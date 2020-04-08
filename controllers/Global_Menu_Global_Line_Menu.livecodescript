script "Global | Menu | Global | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Global | Line | Menu
type: controller
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
*/

--> Variables
-
local LocalArray


--> Menu | Init
-
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

getprop menu_Target [tObject]
   put the selected_Line of tObject into gMenuTitle
   return gMenuTitle
end menu_Target


--> Global | Menu | Global | Line | Menu
-
on menu_FixBadController gMenuTitle
   put menu_GetTargetObject() into tObject
   put the display_View of tObject into displayView
   --
   -- put the selected_Value of displayView into sValue
   put the displayed_Array of displayView into dArray
   put the top_Array of displayView into tArray
   put tArray ["mController"] into badMenuController
   --
   put file_Choose() into newStackPath
   put the long id of stack newStackPath into mController
   -- 
   put the script_MenuTitleTableArray of mController into mTitleTableArray
   menu_UpdateGlobalArray mController, mTitleTableArray
   put the result into menuTitleArray
   put menu_GetGlobalArray() into gMenuArray
   --
   put revRuggedId (mController) into ruggedController
   put ruggedController into dArray [gMenuTitle]["mController"]
   --
   set the displayed_Array of displayView to dArray
   put display_FindView ("Global Menus", "From Disk") into gDisplayView
   if exists (gDisplayView) then
      set the displayed_Array of gDisplayView to gMenuArray
   end if
   --
   lcw_AnswerWarning "Updated gMenuArray and diplay views"
end menu_FixBadController

on _
end _

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_EditBehavior gMenuTitle
   -- put the target into tObject -- this is the menuButton
   put menu_GetTargetObject() into tObject
   put the display_View of tObject into displayView
   --
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_EditBehavior


--> Deps
-
