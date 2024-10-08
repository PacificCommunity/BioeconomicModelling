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
   ##    Reach into the COMTRADE project and grab its FFA data
   ##
      load("C:/Users/jamesh/GIT/COMTRADE/Data_Output/FFANonSummaryData.rda")
      load("C:/Users/jamesh/GIT/COMTRADE/Data_Intermediate/FFA_Compendium_of_Economic_and_Development_Statistics_2022.rda")

      Purse_Seine_Value <- data.table(FFANonSummaryData[["Value catch nat wat"]])
      
      Purse_Seine_Value <- Purse_Seine_Value[(Purse_Seine_Value$Spreadsheet == "WCPFC-CA_tuna_fisheries_2023") & (Purse_Seine_Value$Data_Row == "10.3 PURSE SEINE"),
                                             list(Total_Value = sum(value,na.rm = TRUE)),
                                             by = .(Measure = Measure, 
                                                    Year = Year)]

      Purse_Seine_Volume <- data.table(FFANonSummaryData[["Catch by national waters"]])
      
      Purse_Seine_Volume <- Purse_Seine_Volume[(Purse_Seine_Volume$Spreadsheet == "WCPFC-CA_tuna_fisheries_2023") & (Purse_Seine_Volume$Data_Row == "6.3 PURSE SEINE"),
                                             list(Total_Volume = sum(value,na.rm = TRUE)),
                                             by = .(Measure = ifelse(Measure == "Australia (includes Norfolk Island)", "Australia",
                                                              ifelse(Measure == "US (includes territories, ex Am Samoa)", "US", Measure)), 
                                                    Year = Year)]

      ##
      ##    There's more fishing catch in the volume measures than the value measures becasue there's international waters and some other things.
      ##
         Purse_Seine_Value_Volume <- merge(Purse_Seine_Value,
                                           Purse_Seine_Volume,
                                           by = c("Measure", "Year"))
                                           
         Purse_Seine_Value_Volume$Measure <- ifelse(Purse_Seine_Value_Volume$Measure == "FSM", "Federated States of Micronesia",
                                             ifelse(Purse_Seine_Value_Volume$Measure == "PNG", "Papua New Guinea", 
                                             ifelse(Purse_Seine_Value_Volume$Measure == "Solomon  Islands", "Solomon Islands",Purse_Seine_Value_Volume$Measure)))

      ##
      ##    Merge with the Compendium :) I love that name :)
      ##
         Purse_Seine_Value_Volume_Revenue <- merge(Purse_Seine_Value_Volume, 
                                                   FFA_Compendium_of_Economic_and_Development_Statistics_2022[FFA_Compendium_of_Economic_and_Development_Statistics_2022$SecondHeading == "Licence and access fee revenue", c("Country", "Year", "Value")],
                                                   by.x = c("Measure", "Year"),
                                                   by.y = c("Country", "Year"),
                                                   all = TRUE)
                                           
         names(Purse_Seine_Value_Volume_Revenue) <- c("Country", "Year", "Total_Value", "Total_Volume", "License_Revenue")


   ##
   ## Save files
   ##
      save(Purse_Seine_Value_Volume_Revenue, file = 'Data_Intermediate/Purse_Seine_Value_Volume_Revenue.rda')
      
##
##    And we're done
##
