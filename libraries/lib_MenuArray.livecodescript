script "lib_MenuArray"
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
end exportToUrl--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_MenuArray
type: library

/*
This library is for the set of handlers that deal with new menu array format used by widgets.

In order to account for menus that are directed at targets that are not related to the objects clicked on we must use a local or global variable
*/

--> Variables
-
local LocalArray


--> Working on
-
private command _ClearActiveMenuArray
   delete variable LocalArray
   -- delete variable LocalArray ["MenuControllerInit"]
end _ClearActiveMenuArray

private function _SlowMenuHandlers mController, mTitle
   put the script of mController into someScript
   --
   put script_GetSuite (mTitle, someScript) into hLines
   filter hLines with "on *"
   repeat for each line scriptLine in hLines
      put word 2 of scriptLine into hName
      put hName & CR after hNames
   end repeat
   delete char -1 of hNames
   return hNames
end _SlowMenuHandlers

private function _FastMenuHandlers mController
   -- assumes only one menu and all named "menu_"
   put the revAvailableHandlers of mController into hTable
   
   sort numeric hTable by word 3 of each
   -- filter hTable with "M menu_*"
   repeat for each line hLine in hTable
      switch
         case word 1 of hLine is no "M"
         case word 1 to 2 of hLine = "M submenu_Dev"
         case word 2 of hLine = "menu_Init"
            break
         case word 1 to 2 of hLine = "M _" -- a divider
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
   
   -- menu_Target
   put mArray_FindMenuTarget (newMenuController, tObject) into mTarget
   --
   -- menu_CheckTarget
   put the menu_CheckTarget [mTarget] of newMenuController into targetOK
   if targetOk is false then return false
   
   -- put the script_MenuHandlers [mTitle] of newMenuController into scriptHandlers
   if the menu_IsSimple of newMenuController then
      -- only one menu defned in the script
      put _FastMenuHandlers (newMenuController) into scriptHandlers
   else
      put _SlowMenuHandlers (newMenuController, mTitle) into scriptHandlers
   end if
   --
   repeat for each line hName in scriptHandlers       
      if hName = "_" then
         _AddDivider mArray
         next repeat
      end if
      
      put mArray_GetDisabled (hName, newMenuController, mTarget) into isDisabled
      switch
         case isDisabled = true -- we can delete it as right now there is no graying out
         case isDisabled = "delete"
            next repeat
         case hName begins with "submenu_"
            _SubmenuBit mArray, hName, newMenuController, tObject, recursionArray
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

private command _FindActiveItem mItemPath, @hkeyController, @paramValue
   put mArray_GetActiveArray() into mArray
   --
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
         put itemArray ["name"] into hkeyController
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
      put itemName into hkeyController
      put subItemPath into paramValue -- should be empty unless parramm contains "|"
   end if
end _FindActiveItem

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


--> Menu | Dispatch | Working on
-
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
   put hName && "pTarget,pValue" into callCommand
   --
   call callCommand of hObject
   return the result
end handler_Do

on menu_Dispatch mItem
   -- "menu_Dispatch mItem" placed in the mButton target
   mArray_SetActiveItem mItem
   put the long id of the target into tObject
   switch word 1 of tObject
      case "widget"
         menu_DispatchPick mItem
         break
      default
         menu_DispatchTextPick mItem
   end switch
end menu_Dispatch

command menu_DispatchTextPick mItem
   mArray_SetActiveItem mItem
   _FindActiveItem mItem, hkeyController, paramValue   
   mArray_DoController hkeyController, paramValue
   return the result
end menu_DispatchTextPick

command menu_DispatchPick mItem
   local paramValue
   
   mArray_SetActiveItem mItem
   set the itemdelimiter to "|"
   put item -1 of mItem into hkeyController
   if word 1 of hkeyController = "param" then
      put word 2 to -1 of hkeyController into paramValue
      put item -2 of mItem into hkeyController 
   end if
   mArray_DoController hkeyController, paramValue
   return the result
end menu_DispatchPick


--> Related | Props
-
getprop script_MenuHandlers [mTitle]
   put the long id of the target into mController
   switch
      case mTitle is empty
      case the menu_IsSimple of mController is true
         put _FastMenuHandlers (mController) into hNames
         break
      default
         put _SlowMenuHandlers (mController, mTitle) into hNames
   end switch
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

getprop menu_IsSimple
   return menu_GetSimple()
end menu_IsSimple

getprop menu_Handlers [pFast]
   put the long id of the target into mController
   switch pFast
      case empty
      case true
         put _FastMenuHandlers (mController) into hNames -- latest fastest
         break
      case false
         put line 1 of the script_MenuTitles of mController into mTitle
         put _SlowMenuHandlers (mController, mTitle) into hNames
         break
      default
         put pFast into mTitle
         put the script_MenuArray [mTitle] of mController into scriptMenuArray -- the way mArray works
         -- put _GetMenuHandlers (mTitle, mController) into hNames -- old and thorough
         put _SlowMenuHandlers (mController, mTitle) into hNames
   end switch
   return hNames
end menu_Handlers


--> Menu | Utils
-
function menu_GetGlobalButton
   -- a button that is always available to the LCW environment
   put the long id of btn 1 of cd 1 of stack "View|Index|Simple" into mButton
   return mButton
end menu_GetGlobalButton

function menu_IsGlobal mTitle
   -- could do better check
   return word 1 of mTitle = "Global"
end menu_IsGlobal

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
   -- global gLCW
   -- put gLCW ["activeMenuArray"]["top"]["targetObject"] into targetObject
end menu_GetTopTargetObject

command menu_SetTopTargetObject tObject
   put tObject into LocalArray ["active_TopTargetObject"]
   -- global gLCW
   -- put targetObject into gLCW ["activeMenuArray"]["top"]["targetObject"]
end menu_SetTopTargetObject


--> Menu | Simple
-
function menu_GetSimple
   -- a guess at the default property for a menu
   -- as simple menu can only have one divider
   -- we assume that if it does not have a "M submenu_Dev" handler it is simple
   
   if the shiftKey is "Down" then return false
   put mArray_GetSimple() into isSimple
   if isSimple is not empty then return isSimple
   --
   put the script_HandlerExists ["M submenu_Dev"] of the target into devExists
   if devExists then
      return false
   else
      return true
   end if
end menu_GetSimple

function mArray_GetSimple
   global gLCW
   return gLCW ["menu_IsSimple"] is not false
end mArray_GetSimple

command mArray_SetSimple sBoolean
   global gLCW
   put sBoolean is not false into gLCW ["menu_IsSimple"]
end mArray_SetSimple


--> mArray | Find
-
command mArray_Marshal @hkeyController
   replace "|" with "\" in hkeyController
end mArray_Marshal

command mArray_UnMarshal @hkeyController
   replace "\" with "|" in hkeyController
end mArray_UnMarshal

function menu_GetCaseParams theParams, pController
   if pController is empty then put debug_GetCallingObject(2) into pController
   --
   put word 1 of theParams into hName
   set the itemdelimiter to "_"
   delete item 2 of hName
   put toUpper (Char 1 of hName) into char 1 of hName
   put "M" && "menu_" & hName into shortHkey
   put the hkey_CaseConditions [shortHkey] of pController into cMenuParams
   return cMenuParams
end menu_GetCaseParams


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
   _ClearActiveMenuArray
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


--> mArray | Dispatch
-
/*
These handlers all take the form of "controller messaging".

In the receiving hName handler "the target" is changed to = mController, which is useless as it is where the handler is.
This is because we use "dispatch". If we use call we may get around this and try to preserve the target?
*/
command mArray_DoController mKey, pValue
   -- changed "dispatch" to "call" which keeps the context of the target
   
   -- put the long id of the target into tObject
   put menu_GetTopTargetObject() into tObject
   --
   mArray_UnMarshal mKey
   hkey_Deconstruct mKey, hName, hType, mController, hNum
   --
   put mArray_FindMenuTarget (mController, tObject) into mTarget
   --
   hKey_Do mKey, mTarget, pValue
   return the result
end mArray_DoController

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


--> mArray
-
function mArray_FindMenuTarget mController, tObject
   -- logic: controller, target
   -- called for every nested menu - but not menu items (I think)
   -- could optimise by only calling the menu_Target when not already done
   
   if exists (mController) is true then
      put the menu_Target [tObject] of mController into mTarget
      if mTarget is not empty then return mTarget
   end if
   
   put the menu_Target of tObject into mTarget
   if mTarget is not empty then
      return mTarget
   else
      return tObject
   end if
end mArray_FindMenuTarget


--> mArray | Active | Set
-
function mArray_GetActiveTitle
   return LocalArray ["active_MenuTitle"]
end mArray_GetActiveTitle

command  mArray_SetActiveTitle mItem
   put mItem into LocalArray ["active_MenuTitle"]
end mArray_SetActiveTitle

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

function mArray_GetActiveMenuController mTitle
   put LocalArray ["MenuControllerInit"] into mControllerArray
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
      mArray_SetActiveTitle mTitle
      dispatch "menu_Init" to topMenuController with tObject
      
      -- insert has not been done for tables yet
      switch mType
         case "insert"
            breakpoint
            break
         case "submenu"
            put menu_ConstructItemText (mTitle) into prettyTitle
            _AddSubmenu mArray, prettyTitle, prettyTitle, mTitle, tObject, topMenuController, recursionArray
            break
         default
            _AddScriptMenu mArray, mTitle, tObject, topMenuController, recursionArray
      end switch
   end repeat
   --
   mArray_SetActiveArray mArray
   --
   return mArray
end mArray_FromTitleTable

private function _GetTopController mTitle, tObject
   put menu_GetGlobalController (mTitle) into gMenuController
   if exists (gMenuController) is true then return gMenuController
   
   -- check the local context (assumes global default can return empty)
   put the menu_Controller [mTitle] of tObject into mController
   if exists (mController) is true then return mController
   
   return tObject
end _GetTopController

private function _GetNewMenuController tObject, mTitle, mController
   -- logic: global, controller (overkill logic)
   
   switch
      case word 1 of mTitle is "Global"
         -- prioritize global Menu
         put menu_GetGlobalController (mTitle) into gMenuController
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

private function _MenuLogActivated newMenuController, tObject, mTitle
   -- checks for double menus in an object
   -- and logs menus that have been activated
   
   put LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] is true into mInitialised
   if mInitialised is not true then      
      put someBoolean into LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] -- check recursion
      
      -- for debugging
      put mTitle into LocalArray ["MenuControllerInit"][newMenuController]["mTitle"] -- to find mController from mTitle
      put tObject into LocalArray ["MenuControllerInit"][newMenuController]["tObject"]
   end if
   return mInitialised
end _MenuLogActivated

private command _AddSubmenu @mArray, mName, mLabel, mTitle, tObject, mController, @recursionArray
   put mArray_FromScript (mTitle, tObject, mController, recursionArray) into subMenuArray
   if subMenuArray is not an array then return false
   --
   put _NextIndexNum (mArray) into indexNum
   --
   put subMenuArray into mArray [indexNum]["menu"]
   put mName into mArray [indexNum]["name"]
   put mLabel into mArray [indexNum]["label"]
   return true
end _AddSubmenu

function mArray_FromScript mTitle, tObject, mController, @recursionArray
   local mArray
   _AddScriptMenu mArray, mTitle, tObject, mController, recursionArray
   return mArray
end mArray_FromScript

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
            hkey_Deconstruct hKey, hName, hType, hObject, hNum
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

command mArray_TextRecurse @mText, someIndent, mArray, pController, pMenuTarget
   put keys (mArray) into indexNums
   sort numeric indexNums
   repeat for each line indexNum in indexNums
      -- repeat for each key indexNum in mArray
      put mArray [indexNum] into itemArray
      --
      put itemArray ["name"] into mController
      put itemArray ["label"] into itemText
      --
      if pController is empty then
         put itemArray ["checked"] into isChecked
         put itemArray ["disabled"] into isDisabled
      else
         -- check live (not sure if this is ever used?)
         -- put mArray_GetObjectCheckStatus (hName, pController, pMenuTarget) into isDisabled
         put mArray_GetDisabled (hName, pController, pMenuTarget) into isDisabled
      end if
      --
      if isDisabled is true then put "(" before itemText
      if isChecked is true then
         put "!c" before itemText
      else
         -- put "!n" before itemText
      end if
      put someIndent & itemText & CR after mText
      --
      put itemArray ["menu"] into subArray
      if subArray is an array then
         put tab & someIndent into nextIndent
         mArray_TextRecurse mText, nextIndent, subArray
      end if
   end repeat
end mArray_TextRecurse

function mArray_GetDisabled hName, mController, mTarget
   set the itemdelimiter to "_"
   put item 2 of hName into hText
   put "disabled_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into isDisabled
   return isDisabled
end mArray_GetDisabled

function mArray_GetCheckItem hName, mController, mTarget
   set the itemdelimiter to "_"
   put item 2 of hName into hText
   put "checked_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into someBoolean
   return someBoolean is true
end mArray_GetCheckItem

function mArray_GetParamValues propLabel, mController, mTarget
   put propLabel & "_Params" & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into paramValues
   return paramValues
end mArray_GetParamValues

function mArray_GetCheckParams propLabel, mController, mTarget
   put propLabel & "_Param" & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into checkParams
   return checkParams
end mArray_GetCheckParams


--> mArray | Bits
-
function mArray_ConstructHkey hName, mController
   put hkey_Construct (hName, "M", mController) into hkeyController
   mArray_Marshal hkeyController
   return hkeyController
end mArray_ConstructHkey


--> Private
-
private command _DeconstructHandlerParams theParams, @hName, @firstParam, @secondParam
   get item 1 of theParams
   put word 1 of it into hName
   put char 2 to -2 of word 2 to -1 of it into firstParam
   put char 2 to -2 of word 1 of item 2 of theParams into secondParam
end _DeconstructHandlerParams

private command _SubmenuBit @mArray, hName, mController, tObject, @recursionArray
   dispatch hName to mController
   put the result into subMenuTitle
   if subMenuTitle is empty then return false
   --
   mArray_SetActiveTitle subMenuTitle
   --
   put _GetNewMenuController (tObject, subMenuTitle, mController) into newMenuController
   --
   put menu_CommandToText (hName) into mLabel
   _AddSubmenu mArray, hName, mLabel, subMenuTitle, tObject, newMenuController, recursionArray
   --
   return true
end _SubmenuBit

private command _InsertBit @mArray, hName, mController, tObject, mTarget, @recursionArray
   dispatch hName to mController
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
   mArray_SetActiveTitle insertMenuTitle
   --
   _AddMenu mArray, insertMenuTitle, insertController, tObject, mTarget, recursionArray
   return the result
end _InsertBit


--> Private | Construct | MenuItem
-
private command _AddMenuItem @mArray, hName, mController, mTarget
   set the itemdelimiter to "_"
   put item 2 of hName into propLabel
   --
   put mArray_GetParamValues (propLabel, mController, mTarget) into paramValues
   --
   if paramValues is empty then
      put mArray_GetCheckItem (hName, mController, mTarget) into hNameIsChecked
      _SetPlainMenuItem mArray, hName, mController, hNameIsChecked
   else
      put mArray_GetCheckParams (propLabel, mController, mTarget) into checkParams
      --
      _SetParamMenuItem mArray, propLabel, hName, mController, paramValues, checkParams
   end if
   return true
end _AddMenuItem

private command _SetPlainMenuItem @mArray, hName, mController, hNameIsChecked   
   put _NextIndexNum (mArray) into indexNum
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put menu_CommandToText (hName) into mArray [indexNum]["label"]
   
   -- bizarre bug in Livecode widget being strict on boolean type an text type
   -- put true into mArray [indexNum]["disabled"] does not seem possible
   -- put itemChecked into mArray [indexNum]["checked"] -- does nto work!
   
   put item 2 of the extents of mArray into indexNum
   number_PadLeft indexNum, 2
   
   if hNameIsChecked is true then
      put true into mArray [indexNum]["checked"]
   else
      put false into mArray [indexNum]["checked"]
   end if
end _SetPlainMenuItem

private command _SetParamMenuItem @mArray, propLabel, hName, mController, paramValues, checkParams
   put _NextIndexNum (mArray) into indexNum
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
      -- crazy boolean bug
      if someBoolean is true then
         put true into subMenuArray [subIndexNum]["checked"]
      else
         put false into subMenuArray [subIndexNum]["checked"]
      end if
      --
      add 1 to subIndexNum
   end repeat
   
   put subMenuArray into mArray [indexNum]["menu"]
   --
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put text_SplitCaps (propLabel) into mArray [indexNum]["label"]
end _SetParamMenuItem

private command _SetDisabled @mArray, isDisabled
   if isDisabled is not empty then
      put item 2 of the extents of mArray into indexNum
      number_PadLeft indexNum, 2
      put isDisabled is true into mArray [indexNum]["disabled"]
   end if
end _SetDisabled


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


--> Private | Basic
-
command _AddDivider @mArray
   put _NextIndexNum (mArray) into indexNum
   put "-" into mArray [indexNum]["name"]
   put "-" into mArray [indexNum]["label"]
   put false into mArray [indexNum]["checked"]
   return indexNum
end _AddDivider
