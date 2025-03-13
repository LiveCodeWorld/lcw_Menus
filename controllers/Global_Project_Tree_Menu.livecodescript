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

getprop disabled_DisplayGitStatus [projectName]
   if env_ProjectIsActive ("lcw_GIT") is true then
      return false
   else
      return true
   end if
end disabled_DisplayGitStatus


--> Global | Project | Tree | Menu
-
on submenu_Git
   return "Global | GIT | Simple | Menu"
end submenu_Git

on menu_StartProject projectName
   put env_ProjectIsActive (projectName) is true into isActive
   if isActive is true then
      project_Stop projectName
   else
      project_Start projectName
   end if
   --
   display_Environment true
end menu_StartProject

private on _
end _

on menu_EditProjectHome projectName
   put env_GetProjectHomePath (projectName) into homeStackPath
   -- put project_GetHomeStackPath (projectName) into homeStackPath
   if exists (stack homeStackPath) is false then
      put homeStackPath
      breakpoint
      exit to top
   end if
   
   go to stack homeStackPath
   --
   put the name of stack homeStackPath into sObject
   display_ObjectProperties sObject
   --
   edit the script of stack homeStackPath
end menu_EditProjectHome

on menu_UpdateProjectArray projectName
   display_ProjectArray projectName, true
end menu_UpdateProjectArray

on menu_RevealProjectFolder projectName
   put the project_Folder of stack projectName into projectFolder
   finder_Reveal projectFolder
end menu_RevealProjectFolder

private on __
end __

on menu_ProjectReadme projectName
   display_ProjectReadme projectName
end menu_ProjectReadme

getprop checked_ProjectReadme [projectName]
   put project_ConstructReadMeFile (projectName) into readMeFile
   return there is a file readMeFile
end checked_ProjectReadme

-- on menu_ProjectHelp projectName
launch_OrCreateProject projectName
 menu_ProjectHelp

on menu_Refresh projectName
   display_Project projectName
end menu_Refresh

on submenu_Dev
   return menu_DevTitle ("Global | Project | Tree | Menu")
end submenu_Dev
