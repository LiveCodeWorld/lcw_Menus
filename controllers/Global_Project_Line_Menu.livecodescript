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

private function _Disabled shortFolder, sName
   if shortFolder is not sName then
      return "delete"
   else
      return false
   end if
end _Disabled

getprop disabled_Library [shortFolder]
   return _Disabled (shortFolder, "Libraries")
end disabled_Library

getprop disabled_Controller [shortFolder]
   return _Disabled (shortFolder, "Controllers")
end disabled_Controller

getprop disabled_Module [shortFolder]
   return _Disabled (shortFolder, "Modules")
end disabled_Module

getprop disabled_Model [shortFolder]
   return _Disabled (shortFolder, "Models")
end disabled_Model

getprop disabled_View [shortFolder]
   return _Disabled (shortFolder, "Views")
end disabled_View

getprop disabled_Behavior [shortFolder]
   return _Disabled (shortFolder, "Behaviors")
end disabled_Behavior


--> Global | Project | Line | Menu
-
on insert_Controller
   return _GetNewMenu ("Controllers")
end insert_Controller

on insert_Library
   return _GetNewMenu ("Lib")
end insert_Library

on insert_Model
   return _GetNewMenu ("Model")
end insert_Model

on insert_Module
   return _GetNewMenu ("Module")
end insert_Module

on insert_View
   return _GetNewMenu ("View")
end insert_View

on insert_Behavior
   return _GetNewMenu ("Behavior")
end insert_Behavior

private command _
end _

-- on submenu_ModuleTools
return "Global | Modules | Tree | Line | Menu"
end submenu_ModuleTools

on menu_GoAndShow
   put _GetStackName() into stackName
   go to stack stackName
   show stack stackName
   --
   menu_BringHere
end menu_GoAndShow

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
