script "Global | Index | Simple | Style | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Index | Simple | Style | Menu
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
   return the display_View of tObject
end menu_Target

getprop fieldStyle_Param [indexView]
   put the field_Style of indexView into fStyle
   return fStyle
end fieldStyle_Param

getprop fieldStyle_Params [indexView]
   if exists (indexView) is false then return empty
   put the field_Styles of indexView into fStyles
   return fStyles
end fieldStyle_Params

getprop fieldAlign_Param [indexView]
   put the field_Align of indexView into fStyle
   return fStyle
end fieldAlign_Param

getprop fieldAlign_Params [indexView]
   if exists (indexView) is false then return empty
   put the field_Aligns of indexView into fStyles
   return fStyles
end fieldAlign_Params

getprop dontWrap_Param [indexView]
   put the dont_Wrap of indexView into someBoolean
   return someBoolean
end dontWrap_Param

getprop dontWrap_Params
   return "true,false"
end dontWrap_Params


--> Global | Index | Simple | Style | Menu
-
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
   display_ObjectProperties indexField
end menu_InspectField

private on _
end _

on menu_SetMyName indexView
   put the group_Name of indexView into oldName
   put lcw_Ask ("Give this group and title a name...", oldName) into someName
   --
   put the title_Colour of indexView into tColour
   if tColour is empty then put "random" into tColour
   set the group_Name [tColour] of indexView to someName
end menu_SetMyName

/*
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
*/
