script "Global | Index | Simple | Colour | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Index | Simple | Colour | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the index_View of tObject into dView
   -- put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | Index | Simple | Colour | Menu
-
on menu_SetTitleColour indexView   
   answer color
   if it is empty then exit to top
   
   put it into someColour
   set the title_Colour of indexView to someColour
   put the result into titleColour
   
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_SetTitleColour

on menu_SetTitleTextColour indexView   
   answer color
   if it is empty then exit to top
   
   put it into someColour
   set the title_TextColour of indexView to someColour
end menu_SetTitleTextColour

on _
end _

on menu_BlackAndWhiteTitle indexView   
   put the title_Colour of indexView into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_BlackAndWhiteTitle

on menu_ReverseTitleColour indexView   
   put the title_Colour of indexView into titleColour
   put colour_GetReverse (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_ReverseTitleColour
