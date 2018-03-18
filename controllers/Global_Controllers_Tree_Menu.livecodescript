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

on menu_LoadMenusAndStackFiles indexView
   put the title_Text of indexView into projectName
   put project_GetFolder (projectName) into projectFolder
   project_LoadMenusAndStackFiles projectFolder
end menu_LoadMenusAndStackFiles

on _
end _

on submenu_Project
   return "Global | Project | Display | Menu"
end submenu_Project

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_RevealFolder projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_ConstructFolder ("controllers", projectFolder) into controllerFolder
   finder_Reveal controllerFolder
end menu_RevealFolder

on menu_Refresh
   display_ProjectControllers projectName
end menu_Refresh
