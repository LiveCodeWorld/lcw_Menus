script "Global | Menu | Group | Exists | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Group | Exists | Menu
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
   put display_MenuTarget (tObject) into sView
   --
   put the menubar_View of sView into mGroup
   return mGroup
end menu_Target

getprop menu_CheckTarget [mGroup]
   if exists (mGroup) is false then return false
   --
   put the view_Name of mGroup into vName
   return vName = "View|Menu|Group"
end menu_CheckTarget

getprop checked_PreviewMenu
   put menubar_IsDefault() is false into isPreview
   return isPreview
end checked_PreviewMenu

getprop checked_ShowMenu [mGroup]
   if exists (mGroup) is false then return false -- bug should not be needed
   --
   put the show_Menu of mGroup into sBoolean
   return sBoolean
end checked_ShowMenu

getprop checked_ToggleEditMenus [mGroup]
   if exists (mGroup) is false then return false -- bug should not be needed
   
   put the stack_Name of mGroup into stackName
   put the editMenus of stack stackName into sBoolean
   return sBoolean
end checked_ToggleEditMenus

getprop setMenuTitle_Params [mGroup]
   if exists (mGroup) is false then return false -- bug should not be needed
   
   return the menuButton_Names of mGroup
end setMenuTitle_Params

getprop deleteMenuButton_Params [mGroup]
   if exists (mGroup) is false then return true
   --
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   return mButtonNames
end deleteMenuButton_Params

getprop checked_LiveMenu [mGroup]
   if exists (mGroup) is false then return empty
   --
   put the live_Menu of mGroup into sBoolean
   return sBoolean
end checked_LiveMenu


--> Global | Menu | Group | Exists | Menu
-
on menu_DeleteMenuGroup mGroup
   put the stack_Name of mGroup into stackName
   save stack stackName
   --
   put the defaultMenuBar into tOriginalDefaultMenuBar
   set the defaultMenuBar to ide_DefaultMenuGroup()
   --
   delete mGroup
   --
   set the menuBar of stack stackName to empty
   set the defaultMenuBar to tOriginalDefaultMenuBar
end menu_DeleteMenuGroup

on menu_RefreshMenubar mGroup
   dispatch "menuBar_Refresh" to mGroup
end menu_RefreshMenubar

private on _
end _

on menu_NewMenuButton mGroup
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   put the number of lines of mButtonNames into newNum
   add 1 to newNum
   put "Item" && newNum into newName
   
   # Ask
   put lcw_Ask ("Create a new menu button in this stack menu...", newName, "Creat Menu", mGroup) into newButtonName
   
   # Create
   -- menuBar_CreateButton newButtonName, mGroup
   set the new_MenuButton ["Help"] of mGroup to newButtonName
end menu_NewMenuButton

on menu_DeleteMenuButton mGroup, mName
   lcw_Answer "Delete menu button [[mName]]?", mGroup, mName
   --
   dispatch "menuButton_Delete" to mGroup with mName
end menu_DeleteMenuButton

private on __
end __

on menu_SetMenuTitle mGroup, mName
   put the menuButton_Title [mName] of mGroup into mTitle
   put lcw_Ask ("Edit menuButton_Title...", mTitle, "Edit Menu Titles", mGroup) into mTitle
   
   set the menuButton_Title [mName] of mGroup to mTitle
end menu_SetMenuTitle

on menu_EditMenuScript mGroup, mName
   edit the script of btn mName of mGroup
end menu_EditMenuScript

getprop editMenuScript_Params [mGroup]
   if exists (mGroup) is false then return false -- bug should not be needed
   
   return the menuButton_Names of mGroup
end editMenuScript_Params

private on ___
end ___

on menu_LiveMenu mGroup
   put the live_Menu of mGroup into sBoolean
   put sBoolean is false into newStatus
   set the live_Menu of mGroup to newStatus
   --
   put "The Live Menu status is now" && newStatus into sComment
   lcw_Notify sComment
end menu_LiveMenu

on menu_ShowMenu mGroup
   menuBar_ToggleShowMenu mGroup
end menu_ShowMenu

on menu_RefreshLiveMenus.R mGroup
   dispatch "refresh_Menus" to mGroup
end menu_RefreshLiveMenus.R

on menu_ToggleEditMenus mGroup
   menuBar_ToggleEditMenus mGroup
end menu_ToggleEditMenus

on menu_PreviewMenu mGroup
   menubar_TogglePreview mGroup
end menu_PreviewMenu

on menu_ResetDefaultMenubar
   ide_ResetDefaultMenubar
end menu_ResetDefaultMenubar

private on ____
end ____

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

private on _____
end _____

on menu_MenuManagerTools mGroup
   display_MenuManager mGroup
end menu_MenuManagerTools

on menu_MenuGroupBehavior mGroup
   put the behavior of mGroup into bObject
   edit the script of bObject
end menu_MenuGroupBehavior

private on ______
end ______

on menu_DisplayMenubarData mGroup
   put the menubar_Data of mGroup into mBarData
   --
   put the stack_Name of mGroup into stackName
   display_Tool mBarData, stackName, "Menubar Data"
end menu_DisplayMenubarData

on menu_DisplayMenuArray dView
   display_ActiveMenuArray
end menu_DisplayMenuArray

on menu_MenuGroupTools mGroup
   put the view_Name of mGroup into viewName
   display_ModuleTools viewName
end menu_MenuGroupTools

