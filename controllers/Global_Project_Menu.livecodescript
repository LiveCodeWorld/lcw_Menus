script "Global_Project_Menu"
--> MetaData
-
license: GPLv3
name: Global_Project_Menu
type: controller
version: 0.7

--> Variables
-
local LocalArray


--> Display
-
command display_LoadedStacks
   if the optionKey is "Down" then breakpoint
   
   put revLoadedStacks ("application") into stackNames
   sort stackNames
   display_Index stackNames, "Project", "Global | Project | Menu", "Global | Project | Line | Menu", empty, "project_GoToStack"
   put the result into displayView
   
   put project_FetchValue ("openStacks") into stackNames
   set the multiple_Hilites of displayView to true
   set the selected_Index of displayView to stackNames
end display_LoadedStacks

function fedwiki_ConstructMarkdownIndex someLines
   repeat for each line someLine in someLines
      put "* [[" & word 1 to -1 of someLine && "]]" & CR after markdownIndex
   end repeat
   delete char -1 of markdownIndex
   return markdownIndex
end fedwiki_ConstructMarkdownIndex


--> Display | Events
-
command project_GoToStack targetObject, stackName
   if the optionKey is "Down" then breakpoint
   
   if exists (stack stackName) is false then
      put stackName
      project_RemoveOpenStack stackName
      display_LoadedStacks
      answer warning merge ("Cannot locate stack '[[stackName]]'")
      exit to top
   end if
   
   if the scriptonly of stack stackName is true then
      edit the script of stack stackName
   else
      go to stack stackName
   end if
end project_GoToStack

command project_RemoveOpenStack stackNames
   put project_FetchValue ("openStacks") into projectStackNames
   set the wholematches to true
   repeat for each line stackName in stackNames
      put lineoffset (stackName, projectStackNames) into lineNum
      delete line lineNum of projectStackNames
   end repeat
   project_SaveValue "openStacks", projectStackNames
end project_RemoveOpenStack


--> Menu | Props
-
on menu_Init indexView
   set the cursor to watch
   put the stack_Object of indexView into stackObject
   put the label of stackObject into someLabel
   switch someLabel
      case "Projects"
         put the selected_Index of indexView into projectName
         break
      case "Model and Libraries"
         put the title_Text of indexView into projectName
         break
      default
         put someLabel into projectName
   end switch
   put projectName into LocalArray ["projectName"]
end menu_Init


--> Global | Project | Menu
-
on menu_DisplayProjectStacks mTarget, projectChoice
   -- put the project_StackNames of stack projectName into stackNames
   -- display_Index stackNames, "the project_StackNames"
   
   put the index_View of mTarget into indexView
   if exists (indexView) then
      put library_FetchProjectHomeStackPath (projectChoice) into homeStackPath
      put the project_UsedStackNames of stack homeStackPath into stackNames
      
      lock screen
      set the view_Index of indexView to stackNames
      set the title_Text of indexView to projectChoice
      put the stack_Object of indexView into stackObject
      set the label of stackObject to "Model and Libraries"
      unlock screen
   else
      display_ProjectLibs projectChoice
   end if   
end menu_DisplayProjectStacks

on _
end _

on menu_ConstructStackLinkMarkDown mTarget, pName
   put the project_StackObjects of stack pName into projectStackObjects
   put fedwiki_ConstructMarkdownIndex (projectStackObjects) into markdownIndex
   put markdownIndex
end menu_ConstructStackLinkMarkDown

on menu_ConstructScriptArray mTarget, pName
   put the script of stack pName into someScript
   put script_GetSuiteOutline (someScript)
end menu_ConstructScriptArray

on _
end _

on _
end _

on submenu_Important
   return "Global | Project | Important | Menu"
end submenu_Important

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Global | Project | Menu | Props
-
getprop start_Project [indexView]
   put LocalArray ["projectName"] into projectName
   return project_IsActive (projectName) is true
end start_Project

getprop project_Choice [indexView]
   put the title_Text of indexView into displayedProjectName
   return displayedProjectName
end project_Choice

getprop project_Choices
   return library_ListProjectNames() & CR & "-,Active environment"
end project_Choices

getprop p_Name
   return env_GetProjectFocus()
end p_Name

getprop p_Names
   return library_ListProjectNames()
end p_Names

getprop project_StackNames
   put project_FetchValue ("openStacks") into stackNames
   return stackNames
end project_StackNames


--> Global | Project | Menu | Props
-
getprop disabled_GoToStack
   put project_FetchValue ("openStacks") into stackNames
   if stackNames is empty then
      return true
   else
      return false
   end if
end disabled_GoToStack


--> Deps
-
command stack_StripUnsaved @stackNames
   repeat for each line stackName in stackNames
      if exists (stack stackName) is false then next repeat
      if the filename of stack stackName is empty then next repeat
      put stackName & CR after goodStackNames
   end repeat
   delete char -1 of goodStackNames
   sort goodStackNames
   put goodStackNames into stackNames
end stack_StripUnsaved

private command _safeGoProjectStack projectStackName
   if exists (stack projectStackName) then
      go to stack projectStackName
      show stack projectStackName
   else
      answer merge ("Cannot locate stack '[[projectStackName]]'")
      put projectStackName
   end if
end _safeGoProjectStack


--> Dev | Menu
-
on menu_OpenAllProjectStacks
   put project_FetchValue ("openStacks") into stackNames
   repeat for each line projectStackName in stackNames
      _safeGoProjectStack projectStackName
   end repeat
end menu_OpenAllProjectStacks

on menu_SetMultipleHilites mTarget, someBoolean
   set the multiple_Hilites of mTarget to someBoolean
   set the selected_Index of mTarget to empty
end menu_SetMultipleHilites

on menu_TopLevel mTarget, someBoolean
   put the stack_Name of mTarget into stackName
   if someBoolean is true then
      toplevel stack stackName
   else
      palette stack stackName
   end if
end menu_TopLevel

on _
end _

on menu_EditBehavior mTarget
   put the behavior of mTarget into bStackObject
   edit the script of bStackObject
end menu_EditBehavior

on menu_SaveStack mTarget
   put the stack_Name of mTarget into stackName
   save stack stackName
   put merge ("Saved stack '[[stackName]]'") into someMessage
   lcw_Notify someMessage
end menu_SaveStack


--> Dev | Menu | Props
-
getprop set_MultipleHilites [mTarget]
   put the multiple_Hilites of mTarget into someBoolean
   return someBoolean
end set_MultipleHilites

getprop top_Level [mTarget]
   put the stack_Name of mTarget into stackName
   put the mode of stack stackname into someMode
   return someMode is not 4
end top_Level
