script "Global_Project_Display_Menu"
--> MetaData
-
license: GPLv3
name: Global_Project_Display_Menu
type: controller
version: 0.3


--> Global | Project | Display | Menu
-
on menu_ProjectMenus homeStackName
   display_ProjectControllers homeStackName
end menu_ProjectMenus

on menu_ProjectBehaviors homeStackName
   display_ProjectBehaviors homeStackName
end menu_ProjectBehaviors

on menu_ProjectModules homeStackName
   display_ProjectModules homeStackName
   return empty
end menu_ProjectModules

on menu_ProjectViews homeStackName
   display_ProjectViews homeStackName
   return empty
end menu_ProjectViews


--> Global | Project | Display | Menu | Props
-

--> Global | Project | Display | Menu | Disabled
-
getprop disabled_ProjectMenus [projectName]
   put project_ListControllerPaths (projectName) into filePaths
   if filePaths is empty then
      return true
   else
      return false
   end if
end disabled_ProjectMenus

getprop disabled_ProjectBehaviors [projectName]
   put project_ListBehaviorPaths (projectName) into filePaths
   if filePaths is empty then
      return true
   else
      return false
   end if
end disabled_ProjectBehaviors

getprop disabled_ProjectViews [homeStackName]
   put project_ListViewPaths (homeStackName) into filePaths
   if filePaths is empty then
      return true
   else
      return false
   end if
end disabled_ProjectViews
   
getprop disabled_ProjectModules [homeStackName]
   put project_ListModulePaths (homeStackName) into filePaths
   -- put project_ListModuleHomeStackNames (homeStackName) into stackNames
   if filePaths is empty then
      return true
   else
      return false
   end if
end disabled_ProjectModules

on errorDialog pExecutionError, pParseError
   
end errorDialog
