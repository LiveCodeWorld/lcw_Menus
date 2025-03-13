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

getprop menu_Target [tObject]
   put the top_Line of tObject into shortFolder
   --
   put the title_Text of tObject into LocalArray ["oProjectName"]
   put the display_View of tObject into LocalArray ["displayView"]
   --
   return shortFolder
end menu_Target

on mDoubleUp_ProjectTree displayView, shortFile
   if the optionkey is "Down" then breakpoint
   --
   put the selected_Path of displayView into sPath
   put _StackPath (displayView, sPath) into sFile
   --
   set the itemDelimiter to "."
   put item -1 of sFile into fExt
   set the itemDelimiter to comma
   
   switch
      case fExt = "json"
         display_JsonFile sFile
         put the result into dView
      case shortFile = "README.html"
         display_TiddlyFile sFile
         break
      case item 1 of sPath = "Modules"
         put shortFile into stackName
         --
         display_ModuleTools stackName
         
         show stack stackName
         toplevel stack stackName
         
         if the shiftKey is "Down" then
            put the name of stack stackName into sObject
            display_StackDeps sObject
         end if
         break
      default
         if exists (stack sFile) is false then
            lcw_AnswerWarning "Stack does not exist!", displayView
         end if
         
         if the scriptonly of stack sFile is true then
            edit the script of stack sFile 
         else
            show stack sFile
            toplevel stack sFile
         end if
   end switch
end mDoubleUp_ProjectTree

private function _StackPath displayView, sPath
   put the title_Text of displayView into projectName
   replace comma with slash in sPath
   put project_GetFolder (projectName) into projectFolder
   put projectFolder & sPath into stackPath
   return stackPath
end _StackPath

private function _GetStackName
   breakpoint
   
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

private on _
end _

on menu_Edit
   edit the script of me
end menu_Edit
