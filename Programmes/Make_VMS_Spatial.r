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
      load('Data_Spatial/PNA_EEZ.rda')
      
   ##
   ##    Grab some vms data and get it ready to parallelise
   ##
      VMS <- fread(file = "Data_Raw/vms.txt")


      Size_of_Loops <- ceiling(nrow(VMS) / 100)

      cl <- makeCluster(detectCores())
      clusterEvalQ(cl, { c(library(sf), library(sp)) }) 
      clusterExport(cl, c("PNA_EEZ"))
      
      for(i in 0:99)
      {
      
       Grab_Obs <- VMS[(i*Size_of_Loops + 1):min(((i+1)*Size_of_Loops), nrow(VMS)),]
       
        Peg_Me <- function(Fistful)
         {
            Fistful_of_Data <- Grab_Obs[Fistful,]
            ##
            ##    Grab their TLAs - both now and previous
            ##

            coordinates(Fistful_of_Data) <- ~ longitude + latitude
            proj4string(Fistful_of_Data) <- CRS("+proj=longlat +datum=WGS84")
            
            Fistful_of_Data <- st_as_sf(Fistful_of_Data)               
            Fistful_of_Data <- st_transform(Fistful_of_Data, st_crs(PNA_EEZ))
            Fistful_of_Data <- st_rotate(Fistful_of_Data)
            
            return(Fistful_of_Data)
         }
         sp <- parallel::clusterSplit(cl, 1:nrow(Grab_Obs))
         clusterExport(cl, c("sp", "Grab_Obs", "Peg_Me", "st_rotate"))  # each worker is a new environment, you will need to export variables/functions to
         
       tic(print(paste("Starting to process loop", i)))
         system.time(ll <- parallel::parLapply(cl, sp, Peg_Me))
         New_VMS <- do.call(rbind, ll)

         assign(paste0("Obs_split_", i, "XXVMS_Split"), New_VMS)
         save(list = paste0("Obs_split_", i, "XXVMS_Split"), 
              file = paste0("Parallel/Obs_split_", i, "XXVMS_Split.rda"))
       toc()
      }
      stopCluster(cl)
    
##
##    Collect them all back up
##   
      Contents <- as.data.frame(list.files(path = "Parallel/",  pattern = "*.rda"))
      names(Contents) = "DataFrames"
      Contents$Dframe <- str_split_fixed(Contents$DataFrames, "\\.", n = 2)[,1]
      Contents <- Contents[str_detect(Contents$DataFrames, "XXVMS_Split"),]

      All_Data <- lapply(Contents$DataFrames, function(File){
                           load(paste0("Parallel/", File))  
                           X <- get(str_split_fixed(File, "\\.", n = 2)[,1])
                           return(X)})
#      rm(list=ls(pattern="Obs_split*"))
      New_VMS <- do.call(rbind, All_Data)
      New_VMS <- st_as_sf(New_VMS)
      save(New_VMS, file = "Data_Spatial/New_VMS.rda")













   
   ##
   ##    make sure the CRS of the point data is the same as the crs of the geometry data, or they'll never map together
   ##
save(VMS, file = 'Data_Spatial/VMS.rda')


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
