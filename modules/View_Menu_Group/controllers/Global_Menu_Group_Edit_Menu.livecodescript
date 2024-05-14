script "Global | Menu | Group | Edit | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Group | Edit | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- put display_MenuTarget (tObject) into dView
   if exists (tObject) is false then
      breakpoint
      return empty
   end if
   put the display_View of tObject into dView
   return dView
end menu_Target

-- getprop menu_CheckTarget [dView]
return exists (dView)
end menu_CheckTarget

-- command actionUndo
textUndo
end actionUndo

-- command actionRedo
textRedo
end actionRedo

command actionDeselectAll
   lock messages
   select empty
   unlock messages
end actionDeselectAll

command actionSelectAll
   lock messages
   
   if word 1 of the name of the focusedObject is "field" then
      select char 1 to -1 of the focusedObject
   end if
   unlock messages
end actionSelectAll

on revMenubarMenuButtonClicked pWhich
   switch pWhich
      case "Inspector"
         if (the selectedObject) is empty then
            revIDEActionInspectStack
         else
            revIDEActionInspectObjects
         end if
         break
      case "Code"
         if (the selectedObject) is empty then
            revIDEActionEditScriptOfStack
         else
            revIDEActionEditScriptOfObjects
         end if
         break
      case "Message Box"
         revIDETogglePalette "message box"
         break
      case "Group"
         if the number of lines in (the selObj) > 1 or word 1 of (the selObj) is not "group" then
            revIDEActionGroupObjects
         else
            revIDEActionUngroup
         end if
         break
      case "Edit Group"
         revIDEActionEditGroup
         break
      case "Select Grouped"
         revIDEToggle "Select Grouped Controls"
         break
      case "Messages"
         revIDEToggle "Suppress Messages"
         break
      case "Errors"
         revIDEToggle "Suppress Errors"
         break
      case "Sample Stacks"
      case "Lessons"
         revIDELaunchResource pWhich
         break
      case "Resources"
         revIDEOpenPalette "Resource Center"
         break
      case "Dictionary"
         revIDEDocumentationLoad "API", "LiveCode Script"
         break
      case "Test"
         revIDEDeployAction
         break
   end switch
end revMenubarMenuButtonClicked

private command handleEditMenuPick pItemName
   if dispatchMenuPick("Edit", pItemName) then
      exit handleEditMenuPick
   end if
   
   switch pItemName
      case "Undo"
         actionUndo
         break
      case "Redo"
         actionRedo
         break
      case "Cut"
         actionCut
         break
      case "Copy"
         actionCopy
         break
      case "Paste"
         actionPaste
         break
      case "Select all"
         actionSelectAll
         break
      case "Comment"
         actionComment
         break
      case "Uncomment"
         actionUncomment
         break
      case "Quick Find"
         actionInteractiveFind
         break
      case "Find and replace..."
         actionFindDialog
         break
      case "Find Selection"
         actionFindSelection
         break
      case "Go..."
         actionGoDialog
         break
      case "Revert"
         actionRevert
         break
      case "Options|Variable Checking"
         sePrefSet "explicitVariables", (not sePrefGet("explicitVariables"))
         break
      case "Options|Live Errors"
         sePrefSet "editor,liveerrors", (not sePrefGet("editor,liveerrors"))
         break
      case "Options|Bracket Completion"
         sePrefSet "editor,bracketcompletion", (not sePrefGet("editor,bracketcompletion"))
         break
      case "Options|Bracket Highlighting"
         sePrefSet "editor,brackethighlighting", (not sePrefGet("editor,brackethighlighting"))
         break
      case "Options|Control Structure Completion"
         sePrefSet "editor,autocomplete", (not sePrefGet("editor,autocomplete"))
         break
      case "Options|Autocomplete"
         sePrefSet "editor,providercompletion", (not sePrefGet("editor,providercompletion"))
         break
      case "Options|Autoformat"
         sePrefSet "editor,autoformat", (not sePrefGet("editor,autoformat"))
         break
      case "Preferences"
         actionShowPreferences
         break
      case "Autocomplete Snippets..."
         actionAutocompleteSnippetManager
         break
   end switch
end handleEditMenuPick

private command buildEditMenu pContext
   local tEdit
   if seUndoAvailable() then
      put "Undo/Z" & return into tEdit
   else
      put "(Undo/Z" & return into tEdit
   end if
   
   if seRedoAvailable() then
      put "Redo/^@Z" & return after tEdit
   else
      put "(Redo/^@Z" & return after tEdit
   end if
   
   if pContext["textSelected"] then
      put "Cut/X" & return & \
            "Copy/C" & return after tEdit
   else
      put "(Cut/X" & return & \
            "(Copy/C" & return after tEdit
   end if
   
   put "Paste/V" & return & \
         "Select All/A" & return & \
         "Revert" & return & \
         "-" & return & \
         "Comment/-" & return & \
         "Uncomment/_" & return & \
         "-" & return & \
         "Quick Find/F" & return & \
         "Find and Replace.../^@F" & return & \
         "Find Selection/^#F" & return & \
         "Go.../L" & return after tEdit
   
   if revEnvironmentEditionProperty("autocomplete_pro") then
      put "Autocomplete Snippets..." & return after tEdit
   end if
   
   put "Options" & return after tEdit
   put toggleMenuItem(tab & "Variable Checking", sePrefGet("explicitVariables")) & return after tEdit
   put toggleMenuItem(tab & "Live Errors", sePrefGet("editor,liveerrors")) & return after tEdit
   put toggleMenuItem(tab & "Bracket Completion", sePrefGet("editor,bracketcompletion")) & return after tEdit
   put toggleMenuItem(tab & "Bracket Highlighting", sePrefGet("editor,brackethighlighting")) & return after tEdit
   put toggleMenuItem(tab & "Control Structure Completion", sePrefGet("editor,autocomplete")) & return after tEdit
   
   if revEnvironmentEditionProperty("autocomplete") then
      put toggleMenuItem(tab & "Autocomplete", sePrefGet("editor,providercompletion")) & return after tEdit
   end if
   put toggleMenuItem(tab & "Autoformat", sePrefGet("editor,autoformat")) & return after tEdit
   
   put "-" & return & \
         "Preferences" after tEdit
   
   set the text of button "Edit" of me to modifyMenu("Edit", tEdit)
end buildEditMenu

command display_ActiveMenuArray
   put mArray_GetActiveArray() into activeMenuArray
   --
   display_Data activeMenuArray, "mArray_GetActiveArray()", mArray
   put the result into dView
   return dView
end display_ActiveMenuArray

getprop disabled_MessageBox
   return false
end disabled_MessageBox

getprop checked_MessageBox
   return "Message Box" is among the lines of the openstacks
end checked_MessageBox


--> Global | Menu | Group | Edit | Menu
-
on menu_Undo dView
   -- actionUndo
end menu_Undo

on menu_Redo dView
   breakpoint
   -- put the params
end menu_Redo

private on _
end _

on menu_Cut.X dView
   -- actionCut
   -- cut
   -- revMenubarEditMenuPick "Cut"
end menu_Cut.X

on menu_Copy.C dView
   -- copy
end menu_Copy.C

on menu_Paste.V dView
   -- paste
end menu_Paste.V

private on __
end __

on menu_SelectAll.A dView
   -- actionSelectAll
   revMenubarEditMenuPick "Select All"
end menu_SelectAll.A

-- on menu_Revert dView
put the params
end menu_Revert

private on ___
end ___

on menu_CardScript dView
   put the card_Object of dView into cardObject
   edit the script of cardObject
end menu_CardScript

on menu_WikiBehavior dView
   put the browser_View of dView into browserView
   put the behavior of browserView into bObject
   edit the script of bObject
end menu_WikiBehavior

on menu_MenuGroupBehavior dView
   put the browser_View of dView into wikiView
   put the menuBar_View of wikiView into mGroup
   put the behavior of mGroup into bObject
   --
   edit the script of bObject
end menu_MenuGroupBehavior

private on ____
end ____

on menu_MessageBox.M
   revIDETogglePalette "message box"
end menu_MessageBox.M
