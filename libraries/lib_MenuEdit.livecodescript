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
   _SelectScriptEditorLineNum fObject, fName, hkeyLine
   --
   return foundHkey & CR & foundLineNum
end hkey_Edit


--> Menu | Edit
-
on menu_EditMenuItem pigeon, mController, sentMenuTarget
   put "What would you like to do with the script of this menu item?" into someQuestion
   
   -- answer someQuestion with "Cancel" or "Edit" as sheet
   put rev_TopScriptEditor() into stackObject
   dispatch "lcw_AnswerSheet" to stackObject with someQuestion,"Edit"
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
command _SelectScriptEditorLineNum hObject, hName, hkeyLine
   edit the script of hObject
   put rev_HandlerTreeField() into handlerTreeField
   put rev_ScriptEditorField() into scriptEditorField
   
   put the hkey_StartLine [hkeyLine] of hObject into scriptLineNum
   put the text of handlerTreeField into hIndex
   put lineOffset (hName, hIndex) into hLineNum
   
   try
      lock screen
      set the hilitedLine of handlerTreeField to hLineNum
      field_ScrollToLine scriptLineNum, scriptEditorField, true
      dispatch "closeAccept" to handlerTreeField
      unlock screen
      return empty
   catch e
      -- lcw_Notify (the params & CR & handlerTreeField), true
      return the executioncontexts
   end try
end _SelectScriptEditorLineNum
