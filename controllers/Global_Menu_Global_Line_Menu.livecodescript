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
   put tObject into LocalArray ["tObject"]
   --
   put the selected_Path of tObject into pathItems
   if pathItems is empty then
      put the selected_Line of tObject into gMenuTitle
   else
      put item 1 of pathItems into gMenuTitle
   end if
   return gMenuTitle
end menu_Target

getprop menu_CheckTarget [mTarget]
   return _WithinGlobalMenusTree()
end menu_CheckTarget

private function _SelectedMenuController
   put LocalArray ["tObject"] into tObject
   --
   put the top_Array of tObject into tArray
   put line 1 of the keys of tArray into tGlobalMenu
   put tArray [tGlobalMenu]["mController"] into mController
   return mController
end _SelectedMenuController

private function _WithinGlobalMenusTree
   put LocalArray ["tObject"] into tObject
   put display_FindView ("Global Menus", "From Disk") into gDisplayView
   put the stack_Name of tObject into tName
   put the stack_Name of gDisplayView into gName 
   if tName = gName then
      return true
   else
      return false
   end if
end _WithinGlobalMenusTree


--> Global | Menu | Global | Line | Menu
-
on menu_EditMenu gMenuTitle
   menu_Edit gMenuTitle
end menu_EditMenu

on _
end _

on menu_FixMenuName gMenuTitle
   --  put menu_GetGlobalController (gMenuTitle) into mController
   put _SelectedMenuController() into mController
   --
   controller_AskFixMenuName mController
   put the result into newStackName
   --
   display_GlobalMenus
end menu_FixMenuName

on menu_DisplayProjectMenus gMenuTitle
   put _SelectedMenuController() into mController
   put the project_Name of mController into projectName
   --
   display_ProjectControllers projectName
end menu_DisplayProjectMenus

on _
end _

on menu_Refresh
   display_GlobalMenus
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_FixBadController gMenuTitle
   put LocalArray [tObject] into tObject
   put the display_View of tObject into displayView
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
   menu_UpdateGlobalArray mController, mTitleTableArray
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
end menu_FixBadController


