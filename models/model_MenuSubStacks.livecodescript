script "model_MenuSubStacks"
--> MetaData
-
license: GPLv3
name: model_MenuSubStacks
type: model
version: 0.2

/*

*/


--> Variables
-
constant LcwSubStackName = "LCW Stack Menus" -- was "OPN Stack Menus"


--> Working on
-
getprop menu_FindController [mTitle]
   -- optional utility to do clever searchigng when updating menus using menu_Update
   put the long id of the target into tObject
   
   -- look for menu_SubStackCard's for any menus with the same mTitle
   put the menu_SubStackCard [mTitle] of tObject into mController
   if exists (mController) then return mController
   
   -- search script hieararchy for menu
   put the script_Hierarchy of tObject into scriptHierarchy
   repeat for each line mController in scriptHierarchy
      put the script of mController into mControllerScript
      put "-->" && mTitle into mTitleLine
      if mTitleLine is among the lines of mControllerScript then
         return mController
      end if
   end repeat
   return empty
end menu_FindController


--> Menu | Sub Stacks
-
/*
Menu sub-stacks allow you to separate out menus onto their own sel-contained cards,
without haivng to go to create a Global menu.

These are used by "menu_TableLineFromScript"
*/

getprop menu_SubStackCard [mTitle]
   -- used by menu_FindController 
   -- which is an optional dependnecy of "menu_Update" via "menu_GetDefaultController"
   
   put the stack_SubName [LcwSubStackName] of the target into subStackName
   if exists (card mTitle of stack subStackName) then
      return the long id of card mTitle of stack subStackName
   else
      return empty
   end if
end menu_SubStackCard

getprop menu_SubStackName
   put the stack_SubName [LcwSubStackName] of the target into subStackName
   return subStackName
end menu_SubStackName

getprop menu_SubStack
   put the stack_Object of the target into stackObject
   put the mainstack of stackObject into mainStackName
   put the stack_SubName [LcwSubStackName] of stackObject into subStackName
   
   if exists(stack subStackName of stack mainStackName) then
      put the long name of stack subStackName of stack mainStackName into stackObject
      return stackObject
   else
      return empty
   end if
end menu_SubStack

getprop menu_Cards
   put the menu_CardArray of the target into mCardArray
   return keys (mCardArray ["rugged_ID"])
end menu_Cards

getprop menu_CardNames
   put the menu_SubStack of the target into menuSubStack
   if exists (menuSubStack) is false then return empty
   put the cardNames of stack menuSubStack into mCardNames
   filter mCardNames with "* | Menu"
   return mCardNames
end menu_CardNames

getprop menu_CardMenu
   put the menu_CardNames of the target into mCards
   return menu_ConstructCardMenu (mCards)
end menu_CardMenu

function menu_ConstructCardMenu mCards
   sort mCards
   put mCards into globalMenuTitles
   filter globalMenuTitles with "Global |*"
   
   put mCards into mCardMenu
   filter mCardMenu without "Global |*"
   
   if mCardMenu is not empty and globalMenuTitles is not empty then put ",-," after mCardMenu
   if globalMenuTitles is not empty then put globalMenuTitles after mCardMenu
   return mCardMenu
end menu_ConstructCardMenu

getprop menu_CardArray
   put the menu_CardNames of the target into mCardNames
   repeat for each line mCardName in mCardNames
      put the long id of card mCardName of stack menuSubStack into cardObject
      put revRuggedID (cardObject) into rObject
      put rObject into mCardArray ["mTitle"][mCardName]
      put mCardName into mCardArray ["rugged_ID"][rObject]
   end repeat
   return mCardArray
end menu_CardArray

command menu_IndexStackMenuCards pStackObject
   if pStackObject is empty then put the stack_Object of the target into pStackObject
   
   repeat for each line someID in the cardids of pStackObject
      set the cursor to busy
      put the long id of card id someID of pStackObject into cardObject
      set the menu_Update of cardObject to true
   end repeat
end menu_IndexStackMenuCards

command menu_CreateSubStack someObject
   stack_CreateSubStack someObject, LcwSubStackName
   return the result
end menu_CreateSubStack


--> Deps
-
getprop stack_SubName [subStackStem]
   if subStackStem is empty then put "LCW SubStack" into subStackStem
   put the defaultstack into stackObject
   put the mainstack of stackObject into mainStackName
   put mainStackName & "|" & subStackStem into subStackName
   return subStackName
end stack_SubName

command stack_CreateSubStack someObject, subStackStem
   put the main_Stack of someObject into mainStackObject
   put the short name of mainStackObject into mainStackName
   
   put the stack_SubName [subStackStem] of mainStackObject into subStackName
   -- could do extensive checking for a unique name
   put exists (stack subStackName) is true into stackExists
   put exists (stack subStackName of stack mainStackName) is true into subStackExists
   
   switch
      case (stackExists is false) and (subStackExists is false)
         create invisible stack subStackName
         set the mainstack of stack subStackName to stackObject
         break
      case subStackExists is true
         -- already created -- skip to copy over view_Template
         return the long id of stack subStackName of stack mainStackName
      case stackExists is true
         -- there is a mainstack of this name
         return the long id of stack subStackName
      default
         answer warning merge ("A stack named '[[subStackName]]' already exists! Be careful (check manually)!")
         exit to top
   end switch
end stack_CreateSubStack


--> Deps
-
getprop main_Stack
   put the defaultstack into stackObject
   put the mainstack of stackObject into mainStackName
   put the name of stack mainStackName into mainStackObject
   return mainStackObject
end main_Stack

getprop stack_Object
   return the defaultstack
end stack_Object

