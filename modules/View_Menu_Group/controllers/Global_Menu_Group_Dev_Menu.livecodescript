﻿script "Global | Menu | Group | Dev | Menu"
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
   -- return display_MenuTarget(tObject)
   return the display_View of tObject
end menu_Target

getprop menu_CheckTarget [mTarget]
   return exists (mTarget)
end menu_CheckTarget


--> Global | Menu | Group | Dev | Menu
-
on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

private on _
end _

on menu_ShrinkPage wikiView, pageTitle
   put wikijs_SetPageScale (sSale) into sJavascript
   set the browser_Javascript of wikiView to sJavascript
end menu_ShrinkPage

on menu_FetchDomainMenu wikiView
   put the wiki_Domain of wikiView
end menu_FetchDomainMenu

