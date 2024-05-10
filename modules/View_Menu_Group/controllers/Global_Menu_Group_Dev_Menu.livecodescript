script "Global | Menu | Group | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Group | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this developer menu.
Full help text should be provided on the linked wiki.

Consider improving by creating with same menu_Target as no-developer menu is is based on.
*/

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


--> Global | Menu | Group | Dev | Menu
-
on menu_DisplayIdeMenubar
   put ide_DefaultMenubar() into defaultMenuBarGroup
   object_GoTo defaultMenuBarGroup, treu 
end menu_DisplayIdeMenubar

on menu_FormatMenuButtons mGroup
   put the menu_Buttons of mGroup into mButtons
   repeat ofr each line mButton in mButtons
      _SetMenuButtonDefaults mButton
   end repeat
end menu_FormatMenuButtons
