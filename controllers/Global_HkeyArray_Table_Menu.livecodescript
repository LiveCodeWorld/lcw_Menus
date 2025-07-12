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
on menu_CollectHkeys dView
   put the uOPN ["displayed_Object"] of dView into sObject
   put the uOPN ["hkey_Array"] of dView into hkeyArray
   put the uOPN ["stack_DepArray"] of dView into stackDepArray
   
   put the displayed_Lines of dView into stackDepTable
   set the itemdelimiter to tab
   repeat for each line tLine in stackDepTable
      put item 1 of tLine into stackObject
      put stackDepArray [stackObject] into newStackDepArray [stackObject]
   end repeat
   
   put hkeyStackArray_ListHkeys (newStackDepArray) into newHkeyArray
   display_ScriptHkeyArray newHkeyArray, sObject, "neato"
end menu_CollectHkeys

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

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | HkeyArray | Table | Menu")
end submenu_Dev
