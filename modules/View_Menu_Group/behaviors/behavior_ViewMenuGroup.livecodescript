script "behavior_ViewMenuGroup" with behavior "behavior_MenuGroupCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewMenuGroup
type: behavior
version: 0.2

/*
There needs to be a menu_Data model of the menuBar
Or we need behaviors for menu_Buttons that can then have handelrs like this:

That do not recurse.
*/

--> Variables
-

--> Working on
-
--> Init
-
on preOpenControl
   -- does not seem to be called
   set the behavior_StackNames of me to "behavior_ViewMenuGroup,behavior_MenuGroupCreate"
   lcw_Notify "Initialised behaviors for" && the name of me
   pass preOpenControl
end preOpenControl

private command _MenubarPick mItem
   -- _SetColour "yellow"
   put the long id of the target into mButton
   
   put the menuButton_UpdateStyle of mButton into updateStyle
   switch updateStyle
      case "rev"
         put the short name of mButton into mName
         ide_RevMenubarMenuPick mName, mItem
         break
      case "mTitle"
         put the live_MenuArray of mButton into mArray
         menu_DispatchTextPick mItem, mArray
         put the result into hKeyLine
         break
      case "cached"
      default
         put the cached_MenuArray of mButton into mArray
         menu_DispatchTextPick mItem, mArray
         --
         -- put the menuButton_LiveText of mButton into mText
         put the live_MenuArray of mButton into mArray
         set the cached_MenuArray of mButton to mArray
         
         /*
         # Set mText (even faster)
         if mArray is not an array then return empty
         put mArray_ToText (mArray) into mText
         set the text of mButton to mText
         */
   end switch
end _MenubarPick

private command _UpdateMenubar pForce
   mArray_ClearActiveMenuArray
   --
   put the number of buttons of me into maxNum
   repeat with mNum = 1 to maxNum
      put the long id of btn mNum of me into mButton
      --
      try
         _UpdateMenuButton mButton, pForce
      catch sError
         put sError
      end try
   end repeat
end _UpdateMenubar

private command _UpdateMenuButton mButton, pForce
   put the menuButton_UpdateStyle of mButton into updateStyle
   switch 
      case updateStyle = "Rev"
         put the short name of mButton into mName
         set the menuButton_RevText of mButton to mName
         set the cached_MenuArray of mButton to empty
         -- set the menuButton_RevScript of mButton to mName
         break
      case pForce is true
         put the menuButton_Array of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
      case updateStyle = "cached"
         put the cached_MenuArray of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
      case updateStyle = "mTitle"
         put the menuButton_Array of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
      case "updateStyle = live"
         put the live_MenuArray of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
      default
         -- do nothing
   end switch
end _UpdateMenuButton

getprop menuButton_Text [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   switch the menuButton_UpdateStyle of mButton
      case "Rev"
      case "cached"
         return the text of mButton
      case "mTitle"
      case "live"
      default
         mArray_ClearActiveMenuArray
         put the menuButton_Array of mButton into mArray
         if mArray is not an array then return empty
         put mArray_ToText (mArray) into mText
   end switch
   return mText
end menuButton_Text

getprop menuButton_LiveText [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   -- put the menuButton_Array of mButton into mArray
   put the live_MenuArray of mButton into mArray
   if mArray is not an array then return empty
   --
   put mArray_ToText (mArray) into mText
   return mText
end menuButton_LiveText


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
   lock menus
   set the lockscreen to true
   --
   if sBoolean is true then
      put the short name of me into mName
      set the menubar of stack sName to mName
   else
      set the menubar of stack sName to empty
   end if
   dispatch "LayoutCard"
   
   if pRefresh is true then
      menuBar_Refresh
   end if
   
   # Hack to force geometry
   choose pointer tool
   choose browse tool
   --
   set the lockscreen to false
   unlock menus
   
   return oRect
end show_Menu

getprop menu_Text [numOrName]
   put the live_MenuArray [numOrName] of the target into mArray
   if mArray is not an array then return empty
   put mArray_ToText (mArray) into mText
   return mText
end menu_Text


--> Dep | Props
-
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


--> Props | mButton
-
getprop menuButton_UpdateStyles
   return "rev,cached,mTitle,live"
end menuButton_UpdateStyles

getprop menuButton_UpdateStyle [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   put the uOPN ["mUpdateStyle"] of mButton into mUpdateStyle
   return mUpdateStyle
end menuButton_UpdateStyle

setprop menuButton_UpdateStyle [numOrName] mUpdateStyle
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   set the uOPN ["mUpdateStyle"] of mButton to mUpdateStyle
   --
   _UpdateMenuButton mButton
   return mButton
end menuButton_UpdateStyle

getprop menuButton_NumFromName [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   put the short name of mButton into mName
   put _GroupButtonNumber (mName) into mNum
   return mNum
end menuButton_NumFromName

getprop menuButton_Num
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
end menuButton_Num

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

getprop menu_Controller [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   put the uOPN ["menu_Controller"] of mButton into mController
   if exists (mController) is false then
      put the menuButton_Title [numOrName] of the target into mTitle
   end if
   return mController
end menu_Controller

setprop menuButton_Controller [numOrName] mController
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   -- _SetMenuItemController mController, mButton
   set the uOPN ["menu_Controller"] of mButton to mController
   return mButton
end menuButton_Controller


--> Events
-
on mouseDown
   # When the menu is initiated (roled over menu)
   -- no longer sent to menu-button
   put the long id of the target into mButton   
   --
   if word 1 of mButton is "button" then
      put the menuButton_Text of mButton into mText
      set the text of mButton to mText
   else
      _UpdateMenubar
   end if
   --
   -- _SetColour "random"
end mouseDown

on resizeControl
   _LayoutMenuButtons
end resizeControl

on menuPick mItem
   _MenubarPick mItem
end menuPick


--> Props
-
getprop menuBar_Owner
   return the long id of the owner of me
end menuBar_Owner

getprop menuButton_Title [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --  
   put the uOPN ["mTitle"] of mButton into mTitle
   return mTitle
end menuButton_Title

getprop menuButton_Target [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   put the uOPN ["mTarget"] of mButton into mTarget
   if exists (mTarget) is false then
      _NormalizeMenuTarget mTarget
   end if
   return mTarget
end menuButton_Target

setprop menuButton_Target [mNum] mTarget
   _SetMenuButtonTarget mNum, mTarget
   return the result
end menuButton_Target

getprop menuButton_Array [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   if the use_Cached of mButton is true then
      put the cached_MenuArray of mButton into mArray
   else
      put the live_MenuArray of mButton into mArray
   end if
   return mArray
end menuButton_Array


--> Live
-
getprop live_MenuData [mTitle]
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then
      breakpoint
      return empty
   end if
   --   
   put the menuButton_Target of mButton into mTarget
   put _LiveMenuData (mTitle, mButton, mTarget) into mData
   return mData
end live_MenuData

getprop live_MenuArray [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   put the menuButton_Title of mButton into mTitle
   if mTitle is empty then return empty
   
   put the menuBar_Owner of me into tObject
   put the menuButton_Target of mButton into mTarget
   
   # Get live mData
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject tObject
   put mArray_FromTitleTable (mTitle, mTarget) into mArray
   return mArray
end live_MenuArray


--> Layout
-
on LayoutControl
   _LayoutMenuButtons
end LayoutControl

on refresh_Menus
   _UpdateMenubar true
   _LayoutMenuButtons
end refresh_Menus


--> Menu | Props
-
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


--> Dep
-
command menuBar_Refresh
   put the menuBar of this stack into tOriginalMenuBar
   put the defaultMenuBar into tOriginalDefaultMenuBar
   
   set the menuBar of this stack to empty
   set the defaultMenuBar to ide_DefaultMenuGroup()
   --
   set the menuBar of this stack to tOriginalMenuBar
   set the defaultMenuBar to tOriginalDefaultMenuBar
end menuBar_Refresh

command ide_RevMenubarMenuPick mName, mItem
   switch mName
      case "File"
         dispatch "revMenubarFileMenuPick" to stack "revMenuBar" with mItem
         break
      case "Edit"
         dispatch "revMenubarEditMenuPick" to stack "revMenuBar" with mItem
         break
      case "Tools"
         dispatch "revMenubarToolsMenuPick" to stack "revMenuBar" with mItem
         break
      case "Object"
         dispatch "revMenubarObjectMenuPick" to stack "revMenuBar" with mItem
         break
      case "Text"
         dispatch "revMenubarTextMenuPick" to stack "revMenuBar" with mItem
         break
      case "Development"
         dispatch "revMenubarDevelopmentMenuPick" to stack "revMenuBar" with mItem
         break
      case "View"
         dispatch "revMenubarViewMenuPick" to stack "revMenuBar" with mItem
         break
      case "Window"
         dispatch "revMenubarWindowMenuPick" to stack "revMenuBar" with mItem
         break
      case "Help"
         dispatch "revMenubarHelpMenuPick" to stack "revMenuBar" with mItem
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
   
   return empty
end ide_RevMenubarText


--> Objects
-
getprop menubar_View
   return the long id of me
end menubar_View

getprop view_Object
   return the long id of me
end view_Object

getprop menuButton_Object [numOrName]
   if numOrName is empty then
      put the long id of the target into mButton
      if word 1 of the target is not "button" then
         return empty
      end if
   else
      put _GroupButtonNumber (numOrName) into mNum
      if mNum is empty then return empty
      --
      put the long id of button mNum of me into mButton
   end if
   return mButton
end menuButton_Object


--> MenuButon | Update
-
command menuButton_Delete mName
   put _NameToNum (mName) into mButtonNum
   if mButtonNum is empty then return "Error, button of this name does not exoist in this menu:" && mName
   
   delete button mButtonNum of me
   --
   _LayoutMenuButtons
   put the result into mButtonIDs
   return mButtonIDs
end menuButton_Delete


--> Private
-
private command _SetTextFromArray mButton, mArray
   if mArray is not an array then return false
   --
   set the cached_MenuArray of mButton to mArray
   --
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
   set the showBorder of mButton to false
   return true
end _SetTextFromArray

private command _SetButtonText mButton, mNum
   put the menuButton_Text of mButton into mText
   set the text of mButton to mText
   set the showBorder of mButton to false
end _SetButtonText

private function _Error
   return empty
end _Error

private command _SetColour sColour
   -- put the graphic_View of me into gView
   -- if exists (gView) then
   if sColour = "random" then put colour_GetRandom() into sColour
   --
   set the backgroundcolor of this cd to sColour
   -- end if
end _SetColour

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

private function _GetMenuButtonTarget mNum
   put the uOPN ["mTarget"] of btn mNum of me into mTarget
   return mTarget
end _GetMenuButtonTarget

private command _SetMenuButtonTarget mNum, mTarget
   _SetMenuButtonValue mNum, "mTarget", mTarget -- no longer needed?
   set the uOPN ["mTarget"] of btn mNum of me to mTarget
   return the result
end _SetMenuButtonTarget

private function _LiveMenuArray mNum, tObject
   # Get basics from mNum
   put the uOPN ["mTitle"] of btn mNum of me into mTitle
   
   put _GetMenuButtonTarget (mNum) into mTarget
   _NormalizeMenuTarget mTarget
   
   # Get live mData
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject tObject
   put mArray_FromTitleTable (mTitle, mTarget) into mArray
   return mArray
end _LiveMenuArray

private command _LayoutMenuButtons pMenuButtonIDs
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

