script "Global | Menu | Group | Exists | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Group | Exists | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put display_MenuTarget (tObject) into sView
   --
   put the menubar_View of sView into mGroup
   return mGroup
end menu_Target

getprop menu_CheckTarget [mGroup]
   if exists (mGroup) is false then return false
   --
   put the view_Name of mGroup into vName
   return vName = "View|Menu|Group"
end menu_CheckTarget

getprop checked_PreviewMenu
   put menubar_IsDefault() is false into isPreview
   return isPreview
end checked_PreviewMenu

getprop deleteMenuButton_Params [mGroup]
   if exists (mGroup) is false then return true
   --
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   return mButtonNames
end deleteMenuButton_Params


--> Global | Menu | Group | Exists | Menu
-
on menu_DeleteMenuGroup mGroup
   menubar_Delete mGroup
end menu_DeleteMenuGroup

on menu_RefreshLiveMenus.R mGroup
   dispatch "refresh_Menus" to mGroup
end menu_RefreshLiveMenus.R

private on _
end _

on menu_NewMenuButton mGroup
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   put the number of lines of mButtonNames into newNum
   add 1 to newNum
   put "Item" && newNum into newName
   
   # Ask
   put lcw_Ask ("Create a new menu button in this stack menu...", newName, "Creat Menu", mGroup) into newButtonName
   
   # Create
   -- menuBar_CreateButton newButtonName, mGroup
   set the new_MenuButton ["Help"] of mGroup to newButtonName
end menu_NewMenuButton

on menu_DeleteMenuButton mGroup, mName
   lcw_Answer "Delete menu button [[mName]]?", mGroup, mName
   --
   dispatch "menuButton_Delete" to mGroup with mName
end menu_DeleteMenuButton

on menu_SetModuleMenus mGroup
   put the menubar_DefaultTitles of mGroup into moduleMenuTitles
   set the menubar_Titles of mGroup to moduleMenuTitles
end menu_SetModuleMenus

private on __
end __

on menu_EditMenuTitle mGroup, mName
   put the menuButton_Title [mName] of mGroup into mTitle
   put lcw_Ask ("Edit menuButton_Title...", mTitle, "Edit Menu Titles", mGroup) into mTitle
   
   set the menuButton_Title [mName] of mGroup to mTitle
end menu_EditMenuTitle

getprop editMenuTitle_Params [mGroup]   
   put the menuButton_Names of mGroup into mNames
   return mNames
end editMenuTitle_Params

on menu_EditMenuScript mGroup, mName
   if exists (btn mName of mGroup) then
      edit the script of btn mName of mGroup
   else
      breakpoint
   end if
end menu_EditMenuScript

getprop editMenuScript_Params [mGroup]   
   get the menuButton_Names of mGroup
   return it
end editMenuScript_Params

private on ___
end ___

on menu_ShowMenu mGroup
   menuBar_ToggleShowMenu mGroup
end menu_ShowMenu

getprop checked_ShowMenu [mGroup]
   if exists (mGroup) is false then return false -- bug should not be needed
   --
   put the show_Menu of mGroup into sBoolean
   return sBoolean
end checked_ShowMenu

on menu_PreviewMenu mGroup
   menubar_TogglePreview mGroup
end menu_PreviewMenu

private on ____
end ____

on menu_EditMenubarBehavior mGroup
   put the behavior of mGroup into bObject
   edit the script of bObject
end menu_EditMenubarBehavior

on menu_MenuBehavior mGroup, sName
   -- put the behavior_Objects of mGroup -- into bObjects
   -- edit the script of stack sName
   if the behavior_InHierarchy [sName] of mGroup is true then
      set the behavior_Remove of mGroup to sName
   else
      set the behavior_Add of mGroup to sName
   end if
end menu_MenuBehavior

getprop menuBehavior_Param [mGroup]
   return the behavior_StackNames of mGroup
end menuBehavior_Param

getprop menuBehavior_Params [mGroup]
   put the template_Object of mGroup into tObject
   put the module_BehaviorStackNames of tObject into sNames
   return sNames
end menuBehavior_Params

private on _____
end _____

on menu_MenuGroupTools mGroup
   display_ModuleTools "View|Menu|Group"
end menu_MenuGroupTools

on menu_MenuManager mGroup
   display_MenuManager mGroup
end menu_MenuManager

private on ______
end ______

on menu_MenubarTitleData mGroup
   put the stack_Name of mGroup into sName
   display_MenuBarData sName
end menu_MenubarTitleData

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Exists | Menu")
end submenu_Dev
