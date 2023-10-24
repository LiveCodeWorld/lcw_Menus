script "Global | Project | Tree | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Tree | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target


--> Global | Project | Tree | Dev | Menu
-
on menu_ForgetProjectStacks projectName
   project_RemoveStacksFromMemory projectName
end menu_ForgetProjectStacks

on menu_ScriptOnly projectName
   put the scriptonly of stack projectName into isScriptOnly
   set the scriptonly of stack projectName to isScriptOnly is false
end menu_ScriptOnly

on menu_UseProject projectName
   project_UseStackFiles projectName
end menu_UseProject

private command _
end _

on menu_LoadProjectArray projectName
   put the project_Folder of stack projectName into projectFolder
   project_LoadMenusAndStackFiles projectFolder
   put the result into projectArray
   --
   display_Data projectArray, "Project Array", projectName
end menu_LoadProjectArray

on menu_ReLoadHome projectName
   put project_GetHomeStackPath (projectName) into homeStackPath
   --
   delete stack homeStackPath
   go to stack homeStackPath
end menu_ReLoadHome

on menu_TestControllers projectName
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
end menu_TestControllers


