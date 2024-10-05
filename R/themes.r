##    Programme:  themes.r
##
##    Objective:  Graphical themes for IRD
##
##      Author:   James Hogan, Sense Parters, 15 March 2022
##

#------------------Sense Partners Colour Palette-------------------------

# Create a vector to store the colours
IRD_Colours <- c( IR_Teal   	   = rgb(000, 139, 140,  maxColorValue=255),
                  IR_Taupe   	   = rgb(223, 216, 173,  maxColorValue=255),
                  IR_Grey   	   = rgb(076, 087, 098,  maxColorValue=255),
                  
                  IR_DarkTeal	   = rgb(000, 096, 104,  maxColorValue=255),
                  IR_Pink        = rgb(170, 025, 116,  maxColorValue=255),
                  IR_Ruby  	   = rgb(153, 000, 079,  maxColorValue=255),
                  IR_Indigo	   = rgb(097, 033, 102,  maxColorValue=255),

                  IR_OceanBlue   = rgb(000, 066, 107,  maxColorValue=255),
                  IR_Canary	   = rgb(242, 226, 079,  maxColorValue=255),
                  IR_BurntOrange = rgb(211, 071, 031,  maxColorValue=255),
                  IR_Silver      = rgb(145, 153, 159,  maxColorValue=255),
                  IR_Gold        = rgb(164, 150, 113,  maxColorValue=255))

# Create a function for easy reference to combinations of IRD_Colours
IRDColours <- function(x=1:12){
   if(x[1]=="Duo1")  x <- c(1,5)
   if(x[1]=="Duo2")  x <- c(1,4)
   if(x[1]=="Duo3")  x <- c(1,5)
   if(x[1]=="Duo4")  x <- c(1,6)
   if(x[1]=="Duo5")  x <- c(1,7)
   if(x[1]=="Trio1") x <- c(1:3)
   if(x[1]=="Trio2") x <- c(2,6,10)
   if(x[1]=="Trio3") x <- c(2,7,9)
   if(x[1]=="Trio4") x <- c(1,3,12)
   if(x[1]=="Quad1") x <- c(1:3,6)
   if(x[1]=="Quad2") x <- c(4:8)
   as.vector(IRD_Colours[x])
}
