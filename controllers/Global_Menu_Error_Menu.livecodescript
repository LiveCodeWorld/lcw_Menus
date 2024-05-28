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

private function _MenuErrorData
   global gLCW
   put gLCW ["Error"]["menu_CheckTarget"] into errorData
   return errorData
end _MenuErrorData

private command _DeleteMenuErrorData
   # Now tidy global as we have data in dispayView
   
   global gLCW
   delete variable gLCW ["Error"]["menu_CheckTarget"]
end _DeleteMenuErrorData

private function _MissingMenuController
   put _MenuErrorData() into errorData
   put errorData ["mTitle"] into mTitle
   put menu_GetGlobalController (mTitle) into mController
   return mController
end _MissingMenuController

getprop disabled_CreateMissingMenu
   put _MissingMenuController() into mController
   return exists (mController) is true
end disabled_CreateMissingMenu


--> Global | Menu | Error | Menu
-
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
