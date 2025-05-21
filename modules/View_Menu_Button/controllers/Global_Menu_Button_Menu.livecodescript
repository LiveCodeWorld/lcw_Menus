script "Global | Menu | Button | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Button | Menu
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
   put display_GetObject (tObject) into mButton
   return mButton
end menu_Target

getprop menu_CheckTarget [mButton]
   return exists (mButton)
end menu_CheckTarget


--> Global | Menu | Button | Menu
-
on menu_MenuButtonColour mButton
   set the backgroundcolor of mButton to colour_GetRandom()
end menu_MenuButtonColour

private on _
end _

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Button | Menu")
end submenu_Dev
