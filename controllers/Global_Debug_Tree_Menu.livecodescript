script "Global | Debug | Tree | Menu"
--> MetaData
-
license: GPLv3
name: Global | Debug | Tree | Menu
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


--> Global | Debug | Tree | Menu
-
on menu_Test mTarget, abc
   put mTarget & CR & abc
end menu_Test

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev
