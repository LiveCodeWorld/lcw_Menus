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
   -- put display_MenuTarget (tObject) into sView
   put the displayed_Object of tObject into sView
   if exists (sView) is false then
      put the card_Object of tObject into cardObject
   else
      put the card_Object of sView into cardObject
   end if
   --
   put the menubar_View of cardObject into mGroup
   return mGroup
end menu_Target

getprop menu_CheckTarget [mGroup]
   if exists (mGroup) is false then return false
   --
   put the the behavior_StackNames of mGroup into LocalArray ["behavior_StackNames"]
   --
   put the view_Name of mGroup into mName -- "View|Menu|Group" 
   put module_ListBehaviorStackNames (mName) into LocalArray ["mBehavioStackNames"]
   --
   return mName begins with "View|Menu|"
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

on menu_RefreshLiveMenus mGroup
   dispatch "refresh_Menus" to mGroup
end menu_RefreshLiveMenus

private on _
end _

on menu_NewMenuButton mGroup
   put "Global | TiddlyWiki | Plugins | Menu" into newName
   
   # Ask
   put lcw_Ask ("Create a new menu button in this stack menu...", newName, "Creat Menu", mGroup) into newButtonName
   
   # Create before Help
   set the new_MenuButton ["Help"] of mGroup to newButtonName
   put the result into mButton
   
   # Set Title
   set the menuButton_Title of mButton to newButtonName
end menu_NewMenuButton

on menu_DeleteMenuButton mGroup, mName
   lcw_Answer "Delete menu button [[mName]]?", mGroup, mName
   --
   dispatch "menuButton_Delete" to mGroup with mName
end menu_DeleteMenuButton

on menu_SetModuleMenus mGroup
   put the menubar_DefaultTitles of mGroup into mTitles
   -- put lcw_Ask ("Set the menubar_Titles of this module to...", mTitles, mGroup) into mTitles
   lcw_Answer "Set the menubar_Titles of this module to [[mTitles]]?", mGroup, mTitles
   --
   set the menubar_Titles of mGroup to mTitles
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

on menu_EditMenubarBehavior mGroup, sName
   -- put the behavior of mGroup into bObject
   edit the script of stack sName
end menu_EditMenubarBehavior

getprop editMenubarBehavior_Params [mGroup]
   return LocalArray ["mBehavioStackNames"]
end editMenubarBehavior_Params

on menu_MenuBehavior mGroup, sName
   if the behavior_InHierarchy [sName] of mGroup is true then
      set the behavior_Remove of mGroup to sName
      lcw_Notify "Removed behavior!"
   else
      set the behavior_Add of mGroup to sName
      lcw_Notify "Added behavior!"
   end if
end menu_MenuBehavior

getprop menuBehavior_Param [mGroup]
   return LocalArray ["behavior_StackNames"]
end menuBehavior_Param

getprop menuBehavior_Params [mGroup]
   return LocalArray ["mBehavioStackNames"]
end menuBehavior_Params

on menu_AllMenubarBehaviors mGroup
   put the view_Name of mGroup into mName -- put "View|Menu|Group"
   --
   if _AllChecked(mGroup) is true then
      put the stack_Name of mGroup into sName
      lcw_Answer "Clear all behaviors of the menubar of stack [[var]]?", mGroup, sName
      --
      module_ClearDefaultBehaviors mGroup
      --
      lcw_Notify "Cleared all behaviors!"
   else
      put merge ("Set the behaviors of the menubar to all the module_Behaviors of '[[mName]]'?") into sQuestion
      lcw_Answer sQuestion, mGroup
      
      set the behavior_Hierarchy of mGroup to "default"
      --
      put "!" into char -1 of sQuestion
      lcw_Notify sQuestion
   end if
end menu_AllMenubarBehaviors

getprop checked_AllMenubarBehaviors [mGroup]
   return _AllChecked(mGroup)
end checked_AllMenubarBehaviors

private function _AllChecked mGroup
   put the module_DefaultHierarchy of mGroup into moduleBehaviors
   delete line 1 of moduleBehaviors
   get the behavior_Objects of mGroup
   return moduleBehaviors = it
end _AllChecked

private on _____
end _____

on menu_MenuGroupTools mGroup
   display_ModuleTools "View|Menu|Group"
end menu_MenuGroupTools

on menu_MenuManager mGroup
   display_MenuManager mGroup
end menu_MenuManager

on menu_MenuGroupProperties mGroup
   display_ObjectProperties mGroup
end menu_MenuGroupProperties

private on ______
end ______

on menu_MenubarTitleData mGroup
   display_MenuBarData mGroup
end menu_MenubarTitleData

on menu_LayoutMenuButtons mGroup
   dispatch "LayoutControl" to mGroup
   switch the result
      breakpoint
end switch
end menu_LayoutMenuButtons

on menu_TestAddButton mGroup
   menuButton_Add mGroup, "Global | Guide | Menu", 1
end menu_TestAddButton

on menu_MenubarTable mGroup
   put _TestMenuTitles() into mTitles
   put the menubar_Table [mTitles] of mGroup
end menu_MenubarTable

function _TestMenuTitles
   return "TiddlyWiki,Global | Caddy | Menu,Plugins"
end _TestMenuTitles

on menu_SetTiddlyTitles mGroup
   set the menubar_Titles of mGroup to _TestMenuTitles()
end menu_SetTiddlyTitles

on menu_ClearTiddlyTitles mGroup
   set the menubar_Titles of mGroup to empty
end menu_ClearTiddlyTitles

on menu_StoreInitData mGroup
   put the view_Name of mGroup into mName
   put module_ListBehaviorStackNames (mName) into mBehavioStackNames
   --
   module_ClearBehaviors mName
   set the view_BehaviorStackNames of mGroup to mBehavioStackNames
end menu_StoreInitData

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Exists | Menu")
end submenu_Dev
