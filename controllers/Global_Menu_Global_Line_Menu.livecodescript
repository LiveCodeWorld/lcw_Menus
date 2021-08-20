script "Global | Menu | Global | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Global | Line | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray


--> Menu | Init
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   return displayView
end menu_Target

private function _GetGlobalMenuTitle displayView
   -- bug: can be empty
   put the selected_Path of displayView into pathItems
   if pathItems is empty then
      put the selected_Line of displayView into gMenuTitle
   else
      put item 1 of pathItems into gMenuTitle
   end if
   return gMenuTitle
end _GetGlobalMenuTitle

getprop menu_CheckTarget [displayView]
   return _WithinGlobalMenusTree (displayView)
end menu_CheckTarget

private function _WithinGlobalMenusTree displayView
   put display_FindView ("Global Menus", "From Disk") into gDisplayView
   put the stack_Name of displayView into tName
   put the stack_Name of gDisplayView into gName 
   if tName = gName then
      return true
   else
      return false
   end if
end _WithinGlobalMenusTree

private function _SelectedMenuController displayView
   put the top_Array of displayView into tArray
   put tArray ["mController"] into mController
   return mController
end _SelectedMenuController

getprop moveController_Param [displayView]
   put _GetGlobalMenuTitle (displayView) into gMenuTitle
   if exists (stack gMenuTitle) is false then return empty
   put the project_Name of stack gMenuTitle into projectName
   return projectName
end moveController_Param

getprop moveController_Params
   return library_ListProjectNames()
end moveController_Params

getprop disabled_MoveController [displayView]
   put _GetGlobalMenuTitle (displayView) into gMenuTitle
   if gMenuTitle is empty then return true
   put menu_GetGlobalController (gMenuTitle) into mController
   return exists (mController) is false
end disabled_MoveController


--> Global | Menu | Global | Line | Menu
-
on menu_MoveController displayView, newProjectName
   put _GetGlobalMenuTitle (displayView) into gMenuTitle
   put menu_GetGlobalController (gMenuTitle) into mController
   --
   ask_MoveMenu mController, gMenuTitle, newProjectName, displayView 
end menu_MoveController

on menu_EditMenu displayView
   put _GetGlobalMenuTitle (displayView) into gMenuTitle
   if gMenuTitle is empty then
      -- bug
      put _SelectedMenuController (displayView) into mController
      edit the script of mController
   else
      menu_Edit gMenuTitle
   end if
end menu_EditMenu

on menu_ReindexMenu displayView
   put _SelectedMenuController (displayView) into mController
   --
   menu_ReIndexController mController
   put the result into projectArray
   --
   display_Data projectArray, "projectArray", "gMenuTitle"
   display_EnvironmentMenus
end menu_ReindexMenu

on menu_FixMenuName displayView
   put _SelectedMenuController (displayView) into mController
   --
   ask_FixMenuControllerStackName mController
   put the result into newStackName
   --
   display_EnvironmentMenus
end menu_FixMenuName

on _
end _

on menu_DisplayProjectMenus displayView
   put _SelectedMenuController (displayView) into mController
   put the project_Name of mController into projectName
   --
   display_ProjectControllers projectName
end menu_DisplayProjectMenus

on _
end _

on menu_RemoveGlobalMenu displayView
   put _GetGlobalMenuTitle (displayView) into gMenuTitle
   --
   menu_RemoveGlobalController gMenuTitle
   --
   display_EnvironmentMenus
end menu_RemoveGlobalMenu

on menu_Refresh
   display_EnvironmentMenus
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on _FixBadController displayView
   put _GetGlobalMenuTitle (displayView) into gMenuTitle
   --
   lcw_Answer "Do you want to update gMenuArray for global menu '[[gMenuTitle]]'?", displayView, gMenuTitle
   --
   if exists (stack gMenuTitle) is false then
      lcw_AnswerWarning "Cannot locate stack '[[gMenuTitle]]'. Probably named badly?", displayView, gMenuTitle
   end if
   --
   breakpoint
   --
   put merge ("Choose '[[gMenuTitle]]' menu controller...") into someQuestion
   put the controller_Folder of stack gMenuTitle into cFolder
   put file_Choose (someQuestion, cFolder, "livecodescript") into newStackPath
   put the long id of stack newStackPath into mController
   -- 
   put the script_MenuTitleTableArray of mController into mTitleTableArray
   _UpdateGlobalArray mController, mTitleTableArray
   put the result into menuTitleArray
   put menu_GetGlobalArray() into gMenuArray
   --
   put revRuggedId (mController) into ruggedController
   put ruggedController into dArray [gMenuTitle]["mController"]
   --
   set the displayed_Array of displayView to dArray
   put display_FindView ("Global Menus", "From Disk") into gDisplayView
   if exists (gDisplayView) then
      set the displayed_Array of gDisplayView to gMenuArray
   end if
   --
   lcw_AnswerWarning "Updated gMenuArray and diplay views"
end _FixBadController

private command _UpdateGlobalArray mController, mTitleTableArray
   global gLCW
   menu_DeleteActiveArray
   
   put revRuggedId (mController) into mController
   --
   repeat for each key gMenuTile in mTitleTableArray
      if word 1 of gMenuTile = "Global" and word 2 of gMenuTile = "|" then
         put mTitleTableArray [gMenuTile] into gMenuTable
         
         -- menu_NormalizeTitle gMenuTile
         put gMenuTable into gLCW ["Global Menus"][gMenuTile]["gMenuTable"]
         put mController into gLCW ["Global Menus"][gMenuTile]["mController"]
         
         -- probably not really needed
         put gMenuTable into menuTitleArray [gMenuTile]["gMenuTable"]
         put mController into menuTitleArray [gMenuTile]["mController"]
      end if
   end repeat
   --
   return menuTitleArray
end _UpdateGlobalArray


