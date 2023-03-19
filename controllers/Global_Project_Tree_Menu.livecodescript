script "Global | Project | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Tree | Menu
type: controller
target: projectName
version: 0.2


--> Menu | Props
-
/* 
mTarget should already be set by set the menu_Target of displayView to projectName 

The menu is created using a menu_Table
*/

local LocalArray

--> Meu | Props
-
getprop menu_Target [tObject]
   put the display_View of tObject into displayView
   put displayView into LocalArray ["displayView"]
   put the title_Text of displayView into projectName
   return projectName
end menu_Target

getprop checked_StartProject [projectName]
   put env_ProjectIsActive (projectName) is true into someBoolean
   return someBoolean
end checked_StartProject

getprop checked_StartProject [projectName]
   put env_ProjectIsActive (projectName) is true into isActive
   return isActive
end checked_StartProject

getprop checked_ScriptOnly [projectName]
   put the scriptonly of stack projectName into isScriptOnly
   return isScriptOnly
end checked_ScriptOnly

getprop disabled_DisplayGitStatus
   if env_ProjectIsActive ("lcw_GIT") is true then
      return false
   else
      return true
   end if
end disabled_DisplayGitStatus


--> Global | Project | Tree | Menu
-
on menu_StartProject projectName, someBoolean
   if someBoolean is true then
      project_Start projectName
   else
      project_Stop projectName
   end if
end menu_StartProject

on menu_ScriptOnly projectName
   put the scriptonly of stack projectName into isScriptOnly
   set the scriptonly of stack projectName to isScriptOnly is false
end menu_ScriptOnly

on menu_UseProject projectName
   project_UseStackFiles projectName
end menu_UseProject

private on _
end _

on menu_FixProjectStackFiles projectName
   project_FixStackFiles projectName
   put the result into projectArray
   --
   display_Project projectName, true
   display_EnvironmentMenus true
   display_GitRefreshProjectName projectName
end menu_FixProjectStackFiles

on menu_ProjectHelp projectName
   launch_OrCreateProject projectName
end menu_ProjectHelp

on submenu_Git
   return "Global | GIT | Simple | Menu"
end submenu_Git

private on __
end __

on menu_EditProjectHome projectName
   put project_GetHomeStackPath (projectName) into homeStackPath
   go to stack homeStackPath
   --
   edit the script of stack homeStackPath
end menu_EditProjectHome

on menu_RevealProjectFolder projectName
   put the project_Folder of stack projectName into projectFolder
   finder_Reveal projectFolder
end menu_RevealProjectFolder

on menu_Refresh projectName
   display_Project projectName
   dispatch "display_GitRefreshProjectName" with projectName
end menu_Refresh

on _LoadProjectArray projectName
   put the project_Folder of stack projectName into projectFolder
   project_LoadMenusAndStackFiles projectFolder
   put the result into projectArray
   --
   display_Data projectArray, "Project Array", projectName
end _LoadProjectArray

on _ReLoadHome projectName
   put project_GetHomeStackPath (projectName) into homeStackPath
   --
   delete stack homeStackPath
   go to stack homeStackPath
end _ReLoadHome

on _TestControllers projectName
   put LocalArray ["displayView"] into displayView
   put the displayed_Data of displayView into dData
   put dData ["Controllers"] into cData
   --
   repeat for each key stackName in cData
      put the menu_GlobalTitle of stack stackName into gMenuTitle
      if gMenuTitle is empty then
         put stackName & CR after badStackNames
      end if
   end repeat
   sort badStackNames
   --
   display_Data badStackNames, "Bad Controllers", projectName
   put the result into dView
end _TestControllers

