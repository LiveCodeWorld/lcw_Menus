script "lib_MenuArray"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_MenuArray
type: library

/*
This library is for the set of handlers that deal with new menu array format used by widgets.

In order to account for menus that are directed at targets that are not related to the objects clicked on we must use a local or global variable

function fetchFromUrl jsonURL
   put url someURL into utf8JSON
   put textDecode (jsonURL, "UTF-8") into encodedJSON
   put json_ToArray (encodedJSON) into someArray
   return someArray
end fetchFromUrl

command exportToUrl someArray, jsonURL
   put json_FromArray (someArray) into encodedJSON
   put textEncode (encodedJSON, "UTF-8") into decodedJSON
   put decodedJSON into url someURL
end exportToUrl
*/

--> Variables
-
local LocalArray


--> Working on
-
function menu_IsGlobal mTitle
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of mTitle = "Global" \
         AND word 1 to -1 of item -1 of mTitle = "Menu" then
         return true
   else
      return false
   end if
end menu_IsGlobal

private function _MenuCheckFailed mTitle, mType, tObject, topMenuController, mTitleTable, mArray
   # Error due to "menu_CheckTarget" returns false (or menu does not exist)
   # We should just disable the menu, but now there is an issue with that that is hard to debug.
   
   # Gather info
   put mTitle into errorData ["mTitle"]
   put mType into errorData ["mType"]
   put mType into errorData ["mType"]
   put topMenuController into errorData ["topMenuController"]
   put mTitleTable into errorData ["mTitleTable"]
   put mArray into errorData ["mArray"]
   --
   global gLCW
   put errorData into gLCW ["Error"]["menu_CheckTarget"]
   
   # Get a simple safe menu to display
   local recursionArray
   put mArray_FromScript ("Global | Menu | Error | Menu", tObject, tObject, recursionArray) into mArray
   return mArray
   
   # Don't do this
   -- AddScriptMenu mArray, "Global | Menu | Error | Menu", tObject, tObject, recursionArray -- error, recurses!
end _MenuCheckFailed

getprop menu_Marray [mTitle]
   -- simple tester
   local mArray, recursionArray
   --
   put the long id of the target into tObject
   put tObject into mController
   --
   _AddScriptMenu mArray, mTitle, tObject, mController, recursionArray
   --
   return mArray
end menu_Marray

function mArray_FromScript mTitle, tObject, mController, @recursionArray
   local mArray
   _AddScriptMenu mArray, mTitle, tObject, mController, recursionArray
   return mArray
end mArray_FromScript

private command _DeconstructHandlerName hName, @propLabel, @shortCut
   set the itemdelimiter to "_"
   get item 2 of hName
   set the itemdelimiter to "."
   put item 1 of it into propLabel
   put item 2 to -1 of it into shortCut
end _DeconstructHandlerName

private function _PropLabel hName
   _DeconstructHandlerName hName, propLabel, shortCut
   return propLabel
end _PropLabel

function menu_CommandToText hName
   _DeconstructHandlerName hName, propLabel, shortCut
   put text_SplitCaps (propLabel) into mLine
   return mLine
end menu_CommandToText

command mArray_TextRecurse @mText, someIndent, mArray, pController, pMenuTarget
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
         mArray_TextRecurse mText, nextIndent, subArray
      end if
   end repeat
end mArray_TextRecurse

function mArray_GetDisabled hName, mController, mTarget
   put _PropLabel(hName) into hText
   put "disabled_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into isDisabled
   return isDisabled
end mArray_GetDisabled

function mArray_GetCheckItem hName, mController, mTarget
   put _PropLabel(hName) into hText
   put "checked_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into someBoolean
   return someBoolean is true
end mArray_GetCheckItem

function mArray_GetParamValues propLabel, mController, mTarget
   put propLabel & "_Params" & "[" & mTarget & "]" into mProperty
   try
      put the mProperty of mController into paramValues
      return paramValues
   catch e
      -- edit the script of mController
      lcw_Notify the params
   end try
end mArray_GetParamValues

function mArray_GetCheckParams propLabel, mController, mTarget
   put propLabel & "_Param" & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into checkParams
   return checkParams
end mArray_GetCheckParams


--> Private | Construct | MenuItem
-
private command _AddMenuItem @mArray, hName, mController, mTarget
   _DeconstructHandlerName hName, propLabel, shortCut
   --
   put mArray_GetParamValues (propLabel, mController, mTarget) into paramValues
   put paramValues into LocalArray ["Params"][mController][hName]["mParams"]
   --
   put _NextIndexNum (mArray) into indexNum
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put text_SplitCaps (propLabel) into mArray [indexNum]["label"] -- menu_CommandToText (hName)
   put shortCut into mArray [indexNum]["shortCut"]
   --
   if paramValues is empty then
      put mArray_GetCheckItem (hName, mController, mTarget) into hNameIsChecked
      put mTarget into LocalArray ["Params"][mController][hName]["hNameIsChecked"][hNameIsChecked]
      --
      -- bizarre bug in Livecode widget being strict on boolean type an text type
      -- put true into mArray [indexNum]["disabled"] does not seem possible
      -- put itemChecked into mArray [indexNum]["checked"] -- does nto work!
      
      -- put item 2 of the extents of mArray into indexNum
      -- number_PadLeft indexNum, 2
      put hNameIsChecked is true into mArray [indexNum]["checked"]
   else
      put mArray_GetCheckParams (propLabel, mController, mTarget) into checkParams
      put checkParams into LocalArray ["Params"][mController][hName]["mCheckParams"]
      --
      _SetParamMenuItem mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   end if
   return true
end _AddMenuItem

private command _SetParamMenuItem @mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   replace comma with CR in paramValues
   replace comma with CR in checkParams
   set the wholematches to true
   
   -- not safe for widget bug ordering
   put 1 into subIndexNum
   repeat for each line paramValue in paramValues
      put paramValue into subMenuArray [subIndexNum]["label"]
      --
      put "param" && paramValue into subMenuArray [subIndexNum]["name"]
      --
      put paramValue is among the lines of checkParams into someBoolean
      put someBoolean is true into subMenuArray [subIndexNum]["checked"]
      --
      add 1 to subIndexNum
   end repeat
   
   put subMenuArray into mArray [indexNum]["menu"]
   
   # Set mArray
   -- put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   -- put text_SplitCaps (propLabel) into mArray [indexNum]["label"]
end _SetParamMenuItem

private command _SetDisabled @mArray, isDisabled
   if isDisabled is not empty then
      put item 2 of the extents of mArray into indexNum
      number_PadLeft indexNum, 2
      put isDisabled is true into mArray [indexNum]["disabled"]
   end if
end _SetDisabled


--> mTarget
-
function mArray_FindMenuTarget mController, tObject
   -- logic: controller, target (called for every nested menu)
   
   if exists (tObject) is false then
      put menu_GetTopTargetObject() into tObject -- bug: should exist
   end if
   --
   if exists (mController) is true then
      put the menu_Target [tObject] of mController into mTarget
      if mTarget is not empty then return mTarget
   end if
   --
   put the menu_Target [tObject] of tObject into mTarget
   if mTarget is empty then
      return tObject
   else
      return mTarget
   end if
end mArray_FindMenuTarget

command mArray_ClearActiveMenuArray
   delete variable LocalArray
end mArray_ClearActiveMenuArray

private command _SubmenuBit @mArray, hName, mController, tObject, @recursionArray, mTarget
   -- bug: can recurse
   dispatch hName to mController with mTarget
   put the result into subMenuTitle
   if subMenuTitle is empty then return false
   --
   -- mArray_SetActiveTitle subMenuTitle
   put _GetNewMenuController (tObject, subMenuTitle, mController) into newMenuController
   put menu_CommandToText (hName) into mLabel
   _AddSubmenu mArray, hName, mLabel, subMenuTitle, tObject, newMenuController, recursionArray
   --
   return true
end _SubmenuBit

private function _GetNewMenuController tObject, mTitle, mController
   -- logic: global, controller (overkill logic)
   
   switch
      case word 1 of mTitle is "Global"
         -- prioritize global Menu
         put menu_GetGlobalController (mTitle) into gMenuController
         
         # Simple Recursion check hack
         if _SimpleRecursionCheck (mController, mTitle) is true then
            -- Not sure what is going on with recursion checking in general
            return empty
         end if
         
         if exists (gMenuController) is true then
            return gMenuController
         else
            return empty
         end if
         break
      case exists (mController)
         -- next the controller
         put the menu_Controller [tObject] of mController into newMenuController -- overkill logic?
         if newMenuController is empty then
            return mController
         else
            -- overriden with a getprop in the controller
            return newMenuController
         end if
         break
      default
         -- mController does not exist and it's not global
         display_DebugHistory
         breakpoint
         return empty
   end switch
end _GetNewMenuController

private function _SimpleRecursionCheck mController, mTitle
   put mArray_GetActiveControllerArray() into mControllerArray
   put mControllerArray [mController] into testArray
   return testArray is an array
end _SimpleRecursionCheck

private function _RecursionCheck @recursionArray, tObject, mController, mTitle
   put recursionArray [mController][mTitle] into testObject
   if testObject is not empty then
      -- already indexed. Don't allow a menu to be there twice.
      return false
   else
      put tObject into recursionArray [mController][mTitle]
      return true
   end if
end _RecursionCheck

private function _GetTopController mTitle, tObject
   put menu_GetGlobalController (mTitle) into gMenuController
   if exists (gMenuController) is true then return gMenuController
   
   -- check the local context (assumes global default can return empty)
   put the menu_Controller [mTitle] of tObject into mController
   if exists (mController) is true then return mController
   
   return tObject
end _GetTopController

command menu_DispatchTextPick mItem, pMenuArray
   if pMenuArray is not an array then
      put mArray_GetActiveArray() into pMenuArray
   end if
   --
   mArray_SetActiveItem mItem
   _FindActiveHkey pMenuArray, mItem, hKey, paramValue   
   mArray_DoHkey hKey, paramValue
   --
   return hKey
end menu_DispatchTextPick

private command _FindActiveHkey mArray, mItemPath, @hkey, @paramValue
   -- was "mArray_FindActiveItem"
   -- only used by "menu_DispatchTextPick"
   -- need to check if mItemPath is now just mItem?
   
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
end _FindActiveHkey

command mArray_DoHkey hKey, pValue
   -- changed "dispatch" to "call" which keeps the context of the target
   mArray_UnMarshal hKey
   hkeyLine_Deconstruct hKey, hName, hType, mController
   
   put menu_GetTopTargetObject() into tObject
   put mArray_FindMenuTarget (mController, tObject) into mTarget
   --
   hKey_Do hKey, mTarget, pValue
   return the result
end mArray_DoHkey


--> Menu | Introspection
-
private function _FastMenuHandlers mController
   local hNames
   /*
   Assumes only one menu and all named "menu_"
   */
   
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
         case hName ends with "_"
            ## Divider is a command ending with "_"
            put "_" & CR after hNames
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
end _FastMenuHandlers

private command _AddScriptMenu @mArray, mTitle, tObject, mController, @recursionArray
   -- this is the one place where menu drawing happens that dispatches a message
   -- it contains the core logic and messaging order
   -- messaging logic: menu_Target, menu_CheckTarget, menu_Init
   
   -- guess controller
   put _GetNewMenuController (tObject, mTitle, mController) into newMenuController
   
   -- some checks and logging
   switch
      case exists (newMenuController) is false
      case _RecursionCheck (recursionArray, tObject, newMenuController, mTitle) is false
      case _MenuLogActivated (newMenuController, tObject, mTitle) is true
         return false
      default
         -- checks passed
   end switch
   
   ## Set menu_Target
   put mArray_FindMenuTarget (newMenuController, tObject) into mTarget
   put the menu_CheckTarget [mTarget] of newMenuController into targetOK
   if targetOk is false then return false
   
   ## Get Handlers slow or fast
   put _FastMenuHandlers (newMenuController) into scriptHandlers
   
   repeat for each line hName in scriptHandlers       
      if hName ends with "_" then
         _AddDivider mArray
         next repeat
      end if
      
      put mArray_GetDisabled (hName, newMenuController, mTarget) into isDisabled
      switch
         -- case isDisabled = true -- we can delete it as right now there is no graying out
         case isDisabled = "delete"
            next repeat
         case hName begins with "submenu_"
            _SubmenuBit mArray, hName, newMenuController, tObject, recursionArray, mTarget
            _SetDisabled mArray, isDisabled
            break
         case hName begins with "insert_"
            _InsertBit mArray, hName, newMenuController, tObject, mTarget, recursionArray
            _SetDisabled mArray, isDisabled
            break
         default
            _AddMenuItem mArray, hName, newMenuController, mTarget
            _SetDisabled mArray, isDisabled
      end switch
   end repeat
   return true
end _AddScriptMenu


--> Menu | Original
-
command menu_PopUp pMenuTitle, pLocation, pTargetObject
   if pTargetObject is empty then put the long id of the target into pTargetObject
   if pMenuTitle is empty then put the menu_Title of pTargetObject into pMenuTitle
   if pMenuTitle is empty then put "Menu" into pMenuTitle
   
   put the menu_Button of pTargetObject into mButton
   mArray_PopUp pMenuTitle, mButton, pTargetObject
end menu_PopUp

command menu_PullDown pMenuTitle, pLocation, pTargetObject
   if pTargetObject is empty then put the long id of the target into pTargetObject
   if pMenuTitle is empty then put the menu_Title of pTargetObject into pMenuTitle
   if pMenuTitle is empty then put "Menu" into pMenuTitle
   
   put the menu_Button of pTargetObject into mButton
   mArray_PullDown pMenuTitle, mButton, pTargetObject
   return the result
end menu_PullDown


--> Menu | Dispatch | Working on
-
on menu_Dispatch mItem
   -- "menu_Dispatch mItem" placed in the mButton target
   mArray_SetActiveItem mItem
   put the long id of the target into tObject
   switch word 1 of tObject
      case "widget"
         breakpoint
         break
      default
         menu_DispatchTextPick mItem
   end switch
end menu_Dispatch

command hKey_Do hKey, pTarget, pValue, pQuestion
   if the optionKey is "Down" then
      put scriptEditor_GetTop() into stackObject
      if pQuestion is empty then
         put "Edit script for this handler?" into pQuestion
      end if
      lcw_Answer pQuestion, stackObject
      --
      hkey_Edit hKey
      return empty
   end if
   
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   handler_Do hName, hObject, pTarget, pValue
   return the result
end hKey_Do

command handler_Do hName, hObject, pTarget, pValue
   if exists (hObject) is false then
      put the params
      display_DebugHistory hName
      return "Error, hObject does not exists."
   end if
   
   put hName && "pTarget,pValue" into callCommand
   call callCommand of hObject
   return the result
end handler_Do


--> mArray | Mouse
-
command mArray_MouseDown mTitle, pMenuButton, pTargetObject
   if pTargetObject is empty then
      put the long id of the target into pTargetObject
   end if
   if pMenuButton is empty then
      -- defaults to the target rather than the global menu_Button
      put pTargetObject into pMenuButton
   end if
   --
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject pTargetObject
   --
   switch word 1 of pMenuButton
      case "button"
         put mArray_FromTitleTable (mTitle, pTargetObject) into mArray -- dispatches "menu_Init"
         put mArray_ToText (mArray) into mText
         --
         set the text of pMenuButton to mText
         --
         -- mArray_SetActive mArray, mText, mTitle
         return mArray
      case "widget"
         break
      default
         exit to top
   end switch
end mArray_MouseDown

command mArray_PullDown mTitle, pMenuButton, pTargetObject
   _SetMenuObjectDefaults pTargetObject, pMenuButton
   --
   mArray_MouseDown mTitle, pMenuButton, pTargetObject
   put the result into mArray
   --
   put the bottomleft of pTargetObject into popLoc
   add 3 to item 2 of popLoc
   --
   popup pMenuButton at popLoc
   return mArray
end mArray_PullDown

command mArray_PopUp mTitle, pMenuButton, pTargetObject
   _SetMenuObjectDefaults pTargetObject, pMenuButton
   --
   mArray_MouseDown mTitle, pMenuButton, pTargetObject
   put the result into mArray
   --
   popup pMenuButton -- target changes
   return mArray
end mArray_PopUp


--> mArray | Checked
-
function mArray_GetChecked theParams, mTitle
   put mArray_GetActiveMenuController (mTitle) into mController
   put mArray_GetParams() into pArray
   --
   put word 1 of theParams into hName
   put item 2 of theParams into pValue
   delete char 1 of pValue
   delete char -1 of pValue
   --
   put pArray [mController][hName]["mCheckParams"] = pValue into isChecked
   return isChecked
end mArray_GetChecked

function menu_GetChecked theParams
   -- this only works for first level menus
   -- need to do a recusive search fo submenus to match hKey
   
   _DeconstructHandlerParams theParams, hNameToFind, mTarget, hParamValue
   
   put mArray_GetActiveArray() into mArray
   put keys (mArray) into indexNums
   sort numeric indexNums
   repeat for each line indexNum in indexNums
      put mArray [indexNum] into itemArray
      put itemArray ["name"] into hKeyLine
      
      put itemArray ["menu"] into subMenuArray
      if subMenuArray is an array then
         -- here we need to recurse
         -- breakpoint
      end if
      
      hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
      --
      if hName = hNameToFind then
         put itemArray ["menu"] into subMenuArray
         repeat for each key itemNum in subMenuArray
            put subMenuArray [itemNum]["label"] into foundParamValue
            if hParamValue = foundParamValue then
               put subMenuArray [itemNum]["checked"] into someBoolean
               return someBoolean
            end if
         end repeat
      end if
   end repeat
   return false
end menu_GetChecked

function mArray_GetParams
   return LocalArray ["Params"]
end mArray_GetParams

--> Faulty Deps | mArray | Bits
-
function mArray_ConstructHkey hName, mController
   put hkey_Construct (hName, "M", mController) into hkeyController
   mArray_Marshal hkeyController
   return hkeyController
end mArray_ConstructHkey

function hkey_Construct hName, hType, tObject
   if exists (tObject) is false then
      put "Missing" into hObject
   end if
   replace "C" with "M" in hType
   put hKeyLine_Construct (hName, hType, tObject) into hKeyLine
   return hKeyLine
end hkey_Construct

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject


--> Private
-
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

private command _SetMenuObjectDefaults @tObject, @mButton
   if exists (tObject) is false then
      put the long id of the target into tObject
   end if
   if exists (mButton) is false then
      -- defaults to the target rather than the global menu_Button
      put the long id of the target into mButton
   end if
end _SetMenuObjectDefaults


--> Related | Props
-
getprop script_MenuHandlers [mTitle]
   put the long id of the target into mController
   put _FastMenuHandlers (mController) into hNames
   return hNames
end script_MenuHandlers

getprop script_MenuArray [mTitleTable]
   put the long id of the target into tObject
   put mArray_FromTitleTable (mTitleTable, tObject) into mArray -- dispatches "menu_Init"
   return mArray
end script_MenuArray

getprop mArray_Controller [mTitle]
   -- useful for testing?
   put the long id of the target into tObject
   put the menu_Controller of tObject into mController
   put _GetNewMenuController (tObject, mTitle, mController) into mController
   return mController
end mArray_Controller


--> Menu | Props
-
getprop menu_Button
   put menu_GetGlobalButton() into mButton
   return mButton
end menu_Button

getprop menu_Handlers
   put the long id of the target into mController
   put _FastMenuHandlers (mController) into hNames
   return hNames
end menu_Handlers


--> Menu | Utils
-
function menu_GetGlobalButton
   -- a button that is always available to the LCW environment
   put the long id of btn 1 of cd 1 of stack "View|Index|Simple" into mButton
   return mButton
end menu_GetGlobalButton

function menu_ConstructItemText mTitle
   set the itemdelimiter to "|"
   delete item - 1 of mTitle
   if word 1 to -1 of item 1 of mTitle = "Global" then delete item 1 of mTitle
   
   replace " | " with " " in mTitle
   return word 1 to -1 of mTitle
end menu_ConstructItemText

function menu_StripGlobal gMenuTitle
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of gMenuTitle = "Global" then
      delete item 1 of gMenuTitle
   end if
   put word 1 to -1 of gMenuTitle into pageTitle 
   return pageTitle
end menu_StripGlobal

function menu_ToggleChecked theParams
   put not (menu_GetChecked (theParams)) into toggleBoolean
   return toggleBoolean
end menu_ToggleChecked


--> Menu | TargetObject
-
function menu_GetTarget mTitle
   put LocalArray ["menuTarget"][mTitle] into menuTarget
   return menuTarget
end menu_GetTarget

command menu_SetTarget mTitle, mTarget
   put mTarget into LocalArray ["menuTarget"][mTitle]
end menu_SetTarget

function menu_GetTopTargetObject
   return LocalArray ["active_TopTargetObject"]
end menu_GetTopTargetObject

command menu_SetTopTargetObject tObject
   put tObject into LocalArray ["active_TopTargetObject"]
end menu_SetTopTargetObject


--> mArray | Find
-
command mArray_Marshal @hkeyController
   replace "|" with "\" in hkeyController
end mArray_Marshal

command mArray_UnMarshal @hkeyController
   replace "\" with "|" in hkeyController
end mArray_UnMarshal

function menu_GetCaseParams theParams, pController
   if pController is empty then put debug_CallingObject() into pController
   --
   put word 1 of theParams into hName
   set the itemdelimiter to "_"
   delete item 2 of hName
   put toUpper (Char 1 of hName) into char 1 of hName
   put "M" && "menu_" & hName into shortHkey
   put the hkey_CaseConditions [shortHkey] of pController into cMenuParams
   return cMenuParams
end menu_GetCaseParams


--> mArray | Dispatch
-
/*
These handlers all take the form of "controller messaging".

In the receiving hName handler "the target" is changed to = mController, which is useless as it is where the handler is.
This is because we use "dispatch". If we use call we may get around this and try to preserve the target?
*/
command mArray_Do mCommand, mTitle, pMenuTarget, pValue
   -- only search in active mArray
   put mArray_GetActiveMenuController (mTitle) into mController
   --
   if exists (mController) is false then return false
   if pMenuTarget is empty then
      put the long id of the target into tObject
      put mArray_FindMenuTarget (mController, tObject) into pMenuTarget
   end if
   --
   handler_Do mCommand, mController, pMenuTarget, pValue
   return the result
end mArray_Do


--> mArray | Active | Set
-
command  mArray_SetActiveItem mItem
   put mItem into LocalArray ["active_MenuItemPath"]
end mArray_SetActiveItem

command mArray_SetActiveArray mArray
   put mArray into LocalArray ["active_MenuArray"]
end mArray_SetActiveArray

command mArray_SetTopTitle mTitle
   put mTitle into LocalArray ["active_TopMenuTitle"]
end mArray_SetTopTitle

-- command mArray_SetActive mArray, mText, mTitle
put mArray into LocalArray ["active_MenuArray"]
put mTitle into LocalArray ["active_TopMenuTitle"]
end mArray_SetActive


--> mArray | Active
-
function mArray_GetTopTitle
   return LocalArray ["active_TopMenuTitle"]
end mArray_GetTopTitle

function mArray_GetTopController
   put mArray_GetTopTitle() into mTitle
   put mArray_GetActiveMenuController (mTitle) into mController
   return mTitle
end mArray_GetTopController

function mArray_GetActiveArray
   return LocalArray ["active_MenuArray"]
end mArray_GetActiveArray

function mArray_GetActiveItem
   return LocalArray ["active_MenuItemPath"]
end mArray_GetActiveItem

function mArray_ActiveControllerExists mTitle
   put mArray_GetActiveMenuController (mTitle) into mController
   return exists (mController)
end mArray_ActiveControllerExists

function mArray_GetActiveControllerArray
   put LocalArray ["MenuControllerInit"] into mControllerArray
   return mControllerArray
end mArray_GetActiveControllerArray

function mArray_GetActiveMenuController mTitle
   put mArray_GetActiveControllerArray() into mControllerArray
   repeat for each key mController in mControllerArray
      put mControllerArray [mController]["mTitle"] into testMTitle
      if testMTitle = mTitle then
         return mController
      end if
   end repeat
   return empty
end mArray_GetActiveMenuController


--> mArray | TitleTable
-
function mArray_FromTitleTable mTitleTable, tObject
   local mArray, recursionArray
   --
   replace comma with tab in mTitleTable
   set the itemdelimiter to tab
   repeat for each line mTitleLine in mTitleTable
      -- tables are not often used
      put item 1 of mTitleLine into mTitle
      
      put item 2 of mTitleLine into mType
      if mTitle = "-" then
         _AddDivider mArray
         next repeat
      end if
      
      put _GetTopController (mTitle, tObject) into topMenuController
      if exists (topMenuController) is false then next repeat
      
      mArray_SetTopTitle mTitle
      -- mArray_SetActiveTitle mTitle
      dispatch "menu_Init" to topMenuController with tObject -- top only
      
      -- insert has not been done for tables yet
      switch mType
         case "insert"
            breakpoint
            break
         case "submenu"
            try
               put item 3 of mTitleLine into prettyTitle
               if prettyTitle is empty then
                  put menu_ConstructItemText (mTitle) into prettyTitle
               end if
               _AddSubmenu mArray, prettyTitle, prettyTitle, mTitle, tObject, topMenuController, recursionArray
               put the result into goodMenu
            catch e
               -- next repeat
               put false into goodMenu
            end try
            break
         default
            _AddScriptMenu mArray, mTitle, tObject, topMenuController, recursionArray
            put the result into goodMenu
      end switch
      
      if goodMenu is false then
         get _MenuCheckFailed (mTitle, mType, tObject, topMenuController, mTitleTable, mArray)
         put menu_GetGlobalController ("Global | Menu | Error | Menu") into mController
         _AddMenuItem mArray, "display_Error", mController, tObject
         -- exit repeat -- ideally we add and loop
      end if
   end repeat
   --
   mArray_SetActiveArray mArray
   --
   return mArray
end mArray_FromTitleTable

private function _MenuLogActivated newMenuController, tObject, mTitle
   -- checks for double menus in an object
   -- and logs menus that have been activated
   
   put LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] is true into mInitialised
   if mInitialised is not true then      
      put mInitialised into LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] -- check recursion
      
      -- for debugging
      put mTitle into LocalArray ["MenuControllerInit"][newMenuController]["mTitle"] -- to find mController from mTitle
      put tObject into LocalArray ["MenuControllerInit"][newMenuController]["tObject"]
   end if
   return mInitialised
end _MenuLogActivated

private command _AddSubmenu @mArray, mName, mLabel, mTitle, tObject, mController, @recursionArray
   put mArray_FromScript (mTitle, tObject, mController, recursionArray) into subMenuArray
   if subMenuArray is not an array then
      return false
   end if
   --
   put _NextIndexNum (mArray) into indexNum
   --
   put subMenuArray into mArray [indexNum]["menu"]
   put mName into mArray [indexNum]["name"]
   put mLabel into mArray [indexNum]["label"]
   return true
end _AddSubmenu

private command _AddMenu @mArray, mTitle, mController, tObject, mTarget, @recursionArray
   put mArray_FromScript (mTitle, tObject, mController, recursionArray) into addMenuArray
   if addMenuArray is not an array then return false
   --
   put keys (addMenuArray) into insertNum
   sort numeric insertNum
   repeat for each line insertNum in insertNum
      put _NextIndexNum (mArray) into indexNum
      put addMenuArray [insertNum] into mArray [indexNum]
   end repeat
   return true
end _AddMenu


--> mArray
-
function mArray_ListHandlerNames mArray, pNoDividers
   -- not recursive (skips submenus)
   put keys (mArray) into indexNums
   sort numeric indexNums
   repeat for each line indexNum in indexNums
      put mArray [indexNum] into itemArray
      put itemArray ["name"] into hKey
      switch
         case itemArray ["menu"] is an array
            next repeat
         case hKey = "-"
            if pNoDividers is true then next repeat
            put "-" & CR after hNames
            break
         default
            -- hkey_Deconstruct hKey, hName, hType, hObject, hNum
            hkeyLine_Deconstruct hKey, hName, hType, hObject
            --
            put hName & CR after hNames
      end switch
   end repeat
   delete char -1 of hNames
   return hNames
end mArray_ListHandlerNames

function mArray_ToText mArray
   local mText
   put empty into someIndent
   mArray_TextRecurse mText, someIndent, mArray
   delete char -1 of mText
   return mText
end mArray_ToText


--> Private
-
private command _DeconstructHandlerParams theParams, @hName, @firstParam, @secondParam
   get item 1 of theParams
   put word 1 of it into hName
   put char 2 to -2 of word 2 to -1 of it into firstParam
   put char 2 to -2 of word 1 of item 2 of theParams into secondParam
end _DeconstructHandlerParams

private command _InsertBit @mArray, hName, mController, tObject, mTarget, @recursionArray
   dispatch hName to mController with mTarget
   put the result into insertMenuTitle
   --
   switch
      case insertMenuTitle is empty
         return false
      case menu_IsGlobal (insertMenuTitle)
         put _GetNewMenuController (tObject, insertMenuTitle, mController) into insertController
         break
      default
         -- assume it is a non-global menu in the same mController
         put mController into insertController
   end switch
   --
   -- mArray_SetActiveTitle insertMenuTitle
   --
   _AddMenu mArray, insertMenuTitle, insertController, tObject, mTarget, recursionArray
   return the result
end _InsertBit


--> Private | Next
-
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

private command _AddDivider @mArray
   put _NextIndexNum (mArray) into indexNum
   put "-" into mArray [indexNum]["name"]
   put "-" into mArray [indexNum]["label"]
   put false into mArray [indexNum]["checked"]
   return indexNum
end _AddDivider

private command number_PadLeft @someNum, padNum
   put "%0" & padNum & "d" into fString
   put format (fString, someNum) into someNum
end number_PadLeft


--> Deps
-
function text_SplitCaps someWord
   -- was "capsSplit"
   put 1 into charNum
   repeat the number of chars of someWord
      put char charNum of someWord into someChar
      if text_StartsWithCaps(someChar) is true then
         put space before char charNum of someWord
         add 2 to charNum
      else
         add 1 to charNum
      end if
   end repeat
   put text_InitialCaps(word 1 of someWord) into word 1 of someWord
   return word 1 to -1 of someWord
end text_SplitCaps

function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower (word wordNum of someText) into someWord
      put toupper (char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps

function text_StartsWithCaps someText
   put char 1 of sometext into testChar
   put chartonum (testChar) into someCharNum
   if someCharNum >= 97 and someCharNum <= 122 then
      return false
   else
      return true
   end if
end text_StartsWithCaps

# Parameters
#   pObject : either a long id or a valid reference to an object.
# Returns
#   The "rugged" id of the object. This can be used the same as a long id,
#   but is slightly more resistant to stuff like objects being grouped, renamed etc.
#   The script editor uses rugged ids to store object ids when there is a chance that the object
#   could be renamed or grouped etc. 
function revRuggedId pObject
   # First get the long id of our object. If pObject is a valid object reference we just get the 
   # object's long id. If its not a valid reference, this does not always mean the object doesn't
   # exist (because of edit group mode), in this case we assume that pObject is the long id of the object
   # we want, and parse it directly to obtain the rugged id, without needing to refer to the actual
   # object at all.
   local tObject
   if there is a pObject then
      put the long id of pObject into tObject
   else
      put pObject into tObject
      # MDW-2015-08-21: [[ bugfix_revRuggedId ]] pObject is empty when creating a new object
      if tObject is empty then
         put the long id of the target into tObject
      end if
   end if
   
   # Find out what the name of the stack owning the object is. We are only interested in the 
   # stack that immediately owns the object, which could be a substack. To find this we can
   # simply search from the front and find the first ocurrence of "of stack".
   local tSubStack, tMainstack
   local tStackFound
   local tWordNumber
   put 1 into tWordNumber
   repeat for each word tWord in tObject
      # The first match is always the substack, the second (and last) match is always the mainstack
      if tWord is "stack" then
         if tStackFound then
            put tMainStack into tSubStack
            put word (tWordNumber + 1) of tObject into tMainStack
            exit repeat
         else
            put word (tWordNumber + 1) of tObject into tMainStack
         end if
         put true into tStackFound
      end if
      add 1 to tWordNumber
   end repeat
   
   try
      local tStack
      if tSubStack is not empty then
         put "stack " & tSubStack & " of " & (the name of stack (char 2 to -2 of tMainStack)) into tStack
      else
         put (the name of stack (char 2 to -2 of tMainStack)) into tStack
      end if
   catch tError
      
   end try
   
   # MW-2008-09-08: [[ Bug 7142 ]] If the hcAddressing of the stack is true, then the long id
   #    is in a different form than this expects. Thus we temporarily fetch it while hcAddressing
   #    is false.
   if there is a tStack and the hcAddressing of tStack then
      set the hcAddressing of tStack to false
      put the long id of pObject into tObject
      set the hcAddressing of tStack to true
   end if
   
   local tType
   put word 1 of tObject into tType
   
   local tId
   if tType is "stack" then
      # With stacks, the name is the most robust way to refer to them. We assume that the stack exists...
      put tStack into tId
   else if tType is "audioclip" then
      put "audioclip id" && word 3 of tObject & " of " & tStack into tId
   else if tType is "videoclip" then
      put "videoclip id" && word 3 of tObject & " of " & tStack into tId
   else
      # With any other object, the safest thing is to return the object id and the name of its owning stack.
      # For cards we use "card id..." for other objects "control id..". This is significant because when in
      # edit group mode, the group being edited can be referred to as "control id.." but *not* "group id..."
      
      local tPrefix
      if tType is "card" then
         put "card" into tPrefix
      else
         put "control" into tPrefix
      end if
      put tPrefix & " id " & word 3 of tObject & " of " & tStack into tId
   end if
   
   return tId
end revRuggedId
