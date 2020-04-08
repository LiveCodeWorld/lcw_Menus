script "Global | Index | Simple | Menu"
--> MetaData
-
license: GPLv3
name: Global | Index | Simple | Menu
type: menu
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

getprop menuStyle_Param [indexView]
   return the menu_Style of indexView
end menuStyle_Param

getprop menuStyle_Params
   return "Array,Old"
end menuStyle_Params

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


--> Global | Index | Simple | Menu
-
on menu_MenuStyle indexView, mStyle
   set the menu_Style of indexView to mStyle
end menu_MenuStyle

on menu_DisplayMenuArray indexView
   put the script_MenuArray ["Global | Index | Simple | Menu"] of indexView into mArray
   display_Array mArray
end menu_DisplayMenuArray
   
on _
end _

on menu_PaletteStyle indexView, someBoolean
   put the stack_Name of indexView into stackName
   if someBoolean is false then
      set the style of stack stackName to "toplevel"
   else
      set the style of stack stackName to "palette"
   end if
end menu_PaletteStyle

on menu_SystemWindow indexView, someBoolean
   put the stack_Name of indexView into stackName
   set the systemwindow of stack stackName to someBoolean
end menu_SystemWindow

on _
end _

on menu_EditViewScript indexView
   edit the script of indexView
end menu_EditViewScript

on menu_EditViewBehavior indexView
   put the behavior of indexView into bObject
   edit the script of bObject
end menu_EditViewBehavior

on _
end _

on menu_FieldStyle indexView, fStyle
   set the field_Style of indexView to fStyle
end menu_FieldStyle

on menu_FieldAlign indexView, fAlign
   set the field_Align of indexView to fAlign
end menu_FieldAlign

on menu_DontWrap indexView, someBoolean
   set the dont_Wrap of indexView to someBoolean
end menu_DontWrap

on menu_InspectField indexView
   put the index_Field of indexView into indexField
   object_Inspect indexField
end menu_InspectField

on _
end _

on menu_SetMyName indexView
   put the group_Name of indexView into oldName
   put lcw_Ask ("Give this group and title a name...", oldName) into someName
   --
   put the title_Colour of indexView into tColour
   if tColour is empty then put "random" into tColour
   set the group_Name [tColour] of indexView to someName
end menu_SetMyName

on menu_SetMenuTitle indexView, whichTitle
   switch whichTitle
      case "Card"
         put the card_Object of indexView into cardObject
         set the menu_Controller of indexView to cardObject
         break
      case "Button"
         put the menu_Button of indexView into mButton
         set the menu_Controller of indexView to mButton
         break
      case "Tools"
         put menu_GetGlobalController ("Global | Index | Simple | Menu") into mController
         set the menu_Controller of indexView to mController
         break
      case "-"
      case "Ask"
         put the title_Menu of indexView into mTitle
         put lcw_Ask ("Set the menu_Title of this indexView to...", mTitle) into gMenuTitle
         put menu_GetGlobalController (gMenuTitle) into mController
         set the menu_Controller of indexView to mButton
         break
   end switch
end menu_SetMenuTitle

on _
end _

on menu_SetTitleColour indexView   
   answer color
   if it is empty then exit to top
   
   put it into someColour
   set the title_Colour of indexView to someColour
   put the result into titleColour
   
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_SetTitleColour

on menu_SetTitleTextColour indexView   
   answer color
   if it is empty then exit to top
   
   put it into someColour
   set the title_TextColour of indexView to someColour
end menu_SetTitleTextColour

on _
end _

on menu_BlackAndWhiteTitle indexView   
   put the title_Colour of indexView into titleColour
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_BlackAndWhiteTitle

on menu_ReverseTitleColour indexView   
   put the title_Colour of indexView into titleColour
   put colour_GetReverse (titleColour) into titleTextColour
   set the title_TextColour of indexView to titleTextColour
   
   put colour_RgbToHSV (titleColour) into someHSV
   put titleTextColour & CR & CR & someHSV & CR & titleColour
end menu_ReverseTitleColour

on _
end _

on menu_SetTitleMenus indexView
   put the title_Menu of indexView into mTitle   
   put lcw_Ask ("Set the menu_Title to...", mTitle) into mTitle
   set the title_Menu of indexView to mTitle   
end menu_SetTitleMenus

on menu_EditTitleMenus indexView
   put the title_Menu of indexView into mTitles     
   set the itemdelimiter to tab
   repeat for each line titleLine in mTitles
      if titleLine = "-" then next repeat
      put item 1 of titleLine into mTitle
      menu_Edit mTitle
   end repeat
end menu_EditTitleMenus

on menu_EditLineMenu indexView
   put the line_Menu of indexView into mTitle
   menu_Edit mTitle
end menu_EditLineMenu

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Menu | Props | old
-
getprop m_Styles
   return "Array,Old"
end m_Styles

getprop m_Style
   return the menu_Style of me
end m_Style

getprop which_Title [indexView]
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
end which_Title

getprop palette_Style [indexView]
   put the stack_Name of indexView into stackName
   put the style of stack stackName is "palette" into isPalette
   return isPalette
end palette_Style

getprop system_Window [indexView]
   put the stack_Name of indexView into stackName
   put the systemwindow of stack stackName into someBoolean
   return someBoolean
end system_Window

getprop f_Align [indexView]
   put the field_Align of indexView into fStyle
   return fStyle
end f_Align

getprop f_Aligns [indexView]
   if exists (indexView) is false then return empty
   put the field_Aligns of indexView into fStyles
   return fStyles
end f_Aligns

getprop f_Style [indexView]
   put the field_Style of indexView into fStyle
   return fStyle
end f_Style

getprop f_Styles [indexView]
   if exists (indexView) is false then return empty
   put the field_Styles of indexView into fStyles
   return fStyles
end f_Styles


--> Global | Index | Simple | Menu | Disabled
-


--> Dev | Menu
-
on menu_SetStandardBehavior
   put LocalArray ["indexView"] into indexView
   
   put the view_BehaviorStackName of indexView into stackName
   put the name of stack stackName into bObject
   set the behavior of indexView to bObject
end menu_SetStandardBehavior

on _
end _

on menu_ShowIndexTemplate
   put LocalArray ["indexView"] into indexView
   
   put the view_Name of indexView into viewName
   put view_GetTemplateObject (viewName) into templateObject
   object_GoTo templateObject
end menu_ShowIndexTemplate

on menu_EditThisMenu
   menu_Edit "Global | Index | Simple | Menu"
end menu_EditThisMenu

on _
end _

on menu_TestMenuTarget displayedObject
   put LocalArray ["indexView"] into indexView
   
   put the view_Name of mTarget & CR & the name of mTarget & CR & indexView
end menu_TestMenuTarget
