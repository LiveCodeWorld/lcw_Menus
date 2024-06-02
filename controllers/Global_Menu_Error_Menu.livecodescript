script "Global | Menu | Error | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Error | Menu
type: controller
version: 0.1

/*
Keep as simple as possible.
*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return true
end menu_CheckTarget

getprop disabled_DisplayMenuError
   global gLCW
   put gLCW ["Error"]["menu_CheckTarget"] into errorData
   --
   if errorData is an array then
      return false
   else
      return true
   end if
end disabled_DisplayMenuError

private function _MenuErrorData dView
   if exists (dView) then
      put the displayed_Data of dView into errorData
   else
      global gLCW
      put gLCW ["Error"]["menu_CheckTarget"] into errorData
   end if
   return errorData
end _MenuErrorData

private command _DeleteMenuErrorData
   # Now tidy global as we have data in dispayView
   
   global gLCW
   delete variable gLCW ["Error"]["menu_CheckTarget"]
end _DeleteMenuErrorData

private function _MissingMenuController dView
   put _MissingMenuTitle (dView) into mTitle
   put menu_GetGlobalController (mTitle) into mController
   return mController
end _MissingMenuController

private function _MissingMenuTitle dView
   put _MenuErrorData (dView) into errorData
   put errorData ["mTitle"] into mTitle
   return mTitle
end _MissingMenuTitle

getprop disabled_CreateMissingMenu
   put _MissingMenuController() into mController
   return exists (mController) is true
end disabled_CreateMissingMenu

on display_Error dView
   menu_DisplayMenuError dView
end display_Error


--> Global | Menu | Error | Menu
-
on menu_EditMenuController dView
   put _MissingMenuController (dView)into mTitle
   put _MissingMenuController (dView) into mController
   --
   if exists (mController) then
      edit the script of mController
   else
      put "Menu controller:" && mController
      lcw_Answer "Cannot find controller for menu [[var]]", dView, mTitle
   end if
end menu_EditMenuController

on menu_DisplayMenuError dView
   put _MenuErrorData() into errorData
   --
   display_Tool errorData, "_MenuCheckFailed()", "Menu Error"
   --
   _DeleteMenuErrorData
end menu_DisplayMenuError

private on _
end _

on menu_CreateMissingMenu dView
   put _MenuErrorData() into errorData
   --
   put errorData ["mTitle"] -- into mTitle
   
end menu_CreateMissingMenu

on menu_ClearMenuErrorData dView
   _DeleteMenuErrorData
end menu_ClearMenuErrorData
