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
   put the browser_View of tObject into browserView
   --
   -- put the card_Object of tObject into arrayObject
   -- put the displayed_RectDataNum [true] of arrayObject into LocalArray ["dRectDataNum"]
   -- put the displayed_ObjectNames of arrayObject into LocalArray ["objectNames"]
   --
   return browserView
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

private function _MenuButtonNames wikiView
   put the menubar_View of wikiView into mBar
   if exists (mBar) then
      return the menuButton_Names of mBar
   else
      breakpoint
      return empty
   end if
end _MenuButtonNames

getprop setMenuTitle_Params [wikiView]
   return _MenuButtonNames (wikiView)
end setMenuTitle_Params

getprop shrinkPage_Params [wikiView]
   put the lineUp_Titles of wikiView into pageTitles
   return pageTitles
end shrinkPage_Params


--> Global | Menu | Group | Tools | Dev | Menu
-
on menu_BrowserProps browserView
   display_ObjectProperties browserView
end menu_BrowserProps

on menu_StackProps browserView
   put the stack_Object of browserView into sObject
   display_ObjectProperties sObject
end menu_StackProps
   
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

private on _
end _

on menu_EditCardScript wikiView
   put the card_Object of wikiView into cardObject
   edit the script of cardObject
end menu_EditCardScript

on menu_EditCardBehavior wikiView
   put the card_Object of wikiView into cardObject
   put the behavior of cardObject into bObject
   edit the script of bObject
end menu_EditCardBehavior

on menu_EditBehavior wikiView
   put the behavior of wikiView into bObject
   edit the script of bObject
end menu_EditBehavior

private on __
end __

on menu_DisplayRectData browserView
   put the card_object of browserView into cardObject
   --
   display_RectData cardObject
end menu_DisplayRectData

on menu_StorePositions browserView
   put the card_object of browserView into cardObject
   put the displayed_RectDataNum of cardObject into indexNum
   --
   put the rect_Array of cardObject into rectArray
   put the rect_MetaArray [indexNum] of cardObject into mArray
   put mArray into rectArray ["meta"]
   set the rect_Data [indexNum] of cardObject to rectArray
end menu_StorePositions

private on ___
end ___

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

private on ____
end ____

on menu_ObeyaStudioTools browserView
   put the view_Name of browserView into viewName
   display_ModuleTools viewName
end menu_ObeyaStudioTools

on menu_DisplayWikiTools wikiView
   set the page_Title of wikiView to "Tools"
end menu_DisplayWikiTools

on menu_ShrinkPage wikiView, pageTitle
   put fedwiki_ConstructSlug (pageTitle) into pageSlug
   --
   put wikijs_SetPageScale (0.3, pageSlug) into sJavascript
   set the browser_Javascript of wikiView to sJavascript
end menu_ShrinkPage

on menu_FetchDomainMenu wikiView
   put the wiki_Domain of wikiView
end menu_FetchDomainMenu
