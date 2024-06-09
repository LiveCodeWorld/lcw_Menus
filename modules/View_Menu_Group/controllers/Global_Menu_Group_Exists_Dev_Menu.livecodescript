script "Global | Menu | Group | Exists | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Group | Exists | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
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

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Menu | Group | Exists | Dev | Menu
-
on menu_LiveMenu mGroup
   put the live_Menu of mGroup into sBoolean
   put sBoolean is false into newStatus
   set the live_Menu of mGroup to newStatus
   --
   put "The Live Menu status is now" && newStatus into sComment
   lcw_Notify sComment
end menu_LiveMenu

getprop checked_LiveMenu [mGroup]
   if exists (mGroup) is false then return empty
   --
   put the live_Menu of mGroup into sBoolean
   return sBoolean
end checked_LiveMenu

on menu_ToggleEditMenus mGroup
   menuBar_ToggleEditMenus mGroup
end menu_ToggleEditMenus

getprop checked_ToggleEditMenus [mGroup]
   if exists (mGroup) is false then return false -- bug should not be needed
   
   put the stack_Name of mGroup into stackName
   put the editMenus of stack stackName into sBoolean
   return sBoolean
end checked_ToggleEditMenus

on menu_ReorderMenus mGroup
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   replace CR with comma in mButtonNames
   
   # Ask
   put lcw_Ask ("Reorder these menu names...", mButtonNames, "Creat Menu", mGroup) into newButtonNames
   
   set the menuBar_ButtonNames of mGroup to newButtonNames
end menu_ReorderMenus

on menu_LayoutMenuButtons mGroup
   dispatch "LayoutControl" to mGroup
end menu_LayoutMenuButtons

on menu_DisplayMenuArray dView
   display_ActiveMenuArray
end menu_DisplayMenuArray

on menu_MenuGroupTools mGroup
   put the view_Name of mGroup into viewName
   display_ModuleTools viewName
end menu_MenuGroupTools
