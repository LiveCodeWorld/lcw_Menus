script "behavior_ViewMenuGroup" with behavior "behavior_MenuGroupCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_ViewMenuGroup
type: behavior
version: 0.5

/*
This behavior displays and updates a dynamic cross-platform menubar.
*/

--> Working on
-
function menuGroup_Controller mTitle
   put the module_Controller [mTitle] of stack "View|Menu|Group" into mController
   return mController
end menuGroup_Controller

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
         -- breakpoint
         -- put the menuButton_Array of mButton into buttonArray
         -- display_Data buttonArray, the name of mButton, "the menuButton_Array"
         -- put buttonArray ["m mTitle"] into mTitle
         -- set the menuButton_Title of mButton to mTitle
      end try
   end repeat
end _UpdateMenubar

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
      put _DefaultMenuTarget() into mTarget
   end if
   return mTarget
end menuButton_Target

setprop menuButton_Target [numOrName] mTarget
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   set the uOPN ["mTarget"] of mButton to mTarget
   return the result
end menuButton_Target


--> Live
-
getprop live_MenuArray
   # Needs to be called on an mButto that has menuButton_Title an menuButton_Target set
   -- requires lib_MenuArray
   
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then
      breakpoint
      return empty
   end if
   --
   put the menuButton_Target of mButton into tObject
   if tObject is empty then
      breakpoint
      return empty
   end if
   --
   put the menuButton_Title of mButton into mTitle
   if mTitle is empty then
      -- breakpoint
      return empty
   end if
   
   # Get live mData
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject tObject
   put mArray_FromTitleTable (mTitle, tObject) into mArray -- in lib_MenuArray
   return mArray
end live_MenuArray


--> Init
-
getprop view_BehaviorStackNames
   put the uOPN ["view_BehaviorStackNames"] of me into mBehaviorStackNames
   return mBehaviorStackNames
end view_BehaviorStackNames

setprop view_BehaviorStackNames mBehaviorStackNames
   set the uOPN ["view_BehaviorStackNames"] of me to mBehaviorStackNames
   
   # Send-in-time to prevent behavior setting behavior
   send "init_Module" to me in 2 ticks
end view_BehaviorStackNames

command init_Module
   put the view_BehaviorStackNames of me into bStackNames
   set the behavior_StackNames of me to bStackNames
   lcw_Notify "Initialised behaviors for" && the name of me
end init_Module


--> Events
-
on preOpenControl
   init_Module
   pass preOpenControl
end preOpenControl

on mouseDown
   # When the menu is initiated (roled over menu)
   -- no longer sent to menu-button
   put the long id of the target into mButton
   
   if the optionKey is "Down" then
      breakpoint
      set the menuButton_Target of mButton to empty
   end if
   --
   if word 1 of mButton is "button" then
      put the menuButton_Text of mButton into mText
      set the text of mButton to mText
   else
      _UpdateMenubar
   end if
end mouseDown

on resizeControl
   _LayoutMenuButtons
end resizeControl

on menuPick mItemPath
   put the long id of the target into mButton
   --
   put the menuButton_UpdateStyle of mButton into updateStyle
   switch updateStyle
      case "script"
         menuButton_ScriptTextPick mItemPath, mButton
         break
      case "rev"
         put the short name of mButton into mName
         ide_RevMenubarMenuPick mName, mItemPath
         break
      case "cached"
         put the menuButton_CachedArray of mButton into mArray
         _DispatchTextPick mItemPath, mArray, mButton
         put the result into hKeyLine
         break
      case "mTitle"
      default
         put the live_MenuArray of mButton into mArray
         --
         _DispatchTextPick mItemPath, mArray, mButton
         put the result into hKeyLine
   end switch
end menuPick

private command _DispatchTextPick mItemPath, mArray, mButton
   -- menubar version of _DispatchTextPick
   put the menuButton_Target of mButton into mTarget
   --
   -- put mArray_GetActiveArray() into menuArray
   mArray_SetActiveItem mItemPath
   mArray_FindActive mArray, mItemPath, hKey, paramValue
   mArray_UnMarshal hKey
   --
   hKey_Do hKey, mTarget, paramValue
end _DispatchTextPick


--> Layout
-
on LayoutControl
   _LayoutMenuButtons
end LayoutControl

on refresh_Menus
   _UpdateMenubar true
   _LayoutMenuButtons
end refresh_Menus

private command _LayoutMenuButtons pMenuButtonIDs
   lock screen
   set the topleft of me to "0,0"
   
   # Layout buttons from left to right according to order in Menu Buttons field
   if pMenuButtonIDs is empty then
      put the childControlIDs of me into pMenuButtonIDs
      if pMenuButtonIDs is empty then return empty
   end if
   if exists (btn 1 of me) is false then return empty
   put the long id of btn 1 of me into firstbutton
   
   # Props of me
   put the stack_Name of me into menuBarStackName
   put the menuBar of stack menuBarStackName into tOriginalMenuBar
   
   # Relayer defaults
   put the relayerGroupedControls into tOriginalRelayerGroupedControls
   
   set the defaultStack to menuBarStackName
   --
   # Arrange rect of btns for proper positioning in stack window
   put 1 into tNextLeft
   put the formattedHeight of firstbutton into fHeight
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
   set the topleft of me to "0,0"
   --
   unlock screen
   return pMenuButtonIDs
end _LayoutMenuButtons


--> Check
-
function _MenuButton mTitle
   -- private causes diff problem???
   if exists (btn mTitle of me) then
      return the long id of btn mTitle of me
   else
      return empty
   end if
end _MenuButton

private function _GroupButtonNumber numOrName
   return _MenuButton (numOrName)
end _GroupButtonNumber

getprop menuButton_NumFromName [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   put the short name of mButton into mName
   put _GroupButtonNumber (mName) into mNum
   return mNum
end menuButton_NumFromName

getprop menu_Button
   put the long id of the target into mButton
   if word 1 of the target is not "button" then
      return empty
   end if
   return mButton
end menu_Button

getprop menuButton_Object [numOrName]
   -- too complex (just use names?)
   if numOrName is empty then
      return the menu_Button of the target
   else
      return _MenuButton (numOrName)
   end if
end menuButton_Object

getprop norm_Title [mTitle]
   put the normalized_TitleArray [mTitle] of the target into normArray
   return normArray ["mTitle"]
end norm_Title

private function _ConstructNormArray mController
   put "Module" into normArray ["mUpdateStyle"]
   --
   put revRuggedID (mController) into normArray ["mController"]
   put the module_Name of mController into normArray ["moduleName"]
   put menu_TitleFromController (mController) into normArray ["mTitle"]
   return normArray
end _ConstructNormArray

getprop normalized_TitleArray [mTitle]
   put the long id of the target into tObject
   if mTitle is "Default" then put empty into mTitle
   
   # Module or Project menuController
   if the module_Name of tObject is not empty then
      put the module_Controller [mTitle] of tObject into mController
   else
      put the project_Controller [mTitle] of tObject into mController
   end if
   
   # If local menu controller
   if exists (mController) then
      put _ConstructNormArray (mController) into normArray
      return normArray
   end if
   
   # Check menu module for controller
   put menuGroup_Controller (mTitle) into mController
   if exists (mController) then
      put _ConstructNormArray (mController) into normArray
      return normArray
   end if
   
   # Check Rev labled menu
   if the number of words of mTitle = 2 \ 
         AND word -1 of mTitle = "Rev" \
         AND rev_CheckMenuName (mTitle) is true \
         THEN
      put "Rev" into normArray ["mUpdateStyle"]
      put mTitle into normArray ["mTitle"]
      return normArray
   end if
   
   # Check Normalized Global Menu
   if mTitle contains "|" then
      menu_NormalizeGlobalTitle mTitle
      --
      put menu_GetGlobalController(mTitle) into mController
      put "Rev" into normArray ["mUpdateStyle"]
      put mTitle into normArray ["mTitle"]
      put mController into normArray ["mController"]
      return normArray
   end if
   
   # Lastly Rev Menu
   if rev_CheckMenuName (mTitle) is true then
      put "Rev" into normArray ["mUpdateStyle"]
      put mTitle into normArray ["mTitle"]
      return normArray
   end if
   
   # Can't find
   return empty
end normalized_TitleArray


--> MenuButton | Text
-
getprop menuButton_Text [numOrName]
   put the long id of the target into tObject
   put the menuButton_Object [numOrName] of tObject into mButton
   if exists (mButton) is false then return empty
   
   switch the menuButton_UpdateStyle of mButton
      case "Rev"
      case "cached"
         return the text of mButton
      case "mTitle"
      case "live"
      default
         mArray_ClearActiveMenuArray
         put the live_MenuArray of mButton into mArray
         if mArray is not an array then return empty
         put mArray_ToText (mArray) into mText
   end switch
   return mText
end menuButton_Text

getprop menuButton_LiveText [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   put the live_MenuArray of mButton into mArray
   if mArray is not an array then return empty
   --
   put mArray_ToText (mArray) into mText
   return mText
end menuButton_LiveText


--> Module
-
getprop module_Menu
   put the module_Name of the target into mName
   -- put the short name of the defaultstack into mName
   if mName is empty then return empty
   put module_ConstructGlobalMenuTitle (mName, true) into mTitle 
   return mTitle
end module_Menu

getprop module_Name
   put the module_ShortFolder of the target into moduleName
   replace "_" with "|" in moduleName
   return moduleName
end module_Name

function module_ConstructGlobalMenuTitle moduleStackName, pMakePretty
   -- see "menu_GlobalTitleFromViewName"
   
   replace "_" with "|" in moduleStackName
   menu_NormalizeTitle moduleStackName, pMakePretty
   set the itemdelimiter to " | "
   if item 1 of moduleStackName is not "Global" then put "Global | " before moduleStackName
   if item 2 of moduleStackName = "View" then delete item 2 of moduleStackName
   if item -1 of moduleStackName is not "Menu" then put " | Menu" after moduleStackName
   return moduleStackName
end module_ConstructGlobalMenuTitle


--> MenuPick
-
command menuButton_ScriptTextPick mItemPath, mButton
   put the menuButton_Title of mButton into mTitle
   put the menuBar_Owner of mButton into tObject
   put the menuButton_Target of mButton into mTarget
   
   put the menuController_Array [tObject] of mButton into mArray
   
   mArray_DeconstructPicked mItemPath, mArray, hName, mController, paramValue
   put the result into hKey
   
   if the optionKey is "down" then
      hkey_Edit hKey
      return "Option edited:" && hKey
   end if
   
   dispatch hName to mController with mTarget,paramValue
   switch it
      case "handled"
         -- the message was handled and not passed
         break
      case "unhandled"
         -- no matching handlers were found
         break
      case "passed"
         -- the message was handled but passed by all handlers
         break
   end switch
end menuButton_ScriptTextPick

private function _DefaultMenuTarget
   put the top_Sister of me into sTarget
   if exists (sTarget) is false then
      put the long id of the owner of me into sTarget
   end if
   return sTarget
end _DefaultMenuTarget

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


--> Deps | MenuButton
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

command menu_NormalizeTitle @mTitle, pMakePretty
   set the itemdelimiter to "|"
   repeat for each item someItem in mTitle
      if pMakePretty is true then
         put empty into prettyItem
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someText
      else
         put word 1 to -1 of someItem into someText
      end if
      put space & someText & space & "|" after normalizedMenuTitle
   end repeat
   delete char -2 to -1 of normalizedMenuTitle
   delete char 1 of normalizedMenuTitle
   put normalizedMenuTitle into mTitle
end menu_NormalizeTitle

command menuButton_MouseDown mButton
   put the module_Menu of me into mTitle
   -- put "Global | Menu | Button | Menu" into mTitle
   switch
      case the controlkey is "Down"
         mArray_PullDown mTitle, mButton
         break
      default
         mArray_MouseDown mTitle, mButton
   end switch   
end menuButton_MouseDown

command mArray_PullDown mTitle, pMenuButton, pTargetObject
   if exists (pTargetObject) is false then
      put the long id of the target into pTargetObject
   end if
   if exists (pMenuButton) is false then
      put the long id of the target into pMenuButton
   end if   
   --
   mArray_MouseDown mTitle, pMenuButton, pTargetObject
   put the result into mArray
   --
   put the bottomleft of pTargetObject into popLoc
   add 3 to item 2 of popLoc
   --
   popup pMenuButton at popLoc
   return mArray
end mArray_PullDown

command mArray_MouseDown mTitle, pMenuButton, pTargetObject
   if pTargetObject is empty then
      put the long id of the target into pTargetObject
   end if
   if pMenuButton is empty then
      -- defaults to the target rather than the global menu_Button
      put pTargetObject into pMenuButton
   end if
   --
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject pTargetObject
   --
   switch word 1 of pMenuButton
      case "button"
         put mArray_FromTitleTable (mTitle, pTargetObject) into mArray -- dispatches "menu_Init"
         put mArray_ToText (mArray) into mText
         --
         set the text of pMenuButton to mText
         --
         -- mArray_SetActive mArray, mText, mTitle
         return mArray
      case "widget"
         break
      default
         exit to top
   end switch
end mArray_MouseDown

getprop module_ShortFolder
   put the module_Folder of the target into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   return shortFolder
end module_ShortFolder


--> MenuButton | Update
-
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

getprop menuButton_UpdateStyles
   return "rev,cached,mTitle,live"
end menuButton_UpdateStyles

getprop use_Cached
   put the long id of the target into mButton
   put the uOPN ["use_Cached"] of mButton into someBoolean
   return someBoolean 
end use_Cached

setprop use_Cached someBoolean
   put the long id of the target into mButton
   set the uOPN ["use_Cached"] of mButton to someBoolean
   return empty 
end use_Cached

getprop menuButton_CachedArray
   put the long id of the target into mButton
   put the uOPN ["cachedArray"] of mButton into mArray
   return mArray
end menuButton_CachedArray

setprop menuButton_CachedArray mArray
   put the long id of the target into mButton
   set the uOPN ["cachedArray"] of mButton to mArray
   return empty
end menuButton_CachedArray

setprop menuButton_RevText [numOrName] mName
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   put ide_RevMenubarText (mName) into mText
   set the text of mButton to mText
   return mText
end menuButton_RevText

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
   
   if pRefresh is true then
      menuBar_Refresh
   end if
   --
   -- dispatch "LayoutCard"
   send "LayoutCard" to me in 2 ticks
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


--> Props | mButton
-
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


--> MenuButton
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

getprop menuButton_IDs
   put the childControlIDs of me into menuButtonIDs
   return menuButtonIDs
end menuButton_IDs

setprop menuButton_IDs menuButtonIDs
   _LayoutMenuButtons menuButtonIDs
end menuButton_IDs


--> Objects
-
getprop menuBar_Owner
   return the long id of the owner of me
end menuBar_Owner

getprop menubar_View
   return the long id of me
end menubar_View

getprop view_Object
   return the long id of me
end view_Object


--> Private
-
private command _UpdateMenuButton mButton, pForce
   put the menuButton_UpdateStyle of mButton into updateStyle
   switch 
      case updateStyle = "Rev"
         put the short name of mButton into mName
         set the menuButton_RevText of mButton to mName
         set the menuButton_CachedArray of mButton to empty
         -- set the menuButton_RevScript of mButton to mName
         break
      case updateStyle = "cached"
         put the menuButton_CachedArray of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
      case updateStyle = "mTitle"
      case "updateStyle = live"
      case pForce is true
      default
         put the live_MenuArray of mButton into mArray
         _SetTextFromArray mButton, mArray
         break
   end switch
end _UpdateMenuButton

private command _SetTextFromArray mButton, mArray
   if mArray is not an array then return false
   --
   set the menuButton_CachedArray of mButton to mArray
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

private command _NormalizeClickTarget @tObject
   if exists (tObject) then
      return true
   else
      put _DefaultMenuTarget() into tObject
      return false
   end if
end _NormalizeClickTarget
