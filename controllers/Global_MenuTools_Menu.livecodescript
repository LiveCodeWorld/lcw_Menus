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
getprop menu_Target [tObject]
   put display_GetObject (tObject) into sObject
   if sObject is empty then return "delete"
   -- 
   put tObject into LocalArray ["tObject"]
   put sObject into LocalArray ["sObject"]
   --
   put the script_MetaData of sObject into mArray
   put mArray ["type"] into sType
   put mArray into LocalArray ["mArray"]
   put sType into LocalArray ["sType"]
   --
   if sType is "controller" then
      put sObject into LocalArray ["mController"]
   else
      delete variable LocalArray ["mController"]
   end if
   return sObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   if mTarget is "delete" then return false
   _Init mTarget
   
   -- this is called next
   if LocalArray ["sType"] is among the items of "menu,controller" then
      return true
   else
      return false
   end if
end menu_CheckTarget

on _Init mTarget
   -- only called if the menu_CheckTarget is true
   put LocalArray ["mController"] into mController
   if exists (mController) then
      put the menu_Name of mController into LocalArray ["mName"]
      put the script_MenuTitles of mController into LocalArray ["mTitles"]
   end if
end _Init

function scriptEditor_IsHistoryButton sObject
   put rev_HistoryButton() into historyButton
   if the long id of historyButton = sObject then
      return true
   else
      return false
   end if
end scriptEditor_IsHistoryButton


--> Global | MenuTools | Menu
-
on menu_DisplayMenu mController
   display_MenuItems mController
end menu_DisplayMenu

on menu_CreateProjectMenu mController
   put the project_Name of mController into projectName
   ask_CreateProjectmenu projectName
   put the result into controllerStackObject
   --
   display_ProjectControllers projectName
   --
   edit the script of controllerStackObject
end menu_CreateProjectMenu

on _
end _

on menu_RenameController mController
   ask_FixMenuControllerStackName mController
   put the result into newStackName
   --
   put the project_Name of stack newStackName into projectName
   display_ProjectControllers projectName
   --
   edit the script of stack newStackName
end menu_RenameController

on menu_ReindexMenu mController
   -- we reindex the whole projects menus
   -- would be faster and better to just do this menu?
   
   put the menu_Name of mController into mName
   put the script_MenuTitles of mController into scriptMenuTitles
   --
   set the wholematches to true
   if mName is not among the lines of scriptMenuTitles then
      -- a good check but so what :)
   end if
   --
   put the project_Folder of mController into projectFolder
   project_ExportMenusAndStackFiles projectFolder
   --
   put the project_Name of mController into projectName
   display_ProjectControllers projectName
   display_ProjectLibs projectName
   display_GitRefreshProjectName projectName
end menu_ReindexMenu

on _
end _

on menu_DisplayProjectMenus mController
   put the project_Name of mController into projectName
   --
   display_ProjectControllers projectName
end menu_DisplayProjectMenus
