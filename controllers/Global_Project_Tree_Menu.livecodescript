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

on menu_Init tObject
   put the index_View of tObject into indexView
   put indexView into LocalArray ["indexView"]
   put the title_Text of indexView into projectName
end menu_Init


--> Global | Project | Tree | Menu
-
on menu_Test
   put LocalArray ["indexView"] into indexView
   put the title_Menu of indexView into mTitle
   
   put the menu_Table [mTitle] of indexView into mTable
   put the menu_Titles of indexView into mTitles
   --
   put mTable
end menu_Test

on menu_StartProject projectName, someBoolean
   if someBoolean is true then
      project_Start projectName
   else
      project_Stop projectName
   end if
end menu_StartProject

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
