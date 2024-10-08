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

load("Data_Raw/vessel_info_pna_purse_seines.rds")

   ##
   ## Save files
   ##
      save(Purse_Seine_Value_Volume_Revenue, file = 'Data_Intermediate/Purse_Seine_Value_Volume_Revenue.rda')
      
##
##    And we're done
##
