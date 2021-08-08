script "Global | Index | Simple | Style | Menu"
--> MetaData
-
copyright: Anonymous
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
   -- called once for each menu
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   -- use to do initialisation
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | Index | Simple | Style | Menu
-
on menu_EditViewScript indexView
   edit the script of indexView
end menu_EditViewScript

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
   display_ObjectProperties indexField
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
