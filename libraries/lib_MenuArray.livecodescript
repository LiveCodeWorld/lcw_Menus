script "lib_MenuArray"
--> MetaData
-
license: GPLv3
name: lib_MenuArray
type: library
version: 0.2

/*
This library is for the set of handlers that deal with new menu array format used by widgets.

In order to account for menus that are directed at targets that are not related to the objects clicked on we must use a local or global variable
*/

--> Variables
-
local LocalArray


--> Working on
-
/*
These handlers are being slowly ported from the older lib_Menu code
*/

command mArray_SetMenuController @mController, tObject, mTitle
   switch
      case word 1 of mTitle is "Global"
         put menu_GetGlobalController (mTitle) into gMenuController
         if exists (gMenuController) is true then
            put gMenuController into mController
         else
            display_DebugHistory mTitle
         end if
         break
      case exists (mController)
         -- we can override also with a getprop in the controller
         get the menu_Controller [tObject] of mController
         if it is not empty then
            put it into mController
         end if
         break
      default
         breakpoint
   end switch
end mArray_SetMenuController

function mArray_FindMenuTarget mController, tObject
   -- logic: controller, target
   -- called for every nested menu - but not menu items (I think)
   -- could optimise by only calling the menu_Target when not already done
   
   if exists (mController) is false then
      display_DebugHistory
   else
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

private command _SubmenuBit @mArray, hName, mController, tObject, @recursionArray
   dispatch hName to mController
   put the result into subMenuTitle
   if subMenuTitle is empty then return false
   --
   mArray_SetMenuController mController, tObject, subMenuTitle
   --
   put menu_CommandToText (hName) into mLabel
   --
   _AddSubmenu mArray, hName, mLabel, subMenuTitle, tObject, mController, recursionArray
   --
   return true
end _SubmenuBit

private command _InsertBit @mArray, hName, mController, tObject, mTarget, @recursionArray
   dispatch hName to mController
   put the result into insertMenuTitle
   switch
      case insertMenuTitle is empty
         return false
      case mTitle_IsGlobal (insertMenuTitle)
         mArray_SetMenuController mController, tObject, insertMenuTitle
         break
      default
         -- assume it is a non-global menu in the same mController
         put mController into insertController
   end switch
   
   _AddMenu mArray, insertMenuTitle, insertController, tObject, mTarget, recursionArray
   return the result
end _InsertBit


--> mArray | Active
-
function mArray_GetTopTitle
   return LocalArray ["active_TopMenuTitle"]
   
   /*
   put menu_GetSentPath() into mSentPath
   menu_DeconstructPath mSentPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   set the itemdelimiter to "/"
   put item -1 of mTitlePath into sentMenuTitle
   return sentMenuTitle
   */
end mArray_GetTopTitle

function mArray_GetTopController
   /*
   put menu_GetSentPath() into mPath
   menu_DeconstructPath mPath, foundPath, subMenuPath, pigeon, mController, mTitlePath, mItemType
   */
   
   put mArray_GetTopTitle() into mTitle
   put mArray_GetActiveMenuController (mTitle) into mController
   return mController
end mArray_GetTopController

function mArray_GetActiveText
   return LocalArray ["active_MenuText"]
end mArray_GetActiveText

function mArray_GetActiveTitle
   return LocalArray ["active_TopMenuTitle"]
end mArray_GetActiveTitle

function mArray_GetActiveArray
   return LocalArray ["active_MenuArray"]
end mArray_GetActiveArray

command mArray_SetActiveArray mArray
   put mArray into LocalArray ["active_MenuArray"]
end mArray_SetActiveArray

command mArray_SetActive mArray, mText, mTitle
   put mArray into LocalArray ["active_MenuArray"]
   put mText into LocalArray ["active_MenuText"]
   put mTitle into LocalArray ["active_TopMenuTitle"]
end mArray_SetActive

function menu_GetTargetObject
   put LocalArray ["active_menuTarget"] into tObject
   return tObject
end menu_GetTargetObject

command menu_SetTargetObject tObject
   put tObject into LocalArray ["active_menuTarget"]
end menu_SetTargetObject

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

private command mArray_FindActiveItem mItem, @hkeyController, @paramValue
   put mArray_GetActiveArray() into mArray
   --
   set the itemdelimiter to "|"
   repeat for each item itemText in mItem
      put keys (mArray) into indexNums
      sort numeric indexNums
      repeat for each line indexNum in indexNums
         put mArray [indexNum] into itemArray
         if itemArray ["label"] = itemText then
            get itemArray ["name"]
            --
            if word 1 of it is "param" then
               put word 2 to -1 of it into paramValue
            else
               put it into hkeyController
               put empty into paramValue
            end if
            exit repeat
         end if
      end repeat
      put itemArray ["menu"] into mArray
   end repeat
end mArray_FindActiveItem


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
   put menu_GetTargetObject() into tObject
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
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   handler_Do hName, hObject, pTarget, pValue
   return the result
end hKey_Do

command handler_Do hName, hObject, pTarget, pValue
   put hName && "pTarget,pValue" into callCommand
   --
   call callCommand of hObject
   return the result
end handler_Do

private command mArray_AddScriptMenu @mArray, mTitle, tObject, mController, @recursionArray
   -- this is the one place where menu drawing happens that dispatches a message
   -- consider changing dispatch to call?
   
   mArray_SetMenuController mController, tObject, mTitle
   put mArray_FindMenuTarget (mController, tObject) into mTarget
   --
   _RecursionCheck recursionArray, tObject, mController, mTitle
   if the result is false then return false
   
   if exists (mController) is false then
      display_DebugHistory mTitle
      return false
   end if
   
   /*
   put the menu_CheckTarget [mTarget] of mController into targetOK
   if targetOk is false then
      return false
   end if
   */
   
   put LocalArray ["MenuControllerInit"][mController]["mInitialised"] is true into mInitialised
   --
   if mInitialised is not true then
      -- this is the only place where messages are dispatched during menu drawing
      dispatch "menu_Init" to mController with tObject -- works also for submenu
      _SetMenuControllerInit mController, true, mTitle, tObject, mTarget
   end if
   --
   put the script_MenuHandlers [mTitle] of mController into scriptHandlers
   repeat for each line hName in scriptHandlers       
      if hName = "_" then
         _AddDivider mArray
         next repeat
      end if
      
      put mArray_GetDisabled (hName, mController, mTarget) into isDisabled
      switch isDisabled
         case "delete"
            next repeat
         case true -- we can delete it as right now there is no graying out
         case false
         default
            _SetMenuItem mArray, hName, mController, tObject, mTarget, recursionArray
            _SetDisabled mArray, isDisabled
      end switch
   end repeat
   return true
end mArray_AddScriptMenu


--> Working on
-
function mArray_FromTitleTable mTitleTable, tObject
   local mArray, recursionArray
   --
   replace comma with tab in mTitleTable
   set the itemdelimiter to tab
   repeat for each line mTitleLine in mTitleTable
      put item 1 of mTitleLine into mTitle
      put item 2 of mTitleLine into mType
      --
      if mTitle = "-" then
         _AddDivider mArray
         next repeat
      end if
      --
      put the mArray_FoundController [mTitle] of tObject into topMenuController
      if exists (topMenuController) is false then
         display_DebugHistory mTitle
         next repeat
      end if
      --
      switch mType
         case "insert"
            breakpoint
            break
         case "submenu"
            put mTitle_ConstructText (mTitle) into prettyTitle
            _AddSubmenu mArray, prettyTitle, prettyTitle, mTitle, tObject, topMenuController, recursionArray
            break
         default
            mArray_AddScriptMenu mArray, mTitle, tObject, topMenuController, recursionArray
      end switch
   end repeat
   return mArray
end mArray_FromTitleTable

getprop mArray_FoundController [mTitle]
   put the long id of the target into tObject
   --
   put menu_GetGlobalController (mTitle) into gMenuController
   if exists (gMenuController) is true then return gMenuController
   
   -- check the local context (assumes global default can return empty)
   put the menu_Controller [mTitle] of tObject into mController
   if exists (mController) is true then return mController
   
   -- use card as a default controller
   put the card_Object of tObject into cMenuController      
   return cMenuController
end mArray_FoundController

private command _RecursionCheck @recursionArray, tObject, mController, mTitle
   put recursionArray [mController][mTitle] into testObject
   if testObject is not empty then
      -- already indexed. Don't allow a menu to be there twice.
      return false
   else
      put tObject into recursionArray [mController][mTitle]
      return true
   end if
end _RecursionCheck

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
   mArray_AddScriptMenu mArray, mTitle, tObject, mController, recursionArray
   return mArray
end mArray_FromScript


--> Remove
-
private command _SetMenuControllerInit mController, someBoolean, mTitle, tObject, mTarget
   put someBoolean into LocalArray ["MenuControllerInit"][mController]["mInitialised"] -- check recursion
   put mTitle into LocalArray ["MenuControllerInit"][mController]["mTitle"] -- to find mController from mTitle
   
   -- needed?
   put tObject into LocalArray ["MenuControllerInit"][mController]["tObject"]
   put mTarget into LocalArray ["MenuControllerInit"][mController]["mTarget"]
end _SetMenuControllerInit


--> mArray | Props
-
getprop menu_Button
   put the long id of btn 1 of cd 1 of stack "View|Index|Simple" into mButton
   return mButton
end menu_Button

getprop menu_Style
   put LocalArray ["menu_Style"] into mStyle
   if mStyle is empty then return "array"
   return mStyle
end menu_Style

setprop menu_Style mStyle
   put mStyle into LocalArray ["menu_Style"]
end menu_Style

--> Script | MenuArray
-
getprop script_MenuArray [mTitleTable]
   put the long id of the target into tObject
   put mArray_FromTitleTable (mTitleTable, tObject) into mArray -- dispatches "menu_Init"
   return mArray
end script_MenuArray

getprop script_MenuHandlers [mTitle]
   put the long id of the target into mController
   --
   if mTitle is empty then
      -- faster (assumes only one menu and all named "menu_")
      put the revAvailableHandlers of mController into hTable
      -- filter hTable with "M menu_*"
      sort numeric hTable by word 3 of each
      repeat for each line hLine in hTable
         switch
            case hLine begins with "M menu_"
            case word 1 to 2 of hLine = "M _"
               put word 2 of hLine into hName
               put hName & CR after hNames
               break
            default
               -- not a menu
         end switch
      end repeat
   else
      -- slower
      put the script of mController into someScript
      put script_GetSuite (mTitle, someScript) into hLines
      filter hLines with "on *"
      repeat for each line scriptLine in hLines
         put word 2 of scriptLine into hName
         put hName & CR after hNames
      end repeat
   end if
   delete char -1 of hNames
   return hNames
end script_MenuHandlers

function menu_GetChecked theParams
   handler_DeconstructParams theParams, hNameToFind, mTarget, hParamValue
   
   put mArray_GetActiveArray() into mArray
   put keys (mArray) into indexNums
   sort numeric indexNums
   repeat for each line indexNum in indexNums
      put mArray [indexNum] into itemArray
      put itemArray ["name"] into hKeyLine
      hkeyLine_Deconstruct hKeyLine, hName, hType, hObject
      
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


--> Menu | Dispatch
-
on menu_Dispatch mItem
   -- "menu_Dispatch mItem" placed in the mButton target
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
   -- put the long id of the target into mButton
   -- put mButton into tObject
   mArray_FindActiveItem mItem, hkeyController, paramValue   
   mArray_DoController hkeyController, paramValue
   return the result
end menu_DispatchTextPick

command menu_DispatchPick mItem
   local paramValue
   set the itemdelimiter to "|"
   put item -1 of mItem into hkeyController
   if word 1 of hkeyController = "param" then
      put word 2 to -1 of hkeyController into paramValue
      put item -2 of mItem into hkeyController 
   end if
   mArray_DoController hkeyController, paramValue
   return the result
end menu_DispatchPick


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
   menu_SetTargetObject pTargetObject
   --
   switch word 1 of pMenuButton
      case "button"
         put mArray_FromTitleTable (mTitle, pTargetObject) into mArray -- dispatches "menu_Init"
         put mArray_ToText (mArray) into mText
         --
         set the text of pMenuButton to mText
         --
         mArray_SetActive mArray, mText, mTitle
         return mArray
      case "widget"
         break
      default
         exit to top
   end switch
end mArray_MouseDown

command mArray_PullDown mTitle, pMenuButton, pTargetObject
   if pMenuButton is empty then
      -- defaults to the target rather than the global menu_Button
      put the long id of the target into pMenuButton
   end if
   --
   mArray_MouseDown mTitle, pMenuButton, pTargetObject
   put the result into mArray
   --
   put the bottomleft of pMenuButton into popLoc
   add 3 to item 2 of popLoc
   --
   popup pMenuButton at popLoc
   return mArray
end mArray_PullDown

command mArray_PopUp mTitle, pMenuButton, pTargetObject
   if pMenuButton is empty then
      -- defaults to the target rather than the global menu_Button
      put the long id of the target into pMenuButton
   end if
   --
   mArray_MouseDown mTitle, pMenuButton, pTargetObject
   put the result into mArray
   --
   popup pMenuButton -- target changes
   return mArray
end mArray_PopUp   


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


--> mArray
-
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

command mArray_Marshal @hkeyController
   replace "|" with "\" in hkeyController
end mArray_Marshal

command mArray_UnMarshal @hkeyController
   replace "\" with "|" in hkeyController
end mArray_UnMarshal


--> Private
-
private command _ClearActiveMenuArray
   delete variable LocalArray ["MenuControllerInit"]
end _ClearActiveMenuArray

private command handler_DeconstructParams theParams, @hName, @firstParam, @secondParam
   get item 1 of theParams
   put word 1 of it into hName
   put char 2 to -2 of word 2 to -1 of it into firstParam
   put char 2 to -2 of word 1 of item 2 of theParams into secondParam
end handler_DeconstructParams


--> Private | Construct | MenuItem
-
private command _AddMenuItem @mArray, hName, mController, mTarget
   set the itemdelimiter to "_"
   put item 2 of hName into propLabel
   --
   put mArray_GetParamValues (propLabel, mController, mTarget) into paramValues
   put mArray_GetCheckParams (propLabel, mController, mTarget) into checkParams
   --
   if paramValues is empty then
      put checkParams into itemChecked
      mArray_SetPlainMenuItem mArray, hName, mController, checkParams
   else
      mArray_SetParamMenuItem mArray, propLabel, hName, mController, paramValues, checkParams
   end if
   return true
end _AddMenuItem

private command mArray_SetPlainMenuItem @mArray, hName, mController, itemChecked   
   put _NextIndexNum (mArray) into indexNum
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put menu_CommandToText (hName) into mArray [indexNum]["label"]
   
   -- bizarre bug in Livecode widget being strict on boolean type an text type
   -- put true into mArray [indexNum]["disabled"] does not seem possible
   -- put itemChecked into mArray [indexNum]["checked"] -- does nto work!
   
   put item 2 of the extents of mArray into indexNum
   number_PadLeft indexNum, 2
   
   if itemChecked is true then
      put true into mArray [indexNum]["checked"]
   else
      put false into mArray [indexNum]["checked"]
   end if
end mArray_SetPlainMenuItem

private command mArray_SetParamMenuItem @mArray, propLabel, hName, mController, paramValues, checkParams
   put _NextIndexNum (mArray) into indexNum
   replace comma with CR in paramValues
   replace comma with CR in checkParams
   set the wholematches to true
   
   -- not safe for widget bug ordering
   put 1 into subIndexNum
   repeat for each line paramValue in paramValues
      put paramValue into subMenuArray [subIndexNum]["label"]
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
end mArray_SetParamMenuItem

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

private command _SetMenuItem @mArray, hName, mController, tObject, mTarget, @recursionArray
   switch
      case hName begins with "submenu_"
         _SubmenuBit mArray, hName, mController, tObject, recursionArray
         break
      case hName begins with "insert_"
         _InsertBit mArray, hName, mController, tObject, mTarget, recursionArray
         break
      default
         _AddMenuItem mArray, hName, mController, mTarget
   end switch
end _SetMenuItem


--> Private | Basic
-
command _AddDivider @mArray
   put _NextIndexNum (mArray) into indexNum
   put "-" into mArray [indexNum]["name"]
   put "-" into mArray [indexNum]["label"]
   put false into mArray [indexNum]["checked"]
   return indexNum
end _AddDivider

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
