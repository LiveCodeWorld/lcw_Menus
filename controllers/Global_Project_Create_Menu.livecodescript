script "Global | Project | Create | Menu"
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
   put the displayed_Object of displayView into displayedObject
   --
   switch
      case word 1 of stackName = "revNewScriptEditor"
         put scriptEditor_Object() into sObject
         put the project_Name of sObject into projectName
         return projectName
      case exists (displayView)
         put the title_Text of displayView into projectName
         return projectName
      case exists (displayedObject)
         breakpoint
         put the displayed_Object of displayView into sObject
         put the project_Name of sObject into projectName
         return projectName
      default
         return "Error"
   end switch
end menu_Target

getprop menu_CheckTarget [projectName]
   -- could do a check here
   return true
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
   
   project_UpdateArray projectName
   display_Project projectName
end menu_CreateModule

private command _
end _

on menu_CreateProjectLibrary projectName
   ask_CreateProjectLibrary projectName
   
   display_Project projectName
   project_UpdateArray projectName
end menu_CreateProjectLibrary

on menu_CreateProjectModel projectName
   put "Choose a name for your script only model stack...." into someQuestion
   put "model_XXX" into suggestedAnswer
   ask_CreateProjectStack "models", projectName, someQuestion, suggestedAnswer
   
   display_Project projectName
   project_UpdateArray projectName
end menu_CreateProjectModel

on menu_CreateProjectBehavior projectName
   card_CreateBehavior
   project_UpdateArray projectName
end menu_CreateProjectBehavior

on menu_CreateProjectMenu projectName
   put scriptEditor_GetSelectedText() into gMenuTitle
   --
   ask_CreateProjectMenu projectName, gMenuTitle
   put the result into controllerStackObject
   edit the script of controllerStackObject
   --
   project_UpdateArray projectName
end menu_CreateProjectMenu

private command __
end __

on menu_UpdateProjectArray projectName
   project_UpdateArray projectName
   --
   display_ProjectLibs projectName
   display_GitRefreshProjectName projectName
end menu_UpdateProjectArray

-- private command ___
end ___

-- on submenu_Dev
   return menu_DevTitle ("Global | Project | Create | Menu")
end submenu_Dev
