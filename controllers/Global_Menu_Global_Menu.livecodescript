﻿script "Global | Menu | Global | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Global | Menu
type: controller
version: 0.6


--> Menu | Props
-
command lcw_LoadCustomUserProject
   -- initialises non-version controlled private project
   put lcw_UserProjectFolder() into lcwUserProjectFolder
   project_InitialiseFolder lcwUserProjectFolder
   
   put lcw_UserHomeStackName() into userHomeStackName
   put lcw_UserProjectFolder() into lcwUserProjectFolder
   library_StoreProjectFolder userHomeStackName, lcwUserProjectFolder 
   if there is a stack userHomeStackName then
      -- should be
      dispatch "env_RecursivelyLoadProjects" to stack userHomeStackName
   end if
end lcw_LoadCustomUserProject


--> Global | Menu | Global | Menu
-
on menu_Filter displayView
   put lcw_Ask ("Display filtered list of global menus?", "Atopia", displayView) into someFilter
   display_EnvironmentMenus false, someFilter
end menu_Filter

on _
end _

on menu_Help displayView
   launch_MenuHelp "Global | Menu | Global | Menu"
end menu_Help

on menu_Refresh
   display_EnvironmentMenus
end menu_Refresh

on _
end _

on menu_CleanBrokenControllers displayView
   global gLCW
   
   delete variable gLCW ["Hkey Place Array"]
   delete variable gLCW ["Global Menus"][""]
   --
   put gLCW ["Global Menus"] into gMenuData
   repeat for each key gMenuTitle in gMenuData
      set the cursor to busy
      put gMenuData [gMenuTitle] into gMenuArray
      put gMenuArray ["mController"] into mController
      if exists (mController) then
         mArray_UpdateGlobal mController
      else
         delete variable gLCW ["Global Menus"][gMenuTitle]
         put gMenuArray into badMenuArray [gMenuTitle]
      end if
   end repeat
   display_Data badMenuArray, "Broken Controllers", "gLCW"
end menu_CleanBrokenControllers

on submenu_Dev
   return "Global | Menu | Global | Dev | Menu"
end submenu_Dev
