script "behavior_ViewMenuGroup" with behavior "behavior_MenuGroupDev"
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
   
   -- too complex (just use names?)
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

getprop menuButton_NumFromName [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   put the short name of mButton into mName
   put _GroupButtonNumber (mName) into mNum
   return mNum
end menuButton_NumFromName

private function _MenuTarget mTitle, tObject
   -- put the menuButton_Target of tObject into mTarget
   put _MenuTitleController (tObject, mTitle) into mController -- in behavior_MenuGroupDev
   if exists (mController) is false then
      breakpoint
      return empty
   end if
   put the menu_Target [tObject] of mController into mTarget
   if exists (mTarget) is false then
      edit the script of mController
      exit to top
      
      put the menu_Target [tObject] of mController into mTarget
      put the long id of me into mTarget
   end if
   return mTarget
end _MenuTarget

setprop add_Menu [mName] mTitle
   put the long id of the target into tObject
   
   # Normalize mTitle
   _NormTargetTitle mTitle, mName, tObject
   if item 1 of the result = "Error" then return empty
   
   # Check if menu exists
   put the menuButton_Names of me into mNames
   if mName is among the lines of mNames then return empty
   
   if "Help" = line -1 of mNames then
      menuButton_CreateAtEnd mName, -1
   else
      menuButton_CreateAtEnd mName
   end if
   put the result into mButton
   --
   set the menuButton_Title [mName] of mButton to mTitle
   return mButton
end add_Menu


--> Working on
-
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
      
      put _GroupButtonNumber (numOrName) into mNum
      if mNum is empty then return empty
      --
      put the long id of button mNum of me into mButton
   end if
   return mButton
end menuButton_Object

getprop menuButton_Title [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --  
   put the uOPN ["mTitle"] of mButton into mTitle
   if mTitle is empty then
      -- put the short name of mButton into mTitle
   end if
   return mTitle
end menuButton_Title

setprop menuButton_Title [mName] mTitle
   -- Must be called on menuButton
   put the long id of the target into tObject
   put the menuButton_Object of tObject into mButton
   if exists (mButton) is false then return empty
   
   # Normalize mTitle
   _NormTargetTitle mTitle, mName, mButton
   if item 1 of the result = "Error" then return empty
   
   # Set Menu Button Name
   if mName is not empty then
      set the menuButton_Name of mButton to mName
   end if
   
   # Experimental Rev
   if mTitle = "Rev" then
      set the menuButton_RevScript of mButton to mName
      put the result into mText
      return mText
   end if
   
   # Live Array
   set the uOPN ["mUpdateStyle"] of mButton to "mTitle"
   
   -- was set the menuButton_TextFromTitle of mButton to mTitle
   put _MenuTarget (mTitle, tObject) into mTarget 
   put _LiveMenuArray (mTitle, mTarget, tObject) into mArray
   
   # Store Menu Title
   if mArray is not an array then
      set the uOPN ["mTitle"] of mButton to empty
      return empty  
   end if
   set the uOPN ["mTitle"] of mButton to mTitle
   
   # Set Menu Text
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
   --
   set the menuButton_CachedArray of mButton to mArray
   set the script of mButton to empty
   --
   return mData
end menuButton_Title

getprop norm_Title [mTitle]
   put the normalized_TitleArray [mTitle] of the target into normArray
   return normArray ["mTitle"]
end norm_Title

getprop normalized_TitleArray [mTitle]
   if mTitle is "Default" then put empty into mTitle
   
   # Check target module for controller
   put the module_Controller [mTitle] of the target into mController
   if exists (mController) then
      put revRuggedID (mController) into normArray ["mController"]
      put "Module" into normArray ["mUpdateStyle"]
      put the module_Name of the target into normArray ["moduleName"]
      put menu_TitleFromController (mController) into normArray ["mTitle"]
      return normArray
   end if
   
   # Check menu module for controller
   put "View|Menu|Group" into mStackName
   put the module_Controller [mTitle] of stack mStackName into mController
   if exists (mController) then
      put revRuggedID (mController) into normArray ["mController"]
      put "Module" into normArray ["mUpdateStyle"]
      put the module_Name of stack mStackName into normArray ["moduleName"]
      put menu_TitleFromController (mController) into normArray ["mTitle"]
      return normArray
   end if
   
   # Check Rev labled menu
   if the number of words of mTitle = 2 \ 
         AND word -1 of mTitle = "Rev" \
         AND rev_CheckMenuName (mTitle) is true \
         THEN
      put "Rev" into normArray ["mUpdateStyle"]
      put mTitle into normArray ["mTitle"]
   end if
   
   # Check Normalized Global Menu
   if mTitle contains "|" then
      menu_NormalizeGlobalTitle mTitle
      --
      put menu_GetGlobalController(mTitle) into mController
      if exists (mController) then
         put "Rev" into normArray ["mUpdateStyle"]
         put mTitle into normArray ["mTitle"]
         put mController into normArray ["mController"]
         --
         return normArray
      end if
   end if
   
   # Lastly Rev Menu
   if rev_CheckMenuName (mTitle) is true then
      put "Rev" into normArray ["mUpdateStyle"]
      put mTitle into normArray ["mTitle"]
   end if
   
   # Can't find
   return normArray
end normalized_TitleArray

private command _NormTargetTitle @mTitle, @newName, tObject
   put newName into oldName
   --
   switch
      case mTitle = "Rev"
      case word 2 of newName = "Rev"
         put word 1 of newName into newName
         if rev_CheckMenuName (newName) is false then
            return "Error, newName is not rev menu"
         end if
         put "Rev" into mTitle
         break
      default
         put the normalized_TitleArray [mTitle] of tObject into normArray
         put normArray ["mTitle"] into mTitle
         if mTitle is empty then return "Error, mTitle is empty"
         put _NameFrom (newName, mTitle) into newName
   end switch
   --
   return oldName
end _NormTargetTitle

private function _NameFrom numOrName, mTitle
   switch
      case numOrName is empty
         -- put mTitle into mName
         set the itemdelimiter to "|"
         put word 1 to -1 of item -2 of mTitle into mName
         break
      case numOrName is a number
         put empty into numOrName
         break
         -- case (the number of words of numOrName = 2) AND (word -1 of numOrName = "Rev")
         -- put word 1 of numOrName into mName
         -- break
      default
         put numOrName into mName
   end switch
   return mName
end _NameFrom

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
         put the menuButton_Array of mButton into buttonArray
         -- display_Data buttonArray, the name of mButton, "the menuButton_Array"
         put buttonArray ["m mTitle"] into mTitle
         -- set the menuButton_Title of mButton to mTitle
      end try
   end repeat
end _UpdateMenubar


--> Init
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


--> Live
-
getprop live_MenuArray
   put the long id of the target into mButton
   put the menuBar_Owner of me into tObject
   if word 1 of mButton is not "button" then return empty
   put the menuButton_Target of mButton into mTarget
   
   put the menuButton_Title of mButton into mTitle
   if mTitle is empty then return empty
   
   put _LiveMenuArray(mTitle, mTarget, tObject) into mArray
   return mArray
end live_MenuArray

private function _LiveMenuArray mTitle, mTarget, tObject
   # Get live mData
   mArray_ClearActiveMenuArray
   menu_SetTopTargetObject tObject
   put mArray_FromTitleTable (mTitle, mTarget) into mArray
   return mArray
end _LiveMenuArray


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
      hkey_OptionEdit hKey
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

on menuPick mItemPath
   -- put "script" into updateStyle
   put the long id of the target into mButton
   
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
         menu_DispatchTextPick mItemPath, mArray
         put the result into hKeyLine
         break
      case "mTitle"
      default
         put the live_MenuArray of mButton into mArray
         --
         menu_DispatchTextPick mItemPath, mArray
         put the result into hKeyLine
   end switch
end menuPick

private command wasDefault
   put the menuButton_CachedArray of mButton into mArray
   if mArray is not an array then
      #  lets try and re-index and cache again
      put the menuButton_Name of mButton into mName
      lcw_AnswerSheet "Something went wrong. Re-index menu '[[var]]'?", mButton, mName
      --
      breakpoint
      put the live_MenuArray of mButton into mArray
      set the menuButton_CachedArray of mButton to mArray
   end if
   
   menu_DispatchTextPick mItemPath, mArray
   --
   put the live_MenuArray of mButton into mArray
   set the menuButton_CachedArray of mButton to mArray
end wasDefault

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


--> Init
-
getprop behavior_DefaultStackNames
   -- put "behavior_ViewMenuGroup,behavior_MenuGroupCreate" into mBehavioStackNames
   put the behavior_DefaultStackNames of me into mBehavioStackNames
   return mBehavioStackNames
end behavior_DefaultStackNames

setprop behavior_DefaultStackNames mBehavioStackNames
   set the behavior_DefaultStackNames of me to mBehavioStackNames
   init_Module
end behavior_DefaultStackNames

command init_Module
   put the behavior_DefaultStackNames of me into bStackNames
   set the behavior_StackNames of me to bStackNames
   lcw_Notify "Initialised behaviors for" && the name of me
end init_Module


--> Deps | MenuButton
-
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


--> Layout
-
on LayoutControl
   _LayoutMenuButtons
end LayoutControl

on refresh_Menus
   _UpdateMenubar true
   _LayoutMenuButtons
end refresh_Menus


--> Props
-
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
      put _DefaultMenuTarget() into tObject
      return false
   end if
end _NormalizeClickTarget
