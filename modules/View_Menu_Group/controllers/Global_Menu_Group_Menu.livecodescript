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
   put the display_View of tObject into dView
   if exists (dView) then
      put the displayed_Object of dView into dObject
      if exists (dObject) then
         return the card_Object of dObject
      end if
   end if
   return the card_Object of tObject
end menu_Target


--> Global | Menu | Group | Menu
-
on menu_InsertMenuGroup cardObject
   lcw_Answer "Sure you want to create a menubar view on this card?", cardObject
   --
   lock screen
   view_InsertFromPath "View|Menu|Group", cardObject
   put the result into mGroup
   set the topleft of mGroup to 0,0
   unlock screen
   --
   set the show_Menu [true] of mGroup to true
   dispatch "Init_MenuBar" to mGroup
end menu_InsertMenuGroup

getprop disabled_InsertMenuGroup [cardObject]
   put the menuBar_View of cardObject into mGroup
   if exists (mGroup) then return true
   
   put the top_View ["View|Menu|Group"] of cardObject into mGroup
   return exists (mGroup)
end disabled_InsertMenuGroup

private on _
end _

on insert_Exists
   return "Global | Menu | Group | Exists | Menu"
end insert_Exists

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Menu")
end submenu_Dev
