script "Global | Menu | Global | Dev | Menu"
--> MetaData
-
copyright: Anonymous
license: GPLv3
name: Global | Menu | Global | Dev | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop disabled_DisplayDumpedGlobals
   return library_GlobalDumpFileMissing()
end disabled_DisplayDumpedGlobals

getprop disabled_RestoreDumpedGlobals
   return library_GlobalDumpFileMissing()
end disabled_RestoreDumpedGlobals

getprop disabled_DeleteDumpFile
   return library_GlobalDumpFileMissing()
end disabled_DeleteDumpFile



--> Global | Menu | Global | Dev | Menu
-
on menu_CheckGlobalMenus displayView
   put menu_GetGlobalArray() into globalMenuArray
   repeat for each key gMenuTitle in globalMenuArray
      get globalMenuArray [gMenuTitle] 
      put it ["mController"] into mController
      if exists (mController) is false then
         put it into badMenuArray [gMenuTitle]
      end if
   end repeat
   --
   display_BadMenuArray badMenuArray
end menu_CheckGlobalMenus

on menu_FixGlobalMenuArray displayView
   put menu_GetGlobalArray() into globalMenuArray
   --
   repeat for each key gMenuTitle in globalMenuArray
      get globalMenuArray [gMenuTitle] 
      put it ["mController"] into mController
      if exists (mController) is false then
         put it into badMenuArray [gMenuTitle]
      else
         put revRuggedID (mController) into globalMenuArray [gMenuTitle] ["mController"]
      end if
   end repeat
   --
   set the displayed_Array ["Fixed Menus"] of displayView to globalMenuArray
   --
   if badMenuArray is an array then
      display_BadMenuArray badMenuArray
   end if
end menu_FixGlobalMenuArray

on _
end _

on menu_DisplayProjectArray mTarget, projectName
   breakpoint
   put project_FetchArray (projectName) into projectArray
   
   put merge (",[[]]") into someTitle
   display_Array projectArray, "project_FetchArray()", projectName
   set the title_Menu of the result to "Global | Menu | Global | Menu"
end menu_DisplayProjectArray

on menu_DisplayProjectGlobals mTarget, projectName
   breakpoint
   put project_FetchValue ("projectGlobalArray", projectName) into projectGlobalArray
   --
   display_Array projectGlobalArray, "project_FetchValue()", projectName
   set the title_Menu of the result to "Global | Menu | Global | Menu"
end menu_DisplayProjectGlobals


--> Old Project Name
-
on menu_ExportMenusAndStackFiles projectName
   put project_GetFolder (projectName) into projectFolder
   project_ExportMenusAndStackFiles projectFolder
   --
   display_ProjectLibs projectName
end menu_ExportMenusAndStackFiles

on menu_LoadProjectMenus projectName
   breakpoint
   put project_GetFolder (projectName) into projectFolder
   put project_ListAllControllers (projectFolder) into stackPaths
   project_IndexGlobalMenus stackPaths
end menu_LoadProjectMenus

on _
end _

on menu_DisplayDefaultStackfileArray mTarget, projectName
   put project_ConstructStackFileArray (projectName) into projectStackFileArray
   
   display_Array projectStackFileArray, "project_ConstructStackFileArray()"
end menu_DisplayDefaultStackfileArray

on menu_DisplaySavedStackfileArray mTarget, projectName
   put project_FetchValue ("stackFileArray", projectName) into projectStackFileArray
   
   display_Array projectStackFileArray, "project_FetchValue ('stackFileArray')", projectName
end menu_DisplaySavedStackfileArray

on menu_StoreProjectStackfileArray mTarget, projectName
   put project_ConstructStackFileArray (projectName) into projectStackFileArray
   project_SaveValue "stackFileArray", projectStackFileArray, projectName
   
   menu_DisplayDefaultStackfileArray mTarget, projectName
end menu_StoreProjectStackfileArray

on menu_StoreDefaultProjectGlobals mTarget, projectName
   lcw_LoadProjectMenus projectName
   put the result into gMenuArray
   
   project_SaveValue "Global Menus", gMenuArray, projectName
   
   -- temp hack
   project_DeleteValue "projectGlobalArray", projectName
   
   menu_DisplayProjectArray mTarget, projectName
end menu_StoreDefaultProjectGlobals

on _
end _

on menu_StoreGatheredProjectGlobals mTarget, projectName
   put global_Gather() into projectGlobalArray
   project_SaveValue "projectGlobalArray", projectGlobalArray, projectName
end menu_StoreGatheredProjectGlobals

on menu_RestoreProjectGlobals mTarget, projectName
   project_RestoreGlobals projectName
   
   menu_DisplayProjectGlobals mTarget, projectName
end menu_RestoreProjectGlobals

on _
end _

on menu_DisplayGatherGlobals
   put global_Gather() into globalArray
   display_Array globalArray, "global_Gather()"
   set the title_Menu of the result to "Global | Menu | Global | Menu"
end menu_DisplayGatherGlobals

on menu_DisplayGlobal mTarget, globalName
   display_GlobalValue globalName
end menu_DisplayGlobal

on menu_DeleteGlobal mTarget, globalName
   global_Delete globalName
end menu_DeleteGlobal

on _
end _

on menu_DisplayDumpedGlobals
   put library_FetchGlobalDump() into globalArray
   display_Array globalArray, "library_FetchGlobalDump()"
   set the title_Menu of the result to "Global | Menu | Global | Menu"
end menu_DisplayDumpedGlobals

on menu_RestoreDumpedGlobals
   library_RestoreGlobalDump
   menu_DisplayGatherGlobals
end menu_RestoreDumpedGlobals

on menu_DumpAllGlobals
   put global_Gather() into globalArray
   library_StoreGlobalDump globalArray
end menu_DumpAllGlobals

on _
end _

on menu_DeleteAllGlobals
   global_DeleteAll
end menu_DeleteAllGlobals

on menu_DeleteDumpFile
   library_DeleteGlobalDump
end menu_DeleteDumpFile

on menu_ConstructDefaultGlobals mTarget, projectName
   global gLCW
   
   lcw_LoadProjectMenus projectName
   put the result into gMenuArray
   
   display_Array gMenuArray, "project_LoadMenus"
   set the title_Menu of the result to "Global | Menu | Global | Menu"
   
   display_Array gLCW, "gLCW"
   set the title_Menu of the result to "Global | Menu | Global | Menu"
end menu_ConstructDefaultGlobals

on menu_DeleteUneededGlobals
   global gLCW
   delete variable gLCW ["behaviorArray"]
   delete variable gLCW ["handlerArray"]
   delete variable gLCW ["keywordArray"]
   delete variable gLCW ["objectType"]
   delete variable gLCW ["scriptArray"]
   
   menu_DisplayGatherGlobals
end menu_DeleteUneededGlobals

on _
end _

on menu_IndexLcwScripts
   -- lcw_ExportAndAddScriptToHarray cardObject
   put lcw_GetRootFolder() into projectFolder
   project_IndexAllScripts projectFolder
end menu_IndexLcwScripts

on menu_IndexAStack
   global gLCW
   
   put the name of stack "Global_Git_Log_Menu" into mController
   put the script of mController into someScript
   
   put true into forceIndexHandlerCalls
   put true into createHashArray
   
   lcw_ExportAndAddScriptToHarray gLCW, mController, someScript --, createHashArray, forceIndexHandlerCalls, false
   put the result into scriptFile
   
   set the menu_Update of mController to true
   put the result into mTitleTableArray
   
   display_Array gLCW, "lcw_ExportAndAddScriptToHarray lcwArray"
   display_Array mTitleTableArray, "the script_MenuTitleTableArray"
end menu_IndexAStack

on menu_IndexAnotherStack
   put "Global_Array_Menu" into gMenuTitle
   
   put the name of stack gMenuTitle into mController
   script_UpdateHarrayAndExport mController, false
   
   replace "_" with " | " in gMenuTitle
   put menu_GetGlobalTitleArray (gMenuTitle) into gMenuTitleArray
   display_Array gMenuTitleArray, "menu_GetGlobalTitleArray (gMenuTitle)"
end menu_IndexAnotherStack

on menu_IndexAllMenus
   global gLCW
   
   -- put lcw_GetRootFolder() into projectFolder
   put library_FetchProjectFolder ("lcw_Authoring") into projectFolder
   put project_ListAllControllers (projectFolder) into stackPaths
   
   repeat for each line stackPath in stackPaths
      put the name of stack stackPath into mController
      
      -- script_UpdateHarrayAndExport mController, false
      put the script of mController into someScript
      lcw_ExportAndAddScriptToHarray gLCW, mController, someScript
      set the menu_Update of mController to true
      put the result into mTitleTableArray
   end repeat
end menu_IndexAllMenus

on menu_GlobalArrayMenu
   go to stack "Global_Array_Menu"
end menu_GlobalArrayMenu
