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

getprop checked_SetMenuBar [mGroup]
   put the show_Menu of mGroup into sBoolean
   return sBoolean
end checked_SetMenuBar

getprop checked_EditMenus [mGroup]
   put the stack_Name of mGroup into stackName
   put the editMenus of stack stackName into sBoolean
   return sBoolean
end checked_EditMenus

getprop setMenuTitle_Params [mGroup]
   return the menu_Names of mGroup
end setMenuTitle_Params

getprop editMenuScript_Params [mGroup]
   return the menu_Names of mGroup
end editMenuScript_Params

getprop disabled_EditMenuScript
   return LocalArray ["mMissing"]
end disabled_EditMenuScript

getprop disabled_SetMenuTitle
   return LocalArray ["mMissing"]
end disabled_SetMenuTitle

getprop disabled_SetMenuBar
   return LocalArray ["mMissing"]
end disabled_SetMenuBar

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

private on _
end _

on menu_EditMenuScript mGroup, mName
   put the menu_Title [mName] of mGroup into mTitle
   if mTitle is empty then
      lcw_AnswerWarning "The menu_Title of button '[[mName]]' is empty", mGroup, mName
   end if
   menu_Edit mTitle
end menu_EditMenuScript

on menu_SetMenuTitle mGroup, mName
   put the menu_Title [mName] of mGroup into mTitle
   put lcw_Ask ("Edit menu_Title...", mTitle, "Edit Menu Titles", mGroup) into mTitle
   set the menu_Title [mName] of mGroup to mTitle
end menu_SetMenuTitle

private on __
end __

on menu_EditMenus mGroup
   put the stack_Name of mGroup into stackName
   put the editMenus of stack stackName into sBoolean
   set the editMenus of stack stackName to (sBoolean is false)
end menu_EditMenus

on menu_MenuManagerTools mGroup
   display_MenuManager mGroup
end menu_MenuManagerTools

private on ___
end ___

on menu_MenuGroupBehavior mGroup
   put the behavior of mGroup into bObject
   edit the script of bObject
end menu_MenuGroupBehavior

on menu_MenuGroupTools mGroup
   put the view_Name of mGroup into viewName
   display_ModuleTools viewName
end menu_MenuGroupTools

private on ____
end ____

on menu_SetMenuBar mGroup
   put the show_Menu of mGroup into sBoolean
   set the show_Menu of mGroup to (sBoolean is false)
end menu_SetMenuBar

on menu_PreviewMenu mGroup
   menubar_TogglePreview mGroup
end menu_PreviewMenu

on menu_ResetDefaultMenubar
   ide_ResetDefaultMenubar
end menu_ResetDefaultMenubar

private on _____
end _____

on menu_DeleteMenuGroup mGroup
   put the stack_Name of mGroup into stackName
   save stack stackName
   
   delete mGroup
end menu_DeleteMenuGroup

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Menu")
end submenu_Dev
