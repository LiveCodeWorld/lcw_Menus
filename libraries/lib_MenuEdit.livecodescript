script "lib_MenuEdit"
--> MetaData
-
license: GPLv3
name: lib_MenuEdit
type: library
version: 0.1


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
            lcw_Notify "Cannot locate menu!"
            put pigeon,mController,sentMenuTarget
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
command hkey_Edit hKey, pExternalObjects
   -- could be done more efficiently
   -- not using any chachng or database (searches script hierarchy)
   
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into hkeyLine
   --
   if exists (hObject) is true then
      put the found_Hkey [hkeyLine] of hObject into foundHkey
   else
      put hkey_FindFirst (hName, hType, pExternalObjects) into foundHkey 
   end if
   --
   if exists (hObject) is false then return empty
   --
   hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
   if exists (fObject) is false then return empty
   --
   edit the script of fObject
   --
   put the hkey_StartLine [hkeyLine] of fObject into foundLineNum
   rev_SetSelectedHandlerTreeLineNum foundLineNum
   --
   return foundHkey & CR & foundLineNum
end hkey_Edit

function hkey_Construct hName, hType, hObject, pHandlerNum
   if exists (hObject) then
      put revRuggedID (hObject) into hObject
   else
      put "Missing" into hObject
   end if
   if pHandlerNum is empty then put 1 into pHandlerNum
   return hName,hType,hObject,pHandlerNum
end hkey_Construct

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   if the number of items of hkey = 1 then
      hKeyLine_Deconstruct hKey, hName, hType, hObject
      put 1 into hNum
   else
      -- old version
      put word 1 to -1 of item 1 of hKey into hName
      put word 1 to -1 of item 2 of hKey into hType
      if hType is empty then put "c" into hType
      put word 1 to -1 of item 3 of hKey into hObject
      put item 4 of hKey into hNum
      if hNum is empty then put 1 into hNum
   end if
   
   put hKeyLine_FromTripple (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkey_Deconstruct

function hKeyLine_Construct hkeyLine, hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_Construct

command hKeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hKeyLine_Deconstruct

function hKeyLine_FromTripple hName, hType, hObject
   replace "c" with "M" in hType
   put toUpper (hType) && hName into shortHkeyLine
   if hObject is empty then return shortHkeyLine
   
   put hKeyLine_Construct (shortHkeyLine, hObject) into hkeyLine
   return hkeyLine
end hKeyLine_FromTripple

command rev_SetSelectedHandlerTreeLineNum treeLineNum
   -- ignoreCall:  closeAccept,c
   put rev_HandlerTreeField() into handlerTreeField
   try
      set the hilitedLine of handlerTreeField to treeLineNum
      dispatch "closeAccept" to handlerTreeField
      return empty
   catch e
      -- lcw_Notify (the params & CR & handlerTreeField), true
      return the executioncontexts
   end try
end rev_SetSelectedHandlerTreeLineNum

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return rev_TopScriptEditor()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
      default
         return rev_TopScriptEditor()
   end switch
end rev_ScriptEditorStack

function rev_TopScriptEditor
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
end rev_TopScriptEditor


