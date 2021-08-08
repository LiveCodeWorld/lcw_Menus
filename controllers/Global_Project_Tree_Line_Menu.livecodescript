script "Global | Project | Tree | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Tree | Line | Menu
type: controller
version: 0.2


--> Init
-
local LocalArray

on menu_Init tObject
   put the display_View of tObject into displayView
   
   put the title_Text of displayView into projectName
   if projectName = "List of projects" then
      put "LCW" into projectName
   end if
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


--> Menu | Props
-
getprop convertToModule_Param [displayView]
   put the selected_Index of displayView into stackName
   put the project_Name of stack stackName into projectName
   return projectName
end convertToModule_Param

getprop convertToModule_Params
   return library_ListProjectNames()
end convertToModule_Params

getprop startProject_Param [displayView]
   put the selected_Index of displayView into projectName
   put env_ProjectIsActive (projectName) into isActive
   return isActive
end startProject_Param

getprop startProject_Params
   return "true,false"
end startProject_Params

getprop disabled_ConvertToModule [displayView]
   put the title_Text of displayView into displayedTitle
   switch displayedTitle
      case "Active Views"
         return false
      default
         return "delete"
   end switch
end disabled_ConvertToModule

getprop disabled_MoveUsed [displayView]
   put the title_Text of displayView into displayedTitle
   switch displayedTitle
      case "Active Libraries"
         return false
      default
         return "delete"
   end switch
end disabled_MoveUsed

getprop disabled_GitStatus [displayView]
   if LocalArray ["gitIsInitialised"] then
      return false
   else
      return true
      return "delete"
   end if
end disabled_GitStatus

getprop disabled_InitialiseGit [displayView]
   if LocalArray ["gitIsInitialised"] then
      return "delete"
   else
      return false
   end if
end disabled_InitialiseGit

getprop disabled_AddEverythingToGit [displayView]
   if LocalArray ["gitIsInitialised"] then
      return false
   else
      return true
      return "delete"
   end if
end disabled_AddEverythingToGit

getprop disabled_LaunchGithub [displayView]
   if LocalArray ["remoteAddress"] is empty then
      return true
      return "delete"
   else
      return false
   end if
end disabled_LaunchGithub
   
getprop disabled_DisplayGithubInfo [displayView]
   if LocalArray ["remoteAddress"] is empty then
      return true
      return "delete"
   else
      return false
   end if
end disabled_DisplayGithubInfo

getprop disabled_FixRemote [displayView]
   if LocalArray ["gitIsInitialised"] then
      return false
   else
      return true
      return "delete"
   end if
end disabled_FixRemote

getprop disabled_StartProject [displayView]
   put the title_Text of displayView into listType
   if listType contains "Projects" then
      return false
   else
      return "delete"
   end if
end disabled_StartProject


--> Git | Menu
-
on menu_InitialiseGit displayView
   put LocalArray ["projectFolder"] into projectFolder
   git_InitFolder projectFolder
   
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   display_GitFolderStatus gitCheckoutFolder
end menu_InitialiseGit

on menu_GitStatus displayView
   put the selected_Index of displayView into projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   
   display_GitFolderStatus gitCheckoutFolder
end menu_GitStatus

on menu_LaunchGithub
   put LocalArray ["remoteAddress"] into remoteAddress
   put github_FindRepoName (remoteAddress) into repoName
   github_Launch repoName
end menu_LaunchGithub

on menu_GithubReadme displayView
   put the selected_Index of displayView into projectName
   --
   put github_FetchReadmeMD (projectName) into readmeMarkdown
   put "Project" && projectName into pageTitle
   put fedwiki_ConvertGitHubReadme (readmeMarkdown, pageTitle) into pageArray
   put json_FromArray (pageArray) into readmeJSON
   --
   display_FedwikiPageJson readmeJSON
end menu_GithubReadme

on menu_DisplayGithubInfo
   put LocalArray ["remoteAddress"] into remoteAddress
   put github_FindRepoName (remoteAddress) into repoName
   display_GitHubInfo repoName
end menu_DisplayGithubInfo


--> Global | Project | Tree | Line | Menu
-
on menu_DisplayProject displayView
   put the selected_Index of displayView into projectName
   display_ProjectLibs projectName
end menu_DisplayProject

on _
end _

on menu_StoreProjectFolder displayView
   put the selected_Index of displayView into projectName
   --
   put merge ("Choose the project folder that contains the stack [[projectName]]...") into someQuestion
   put the env_RepoFolder of stack "LCW" into repoFolder
   answer folder someQuestion with repoFolder as sheet
   put it into projectFolder
   --
   library_StoreProjectFolder projectName, projectFolder
end menu_StoreProjectFolder

on menu_RevealProjectFolder displayView
   put the selected_Index of displayView into projectName
   put project_GetFolder (projectName) into projectFolder
   finder_Reveal projectFolder
end menu_RevealProjectFolder

on menu_RemoveProjectFromLibrary displayView
   put the selected_Index of displayView into projectName
   answer warning merge ("Are you sure you want to remove the project '[[projectName]]' from the project library?") with "Cancel" or "OK"
   if it is "Cancel" then exit to top
   
   library_DeleteProjectArray projectName
   
   put library_ListProjectNames() into projectNames
   set the view_Index ["List of Projects"] of displayView to projectNames
end menu_RemoveProjectFromLibrary

on _
end _

on menu_TrashProject displayView
   put the selected_Index of displayView into projectName
   answer warning merge ("Are you sure you want to close project '[[projectName]]' and move all files to the trash?") with "Cancel" or "OK"
   if it is "Cancel" then exit to top
   
   project_Trash projectName
end menu_TrashProject

on _
end _

on menu_StartProject displayView, someBoolean
   put the selected_Index of displayView into projectName
   if someBoolean is true then
      project_Start projectName, true
   else
      project_Stop projectName
   end if
end menu_StartProject

on _
end _

on menu_ExportMenusAndStackFiles displayView
   put the selected_Index of displayView into projectName
   put library_FetchProjectFolder (projectName) into projectFolder
   -- put project_GetFolder (projectName) into projectFolder
   
   project_ExportMenusAndStackFiles projectFolder
end menu_ExportMenusAndStackFiles

on menu_ExportAndIndexProject displayView
   put the selected_Index of displayView into projectName
   -- put library_FetchProjectFolder (projectName) into projectFolder
   -- put project_GetFolder (projectName) into projectFolder
   
   env_ExportAndIndexProject projectName
   put the result into hkeyPlaceArray
   display_Array hkeyPlaceArray, "env_ExportAndIndexProject"
end menu_ExportAndIndexProject

on _
end _

on submenu_Git
   return "Git | Menu"
end submenu_Git

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_MoveUsed displayView, newProjectName
   put the selected_Index of displayView into stackName
   put the name of stack stackName into stackObject
   
   put the project_Name of stackObject into oProjectName
   if oProjectName = newProjectName then
      answer warning merge ("Stack is already in project '[[newProjectName]]'. Choose a new project to move this library to!")
      exit to top
   end if
   
   put the short name of stackObject into stackName
   project_MoveStackRelative stackName, newProjectName
   
   lcw_Notify merge ("Moved library to new project '[[newProjectName]]'!")
   
   breakpoint
   -- refreshDisplay newProjectName
   menu_DoGlobal "menu_DisplayActive", "Global | Project | Line | Menu", displayView, "libraries"
end menu_MoveUsed

on menu_ConvertToModule displayView, newProjectName
   put the selected_Index of displayView into moduleStackName
   if exists (stack moduleStackName) is false then
      breakpoint
      exit to top
   end if
   
   put the filename of stack moduleStackName into oStackPath
   -- put the module_Folder [newProjectName] of stack moduleStackName into moduleFolder
   put project_GetFolder (newProjectName) into projectFolder
   put folder_AddShort (projectFolder, "modules") into rootModuleFolder
   
   project_CreateModule moduleStackName, rootModuleFolder, oStackPath
end menu_ConvertToModule

on menu_GoToHomeStack displayView
   put the selected_Index of displayView into projectName
   put library_FetchProjectHomeStackPath (projectName) into homeStackPath
   if exists (stack homeStackPath) is false then breakpoint
   
   go to stack homeStackPath
end menu_GoToHomeStack

on menu_EditStackScript displayView
   put the selected_Index of displayView into projectName
   put library_FetchProjectHomeStackPath (projectName) into homeStackPath
   if exists (stack homeStackPath) is false then breakpoint
   
   edit the script of stack homeStackPath
end menu_EditStackScript

on _
end _

on menu_FixRemote displayView
   put LocalArray ["remoteAddress"] into projectFolder
   put lcw_Ask ("Enter git remote address...", "git@github.com:LiveCodeWorld/lcw.git")into gitRemoteAddress
   git_SetRemoteOrigin gitRemoteAddress, projectFolder
   put the result
end menu_FixRemote

on menu_AddEverythingToGit displayView
   put the selected_Index of displayView into gitProjectName
   put library_FetchProjectFolder (gitProjectName) into projectFolder
   put git_GetCheckoutFolder (projectFolder) into gitCheckoutFolder
   
   breakpoint
   git_AddEverything gitCheckoutFolder
   put the result into shellResult
   
   display_GitFolderStatus gitCheckoutFolder
end menu_AddEverythingToGit


--> Deps
-
private command refreshDisplay projectName
   lock screen
   put LocalArray ["displayView"] into displayView   
   put project_ListUsedStackNames (projectName) into usedStackNames
   set the view_Index of displayView to usedStackNames
   set the title_Text of displayView to projectName
   unlock screen
end refreshDisplay
