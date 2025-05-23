﻿script "behavior_ViewIndexSimple" with behavior "behavior_ViewIndexFiles"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewIndexSimple
type: behavior
version: 0.6

/*
This view presents an index in a scrolling field, with full support for dynamic events.
This script is activated for every LCW menu call that is not handled locally.
For instance the ScriptEditor menus use the "menuPick" handler below.
*/

--> Variables
-
local LocalArray


--> Working on
-
command toggle_Title
   set the title_Colour of me to colour_GetRandom()
   put the stack_Style of me into oStyle
   switch oStyle
      case "toplevel"
         set the stack_Style of me to "palette"
         break
      case "palette"
         set the stack_Style of me to "toplevel"
         break
      default
         put oStyle
         breakpoint
   end switch
end toggle_Title


--> Events
-
on preOpenControl
   local headerHeight
   _setDefaultHeight headerHeight
   if there is a stack "behavior_ViewIndexFiles" then
      put the name of stack "behavior_ViewIndexFiles" into bObject
      set the behavior of stack "behavior_ViewIndexSimple" to bObject
   end if
   pass preOpenControl
end preOpenControl

on mouseDown
   switch word 1 of the name of the target
      case "button"
         if the optionKey is "Down" then
            toggle_Title -- ugly as can't block menu with this method
         else
            _doButtonMenu
         end if
         break
      case "field"
         _doFieldDown
         break
   end switch
end mouseDown

on mouseUp
   switch word 1 of the name of the target
      case "button"
         pass mouseUp
      case "field"
         _doFieldClick
   end switch
end mouseUp

on mouseDoubleUp
   put the long id of the target into tObject
   --
   switch word 1 of tObject
      case "button"
         -- always caught by menu?
         break
      case "field"
         _DoDoubleClick
   end switch
end mouseDoubleUp

on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl

on menuPick menuPath
   menu_DispatchTextPick menuPath
end menuPick


--> Props
-
getprop title_Height
   put the height of _titleView() into titleHeight
   return titleHeight
end title_Height

setprop title_Height
   lock screen
   switch
      case titleHeight is a number
         set the height of _titleView() to titleHeight
         LayoutControl       
         break
      case titleHeight is "auto"
         put the formattedheight of _titleView() into titleHeight
         add 8 to titleHeight
         set the height of _titleView() to titleHeight
         LayoutControl      
         break
      default
   end switch 
   unlock screen
   return titleHeight
end title_Height

getprop formatted_Height [titleHeight]
   put _fieldObject() into fObject
   put the formattedheight of fObject into fHeight
   add 4 to fHeight
   
   put the title_Height of me into titleHeight
   return fHeight + titleHeight
end formatted_Height

getprop formatted_Width
   put _fieldObject() into fObject
   put the formattedwidth of fObject into fWidth
   put the scrollbarWidth of fObject into sWidth
   add sWidth to fWidth
   add 8 to fWidth
   
   put the formattedwidth of _titleView() into bWidth
   return max (fWidth,bWidth)
end formatted_Width

getprop line_Controller [mTitle]
   put the line_Controller of me into mController
   if exists (mController) then return mController
   
   if mTitle is empty then
      put the line_Menu of me into mTitle
   end if
   put menu_GetGlobalController (mTitle) into mController
   return mController
end line_Controller

setprop line_Controller mController
   set the line_Controller of me to mController
end line_Controller

private function _DefaultMouseTarget
   put the line_Controller of me into mouseTarget
   if exists (mouseTarget) is false then
      put the long id of me into mouseTarget
   end if
   return mouseTarget
end _DefaultMouseTarget

private command _DoDoubleClick
   put the mouse_DoubleUp of me into mDoubleUp
   -- if mDoubleClick is empty then return empty
   
   put the mouse_Target of me into mouseTarget
   put the clickText into someLine
   put the long id of me into dView
   
   if the optionKey is "Down" then
      dispatch "ask_CreateMouseDoubleUpHandler" to me with mDoubleUp,dView
   else
      dispatch mDoubleUp to mouseTarget with dView,someLine
   end if
end _DoDoubleClick

getprop mouse_DoubleUp
   put the mouse_DoubleUp of me into mDoubleUp
   if mDoubleUp is empty then return "mouse_DoubleUp"
   return mDoubleUp
end mouse_DoubleUp

setprop mouse_DoubleUp [mTarget] mDoubleUp
   set the mouse_DoubleUp of me to mDoubleUp
end mouse_DoubleUp

getprop mouse_Target
   -- set the mouse_Target of me to empty
   put the mouse_Target of me into mouseTarget
   if exists (mouseTarget) is false then 
      put _DefaultMouseTarget() into mouseTarget
   end if
   return mouseTarget
end mouse_Target

setprop mouse_Target mouseTarget
   set the mouse_Target of me to mouseTarget
end mouse_Target

getprop menu_Target
   put the menu_Target of me into mTarget
   --
   put the displayed_Object of me into displayedObject
   switch 
      case mTarget is not empty
         return mTarget
      case displayedObject is not empty
         return displayedObject
      default
         return the long id of me
   end switch
end menu_Target

setprop menu_Target [mTitlePath] mTarget
   set the menu_Target of me to mTarget
end menu_Target

getprop tool_MenuBit
   -- return the tool_MenuBit name = menuBit
   get the title_Menu of me
   set the itemdelimiter to "|"
   put word 1 to -1 of item 2 to -2 of it into menuBit
   return menuBit
end tool_MenuBit

setprop tool_MenuBit [libName] menuBit
   -- used to use "display_SetToolMenus"
   put the menu_Button of me into mButton
   set the tool_LibName of me to libName
   --
   set the menumode of mButton to "pulldown"
   set the style of mButton to "menu"
   
   # Construct Menu Titles
   get "Global |" && menuBit
   put it && "| Menu" into titleMenu
   put it && "| Line | Menu" into lineMenu
   
   # Construct mDoubleUp
   replace "|" with empty in menuBit
   replace space with empty in menuBit
   put "mDoubleUp_" & menuBit into mDoubleUp
   
   # Set menus and mouse
   set the title_Menu of me to titleMenu
   set the line_Menu of me to lineMenu
   set the mouse_DoubleUp of me to mDoubleUp
   
   # Create menus if needed
   dispatch "ask_CreateMenuFromObject" to me with titleMenu,libName
   
   if the shiftKey is "Down" then
      dispatch "ask_CreateMenuFromObject" to me with lineMenu,libName
      dispatch "ask_CreateMouseDoubleUpHandler" to me with mDoubleUp
   end if
   --
   return titleMenu
end tool_MenuBit


--> Field
-
private command _doFieldDown
   put word 2 of the clickline into cNum
   if the controlkey is "Down" then
      set the hilitedlines of the target to cNum
      put the line_Menu of me into lineTitle
      
      # Option Edit
      put the line_Controller [lineTitle] of me into mController
      if exists (mController) is false then
         put the tool_LibName of me into libName
         ask_CreateMenuFromObject lineTitle, libName
      else
         put the menu_Button of me into mButton
         mArray_PopUp lineTitle, mButton
      end if
   else
      put the drop_Command of me into dCommand
      if dCommand is empty then return false
      
      put the selectedtext of the target into someText
      -- set the dragImage to 3137
      set the dragAction to "copy"
      set the dragData ["text"] to someText
      return true
   end if
end _doFieldDown


--> Button
-
getprop title_Controller
   put the title_Controller of me into mController
   if exists (mController) then
      return mController
   end if
   
   ## Default
   put the title_Menu of me into mTitle
   put menu_GetGlobalController (mTitle) into mController
   return mController
end title_Controller

private command _doButtonMenu
   put the menu_Button of me into mButton
   set the menumode of mButton to "pulldown" -- seems to be needed!
   -- set the style of mButton to "menu"
   --
   put the title_Menu of me into mTitle
   switch
      case the controlkey is "Down"
         put "Global | Index | Simple | Menu" into gMenuTitle
         mArray_PullDown gMenuTitle, mButton
         break
      default
         mArray_MouseDown mTitle, mButton
   end switch
end _doButtonMenu


--> Objects
-
private function _titleView
   put the long id of btn 1 of me into headerWidget
   return headerWidget
end _titleView

private function _fieldObject
   put the long id of field 1 of me into arrayWidget
   return arrayWidget
end _fieldObject


--> Title | Menu
-
getprop menu_Button
   return _titleView()
end menu_Button

getprop title_Menu
   put the title_Menu of me into mName
   if mName is empty then 
      return "Title | Menu"
   else
      return mName
   end if
end title_Menu

setprop title_Menu mName
   set the title_Menu of me to mName
end title_Menu


--> Props
-
getprop max_LineNum
   put the displayed_Index of me into dLines
   return the number of lines of dLines
end max_LineNum

getprop mouse_Up
   put the mouse_Up of me into mUp
   return mUp
end mouse_Up

setprop mouse_Up mouseUpEvent
   set the mouse_Up of me to mUp
end mouse_Up


--> Props | Menu | Model
-
getprop line_Menu
   put the line_Menu of me into mName
   --
   if mName is empty then 
      put "List | Menu" into lineMenuTitle -- a local menu to the field
      put CR & "-" after lineMenuTitle
      put CR & "Global | IndexView | Line | Menu" after lineMenuTitle -- a local menu to the field
      put tab & "submenu" & tab & "Tools" after lineMenuTitle
      return lineMenuTitle
   else
      return mName
   end if
end line_Menu

setprop line_Menu mName
   set the line_Menu of me to mName
end line_Menu

-- getprop menu_Controller [pMenuTitle]
put menu_GetGlobalController (pMenuTitle) into mController
if exists (mController) is true then return mController

put LocalArray ["mController"] into mController
if exists (mController) is true then return mController

return empty
end menu_Controller

-- setprop menu_Controller mController
if exists (mController) is false then return empty
--
put mController into LocalArray ["mController"]
--
put the script_MenuTitles of mController into mTitles
set the title_Menu of me to mTitles
return mTitles
end menu_Controller

getprop line_Controller
   put the line_Controller of me into mController
   if exists (mController) then return mController
   
   ## Default
   put the line_Menu of me into mTitle
   put menu_GetGlobalController (mTitle) into mController
   return mController
end line_Controller


--> Geometry
-
command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   if the showborder of me is true then
      put the borderwidth of me into bWidth
      _SubtractMargins pRect, bWidth
   end if
   _SubtractMargins pRect, the margins of me
   
   set the rect of _titleView() to _headerRect (pRect)
   set the rect of _fieldObject() to _fieldRect (pRect)
   unlock screen
end LayoutControl


--> Drag
-
on dragDrop
   put the drop_Command of me into dCommand
   if dCommand is empty then pass dragDrop
   
   put the long id of me into displayView
   put the dragdata ["text"] into dData ["text"]
   put the dragdata ["files"] into dData ["files"]
   put the dragdata ["html"] into dData ["html"]
   put the dragdata ["image"] into dData ["image"]
   put displayView into dData ["displayView"]
   --
   put the drop_Target of me into dTarget
   --
   dispatch dCommand to dTarget with displayView,dData
   switch it
      case "handled"
         break
      case "unhandled"
         put the dragdata ["text"] into someURL
         put someURL
         break
      case "passed"
         break
   end switch
end dragDrop

on dragEnter
   put the drop_Command of me into dCommand
   if dCommand is empty then pass dragEnter
   
   set the dragAction to "link"
end dragEnter

getprop drop_Command
   put LocalArray ["event"]["dragCommand"] into dragCommand
   return dragCommand
end drop_Command

setprop drop_Command dragCommand
   put dragCommand into LocalArray ["event"]["dragCommand"]
end drop_Command

getprop drop_Target
   put LocalArray ["drop_Target"] into darget
   if darget is empty then return the long id of the target
   return darget
end drop_Target

setprop drop_Target darget
   put darget into LocalArray ["drop_Target"]
end drop_Target


--> Displayed
-
getprop meta_Data [someKey]
   put LocalArray ["meta_Data"][someKey] into someValue
   return someValue
end meta_Data

setprop meta_Data [someKey] someValue
   put someValue into LocalArray ["meta_Data"][someKey]
end meta_Data

getprop displayed_Data
   put LocalArray ["displayed_Data"] into someArray
   return someArray
end displayed_Data

setprop displayed_Data [someTitle] someArray
   put someArray into LocalArray ["displayed_Data"]
   --
   if someArray is an array then
      put the keys of someArray into someIndex
      sort lines of someIndex
   else
      put someArray into someIndex
   end if
   set the displayed_Index [someTitle] of me to someIndex
end displayed_Data

getprop displayed_Array
   return the displayed_Data of me
end displayed_Array

setprop displayed_Array [someTitle] someArray
   set the displayed_Data [someTitle] of me to someArray
end displayed_Array


--> Coloured
-
getprop selected_LineColour
   put _fieldObject() into fldObject
   put the hilitedlines of fldObject into lineNumList
   repeat for each line lineNum in lineNumList
      put the textcolor of line lineNum of fldObject & CR after sLineColours
   end repeat
   delete char -1 of sLineColours
   return sLineColours
end selected_LineColour

getprop line_Colour [lineNum]
   put _fieldObject() into fldObject
   if lineNum is empty then
      put line 1 of the hilitedlines of fldObject into lineNum
   end if
   put the effective textcolor of line lineNum of fldObject into someColour
   return someColour
end line_Colour

setprop line_Colour [lineNumList] someColour
   put _fieldObject() into fldObject
   if lineNumList is empty then
      put line 1 of the hilitedlines of fldObject into lineNumList
   end if
   
   lock screen
   put the displayed_Index of me into displayedIndex
   repeat for each item lineNum in lineNumList
      if lineNum is not a number then
         put lineOffset (lineNum, displayedIndex) into lineNum
         if lineNum is not a number then
            next repeat
         end if
      end if
      --
      set the textcolor of line lineNum of fldObject to someColour
   end repeat
   unlock screen
end line_Colour

getprop coloured_Lines [someColour]
   if someColour = "none" then put empty into someColour
   colour_RgbNormalise someColour
   
   put _fieldObject() into fldObject
   put the text of fldObject into displayedIndex
   --
   repeat with lineNum = 1 to the number of lines of displayedIndex
      get the textcolor of line lineNum of fldObject
      if it = someColour then
         put line lineNum of displayedIndex into someLine
         put someLine & CR after colouredLines
      end if
   end repeat
   delete char -1 of colouredLines
   return colouredLines
end coloured_Lines

setprop coloured_Lines [someColour] someIndex
   if someColour = "none" then put empty into someColour
   
   put _fieldObject() into fldObject
   put the text of fldObject into displayedIndex
   --
   lock screen
   switch
      case someIndex is empty
         put the number of lines of displayedIndex into maxNum
         repeat with lineNum = 1 to maxNum
            set the textcolor of line lineNum of fldObject to empty
         end repeat
         break
      case someIndex = "all"
         put the number of lines of displayedIndex into maxNum
         repeat with lineNum = 1 to maxNum
            set the textcolor of line lineNum of fldObject to someColour
         end repeat
         break
      case someIndex is an array
         put the keys of someIndex into someIndex
      default
         lock screen
         repeat for each line someLine in someIndex
            put lineOffset (someLine, displayedIndex) into lineNum
            set the textcolor of line lineNum of fldObject to someColour
         end repeat
   end switch
   unlock screen
end coloured_Lines

getprop coloured_Array [someColour]
   put _fieldObject() into fldObject
   
   put the number of lines of the text of fldObject into maxNum
   repeat with lineNum = 1 to maxNum
      put the textcolor of line lineNum of fldObject into foundColour
      if foundColour = empty then put "none" into foundColour
      put the textstyle of line lineNum of fldObject into someStyle
      put someStyle into colourArray [foundColour][lineNum]
   end repeat
   
   if someColour is empty then
      return colourArray
   else
      put colourArray [someColour] into lineArray
      put keys (lineArray) into lineNums
      sort numeric lineNums
      return lineNums
   end if
end coloured_Array

setprop coloured_Array colourArray
   put _fieldObject() into fldObject
   
   lock screen
   repeat for each key someColour in colourArray
      put colourArray [someColour] into lineNumArray
      if someColour = "none" then put empty into someColour
      repeat for each key lineNum in lineNumArray
         set the textcolor of line lineNum of fldObject to someColour
      end repeat
   end repeat
   unlock screen
end coloured_Array


--> Migrating
-
getprop display_View
   -- owing to this as we look to merge indexViews and arrayViews into a single view
   return the long id of me
end display_View



--> Menu | Props | Old
-
getprop view_MenuArray
   put the title_Menu of me into menuArray ["title"]
   put the line_Menu of me into menuArray ["line"]
   return menuArray
end view_MenuArray

setprop view_MenuArray menuArray
   set the title_Menu of me to menuArray ["title"]
   set the line_Menu of me to menuArray ["line"]
end view_MenuArray


--> Index | Title
-
getprop stack_Title
   put word 1 to -1 of the title_Text of me into stackTitle
   put word 1 to -1 of the stack_Label of me into stackLabel
   if stackLabel is not empty then put stackLabel into item 2 of stackTitle
   return stackTitle
end stack_Title

setprop stack_Title stackTitle
   put word 1 to -1 of item 1 of stackTitle into titleText
   put word 1 to -1 of item 2 of stackTitle into stackLabel
   --
   lock screen
   set the title_Text of me to titleText
   set the stack_Label of me to stackLabel
   unlock screen
   --
   return the long id of me
end stack_Title

getprop title_Text
   put the effective label of _titleView() into someTitle
   return someTitle
end title_Text

setprop title_Text someTitle
   put _titleView() into titleView
   set the label of titleView to someTitle
   return titleView
end title_Text

getprop stack_Label
   put the label of the defaultstack into stackLabel
   return stackLabel
end stack_Label

getprop stack_Label stackLabel
   put the defaultstack into myStackObject
   set the label of myStackObject to stackLabel
   return myStackObject
end stack_Label


--> Deleted
-
setprop deleted_Line someLine
   if someLine is a number then
      put someLine into lineNum
   else
      put the line_Number [someLine] of me into lineNum
   end if
   --
   put the short id of _fieldObject() into fldID
   delete line lineNum of fld id fldID of me
   return lineNum
end deleted_Line


--> Displayed
-
getprop displayed_Title
   return the title_Text of me
end displayed_Title

setprop displayed_Title [stackLabel] someTitle
   lock screen
   set the title_Text of me to someTitle
   set the stack_Label of me to stackLabel
   unlock screen
   return the long id of me
end displayed_Title

getprop displayed_HtmlText
   return the htmltext of _fieldObject()
end displayed_HtmlText

setprop displayed_HtmlText [someTitle] someHTML
   lock screen
   put _fieldObject() into fldObject
   if someTitle is not empty then
      set the title_Text of me to someTitle
   end if
   set the htmltext of fldObject to someHTML
   unlock screen
   return fldObject
end displayed_HtmlText

getprop displayed_Text
   return the displayed_Lines of me
end displayed_Text

setprop displayed_Text [someTitle] someText
   set the displayed_Lines [someTitle] of me to someText
   return the result
end displayed_Text

getprop displayed_Line [pLineNum]
   if pLineNum is empty then
      put the hilitedlines of _fieldObject() into pLineNum
      if pLineNum = 0 then return 0
   end if
   
   put the text of _fieldObject() into someIndex
   repeat for each item lineNum in pLineNum
      put line lineNum of someIndex & CR after displayedLines
   end repeat
   delete char -1 of displayedLines
   return displayedLines
end displayed_Line

setprop displayed_Line [pLineNum] someLine
   if pLineNum is empty then
      put the hilitedlines of _fieldObject() into pLineNum
      if pLineNum = 0 then return 0
   end if
   
   put the short id of _fieldObject() into fldID
   repeat for each item lineNum in pLineNum
      set the text of line lineNum of fld id fldID to someLine
   end repeat
   return pLineNum
end displayed_Line

getprop displayed_Lines
   put the text of _fieldObject() into someIndex
   return someIndex
end displayed_Lines

setprop displayed_Lines [someTitle] someIndex
   lock screen
   put _fieldObject() into fldObject
   if someTitle is not empty then
      set the title_Text of me to someTitle
   end if
   set the text of fldObject to someIndex
   unlock screen
   return fldObject
end displayed_Lines

getprop displayed_Index
   put the displayed_Lines of _fieldObject() into someIndex
   return someIndex
end displayed_Index

setprop displayed_Index [someTitle] someIndex
   set the displayed_Lines [someTitle] of _fieldObject() to someIndex
   return the result
end displayed_Index


--> Title
-
getprop title_Lines
   put LocalArray ["title_Lines"] into lineNumList
   return lineNumList
end title_Lines

setprop title_Lines [someColour] lineNumList
   replace CR with comma in lineNumList
   put _fieldObject() into fldObject
   --
   lock screen
   repeat for each item lineNum in lineNumList
      if someColour is not empty then
         set the textcolor of line lineNum of fldObject to someColour
      end if
      set the textstyle of line lineNum of fldObject to "bold"
   end repeat
   unlock screen
   --
   put lineNumList into LocalArray ["title_Lines"]
end title_Lines


--> Index | Selected
-
getprop line_Number [someLine]
   if someLine is empty then
      return the hilited_Line of me
   end if
   put the displayed_Index of _fieldObject() into someIndex
   set the wholeMatches to true
   put lineOffset (someLine, someIndex) into lineNum
   return lineNum
end line_Number

setprop line_Number [someLine] someValue
   put the displayed_Index of _fieldObject() into someIndex
   set the wholeMatches to true
   put lineOffset (someLine, someIndex) into lineNum
   if lineNum is 0 then return 0
   
   put the short id of _fieldObject() into fldID
   set the text of line lineNum of fld id fldID of me to someValue
   return lineNum
end line_Number

getprop top_Line
   -- for compatible with tree widget
   return the selected_Line of me
end top_Line


--> Selected
-
setprop top_Line someLine
   -- for compatible with tree widget
   set the selected_Line of me to someLine
   return the result
end top_Line

getprop selected_Line
   put the selected_Index of _fieldObject() into someIndex
   return line 1 of someIndex
end selected_Line

setprop selected_Line someLine
   set the selected_Index of me to line 1 of someLine
   put the result into lineNum
   return lineNum
end selected_Line

getprop selected_Index
   put the selectedtext of _fieldObject() into someIndex
   return someIndex
end selected_Index

setprop selected_Index someLines
   put the displayed_Index of me into viewIndex
   set the itemdelimiter to slash
   set the wholematches to true
   repeat for each line someLine in someLines
      put lineOffset (someLine, viewIndex) into lineNum
      if lineNum > 0 then
         put lineNum & comma after lineNumList
      end if
   end repeat
   delete char -1 of lineNumList
   
   set the hilitedlines of _fieldObject() to lineNumList
   return lineNumList
end selected_Index

getprop selected_Value
   put the selectedtext of _fieldObject() into someIndex
   put LocalArray ["displayed_Data"] into someArray
   put someArray [someIndex] into someValue
   return someValue
end selected_Value

setprop selected_Value someValue
   put LocalArray ["displayed_Data"] into someArray
   put the displayed_Index of me into viewIndex
   repeat with lineNum = 1 to the number of lines of viewIndex
      put line lineNum of viewIndex into testLine
      put someArray [testLine] into testValue
      if testValue = someValue then
         set the hilitedlines of _fieldObject() to lineNum
         return lineNum
      end if
   end repeat
   set the hilitedlines of _fieldObject() to 0
   return 0
end selected_Value


--> Selected | LineNumber

getprop selected_LineNumber
   put the hilitedlines of _fieldObject() into lineNumList
   return lineNumList
end selected_LineNumber

setprop selected_LineNumber lineNumList
   put _fieldObject() into fldObject
   replace CR with comma in lineNumList
   set the hilitedlines of fldObject to lineNumList
   return fldObject
end selected_LineNumber

getprop selected_LineNum
   return the selected_LineNumber of me
end selected_LineNum

setprop selected_LineNum lineNumList
   set the selected_LineNumber of me to lineNumList
end selected_LineNum

getprop hilited_Line
   put the selected_LineNumber of me into lineNumList
   return item 1 of lineNumList
end hilited_Line

setprop hilited_Line lineNum
   set the selected_LineNumber of _fieldObject() to lineNum
   put the result into fldObject
   return fldObject
end hilited_Line

getprop hilited_Lines
   return the selected_LineNumber of _fieldObject()
end hilited_Lines

setprop hilited_Lines lineNumList
   set the selected_LineNumber of me to lineNumList
end hilited_Lines


--> Field | Props
-
getprop lock_Text
   put the locktext of _fieldObject() into someBoolean
   return someBoolean
end lock_Text

setprop lock_Text someBoolean
   set the locktext of _fieldObject() to someBoolean
end lock_Text

getprop view_Text
   return the displayed_Index of me
end view_Text

setprop view_Text someText
   lock screen
   set the displayed_Index of me to someText
   set the field_Style of me to "text"
   unlock screen
end view_Text

getprop field_Align
   put _fieldObject() into fieldView
   put the textalign of fieldView into fieldAlign
   return fieldAlign
end field_Align

setprop field_Align fieldAlign
   put _fieldObject() into fieldView
   set the textalign of fieldView to fieldAlign
   return fieldView
end field_Align

getprop field_Aligns
   return "left,right"
end field_Aligns

getprop field_Style
   -- put the field_Style of me into someStyle
   -- return someStyle
   
   put _fieldObject() into fieldView
   switch
      case the dontwrap of fieldView = false
         return "text"
      case the multiple_Hilites of fieldView = false
         return "scrolling"
      default
         return "multiselect"
   end switch
end field_Style

setprop field_Style someStyle
   put _fieldObject() into fieldView
   lock screen
   switch someStyle
      case "text"
         set the listbehavior of fieldView to false
         set the dontwrap of fieldView to false
         set the locktext of fieldView to false
         set the autoHilite of fieldView to true
         set the fixedLineHeight of fieldView to false
         break
      case "click"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         set the toggleHilites of fieldView to false
         break
      case "scrolling"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         break
      case "multiselect"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to true
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         break
      case "display selected"
         set the fixedLineHeight of fieldView to true
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to true
         set the toggle_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to false
         break
   end switch
   set the field_Style of me to someStyle
   unlock screen
end field_Style

getprop field_Styles
   return "text,click,scrolling,multiselect,display selected"
end field_Styles

getprop dont_Wrap
   put the dontwrap of _fieldObject() into someBoolean
   return someBoolean
end dont_Wrap

setprop dont_Wrap someBoolean
   put _fieldObject() into fieldView
   -- set the listbehavior of fieldView to someBoolean
   set the dontwrap of fieldView to someBoolean
   return fieldView
end dont_Wrap

getprop multiple_Hilites
   put the multiplehilites of _fieldObject() into someBoolean
   return someBoolean
end multiple_Hilites

setprop multiple_Hilites someBoolean
   set the multiplehilites of _fieldObject() to someBoolean
   set the nonContiguousHilites of _fieldObject() to someBoolean
   -- set the toggleHilites of _fieldObject() to someBoolean
end multiple_Hilites

getprop toggle_Hilites
   put the toggleHilites of _fieldObject() into someBoolean
   return someBoolean
end toggle_Hilites

setprop toggle_Hilites someBoolean
   set the toggleHilites of _fieldObject() to someBoolean
end toggle_Hilites


--> Index | Displayed
-
getprop view_Index
   put the displayed_Index of me into someIndex
   return someIndex
end view_Index

setprop view_Index [someTitle] someIndex
   set the displayed_Index [someTitle] of me to someIndex
   return the result
end view_Index


--> Title | Colours
-
setprop title_Colours titleColour
   set the title_Colour of me to titleColour
   put the result into titleColour
   --
   put colour_GetDarkOrLight (titleColour) into titleTextColour
   set the title_TextColour of me to titleTextColour
   --
   return titleColour & CR & titleTextColour
end title_Colours

getprop title_Colour
   return the backgroundcolor of _titleView()
end title_Colour

setprop title_Colour someColour
   if someColour is "random" then put _GetRandomColour() into someColour
   set the backgroundcolor of _titleView() to someColour
   return someColour
end title_Colour

getprop title_TextColour
   return the foregroundcolor of _titleView()
end title_TextColour

setprop title_TextColour someColour
   if someColour is "random" then put _GetRandomColour() into someColour
   set the foregroundcolor of _titleView() to someColour
   return someColour
end title_TextColour


--> Geometry
-
getprop formatted_Rect
   -- utility function not needed for LayoutControl
   
   put _fieldObject() into fldObject
   put _titleView() into titleView
   put the rect of me into pRect
   
   put the effective height of titleView into titleHeight
   put the formattedheight of fldObject into formattedFieldHeight
   add 45 to formattedFieldHeight
   put max (90, formattedFieldHeight) into newHeight
   
   put the formattedwidth of titleView into formattedTitleWidth
   put the formattedwidth of fldObject into formattedFieldWidth
   put max (formattedTitleWidth, formattedFieldWidth) into fWidth
   add 30 to fWidth
   put max (180, fWidth) into newWidth
   
   put item 1 of pRect + newWidth into newRight
   put item 2 of pRect + newHeight into newBottom
   
   put pRect into fRect
   put newRight into item 3 of fRect
   put newBottom into item 4 of fRect
   
   return fRect
end formatted_Rect

getprop header_Height
   return _headerHeight()
end header_Height

setprop header_Height headerHeight
   put headerHeight into LocalArray ["headerHeight"]
   LayoutControl
   return the result
end header_Height


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop display_View
   return the long id of me
end display_View

getprop index_View
   return the long id of me
end index_View

getprop title_View
   return _titleView()
end title_View

getprop index_Field
   return _fieldObject()
end index_Field


--> Private
-
private command _doFieldClick
   put the mouse_Up of me into mouseUpEvent
   if mouseUpEvent is empty then return empty
   
   put the clickText into someLine
   put the long id of me into targetControl
   put the mouse_Target of me into eventTarget
   if exists (eventTarget) is true then
      dispatch mouseUpEvent to eventTarget with targetControl,someLine
   else
      dispatch mouseUpEvent to me with targetControl,someLine
   end if
   return mouseUpEvent
end _doFieldClick

private function _headerRect someRect
   put item 2 of someRect + _headerHeight() into item 4 of someRect
   return someRect
end _headerRect

private function _fieldRect someRect
   add _headerHeight() to item 2 of someRect
   return someRect
end _fieldRect

private function _headerHeight
   put LocalArray ["headerHeight"] into headerHeight
   _setDefaultHeight headerHeight
   return headerHeight
end _headerHeight

private command _setDefaultHeight @headerHeight
   if headerHeight is empty then
      -- let's set a default
      put 30 into headerHeight
      put headerHeight into LocalArray ["headerHeight"]
   end if
end _setDefaultHeight

private function _GetRandomColour
   -- colour_GetRandom
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end _GetRandomColour

private command _SubtractMargins @someRect, pMargin
   _NormalizeMargin pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end _SubtractMargins

private command _NormalizeMargin @someMargin, @leftM, @topM, @rightM, @bottomM
   -- fixed bug in setting bottomM when 4th item is empty
   if the number of items of someMargin < 4 then
      put item 1 of someMargin into defaultMargin
      put defaultMargin into leftM
      
      put item 2 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into topM
      else
         put actualMargin into topM
      end if
      
      put item 3 of someMargin into actualMargin
      if actualMargin is empty then
         put leftM into rightM
      else
         put actualMargin into rightM
      end if
      
      put item 4 of someMargin into actualMargin
      if actualMargin is empty then
         put topM into bottomM
      else
         put actualMargin into bottomM
      end if
   else
      put item 1 of someMargin into leftM
      put item 2 of someMargin into topM
      put item 3 of someMargin into rightM
      put item 4 of someMargin into bottomM
   end if
   put leftM,topM,rightM,bottomM into someMargin
end _NormalizeMargin
