script "Global | Menu | Group | Tools | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Group | Tools | Menu
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
   put the browser_View of tObject into browserView
   --
   put the card_Object of tObject into arrayObject
   put the displayed_RectDataNum [true] of arrayObject into LocalArray ["dRectDataNum"]
   put the displayed_ObjectNames of arrayObject into LocalArray ["objectNames"]
   --
   return browserView
end menu_Target


/*
getprop disabled_EditMode
   if LocalArray ["footer_IsVisible"] is true then
      return false
   else
      return true
   end if
end disabled_EditMode

getprop checked_Footer [wikiView]
   -- return LocalArray ["footer_IsVisible"]
   return the footer_IsVisible of wikiView
end checked_Footer

getprop checked_BrowserVisible [wikiView]
   put the visible of wikiView into isVisible
   return isVisible
end checked_BrowserVisible

getprop checked_SetMenuBar [wikiView]
   put the show_Menu of wikiView into sBoolean
   return sBoolean
end checked_SetMenuBar

getprop scale_Params
   return "0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,-,1,-,1.5"
end scale_Params

getprop shrinkPage_Params [wikiView]
   return the lineup_Titles of wikiView
end shrinkPage_Params

getprop updateToolsMenu_Params [wikiView]
   return _MenuButtonNames (wikiView)
end updateToolsMenu_Params

getprop checked_FlagEvent [wikiView]
   get the flag_Handler of wikiView
   if it = "default" then
      return true
   else
      return true
   end if
end checked_FlagEvent

getprop checked_AnimationEngine [wikiView]
   return "animationEngine" is among the lines of the stacksinuse
end checked_AnimationEngine

-- on submenu_Three
return "Global | Obeya | Studio | Three | Menu"
end submenu_Three
*/

getprop disabled_RefreshLiveMenus [viewObject]
   put the menuBar_View of viewObject into mGroup
   return exists (mGroup) is false
end disabled_RefreshLiveMenus

getprop disabled_StandardMenus [viewObject]
   put the menuBar_View of viewObject into mGroup
   return exists (mGroup) is false
end disabled_StandardMenus


--> Global | Menu | Group | Tools | Menu
-
on menu_SetFileMenu viewObject
   put the menuBar_View of viewObject into mGroup
   --
   -- set the ide_MenuScript ["File"] of mGroup to "default"
   set the menu_Titles of mGroup to "rev"
end menu_SetFileMenu

on menu_StandardMenus viewObject
   put the menuBar_View of viewObject into mGroup
   --
   set the ide_MenuScript ["File"] of mGroup to "default"
   -- set the create_MenuTitles of mGroup to "default"
end menu_StandardMenus

private on _
end _

on menu_RefreshLiveMenus.R viewObject
   put the menuBar_View of viewObject into mGroup
   dispatch "refresh_Menus" to mGroup
end menu_RefreshLiveMenus.R

on menu_SaveStack viewObject
   put the stack_Name of viewObject into stackName
   save stack stackName
end menu_SaveStack

private on __
end __

on menu_FlagEvent wikiView
   set the flag_Handler of wikiView to "default"
end menu_FlagEvent

-- on submenu_Tools
   get menu_DevTitle ("Global | Menu | Group | Tools | Menu")
   return it
end submenu_Tools
