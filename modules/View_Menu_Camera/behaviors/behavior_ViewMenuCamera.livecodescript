script "behavior_ViewMenuCamera"
--> Events
-
getprop menu_GroupData
   put the number of buttons of me into maxNum
   repeat with mButtonNum = 1 to maxNum
      put the menu_ButtonData of btn mButtonNum of me into mData
      put mData into mGroupData [mButtonNum]
   end repeat
   return mGroupData
end menu_GroupData

-- getprop menu_Array
put the menu_ButtonData ["mArray"] of me into mArray
if mArray is an array then return mArray

## First Time we find and set
## First Time we find and set
_SetMenuData
put the result into mData
return mData ["mArray"]
end menu_Array

on mouseDown
   -- breakpoint -- only called in testing
   put the long id of the target into mButton
   --
   # Get mData of mButton
   put the menu_Data of mButton into mData
   put mData ["mArray"] into mArray
   
   # Set text of mButton
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
end mouseDown

on menuPick mItem
   put the long id of the target into mButton
   --
   put the menu_ButtonData ["mArray"] of mButton into mArray
   menu_DispatchTextPick mItem, mArray
end menuPick


--> Menu | Set
-
setprop menu_Title gMenutitle
   _SetMenuData gMenutitle
   put the result into mData
   return mData
end menu_Title

setprop menu_Controller mController
   _SetMenuData mController
   put the result into mData
   return mData
end menu_Controller


--> Menu | Get
-
getprop menu_Target
   put the long id of the target into tObject
   get the menu_GroupData of me
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


--> Menu | Model
-
getprop menu_Group
   return the long id of me
end menu_Group

getprop menu_ButtonData [sKey]
   if word 1 of the target is not "button" then
      -- probably me
      return empty
   end if
   
   put the menu_Data of the target into mData
   if sKey is empty then
      return mData
   else
      return mData [sKey]
   end if
end menu_ButtonData

setprop menu_ButtonData [sKey] sValue
   if sKey is empty then
      set the menu_ButtonData of the target to sValue
   else
      put the menu_ButtonData of the target to mData
      put sValue into mData [sKey]
      set the menu_ButtonData of the target to mData
   end if
end menu_ButtonData


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
   
   # Find mTarget
   if exists (pMenuTarget) is false then
      put the card_Object of mButton into cardObject
      put the view_Object of cardObject into tView
      put the menu_Target [tView] of mTopController into mTarget
   else
      put pMenuTarget into mTarget
   end if
   if exists (mTarget) then
      put revRuggedId (mTarget) into mData ["mTarget"]
   else
      -- not alsways a control (ie projectName)
      put mTarget into mData ["mTarget"]
   end if
   
   # Construct mArray from mController script
   put mArray_FromTitleTable (mTitle, mTarget) into mArray -- works of mControllers from mTitle, mTarget each loop
   put mArray into mData ["mArray"]  --
   return mData
end _ConstructMenuData
