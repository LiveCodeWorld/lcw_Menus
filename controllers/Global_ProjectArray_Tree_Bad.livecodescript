﻿script "Global | ProjectArray | Tree | Bad"
--> MetaData
-
license: GPLv3
name: Global | ProjectArray | Tree | Bad
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
on menu_Init tObject   
   -- do something when the menu first loads
end menu_Init

getprop test_Param [mTarget]
  return "b"
end test_Param

getprop test_Params [mTarget]
   return "a,b,c"
end test_Params


--> Global | ProjectArray | Tree | Bad
-
on menu_Test mTarget, abc
   put mTarget & CR & abc
end menu_Test

on submenu_Dev
   return "Dev | Menu"
end submenu_Dev


--> Dev | Menu
-
on menu_Experiment mTarget
   put mTarget
end menu_Experiment


--> Deps
-
