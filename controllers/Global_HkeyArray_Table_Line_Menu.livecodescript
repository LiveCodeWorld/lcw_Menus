script "Global | HkeyArray | Table | Line | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | HkeyArray | Table | Line | Menu
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


--> Global | HkeyArray | Table | Line | Menu
-
on menu_RemoveObject dView
   put the uOPN ["displayed_Object"] of dView into sObject
   put the uOPN ["hkey_Array"] of dView into hkeyArray
   put the uOPN ["stack_DepArray"] of dView into stackDepArray
   
   set the itemdelimiter to tab
   put the selected_Line of dView into sLine
   put item 1 of sLine into sObject
   
   put hkeyArray_RemoveObject (sObject, hkeyArray) into strippedHkeyArray
end menu_RemoveObject

function hkeyArray_RemoveObject hkeyArray, hKey
   
end hkeyArray_RemoveObject

function hkeyArray_RemoveHkey hkeyArray, hKey
   local deletedArray
   hKeyArray_DeleteHkeyRecurse hkeyArray, hKey, deletedArray
   return hkeyArray
end hkeyArray_RemoveHkey

command hKeyArray_DeleteHkeyRecurse @hkeyArray, hKey, @deletedArray
   -- Recusive command
   
   # Recursion safety check to avoid infinite loops
   if deletedArray [hKey] is true then
      return false
   else
      put true into deletedArray [hKey]
   end if
   
   # What shall we do with the parents? -- before deleting the node recursively?
   -- parents will list hkey as one of their children
   hkeyArray_PruneChildren hkeyArray, hKey
   
   # Work out parents
   put array_Reverse (hkeyArray) into reversedArray
   put reversedArray [hKey] into parentArray
   
   # First get children
   put hkeyArray [hKey] into childKeyArray
   
   # Only delete node if parentArray is empty?
   if parentArray is empty then
      # Delete the node hKey
      delete local hkeyArray [hKey]
   end if
   
   # Recurse for each child
   repeat for each key childKey in childKeyArray   
      linkArray_DeleteNodeRecurse hkeyArray, childKey, deletedArray
   end repeat
   
   return true
end hKeyArray_DeleteHkeyRecurse

command hkeyArray_PruneChildren @hkeyArray, hKey
   repeat for each key parentHKey in hkeyArray
      put hkeyArray [parentHKey] into hkeyChildArray
      put the keys of hkeyChildArray into childHkeys
      if hKey is among the lines of childHkeys then
         put "pruned" into hkeyArray [parentHKey][hkey]
      end if
   end repeat
end hkeyArray_PruneChildren

function hkeyArray_DeleteObject sObject, hkeyArray
   breakpoint -- need to rethink?
   
   set the wholematches to true
   repeat for each key parentHKey in hkeyArray
      set the cursor to busy
      hkeyLine_Deconstruct parentHKey, parentHandlerName, parentType, parentObject
      
      # Parent hkey is in object
      if the long id of sObject = the long id of parentObject then
         -- children may be outside of sObject
         -- we could keep then for future analysis - but we get this from original hKeyArray easily?
         
         # Remove all deps unless they are called by something else
         linkArray_DeleteNodeRecurse hkeyArray, parentHKey
         
         next repeat -- we don't care to follow deps
      end if
      
      put hkeyArray [hKey] into handlerCalls
      put empty into filteredCalls
      repeat for each line callKey in handlerCalls
         hkey_Deconstruct callKey, handlerName, handlerType, handlerNum, callObject
         if exists(callObject) is false then
            if someObject is callObject then
               -- Missing
               next repeat
            else
               put callKey & CR after filteredCalls
               next repeat
            end if
         end if
         if the long id of callObject is not the long id of scriptObject then
            put callKey & CR after filteredCalls
         end if
      end repeat
      delete last char of filteredCalls
      put filteredCalls into hkeyArray [hKey]
   end repeat
   return hkeyArray
end hkeyArray_DeleteObject

private on _
end _

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | HkeyArray | Table | Line | Menu")
end submenu_Dev
