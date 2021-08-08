script "lib_GlobalMenu"
--> MetaData
-
license: GPLv3
name: lib_GlobalMenu
type: library
version: 0.1


/*
Simple menus must only contain one menu per script object
They require some fiddling to get multipl edividers.
*/

--> Menu | Global
-
command menu_DoGlobal mCommand, mTitle, pMenuTarget, pValue
   # Search global for any loaded gMenuTitle
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
