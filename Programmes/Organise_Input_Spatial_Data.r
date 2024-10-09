##
##    Programme: Organise_Input_Data.r
##
##    Objective:  What is this programme designed to do?
##
##    Author:     <PROGRAMMER>, <TEAM>, <DATE STARTED>
##
##
   ##
   ##    Clear the memory
   ##
      rm(list=ls(all=TRUE))
   ##
   ##    Load some generic functions
   ##
      source("R/functions.r")
      
   ##
   ##    Read in the EEZs
   ##
      EEZ_Dir  <- "Data_Spatial/EEZ/eez_v12.shp"
      PLW_Dir  <- "Data_Spatial/PLW_shapefiles/PNMS.shp"
      
      PLW0_Dir <- "Data_Spatial/WDPA_Oct2024/WDPA_WDOECM_Oct2024_Public_marine_shp_0/WDPA_WDOECM_Oct2024_Public_marine_shp-polygons.shp"
      PLW1_Dir <- "Data_Spatial/WDPA_Oct2024/WDPA_WDOECM_Oct2024_Public_marine_shp_1/WDPA_WDOECM_Oct2024_Public_marine_shp-polygons.shp"
      PLW2_Dir <- "Data_Spatial/WDPA_Oct2024/WDPA_WDOECM_Oct2024_Public_marine_shp_2/WDPA_WDOECM_Oct2024_Public_marine_shp-polygons.shp"

      ##
      ##   Load the EEZ spatial data
      ##
         #st_layers(EEZ_Dir)
         EEZ <- st_read(dsn = EEZ_Dir, layer = "eez_v12")
         
         ##
         ##    Select only the Pacific Island Countries    
         ##
            EEZ <- EEZ[EEZ$ISO_TER1 %in% iso_codes,]     # iso_codes lives in the R/functions.r file
            EEZ <- ms_simplify(EEZ, keep_shapes = TRUE)
            EEZ_subset <- st_rotate(EEZ)                 # st_rotate lives in the R/functions.r file
            
           
            # st_read(dsn = here("raw_data", "spatial", "EEZ"),
                    # layer = "eez_v10") %>% 
              # filter(ISO_Ter1 %in% iso_codes) %>% 
              # ms_simplify(keep_shapes = T) %>% 
              # st_rotate() %>% 
              # group_by(ISO_Ter1) %>% 
              # summarize() %>% 
              # st_write(here("data", "spatial", "EEZ_subset.gpkg"))

            # END OF SCRIPT

      ##
      ##   Extract the Parties to the Nauru Agreement
      ##
           PNA_EEZ <- EEZ[EEZ$ISO_TER1 %in% PNA_codes,]     # PNA_codes lives in the R/functions.r file
           PNA_EEZ <- st_rotate(PNA_EEZ)
      ##
      ##   Load the Palua spatial data
      ##
         #st_layers(PLW_Dir)
         PNMS <- st_read(dsn = PLW_Dir, layer = "PNMS")

         PNMS$WDPAID <- 555622118
         PNMS$ISO3   <- "PLW"

         PNMS <- ms_simplify(PNMS, keep_shapes = TRUE)
         PNMS <- st_rotate(PNMS)                           
         
      ##
      ##   Load the Marine Protection Areas spatial data
      ##
         #st_layers(PLW0_Dir)
         LSMPAs <- rbind(st_read(dsn = PLW0_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"),
                         st_read(dsn = PLW1_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"),
                         st_read(dsn = PLW2_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"))

         LSMPAs <- LSMPAs[(LSMPAs$GIS_AREA > 30000) & 
                          (LSMPAs$WDPAID  != 555622118),]
         LSMPAs <- ms_simplify(LSMPAs, keep_shapes = TRUE)
         LSMPAs <- st_rotate(LSMPAs)                       

         LSMPAs <- rbind(LSMPAs[,c("WDPAID","ISO3")],
                         PNMS[,  c("WDPAID","ISO3")])
                         
      ##
      ##   Identify the Pheonix Island Protected Area
      ##
         PIPA <- LSMPAs[LSMPAs$WDPAID == 309888, ]


   ##
   ## Save files
   ##
      save(EEZ_subset, file = 'Data_Spatial/EEZ_subset.rda')
      save(PNA_EEZ,    file = 'Data_Spatial/PNA_EEZ.rda')
      save(LSMPAs,     file = 'Data_Spatial/LSMPAs.rda')
      save(PIPA,       file = 'Data_Spatial/PIPA.rda')
      
##
##    And we're done
##
