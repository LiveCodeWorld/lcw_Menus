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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop checked_PreviewMenu
   put ide_DefaultMenubar() is false into isPreview
   return isPreview
end checked_PreviewMenu


--> Global | Menu | Camera | Menu
-
on menu_MenuManagerTools displayView
   go to stack "revMenuManager"
end menu_MenuManagerTools

on menu_PreviewMenu displayView
   put ide_DefaultMenubar() into isDefault
   put isDefault
   if isDefault is false then
      put menuManager_MenuGroup() into mGroup
      put the short name of mGroup into mGroupName
      --
      set the defaultMenuBar to mGroupName
   else
      ide_ResetDefaultmenubar
   end if
end menu_PreviewMenu

private on _
end _

on menu_TestMenuManager displayView
   put the name of stack revMenuManager into stackObject
   clone stack revMenuManager as "Test MenuManager"
   toplevel stack "Test MenuManager"
   --
   edit the script of card "Menu Manager" of stack "Test MenuManager"
   --
   put the name of stack "Test MenuManager" into stackObject
   display_ObjectProperties stackObject
end menu_TestMenuManager

on menu_DeleteTest displayView
   delete stack "Test MenuManager"
end menu_DeleteTest

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Camera | Menu")
end submenu_Dev
