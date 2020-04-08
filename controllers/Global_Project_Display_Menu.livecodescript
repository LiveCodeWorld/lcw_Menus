script "Global | Project | Display | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Display | Menu
type: controller
version: 0.3


--> Menu | Init
-
getprop disabled_ProjectFolder [projectName]
   if exists (stack projectName) then
      return false
   else
      return true
   end if
end disabled_ProjectFolder

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

getprop disabled_ProjectViews [projectName]
   put project_ListViewPaths (projectName) into filePaths
   if filePaths is empty then
      return true
   else
      return false
   end if
end disabled_ProjectViews
   
getprop disabled_ProjectModules [projectName]
   put project_ListModulePaths (projectName) into filePaths
   -- put project_ListModuleHomeStackNames (projectName) into stackNames
   if filePaths is empty then
      return true
   else
      return false
   end if
end disabled_ProjectModules


--> Global | Project | Display | Menu
-
on menu_ProjectMenus projectName
   display_ProjectControllers projectName
end menu_ProjectMenus

on menu_ProjectBehaviors projectName
   display_ProjectBehaviors projectName
end menu_ProjectBehaviors

on menu_ProjectModules projectName
   display_ProjectModules projectName
   return empty
end menu_ProjectModules

on menu_ProjectViews projectName
   display_ProjectViews projectName
   return empty
end menu_ProjectViews

on _
end _

on menu_ProjectFolder projectName
   put the project_Folder of stack projectName into projectFolder
   --
   finder_Reveal projectFolder
end menu_ProjectFolder
