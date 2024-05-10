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

getprop checked_FlagEvent [wikiView]
   get the flag_Handler of wikiView
   if it = "default" then
      return true
   else
      return true
   end if
end checked_FlagEvent


--> Global | Menu | Group | Tools | Menu
-
on menu_FlagEvent wikiView
   set the flag_Handler of wikiView to "default"
end menu_FlagEvent

on menu_Footer wikiView
   put the footer_IsVisible of wikiView into sBoolean
   set the footer_IsVisible of wikiView to (sBoolean is false)
end menu_Footer

on menu_BrowserVisible wikiView
   put the visible of wikiView into isVisible
   set the visible of wikiView to (isVisible is false)
end menu_BrowserVisible

on menu_ShowTerminal browserView
   put "radar" into shortPluginName
   --
   put the other_Browser of browserView into oBrowser
   put "cd $(npm prefix -g); npm i wiki-plugin-" & shortPluginName into sShellCommand
   --
   display_Xterm oBrowser, sShellCommand
end menu_ShowTerminal

on menu_ShowChatGpt browserView
   put the other_Browser of browserView into oBrowser
   set the browser_URL of oBrowser to "https://auth0.openai.com/authorize?client_id=TdJIcbe16WoTHtN95nyywh5E4yOo6ItG&scope=openid%20email%20profile%20offline_access%20model.request%20model.read%20organization.read%20organization.write&response_type=code&redirect_uri=https%3A%2F%2Fchat.openai.com%2Fapi%2Fauth%2Fcallback%2Fauth0&audience=https%3A%2F%2Fapi.openai.com%2Fv1&state=TCb84sVofxommgO0nGSP6XeL_hIdIIvaeXtgt26fiD4&code_challenge=N28l-klMH55P8456l89bQgkMxADesMuYms3VYIyCECQ&code_challenge_method=S256"
end menu_ShowChatGpt

on menu_ShowAsana browserView
   put the other_Browser of browserView into oBrowser
   set the browser_URL of oBrowser to "https://app.asana.com/0/1206580415766932/1206580454304519"
end menu_ShowAsana

private on _
end _

on menu_SaveStack browserView
   put the stack_Name of browserView into stackName
   save stack stackName
end menu_SaveStack

private on __
end __

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

on submenu_Dev
   return menu_DevTitle ("Global | Menu | Group | Tools | Menu")
end submenu_Dev
