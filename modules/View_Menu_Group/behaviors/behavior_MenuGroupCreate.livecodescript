script "behavior_MenuGroupCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_MenuGroupCreate
type: behavior
version: 0.1

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/


--> Working on
-
function _ModuleMenuTitle mName
   put the view_Object of the owner of me into viewObject
   put the module_MenuTitle of viewObject into mTitle
   return mTitle
end _ModuleMenuTitle


--> Props
-
setprop menuButton_Title [numOrName] mTitle
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then return "Error, target is not a menu button."
   
   /*
   put _GroupButtonNumber (numOrName) into mNum
   if mNum is empty then return empty
   --
   put item 1 of mTitleAndName into mTitle
   put item 2 of mTitleAndName into mItemName
   */
   
   switch
      case numOrName is empty
         put mTitle into mName
         break
      case numOrName is a number
         put empty into numOrName
         break
      default
         put numOrName into mName
   end switch
   --
   _SetMenuButtonTitle mButton, mTitle, mName
   put the result into mData
   return mData
end menuButton_Title

setprop cached_MenuData [mTitle] mData
   put the long id of the target into mButton
   if word 1 of mButton is not "button" then return "Error, target is not a menu button."
   
   put the group_ButtonNumber of mButton into mNum
   put the menuButton_Data [mNum] of mButton into mData
   put mTitle into mData ["mTitle"]
   set the menuButton_Data [mNum] of mButton to mData
   return mData
end cached_MenuData

setprop menubar_Table mTable
   -- put "File-Rev,Edit-Rev,Tools,Menu-Global|Menu|Group|Exists|Menu,Help-Rev" into mTable
   replace comma with CR in mTable
   set the itemdelimiter to "-"
   
   put the menuBar of the defaultstack into tOriginalMenuBar
   --
   lock screen
   lock menus
   menuButton_SetTemplate
   
   put the number of lines of mTable into maxNum
   repeat with lineNum = 1 to maxNum
      get line lineNum of mTable
      put word 1 to -1 of item 1 of it into mName
      put word 1 to -1 of item 2 of it into mTitle
      
      # Create if exists
      if exists (btn lineNum of me) then
         put the long id of btn lineNum of me into mButton
      else
         create btn mName in me
         put the long id of it into mButton
      end if
      put mButton & CR after mButtons
      
      # Name and Label
      set the name of mButton to mName
      set the label of mButton to mName
      
      switch
         case mTitle = "Default"
            put _ModuleMenuTitle (mName) into mTitle
            set the menuButton_Title [mName] of mButton to mTitle
            break
         case mTitle = "Rev"
            put _RevMenuScript (mName) into mScript
            set the script of mButton to mScript
            set the text of mButton to empty
            break
         case mTitle contains "|"
            set the script of mButton to empty
            menu_NormalizeTitle mTitle, true
            set the menuButton_Title [mName] of mButton to mTitle
            break
         case mTitle = empty
            set the script of mButton to empty
            put _ModuleMenuTitle (mName) into mTitle
            if mTitle is not empty then
               set the menuButton_Title [mName] of mButton to mTitle
            end if
            break
         default -- a single plain word?
            set the script of mButton to empty
            put _ModuleMenuTitle (mTitle) into mTitle
            if mTitle is not empty then
               set the menuButton_Title [mName] of mButton to mTitle
            end if
      end switch
   end repeat
   delete char -1 of mButtons
   
   # Delete any extras
   put the number of buttons of me into lastButtonNum
   repeat with btnNum = lastButtonNum down to (maxNum +1)
      delete btn btnNum of me
   end repeat
   
   reset the templateButton
   LayoutControl
   menuBar_Refresh tOriginalMenuBar
   unlock menus
   unlock screen
   --
   return mButtons
end menubar_Table

setprop menu_Titles mTitles
   switch
      case mTitles is empty
         _DeleteMenuButtons
         return empty
      case mTitles = "rev"
         _SetRevMenuButtonScripts "File,Edit,Tools,Help"
         return the result
      default
         
   end switch
   
   replace comma with CR in mTitles
   put the number of lines of mTitles into maxNum
   repeat with mNum = 1 to maxNum
      get line mNum of mTitles
      put item 1 of it into mTitle
      put item 2 of it into mItemName
      
      # Set mTitle
      _SetMenuButtonTitle mNum, mTitle, mItemName
      put the result into mData
      put mData into rData [mNum]
   end repeat
   return mNum
end menu_Titles

getprop menu_Titles
   repeat with mNum = 1 to the number of buttons of me
      put _GetMenuButtonTitle (mNum) into mTitle
      put mTitle & CR after mTitles
   end repeat
   delete char -1 of mTitles
   return mTitles
end menu_Titles


--> Create
-
getprop ide_MenuScript [numOrName]
   put _MenuButton (numOrName) into mButton
   if exists (mButton) is false then return empty
   --
   put the script of mButton into sScript
   return sScript
end ide_MenuScript

setprop ide_MenuScript [numOrName] sScript
   put _MenuButton (numOrName) into mButton
   if exists (mButton) is false then return empty
   --
   if sScript = "default" then
      put numOrName into mName
   end if
   set the script of mButton to sScript
   return mButton
end ide_MenuScript

setprop create_MenuTitles mNames
   if mNames = "default" then
      put "File,Edit,Tools,Help" into mNames
      replace comma with CR in mNames
   else
      put the menuButton_Names of mGroup into mNames
   end if
   
   put 1 into mNum
   repeat for each line mName in mNames
      put merge ("Global | Menu | Group | [[mName]] | Menu") into mTitle
      _SetMenuButtonTitle mNum, mTitle, mName
      add 1 to mNum
   end repeat
   return mNames
end create_MenuTitles

setprop new_MenuButton [pInsertBefore] mTitleOrButtonName
   put the menuBar_View of the target into mGroup
   --
   if mTitleOrButtonName contains "|" then
      set the itemdelimiter to "|"
      put mTitleOrButtonName into mTitle
      put item -2 of mTitle into newButtonName      
   else
      put mTitleOrButtonName into newButtonName
      put empty into mTitle
   end if
   put word 1 to -1 of newButtonName into newButtonName
   
   _CreateMenuButton newButtonName, pInsertBefore
   put the result into newButtonID
   
   if mTitle is not empty then
      set the menuButton_Title [newButtonName] of mGroup to mTitle
   end if
   return newButtonID
end new_MenuButton


--> Menubar | Create
-
on menuBar_DeleteMenuButtons pMenuButtonIDs
   if pMenuButtonIDs is empty then
      put the childControlIDs of me into pMenuButtonIDs
   end if
   
   repeat for each line btnID in pMenuButtonIDs
      delete btn id btnID of me
   end repeat
end menuBar_DeleteMenuButtons


--> MenuButton | Create
-
command menuButton_SetTemplate tButtonName
   menuButton_SetDefaultTemplate pText
   
   # Name
   if tButtonName is not empty then
      set the name of the templateButton to tButtonName
      set the label of the templateButton to tButtonName
   end if
end menuButton_SetTemplate

command menuButton_SetDefaultTemplate pText
   # Text
   if pText is empty then put "Item 1" into pText
   set the text of the templateButton to pText
   
   set the lockLoc of the templateButton to true
   set the showBorder of the templateButton to false
   
   # Set some properties to make the button behave as a menu
   set the style of the templateButton to "menu"
   set the menuMode of the templateButton to "pulldown"
   set the opaque of the templateButton to true
   set the autoHilite of the templateButton to true
   set the hiliteBorder of the templateButton to true
   set the armBorder of the templateButton to true
   set the traversalOn of the templateButton to false
   set the showBorder of the templateButton to false
end menuButton_SetDefaultTemplate


--> Private
-
private command _CreateMenuButton newButtonName, pInsertBefore
   -- was "menuBar_CreateButton"
   put the long id of me into mGroup
   --
   put menuBar_ListButtonNames (mGroup) into existingButtonNames
   if newButtonName is among the lines of existingButtonNames then
      return "Error, already a menu button:" && newButtonName && "of"  && mGroup
   end if
   
   put the stack_Name of mGroup into menuBarStackName
   set the defaultStack to menuBarStackName -- for safety
   put the menuBar of stack menuBarStackName into tOriginalMenuBar
   
   # If ordering
   if pInsertBefore is not empty then
      put the menuButton_Num [pInsertBefore] of mGroup into mButtonNum
      put the menuButton_IDs of mGroup into menuButtonIDs
   end if
   
   lock screen
   lock menus
   -- 
   # Create button in mGroup
   menuButton_SetTemplate newButtonName
   --
   create btn in mGroup
   put the short id of it into newButtonID
   --
   reset the templateButton
   
   # Relayer
   if pInsertBefore is not empty then
      line_Insert newButtonID, menuButtonIDs, mButtonNum
      --
      set the menuButton_IDs of mGroup to menuButtonIDs
   else
      dispatch "LayoutControl" to mGroup
   end if
   
   menuBar_Refresh tOriginalMenuBar
   unlock menus
   unlock screen
   --
   return newButtonID
end _CreateMenuButton

private function _RevMenuScript mName
   put scaffold_Get ("Rev Menu Button Script") into mScript
   put merge (mScript) into sScript
   return sScript
end _RevMenuScript

private command _SetRevMenuButtonScripts mNames
   replace comma with CR in mNames
   --
   put the number of lines of mNames into maxNum
   repeat with btnNum = 1 to maxNum
      put the long id of button btnNum of me into mButton
      put mButton & CR after mButtons
      --
      put line btnNum of mNames into mName
      --
      put _RevMenuScript(mName) into mScript
      set the script of mButton to mScript
      --
      edit the script of mButton
   end repeat
   return mButtons
end _SetRevMenuButtonScripts

private command _SetMenuButtonTitle mButton, mTitle, pMenuItemName
   menu_NormalizeGlobalTitle mTitle
   
   # Construct live mData
   put the live_MenuData [mTitle] of mButton into mData
   set the cached_MenuData [mTitle] of mButton to mData
   
   # Set custom property
   if mData is an array then
      set the uOPN ["mTitle"] of mButton to mTitle
   else
      set the uOPN ["mTitle"] of mButton to empty
      return empty
   end if
   
   put mData ["mArray"] into mArray
   put mArray_ToText (mArray) into mText
   set the text of mButton to mText
   
   # Set Name
   if pMenuItemName is empty then
      set the itemdelimiter to "|"
      put word 1 to -1 of item -2 of mTitle into pMenuItemName
   end if
   set the menuButton_Name of mButton to pMenuItemName
   return mData
end _SetMenuButtonTitle
