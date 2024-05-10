script "Global | Menu | Group | Tools | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Menu | Group | Tools | Dev | Menu
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Menu | Group | Tools | Dev | Menu
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

on menu_FormatMenuButtons wikiView
   put the menubar_View of wikiView into mGroup
   put the menu_Buttons of mGroup into mButtons
   --
   repeat for each line mButton in mButtons
      set the cursor to busy
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

on menu_EditCardScript wikiView
   put the card_Object of wikiView into cardObject
   edit the script of cardObject
end menu_EditCardScript

on menu_EditBehavior wikiView
   put the behavior of wikiView into bObject
   edit the script of bObject
end menu_EditBehavior

on menu_ObeyaStudioTools browserView
   put the view_Name of browserView into viewName
   display_ModuleTools viewName
end menu_ObeyaStudioTools

on menu_StorePositions browserView
   put the card_object of browserView into cardObject
   put the displayed_RectDataNum of cardObject into indexNum
   --
   put the rect_Array of cardObject into rectArray
   put the rect_MetaArray [indexNum] of cardObject into mArray
   put mArray into rectArray ["meta"]
   set the rect_Data [indexNum] of cardObject to rectArray
end menu_StorePositions
   
on menu_SetMenuBar browserView
   put the menubar_View of browserView into mView
   put the show_Menu of mView into sBoolean
   set the show_Menu of mView to (sBoolean is false)
end menu_SetMenuBar

on menu_PreviewMenu browserView
   put the menubar_View of browserView into mView
   menubar_TogglePreview mView
end menu_PreviewMenu

on menu_MenuGroupTools
   put the stack_Folder of stack "View|Menu|Group" into moduleFolder
   put project_PathFromFolder (moduleFolder) into stackPath
   display_ModuleTools stackPath
end menu_MenuGroupTools

private on _
end _

on menu_DisplayWikiTools wikiView
   set the page_Title of wikiView to "Tools"
end menu_DisplayWikiTools

on menu_ShrinkPage wikiView, pageTitle
   put wikijs_SetPageScale (sSale) into sJavascript
   set the browser_Javascript of wikiView to sJavascript
end menu_ShrinkPage

on menu_FetchDomainMenu wikiView
   put the wiki_Domain of wikiView
end menu_FetchDomainMenu
