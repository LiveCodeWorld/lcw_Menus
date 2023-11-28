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
   return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop checked_PreviewMenu
   put ide_DefaultMenubar() is false into isPreview
   return isPreview
end checked_PreviewMenu

getprop checked_Set [mView]
   put the stack_Name of mView into sName
   put the menubar of stack sName into mName
   return mNameis empty
end checked_Set


--> Global | Menu | Camera | Menu
-
on menu_Test mView
   put the long id of button "Camera" of mView into mButton
   set the menu_Title of mButton to "Global | Camera | Tools | Menu"
end menu_Test

on menu_MenuManagerTools mView
   put the stack_Name of mView into sName
   put the id of mView into menuID
   --
   put the menubar of stack sName into mName
   --   
   set the cREVMenuID of stack "revMenuManager" to menuID
   set the cREVDefaultStack of stack "revMenuManager" to sName
   set the cREVMenubar of stack "revMenuManager" to mName
   
   go to stack "revMenuManager"
   dispatch "revEditMenubar" to card "Menu Manager" of stack "revMenuManager"
end menu_MenuManagerTools

on menu_Set mView
   put the stack_Name of mView into sName
   put the menubar of stack sName into aName
   --
   if aName is empty then
      put the short name of mView into mName
      set the menubar of stack sName to mName
   else
      set the menubar of stack sName to empty
   end if
end menu_Set

on menu_PreviewMenu mView
   put ide_DefaultMenubar() into isDefault
   --
   put the stack_Name of mView into sName
   put the id of mView into menuID
   put the short name of mView into mName
   
   -- put menuManager_MenuGroup() into mGroup
   -- put the cREVDefaultStack of this stack into sName
   -- put the cREVMenuID of this stack into menuID
   -- put the short name of bg id menuID of stack sName into mName
   
   --
   if isDefault is true then
      set the menubar of stack sName to mName
      set the defaultMenuBar to mName
   else
      set the menubar of stack sName to empty
      ide_ResetDefaultmenubar
   end if
end menu_PreviewMenu

private on _
end _

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Camera | Menu")
end submenu_Dev
