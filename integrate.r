##    Programme:  <NAME OF PROJECT IN HERE>.r
##
##    Objective:  A brief description of what this project is trying to do.
##                This part of the documentation is about describing the big
##                picture purpose of the work. For example, this could be the
##                IRD Top Tax Earners data processing system, created to support analysis
##                and reporting. Or this could be an age/occupation tax forecasting and 
##                modelling system, designed to take a deeper dive into the
##                data and tell us what we know about New Zealand's age/occupation tax 
##                experience.
##
##    Plan of  :  What are the steps in this programme's execution? What does
##    Attack   :  each step do?
##
##                Be explicit about writing the programming steps here - how are
##                you going to start from nothing, and move through the stages 
##                that ultimately result in the final thing.  These steps are 
##                mirrored in the code down below.
##
##                Step 1:
##                Step 2:
##                Step 3:
##                Step 4:
##                Step xxx:
##
##    Important:  Does this programme make any important cross-project data 
##    Linkages :  connections? For example, does it read labs data from HDI?
##                Or does it read forecasting results from Primary Care?
##
##                The focus here is on the important data linkages between this
##                project and something else, so that if that something changes,
##                we can figure out the impact it has on this project.
##
##    Author   :  <PROGRAMMER>, <TEAM>, <DATE STARTED>
##
##    Peer     :  <PROGRAMMER>, <TEAM>, <PEER REVIEWED COMPLETED>
##    Reviewer :
##
   ##
   ##    Clear the decks and load up some functionality
   ##
      rm(list=ls(all=TRUE))
      
   ##
   ##    Core libraries
   ##
      library(ggplot2)
      library(plyr)
      library(stringr)
      library(reshape2)
      library(lubridate)
      library(calibrate)
      library(Hmisc)
      library(RColorBrewer)
      library(stringi)
      library(sqldf)
      library(extrafont)
      library(scales)
      library(RDCOMClient)
      library(extrafont)
      library(tictoc)
   ##
   ##    Project-specific libraries
   ##
      library(xxxx)
      library(xxxx)
      library(xxxx)

   ##
   ##    Set working directory
   ##
      setwd("C:\\SOMEWHERE\\SOMEPROJECT")

   ##
   ##   Modular-programmed code from here down. Each following programme
   ##      needs to be able to 'stand alone' in the sense that it starts of 
   ##       reading all the data it needs, it processes it, and it concludes
   ##       either writing data for a following programme, or creating a final
   ##       output. 
   ##
      ##
      ##    STEP 1:
      ##
         source("Programmes/xxxxxxxx.r") # This does blah blah blah

      ##
      ##    STEP 2:
      ##
         source("Programmes/xxxxxxxx.r") # This does blah blah blah
         source("Programmes/xxxxxxxx.r") # This does blah blah blah
         source("Programmes/xxxxxxxx.r") # This does blah blah blah
         source("Programmes/xxxxxxxx.r") # This does blah blah blah
      ##
      ##    STEP 3:
      ##
         source("Programmes/xxxxxxxx.r") # This does blah blah blah
      ##
      ##    STEP 4:
      ##
         source("Programmes/xxxxxxxx.r") # This does blah blah blah
      ##
      ##    STEP x: Final output
      ##
         source("Programmes/xxxxxxxx.r") # This does blah blah blah

      ##
      ##    Write up of results
      ##      
         rmarkdown::render("Programmes/Write_Up.rmd", output_file = "C:\\SOMEWHERE\\SOMEPROJECT\\Product_Output\\SOME_WRITE_UP.docx")                   


##
##   End of programme
##
