script "Global | Project | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Project | Line | Menu
type: controller
target: stackObject
version: 0.2


--> Menu | Init
-
local LocalArray

on menu_Init tObject
   put the title_Text of tObject into oProjectName
   put oProjectName into LocalArray ["oProjectName"]
   --
   put the display_View of tObject into LocalArray ["displayView"]
end menu_Init

getprop menu_Target [tObject]
   put the top_Line of tObject into shortFolder
   return shortFolder
end menu_Target

private function _GetStackName
   put LocalArray ["displayView"] into displayView
   -- put the selected_Line of displayView into stackName
   put the selected_Path of displayView into sPath
   put item 2 of sPath into stackName
   return stackName
end _GetStackName

private function _GetNewMenu menuBit
   put the long id of me into myController
   put merge ("Global | Project | [[menuBit]] | Line | Menu") into gMenuTitle
   return gMenuTitle
end _GetNewMenu

getprop disabled_Library [shortFolder]
   return shortFolder is not "Libraries"
end disabled_Library

getprop disabled_Controller [shortFolder]
   return shortFolder is not "Controllers"
end disabled_Controller

getprop disabled_Module [shortFolder]
   return shortFolder is not "Modules"
end disabled_Module

getprop disabled_Model [shortFolder]
   return shortFolder is not "Models"
end disabled_Model

getprop disabled_View [shortFolder]
   return shortFolder is not "Views"
end disabled_View

getprop disabled_Behavior [shortFolder]
   return shortFolder is not "Behaviors"
end disabled_Behavior


--> Global | Project | Line | Menu
-
on submenu_Controller
   return _GetNewMenu ("Controllers")
end submenu_Controller

on submenu_Library
   return _GetNewMenu ("Lib")
end submenu_Library

on submenu_Model
   return _GetNewMenu ("Model")
end submenu_Model

on submenu_Module
   return _GetNewMenu ("Module")
end submenu_Module

on submenu_View
   return _GetNewMenu ("View")
end submenu_View

on submenu_Behavior
   return _GetNewMenu ("Behavior")
end submenu_Behavior

on _
end _

-- on submenu_ModuleTools
return "Global | Modules | Tree | Line | Menu"
end submenu_ModuleTools

on menu_BringHere
   put LocalArray ["displayView"] into displayView
   put the stack_Name of displayView into dStackName
   put _GetStackName() into stackName
   --
   put the mouseloc into gLoc
   put the right of stack dStackName into dRight
   put dRight into item 1 of gLoc
   --
   set the topleft of stack stackName to gLoc
end menu_BringHere

on menu_Go
   put _GetStackName() into stackName
   go to stack stackName
   show stack stackName
   --
   menu_BringHere
end menu_Go
