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
on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

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
