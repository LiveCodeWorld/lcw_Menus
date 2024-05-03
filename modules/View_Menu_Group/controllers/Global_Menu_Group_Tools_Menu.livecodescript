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
   --
   put the card_Object of tObject into arrayObject
   put the displayed_RectDataNum [true] of arrayObject into LocalArray ["dRectDataNum"]
   put the displayed_ObjectNames of arrayObject into LocalArray ["objectNames"]
   --
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

on menu_ShowWiki.W  wikiView
   put the card_Object of wikiView into arrayObject
   --
   set the rectArray_AnimateScaled of arrayObject to "Wiki"
end menu_ShowWiki.W

on menu_ShowVideo.D wikiView
   put the card_Object of wikiView into arrayObject
   --
   set the rectArray_AnimateScaled of arrayObject to "Full"
end menu_ShowVideo.D

on menu_ShowThree.T wikiView
   put the card_Object of wikiView into arrayObject
   --
   set the rectArray_AnimateScaled of arrayObject to "Three"
end menu_ShowThree.T

private on ____
end ____

getprop checked_AnimationEngine [wikiView]
   return "animationEngine" is among the lines of the stacksinuse
end checked_AnimationEngine

on menu_AnimationEngine wikiView
   if "animationEngine" is among the lines of the stacksinuse then
      stop using stack "animationEngine"
   else if exists (stack "animationEngine") then
      start using stack "animationEngine"
   else
      lcw_AnswerWarning "Cannot locate stack animationEngine!"
   end if
end menu_AnimationEngine

on menu_ToggleLayout.N wikiView
   put the card_Object of wikiView into arrayObject
   --
   put the displayed_RectDataNum of arrayObject into itemNum
   put the rect_Data of arrayObject into rectData
   put item 2 of the extents of rectData into maxNum
   if the shiftKey is "Down" then
      subtract 1 from itemNum
      if itemNum < 1 then
         put maxNum into itemNum
      end if
   else
      add 1 to itemNum
      if itemNum > maxNum then
         put 1 into itemNum
      end if
   end if
   set the rectArray_AnimateScaled of arrayObject to itemNum
end menu_ToggleLayout.N

on menu_Scale wikiView, sSale
   -- put wikijs_SetPageScale (sSale) into sJavascript
   -- set the browser_Javascript of wikiView to sJavascript
   set the wiki_Scale of wikiView to sSale
end menu_Scale

private on _____
end _____

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

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Tools | Menu")
end submenu_Dev

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

on menu_SaveStack browserView
   put the stack_Name of browserView into stackName
   save stack stackName
end menu_SaveStack

