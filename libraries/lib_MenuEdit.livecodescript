script "lib_MenuEdit"
--> MetaData
-
license: GPLv3
name: lib_MenuEdit
type: library
version: 0.4
deps: lib_FindHkey

/*
This library enables menu editing when present.
*/

--> Props
-
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


--> Working on
-
command menu_EditItem gMenuTitle, handlerName
   put menu_GetGlobalController (gMenuTitle) into mController
   put hkey_Construct (handlerName, "c", mController) into hKey
   hkey_Edit hKey
   return hKey
end menu_EditItem

command menu_Edit pMenuTitle
   -- if pMenuTitle is empty  we assume we are looking for top title
   
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of pMenuTitle is "Global" then
      put menu_GetGlobalController (pMenuTitle) into mController
   else if pMenuTitle is empty then
      -- put mArray_GetActiveTitle() into pMenuTitle
      -- put menu_ControllerFromTitlePath (pMenuTitle) into mController
      -- put mArray_GetActiveMenuController (pMenuTitle) into mController
      
      ## Assume it is the top title
      put mArray_GetTopTitle() into pMenuTitle
      put menu_GetGlobalController (pMenuTitle) into mController
   else
      put menu_ControllerFromTitlePath (pMenuTitle) into mController
   end if
   
   if exists (mController) is false then
      put pMenuTitle
      display_DebugHistory "Can't find mController"
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
   # Find Hkey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into hkeyLine
   if exists (hObject) is false then
      return "Error, cannot find object for hkey:" && hKey
   end if
   
   put the hkey_StartLine [hkeyLine] of hObject into sLineNum
   scriptEditor_EditAndScroll hObject, sLineNum, hName  
   return sLineNum
end hkey_Edit


--> Menu | Edit | Item
-
on menu_EditMenuItem pigeon, mController, sentMenuTarget
   put "What would you like to do with the script of this menu item?" into someQuestion
   
   -- answer someQuestion with "Cancel" or "Edit" as sheet
   put scriptEditor_GetTop() into stackObject
   lcw_Answer someQuestion, stackObject
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

