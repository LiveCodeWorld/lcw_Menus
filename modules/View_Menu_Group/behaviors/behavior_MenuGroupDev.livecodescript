script "behavior_MenuGroupDev"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_MenuGroupDev
type: behavior
version: 0.1

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/


--> Working on
-
command _SetMenuButtonController numOrName, mController
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   put the long id of button mNum of me into mButton
   --
   _SetMenuItemController mController, mButton
   --
   put the result into mData
   return mData
end _SetMenuButtonController

--> Props | MenuBar | Model
-
getprop menubar_Data
   return the menubar_Data of me
end menubar_Data

setprop menubar_Data mBarData
   _CleanMenuBarData mBarData
   set the menubar_Data of me to mBarData
end menubar_Data


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

private command _SetMenuItemController mController, mButton
   put the menu_GlobalTitle of mController into mTitle
   put _ConstructMenuBarData (mTitle, mButton, mController) into mData
   set the menuButton_Data of me to mData
   return mData
end _SetMenuItemController

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


