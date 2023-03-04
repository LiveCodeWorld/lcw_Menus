script "Global | Modules | Tree | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Modules | Tree | Line | Menu
type: controller
version: 0.2


--> Variables
-
local LocalArray


--> Menu | Props
-
-- getprop menu_CheckTarget [tObject]
   if exists (stack moduleName) is true then
      return true
   else
      -- breakpoint
      return false
   end if
end menu_CheckTarget

getprop menu_Target [tObject]
   _Init tObject
   return LocalArray ["moduleName"]
end menu_Target

command _Init tObject
   pass _Init
   
   put the array_View of tObject into displayView
   if displayView is empty then
      put the display_View of tObject into displayView
      put the selected_Line of displayView into moduleName
   else
      get the selected_Path of displayView
      if item 1 of it = "Modules" then
         put item 2 of it into moduleName
      else
         put empty into moduleName
         return false
      end if
   end if
   
   put the title_Text of displayView into projectName
   
   if exists (stack moduleName) is false then
      return empty
   end if
   
   put the stack_Folder of stack moduleName into moduleFolder
   put project_ConstructHomeStackPath (moduleFolder) into moduleHomeStackPath
   
   put the project_Folder of stack moduleName into LocalArray ["projectFolder"]
   put displayView into LocalArray ["displayView"]
   put moduleName into LocalArray ["moduleName"]
   put moduleFolder into LocalArray ["moduleFolder"]
   put moduleHomeStackPath into LocalArray ["moduleHomeStackPath"]
   put projectName into LocalArray ["projectName"]
end _Init

getprop moveModule_Param
   return LocalArray ["projectName"]
end moveModule_Param

getprop moveModule_Params
   return library_ListProjectNames()
end moveModule_Params

-- getprop disabled_AddModuleProject [viewObject]
put the module_Folder of viewObject into moduleFolder
put project_GetHomeStackName (moduleFolder) into moduleName
put library_FetchProjectFolder (moduleName) into moduleFolder
if there is a folder moduleFolder then return "delete"

return false
end disabled_AddModuleProject

private command _refresh
   put LocalArray ["projectName"] into projectName
   display_ProjectModules projectName
end _refresh


--> Global | Modules | Tree | Line | Menu
-
on menu_DisplayModule moduleName
   put LocalArray ["moduleFolder"] into moduleFolder
   display_Module moduleFolder
end menu_DisplayModule

on menu_DisplayModuleTools moduleName
   display_ModuleTools moduleName, true
end menu_DisplayModuleTools

on _
end _

on menu_RenameModule oldModuleName
   put the project_Folder of stack oldModuleName into projectFolder
   put the project_Name of stack oldModuleName into projectName
   put lcw_Ask ("Give this module a new name...", oldModuleName) into newModuleName
   --
   module_Rename oldModuleName, newModuleName, projectName
   --
   display_ProjectLibs projectName
   display_ProjectModules projectName
end menu_RenameModule

on menu_RevealModuleFolder moduleName
   put LocalArray ["moduleFolder"] into moduleFolder
   if moduleFolder is empty then
      answer warning "Module folder is empty!"
      breakpoint
      exit to top
   end if
   
   finder_Reveal moduleFolder
end menu_RevealModuleFolder

on menu_MoveModule moduleName, newProjectName
   set the cursor to watch
   --
   put the stack_Folder of stack moduleName into oldModuleFolder
   put the project_Folder of stack moduleName into oldProjectFolder
   put module_ViewNameToShortFolder (moduleName) into moduleShortFolder
   put library_FetchProjectFolder (newProjectName) into newProjectFolder
   put module_GetFolder (moduleShortFolder, newProjectFolder) into newModuleFolder
   
   -- remove from memory
   module_RemoveFromMemory moduleName, oldProjectFolder
   
   -- move folder
   revMoveFolder oldModuleFolder, newModuleFolder
   
   if the shiftKey is "Up" then
      -- re-index and re-load
      project_ExportMenusAndStackFiles oldProjectFolder
      project_ExportMenusAndStackFiles newProjectFolder
   end if
   
   -- Refresh index views
   put LocalArray ["projectName"] into oldProjectName
   display_ProjectModules oldProjectName
   display_ProjectModules newProjectName   
end menu_MoveModule

on _
end _

on menu_Refresh
   _refresh
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_CloseModuleStacks moduleName
   put LocalArray ["projectFolder"] into projectFolder
   put the project_Folder of stack moduleName into projectFolder
   --
   module_RemoveFromMemory moduleName, projectFolder
end menu_CloseModuleStacks

on menu_DeleteModule moduleName
   project_CloseAndDelete moduleName
   _refresh
end menu_DeleteModule

on _
end _

on menu_AddModuleProject moduleName
   put LocalArray ["moduleFolder"] into moduleFolder
   
   library_StoreProjectFolder moduleName, moduleFolder
   env_SetProjectFolder moduleName, moduleFolder
end menu_AddModuleProject
