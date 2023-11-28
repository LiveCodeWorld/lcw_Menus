script "Global | Index | Simple | Dev | Menu"
--> MetaData
-
license: GPLv3
name: Global | Index | Simple | Dev | Menu
type: controller
author: David Bovill
version: 0.1

/*
Here you can describe this menu.
Full help text should be provided on the linked wiki.
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


--> Global | Index | Simple | Dev | Menu
-
on menu_EditLocalMenu indexView
   put the title_View of indexView into titleView
   edit the script of titleView
end menu_EditLocalMenu

on menu_SetStandardBehavior displayView   
   put the view_BehaviorStackName of displayView into stackName
   put the name of stack stackName into bObject
   --
   set the behavior of displayView to bObject
   --
   if there is a stack "behavior_ViewTemplateCard" then
      set the behavior of cd 1 of me to the name of stack "behavior_ViewTemplateCard"
   end if
   
   put the card_Object of displayView into cObject
   put the behavior of cObject into cBehavior
   -- put the name of stack "behavior_ViewTemplateCard" into cBehavior
   set the behavior of cObject to cBehavior
   --
end menu_SetStandardBehavior

private on _
end _

on menu_FindDropCommand indexView
   put the drop_Command of indexView into dropCommand
   put "M" && dropCommand into shortHkey
   --
   put the mouse_Target of indexView into mTarget
   if exists (mTarget) then
      put the found_Hkey [shortHkey] of mTarget into hKey
      hkey_Edit hKey
   else
      lcw_AnswerWarning "Cannot locate [[shortHkey]]", indexView, shortHkey
   end if
end menu_FindDropCommand

on menu_SetDropCommand displayView
   put the drop_Command of displayView into dropCommand
   if dropCommand is empty then put "drop_Wiki" into dropCommand
   put lcw_Ask ("What drop_Command would you like for this view?", dropCommand, displayView) into dCommand
   set the drop_Command of displayView to dCommand
end menu_SetDropCommand

on menu_DisplayMenuArray displayView
   put the script_MenuArray ["Global | Index | Simple | Menu"] of displayView into mArray
   display_Array mArray
end menu_DisplayMenuArray

on menu_EditMouseTarget indexView
   put the mouse_Target of indexView into mTarget
   if exists (mTarget) then
      edit the script of mTarget
   else
      lcw_AnswerWarning "The mouse_Target has not been set for this view", indexView
   end if
end menu_EditMouseTarget

private on ___
end ___

on menu_ShowIndexTemplate displayView   
   put the view_Name of displayView into viewName
   put view_GetTemplateObject (viewName) into templateObject
   --
   object_GoTo templateObject
end menu_ShowIndexTemplate

on menu_Behavior displayView
   put the behavior of displayView into bObject
   edit the script of bObject
end menu_Behavior

private on _
end _

on menu_MenuEdit displayView
   menu_Edit "Global | Index | Simple | Dev | Menu"
end menu_MenuEdit
