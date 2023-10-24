script "Global | Project | Create | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Create | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Project | Create | Dev | Menu
-
on menu_CreateProjectBehavior projectName
   put "Choose a name for your script-only behavior stack...." into someQuestion
   put "behavior_XXX" into suggestedAnswer
   ask_CreateProjectStack "behaviors", projectName, someQuestion, suggestedAnswer
end menu_CreateProjectBehavior

on menu_CreateModule homeStackName
   put "Choose a name for your new module...." into someQuestion
   put the clipboarddata ["text"] into suggestedAnswer
   set the itemdelimiter to "|"
   if item 1 of suggestedAnswer is not "View" then
      put "View|Test" into suggestedAnswer
   end if
   put lcw_Ask (someQuestion, suggestedAnswer) into moduleStackName
   
   put project_GetFolder (homeStackName) into projectFolder
   if projectFolder is empty then
      answer warning "Cannot locate project folder!"
      put projectFolder
      breakpoint
      exit to top
   end if
   put folder_AddShort (projectFolder, "modules") into rootModuleFolder
   
   project_CreateModule moduleStackName, rootModuleFolder
end menu_CreateModule

private command _
end _

on menu_CreateRecentMenu projectName
   put lcw_Ask ("What short name do you want for the Recent menu?", projectName) into shortName
   put ide_ConstructMenuTitle ("Recent", shortName) into gMenuTitle
   
   ask_CreateProjectmenu projectName, gMenuTitle
   put the result into controllerStackObject
   --
   edit the script of controllerStackObject
end menu_CreateRecentMenu

on menu_CreateHandlerMenu projectName
   put lcw_Ask ("What short name do you want for the Handler menu?", projectName) into shortName
   put ide_ConstructMenuTitle ("List", shortName) into gMenuTitle
   
   ask_CreateProjectmenu projectName, gMenuTitle
   put the result into controllerStackObject
   edit the script of controllerStackObject
end menu_CreateHandlerMenu
