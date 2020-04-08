script "Global | MenuTools | Menu"
--> MetaData
-
license: GPLv3
name: Global | MenuTools | Menu
type: controller
version: 0.2

/*
Use this menu to manipulate a menu controller.
*/


--> Variables
-
local LocalArray


--> Menu | Props
-
on menu_Init tObject
   put scriptEditor_Object() into sObject
   put sObject into LocalArray ["sObject"]
end menu_Init

getprop menu_Target [tObject]
   put LocalArray ["sObject"] into sObject
   return sObject
end menu_Target

getprop disabled_ReindexMenu [sObject]
   put the script_MetaData ["type"] of sObject into scriptType
   if scriptType is "controller" then
      return false
   else
      return true
   end if
end disabled_ReindexMenu


--> Global | MenuTools | Menu
-
on menu_ReindexMenu mController
   put the menu_Name of mController into mName
   --
   put the script_MenuTitles of mController into scriptMenuTitles
   --
   set the wholematches to true
   if mName is not among the lines of scriptMenuTitles then
      
   end if
end menu_ReindexMenu
