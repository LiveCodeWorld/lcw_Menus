script "behavior_ViewMenuGroup" with behavior "behavior_MenuGroupCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewMenuGroup
type: behavior
version: 0.2

/*
*/

--> Variables
-
local Live_MenuStatus


--> Working on
-
private function _Error
   return empty
end _Error

command menuBar_Refresh
   put the menuBar of this stack into tOriginalMenuBar
   put the defaultMenuBar into tOriginalDefaultMenuBar
   
   set the menuBar of this stack to empty
   set the defaultMenuBar to ide_DefaultMenuGroup()
   --
   set the menuBar of this stack to tOriginalMenuBar
   set the defaultMenuBar to tOriginalDefaultMenuBar
end menuBar_Refresh


--> Events
-
on preOpenControl
   set the behavior_StackNames of me to "behavior_ViewMenuGroup,behavior_MenuGroupCreate"
end preOpenControl

on resizeControl
   _LayoutMenuButtons
end resizeControl

on menuPick mItem
   put the short name of the target into mName
   --
   put the live_MenuArray of the target into mArray
   menu_DispatchTextPick mItem, mArray
   put the result into hKeyLine
   --
   if Live_MenuStatus is not true then
      set the menuButton_Refresh of me to mName
   end if
end menuPick

on mouseDown
   -- called when the stack menu is initiated (roled over menu)
   put the long id of the target into mButton
   
   put the live_Menu of me is false into pUseCached
   if word 1 of mButton is "button" then
      mArray_ClearActiveMenuArray
      put _GroupButtonNumber (numOrName) into mNum
      _SetButtonText mButton, mNum, pUseCached
   else
      _SetMenuGroupText pUseCached
   end if
end mouseDown


--> Props
-
getprop menuButton_Num [numOrName]
   -- overcomplicated
   switch
      case numOrName is an integer
         if numOrName < 0 then
            return _Error(the params)
         else if numOrName > the number of buttons of me then
            return _Error(the params)
         else
            return numOrName
         end if
      case word 1 of the target = "button"
         return the group_ButtonNumber of the target
      case exists (btn numOrName of me)
         return _GroupButtonNumber (numOrName)
      case numOrName is not empty
         put _NameToNum (numOrName) into mButtonNum
         return mButtonNum
      default
         return _Error()
   end switch
end menuButton_Num

private function _MenuButton numOrName
   if numOrName is empty then
      breakpoint
      if word 1 of the target is not "button" then return empty
      put the short name of the target into numOrName
   end if
   --
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   put the long id of button mNum of me into mButton
   return mButton
end _MenuButton

private function _GroupButtonNumber numOrName
   if exists (btn numOrName of me) is false then return empty
   put the short id of btn numOrName of me into btnID
   --
   repeat with btnNum = 1 to the number of buttons of me
      put the short id of btn btnNum of me into testID
      if testID = btnID then
         return btnNum
      end if
   end repeat
   return empty -- should not happen
end _GroupButtonNumber

command ide_RevMenubarMenuPick mName, mItem
   put the name of stack "revMenuBar" into revMbar
   --
   switch mName
      case "File"
         dispatch "revMenubarFileMenuPick" to revMbar with mItem
         break
      case "Edit"
         dispatch "revMenubarEditMenuPick" to revMbar with mItem
         break
      case "Tools"
         dispatch "revMenubarToolsMenuPick" to revMbar with mItem
         break
      case "Object"
         dispatch "revMenubarObjectMenuPick" to revMbar with mItem
         break
      case "Text"
         dispatch "revMenubarTextMenuPick" to revMbar with mItem
         break
      case "Development"
         dispatch "revMenubarDevelopmentMenuPick" to revMbar with mItem
         break
      case "View"
         dispatch "revMenubarViewMenuPick" to revMbar with mItem
         break
      case "Window"
         dispatch "revMenubarWindowMenuPick" to revMbar with mItem
         break
      case "Help"
         dispatch "revMenubarHelpMenuPick" to revMbar with mItem
         break
   end switch
end ide_RevMenubarMenuPick

function ide_RevMenubarText mName, pContext
   put the name of stack "revMenuBar" into revMbar
   --
   switch mName
      case "File"
         return value ("revMenubarFileMenu(pContext)" , revMbar)
      case "Edit"
         return value ("revMenubarEditMenu(pContext)" , revMbar)
      case "Tools"
         return value ("revMenubarToolsMenu(pContext)" , revMbar)
      case "Object"
         return value ("revMenubarObjectMenu(pContext)" , revMbar)
      case "Text"
         return value ("revMenubarTextMenu(pContext)" , revMbar)
      case "Development"         
         return value ("revMenubarDevelopmentMenu(pContext)" , revMbar)
      case "View"
         return value ("revMenubarViewMenu(pContext)" , revMbar)
      case "Window"
         return value ("revMenubarWindowMenu(pContext)" , revMbar)
      case "Help"
         return value ("revMenubarHelpMenu(pContext)" , revMbar)
      default
         break
   end switch
   
   return mText
end ide_RevMenubarText

getprop group_ButtonNumber
   put the long id of the target into tObject
   if word 1 of tObject is not "button" then return empty
   put the owner of tObject into tOwner
   if word 1 of tOwner is not "group" then return empty
   --
   put the short id of tObject into targetID
   repeat with btnNum = 1 to the number of buttons of tOwner
      put the short id of btn btnNum of tOwner into btnID
      if btnID = targetID then
         return btnNum
      end if
   end repeat
   return it
end group_ButtonNumber

getprop top_Sister
   put the long id of me into tObject
   put the top_Controls of the owner of tObject into topControls
   repeat for each line topControl in topControls
      if topControl = tObject then
         next repeat
      end if
      return topControl
   end repeat
   return empty
end top_Sister

command menuButton_Delete mName
   put _NameToNum (mName) into mButtonNum
   if mButtonNum is empty then return "Error, button of this name does not exoist in this menu:" && mName
   
   delete button mButtonNum of me
   --
   _LayoutMenuButtons
   put the result into mButtonIDs
   return mButtonIDs
end menuButton_Delete

private command _SetMenuGroupText pUseCached
   mArray_ClearActiveMenuArray
   --
   put the number of buttons of me into maxNum
   repeat with mNum = 1 to maxNum
      put the long id of btn mNum of me into mButton
      _SetButtonText mButton, mNum, pUseCached
   end repeat
end _SetMenuGroupText

private command _SetButtonText mButton, mNum, pUseCached
   set the showBorder of mButton to false
   if pUseCached is not false then
      -- put _CachedMenuArray (mButton) into mArray
   else
      put _LiveMenuArray (mNum, tObject) into mArray
   end if
   mArray_SetActiveArray mArray -- so we can use live menus
   
   # Set text of mButton
   if mArray is an array then
      put mArray_ToText (mArray) into mText
      set the text of mButton to mText
   end if 
   return mArray
end _SetButtonText


--> Props | MenuBar | Model
-
getprop menubar_Data
   return the menubar_Data of me
end menubar_Data

setprop menubar_Data mBarData
   _CleanMenuBarData mBarData
   set the menubar_Data of me to mBarData
end menubar_Data

getprop live_MenuArray [numOrName]
   local tObject
   --_NormalizeClickTarget tObject
   put the long id of the target into tObject
   
   if numOrName is empty then
      put the short name of the target into numOrName
   end if
   
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   put _LiveMenuArray (mNum, tObject) into mArray
   return mArray
end live_MenuArray


--> Live
-
getprop live_Menu
   return Live_MenuStatus is true
end live_Menu

setprop live_Menu sBoolean
   put sBoolean is true into Live_MenuStatus
   _SetMenuGroupText false
end live_Menu

private function _LiveMenuArray mNum, tObject
   # Get basics from mNum
   put _GetMenuButtonTitle (mNum) into mTitle
   put _GetMenuButtonTarget (mNum) into mTarget
   _NormalizeMenuTarget mTarget
   
   # Get live mData
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject tObject
   put mArray_FromTitleTable (mTitle, mTarget) into mArray
   return mArray
end _LiveMenuArray

private function _LiveMenuData mTitle, mButton, mTarget
   # Set mTarget
   if exists (mTarget) is false then breakpoint -- dangerous
   put mButton into tObject
   
   put mTarget into mData ["mTarget"]
   mArray_ClearActiveMenuArray -- or recursioncheck blanks this
   menu_SetTopTargetObject tObject -- we assume target is mButton?
   
   # Get mController form mTitle
   put menu_GetGlobalController (mTitle) into mTopController
   if exists (mTopController) is false then
      breakpoint
      return empty
   end if
   --
   put mTitle into mData ["mTitle"]
   put mTopController into mData ["mController"] -- this is mTopController
   put the short name of mButton into mData ["mName"]
   
   # Construct mData from mController script
   put mArray_FromTitleTable (mTitle, mTarget) into mArray
   put mArray into mData ["mArray"]
   return mData
end _LiveMenuData

getprop live_MenuData [mTitle]
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then
      breakpoint
      return empty
   end if
   --   
   put the menu_ButtonTarget of mButton into mTarget
   put _LiveMenuData (mTitle, mButton, mTarget) into mData
   return mData
end live_MenuData


--> Layout
-
on LayoutControl
   _LayoutMenuButtons
end LayoutControl

on refresh_Menus
   _SetMenuGroupText false
   _LayoutMenuButtons
end refresh_Menus

setprop menuButton_Refresh numOrName
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then
      return empty
   else
      put the long id of button mNum of me into mButton
   end if
   --
   _SetButtonText mButton, mNum, false
end menuButton_Refresh

setprop menuButton_Order menuButtonIDs
   if menuButtonIDs is empty then
      put the childControlIDs of me into menuButtonIDs
   end if
   
   -- warning: do checks first
   _LayoutMenuButtons menuButtonIDs
end menuButton_Order

command _LayoutMenuButtons pMenuButtonIDs
   # Layout buttons from left to right according to order in Menu Buttons field
   if pMenuButtonIDs is empty then
      put the childControlIDs of me into pMenuButtonIDs
   end if
   
   # Props of me
   put the stack_Name of me into menuBarStackName
   put the menuBar of stack menuBarStackName into tOriginalMenuBar
   
   # Relayer defaults
   put the relayerGroupedControls into tOriginalRelayerGroupedControls
   
   set the defaultStack to menuBarStackName
   --
   # Arrange rect of btns for proper positioning in stack window
   put 1 into tNextLeft
   put the formattedHeight of btn 1 of me into fHeight
   --
   repeat for each line btnID in pMenuButtonIDs
      put the long id of btn id btnID of me into btnObject
      --
      put the formattedWidth of btnObject into fWidth
      -- put the formattedHeight of btnObject into fHeight
      
      # Work out btn rect
      put tNextLeft + fWidth + 4 into tNextRight
      put -1 + fHeight -2 into tNextBottom
      put tNextLeft, -1, tNextRight, tNextBottom into bRect
      
      # Set Rect
      set the rect of btnObject to bRect
      
      # Next
      add the width of btnObject to tNextLeft
   end repeat
   
   # Arrange layer of btns for proper positioning on MacOS menubar
   set the relayerGroupedControls to true
   --
   put the num of lines in pMenuButtonIDs into tNumLines
   put the layer of me + 1 into tLayer
   repeat with lineNum = tNumLines down to 1
      put line lineNum of pMenuButtonIDs into btnID
      put the long id of btn id btnID of me into btnObject
      
      # Without removing the button from the menu group
      set the layer of btnObject to tLayer
   end repeat
   --
   set the relayerGroupedControls to tOriginalRelayerGroupedControls
   return pMenuButtonIDs
end _LayoutMenuButtons

private function _NameToNum mName
   if mName is a number then return mName
   
   put the childControlIDs of me into mButtonIDs
   put 1 into mButtonNum
   repeat for each line btnID in mButtonIDs
      put the short name of btn ID btnID of me into testName
      if testName = mName then
         return mButtonNum
      else
         add 1 to mButtonNum
      end if
   end repeat
   return empty
end _NameToNum

private command _NormaliseButtonNum @mNum, mBarData
   if mNum is a number then return true
   
   put mNum into mName
   repeat with itemNum = 1 to item 2 of the extents of mBarData
      put mBarData [itemNum]["mName"] into testName
      if testName = mName then
         put itemNum into mNum
         return true
      end if
   end repeat
   put 0 into mNum
   return false
end _NormaliseButtonNum


--> Menu | Props
-
getprop menuButton_Title [numOrName]
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   return _GetMenuButtonTitle (mNum)
end menuButton_Title

setprop menu_Controller [numOrName] mController
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   put the long id of button mNum of me into mButton
   --
   _SetMenuItemController mController, mButton
   --
   put the result into mData
   return mData
end menu_Controller

getprop menu_Buttons
   put the number of buttons of me into maxNum
   repeat with mButtonNum = 1 to maxNum
      put the long id of btn mButtonNum of me into mButton
      put mButton & CR after mButtons
   end repeat
   delete char -1 of mButtons
   return mButtons
end menu_Buttons


--> MenuButton
-
getprop menuButton_IDs
   put the childControlIDs of me into menuButtonIDs
   return menuButtonIDs
end menuButton_IDs

setprop menuButton_IDs menuButtonIDs
   _LayoutMenuButtons menuButtonIDs
end menuButton_IDs

getprop menuButton_Names
   return _ListButtonNames()
end menuButton_Names

setprop menuButton_Names newButtonNames
   -- put menuBar_ListButtonNames (mGroup) into oButtonNames
   put the long id of me into mGroup
   -- 
   replace comma with CR in newButtonNames
   put _ListButtonNames() into oButtonNames
   --
   if index_CheckSameItems (oButtonNames, newButtonNames) is false then
      return "Error, new button names are different for existing names"
   end if
   
   repeat for each line newButtonName in newButtonNames
      put the short id of btn newButtonName of mGroup into btnID
      put btnID & CR after menuButtonIDs
   end repeat
   delete char -1 of menuButtonIDs
   
   _LayoutMenuButtons pMenuButtonIDs
   --
   return menuButtonIDs
end menuButton_Names

getprop menuButton_Name [numOrName]
   put the menuButton_Object [numOrName] of me into mButton
   put the short name of mButton into mName
   return mName
end menuButton_Name

getprop menuButton_Object [numOrName]
   put _MenuButton (numOrName) into mButton
   return mButton
end menuButton_Object

setprop menuButton_Name [numOrName] mName
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   put the long id of button mNum of me into mButton
   if mName is empty then
      breakpoint
   end if
   
   set the name of mButton to mName
   set the label of mButton to mName
   return mButton
end menuButton_Name

getprop menuButton_Title [numOrName]
   put _GroupButtonNumber (numOrName) into mNum
   return _GetMenuButtonTitle (mNum) -- for mGroup buttons
end menuButton_Title

setprop menuButton_Controller [numOrName] mController
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   put the long id of button mNum of me into mButton
   --
   _SetMenuItemController mController, mButton
   --
   put the result into mData
   return mData
end menuButton_Controller

getprop menuButton_Data [numOrName]
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   return _GetMenuButtonData (mNum)
end menuButton_Data

setprop menuButton_Data [numOrName] mData
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   _SetMenuButtonData mNum, mData
   put the result into mBarData
   return mBarData
end menuButton_Data


--> Props
-
getprop show_Menu
   put the stack_Name of me into sName
   put the menubar of stack sName into mName
   put mName is not empty into sBoolean
   return sBoolean
end show_Menu

setprop show_Menu [pRefresh] sBoolean
   put the stack_Name of me into sName
   --
   set the lockscreen to true
   if sBoolean is true then
      put the short name of me into mName
      set the menubar of stack sName to mName
   else
      set the menubar of stack sName to empty
   end if
   set the lockscreen to false
   
   if pRefresh is true then
      menuBar_Refresh
   end if
end show_Menu


--> Working on
-
getprop menuButton_Num
   if word 1 of the target is not "button" then return empty
   --
   put the short name of the target into mName
   put _GroupButtonNumber (mName) into mNum
   return mNum
end menuButton_Num

getprop menu_ButtonTarget [mNum]
   if mNum is empty then
      put the menuButton_Num of the target into mNum
      if mNum is empty then
         breakpoint
         return empty
      end if
   end if
   put _GetMenuButtonTarget (mNum) into mTarget
   --
   if exists (mTarget) is false then
      _NormalizeMenuTarget mTarget
   end if
   return mTarget
end menu_ButtonTarget

setprop menu_ButtonTarget [mNum] mTarget
   _SetMenuButtonTarget mNum, mTarget
   return the result
end menu_ButtonTarget

getprop menu_Text [numOrName]
   put the live_MenuArray [numOrName] of the target into mArray
   if mArray is not an array then return empty
   put mArray_ToText (mArray) into mText
   return mText
end menu_Text


--> Objects
-
getprop menubar_View
   return the long id of me
end menubar_View

getprop view_Object
   return the long id of me
end view_Object


--> Private
-
private command _SetMenuItemController mController, mButton
   put the menu_GlobalTitle of mController into mTitle
   put _ConstructMenuBarData (mTitle, mButton, mController) into mData
   set the menuButton_Data of me to mData
   return mData
end _SetMenuItemController

private command _NormalizeClickTarget @tObject
   if exists (tObject) then
      return true
   else
      put _DefaultTarget() into tObject
      return false
   end if
end _NormalizeClickTarget

private command _NormalizeMenuTarget @pMenuTarget
   if exists (pMenuTarget) then
      return true
   else
      put _DefaultTarget() into pMenuTarget
      return false
   end if
end _NormalizeMenuTarget

private function _DefaultTarget
   put the top_Sister of me into sTarget
   if exists (sTarget) is false then
      put the long id of the owner of me into sTarget
   end if
   return sTarget
end _DefaultTarget


--> Private | Model
-
private command _CleanMenuBarData @mBarData
   repeat with mNum = 1 to the number of buttons of me
      put mBarData [mNum] into cleanData [mNum]
   end repeat
   put cleanData into mBarData
end _CleanMenuBarData

private function _ConstructMenuBarData mTitle, mButton, pTopController, pMenuTarget
   # Add mTitle
   put mTitle into mData ["mTitle"]
   
   # Find mTopController
   if exists (pTopController) is false then
      put menu_GetGlobalController (mTitle) into mTopController
   else
      put pTopController into mTopController
   end if
   put revRuggedId (mTopController) into mData ["mController"] -- this is mTopController
   
   # Construct mArray from mController script
   put mArray_FromTitleTable (mTitle, pMenuTarget) into mArray -- works of mControllers from mTitle, mTarget each loop
   put mArray into mData ["mArray"]
   return mData
end _ConstructMenuBarData

private function _GetMenuButtonData mNum
   if mNum is empty then return empty
   put the menubar_Data of me into mBarData
   if mBarData is not an array then return empty
   
   _NormaliseButtonNum mNum, mBarData
   
   return mBarData [mNum]
end _GetMenuButtonData

private command _SetMenuButtonData mNum, mData
   if mNum is empty then return empty
   put the menubar_Data of me into mBarData
   _NormaliseButtonNum mNum
   
   put mData into mBarData [mNum]
   set the menubar_Data of me to mBarData
   return mBarData
end _SetMenuButtonData

private function _GetMenuButtonValue mNum, sKey
   if exists (button mNum of me) is false then return empty
   --
   put _GetMenuButtonData (mNum) into mData
   put mData [sKey] into sValue
   return sValue
end _GetMenuButtonValue

private command _SetMenuButtonValue mNum, sKey, sValue
   if exists (button mNum of me) is false then return empty
   --
   put _GetMenuButtonData (mNum) into mData
   put sValue into mData [sKey]
   _SetMenuButtonData mNum, mData
   return mData
end _SetMenuButtonValue

private function _ListButtonNames
   --  put menuBar_ListButtonNames (mGroup) into mButtonNames
   repeat with mNum = 1 to the number of buttons of me
      put the short name of btn mNum of me into mName
      put mName & CR after mButtonNames
   end repeat
   delete char -1 of mButtonNames
   return mButtonNames
end _ListButtonNames

private function _GetMenuButtonTarget mNum
   put the uOPN ["mTarget"] of btn mNum of me into mTarget
   -- put _GetMenuButtonValue (mNum, "mTarget") into mTarget
   return mTarget
end _GetMenuButtonTarget

private command _SetMenuButtonTarget mNum, mTarget
   _SetMenuButtonValue mNum, "mTarget", mTarget -- no longer needed?
   set the uOPN ["mTarget"] of btn mNum of me to mTarget
   return the result
end _SetMenuButtonTarget

private function _GetMenuButtonTitle mNum
   put the uOPN ["mTitle"] of btn mNum of me into mTitle
   -- put _GetMenuButtonValue (mNum, "mTitle") into mTitle
   return mTitle
end _GetMenuButtonTitle
