script "behavior_ViewIndexSimple" with behavior "behavior_ViewIndexFiles"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewIndexSimple
type: view behavior
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
getprop drag_Command
   put LocalArray ["event"]["dragCommand"] into dragCommand
   return dragCommand
end drag_Command

setprop drag_Command dragCommand
   put dragCommand into LocalArray ["event"]["dragCommand"]
end drag_Command

private command _doFieldDown
   put word 2 of the clickline into cNum
   if the controlkey is "Down" then
      set the hilitedlines of the target to cNum
      put the line_Menu of me into mTitle
      --
      if the menu_Style of me is "array" then
         mArray_PopUp mTitle
      else
         menu_PopUp mTitle 
      end if
   else
      put the drag_Command of me into dCommand
      if dCommand is empty then return false
      
      -- this also gets triggered on simple mouseDown
      -- consider using mouseStillDown ?
      
      put the selectedtext of the target into someText
      -- set the dragImage to 3137
      set the dragAction to "copy"
      set the dragData ["text"] to someText
      
      /*
      put the long id of me into targetControl
      put the event_Target of me into eventTarget
      dispatch dCommand to eventTarget with targetControl,someText
      put the result into vName
      set the dragData ["private"] to vName
      */
      return true
   end if
end _doFieldDown

getprop menu_Style
   put LocalArray ["menu_Style"] into mStyle
   if mStyle is empty then pass menu_Style
   return mStyle
end menu_Style

setprop menu_Style mStyle
   put mStyle into LocalArray ["menu_Style"]
   return LocalArray 
end menu_Style


--> Active | Menus
-
getprop active_MenuArray
   return LocalArray ["active_MenuArray"]
end active_MenuArray

setprop active_MenuArray [mTitle] mArray
   -- set by "mArray_MouseDown"
   put mArray into LocalArray ["active_MenuArray"]
   if mTitle is not empty then
      set the active_MenuTitle of me to mTitle
   end if
end active_MenuArray

getprop active_MenuTitle
   return LocalArray ["active_MenuTitle"]
end active_MenuTitle

setprop active_MenuTitle mTitle
   put mTitle into LocalArray ["active_MenuTitle"]
end active_MenuTitle


--> Events | Menupick
-
on menuPick menuPath
   if the menu_Style of me is "array" then
      -- mArray and mTitle set by "mArray_MouseDown"
      menu_DispatchTextPick menuPath
   else
      menu_SendMessage menuPath
   end if
end menuPick

on _doButtonMenu
   put the menu_Button of me into mButton
   set the menumode of mButton to "pulldown"
   set the style of mButton to "menu"
   --
   put the title_Menu of me into mTitle
   put the menu_Button of me into mButton
   switch
      case the controlkey is "Down"
         put "Global | Index | Simple | Menu" into gMenuTitle
         if the menu_Style of me is "array" then
            mArray_PullDown gMenuTitle, mButton
         else
            menu_PullDown gMenuTitle
            -- menu_MouseDown gMenuTitle -- does not work here
         end if
         break
      default
         if the menu_Style of me is "array" then
            mArray_MouseDown mTitle, mButton
         else
            -- menu_PullDown will trigger also native manumode menu = two menu calls
            menu_MouseDown mTitle, mButton
         end if
   end switch
end _doButtonMenu


--> Events
-
on mouseDown
   switch word 1 of the name of the target
      case "button"
         _doButtonMenu
         break
      case "field"
         _doFieldDown
         break
   end switch
end mouseDown

on preOpenControl
   local headerHeight
   _setDefaultHeight headerHeight
   if there is a stack "behavior_ViewIndexFiles" then
      put the name of stack "behavior_ViewIndexFiles" into bObject
      set the behavior of stack "behavior_ViewIndexSimple" to bObject
   end if
   pass preOpenControl
end preOpenControl

on mouseUp
   switch word 1 of the name of the target
      case "button"
         break
      case "field"
         _doFieldClick
         break
   end switch
end mouseUp

on mouseDoubleUp
   switch word 1 of the name of the target
      case "button"
         break
      case "field"
         _doFieldDoubleClick
         break
   end switch
end mouseDoubleUp

on resizeControl
   put the rect of me into viewRect
   LayoutControl viewRect
end resizeControl


--> Objects
-
getprop menu_Button
   return _titleView()
end menu_Button

getprop menu_Controller [pMenuTitle]
   put menu_GetGlobalController (pMenuTitle) into mController
   if exists (mController) is true then return mController
   
   put LocalArray ["mController"] into mController
   if exists (mController) is true then return mController
   
   -- put the long id of this card into mController
   put the menu_Button of me into mController
   return mController
end menu_Controller

setprop menu_Controller mController
   if exists (mController) is false then return empty
   --
   put mController into LocalArray ["mController"]
   --
   put the script_MenuTitles of mController into mTitles
   set the title_Menu of me to mTitles
   return mTitles
end menu_Controller

getprop menu_Target [mTitlePath]
   put LocalArray ["menuTarget"] into mTarget
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
   put mTarget into LocalArray ["menuTarget"]
end menu_Target


--> Index | menus
-
getprop line_Menu
   put LocalArray ["line_Menu"] into lineMenuTitle
   if lineMenuTitle is empty then
      put "List | Menu" into lineMenuTitle -- a local menu to the field
      put CR & "-" after lineMenuTitle
      put CR & "Global | IndexView | Line | Menu" after lineMenuTitle -- a local menu to the field
      put tab & "submenu" & tab & "Tools" after lineMenuTitle
   end if
   return lineMenuTitle
end line_Menu

setprop line_Menu lineMenuName
   put lineMenuName into LocalArray ["line_Menu"]
end line_Menu

getprop title_Menu
   put LocalArray ["title_Menu"] into mTitle
   if mTitle is empty then return "Title | Menu"
   return mTitle
end title_Menu

setprop title_Menu mTitle
   put mTitle into LocalArray ["title_Menu"]
end title_Menu

getprop view_MenuArray
   put the title_Menu of me into menuArray ["title"]
   put the line_Menu of me into menuArray ["line"]
   return menuArray
end view_MenuArray

setprop view_MenuArray menuArray
   set the title_Menu of me to menuArray ["title"]
   set the line_Menu of me to menuArray ["line"]
end view_MenuArray


--> Events | Handlers
-
private command _doFieldClick
   put the mouse_UpEvent of me into mouseUpEvent
   if mouseUpEvent is empty then return empty
   
   put the clickText into someLine
   put the long id of me into targetControl
   put the event_Target of me into eventTarget
   if exists (eventTarget) is true then
      dispatch mouseUpEvent to eventTarget with targetControl,someLine
   else
      dispatch mouseUpEvent to me with targetControl,someLine
   end if
   return mouseUpEvent
end _doFieldClick

private command _doFieldDoubleClick
   put the mouse_DoubleUpEvent of me into mouseDoubleUpEvent
   if mouseDoubleUpEvent is empty then return empty
   
   put the event_Target of me into eventTarget
   if exists (eventTarget) is true then
      put the long id of me into targetControl
      put the clickText into someLine
      dispatch mouseDoubleUpEvent to eventTarget with targetControl,someLine
   else
      do mouseDoubleUpEvent
   end if
   return mouseDoubleUpEvent
end _doFieldDoubleClick


--> Events | Custom
-
on refreshDisplay
   -- put the rect of this card into cardRect
   put the rect of me into viewRect
   LayoutControl viewRect
end refreshDisplay

command LayoutControl pRect
   lock screen
   if pRect is empty then put the rect of me into pRect
   
   if the showborder of me is true then
      put the borderwidth of me into bWidth
      rect_SubtractMargins pRect, bWidth
   end if
   rect_SubtractMargins pRect, the margins of me
   
   set the rect of _titleView() to _headerRect (pRect)
   set the rect of _fieldObject() to _fieldRect (pRect)
   unlock screen
end LayoutControl


--> Index | Title
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


--> Data
-
getprop displayed_Index
   return the view_Index of me
end displayed_Index

setprop displayed_Index [someTitle] someIndex
   set the view_Index [someTitle] of me to someIndex
   return the result
end displayed_Index

getprop displayed_Array
   put LocalArray ["displayed_Data"] into someArray
   return someArray
end displayed_Array

setprop displayed_Array [someTitle] someArray
   -- also sets the display
   put keys (someArray) into someIndex
   sort someIndex
   set the view_Index [someTitle] of me to someIndex
   put someArray into LocalArray ["displayed_Data"]
end displayed_Array

getprop displayed_Data
   put LocalArray ["displayed_Data"] into someArray
   return someArray
end displayed_Data

setprop displayed_Data someArray
   put someArray into LocalArray ["displayed_Data"]
end displayed_Data

getprop meta_Data [someKey]
   put LocalArray ["meta_Data"][someKey] into someValue
   return someValue
end meta_Data

setprop meta_Data [someKey] someValue
   put someValue into LocalArray ["meta_Data"][someKey]
end meta_Data


--> Title
-
getprop title_Lines
   put LocalArray ["title_Lines"] into lineNumList
   return lineNumList
end title_Lines

setprop title_Lines [someColour] lineNumList
   replace CR with comma in lineNumList
   put _fieldObject() into fieldObject
   --
   lock screen
   repeat for each item lineNum in lineNumList
      if someColour is not empty then
         set the textcolor of line lineNum of fieldObject to someColour
      end if
      set the textstyle of line lineNum of fieldObject to "bold"
   end repeat
   unlock screen
   --
   put lineNumList into LocalArray ["title_Lines"]
end title_Lines

getprop hilited_Line
   put the hilited_Lines of me into lineNumList
   return item 1 of lineNumList
end hilited_Line

setprop hilited_Line lineNum
   set the hilited_Lines of _fieldObject() to lineNum
   put the result into fieldObject
   return fieldObject
end hilited_Line

getprop hilited_Lines
   put the hilitedlines of _fieldObject() into lineNumList
   return lineNumList
end hilited_Lines

setprop hilited_Lines lineNumList
   put _fieldObject() into fieldObject
   replace CR with comma in lineNumList
   set the hilitedlines of fieldObject to lineNumList
   return fieldObject
end hilited_Lines

getprop line_Colours [someColour]
   put _fieldObject() into fieldObject
   
   put the number of lines of the text of fieldObject into maxNum
   repeat with lineNum = 1 to maxNum
      put the textcolor of line lineNum of fieldObject into foundColour
      if foundColour = empty then put "none" into foundColour
      put the textstyle of line lineNum of fieldObject into someStyle
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
end line_Colours

setprop line_Colours colourArray
   put _fieldObject() into fieldObject
   
   lock screen
   repeat for each key someColour in colourArray
      put colourArray [someColour] into lineNumArray
      if someColour = "none" then put empty into someColour
      repeat for each key lineNum in lineNumArray
         set the textcolor of line lineNum of fieldObject to someColour
      end repeat
   end repeat
   unlock screen
end line_Colours

getprop line_Colour [lineNum]
   put _fieldObject() into fieldObject
   if lineNum is empty then
      put line 1 of the hilitedlines of fieldObject into lineNum
   end if
   put the textcolor of line lineNum of fieldObject into someColour
   return someColour
end line_Colour

setprop line_Colour [lineNumList] someColour
   -- could change to using:
   -- put the styledText of fieldObject into styledArray
   
   put _fieldObject() into fieldObject
   if lineNumList is empty then
      put line 1 of the hilitedlines of fieldObject into lineNumList
   end if
   
   lock screen
   repeat for each item lineNum in lineNumList
      if lineNum is not a number then next repeat
      set the textcolor of line lineNum of fieldObject to someColour
   end repeat
   unlock screen
end line_Colour


--> Index | Selected
-
setprop deleted_Line someLine
   put the line_Number [someLine] of me into lineNum
   put the short id of _fieldObject() into fldID
   delete line lineNum of fld id fldID of me
   return lineNum
end deleted_Line

getprop line_Number [someLine]
   put the view_Index of _fieldObject() into someIndex
   set the wholeMatches to true
   put lineOffset (someLine, someIndex) into lineNum
   return lineNum
end line_Number

setprop line_Number [someLine] someValue
   put the view_Index of _fieldObject() into someIndex
   set the wholeMatches to true
   put lineOffset (someLine, someIndex) into lineNum
   if lineNum is 0 then return 0
   
   put the short id of _fieldObject() into fldID
   set the text of line lineNum of fld id fldID of me to someValue
   return lineNum
end line_Number

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
   put the view_Index of me into viewIndex
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
   put the view_Index of me into viewIndex
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
   return the view_Index of me
end view_Text

setprop view_Text someText
   lock screen
   set the view_Index of me to someText
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
         break
      case "click"
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         set the toggleHilites of fieldView to false
         break
      case "scrolling"
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to false
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         break
      case "multiselect"
         set the listbehavior of fieldView to true
         set the multiple_Hilites of fieldView to true
         set the dontwrap of fieldView to true
         set the locktext of fieldView to true
         set the autoHilite of fieldView to true
         break
      case "display selected"
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
getprop displayed_Object
   -- put LocalArray ["displayedObject"] into displayedObject
   put the displayed_Object of me into displayedObject -- so it is stored for each view
   if exists (displayedObject) is false then return the long id of me
   return displayedObject
end displayed_Object

setprop displayed_Object displayedObject
   -- put displayedObject into LocalArray ["displayedObject"]
   set the displayed_Object of me to displayedObject -- so it is stored for each view
end displayed_Object

getprop displayed_Text
   return the view_Index of me
end displayed_Text

setprop displayed_Text someText
   set the view_Index of me to someText
   return the result
end displayed_Text

getprop view_Index
   put the text of _fieldObject() into someIndex
   return someIndex
end view_Index

setprop view_Index [someTitle] someIndex
   lock screen
   put _fieldObject() into fieldObject
   if someTitle is not empty then
      set the title_Text of me to someTitle
   end if
   set the text of fieldObject to someIndex
   unlock screen
   return fieldObject
end view_Index


--> EventArray
-
getprop view_EventArray eventArray   
   put the event_Target of me into eventArray ["eventTarget"]
   put the drag_Command of me into eventArray ["dragCommand"]
   put the mouse_UpEvent of me into eventArray ["mouseUp"]
   put the mouse_DoubleUpEvent of me into eventArray ["mouseDoubleUp"]
   return eventArray
end view_EventArray

setprop view_EventArray eventArray   
   put eventArray ["dragCommand"] into LocalArray ["event"]["dragCommand"]
   put eventArray ["eventTarget"] into LocalArray ["event"]["eventTarget"]
   put eventArray ["mouseUp"] into LocalArray ["event"]["mouseUp"]
   put eventArray ["mouseDoubleUp"] into LocalArray ["event"]["mouseDoubleUp"]
end view_EventArray

getprop event_Target
   put LocalArray ["event"]["eventTarget"] into eventTarget
   return eventTarget
end event_Target

setprop event_Target eventTarget
   put eventTarget into LocalArray ["event"]["eventTarget"]
end event_Target

getprop mouse_UpEvent
   put LocalArray ["event"]["mouseUp"] into mouseUpEvent
   return mouseUpEvent
end mouse_UpEvent

setprop mouse_UpEvent mouseUpEvent
   put mouseUpEvent into LocalArray ["event"]["mouseUp"]
end mouse_UpEvent

getprop mouse_DoubleUpEvent
   put LocalArray ["event"]["mouseDoubleUp"] into mouseDoubleUp
   return mouseDoubleUp
end mouse_DoubleUpEvent

setprop mouse_DoubleUpEvent mouseDoubleUp
   put mouseDoubleUp into LocalArray ["event"]["mouseDoubleUp"]
end mouse_DoubleUpEvent


--> Names and Titles
-
/*
Rationalise these naames and check other external handlers do not reference old ones.
*/

getprop group_Name
   put the short name of me into someTitle
   return someTitle
end group_Name

setprop group_Name [someColour] someTitle
   lock screen
   set the label of _titleView() to someTitle
   set the name of me to someTitle
   set the title_Colour of me to someColour
   unlock screen
end group_Name


--> Title | Colours
-
getprop title_Colour
   return the backgroundcolor of _titleView()
end title_Colour

setprop title_Colour someColour
   if someColour is "random" then put colour_GetRandom() into someColour
   set the backgroundcolor of _titleView() to someColour
   return someColour
end title_Colour

getprop title_TextColour
   return the foregroundcolor of _titleView()
end title_TextColour

setprop title_TextColour someColour
   if someColour is "random" then put colour_GetRandom() into someColour
   set the foregroundcolor of _titleView() to someColour
   return someColour
end title_TextColour


--> Geometry
-
getprop formatted_Rect
   -- utility function not needed for LayoutControl
   
   put _fieldObject() into fieldObject
   put _titleView() into titleView
   put the rect of me into pRect
   
   put the effective height of titleView into titleHeight
   put the formattedheight of fieldObject into formattedFieldHeight
   add 45 to formattedFieldHeight
   put max (90, formattedFieldHeight) into newHeight
   
   put the formattedwidth of titleView into formattedTitleWidth
   put the formattedwidth of fieldObject into formattedFieldWidth
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
   refreshDisplay
   return the result
end header_Height


--> Objects
-
getprop view_Object
   return the long id of me
end view_Object

getprop index_View
   return the long id of me
end index_View

getprop index_Field
   return _fieldObject()
end index_Field


--> Private
-
private function _titleView
   put the long id of btn 1 of me into headerWidget
   return headerWidget
end _titleView

private function _fieldObject
   put the long id of field 1 of me into arrayWidget
   return arrayWidget
end _fieldObject

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


--> Deps
-
function colour_GetRandom
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom

command rect_SubtractMargins @someRect, pMargin
   margin_Normalize pMargin, leftM, topM, rightM, bottomM   
   add leftM to item 1 of someRect
   add topM to item 2 of someRect
   subtract rightM from item 3 of someRect
   subtract bottomM from item 4 of someRect
end rect_SubtractMargins

command margin_Normalize @someMargin, @leftM, @topM, @rightM, @bottomM
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
end margin_Normalize

