script "Global | Menubar | Data | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Menubar | Data | Menu
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
   put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Menubar | Data | Menu
-
on menu_MenubarData dView
   put the displayed_Object of dView into mGroup
   put the menubar_TableData of mGroup into menubarData
   --
   put keys (menubarData)
end menu_MenubarData

private on _
end _

on menu_DisplayNameArray dView
   put the displayed_Data of dView into indexArray
   -- put the view_Data of dView into indexArray
   set the view_Data of dView to indexArray
end menu_DisplayNameArray

on menu_Refresh dView
   put the displayed_Object of dView into viewObject
   put the title_Text of viewObject into sName
   put the stack_Name of viewObject into sName
   --
   display_MenuBarData sName, dView
end menu_Refresh

private on __
end __

on submenu_Dev
   return menu_DevTitle ("Global | Menubar | Data | Menu")
end submenu_Dev
