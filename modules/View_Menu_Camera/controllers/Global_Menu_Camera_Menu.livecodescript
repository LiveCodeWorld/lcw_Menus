script "Global | Menu | Camera | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menu | Camera | Menu
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
   put the card_Object of dView into cObject
   if exists (group "View|Menu|Camera" of cObject) is false then return empty
   put the long id of group "View|Menu|Camera" of cObject into mGroup
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


--> Global | Menu | Camera | Menu
-
on menu_SetMenuBar mView
   put the show_Menu of mView into sBoolean
   set the show_Menu of mView to (sBoolean is false)
end menu_SetMenuBar

on menu_PreviewMenu mView
   menubar_TogglePreview mView
end menu_PreviewMenu

private on _
end _

on menu_DisplayMenuManager mGroup
   display_MenuManager mGroup
end menu_DisplayMenuManager

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Camera | Menu")
end submenu_Dev
