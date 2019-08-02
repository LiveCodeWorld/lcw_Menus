script "Global_Project_Tree_Menu"
--> MetaData
-
license: GPLv3
name: Global_Project_Tree_Menu
type: controller
version: 0.2


--> Menu | Props
-
/* 
mTarget should already be set by set the menu_Target of indexView to projectName 

The menu is created using a menu_Table
*/

local LocalArray

--> Meu | Props
-
on menu_Init tObject
   put the index_View of tObject into indexView
   put indexView into LocalArray ["indexView"]
   put the title_Text of indexView into projectName
   --
   put library_FetchProjectFolder (projectName) into projectFolder
   put project_GetHomeStackPath (projectName) into homeStackPath
   if homeStackPath is empty then
      put projectFolder & projectName & ".livecode" into homeStackPath
      if exists (stack homeStackPath) is false then
         breakpoint
      end if
   end if
   
   put git_GetCheckoutFolder (homeStackPath) into gitCheckoutFolder
   put there is a folder gitCheckoutFolder into gitIsInitialised
   put git_GetRemoteAddress (projectFolder) into remoteAddress
   
   put projectName into LocalArray ["projectName"]
   put projectFolder into LocalArray ["projectFolder"]
   put remoteAddress into LocalArray ["remoteAddress"]
   put homeStackPath into LocalArray ["homeStackPath"]
   put gitCheckoutFolder into LocalArray ["gitCheckoutFolder"]
   put gitIsInitialised into LocalArray ["gitIsInitialised"]
end menu_Init

getprop disabled_GitStatus [projectName]
   if LocalArray ["gitIsInitialised"] then
      return false
   else
      return true
      return "delete"
   end if
end disabled_GitStatus

getprop disabled_InitialiseGit [projectName]
   if LocalArray ["gitIsInitialised"] then
      return "delete"
   else
      return false
   end if
end disabled_InitialiseGit


--> Git | Menu
-
on menu_InitialiseGit projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   --
   git_InitFolder projectFolder
   --
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   display_GitFolderStatus gitCheckoutFolder
end menu_InitialiseGit

on menu_GitStatus projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   --
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   --
   display_GitFolderStatus gitCheckoutFolder
end menu_GitStatus

on menu_LaunchGithub projectName
   put LocalArray ["remoteAddress"] into remoteAddress
   put github_FindRepoName (remoteAddress) into repoName
   github_Launch repoName
end menu_LaunchGithub


--> Global | Project | Tree | Menu
-
on menu_StartProject projectName, someBoolean
   if someBoolean is true then
      project_Start projectName
   else
      project_Stop projectName
   end if
end menu_StartProject

on insert_Git
   return "Git | Menu"
end insert_Git

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
