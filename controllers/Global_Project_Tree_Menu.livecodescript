script "Global_Project_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Project_Tree_Menu
type: controller
version: 0.2


--> Menu | Props
-
/* mTarget should already be set by set the menu_Target of indexView to projectName */

local LocalArray

on menu_Init tObject
   put the index_View of tObject into indexView
   put indexView into LocalArray ["indexView"]
   put the title_Text of indexView into projectName
   put the git_IsActive of stack projectName into gitIsActive
   put gitIsActive into LocalArray ["gitIsActive"]
end menu_Init

getprop menu_CheckTarget [projectName]
   put projectName & ".wiki" into wikiProjectName
   put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   put wikiFolder into LocalArray ["wikiFolder"]
   return true
end menu_CheckTarget


--> Global | Project | Tree | Menu
-
on menu_StartProject projectName, someBoolean
   if someBoolean is true then
      project_Start projectName
   else
      project_Stop projectName
   end if
end menu_StartProject

on submenu_Init
   return "Global | GIT | Init | Menu"
end submenu_Init

on submenu_Git
   return "Global | GIT | Basics | Menu"
end submenu_Git

on menu_GithubReadme projectName
   put github_FetchReadmeMD (projectName) into readmeMarkdown
   put "Project" && projectName into pageTitle
   put fedwiki_ConvertGitHubReadme (readmeMarkdown, pageTitle) into pageArray
   --
   put json_ToArray (pageArray) into readmeJSON
   --
   display_FedwikiPageJson readmeJSON
end menu_GithubReadme

on _
end _

on menu_ExportMenusAndStackFiles projectName
   put project_GetFolder (projectName) into projectFolder
   project_ExportMenusAndStackFiles projectFolder
   --
   display_RefreshProjectLibs projectName
end menu_ExportMenusAndStackFiles

on menu_ExportAndIndexProject projectName
   env_ExportAndIndexProject projectName
   put the result into hkeyPlaceArray
   display_Array hkeyPlaceArray, "env_ExportAndIndexProject"
end menu_ExportAndIndexProject

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev

on _
end _

on menu_Refresh projectName
   display_RefreshProjectLibs projectName
end menu_Refresh


--> Global | Project | Tree | Menu | Props
-
getprop start_Project [projectName]
   put project_IsActive (projectName) is true into someBoolean
   return someBoolean
end start_Project

getprop home_IsScriptOnly [projectName]
   put project_GetHomeStackPath (projectName) into homeStackPath
   put the scriptonly of stack homeStackPath into someBoolean
   return someBoolean
end home_IsScriptOnly

getprop project_Choice [indexView]
   put menu_GettargetObject() into tObject
   put the index_View of tObject into indexView
   
   put the title_Text of indexView into displayedProjectName
   return displayedProjectName
end project_Choice

getprop project_Choices
   return library_ListProjectNames()
end project_Choices


--> Global | Project | Tree | Menu | Disabled
-
