script "Global_Controllers_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Controllers_Tree_Menu
type: controller
version: 0.2


--> Global | Controllers | Tree | Menu
-
on menu_CreateProjectMenu projectName
   menu_Do "menu_CreateProjectMenu", "Global | Project | Create | Menu", projectName
   display_ProjectControllers projectName
end menu_CreateProjectMenu

on _
end _

on menu_LoadMenus projectName
   put project_GetFolder (projectName) into projectFolder
   project_LoadMenus projectFolder, true
end menu_LoadMenus

on menu_ExportMenusAndStackFiles projectName
   put project_GetFolder (projectName) into projectFolder
   project_ExportMenusAndStackFiles projectFolder
end menu_ExportMenusAndStackFiles

on menu_LoadMenusAndStackFiles projectName
   put project_GetFolder (projectName) into projectFolder
   project_LoadMenusAndStackFiles projectFolder
end menu_LoadMenusAndStackFiles

on _
end _

on menu_ControllerFolder projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_ConstructFolder ("controllers", projectFolder) into controllerFolder
   finder_Reveal controllerFolder
end menu_ControllerFolder

on _
end _

on menu_Refresh projectName
   display_ProjectControllers projectName
end menu_Refresh
