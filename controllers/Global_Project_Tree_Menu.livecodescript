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
   put the index_View of tObject into LocalArray ["indexView"]
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

on menu_GitStatus projectName
   display_GitProjectStatus projectName
end menu_GitStatus

on menu_AddProjectWiki projectName
   put projectName & ".wiki" into wikiProjectName
   
   answer folder "Select a folder containing a project..."
   put it into projectFolder
   if it is empty then exit to top
   if projectFolder ends with ".wiki" is false then
      answer warning "Not a GitHub wiki project"
      exit to top
   end if
   
   put projectFolder into projectArray ["projectFolder"]
   put "wiki" into projectArray ["projectType"]
   library_StoreProjectArray wikiProjectName, projectArray
   
   display_LcwProjectList
end menu_AddProjectWiki

on menu_CreateLibraryPages projectName
   -- put projectName & ".wiki" into wikiProjectName
   -- put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   put LocalArray ["wikiFolder"] into wikiFolder
   put LocalArray ["indexView"] into indexView
   put the view_Index of indexView into stackNames
   repeat for each line stackName in stackNames
      put wikiFolder & stackName & ".md" into wikiPageFile
      if there is a file wikiPageFile then
         breakpoint
      else
         put the github_WikiPage of stack stackName into wikiMarkdown
         put "file:" & wikiPageFile into someURL
         put wikiMarkdown into url someURL
      end if
   end repeat
end menu_CreateLibraryPages

on _
end _

on menu_GoToHomeStack homeStackName
   put library_FetchProjectHomeStackPath (homeStackName) into homeStackPath
   if exists (stack homeStackPath) is false then breakpoint
   
   go to stack homeStackPath
end menu_GoToHomeStack

on menu_EditHomeStackScript homeStackName
   put library_FetchProjectHomeStackPath (homeStackName) into homeStackPath
   if exists (stack homeStackPath) is false then breakpoint
   
   edit the script of stack homeStackPath
end menu_EditHomeStackScript

on menu_HomeIsScriptOnly projectName, someBoolean
   if someBoolean is false then
      put project_GetHomeStackPath (projectName) into homeStackPath
      stack_ConvertScriptOnly homeStackPath
      put the result into tempStackFileName
      
      answer warning "Saved old script only home stack to temporary file, and created new livecode stack in it's place. Check everything is saved you need before continuing!"
      put tempStackFileName
      put tempStackFileName into tempFolder
      set the itemdelimiter to slash
      put empty into item -1 of tempFolder
      finder_Reveal tempFolder
   else
      -- don't automatically change to scriptonly stack. Do manually ?
      breakpoint
   end if
end menu_HomeIsScriptOnly

on menu_InspectHomeStack homeStackName
   put library_FetchProjectHomeStackPath (homeStackName) into homeStackPath
   if exists (stack homeStackPath) is false then breakpoint
   
   put the name of stack homeStackPath into stackObject
   object_Inspect stackObject
end menu_InspectHomeStack

on menu_ExportStandaloneSettings homeStackName
   put "cRevStandaloneSettings" into setName
   put the name of stack homeStackName into homeStackObject
   
   put the customproperties [setName] of homeStackObject into customArray
   -- display_Array customArray
   
   set the project_Array of homeStackObject to  customArray
   -- custom_DeleteSet setName, homeStackObject
   put the project_Array of homeStackObject into customArray
   display_Array customArray
end menu_ExportStandaloneSettings

on _
end _

on menu_SetHomeStackfiles homeStackName
   put the stack_Folder of stack homeStackName into projectFolder
   project_SetFoundStackFiles projectFolder
   
   menu_DisplayHomeStackFiles homeStackName
end menu_SetHomeStackfiles

on menu_DisplayHomeStackFiles homeStackName
   put the stackFile_Array of stack homeStackName into stackFileArray
   put the name of stack homeStackName into stackObject
   display_Array stackFileArray, merge ("[[stackObject]],stackFile_Array")
end menu_DisplayHomeStackFiles

on menu_ExportHomeStackFiles homeStackName
   put the stackfiles of stack homeStackName into homeStackFiles
   put homeStackFiles
end menu_ExportHomeStackFiles

on _
end _

on menu_ChangeProject projectName, projectChoice
   put library_FetchProjectHomeStackPath (projectChoice) into homeStackPath
   put the project_UsedStackNames of stack homeStackPath into stackNames
   
   lock screen
   put menu_GettargetObject() into tObject
   put the index_View of tObject into indexView
   
   set the view_Index of indexView to stackNames
   set the title_Text of indexView to projectChoice
   put the stack_Object of indexView into stackObject
   set the label of stackObject to "Model and Libraries"
   unlock screen
end menu_ChangeProject

on _
end _

on menu_DisplayProjectFolder homeStackName
   put the project_Folder of stack homeStackName into projectFolder
   if there is not a folder projectFolder then
      answer warning "Cannot find project folder!"
      put projectFolder
      exit to top
   end if
   
   finder_Reveal projectFolder
end menu_DisplayProjectFolder

on menu_ExportAndIndexProject projectName
   put merge ("Do you want to export and index project '[[projectName]]'?") into someComment
   lcw_Answer someComment
   
   -- project_ExportAndIndex projectName, true
   
   env_ExportAndIndexProject projectName
   put the result into hkeyPlaceArray
   display_Array hkeyPlaceArray
end menu_ExportAndIndexProject

on _
end _

on menu_Refresh homeStackName
   display_RefreshProjectLibs homeStackName
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
getprop disabled_AddProjectWiki [projectName]
   -- put projectName & ".wiki" into wikiProjectName
   -- put library_FetchProjectFolder (wikiProjectName) into wikiFolder
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return "delete"
   else
      return false
   end if
end disabled_AddProjectWiki

getprop disabled_CreateLibraryPages [projectName]
   put LocalArray ["wikiFolder"] into wikiFolder
   if there is a folder wikiFolder then
      return false
   else
      return true
   end if
end disabled_CreateLibraryPages
