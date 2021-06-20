script "Global | Controllers | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Controllers | Tree | Menu
type: controller
target: projectName
version: 0.2


--> Menu | Props
-
local LocalArray

getprop menu_Target [tObject]
   -- this is called first
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   if exists (displayView) is false then return empty
   --
   put the title_Text of displayView into projectName
   return projectName
end menu_Target

getprop menu_CheckTarget [projectName]
   put project_Exists (projectName) into isOK
   return isOK
end menu_CheckTarget


--> Global | Controllers | Tree | Menu
-
on menu_CreateProjectMenu projectName
   display_AskCreateMenu projectName
   put the result into controllerStackObject
   --
   display_ProjectControllers projectName
   --
   edit the script of controllerStackObject
end menu_CreateProjectMenu

on _
end _

on menu_TestControllers projectName
   put project_IsActive (projectName) into isActive
   if isActive is false then
      lcw_AnswerWarning "Project is not active!"
   end if
   
   display_ProjectControllers projectName
   put the result into indexView
   put the displayed_Index of indexView into mControlerNames
   --
   repeat for each line mControlerName in mControlerNames
      display_Spin mControlerName, indexView
      put the result into lineNum
      wait 10 ticks
      --
      -- could get from path (lazy for now and assuming the project is active)
      if there is not a stack mControlerName then
         set the line_Colour [lineNum] of indexView to "red"
         next repeat
      end if
      
      put the script_MetaData of stack mControlerName into metaDataArray
      if metaDataArray is not an array then
         set the line_Colour [lineNum] of indexView to "dark red"
         next repeat
      end if
      
      switch metaDataArray ["type"]
         case "controller"
            set the line_Colour [lineNum] of indexView to "green"
            break
         case "menu"
            set the line_Colour [lineNum] of indexView to "yellow"
            break
         default
            set the line_Colour [lineNum] of indexView to "orange"
      end switch
   end repeat
end menu_TestControllers

on menu_SaveDisplayedStacks
   put LocalArray ["displayView"] into displayView
   --
   put the displayed_Index of displayView into gMenuTitles
   stack_SaveEdited gMenuTitles, displayView, "green"
   put the result into couldntSaveNames
   --
   if couldntSaveNames is not empty then
      set the coloured_Lines ["red"] of displayView to couldntSaveNames
      lcw_AnswerWarning "Could not save these menu stacks!", displayView
   end if
end menu_SaveDisplayedstacks

on menu_ExportMenusAndStackFiles projectName
   put LocalArray ["displayView"] into displayView
   --
   put project_ListPathSortedControllerNames (projectName) into sortedMenuTitles
   set the displayed_Index of displayView to sortedMenuTitles
   --
   put project_GetFolder (projectName) into projectFolder
   project_ExportMenusAndStackFiles  projectFolder, displayView, true
end menu_ExportMenusAndStackFiles

on _
end _

on menu_RevealControllerFolder projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   put project_GetFolder (projectName) into projectFolder
   put project_ConstructFolder ("controllers", projectFolder) into controllerFolder
   --
   finder_Reveal controllerFolder
end menu_RevealControllerFolder

on menu_Refresh projectName
   set the cursor to watch
   display_ProjectControllers projectName
end menu_Refresh

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
getprop disabled_SaveDisplayedstacks [projectName]
   put LocalArray ["displayView"] into displayView
   if exists (displayView) then
      return false
   else
      return true
   end if
end disabled_SaveDisplayedstacks

on _
end _

on menu_OldLoadMenus projectName
   put project_GetFolder (projectName) into projectFolder
   project_LoadMenus projectFolder, true
end menu_OldLoadMenus

on menu_OldLoadMenusAndStackFiles projectName
   put project_GetFolder (projectName) into projectFolder
   project_LoadMenusAndStackFiles projectFolder
end menu_OldLoadMenusAndStackFiles


