script "lib_MenuText"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_MenuText
type: library
version: 0.2


--> Working on
-
/* -- models using LocalArray

function mArray_GetActiveArray
   return LocalArray ["active_MenuArray"]
end mArray_GetActiveArray

command mArray_SetActiveItem mItem
   -- used, but needed?
   put mItem into LocalArray ["active_MenuItemPath"]
end mArray_SetActiveItem

getprop menu_Target
   breakpoint -- a default
   put the long id of the target into tObject
   put the view_Object of tObject into vObject
   if exists (vObject) then
      return vObject
   else
      return tObject
   end if
end menu_Target

getprop view_Object
   -- a default (ideally this handler is present as a behavior of script of the view)
   put the long id of the target into targetObject
   return view_FindAbove (targetObject)
end view_Object

command menu_PopUp mTitle, mButton
   put the menu_Text of the target into mText
   set the text of mButton to mText
   --
   popup mButton
end menu_PopUp

private command _AddMenuItem @mArray, hName, mController, mTarget
   -- removed LocalArray
   _DeconstructHandlerName hName, propLabel, shortCut
   --
   put _ParamsProp (propLabel, mTarget) into mProperty
   try
      put the mProperty of mController into paramValues
      put paramValues into paramArray [mController][hName]["mParams"]
   catch e
      put empty into paramValues
      put ("Error, with:" && mProperty) into paramArray [mController][hName]["mParams"]
   end try
   --
   put _NextIndexNum (mArray) into indexNum
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put text_SplitCaps (propLabel) into mArray [indexNum]["label"]
   put shortCut into mArray [indexNum]["shortCut"]
   --
   if paramValues is empty then
      put _CheckItemProp (hName, mTarget) into mProperty
      put the mProperty of mController into hNameIsChecked
      --
      put mTarget into paramArray [mController][hName]["hNameIsChecked"][hNameIsChecked]
      put hNameIsChecked is true into mArray [indexNum]["checked"]
   else
      put _CheckParamsProp (propLabel, mTarget) into mProperty
      put the mProperty of mController into checkParams
      --
      put checkParams into paramArray [mController][hName]["mCheckParams"]
      _SetParamMenuItem mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   end if
   return paramArray -- was LocalArray ["Params"]
end _AddMenuItem

private command _SetParamMenuItem @mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   replace comma with CR in paramValues
   replace comma with CR in checkParams
   set the wholematches to true
   
   # Not safe for widget bug ordering
   put 1 into subIndexNum
   repeat for each line paramValue in paramValues
      put paramValue into subMenuArray [subIndexNum]["label"]
      put "param" && paramValue into subMenuArray [subIndexNum]["name"]
      put paramValue is among the lines of checkParams into someBoolean
      put someBoolean is true into subMenuArray [subIndexNum]["checked"]
      --
      add 1 to subIndexNum
   end repeat
   put subMenuArray into mArray [indexNum]["menu"]
end _SetParamMenuItem


--> Defaults | Optional
-
getprop menu_Controller [pMenuTitle]
   put the long id of the target into tObject
   --
   put menu_GetGlobalController (pMenuTitle) into mController
   if exists (mController) is true then return mController
   return empty
end menu_Controller

private function view_FindAbove targetObject
   repeat
      if the uRIP ["type"] of targetObject is "view" then return targetObject
      if word 1 of targetObject = "group" and the selectGroupedControls of targetObject then return targetObject 
      if word 1 of targetObject = "stack" or targetObject = empty then return empty
      delete word 1 to 4 of targetObject -- does not work for substacks
   end repeat
   return empty
end view_FindAbove


--> MenuPick | Deps
-
command menu_TextPick mItemPath
   -- simplified "menu_DispatchTextPick"
   put the long id of the target into tObject
   put the menu_Target of tObject into mTarget
   
   if pNested is false then
      # Simple version
      put the menu_Controller of mTarget into mController
      
      # Construct hName
      set the itemdelimiter to "|"
      --
      put item 1 of mItemPath into hPostFix
      replace space with empty in hPostFix
      put "menu_" & hPostFix into hName
      --
      put item 2 of mItemPath into pValue
   else
      # Nested menus have different mControllers
      put mArray_GetActiveArray() into pMenuArray
      mArray_SetActiveItem mItemPath
      mArray_FindActive pMenuArray, mItemPath, hKey, pValue
      hkeyLine_Deconstruct hKey, hName, hType, mController
   end if
   
   if the optionKey is "down" then
      menu_OptionAnswer hName, mController
   else
      # Construct callCOmmand
      put hName && "mTarget,pValue" into callCommand
      --
      call callCommand of mController
      return hKey
   end if
end menu_TextPick

function mArray_FindActiveHkey mItem, pMenuArray
   if pMenuArray is not an array then
      put mArray_GetActiveArray() into pMenuArray
   end if
   --
   mArray_SetActiveItem mItem
   mArray_FindActive pMenuArray, mItem, hKey, paramValue  
   return hKey
end mArray_FindActiveHkey

command display_MenuItemHelp hKey
   hkeyLine_Deconstruct hKey, hName, hType, mController
   -- put the stack_Name of mController into mTitle
   
   set the itemdelimiter to "_"
   switch
      case hType is not "M"
      case item 1 of hName is not "menu"
         return "Error, handler is not a menu-item:" && hKey
      default
         put the menu_GlobalTitle of mController into mTitle
         if mTitle is empty then
            return "Error, handler is not in a menu_Controller:" && hKey
         end if
   end switch
   --
   put help_TiddlyMenuFile (mTitle) into mFile
   if there is not a file mFile then
      breakpoint
      tiddly_CreateMenuHelp mTitle
   end if
   
   display_MenuHelp mTitle
end display_MenuItemHelp

command hkey_Edit hKey
   # Find Hkey
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into hkeyLine
   if exists (hObject) is false then
      return "Error, cannot find object for hkey:" && hKey
   end if
   
   put the hkey_StartLine [hkeyLine] of hObject into sLineNum
   scriptEditor_EditAndScroll hObject, sLineNum, hName  
   return sLineNum
end hkey_Edit

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

command mArray_FindActive mArray, mItemPath, @hkey, @paramValue
   -- only used by "menu_DispatchTextPick" (was "_FindActiveHkey")
   set the itemdelimiter to "|"
   put mItemPath into subItemPath
   repeat the number of items of mItemPath
      put item 1 of subItemPath into itemText
      put _FindItemArray (mArray, itemText) into nextItemArray
      --
      if nextItemArray is not an array then
         -- was the last one -- probably because itemText caontained a param like "Hello|World"
         exit repeat
      else
         put nextItemArray into itemArray
      end if
      
      delete item 1 of subItemPath
      --
      put itemArray ["menu"] into subMenuArray
      if subMenuArray is an array then
         -- do we need to check that mItemPath is not emmpty?
         put itemArray ["name"] into hkey
         put subMenuArray into mArray
      else
         exit repeat -- at end (no more submenus)
      end if
   end repeat
   --
   put itemArray ["name"] into itemName
   if word 1 of itemName is "param" then
      put word 2 to -1 of itemName into paramValue
   else
      put itemName into hkey
      put subItemPath into paramValue -- should be empty unless parramm contains "|"
   end if
end mArray_FindActive

command menu_OptionAnswer hName, mController
   put hKeyLine_Construct (hName, "M", mController) into hKey
   mArray_OptionAnswer hKey
end menu_OptionAnswer

command menu_TextPick mItemPath
   -- simplified "menu_DispatchTextPick"
   put the long id of the target into tObject
   put the menu_Target of tObject into mTarget
   
   if pNested is false then
      # Simple version
      put the menu_Controller of mTarget into mController
      
      # Construct hName
      set the itemdelimiter to "|"
      --
      put item 1 of mItemPath into hPostFix
      replace space with empty in hPostFix
      put "menu_" & hPostFix into hName
      --
      put item 2 of mItemPath into pValue
   else
      # Nested menus have different mControllers
      put mArray_GetActiveArray() into pMenuArray
      mArray_SetActiveItem mItemPath
      mArray_FindActive pMenuArray, mItemPath, hKey, pValue
      hkeyLine_Deconstruct hKey, hName, hType, mController
   end if
   
   if the optionKey is "down" then
      menu_OptionAnswer hName, mController
   else
      # Construct callCOmmand
      put hName && "mTarget,pValue" into callCommand
      --
      call callCommand of mController
      return hKey
   end if
end menu_TextPick

private function _FindItemArray mArray, itemText
   -- forgot why this is indexed with "01" rather thaan "1"
   -- something to do with display sorting, but a bad solution I think
   -- repeat with indexNum = 1 to item 2 of the extents of mArray
   put keys (mArray) into orderedNums
   sort numeric orderedNums
   repeat for each line indexNum in orderedNums
      put mArray [indexNum] into itemArray
      if itemArray ["label"] = itemText then
         return itemArray
      end if
   end repeat
   return empty
end _FindItemArray

command field_ScrollToLine lineNum, fieldObject, pSelectLine
   -- does not seem accurate for large line numbers (it's an underestimate) ???
   
   if lineNum = 0 then
      put 0 into someScroll
   else if lineNum is a number then
      put the effective textHeight of fieldObject into lineHeight
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   else -- any text = "bottom"
      -- bit of a hack (but works :)
      put the effective textHeight of fieldObject into lineHeight
      put the number of lines of the text of fieldObject into lineNum
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   end if
   set the scroll of fieldObject to someScroll
   if pSelectLine is not false then
      select line lineNum of fieldObject
   end if
end field_ScrollToLine

getprop hkey_StartLine [hkeyLine]
   put word 1 to 2 of hkeyLine into shortHkey
   put the revAvailableHandlers of the target into hTable
   repeat for each line someLine in hTable
      if word 1 to 2 of someLine = shortHkey then
         put word 3 of someLine into startLineNum
         return startLineNum
      end if
   end repeat
   return 0
end hkey_StartLine

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

command mArray_OptionAnswer hKey, pQuestion
   put scriptEditor_GetTop() into stackObject
   if pQuestion is empty then
      put "Edit script for this handler?" into pQuestion
   end if
   answer pQuestion with "Cancel" or "Help" or "OK" as sheet
   switch it
      case "Help"
         display_MenuItemHelp hKey
         break
      case "Cancel"
         break
      case "OK"
         hkey_Edit hKey
         break
   end switch
   exit to top
end mArray_OptionAnswer

function menu_GetGlobalController mTitle, pWithModel
   if there is a stack mTitle then
      return the name of stack mTitle
   else
      return empty
   end if
end menu_GetGlobalController

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (fld "Script" of group "Editor" of cd "Main" of editorStack) is false then return empty
   put the long id of fld "Script" of group "Editor" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return scriptEditor_GetTop()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
      default
         return scriptEditor_GetTop()
   end switch
end rev_ScriptEditorStack

command scriptEditor_EditAndScroll hObject, scriptLineNum, hName
   edit the script of hObject
   put rev_HandlerTreeField() into handlerTreeField
   put rev_ScriptEditorField() into scriptEditorField
   --
   put the text of handlerTreeField into hIndex
   --
   try
      lock screen
      if hName is not empty then
         put lineOffset (hName, hIndex) into hLineNum
         set the hilitedLine of handlerTreeField to hLineNum
      end if
      --
      field_ScrollToLine scriptLineNum, scriptEditorField, true
      dispatch "closeAccept" to handlerTreeField
      unlock screen
      --
      return empty
   catch e
      return the executioncontexts
   end try
end scriptEditor_EditAndScroll

function scriptEditor_GetTop
   -- was "scriptEditor_GetTop()"
   
   put the short name of the defaultstack into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      if stackNames is empty then return empty
      put line 1 of stackNames into firstEditorStackName
      return the long id of stack firstEditorStackName
   end if
end scriptEditor_GetTop


--> MenuText | Deps
-
getprop menu_Text
   put the menu_Array of the target into mArray
   put mArray_ToText (mArray) into mText
   return mText
end menu_Text

getprop menu_Array
   -- does not do recursive sub_Menu or insert_Menu
   local mArray
   put the long id of the target into tObject
   --
   -- put the script_MenuTitle of tObject into mTitle
   put the menu_Target of tObject into mTarget
   put the menu_Controller of tObject into mController
   if exists (mController) is false then
      return "Error, cannot locate mController of:" && tObject
   end if
   
   put the menu_Handlers of mController into scriptHandlers
   repeat for each line hName in scriptHandlers       
      if hName ends with "_" then
         _AddDivider mArray
         next repeat
      end if
      
      put _DisabledProp (hName, mTarget) into mProperty
      put the mProperty of mController into isDisabled
      switch
         case isDisabled = "delete"
            next repeat
         case hName begins with "submenu_"
            break
         case hName begins with "insert_"
            break
         default
            _AddMenuItem mArray, hName, mController, mTarget
            _SetDisabled mArray, isDisabled
      end switch
   end repeat
   return mArray
end menu_Array

getprop menu_Controller [pMenuTitle]
   put the long id of the target into tObject
   --
   put menu_GetGlobalController (pMenuTitle) into mController
   if exists (mController) is true then return mController
   return empty
end menu_Controller

getprop menu_Handlers [pAddDviders]
   -- can be simpler
   put the long id of the target into mController
   return menuItem_List (mController, pAddDviders)
end menu_Handlers

private command _AddDivider @mArray
   put _NextIndexNum (mArray) into indexNum
   put "-" into mArray [indexNum]["name"]
   put "-" into mArray [indexNum]["label"]
   put false into mArray [indexNum]["checked"]
   return indexNum
end _AddDivider


--> Private
-
private function _CheckItemProp hName, mTarget
   put _PropLabel (hName) into hText
   put "checked_" & hText & "[" & mTarget & "]" into mProperty
   return mProperty
end _CheckItemProp

private function _CheckParamsProp propLabel, mTarget
   put propLabel & "_Param" & "[" & mTarget & "]" into mProperty
   return mProperty
end _CheckParamsProp

private command _DeconstructHandlerName hName, @propLabel, @shortCut
   set the itemdelimiter to "_"
   get item 2 of hName
   set the itemdelimiter to "."
   put item 1 of it into propLabel
   put item 2 to -1 of it into shortCut
end _DeconstructHandlerName

private function _DisabledProp hName, mTarget
   put _PropLabel(hName) into hText
   put "disabled_" & hText & "[" & mTarget & "]" into mProperty
   return mProperty
end _DisabledProp

private command _MarshalController @hkeyController
   replace "|" with "\" in hkeyController
end _MarshalController

private function _NextIndexNum mArray
   -- padding added due to ordering issue with widget
   if mArray is an array then
      put item 2 of the extents of mArray into indexNum
      add 1 to indexNum
   else
      put 01 into indexNum
   end if
   number_PadLeft indexNum, 2
   return indexNum
end _NextIndexNum

private function _ParamsProp propLabel, mTarget
   put propLabel & "_Params" & "[" & mTarget & "]" into mProperty
   return mProperty
end _ParamsProp

private function _PropLabel hName
   _DeconstructHandlerName hName, propLabel, shortCut
   return propLabel
end _PropLabel

private command _SetDisabled @mArray, isDisabled
   if isDisabled is not empty then
      put item 2 of the extents of mArray into indexNum
      number_PadLeft indexNum, 2
      put isDisabled is true into mArray [indexNum]["disabled"]
   end if
end _SetDisabled

private command _TextRecurse @mText, someIndent, mArray, pController, pMenuTarget
   put keys (mArray) into indexNums
   sort numeric indexNums
   repeat for each line indexNum in indexNums
      put mArray [indexNum] into itemArray
      --
      put itemArray ["name"] into mController
      put itemArray ["label"] into itemText
      
      # Set disabled
      if pController is empty then
         put itemArray ["checked"] into isChecked
         put itemArray ["disabled"] into isDisabled
      else
         -- check live (not sure if this is ever used?)
         -- put mArray_GetObjectCheckStatus (hName, pController, pMenuTarget) into isDisabled
         put mArray_GetDisabled (hName, pController, pMenuTarget) into isDisabled
      end if
      if isDisabled is true then put "(" before itemText
      
      # Set Shortcut
      put itemArray ["shortcut"] into shortcut
      if shortcut is not empty then
         put "/" & shortCut after itemText
      end if
      
      # Set checked
      if isChecked is true then
         put "!c" before itemText
      else
         -- put "!n" before itemText
      end if
      put someIndent & itemText & CR after mText
      
      # Recurse
      put itemArray ["menu"] into subArray
      if subArray is an array then
         put tab & someIndent into nextIndent
         _TextRecurse mText, nextIndent, subArray
      end if
   end repeat
end _TextRecurse

function hkey_Construct hName, hType, tObject
   if exists (tObject) is false then
      put "Missing" into hObject
   end if
   replace "C" with "M" in hType
   put hKeyLine_Construct (hName, hType, tObject) into hKeyLine
   return hKeyLine
end hkey_Construct

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

function mArray_ConstructHkey hName, mController
   put hkey_Construct (hName, "M", mController) into hkeyController
   _MarshalController hkeyController
   return hkeyController
end mArray_ConstructHkey

function mArray_GetDisabled hName, mController, mTarget
   put _DisabledProp (hName, mTarget) into mProperty
   put the mProperty of mController into isDisabled
   return isDisabled
end mArray_GetDisabled

function mArray_ToText mArray
   local mText
   put empty into someIndent
   _TextRecurse mText, someIndent, mArray
   delete char -1 of mText
   return mText
end mArray_ToText

function menu_GetGlobalController mTitle, pWithModel
   if there is a stack mTitle then
      return the name of stack mTitle
   else
      return empty
   end if
end menu_GetGlobalController

function menuItem_List mController, pAddDviders
   # List handler names
   -- Assumes only one menu and all named "menu_"
   local hNames
   
   put the revAvailableHandlers of mController into hTable
   sort numeric hTable by word 3 of each
   -- filter hTable with "M menu_*"
   repeat for each line hLine in hTable
      put word 1 to 2 of hLine into shortKey
      put word 2 of hLine into hName
      --
      switch
         case shortKey = "M submenu_Dev"
            if the shiftKey is "Down" then
               put hName & CR after hNames
            end if
            break
         case hName = "menu_Init"
            break
         case (hName ends with "_") AND (pAddDviders is not false)
            ## Divider is a command ending with "_"
            if hNames is empty then
               -- breakpoint
            else
               put "_" & CR after hNames -- should be "-" ???
            end if
            break
         case hLine begins with "M submenu_"
         case hLine begins with "M insert_"
         case hLine begins with "M menu_"
            put word 2 of hLine into hName
            put hName & CR after hNames
            break
         default
            -- not a menu
      end switch
   end repeat
   delete char -1 of hNames
   return hNames
end menuItem_List

private command number_PadLeft @someNum, padNum
   put "%0" & padNum & "d" into fString
   put format (fString, someNum) into someNum
end number_PadLeft

function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower (word wordNum of someText) into someWord
      put toupper (char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps

private function text_SplitCaps sWord, pDelimChar
   put word_SplitCaps (sWord, pDelimChar) into sText
   put text_InitialCaps (word 1 of sText) into word 1 of sText
   return sText
end text_SplitCaps

function text_StartsWithCaps someText
   put char 1 of sometext into testChar
   put nativeCharToNum (testChar) into someCharNum
   if someCharNum >= 97 and someCharNum <= 122 then
      return false
   else
      return true
   end if
end text_StartsWithCaps

private function word_SplitCaps sWord, pDelimChar
   if pDelimChar is empty then put space into pDelimChar
   --
   put 1 into charNum
   repeat the number of chars of sWord
      put char charNum of sWord into sChar
      if text_StartsWithCaps (sChar) is true then
         put pDelimChar before char charNum of sWord
         add 2 to charNum
      else
         add 1 to charNum
      end if
   end repeat
   put the number of chars of pDelimChar into maxNum
   delete char 1 to maxNum of sWord
   return sWord
end word_SplitCaps


--> Deps
-
*/
