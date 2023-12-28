script "Global | Menu | Camera | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Camera | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Menu | Camera | Dev | Menu
-
on menu_DevHelp mView
   put the params
end menu_DevHelp

on menu_RenameTwo mView
   set the menuItem_Name [2] of mView to "Recording"
end menu_RenameTwo

on menu_SetRecordMenu mView
   set the menu_GroupData of mView to empty
   set the menu_Title [1] of mView to "Global | Camera | Menu"
   set the menu_Title [2] of mView to "Global | Camera | Recording | Menu"
   set the menu_Title [3] of mView to "Global | Screen | Record | Menu"
   set the menu_Title [4] of mView to "Global | Menu | Camera | Menu"
end menu_SetRecordMenu
