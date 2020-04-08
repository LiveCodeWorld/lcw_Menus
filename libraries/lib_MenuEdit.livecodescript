script "lib_MenuEdit"
--> MetaData
-
license: GPLv3
name: lib_MenuEdit
type: library
version: 0.3
deps: lib_FindHkey

/*
This library enables menu editing when present.
*/


--> Working on
-
command menu_Edit pMenuTitle
   -- should use "script_ScrollToLine"
   
   if pMenuTitle is empty then
      -- put debug_GetCallingObject ()
      
      put debug_GetCallingContextLine () into contextLine
      debug_DeconstructContextLine contextLine, hObject, hName, lineNum, behaviorObjects      
      --
      put the script_MenuTitleAbove [lineNum] of hObject into pMenuTitle
      if pMenuTitle is empty then
         breakpoint
         lcw_AnswerWarning "Cannot locate menu for this item!"
      end if
   end if
   
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of pMenuTitle is "Global" then
      put menu_GetGlobalController (pMenuTitle) into mController
   else if pMenuTitle is empty then
      put mArray_GetTopTitle() into pMenuTitle
      put menu_ControllerFromTitlePath (pMenuTitle) into mController
   else
      put menu_ControllerFromTitlePath (pMenuTitle) into mController
   end if
   
   if exists (mController) is false then
      answer warning merge ("Cannot locate controller for menu '[[pMenuTitle]]'!")
      exit to top
   end if
   
   -- Let's edit the mController
   edit the script of mController
   put the script of mController into someScript
   
   -- Find the place and scroll to the mTitle
   put "-->" && pMenuTitle into suiteTitle
   script_ScrollToLine suiteTitle, someScript
end menu_Edit


--> Heky | Edit
-
command hkey_Edit hKey
   -- could be done more efficiently
   -- not using any chachng or database (searches script hierarchy)
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into hkeyLine
   --
   if exists (hObject) is true then
      put the found_Hkey [hkeyLine] of hObject into foundHkey
   else
      put hkey_Find (hkeyLine) into foundHkey 
   end if
   --
   hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
   if exists (fObject) is false then return empty
   --
   put the hkey_StartLine [hkeyLine] of fObject into scriptLineNum
   scriptEditor_EditAndScroll fObject, scriptLineNum   
   --
   return foundHkey & CR & foundLineNum
end hkey_Edit


--> Menu | Edit
-
on menu_EditMenuItem pigeon, mController, sentMenuTarget
   put "What would you like to do with the script of this menu item?" into someQuestion
   
   -- answer someQuestion with "Cancel" or "Edit" as sheet
   put scriptEditor_GetTop() into stackObject
   if exists (stackObject) then
      dispatch "lcw_AnswerSheet" to stackObject with someQuestion,"Edit"
   else
      lcw_AnswerSheet someQuestion, "Edit"
   end if
   put the result into answerResult
   
   switch answerResult
      case "Edit"
         put word 1 of pigeon into handlerName
         menu_EditMenuItemScript handlerName, mController, sentMenuTarget
         put the result into foundInfo
         --
         if foundInfo is empty then
            -- let's try to find it another way?
            -- lcw_Notify "Cannot locate menu!"
            put "Cannot locate menu!" & CR & pigeon,mController,sentMenuTarget
            edit the script of mController
         end if
         break
      case "Export"
         menu_ExportMenuItemScript pigeon, mController
         break
      default
         exit to top
   end switch
end menu_EditMenuItem

command menu_EditMenuItemScript handlerName, mController, sentMenuTarget
   put hkey_Construct (handlerName, "c", mController) into hKey
   try
      hkey_Edit hKey
      put the result into foundInfo
      return foundInfo
   catch e
      edit the script of mController
      return "Error: canot edit script of" && mController
   end try
end menu_EditMenuItemScript

command menu_ExportMenuItemScript pigeon, mController
   put word 1 of pigeon into handlerName
   put hkey_Construct (handlerName, "c", mController) into hKey
   -- hkey_CreateTest hKey
end menu_ExportMenuItemScript


--> Deps
-
command script_ScrollToLine suiteTitle, someScript
   set the wholematches to true
   put lineOffset (suiteTitle, someScript) into lineNum
   if lineNum = 0 then return empty
   
   put rev_ScriptEditorField() into someField   
   field_ScrollToLine lineNum, someField
end script_ScrollToLine

command scriptEditor_EditAndScroll hObject, scriptLineNum
   edit the script of hObject
   put rev_HandlerTreeField() into handlerTreeField
   put rev_ScriptEditorField() into scriptEditorField
   
   put the text of handlerTreeField into hIndex
   put lineOffset (hName, hIndex) into hLineNum
   --
   try
      lock screen
      set the hilitedLine of handlerTreeField to hLineNum
      field_ScrollToLine scriptLineNum, scriptEditorField, true
      dispatch "closeAccept" to handlerTreeField
      unlock screen
      --
      return empty
   catch e
      return the executioncontexts
   end try
end scriptEditor_EditAndScroll

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

