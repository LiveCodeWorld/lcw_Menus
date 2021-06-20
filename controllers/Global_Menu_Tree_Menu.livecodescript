script "Global | Menu | Tree | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Menu | Tree | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
   
   put the display_View of tObject into displayView
   --
   put the data_Array of displayView into LocalArray ["dataArray"]
end menu_Init


--> Global | Menu | Tree | Menu
-
on menu_CreateWikiPage displayView
   put menu_GetChecked (the params)
end menu_CreateWikiPage

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_CheckWikiPage displayView
   put displayView
end menu_CheckWikiPage

on menu_EditLibs
   edit the script of stack "lib_MenuAuthoring"
   edit the script of stack "lib_MenuHelp"
end menu_EditLibs


--> Deps
-
