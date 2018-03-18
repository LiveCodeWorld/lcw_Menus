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

on _
end _

on menu_ProjectStacks homeStackName
   display_ProjectStacks homeStackName
end menu_ProjectStacks

on menu_ProjectFrontScripts homeStackName
   display_ProjectFrontScripts homeStackName
end menu_ProjectFrontScripts

on menu_ProjectBackScripts homeStackName
   display_ProjectBackScripts homeStackName
end menu_ProjectBackScripts


--> Global | Project | Display | Menu | Props
-

--> Global | Project | Display | Menu | Disabled
-
