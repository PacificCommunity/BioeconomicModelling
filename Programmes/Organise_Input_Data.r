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
      EEZ_Dir <- "Data_Spatial/EEZ/eez_v12.shp"
      PLW_Dir <- "Data_Spatial/EEZ/PLW_shapefiles.shp"
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

      ##
      ##   Load the Palua spatial data
      ##
         #st_layers(PLW0_Dir)
         LSMPAs <- rbind(st_read(dsn = PLW0_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"),
                         st_read(dsn = PLW1_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"),
                         st_read(dsn = PLW2_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"))

         LSMPAs$WDPAID <- 555622118
         LSMPAs$ISO3   <- "PLW"

         LSMPAs <- ms_simplify(LSMPAs, keep_shapes = TRUE)
         LSMPAs <- st_rotate(LSMPAs)                 # st_rotate lives in the R/functions.r file
      ##
      ##   Load the Marine Protection Areas spatial data
      ##
         #st_layers(PLW0_Dir)
         LSMPAs <- rbind(st_read(dsn = PLW0_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"),
                         st_read(dsn = PLW1_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"),
                         st_read(dsn = PLW2_Dir, layer = "WDPA_WDOECM_Oct2024_Public_marine_shp-polygons"))

         LSMPAs$WDPAID <- 555622118
         LSMPAs$ISO3   <- "PLW"

         LSMPAs <- ms_simplify(LSMPAs, keep_shapes = TRUE)
         LSMPAs <- st_rotate(LSMPAs)                 # st_rotate lives in the R/functions.r file

   ##
   ## Save files our produce some final output of something
   ##
      save(EEZ_subset, file = 'Data_Spatial/EEZ_subset.rda')
      save(PNA_EEZ,    file = 'Data_Spatial/PNA_EEZ.rda')
      
##
##    And we're done
##

# The PNMS lines are different
pnms <- st_read(here("raw_data", "spatial", "PLW_shapefiles"),
                "PNMS") %>% 
  mutate(WDPAID = 555622118,
         ISO3 = "PLW") %>% 
  select(WDPAID, ISO3) %>% 
  ms_simplify(keep_shapes = T) %>% 
  st_rotate()

# Load the database
st_read(here::here("raw_data", "spatial", "WDPA_Jan2019"),
        layer = "WDPA_Jan2019_marine-shapefile-polygons",
        quiet = T,
        stringsAsFactors = F) %>% 
  filter(GIS_M_AREA > 30000,                            ### Keep LSMPAs only
         !WDPAID == 555622118) %>%                      ### Remove the PNMS, which has new boundaries
  ms_simplify(keep_shapes = T) %>% 
  st_rotate() %>% 
  select(WDPAID, ISO3) %>% 
  rbind(pnms) %>% 
  arrange(WDPAID) %>% 
  st_write(dsn = here("data", "spatial", "LSMPAs.gpkg")) #Save to file

# END OF SCRIPT