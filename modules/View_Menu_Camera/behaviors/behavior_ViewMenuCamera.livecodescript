script "behavior_ViewMenuCamera"
--> Menu | Model
-
getprop menubar_View
   return the long id of me
end menubar_View

getprop menu_ButtonData [mNum]
   if mNum is empty then return empty
   put the menubar_Data of me into mGroupData
   _NormaliseButtonNum mNum, mGroupData
   
   return mGroupData [mNum]
end menu_ButtonData

setprop menu_ButtonData [mNum] mData
   if mNum is empty then return empty
   put the menubar_Data of me into mGroupData
   _NormaliseButtonNum mNum
   
   put mData into mGroupData [mNum]
   set the menubar_Data of me to mGroupData
   return mData
end menu_ButtonData

getprop menubar_Data
   return the menubar_Data of me
end menubar_Data

setprop menubar_Data mGroupData
   set the menubar_Data of me to mGroupData
end menubar_Data


--> Private
-
private command _SetMenuData pTitleOrController
   local mTitle, pTopController, pMenuTarget
   
   put the long id of the target into mButton
   switch
      case word 1 of mButton is not "button"
         breakpoint
         return empty
      case pTitleOrController is empty
         put the menu_Title of me into mTitle
         break
      case exists (pTitleOrController)
         put pTitleOrController into pTopController
         put the menu_GlobalTitle of pTopController into mTitle
         break
      default
         put pTitleOrController into mTitle
   end switch
   --
   put _ConstructMenuData (mTitle, mButton, pTopController) into mData
   --
   set the menu_ButtonData of me to mData
   return mData
end _SetMenuData

private function _ConstructMenuData mTitle, mButton, pTopController, pMenuTarget
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
end _ConstructMenuData

private function _FindMenuTarget mButton, mTopController, pMenuTarget
   # Find mTarget
   if exists (pMenuTarget) is false then
      put the card_Object of mButton into cardObject
      put the view_Object of cardObject into tView
      put the menu_Target [tView] of mTopController into mTarget
      return mTarget
   else
      return pMenuTarget
   end if
end _FindMenuTarget


--> Events
-
on menuPick mTitle
   menu_DispatchTextPick mTitle
end menuPick

on mouseDown
   -- Also when mousedown in menubar
   put the long id of the target into mButton
   if word 1 of mButton is "button" then
      mArray_ClearActiveMenuArray
      _SetButtonText mButton
   else
      _SetMenuGroupText
   end if
end mouseDown

private command _SetMenuGroupText
   mArray_ClearActiveMenuArray
   --
   put the number of buttons of me into maxNum
   repeat with mButtonNum = 1 to maxNum
      put the long id of btn mButtonNum of me into mButton
      _SetButtonText mButton
   end repeat
end _SetMenuGroupText

private command _SetButtonText mButton
   -- put _CachedMenuArray (mButton) into mArray
   put the live_MenuArray of mButton into mArray
   mArray_SetActiveArray mArray -- consistant with async shift key or other drawing of menus
   
   # Set text of mButton
   if mArray is empty then
      put "Hello" into mText
   else
      put mArray_ToText (mArray) into mText
   end if 
   set the text of mButton to mText
   return mArray
end _SetButtonText

private function _CachedMenuArray mButton
   put the short name of mButton into mName
   
   # Get mArray_GetActive(keyItems)
   put the menu_ButtonData [mName] of me into mData
   put mData ["mArray"] into mArray
   --
   return mArray
end _CachedMenuArray

getprop menu_Title [mNum]
   put the menu_ButtonData [mNum] of me into mData
   put mData ["mTitle"] into mTitle
   return mTitle
end menu_Title

setprop menu_Title [menuNum] mTitleAndName
   if exists (button menuNum of me) is false then return empty
   
   put item 1 of mTitleAndName into mTitle
   put item 2 of mTitleAndName into mName
   
   put the long id of button menuNum of me into mButton
   put the live_MenuData [mTitle] of mButton into mData
   set the menu_ButtonData [menuNum] of mButton to mData
   
   put mData ["mArray"] into mArray
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
   --
   set the menu_ButtonName of mButton to mName
   return mData
end menu_Title

getprop menu_ButtonName [menuNum]
   if exists (button menuNum of me) is false then return empty
   
   put the long id of button menuNum of me into mButton
   put the short name of mButton into mName
   return mName
end menu_ButtonName

setprop menu_ButtonName [menuNum] mName
   if exists (button menuNum of me) is false then return empty
   put the long id of button menuNum of me into mButton
   if mName is empty then
      -- get a default from the menu_Title
      put the menu_Title [menuNum] of mButton into mTitle
      set the itemdelimiter to "|"
      put word 1 to -1 of item -2 of mTitle into mName
      if mName is empty then
         return "Error, menu_Title [" & menuNum & "]" of mButton & "is broken."
      end if
   end if
   
   set the name of mButton to mName
   set the label of mButton to mName
   --
   
   --
   return mButton
end menu_ButtonName

function _GetMenuButton numOrName
   if exists (button numOrName of me) then
      put the long id of button numOrName of me into mButton
      return mButton
   else
      return empty
   end if
end _GetMenuButton

getprop menu_Target
   return the long id of group "View|Camera" of card 1 of stack "View|Camera"
end menu_Target

getprop live_MenuArray
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then
      breakpoint
      return empty
   end if
   --
   -- put the number of mButton into mNum
   put the short name of mButton into mName
   put the menu_Title [mName] of mButton into mTitle
   if mTitle is empty then return empty
   
   # Update mData
   put the live_MenuData [mTitle] of mButton into mData
   set the menu_ButtonData [mTitle] of mButton to mData
   --
   put mData ["mArray"] into mArray
   return mArray
end live_MenuArray

getprop live_MenuData [mTitle]
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then
      breakpoint
      return empty
   end if
   --
   put the menu_Target of mButton into mTarget
   
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject mTarget
   put _LiveMenuData (mTitle, mButton, mTarget) into mData
   return mData
end live_MenuData

private function _LiveMenuData mTitle, mButton, pMenuTarget
   put menu_GetGlobalController (mTitle) into mTopController
   if exists (mTopController) is false then return empty
   --
   put mTitle into mData ["mTitle"]
   put mTopController into mData ["mController"] -- this is mTopController
   put the short name of mButton into mData ["mName"]
   --
   put _FindMenuTarget (mButton, mTopController, pMenuTarget) into mTarget
   put mTarget into mData ["mTarget"]
   
   # Construct mData from mController script
   put mArray_FromTitleTable (mTitle, mTarget) into mArray
   put mArray into mData ["mArray"]
   return mData
end _LiveMenuData


--> Menu | Set
-
setprop menu_Title [pMenuTarget] gMenutitle
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then
      breakpoint
      return empty
   end if
   
   _SetMenuButtonText gMenutitle, mButton, pMenuTarget
   put the result into mData
   return mData
end menu_Title

private command _SetMenuButtonText mTitle, mButton, pMenuTarget
   put _LiveMenuData (mTitle, mButton, pMenuTarget) into mData
   put mData ["mArray"] into mArray
   
   # Set text of mButton
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
   
   # Set menu_ButtonData of mButton
   put the short name of mButton into mName
   set the menu_ButtonData [mName] of me to mData
   return mData
end _SetMenuButtonText

setprop menu_Controller mController
   _SetMenuData mController
   put the result into mData
   return mData
end menu_Controller


--> Menu | Get
-
getprop show_Menu
   put the stack_Name of me into sName
   put the menubar of stack sName into mName
   put mName is not empty into sBoolean
   return sBoolean
end show_Menu

setprop show_Menu sBoolean
   put the stack_Name of me into sName
   --
   if sBoolean is true then
      put the short name of me into mName
      set the menubar of stack sName to mName
   else
      set the menubar of stack sName to empty
   end if
end show_Menu

getprop menu_Target
   put the long id of the target into tObject
   get the menubar_Data of me
   put the menu_ButtonData ["mTarget"] of me into mTarget
   if exists (mTarget) is true then return mTarget
   
   ## First Time we find and set
   _SetMenuData
   put the result into mData
   return mData ["mTarget"]
end menu_Target

getprop menu_Controller
   put the menu_ButtonData ["mController"] of me into mController
   if exists (mController) is true then return mController
   
   ## First Time we find and set
   _SetMenuData
   put the result into mData
   return mData ["mController"]
end menu_Controller

command _NormaliseButtonNum @mNum, mGroupData
   if mNum is a number then return true
   
   put mNum into mName
   repeat with itemNum = 1 to item 2 of the extents of mGroupData
      put mGroupData [itemNum]["mName"] into testName
      if testName = mName then
         put itemNum into mNum
         return true
      end if
   end repeat
   put 0 into mNum
   return false
end _NormaliseButtonNum
