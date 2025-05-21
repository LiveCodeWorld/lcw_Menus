script "Global | Index | Simple | Menu"
--> MetaData
-
license: GPLv3
name: Global | Index | Simple | Menu
type: controller
version: 0.3


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   put the index_View of tObject into indexView
   return indexView
end menu_Target

getprop stackStyle_Param [displayView]
   put the stack_Style of displayView into sStyle
   return sStyle
end stackStyle_Param

getprop stackStyle_Params
   return "toplevel,palette,system"
end stackStyle_Params

getprop disabled_FindDropCommand [indexView]
   put the drop_Command of indexView into dropCommand
   if dropCommand is empty then
      return true
   else
      return false
   end if
end disabled_FindDropCommand
   
getprop systemWindow_Param [displayView]
   put the stack_Style of displayView into sStyle
   return sStyle = "system"
end systemWindow_Param

getprop systemWindow_Params
   return "true,false"
end systemWindow_Params


--> Global | Index | Simple | Menu
-
on menu_StackStyle displayView, someStyle
   set the stack_Style of displayView to someStyle
end menu_StackStyle

on submenu_Colour
   return "Global | Index | Simple | Colour | Menu"
end submenu_Colour

on submenu_Style
   return "Global | Index | Simple | Style | Menu"
end submenu_Style

private on _
end _

on menu_SetHeaderHeight indexView
   put the header_Height of indexView into sHeight
   put lcw_Ask ("Set the height of the header...", sHeight) into sHeight
   set the header_Height of indexView to sHeight
end menu_SetHeaderHeight

on menu_FormattedWidth dView
   put the formatted_Width of dView into fWidth
   set the stack_Width of dView to fWidth
end menu_FormattedWidth

on menu_FormattedHeight dView
   put the formatted_Height of dView into fHeight
   set the stack_Height of dView to fHeight
end menu_FormattedHeight

private on __
end __

on menu_ChangeTitleMenu indexView
   put the title_Menu of indexView into mTitle   
   put lcw_Ask ("Set the title_Menu to...", mTitle) into mTitle
   set the title_Menu of indexView to mTitle   
end menu_ChangeTitleMenu

on menu_TitleMenuScript indexView
   put the title_Menu of indexView into mTitles     
   set the itemdelimiter to tab
   repeat for each line titleLine in mTitles
      if titleLine = "-" then next repeat
      put item 1 of titleLine into mTitle
      --
      menu_Edit mTitle
   end repeat
end menu_TitleMenuScript

on menu_ChangeLineMenu indexView
   put the line_Menu of indexView into mTitle   
   put lcw_Ask ("Set the line_Menu to...", mTitle) into mTitle
   set the line_Menu of indexView to mTitle   
end menu_ChangeLineMenu

on menu_LineMenuScript indexView
   put the line_Menu of indexView into mTitle
   menu_Edit mTitle
end menu_LineMenuScript

private on ___
end ___

on menu_ChangeDoubleClick indexView
   put the mouse_DoubleUp of indexView into mDoubleUp
   put lcw_Ask ("Edit the mouse_DoubleUp of indexView", mDoubleUp) into mDoubleUp
   --
   set the mouse_DoubleUp of indexView to mDoubleUp
end menu_ChangeDoubleClick

on menu_FindDoubleClickHandler indexView
   put the mouse_DoubleUp of indexView into mDoubleUp
   put "M" && mDoubleUp into shortHkey
   --
   put the mouse_Target of indexView into mTarget
   if exists (mTarget) is false then
      lcw_AnswerWarning "The mouse_Target of [[indexView]] does not exist!", indexView, indexView
   end if
   
   put the found_Hkey [shortHkey] of mTarget into hKey
   if hKey is empty then
      put shortHkey
      lcw_AnswerWarning "Cannot locate [[shortHkey]]", indexView, shortHkey
   else
      hkey_Edit hKey
   end if
end menu_FindDoubleClickHandler

private on ____
end ____

on menu_InspectView indexView
   display_ObjectProperties indexView
end menu_InspectView

on menu_InspectTitleView indexView
   put the title_View of indexView into titleView
   display_ObjectProperties titleView
end menu_InspectTitleView

on menu_InspectIndexField indexView
   put the index_Field of indexView into indexField
   display_ObjectProperties indexField
end menu_InspectIndexField

private on ______
end ______

on menu_ShowIndexTemplate indexView
   put the stack_Loc of indexView into gStackLoc
   display_ViewTemplate "View|Index|Simple", gStackLoc
end menu_ShowIndexTemplate

on menu_EditViewBehavior indexView
   put the behavior of indexView into bObject
   edit the script of bObject
end menu_EditViewBehavior

private on _____
end _____

on menu_SetLines indexView
   put the displayed_Lines of indexView into sLines
   --
   replace CR with comma in sLines
   put lcw_Ask ("Edit lines...", sLines, indexView) into sLines
   replace comma with CR in sLines
   --
   set the displayed_Lines of indexView to sLines 
end menu_SetLines

on menu_LayoutControl indexView
   dispatch "LayoutControl" to indexView
end menu_LayoutControl

on submenu_Dev
   return menu_DevTitle()
end submenu_Dev
