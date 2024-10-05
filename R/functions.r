##    Programme:  functions.r
##
##    Objective:  Generic functions for doing something
##
##      Author:   
##

##
##    Put functions in here
##

AskCreds <- function()
{
##    Function: AskCreds
##
##    Objective: This function is designed to pop up a text box that allows
##               the user to enter their username and password crediential at one time
##               and have them available for the rest of the database. 
##
##               It was developed from reading the RGtk2 manual and from 
##                  https://stackoverflow.com/questions/15455692/how-to-return-values-from-gwidgets-and-handlers
##                  https://stackoverflow.com/questions/12558532/populate-a-dataframe-from-spinbuttons-in-rgtk2
##               Inspired by similar functionality from MBIE, but redeveloped from 
##               scratch.
##
##    Author:    James Hogan, Sense Partners, 24 May 2020
##
  library(RGtk2)
   ##
   ## Initialise a window
   ##
      window <- gtkWindow()
      window["title"] <- "Sense Partners for R"
      frame <- gtkFrameNew("AskCreds")
      window$add(frame)
   ##
   ## Add a box to hold the text boxs and the button
   ##
      box1 <- gtkVBoxNew()
      box1$setBorderWidth(30)
      frame$add(box1)  

      box2 <- gtkHBoxNew(spacing= 10) #distance between elements
      box2$setBorderWidth(24)
   ##
   ## Put the text boxs in the first box
   ##
      ##
      ##    Username
      ##
         Ulabel = gtkLabelNewWithMnemonic("UserName") #text label
         box1$packStart(Ulabel)
         UserName <- gtkEntryNew()
         UserName$setWidthChars(25)
         box1$packStart(UserName)
      ##
      ##    Password
      ##
         Password <- gtkEntryNew()
         Password$setWidthChars(25)
         box1$packStart(Password)
         Plabel = gtkLabelNewWithMnemonic("Password") #text label
         box1$packStart(Plabel)
   ##
   ## Put the text boxs in the first box
   ##
      box2 <- gtkHBoxNew(spacing= 10) # distance between elements
      box2$setBorderWidth(24)
      box1$packStart(box2)

      Calculate <- gtkButton("Calculate")
      box2$packStart(Calculate,fill=F) #button which will start calculating

   ##
   ## Put the text boxs in the first box
   ##
   Hold <- list()
   gSignalConnect(Calculate, "clicked", function(entry, ...) {
     if ((UserName$getText() == "") | (Password$getText() == "")) return(invisible(NULL)) #if no text do nothing
      Hold[["UserName"]] <<- UserName$getText()
      Hold[["Password"]] <<- Password$getText()
      window$destroy()
   })
   while(length(Hold) == 0)
   {
      Sys.sleep(.5)   
   }
   return(Hold)
}

##
##    Syntax:
##       Creds <- AskCreds()
##
##    print(Creds)
##








   
   


