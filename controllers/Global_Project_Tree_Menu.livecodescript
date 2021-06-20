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
mTarget should already be set by set the menu_Target of indexView to projectName 

The menu is created using a menu_Table
*/

local LocalArray

--> Meu | Props
-
getprop menu_Target [tObject]
   put the index_View of tObject into indexView
   put the title_Text of indexView into projectName
   return projectName
end menu_Target

on menu_Init tObject
   -- simplify
   put the index_View of tObject into indexView
   put indexView into LocalArray ["indexView"]
   put the title_Text of indexView into projectName
   --
   put env_ConstructProjectFolder (projectName) into projectFolder
   --
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

getprop editMenu_Params [projectName]
   put project_DisplayMenuTitles (projectName) into titleMenuTable
   set the itemdelimiter to tab
   repeat for each line someLine in titleMenuTable
      put item 1 of someLine into mTitle
      put mTitle & CR after mTitles
   end repeat
   delete char -1 of mTitles
   replace "|" with "-" in mTitles
   return mTitles
end editMenu_Params

getprop startProject_Param [projectName]
   put project_IsActive (projectName) is true into someBoolean
   return someBoolean
end startProject_Param

getprop startProject_Params
   return "true,false"
end startProject_Params

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
   --
   project_ExportMenusAndStackFiles projectFolder
   put the result into projectArray
   -- display_Data projectArray, projectName, "Project Array"
   --
   display_ProjectLibs projectName
   display_GitRefreshProjectName projectName
end menu_ExportMenusAndStackFiles

on menu_ExportAndIndexProject projectName
   env_ExportAndIndexProject projectName
   put the result into hkeyPlaceArray
   display_Array hkeyPlaceArray, "env_ExportAndIndexProject"
end menu_ExportAndIndexProject

on menu_DisplayGitStatus projectName
   display_GitProjectStatus projectName
end menu_DisplayGitStatus

on _
end _

on menu_DisplayProjectArray projectName
   put the project_Array of stack projectName into projectArray
   --
   display_Array projectArray
end menu_DisplayProjectArray

on menu_OpenProjectHome projectName
   go to stack projectName
   show stack projectName
end menu_OpenProjectHome

on menu_EditMenu projectName, mTitle
   replace "-" with "|" in mTitle
   --
   menu_Edit mTitle
end menu_EditMenu
on menu_Refresh projectName
   display_ProjectLibs projectName
   display_GitRefreshProjectName projectName
end menu_Refresh


--> Git | Menu
-
on menu_InitialiseGit projectName
   put env_ConstructProjectFolder (projectName) into projectFolder
   --
   git_InitFolder projectFolder
   --
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   display_GitFolderStatus gitCheckoutFolder
end menu_InitialiseGit

on menu_GitStatus projectName
   put env_ConstructProjectFolder (projectName) into projectFolder
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
