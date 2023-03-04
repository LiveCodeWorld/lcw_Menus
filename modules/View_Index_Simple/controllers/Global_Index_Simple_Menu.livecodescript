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
   -- mTarget is set to the displayed_Object of indexView by the indexView
   -- for these tools we need to reset the target
   if exists (tObject) is false then
      pass menu_Target
   end if
   
   put the index_View of tObject into indexView
   return indexView
end menu_Target

getprop fieldAlign_Param [indexView]
   put the field_Align of indexView into fStyle
   return fStyle
end fieldAlign_Param

getprop fieldAlign_Params [indexView]
   if exists (indexView) is false then return empty
   put the field_Aligns of indexView into fStyles
   return fStyles
end fieldAlign_Params

getprop fieldStyle_Param [indexView]
   put the field_Style of indexView into fStyle
   return fStyle
end fieldStyle_Param

getprop fieldStyle_Params [indexView]
   if exists (indexView) is false then return empty
   put the field_Styles of indexView into fStyles
   return fStyles
end fieldStyle_Params

getprop dontWrap_Param [indexView]
   put the dont_Wrap of indexView into someBoolean
   return someBoolean
end dontWrap_Param

getprop dontWrap_Params
   return "true,false"
end dontWrap_Params

getprop setMenuTitle_Params
   return "Card,Button,Tools,-,Ask"
end setMenuTitle_Params

getprop setMenuTitle_Param [indexView]
   put the menu_Controller of indexView into someObject
   switch someObject
      case the card_Object of indexView
         return "Card"
      case the menu_Button of indexView
         return "Button"
      case menu_GetGlobalController ("Global | Index | Simple | Menu")
         return "Tools"
      default
         return "Ask"
   end switch
end setMenuTitle_Param

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

private on _____
end _____

on menu_EditTitleMenu indexView
   put the title_Menu of indexView into mTitles     
   set the itemdelimiter to tab
   repeat for each line titleLine in mTitles
      if titleLine = "-" then next repeat
      put item 1 of titleLine into mTitle
      menu_Edit mTitle
   end repeat
end menu_EditTitleMenu

on menu_EditLineMenu indexView
   put the line_Menu of indexView into mTitle
   menu_Edit mTitle
end menu_EditLineMenu

on menu_ChangeTitleMenu indexView
   put the title_Menu of indexView into mTitle   
   put lcw_Ask ("Set the title_Menu to...", mTitle) into mTitle
   set the title_Menu of indexView to mTitle   
end menu_ChangeTitleMenu

on menu_ChangeLineMenu indexView
   put the line_Menu of indexView into mTitle   
   put lcw_Ask ("Set the line_Menu to...", mTitle) into mTitle
   set the line_Menu of indexView to mTitle   
end menu_ChangeLineMenu

private on _
end _

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

on menu_ChangeDoubleClickHandler indexView
   put the mouse_DoubleUp of indexView into mDoubleUp
   put lcw_Ask ("Edit the mouse_DoubleUp of indexView", mDoubleUp) into mDoubleUp
   --
   set the mouse_DoubleUp of indexView to mDoubleUp
end menu_ChangeDoubleClickHandler

on menu_EditMouseTarget indexView
   put the mouse_Target of indexView into mTarget
   if exists (mTarget) then
      edit the script of mTarget
   else
      lcw_AnswerWarning "The mouse_Target has not been set for this view", indexView
   end if
end menu_EditMouseTarget

private on __
end __

on menu_FindDropCommand indexView
   put the drop_Command of indexView into dropCommand
   put "M" && dropCommand into shortHkey
   --
   put the mouse_Target of indexView into mTarget
   if exists (mTarget) then
      put the found_Hkey [shortHkey] of mTarget into hKey
      hkey_Edit hKey
   else
      lcw_AnswerWarning "Cannot locate [[shortHkey]]", indexView, shortHkey
   end if
end menu_FindDropCommand

on menu_SetDropCommand displayView
   put the drop_Command of displayView into dropCommand
   if dropCommand is empty then put "drop_Wiki" into dropCommand
   put lcw_Ask ("What drop_Command would you like for this view?", dropCommand, displayView) into dCommand
   set the drop_Command of displayView to dCommand
end menu_SetDropCommand

on menu_DisplayMenuArray displayView
   put the script_MenuArray ["Global | Index | Simple | Menu"] of displayView into mArray
   display_Array mArray
end menu_DisplayMenuArray

private on ___
end ___

on menu_EditViewBehavior indexView
   put the behavior of indexView into bObject
   edit the script of bObject
end menu_EditViewBehavior

on menu_SetStandardBehavior displayView   
   put the view_BehaviorStackName of displayView into stackName
   put the name of stack stackName into bObject
   --
   set the behavior of displayView to bObject
   --
   if there is a stack "behavior_ViewTemplateCard" then
      set the behavior of cd 1 of me to the name of stack "behavior_ViewTemplateCard"
   end if
   
   put the card_Object of displayView into cObject
   put the behavior of cObject into cBehavior
   -- put the name of stack "behavior_ViewTemplateCard" into cBehavior
   set the behavior of cObject to cBehavior
   --
end menu_SetStandardBehavior

on menu_ShowIndexTemplate displayView   
   put the view_Name of displayView into viewName
   put view_GetTemplateObject (viewName) into templateObject
   --
   object_GoTo templateObject
end menu_ShowIndexTemplate
