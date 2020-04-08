script "lib_GlobalMenu"
--> MetaData
-
license: GPLv3
name: lib_GlobalMenu
type: library
version: 0.1


--> Menu | Global
-
command menu_DoGlobal mCommand, mTitle, pMenuTarget, pValue
   -- search global for any loaded gMenuTitle
   put menu_FindGlobalController (mCommand, mTitle) into mController
   --
   if exists (mController) is false then return false
   if pMenuTarget is empty then
      put the long id of the target into tObject
      put mArray_FindMenuTarget (mController, tObject) into pMenuTarget
   end if
   --
   handler_Do mCommand, mController, pMenuTarget, pValue
   return the result
end menu_DoGlobal

function menu_GlobalControllerExists gMenuTitle
   put menu_GetGlobalController (gMenuTitle) into mController
   return exists (mController)
end menu_GlobalControllerExists

function menu_GetGlobalController gMenuTitle
   -- used quite a lot
   -- used to find a Global Menu
   put menu_GetGlobalArray() into gMenuArray
   put gMenuArray [gMenuTitle]["mController"] into mController
   return mController
end menu_GetGlobalController

function menu_FindGlobalController mCommand, pMenuTitle
   global gLCW
   if pMenuTitle is empty then
      put gLCW ["Global Menus"] into gMenuArray
   else
      put gLCW ["Global Menus"][pMenuTitle] into gMenuArray [mTitle]
   end if
   
   repeat for each key mTitle in gMenuArray
      put gMenuArray [mTitle]["gMenuTable"] into gMenuTable
      repeat for each line mTableLine in gMenuTable
         menu_DeconstructTableLine mTableLine, mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp, mSendLine
         if word 1 of pigeon = mCommand then
            return mController
         end if
      end repeat
   end repeat
   return empty
end menu_FindGlobalController

function menu_GetGlobalArray
   global gLCW
   put gLCW ["Global Menus"] into menuGlobalArray
   return menuGlobalArray
end menu_GetGlobalArray

command menu_SetGlobalArray menuGlobalArray
   global gLCW
   put menuGlobalArray into gLCW ["Global Menus"]
   return gLCW ["Global Menus"]
end menu_SetGlobalArray


--> Menu | Old
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


--> Menu | Props
-
getprop menu_Text [mTitle]
   put the script_MenuArray [mTitle] of the target into mArray
   put mArray_ToText (mArray) into mText
   return mText
end menu_Text

getprop menu_Array [pMenuTitle]
   -- default target is the target which we assume is a menu_Button
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
