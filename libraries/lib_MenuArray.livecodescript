script "lib_MenuArray"
--> MetaData
-
license: GPLv3
name: lib_MenuArray
type: library
version: 0.2

/*
This library is for the set of handlers that deal with new menu array format used by widgets.
*/

--> Variables
-
local LocalArray


--> Working on
-
function menu_ConstructArray gMenuTitle
   put menu_GetGlobalController (gMenuTitle) into mController
   if exists (mController) is false then return empty
   put the script_MenuArray of mController into mArray
   return mArray
end menu_ConstructArray

getprop menu_Index [mTitle]
   -- used by "help_ConstructMenuStory"
   put the menu_Handlers [mTitle] of the target into mHandlers
   return mHandlers
   
   put the script_MenuTitleTableArray of the target into mTitleTableArray
   put mTitleTableArray [mTitle] into mTitleTable
   set the itemdelimiter to tab
   repeat for each line tLine in mTitleTable
      menu_DeconstructTableLine tLine, mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp, mSendLine
      -- put word 1 of item 2 of tLine into mHandler
      put word 1 of pigeon into mHandler
      switch
         case tLine = "-"
            put "-" & CR after mHandlers
            break
         case mItemType = "submenu"
            put submenuProp & CR after mHandlers
            break
         case mHandler is empty
            breakpoint
            break
         default
            put mHandler & CR after mHandlers
      end switch
   end repeat
   delete char -1 of mHandlers
   return mHandlers
end menu_Index


--> Hkey | Do
-
/*
These handlers all take the form of "controller messaging".

In the receiving hName handler "the target" is changed to = mController, which is useless as it is where the handler is.
This is because we use "dispatch". If we use call we may get around this and try to preserve the target?
*/

command mArray_DoController mKey, pValue
   -- changed "dispatch" to "call"
   -- which keeps the context of the target
   
   put the long id of the target into tObject
   mArray_UnMarshal mKey
   hkey_Deconstruct mKey, hName, hType, mController, hNum
   --
   menu_SetTarget mTarget, mController, tObject
   hKey_Do mKey, mTarget, pValue
   return the result
end mArray_DoController

command menu_Do mCommand, mTitle, pMenuTarget, pValue
   -- if pMenuTitle is empty we search all loaded menus and return the first instance
   put menu_FindGlobalController (mCommand, mTitle) into mController
   if exists (mController) is false then return false
   if pMenuTarget is empty then
      put the long id of the target into tObject
      menu_SetTarget pMenuTarget, mController, tObject
   end if
   --
   handler_Do mCommand, mController, pMenuTarget, pValue
   return the result
end menu_Do

command hKey_Do hKey, pTarget, pValue, pQuestion
   if the optionKey is "Down" then
      put rev_TopScriptEditor() into stackObject
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
   
   /*
   dispatch hName to hObject with pTarget,pValue
   switch it
      case "passed"
      case "unhandled"
         return it
      case "handled"
         return the result
   end switch
   */
end handler_Do


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
   put the long id of the target into tObject
   put the active_MenuArray of tObject into mArray
   put the active_MenuTitle of tObject into mTitle
   --
   set the itemdelimiter to "|"
   repeat for each item itemText in mItem
      if mArray is not an array then
         breakpoint
      end if
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
   -- 
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


--> Menu | Props
-
getprop menu_Style
   put LocalArray ["menu_Style"] into mStyle
   if mStyle is empty then return "old"
   return mStyle
end menu_Style

setprop menu_Style mStyle
   put mStyle into LocalArray ["menu_Style"]
end menu_Style

getprop menu_Text [mTitle]
   put the script_MenuArray [mTitle] of the target into mArray
   put mArray_ToText (mArray) into mText
   return mText
end menu_Text

getprop menu_Array [pMenuTitle]
   -- default target is the target whic we assume is a menu_Button
   put the long id of the target into tObject
   
   -- check cache
   put the cached_MenuArray of tObject into mArray
   if mArray is not an array then
      -- calculate from script
      if pMenuTitle is empty then put the cached_MenuTitle of tObject into pMenuTitle
      put mArray_FromTitleTable (pMenuTitle, tObject) into mArray -- dispatches "menu_Init"
   end if
   return mArray
end menu_Array

setprop menu_Array [pMenuTitle] mArray
   -- same as "cached_MenuArray"
   set the cached_MenuArray [pMenuTitle] of the target to mArray
end menu_Array


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


--> Cached | Menus
-
getprop cached_MenuArray
   put the uLCW ["menu_Array"] of the target into mArray
   return mArray
end cached_MenuArray

setprop cached_MenuArray [pMenuTitle] mArray
   put the long id of the target into tObject
   set the uLCW ["menu_Array"] of tObject to mArray
   if pMenuTitle is not empty then
      -- lazy shortcut
      set the cached_MenuTitle of tObject to pMenuTitle
   end if
end cached_MenuArray

getprop cached_MenuTitle
   put the uLCW ["menu_Title"] of the target into mTitle
   return mTitle
end cached_MenuTitle

setprop cached_MenuTitle mTitle
   set the uLCW ["menu_Title"] of the target to mTitle
end cached_MenuTitle


--> Menu | Objects
-
command menu_SetController @mController, tObject, pMenuTitle
   -- global first
   put menu_GetGlobalController (pMenuTitle) into mController
   if exists (mController) is true then return mController
   
   -- check the local context (assumes global default can return empty)
   put the menu_Controller [pMenuTitle] of tObject into mController
   if exists (mController) is true then return mController
   
   -- use card as a default controller
   put the card_Object of tObject into mController   
   return tObject
end menu_SetController

command menu_SetTarget @mTarget, mController, tObject
   -- different from "menu_SetTargetObject" which just set global
   -- controller, view, target logic
   put the menu_Target [tObject] of mController into mTarget
   if mTarget is empty then
      put the menu_Target of tObject into mTarget
      if mTarget is empty then
         put tObject into mTarget
      end if
   end if
end menu_SetTarget


--> mTitle
-
function mTitle_IsGlobal mTitle
   -- could do better check
   return word 1 of mTitle = "Global"
end mTitle_IsGlobal

command mTitle_Normalize @gMenuTitle
   replace "_" with " | " in gMenuTitle
end mTitle_Normalize

function mTitle_ConstructText mTitle
   set the itemdelimiter to "|"
   delete item - 1 of mTitle
   if word 1 to -1 of item 1 of mTitle = "Global" then delete item 1 of mTitle
   
   replace " | " with " " in mTitle
   return word 1 to -1 of mTitle
end mTitle_ConstructText


--> mArray | Mouse
-
command mArray_MouseDown mTitle, pMenuButton
   put the long id of the target into tObject
   if pMenuButton is empty then
      -- defaults to the target rather than the global menu_Button
      put tObject into pMenuButton
   end if
   --
   switch word 1 of pMenuButton
      case "button"
         -- put the menu_Array [mTitle] of tObject into mArray
         put mArray_FromTitleTable (mTitle, tObject) into mArray -- dispatches "menu_Init"
         put mArray_ToText (mArray) into mText
         --
         set the text of pMenuButton to mText
         set the active_MenuArray [mTitle] of pMenuButton to mArray
         return mArray
      case "widget"
         break
      default
         exit to top
   end switch
end mArray_MouseDown

command mArray_PullDown mTitle, pMenuButton
   if pMenuButton is empty then
      -- defaults to the target rather than the global menu_Button
      put the long id of the target into pMenuButton
   end if
   --
   mArray_MouseDown mTitle, pMenuButton
   put the result into mArray
   --
   put the bottomleft of pMenuButton into popLoc
   add 3 to item 2 of popLoc
   popup pMenuButton at popLoc
end mArray_PullDown

command mArray_PopUp mTitle, pMenuButton
   if pMenuButton is empty then
      -- defaults to the target rather than the global menu_Button
      put the long id of the target into pMenuButton
   end if
   --
   mArray_MouseDown mTitle, pMenuButton
   put the result into mArray
   --
   popup pMenuButton
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
      menu_SetController mController, tObject, mTitle
      menu_SetTarget mTarget, mController, tObject
      --
      switch mType
         case "submenu"
            put mTitle_ConstructText (mTitle) into prettyTitle
            _AddSubmenu mArray, prettyTitle, prettyTitle, mTitle, mController, tObject, mTarget, recursionArray
            break
         default
            -- _AddMenu mArray, mTitle, mController, tObject, mTarget, recursionArray
            dispatch "menu_Init" to mController with tObject,mTarget
            mArray_AddScriptMenu mArray, mTitle, mController, tObject, mTarget, recursionArray
      end switch
   end repeat
   return mArray
end mArray_FromTitleTable


--> Menu | Array
-
function mArray_FromScript mTitle, mController, tObject, mTarget, @recursionArray
   local mArray
   mArray_AddScriptMenu mArray, mTitle, mController, tObject, mTarget, recursionArray
   return mArray
end mArray_FromScript

command mArray_AddScriptMenu @mArray, mTitle, mController, tObject, mTarget, @recursionArray
   _RecursionCheck recursionArray, tObject, mController, mTitle
   if the result is false then return false
   
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
         -- check live
         put mArray_GetChecked (hName, pController, pMenuTarget) into isDisabled
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

function mArray_GetChecked hName, mController, mTarget
   set the itemdelimiter to "_"
   put item 2 of hName into hText
   put "check_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into isChecked
   return isChecked
end mArray_GetChecked

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
command mArray_SetParamMenuItem @mArray, propLabel, hName, mController, paramValues, checkParams
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

command mArray_SetPlainMenuItem @mArray, hName, mController
   put _NextIndexNum (mArray) into indexNum
   --
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put menu_CommandToText (hName) into mArray [indexNum]["label"]
   
   _SetChecked mArray, hName, mController
end mArray_SetPlainMenuItem

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
private command _SetDisabled @mArray, isDisabled
   if isDisabled is not empty then
      put item 2 of the extents of mArray into indexNum
      number_PadLeft indexNum, 2
      put isDisabled is true into mArray [indexNum]["disabled"]
   end if
end _SetDisabled

private command _SetChecked @mArray, hName, mController 
   put item 2 of the extents of mArray into indexNum
   number_PadLeft indexNum, 2
   put mArray_GetChecked (hName, mController, mTarget) into itemChecked
   
   -- bizarre bug in Livecode widget being strict on boolean type an text type
   -- put true into mArray [indexNum]["disabled"] does not seem possible
   -- put itemChecked into mArray [indexNum]["checked"] -- does nto work!
   
   if itemChecked is true then
      put true into mArray [indexNum]["checked"]
   else
      put false into mArray [indexNum]["checked"]
   end if
end _SetChecked

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
         _SubmenuBit mArray, hName, mController, tObject, mTarget, recursionArray
         break
      case hName begins with "insert_"
         _InsertBit mArray, hName, mController, tObject, mTarget, recursionArray
         break
      default
         _AddMenuItem mArray, hName, mController, mTarget
   end switch
end _SetMenuItem

private command _AddMenuItem @mArray, hName, mController, mTarget
   set the itemdelimiter to "_"
   put item 2 of hName into propLabel
   --
   put mArray_GetParamValues (propLabel, mController, mTarget) into paramValues
   put mArray_GetCheckParams (propLabel, mController, mTarget) into checkParams
   --
   if paramValues is empty then            
      mArray_SetPlainMenuItem mArray, hName, mController
   else
      mArray_SetParamMenuItem mArray, propLabel, hName, mController, paramValues, checkParams
   end if
   return true
end _AddMenuItem

private command _SubmenuBit @mArray, hName, mController, tObject, mTarget, @recursionArray
   dispatch hName to mController
   put the result into subMenuTitle
   switch
      case subMenuTitle is empty
         return false
      case mTitle_IsGlobal (subMenuTitle)
         menu_SetController subMenuController, tObject, subMenuTitle
         break
      default
         -- assume it is a non-global menu in the same mController
         put mController into subMenuController
   end switch
   put menu_CommandToText (hName) into mLabel
   --
   _AddSubmenu mArray, hName, mLabel, subMenuTitle, subMenuController, tObject, mTarget, recursionArray
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
         menu_SetController insertController, tObject, insertMenuTitle
         break
      default
         -- assume it is a non-global menu in the same mController
         put mController into insertController
   end switch
   
   _AddMenu mArray, insertMenuTitle, insertController, tObject, mTarget, recursionArray
   return the result
end _InsertBit


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
   put mArray_FromScript (mTitle, mController, tObject, mTarget, recursionArray) into addMenuArray
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

private command _AddSubmenu @mArray, mName, mLabel, mTitle, mController, tObject, mTarget, @recursionArray
   put mArray_FromScript (mTitle, mController, tObject, mTarget, recursionArray) into subMenuArray
   if subMenuArray is not an array then return false
   --
   put _NextIndexNum (mArray) into indexNum
   --
   put subMenuArray into mArray [indexNum]["menu"]
   put mName into mArray [indexNum]["name"]
   put mLabel into mArray [indexNum]["label"]
   return true
end _AddSubmenu

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
