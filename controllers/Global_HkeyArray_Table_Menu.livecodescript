script "Global | HkeyArray | Table | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | HkeyArray | Table | Menu
type: controller
version: 0.1


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into LocalArray ["dView"]
   put the displayed_Object of tObject into sObject
   return sObject
end menu_Target

private function _dView
   return LocalArray ["dView"]
end _dView

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | HkeyArray | Table | Menu
-
on menu_CollectHkeys
   put _FilteredHkeys() into hKeys
   put word 1 to -1 of hkeyIndex_CollectScript (hKeys) into depScript
   
   -- display_HkeyArrayDeps hkeyArray, sTitle
   put the uOPN ["displayed_Object"] of _dView() into sObject
   display_Text depScript, sObject, "Script Deps"
end menu_CollectHkeys

on menu_DisplayHkeys
   put _FilteredHkeys() into hKeys
   set the displayed_Index of _dView() to hKeys
end menu_DisplayHkeys

on menu_CollectDisplayed sObject
   put _dView() into dView
   put the displayed_Lines of dView into stackDepTable
   
   -- put the uOPN ["stack_DepArray"] of dView into stackDepArray
   put the uOPN ["displayed_Object"] of dView into sObject
   put the uOPN ["hkey_Array"] of dView into hkeyArray
   put stackArray_Without (hkeyArray, sObject) into stackDepArray
   
   # Filter by displayed sObjects
   put _FilterHkeyArray (stackDepArray, stackDepTable) into newHkeyArray
   
   # Display
   display_ScriptHkeyArray newHkeyArray, sObject, "neato"
end menu_CollectDisplayed

private function _FilteredHkeys
   put _FilteredHkeyArray() into hkeyArray
   put the uOPN ["displayed_Object"] of _dView() into sObject
   put hkeyArray_HkeysWithout (hkeyArray, sObject) into hKeys
   return hKeys
end _FilteredHkeys

function hkeyArray_HkeysWithout hkeyArray, sObject
   -- put keys (hkeyArray) into hKeys -- but deps could be outside sObject
   put array_ListKeys (hkeyArray) into hKeys -- includes sObject deps
   
   # Filter
   filter hKeys without ("*" && sObject)
   return hKeys
end hkeyArray_HkeysWithout

private function _FilteredHkeyArray
   put _dView() into dView
   put the uOPN ["hkey_Array"] of dView into hkeyArray
   put the uOPN ["displayed_Object"] of dView into sObject
   
   put stackArray_Without (hkeyArray, sObject) into stackDepArray
   put hkeyArray_FromStackDepArray (stackDepArray) into hkeyArray
   return hkeyArray
end _FilteredHkeyArray

on menu_ListExternalStacks
   put _dView() into dView
   put the uOPN ["displayed_Object"] of dView into sObject
   put the uOPN ["hkey_Array"] of dView into hkeyArray
   
   -- display_HkeyArrayDepTable hkeyArray, sObject
   put stackHkeyTable_Construct (hkeyArray, sObject) into hkeyTable
   set the displayed_Index of dView to hkeyTable
end menu_ListExternalStacks

private function _FilterHkeyArray stackDepArray, stackDepTable
   put _FilterStackArray(stackDepArray, stackDepTable) into newStackDepArray
   put hkeyStackArray_ListHkeys (newStackDepArray) into newHkeyArray
   return newHkeyArray
end _FilterHkeyArray

private function _FilterStackArray stackDepArray, stackDepTable
   -- strips out stacks (creates new stackArray based on thos listed in stackDepTable)
   set the itemdelimiter to tab
   repeat for each line tLine in stackDepTable
      put item 1 of tLine into stackObject
      put stackDepArray [stackObject] into newStackDepArray [stackObject]
   end repeat
   return newStackDepArray
end _FilterStackArray

function hkeyStackArray_ListHkeys hkeyStackArray
   local hkeyArray
   repeat for each key stackObject in hkeyStackArray
      put hkeyStackArray [stackObject] into subHkeyArray
      union hkeyArray with subHkeyArray
   end repeat
   return hkeyArray
end hkeyStackArray_ListHkeys

on menu_RemoveSelected dView
   put the selected_LineNums of dView into lineList
   set the deleted_LineNums of dView to lineList 
end menu_RemoveSelected

private on _
end _

on menu_SortByDeps sObject
   put _dView() into dView
   put the displayed_Index of dView into hkeyTable
   --
   set the itemdelimiter to tab
   sort numeric descending lines of hkeyTable by item 2 of each
   --
   set the displayed_Index of dView to hkeyTable
end menu_SortByDeps

on menu_SortAlphabetical sObject
   put _dView() into dView
   put the displayed_Index of dView into hkeyTable
   --
   set the itemdelimiter to tab
   sort lines of hkeyTable by item 1 of each
   --
   set the displayed_Index of dView to hkeyTable
end menu_SortAlphabetical

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | HkeyArray | Table | Menu")
end submenu_Dev
