﻿script "Global | Project | Create | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Create | Menu
type: controller
version: 0.2

/*
This controller is sometimes called by the Script Editor,
and sometimes by a (project) displayView.
*/

--> Variables
-
local LocalArray


--> Menu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   put the stack_Name of tObject into stackName
   switch
      case word 1 of stackName = "revNewScriptEditor"
         put scriptEditor_Object() into sObject
         put the project_Name of sObject into projectName
         return projectName
      case exists (the displayed_Object of displayView)
         put the displayed_Object of displayView into sObject
         put the project_Name of sObject into projectName
         return projectName
      case exists (displayView)
         put the title_Text of displayView into projectName
         return projectName
      default
         return empty
   end switch
end menu_Target

getprop menu_CheckTarget [projectName]
   pass menu_CheckTarget
end menu_CheckTarget


--> Global | Project | Create | Menu
-
on menu_CreateNewProject
   project_AskCreate
   put the result into newProjectName
   display_Project newProjectName
end menu_CreateNewProject

on menu_CreateModule projectName
   put lcw_Ask ("What name would you like for this module?", "View|Something") into moduleName
   module_CreateWithObject moduleName, projectName
   display_Project projectName
end menu_CreateModule

private command _
end _

on menu_CreateMenu projectName
   put scriptEditor_GetSelectedText() into gMenuTitle
   --
   ask_CreateProjectMenu projectName, gMenuTitle
   put the result into controllerStackObject
   edit the script of controllerStackObject
end menu_CreateMenu

on menu_CreateProjectMenu projectName
   ask_CreateProjectMenu projectName
   put the result into controllerStackObject
   edit the script of controllerStackObject
end menu_CreateProjectMenu

on menu_CreateProjectLibrary projectName
   ask_CreateProjectLibrary projectName
   display_Project projectName
end menu_CreateProjectLibrary

on menu_CreateProjectModel projectName
   put "Choose a name for your script only model stack...." into someQuestion
   put "model_XXX" into suggestedAnswer
   ask_CreateProjectStack "models", projectName, someQuestion, suggestedAnswer
   display_Project projectName
end menu_CreateProjectModel

on menu_CreateProjectBehavior projectName
   card_CreateBehavior
end menu_CreateProjectBehavior

private command __
end __

on menu_ExportMenusAndStackFiles projectName
   put project_GetFolder (projectName) into projectFolder
   project_ExportMenusAndStackFiles projectFolder
   --
   display_ProjectLibs projectName
   display_GitRefreshProjectName projectName
end menu_ExportMenusAndStackFiles

private command __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Project | Create | Menu")
end submenu_Dev
