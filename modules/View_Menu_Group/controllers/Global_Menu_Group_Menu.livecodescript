script "Global | Menu | Group | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Group | Menu
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
   put tObject into LocalArray ["tObject"]
   --
   put display_MenuTarget (tObject) into dView
   if exists (dView) then
      put the menubar_View of dView into mGroup
   else
      put the menubar_View of tObject into mGroup
   end if
   
   if exists (mGroup) is true then
      put false into LocalArray ["mMissing"]
   else
      put "delete" into LocalArray ["mMissing"]
   end if
   return mGroup
end menu_Target

getprop checked_PreviewMenu
   put menubar_IsDefault() is false into isPreview
   return isPreview
end checked_PreviewMenu

getprop checked_ToggleMenu [mGroup]
   put the show_Menu of mGroup into sBoolean
   return sBoolean
end checked_ToggleMenu

getprop checked_ToggleEditMenus [mGroup]
   put the stack_Name of mGroup into stackName
   put the editMenus of stack stackName into sBoolean
   return sBoolean
end checked_ToggleEditMenus

getprop setMenuTitle_Params [mGroup]
   return the menuButton_Names of mGroup
end setMenuTitle_Params

getprop editMenuScript_Params [mGroup]
   return the menuButton_Names of mGroup
end editMenuScript_Params

getprop disabled_EditMenuScript
   return LocalArray ["mMissing"]
end disabled_EditMenuScript

getprop disabled_SetMenuTitle
   return LocalArray ["mMissing"]
end disabled_SetMenuTitle

getprop disabled_PreviewMenu
   return LocalArray ["mMissing"]
end disabled_PreviewMenu

getprop disabled_EditMenus
   return LocalArray ["mMissing"]
end disabled_EditMenus

getprop disabled_MenuManagerTools
   return LocalArray ["mMissing"]
end disabled_MenuManagerTools

getprop disabled_MenuGroupBehavior
   return LocalArray ["mMissing"]
end disabled_MenuGroupBehavior

getprop disabled_MenuGroupTools
   return LocalArray ["mMissing"]
end disabled_MenuGroupTools

getprop disabled_ResetDefaultMenubar
   return LocalArray ["mMissing"]
end disabled_ResetDefaultMenubar

-- getprop menu_CheckTarget [mGroup]
menu_CheckTarget

getprop disabled_InsertMenuGroup
   if LocalArray ["mMissing"] is false then
      return "delete"
   else
      return false
   end if
end disabled_InsertMenuGroup

getprop disabled_DeleteMenuGroup
   if LocalArray ["mMissing"] is false then
      return false
   else
      return "delete"
   end if
end disabled_DeleteMenuGroup

getprop deleteMenuButton_Params [mGroup]
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   return mButtonNames
end deleteMenuButton_Params


--> Global | Menu | Group | Menu
-
on menu_InsertMenuGroup
   put LocalArray ["tObject"] into tObject
   put display_MenuTarget (tObject) into dView
   put the card_Object of dView into cardObject
   
   view_InsertFromPath "View|Menu|Group", cardObject
   put the result into mGroup
   set the topleft of mGroup to 0,0
end menu_InsertMenuGroup

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

-- on menu_NewMenuItem mGroup
put menuBar_ManagerCard() into menuManagerCard
dispatch "revNewMenuItem" to menuManagerCard
end menu_NewMenuItem

private on _
end _

on menu_SetMenuTitle mGroup, mName
   put the menu_Title [mName] of mGroup into mTitle
   put lcw_Ask ("Edit menu_Title...", mTitle, "Edit Menu Titles", mGroup) into mTitle
   
   -- set the menu_Title [mName] of mGroup to mTitle
   set the menuButton_Title [mName] of mGroup to mTitle
end menu_SetMenuTitle

on menu_EditMenuScript mGroup, mName
   put the menu_Title [mName] of mGroup into mTitle
   if mTitle is empty then
      lcw_AnswerWarning "The menu_Title of button '[[mName]]' is empty", mGroup, mName
   end if
   menu_Edit mTitle
end menu_EditMenuScript

private on __
end __

on menu_ToggleMenu mGroup
   menuBar_ToggleShowMenu mGroup
end menu_ToggleMenu

on menu_ToggleEditMenus mGroup
   menuBar_ToggleEditMenus mGroup
end menu_ToggleEditMenus

on menu_PreviewMenu mGroup
   menubar_TogglePreview mGroup
end menu_PreviewMenu

on menu_ResetDefaultMenubar
   ide_ResetDefaultMenubar
end menu_ResetDefaultMenubar

private on ___
end ___

on menu_ReorderMenus mGroup
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   replace CR with comma in mButtonNames
   
   # Ask
   put lcw_Ask ("Reorder these menu names...", mButtonNames, "Creat Menu", mGroup) into newButtonNames
   
   set the menuBar_ButtonNames of mGroup to newButtonNames
end menu_ReorderMenus

on menu_LayoutMenuButtons mGroup
   dispatch "LayoutControls" to mGroup
   -- menuBar_RelayerMenuButtons mGroup
end menu_LayoutMenuButtons

private on ____
end ____

on menu_MenuManagerTools mGroup
   display_MenuManager mGroup
end menu_MenuManagerTools

on menu_MenuGroupBehavior mGroup
   put the behavior of mGroup into bObject
   edit the script of bObject
end menu_MenuGroupBehavior

on menu_MenuGroupTools mGroup
   put the view_Name of mGroup into viewName
   display_ModuleTools viewName
end menu_MenuGroupTools

private on _____
end _____

on menu_DisplayMenubarData mGroup
   put the menubar_Data of mGroup into mBarData
   --
   put the stack_Name of mGroup into stackName
   display_Data mBarData, stackName, "Menubar Dat"
end menu_DisplayMenubarData

on menu_DisplayMenuArray dView
   display_ActiveMenuArray
end menu_DisplayMenuArray

on menu_DeleteMenuGroup mGroup
   put the stack_Name of mGroup into stackName
   save stack stackName
   --
   delete mGroup
end menu_DeleteMenuGroup

private on ______
end ______

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Menu")
end submenu_Dev
