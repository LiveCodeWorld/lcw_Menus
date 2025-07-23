script "Global | MenuArray | Menu"
--> MetaData
-
license: GPLv3
name: Global | MenuArray | Menu
type: controller
version: 0.1


--> Global | MenuArray | Menu
-
on menu_Test dView
   put the mArray_Controller of dView into mArrayController
end menu_Test

on _
end _

on menu_ScriptMenuArray dView
   put the mArray_Controller of dView into mController
   --
   put the script_MenuArray of mController into mArray
   display_Array mArray
end menu_ScriptMenuArray
