﻿script "Global | Menu | Group | Help | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Group | Help | Menu
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
   -- put display_MenuTarget (tObject) into dView
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Menu | Group | Help | Menu
-
on menu_Dictionary
   revIDEDocumentationLoad "API", "LiveCode Script"
end menu_Dictionary

on menu_MessageWatcher
   revIDEOpenPalette "message watcher"
end menu_MessageWatcher

on menu_SuspendDevelopmentTools
   revIDESuspendDevelopmentTools
end menu_SuspendDevelopmentTools

private on _
end _

on menu_PluginSettings
   revIDEOpenPalette "plugin preferences"
end menu_PluginSettings

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on menu_RevMenuBarScript wikiView
   edit the script of ide_DefaultMenuBarStack()
end menu_RevMenuBarScript

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Help | Menu")
end submenu_Dev
