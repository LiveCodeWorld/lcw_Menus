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
   return browserView
end menu_Target

private function _MenuButtonNames wikiView
   put the menubar_View of wikiView into mBar
   if exists (mBar) then
      return the menu_Names of mBar
   else
      breakpoint
      return empty
   end if
end _MenuButtonNames

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

getprop setMenuTitle_Params [wikiView]
   return _MenuButtonNames (wikiView)
end setMenuTitle_Params

getprop menuButtonInspector_Params [wikiView]
   return _MenuButtonNames (wikiView)
end menuButtonInspector_Params

getprop scale_Params
   return "0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,-,1,-,1.5"
end scale_Params

getprop shrinkPage_Params [wikiView]
   return the lineup_Titles of wikiView
end shrinkPage_Params

getprop updateToolsMenu_Params [wikiView]
   return _MenuButtonNames (wikiView)
end updateToolsMenu_Params


--> Global | Menu | Group | Tools | Menu
-
on menu_UpdateToolsMenu wikiView, mName
   if mName is empty then put "Tools" into mName
   
   put the menubar_View of wikiView into menubarView
   put the long id of btn mName of menubarView into mButton
   --
   mArray_ClearActiveMenuArray
   put the live_MenuArray of mButton into mArray
   mArray_SetActiveArray mArray -- so we can use live menus
   
   # Set text of mButton
   if mArray is an array then
      put mArray_ToText (mArray) into mText
      set the text of mButton to mText
   end if 
end menu_UpdateToolsMenu

private on _
end _

on menu_SetMenuTitle wikiView, mName
   put the menubar_View of wikiView into mBar
   --
   put the menu_Title [mName] of mBar into mTitle
   put lcw_Ask ("Edit menu_Title...", mTitle, "Edit Menu Titles", wikiView) into mTitle
   set the menu_Title [mName] of mBar to mTitle
end menu_SetMenuTitle

on menu_MenuButtonInspector wikiView, mName
   put the menubar_View of wikiView into menubarView
   put the long id of button mName of menubarView into mButton
   display_ObjectProperties mButton
end menu_MenuButtonInspector

private on __
end __

on menu_Footer wikiView
   put the footer_IsVisible of wikiView into sBoolean
   set the footer_IsVisible of wikiView to (sBoolean is false)
end menu_Footer

on menu_BrowserVisible wikiView
   put the visible of wikiView into isVisible
   set the visible of wikiView to (isVisible is false)
end menu_BrowserVisible

private on ___
end ___

on menu_Scale wikiView, sSale
   -- put wikijs_SetPageScale (sSale) into sJavascript
   -- set the browser_Javascript of wikiView to sJavascript
   set the wiki_Scale of wikiView to sSale
end menu_Scale

private on ____
end ____

on menu_EditBehavior wikiView
   put the behavior of wikiView into bObject
   edit the script of bObject
end menu_EditBehavior

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Tools | Menu")
end submenu_Dev
