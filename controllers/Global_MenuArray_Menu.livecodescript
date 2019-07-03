script "Global_MenuArray_Menu"
--> MetaData
-
license: GPLv3
name: Global_MenuArray_Menu
type: controller
version: 0.1


--> Global | MenuArray | Menu
-
on menu_Test displayView
   put the mArray_Controller of displayView into mArrayController
   put keys (mArrayController)
end menu_Test

on _
end _

on menu_Step displayView
   put the mArray_Controller of displayView into mController
   --
   put the script_MenuArray of mController into mArrayController
   display_Array mArrayController
end menu_Step


--> Global | MenuArray | Menu | Props
-

--> Global | MenuArray | Menu | Disabled
-
