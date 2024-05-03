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
   put display_MenuTarget(tObject) into dView
   if exists (dView) is false then return empty
   put the menubar_View of dView into mGroup
   return mGroup
end menu_Target

getprop menu_CheckTarget [mGroup]
   return exists (mGroup)
end menu_CheckTarget

getprop checked_PreviewMenu
   put menubar_IsDefault() is false into isPreview
   return isPreview
end checked_PreviewMenu

getprop checked_SetMenuBar [mGroup]
   put the show_Menu of mGroup into sBoolean
   return sBoolean
end checked_SetMenuBar

getprop checked_EditMenus [mView]
   put the stack_Name of mView into stackName
   put the editMenus of stack stackName into sBoolean
   return sBoolean
end checked_EditMenus

getprop setMenuTitle_Params [mView]
   return the menu_Names of mView
end setMenuTitle_Params

getprop editMenuScript_Params [mView]
   return the menu_Names of mView
end editMenuScript_Params


--> Global | Menu | Group | Menu
-
on menu_EditMenuScript mView, mName
   put the menu_Title [mName] of mView into mTitle
   if mTitle is empty then
      lcw_AnswerWarning "The menu_Title of button '[[mName]]' is empty", mView, mName
   end if
   menu_Edit mTitle
end menu_EditMenuScript

on menu_SetMenuTitle mView, mName
   put the menu_Title [mName] of mView into mTitle
   put lcw_Ask ("Edit menu_Title...", mTitle, "Edit Menu Titles", mView) into mTitle
   set the menu_Title [mName] of mView to mTitle
end menu_SetMenuTitle

on menu_SetMenuBar mView
   put the show_Menu of mView into sBoolean
   set the show_Menu of mView to (sBoolean is false)
end menu_SetMenuBar

on menu_PreviewMenu mView
   menubar_TogglePreview mView
end menu_PreviewMenu

private on _
end _

on menu_EditMenus mView
   put the stack_Name of mView into stackName
   put the editMenus of stack stackName into sBoolean
   set the editMenus of stack stackName to (sBoolean is false)
end menu_EditMenus

on menu_MenuManagerTools mGroup
   display_MenuManager mGroup
end menu_MenuManagerTools

private on __
end __

on menu_MenuGroupBehavior mGroup
   put the behavior of mGroup into bObject
   edit the script of bObject
end menu_MenuGroupBehavior

on menu_MenuGroupTools mGroup
   put the view_Name of mGroup into viewName
   display_ModuleTools viewName
end menu_MenuGroupTools

private on ___
end ___

on menu_DisplayIdeMenubar
   put ide_DefaultMenubar() into defaultMenuBarGroup
   object_GoTo defaultMenuBarGroup, treu 
end menu_DisplayIdeMenubar

on menu_ResetDefaultMenubar
   ide_ResetDefaultMenubar
end menu_ResetDefaultMenubar

on menu_FormatMenuButtons mGroup
   put the menu_Buttons of mGroup into mButtons
   repeat ofr each line mButton in mButtons
      _SetMenuButtonDefaults mButton
   end repeat
end menu_FormatMenuButtons

private command _SetMenuButtonDefaults mButton
   set the showname of mButton to true
   set the style of mButton to "transparent"
   set the threed of mButton to false
   set the borderwidth of mButton to 0
   set the blendlevel of mButton to 0
   set the margins of mButton to "4,0,4,1"
   set the traversalOn of mButton to false
   set the autoHilite of mButton to false
end _SetMenuButtonDefaults

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Menu")
end submenu_Dev
