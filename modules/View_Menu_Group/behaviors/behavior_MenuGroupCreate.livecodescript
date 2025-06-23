script "behavior_MenuGroupCreate" with behavior "behavior_ViewMenuGroupDeps"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_MenuGroupCreate
type: behavior
version: 0.3

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.*/


--> Working on
-
function _TableFromTitles mTitles
   replace comma with CR in mTitles
   put the number of lines of mTitles into maxNum
   set the itemdelimiter to "|"
   repeat with mNum = 1 to maxNum
      put line mNum of mTitles into mTitle
      put word 1 to -1 of item -2 of mTitle into mName
      put mName & ":" & mTitle & CR after mTable
   end repeat
   delete char -1 of mTable
   return mTable
end _TableFromTitles


--> Menuar | Table
-
setprop menubar_Table [pAppend] mTable
   -- put "File:Rev, Edit:Rev, Tools, Menu:Global|Menu|Group|Tools|Menu, Help:Rev" into mTable
   replace comma with CR in mTable
   put the menuBar of the defaultstack into tOriginalMenuBar
   --
   lock screen
   lock menus
   menuButton_SetTemplate
   
   put the number of lines of mTable into maxNum
   set the itemdelimiter to ":"
   repeat with lineNum = 1 to maxNum
      put line lineNum of mTable into mLine
      put word 1 to -1 of item 1 of mLine into mName
      
      # Ducktyping
      get word 1 to -1 of item 2 of mLine
      if it is among the items of "rev,live,mTitle,script" then
         put it into mUpdateStyle
         breakpoint
      else if it is not empty then
         put it into mTitle
      end if
      --
      get word 1 to -1 of item 3 of mLine
      if it is among the items of "rev,live,mTitle,script" then
         put it into mUpdateStyle
         breakpoint
      else if it is empty then
         put "mTitle" into mUpdateStyle
      else
         put it into mTitle
      end if
      
      # Create if it does not exist
      switch
         case pAppend is not false
            -- case exists (btn lineNum of me) is false
            if exists (btn mName of me) is true then
               put the long id of btn mName of me into mButton
            else
               create button mName in me
               put the long id of it into mButton
            end if
            break
         default
            put the long id of btn mName of me into mButton
            -- put the long id of btn lineNum of me into mButton
      end switch

      
      # Set
      set the menuButton_Title [mName] of mButton to mTitle
      --
      _SetMenuButtonTarget mButton, mTitle
      --
      -- from ducktyping
      set the menuButton_UpdateStyle of mButton to mUpdateStyle
      --
   end repeat
   delete char -1 of mButtons
   
   # Delete any extras
   if pAppend is not true then
      put the number of buttons of me into lastButtonNum
      repeat with btnNum = lastButtonNum down to (maxNum +1)
         delete btn btnNum of me
      end repeat
   end if
   
   reset the templateButton
   LayoutControl
   menuBar_Refresh tOriginalMenuBar
   unlock menus
   unlock screen
   --
   return mButtons
end menubar_Table

setprop menubar_DefaultTable mTable
   -- used by menu_Init of beahior_WikiBrowserCard
   put menubar_ConstructTable (mTable) into mTable -- eg "Browser-Default"
   --
   put menubar_TableToArray (mTable) into menubarArray
   repeat with mNum = 1 to the number of buttons of me
      put the short name of btn mNum of me into mName
      put menubarArray [mName] into mTitle
      --
      if mTitle is empty then
         set the menuButton_Title of btn mNum of me to mName
      else
         set the menuButton_Title [mName] of btn mNum of me to mTitle
      end if
   end repeat
end menubar_DefaultTable

function menubar_ConstructTable mTable
   switch pTableName
      case "Browser-Default"
         return "File-Rev,Edit-Rev,Tools,Menu-Global|Menu|Group|Exists|Menu,Help-Rev"
      default
         return mTable
   end switch
end menubar_ConstructTable

function menubar_TableToArray mTable
   replace comma with CR in mTable
   split mTable with CR and "-"
   return mTable
end menubar_TableToArray


--> Menubar
-
getprop menubar_DefaultTitles
   put the module_Name of the target into stackName
   if stackName is empty then
      put the project_Name of me into stackName
      put the project_MenuTitle of stack stackName into defaultMenu
      -- put the project_ControllerStackNames of stack stackName into mTitles
      put empty into mTitles
   else
      put the module_MenuTitle of stack stackName into defaultMenu
      put the module_ControllerStackNames of stack stackName into mTitles
   end if
   
   if mTitles is empty then
      put defaultMenu into defaultMenuTitles
   else
      filter mTitles without "* | Dev | Menu"
      line_Delete defaultMenu, mTitles
      put defaultMenu & CR & mTitles into defaultMenuTitles
   end if
   
   # Add a Edit Menu if needed
   if line 2 of defaultMenuTitles ends with "| Edit | Menu" is false then
      put CR & "Global | Menu | Group | Edit | Menu" after line 1 of defaultMenuTitles
   end if
   
   # Add Help Menu if needed
   put lineOffset (" | Help | Menu", defaultMenuTitles) into lineNum
   if lineNum > 0 then
      put line lineNum of defaultMenuTitles into helpTitle
      delete line lineNum of defaultMenuTitles
      put CR & helpTitle after defaultMenuTitles
   else
      put CR & "Global | Menu | Group | Help | Menu" after defaultMenuTitles
   end if
   return word 1 to -1 of defaultMenuTitles
end menubar_DefaultTitles


--> MenuButton | Array
-
setprop menuButton_Array buttonArray
   # Deconstruct ButtonArray
   put buttonArray ["m mNum"] into mNum
   put buttonArray ["m id"] into sID
   put buttonArray ["m mButton"] into mButton
   if exists (mButton) is false then
      breakpoint -- something went wrong
      put the long id of button mNum into mButton
   end if
   
   # Name
   put buttonArray ["m mName"] into sName
   if sName is not empty then
      set the menuButton_Name of mButton to sName
   end if
   
   # mUpdateStyle
   put buttonArray ["m mUpdateStyle"] into mUpdateStyle
   if mUpdateStyle is not empty then
      set the menuButton_UpdateStyle of mButton to mUpdateStyle
   end if
   
   # mTarget
   put buttonArray ["m mTarget"] into mTarget
   if mTarget is not empty then
      set the menuButton_Target of mButton to mTarget
   end if
   
   # mController
   put buttonArray ["m mController"] into mController
   if mController is not empty then
      set the menuButton_Controller of mButton to mController
   end if
   
   put buttonArray ["m cachedArray"] into cachedArray
   if cachedArray is an array then
      set the menuButton_CachedArray of mButton to mController
   end if
   
   # mTitle
   put buttonArray ["m mTitle"] into mTitle
   if mTitle is not empty then
      set the menuButton_Title of mButton to mTitle
   end if
   
   return mButton
end menuButton_Array

getprop menuButton_Array
   put the long id of the target into mButton
   
   # Collect mButton Data
   put the short id of mButton into sID
   put the short name of mButton into sName
   put revRuggedID (mButton) into rButton
   put the menuButton_Controller of mButton into mController
   put revRuggedID (mController) into rController
   put the menuButton_Target of mButton into mTarget
   put revRuggedID (mTarget) into rTarget
   put the menuButton_Title of mButton into mTitle
   put the uOPN ["mUpdateStyle"] of mButton into mUpdateStyle
   put the menuButton_CachedArray of mButton into cachedArray
   
   # Construct ButtonArray
   put rButton into buttonArray ["m mButton"]
   put sID into buttonArray ["m id"]
   --
   put mNum into buttonArray ["m mNum"]
   put sName into buttonArray ["m mName"]
   put mTitle into buttonArray ["m mTitle"]
   put mUpdateStyle into buttonArray ["m mUpdateStyle"]
   --
   put rController into buttonArray ["m mController"]
   put rTarget into buttonArray ["m mTarget"]
   put cachedArray into buttonArray ["m cachedArray"]
   --
   return buttonArray
end menuButton_Array

private command _SetMenuButtonTarget mButton, mTitle
   /*
   Let's get a default guess from mController
   If getprop menu_Target of mController is not empty
   we can always set the menuButton_Target manually later
   */
   
   put _MenuTargetGuess (mTitle, mButton) into mTargetGuess
   set the menuButton_Target of mButton to mTargetGuess
end _SetMenuButtonTarget

private function _MenuTargetGuess mTitle, mButton
   -- only used by menuButton_Title
   -- put the menuBar_Owner of me into cardObject
   
   # Guess the target object
   put the menu_TargetGuess of me into tObject -- overide on card behavior to be safe
   if tObject is empty then
      -- Assume that the target object was the menubutton clicked on
      put mButton into tObject
   end if
   
   # Work out mTarget from Controller
   put _MenuTitleController (mTitle, mButton) into mController
   if exists (mController) is false then return tObject
   --
   put the menu_Target [tObject] of mController into mTarget   
   return mTarget
end _MenuTargetGuess

private function _MenuTitleController mTitle, mButton
   # Stored custom property (ie for script fork)
   put the uOPN ["menu_Controller"] of mButton into mController
   if exists (mController) then return mController
   
   # Default to stack name mTitle
   put menu_GetGlobalController (mTitle) into mController
   if exists (mController) is true then return mController
   
   return mButton
end _MenuTitleController

getprop menubar_Titles
   repeat with mNum = 1 to the number of buttons of me
      put the uOPN ["mTitle"] of btn mNum of me into mTitle
      put mTitle & CR after mTitles
   end repeat
   delete char -1 of mTitles
   return mTitles
end menubar_Titles

setprop menubar_Titles [pAppend] mTitles
   switch
      case mTitles is empty
         menuBar_DeleteMenuButtons
         return empty
      case mTitles = "rev"
         _SetRevMenuButtonScripts "File,Edit,Tools,Help"
         return the result
      default
         put _TableFromTitles (mTitles) into mTable
         set the menubar_Table [pAppend] of me to mTable
   end switch
end menubar_Titles

setprop menubar_Lables [pAppend] mTitles
   switch
      case mTitles is empty
         menuBar_DeleteMenuButtons
         return empty
      case mTitles = "rev"
         _SetRevMenuButtonScripts "File,Edit,Tools,Help"
         return the result
      default
         put menubar_TableFromNames (mTitles) into mTable
         set the menubar_Table [pAppend] of me to mTable
         return mTable
   end switch
end menubar_Lables

getprop menubar_Table [mNames]
   put menubar_TableFromNames (mNames, false) into mTable
   return mTable
end menubar_Table

command menuBar_DeleteMenuButtons pMenuButtonIDs
   if pMenuButtonIDs is empty then
      put the childControlIDs of me into pMenuButtonIDs
   end if
   
   lock screen
   --
   repeat for each line btnID in pMenuButtonIDs
      delete btn id btnID of me
   end repeat
   LayoutControl
   --
   unlock screen
end menuBar_DeleteMenuButtons


--> MenuButton | mController
-
getprop menu_Controller [mTitle]
   put _MenuButton (mTitle) into mButton
   put _MenuTitleController (mTitle, mButton) into mController
   return mController
end menu_Controller

setprop menu_Controller mController
   put _MenuButton (pMenuTitle) into mButton
   if exists (mButton) is false then
      breakpoint
      return empty
   end if
   --
   set the uOPN ["menu_Controller"] of mButton to mController
end menu_Controller


--> MenuButton | mTitle
-
setprop menuButton_Title [mName] mTitle
   -- Must be called on menuButton
   -- uses put _MenuTargetGuess (mTitle, mButton) into mTarget
   
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
   
   # Set mTitle
   switch mTitle
      case "Rev"
         # Experimental Rev
         set the menuButton_RevScript of mButton to mName
         put the result into mText
         return mText
      default
         set the uOPN ["mUpdateStyle"] of mButton to "mTitle"
         set the uOPN ["mTitle"] of mButton to mTitle
         set the script of mButton to empty
         
         # Set mTarget
         -- do this separately???
         /*
         set the menuButton_Target of mButton to mTarget
         
         -- put _MenuTargetGuess (mTitle, mButton) into mTarget
         -- set the uOPN ["mTarget"] of mButton to mTarget
         -- put the menuButton_Target of mButton into mTarget
         -- if mTarget is empty then
         if exists (mTarget) then
            breakpoint -- we only use fixed mTarget objects for each menuButton ???
         end if
         */
         
         # Check live_MenuArray
         put the live_MenuArray of mButton into mArray
         if mArray is not an array then
            set the uOPN ["mTitle"] of mButton to empty
            return empty  
         end if
         
         # Set Menu Text
         put mArray_ToText (mArray) into mText
         set the text of mButton to mText
         
         # Set menuButton_CachedArray
         set the menuButton_CachedArray of mButton to mArray
         return mArray
   end switch
end menuButton_Title

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


--> MenuController
-
function menu_GetGlobalController mTitle
   if there is a stack mTitle then
      return the name of stack mTitle
   else
      return empty
   end if
end menu_GetGlobalController


--> Menubutton
-
getprop menuButton_UniqueName
   put the long id of me into mGroup
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   put the number of lines of mButtonNames into newNum
   add 1 to newNum
   put "Item" && newNum into newName
   return newName
end menuButton_UniqueName

setprop menuButton_NameAndTitle [mName] mTitle
   # Work out mTitle from name
   put _ConstructMenuTitle (mTitle, mName) into mTitle
   
   put mName into buttonArray ["m mName"]
   put mTitle into buttonArray ["m mTitle"]
   put mUpdateStyle into buttonArray ["m mUpdateStyle"]
   
   set the menuButton_Array of the target to buttonArray
   put the result into mButton
   return mButton
end menuButton_NameAndTitle


--> MenuButton | New and Delete
-
setprop new_MenuButton [pInsertBefore] mTitleOrButtonName
   put the menuBar_View of the target into mGroup
   
   # Set newButtonName and mTitle
   if mTitleOrButtonName contains "|" then
      set the itemdelimiter to "|"
      put mTitleOrButtonName into mTitle
      put item -2 of mTitle into newButtonName      
   else
      put mTitleOrButtonName into newButtonName
      put empty into mTitle
   end if
   
   # Tidy
   put word 1 to -1 of newButtonName into newButtonName
   
   # Create
   menuBar_CreateButton newButtonName, mGroup, pInsertBefore
   put the result into newButtonID
   
   # Maybe set menuButton_Title
   if mTitle is not empty then
      set the menuButton_Title [newButtonName] of btn id newButtonID of mGroup to mTitle
   end if
   
   # Return something useful
   put the long id of btn id newButtonID into mButton
   return mButton
end new_MenuButton

command menuButton_Delete mName
   put _NameToNum (mName) into mButtonNum
   if mButtonNum is empty then return "Error, button of this name does not exoist in this menu:" && mName
   
   put the menuBar of the defaultstack into tOriginalMenuBar
   lock screen
   lock menus
   -- 
   delete button mButtonNum of me
   _LayoutMenuButtons
   put the result into mButtonIDs
   --
   menuBar_Refresh tOriginalMenuBar
   unlock menus
   unlock screen
   --
   return mButtonIDs
end menuButton_Delete

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


--> MenuButton | TableData
-
getprop menubar_TableData
   -- rename to "menubar_Data"?
   repeat with mNum = 1 to the number of buttons of me
      put the long id of btn mNum of me into mButton
      --
      put the menuButton_Array of mButton into menubarData [mNum]
      
      /*
      put mNum into menubarData [mNum]["m mNum"]
      put the short name of mButton into menubarData [mNum]["m mName"]
      --
      put revRuggedID (mButton) into menubarData [mNum]["m mButton"]
      put the short id of mButton into menubarData [mNum]["m id"]
      --
      put the menuButton_Title of mButton into menubarData [mNum]["m mTitle"]
      put the uOPN ["mUpdateStyle"] of mButton into menubarData [mNum]["m mUpdateStyle"]
      --
      put the menuButton_Controller of mButton into mController
      put the menuButton_Target of mButton into mTarget
      put revRuggedID (mController) into menubarData [mNum]["m mController"]
      put revRuggedID (mTarget) into menubarData [mNum]["m mTarget"]
      --
      put the menuButton_CachedArray of mButton into menubarData [mNum]["m cachedArray"]
      */
   end repeat
   --
   return menubarData
end menubar_TableData

private function _ConstructMenuTitle mTitle, mName
   switch
      case mTitle = "Default"
         put _ModuleMenuTitle (mName) into mTitle
         break
      case mTitle contains "|"
         menu_NormalizeGlobalTitle mTitle, true
         break
      case mTitle = empty
         put _ModuleMenuTitle (mName) into mTitle
         break
      default
         # Single plain word?
         put _ModuleMenuTitle (mTitle) into mTitle
   end switch
   return mTitle
end _ConstructMenuTitle

function _ModuleMenuTitle mName
   put the menuBar_Owner of me into viewObject -- assume it is the card
   put the module_MenuTitle of viewObject into mTitle
   return mTitle
end _ModuleMenuTitle

command menu_NormalizeGlobalTitle @mTitle
   menu_NormalizeTitle mTitle
   set the itemdelimiter to " | "
   if item 1 of mTitle is not "Global" then put "Global | " before mTitle
   if item -1 of mTitle is not "Menu" then put " | Menu" after mTitle
end menu_NormalizeGlobalTitle


--> Create
-
command menuButton_CreateAtEnd mName, pBeforeNum
   lock menus
   put the menuBar of the defaultStack into oMenuBar
   put the childControlIDs of me into menuButtonIDs
   --
   _CreateMenuButtonAtEnd mName
   put the result into mButton
   --
   if pBeforeNum is a number then
      put the short id of mButton into newID
      put newID & CR before line pBeforeNum of menuButtonIDs
      _LayoutMenuButtons menuButtonIDs
   end if
   --
   menuBar_Refresh oMenuBar
   unlock menus
   --
   return mButton
end menuButton_CreateAtEnd

getprop menuButton_Names
   return _ListButtonNames()
end menuButton_Names

private function _ListButtonNames
   repeat with mNum = 1 to the number of buttons of me
      put the short name of btn mNum of me into mName
      put mName & CR after mButtonNames
   end repeat
   delete char -1 of mButtonNames
   return mButtonNames
end _ListButtonNames

setprop menuButton_Names newButtonNames
   lock menus
   put the menuBar of the defaultStack into oMenuBar
   --
   _SetNameOrder newButtonNames
   --
   menuBar_Refresh oMenuBar
   unlock menus
   --
   return menuButtonIDs
end menuButton_Names

private command _SetNameOrder newButtonNames
   lock screen
   -- 
   replace comma with CR in newButtonNames
   put _ListButtonNames() into oButtonNames
   
   # Delete old menu buttons
   put oButtonNames into btnsToDelete
   line_DeleteIndex btnsToDelete, newButtonNames
   repeat for each line btnName in btnsToDelete
      delete btn btnName of me
   end repeat
   
   repeat for each line newButtonName in newButtonNames
      if newButtonName is not among the lines of oButtonNames then
         # Create
         _CreateMenuButtonAtEnd newButtonName
         put the result into newButton
      end if
      --
      put the short id of btn newButtonName of me into btnID
      put btnID & CR after menuButtonIDs
   end repeat
   delete char -1 of menuButtonIDs
   
   # Relayer to order
   _LayoutMenuButtons menuButtonIDs
   unlock screen
   
   return menuButtonIDs
end _SetNameOrder

getprop menuBar_IdOrder
   put the childControlIDs of me into menuButtonIDs
   return menuButtonIDs
end menuBar_IdOrder

setprop menuBar_IdOrder menuButtonIDs
   replace comma with CR in menuButtonIDs
   if menuButtonIDs is empty then
      put the childControlIDs of me into menuButtonIDs
   end if
   _LayoutMenuButtons menuButtonIDs
end menuBar_IdOrder

command menuBar_OptionEdit numOrName
   if the optionKey is not "Down" then return empty
   
   put the menuButton_Object [numOrName] of me into mButton
   if exists (mButton) is false then return empty
   
   breakpoint
   if the optionKey is "Down" then
      edit the script of mButton
      exit to top
   end if
   return mButton
end menuBar_OptionEdit

setprop delete_Menu numOrName
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   lock menus
   put the menuBar of the defaultStack into oMenuBar
   --
   lock screen
   put the short id of mButton into btnID
   delete btn id btnID of me
   LayoutControl
   unlock screen
   --
   menuBar_Refresh oMenuBar
   unlock menus
   
   return mButton
end delete_Menu

setprop rev_Menu [mNum] revName
   menuBar_OptionEdit mNum
   if rev_CheckMenuName (revName) is false then return empty
   --
   menuButton_CreateIfNeeded mNum, revName
   put the result into mButton
   
   # Rev Text
   set the menuButton_RevText of mButton to revName
   
   # Rev Script
   put _RevMenuScript (revName) into mScript
   set the script of mButton to mScript
   
   # Menu metadata
   put the short name of mButton into mName
   set the uOPN ["mUpdateStyle"] of mButton to "Rev"
   set the uOPN ["mTitle"] of mButton to mName
   set the menuButton_CachedArray of mButton to empty
   --
   return mButton
end rev_Menu

command menuButton_CreateIfNeeded mNum, newName
   put the number of buttons of me into maxNum
   switch
      case mNum is not a number
      case mNum < 0
      case mNum > maxNum
         menuButton_CreateAtEnd newName
         put the result into mButton
         break
      default
         put the long id of btn mNum of me into mButton
         set the name of mButton to newName
         set the label of mButton to newName
   end switch
   return mButton
end menuButton_CreateIfNeeded

private command _CreateMenuButtonAtEnd mName
   lock screen
   --
   menuButton_SetTemplate mName
   create btn in me
   put the long id of it into mButton
   reset the templateButton
   --
   LayoutControl
   --
   unlock screen
   return mButton
end _CreateMenuButtonAtEnd

private command _CreateMenuButton newButtonName, pInsertBeforeButtonNum
   -- was "menuBar_CreateButton"
   put the long id of me into mGroup
   
   # Check new
   put menuBar_ListButtonNames (mGroup) into existingButtonNames
   if newButtonName is among the lines of existingButtonNames then
      return "Error, already a menu button:" && newButtonName && "of"  && mGroup
   end if
   
   # If ordering
   put the menuButton_IDs of mGroup into oMenuButtonIDs
   switch 
      case pInsertBeforeButtonNum is empty
         put 0 into insertBeforeButtonNum
         break
      case pInsertBeforeButtonNum is a number
         put pInsertBeforeButtonNum into insertBeforeButtonNum
         break
      default
         set the wholematches to true
         put lineOffset (pInsertBeforeButtonNum, existingButtonNames) into insertBeforeButtonNum
   end switch
   
   put the stack_Name of mGroup into menuBarStackName
   --
   set the defaultStack to menuBarStackName -- for safety
   put the menuBar of stack menuBarStackName into tOriginalMenuBar
   
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
   if insertBeforeButtonNum > 0 then
      put oMenuButtonIDs into newMnuButtonIDs
      line_Insert newButtonID, newMnuButtonIDs, insertBeforeButtonNum
      set the menuButton_IDs of mGroup to newMnuButtonIDs
   else
      dispatch "LayoutControl" to mGroup
   end if
   
   menuBar_Refresh tOriginalMenuBar
   unlock menus
   unlock screen
   --
   return newButtonID
end _CreateMenuButton

setprop menuButton_RevScript [numOrName] mName
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   
   # Set props
   set the uOPN ["mUpdateStyle"] of mButton to "Rev"
   set the uOPN ["mTitle"] of mButton to mName
   set the menuButton_CachedArray of mButton to empty
   
   # Set mScript
   put _RevMenuScript (mName) into mScript
   set the script of mButton to mScript
   
   # Set mText
   set the menuButton_RevText [numOrName] of mButton to mName
   
   # Set props (not needed)
   -- menuButton_SetProps mButton
   --
   return mText
end menuButton_RevScript

private command menuButton_SetProps mButton
   # Set some properties to make the button behave as a menu
   set the lockLoc of mButton to true
   set the showBorder of mButton to false
   --
   set the style of mButton to "menu"
   set the menuMode of mButton to "pulldown"
   set the opaque of mButton to true
   set the autoHilite of mButton to true
   set the hiliteBorder of mButton to true
   set the armBorder of mButton to true
   set the traversalOn of mButton to false
   set the showBorder of mButton to false
   --
   return the properties of mButton
end menuButton_SetProps

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


--> Props
-
getprop menuButton_Name [numOrName]
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --
   put the short name of mButton into mName
   return mName
end menuButton_Name

setprop menuButton_Name [numOrName] mName
   put the menuButton_Object [numOrName] of the target into mButton
   if exists (mButton) is false then return empty
   --  
   set the name of mButton to mName
   set the label of mButton to mName
   return mButton
end menuButton_Name


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


--> Private
-
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
