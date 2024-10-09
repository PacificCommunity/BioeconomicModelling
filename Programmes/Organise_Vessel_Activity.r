##
##    Programme: Organise_Vessel_Activity.r
##
##    Objective: 
##
####################################################################################
# This query will extract all vessels that evr fished
# in the PNA, and then assign them to groups based on
# when and where they fished. There are two groups:
# - "displaced": vessels that fished inside PIPA before Jan, 2015 and continued to
#    fish elsewhere
# - "non-displaced": vessels that never fished inside PIPA before Jan, 2015, and that
#   we observe before and after the closure of PIPA
#
############################
#
# The query will proceed in the following way:
# 1) Create a subquery that contains the EEZ identifiers (numeric) based on the known
#     iso3 codes for PAN countries
# 2) Create a subquery for all vessels that ever fished within these EEZs. Here, we'll
#     define fishing as having a neural net score of nnet_score > 0.5
# 3) Then, create a subquery of all vessel tracks (that is, with lat lon positions)
#     for all vessels that ever fished in PNA countries
# 4) Create a spatial table using the PIPA shapefile
# 5) Intersect the vessel tracks with the PIPA shapefile to find vessels that fished
#     within PIPA before Jan, 2015 (these are the "displaced" vessels)
# 6) Create a table of ssvid and group
#
######################################################################################
##
##
##
##
##    Author:     <PROGRAMMER>, <TEAM>, <DATE STARTED>
##
##
   ##
   ##    Clear the memory
   ##
      rm(list=ls(all=TRUE))
      
   ##
   ##    load some colour themes and spatial functions
   ##
      source("R/themes.r")
      source("R/functions.r")

   ##
   ##    Grab some spatial data
   ##
      load('Data_Spatial/EEZ_subset.rda')
      load('Data_Spatial/PNA_EEZ.rda')
   
   ##
   ##    Open a ODBC Connection to SPC databases
   ##
      db2 <- odbcDriverConnect("driver=SQL Server;server=noufameSQL01")

      ##
      ##    Extract vessel activity metrics. 
      ##       tufman2.vms.vms_trips = a VMS-derived record of unique vessel IDs (based on VMS data), departing and returning to ports, 
      ##                               at specific datetimes.
      ##
      ##       tufman2.vms.vms_trip_efforts = a linked record of the time spent in different EEZ's, the number of days are sea[in the EEZ]
      ##                                      and the number of "day_fishing"
      ##
      ##                                      EEZ code spatially described here: [tufman2].[ref].[eez_definitions]
      ##
      ##       tufman2.ref.vessels = a linked record to the VMS-derived unique vessel_id which links to the vessel's gear. 
      ##                             Gear can derived from here: [tufman2].[ref].[gears]
      ##
      ##       tufman2.ref.vessel_instances = a point in time record of what is the vessel_id known by at different time, and how is it
      ##                                      flagged
      ##
      ##       log_master.log.trips_ps = looks like an older datasource, containing older metrics of vessels, flags, departure and return ports
      ##                                 
      ##       log_master.ref.vessel = gives basic details for what we knew about that vessel at that time. Note the link between vessel and trips_ps
      ##                               is through trips_ps.vfp_boat_id = vessel.BOAT_ID. 
      ##                               Also, it looks like log_master.ref.vessel.ref2_guid is the same variable as tufman2.ref.vessels.vessel_id
      ##                               since Tiffany later appends them together 
      ##
      ##       log_master.log.sets_ps = Looks to be a specific Purse seine table (there's also sets_ll, sets_pl, and sets_tr) with a catch-all "in_wcpfc_area"
      ##                                variable. 
      ##

        ##
        ##     Get the number of vessels that have ever fished inside of the PNA waters. And for giggles, lets get where they travelled.
        ##
         Vessel_Ever_Fished_PNA = data.table(sqlQuery(db2,
                                                      "SELECT vi.vessel_id,
                                                              vi.vesselname,
                                                              t.departure_date,
                                                              t.return_date,
                                                              e.eez_code,
                                                              country.country_name,
                                                              VMS.latitude,
                                                              VMS.longitude,
                                                              VMS.date_time as AsAtDateTime
                                                        FROM tufman2.vms.vms_trips t 
                                                           INNER JOIN tufman2.vms.vms_trip_efforts e  ON (t.vms_trip_id = e.vms_trip_id)
                                                           INNER JOIN tufman2.ref.vessels v           ON (v.vessel_id   = t.vessel_id)
                                                           INNER JOIN tufman2.ref.vessel_instances vi ON ((vi.vessel_id  = v.vessel_id)
                                                                                                              AND 
                                                                                                          (t.departure_date BETWEEN vi.start_date AND vi.calculated_end_date))
                                                           INNER JOIN tufman2.ref.countries country   ON (e.eez_code = country.country_code)
                                                           INNER JOIN vms.dbo.vms_position VMS        ON ((v.vessel_id = VMS.vessel_id)
                                                                                                              AND 
                                                                                                          (VMS.date_time BETWEEN t.departure_date AND t.return_date))
                                                           
                                                        where v.gear = 'S'                                                                  -- Purse seine gear
                                                          and not (flag_id = 'PH' and e.eez_code in ('ID','I1','PH','PW','I3','I4'))       -- and not Phillipino flagged vessels located in Indonesian, Palau, Phillipine or international waters
                                                          and flag_id not in ('ID','VN','BN','SG')                                         -- and not flagged to Brunei, Indonesia, Singapore or Vietnam
                                                          and e.eez_code in ('FM','KI','MH','NR','PG','PW','SB','TK','TV')                 -- and having fished in in Parties to the Nauru Agreement waters
                                                          and day_fishing > 0                                                              -- and having spent some time fishing there
                                                          and year(departure_date) >= 2014                                                 -- anytime after 2013
                                                                                                                                           --
                                                          -- and v.vessel_id = 'FD8F6698-B821-0BCD-159D-39D163386E42'                      -- REMOVED put a little test in to restrict output for a smidgeon
                                                      "))



   coordinates(Vessel_Ever_Fished_PNA) <- ~ longitude + latitude
   proj4string(Vessel_Ever_Fished_PNA) <- CRS("+proj=longlat +datum=WGS84")
   
   Vessel_Ever_Fished_PNA <- st_as_sf(Vessel_Ever_Fished_PNA)   
   
   ##
   ##    make sure the CRS of the point data is the same as the crs of the geometry data, or they'll never map together
   ##
   Vessel_Ever_Fished_PNA <- st_transform(Vessel_Ever_Fished_PNA, st_crs(PNA_EEZ))
   Vessel_Ever_Fished_PNA <- st_rotate(Vessel_Ever_Fished_PNA)
   

##
##    Show me a map of 
##  
     showtext_auto()

   ggplot() + 
     geom_sf(data = PNA_EEZ,  color = "red", fill = SPCColours("Light_Blue")) +
     geom_sf(data = Vessel_Ever_Fished_PNA, size = 0.05, alpha = 0.05) +
     coord_sf(datum = NA) +
     theme_bw(base_size=12, base_family =  "Calibri") %+replace%
     theme(legend.title.align=0.5,
           plot.margin = unit(c(1,3,1,1),"mm"),
           panel.border = element_blank(),
           strip.background =  element_rect(fill   = SPCColours("Light_Blue")),
           strip.text = element_text(colour = "white", 
                                     size   = 13,
                                     family = "MyriadPro-Bold",
                                     margin = margin(1.25,1.25,1.25,1.25, unit = "mm")),
           panel.spacing = unit(1, "lines"),                                              
           legend.text   = element_text(size = 10, family = "MyriadPro-Regular"),
           plot.title    = element_text(size = 24, colour = SPCColours("Dark_Blue"),  family = "MyriadPro-Light"),
           plot.subtitle = element_text(size = 14, colour = SPCColours("Light_Blue"), family = "MyriadPro-Light"),
           plot.caption  = element_text(size = 10,  colour = SPCColours("Dark_Blue"), family = "MyriadPro-Light", hjust = 1.0),
           plot.tag      = element_text(size =  9, colour = SPCColours("Red")),
           axis.title    = element_text(size = 14, colour = SPCColours("Dark_Blue")),
           axis.text.x   = element_text(size = 14, colour = SPCColours("Dark_Blue"), angle = 00, margin = margin(t = 10, r = 0,  b = 0, l = 0, unit = "pt"),hjust = 0.5),
           axis.text.y   = element_text(size = 14, colour = SPCColours("Dark_Blue"), angle = 00, margin = margin(t = 0,  r = 10, b = 0, l = 0, unit = "pt"),hjust = 1.0),
           legend.key.width = unit(1, "cm"),
           legend.spacing.y = unit(1, "cm"),
           legend.margin = margin(10, 10, 10, 10),
           legend.position  = "bottom")


      
##
##    And we're done
##
   save(Vessel_Ever_Fished_PNA, file = 'Data_Spatial/Vessel_Ever_Fished_PNA.rda')
