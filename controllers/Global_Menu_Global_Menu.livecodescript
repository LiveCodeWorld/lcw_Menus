script "Global | Menu | Global | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Global | Menu
type: controller
version: 0.6


--> Menu | Props
-
getprop menu_Target [tObject]
   pass menu_Target
end menu_Target

getprop menu_CheckTarget [mTarget]
   return true
end menu_CheckTarget

on menu_Init tObject
   -- not needed any more
   -- use "menu_CheckTarget" to any initialisation
end menu_Init

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

command env_LoadMenus pListAll
   put env_ListProjects (pListAll) into projectNames
   repeat for each line projectName in projectNames
      put project_GetFolder (projectName) into projectFolder
      project_LoadMenus projectFolder, true
   end repeat
end env_LoadMenus


--> Global | Menu | Global | Menu
-
on menu_Filter displayView
   put lcw_Ask ("Display filtered list of global menus?", "Atopia", displayView) into someFilter
   display_EnvironmentMenus someFilter
end menu_Filter

on _
end _

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
