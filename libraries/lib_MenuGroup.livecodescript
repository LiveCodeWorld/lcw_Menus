script "lib_MenuGroup"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_MenuGroup
type: library
version: 0.3

/*
A library to help manage and create menubars.
*/


--> Working on
-
on EnableStatusMenu pEnabled
   macStatusMenuSet "David", "enabled", pEnabled
   if pEnabled then
      -- macStatusMenuSet "David", "icon", the long id of image "enabled"
      macStatusMenuSet "David", "items", "Open" & return & "-" & return & "Settings" 
   else
      -- macStatusMenuSet "David", "icon", the long id of image "disabled"
      macStatusMenuSet "David", "items", empty
   end if
end EnableStatusMenu


--> Display
-
command display_MenuManager mGroup
   put the stack_Name of mGroup into sName
   put the id of mGroup into menuID
   -- put the menubar of stack sName into mName
   put the short name of mGroup into mName
   --   
   set the cREVMenuID of stack "revMenuManager" to menuID
   set the cREVDefaultStack of stack "revMenuManager" to sName
   set the cREVMenubar of stack "revMenuManager" to mName
   
   go to stack "revMenuManager"
   put menuBar_ManagerCard() into menuManagerCard
   dispatch "revEditMenubar" to menuManagerCard
end display_MenuManager

getprop menubar_IsActive
   put the menubar of the defaultstack into mName
   put mName is not empty into sBoolean
   return sBoolean
end menubar_IsActive

getprop menubar_View
   -- default (make a local version)
   put the card_Object of the target into cObject
   put the childControlIDs of cObject into someIDs
   repeat for each line someID in someIDs
      put the long id of control id someID into testObject
      if word 1 of testObject = "group" then
         put the uRIP["name"] of testObject into viewName
         if viewName = "View|Menu|Group" then
            -- if viewName begins with "View|Menu|Group" then
            return testObject
         end if
      end if
   end repeat
   return empty
end menubar_View

getprop menubar_Name
   put the menubar_View of the target into mView
   put the short name of mView into mName
   return mName
end menubar_Name


--> Props | Move to behavior?
-
getprop menuBar_ButtonNames
   put the menubar_View of the target into mGroup
   --
   put menuBar_ListButtonNames (mGroup) into mButtonNames
   return mButtonNames
end menuBar_ButtonNames

setprop menuBar_ButtonNames newButtonNames
   put the menubar_View of the target into mGroup
   replace comma with CR in newButtonNames
   put menuBar_ListButtonNames (mGroup) into oButtonNames
   --
   if index_CheckSameItems (oButtonNames, newButtonNames) is false then
      return "Error, new button names are different for existing names"
   end if
   
   repeat for each line newButtonName in newButtonNames
      put the short id of btn newButtonName of mGroup into btnID
      put btnID & CR after menuButtonIDs
   end repeat
   delete char -1 of menuButtonIDs
   
   set the menuBar_IdOrder of mGroup to menuButtonIDs
   return menuButtonIDs
end menuBar_ButtonNames

function menuBar_ListButtonNames mGroup
   put the childControlIDs of mGroup into tMenuButtonIDs
   repeat for each line btnID in tMenuButtonIDs
      put the short name of btn id btnID of mGroup into btnName
      put btnName & CR after mButtonNames
   end repeat
   delete char -1 of mButtonNames
   return mButtonNames
end menuBar_ListButtonNames


--> Menubar | Create
-
command menubar_Insert sView
   put the menubar_View of sView into mGroup
   if exists (mGroup) is true then
      breakpoint
   end if
   
   put the card_Object of sView into cardObject
   lcw_Answer "Sure you want to create a menubar view on this card?", cardObject
   --
   view_InsertFromPath "View|Menu|Group", cardObject
   put the result into mGroup
   set the topleft of mGroup to 0,0
   --
   set the show_menu of mGroup to true
   return mGroup
end menubar_Insert

command menubar_Delete mGroup
   put the stack_Name of mGroup into stackName
   save stack stackName
   --
   put the defaultMenuBar into tOriginalDefaultMenuBar
   set the defaultMenuBar to ide_DefaultMenuGroup()
   --
   delete mGroup
   --
   set the menuBar of stack stackName to empty
   set the defaultMenuBar to tOriginalDefaultMenuBar
end menubar_Delete


--> MenuButton | Create
-
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
   
   menuBar_CreateButton newButtonName, mGroup, pInsertBefore
   put the result into newButtonID
   
   if mTitle is not empty then
      set the menuButton_Title [newButtonName] of mGroup to mTitle
   end if
   return newButtonID
end new_MenuButton

command menuBar_CreateButton newButtonName, mGroup, pInsertBeforeButtonNum
   # If ordering
   if pInsertBeforeButtonNum is not empty then
      put pInsertBeforeButtonNum into mButtonNum
      put the menuButton_IDs of mGroup into menuButtonIDs
   end if
   
   put menuBar_ListButtonNames (mGroup) into existingButtonNames
   if newButtonName is among the lines of existingButtonNames then
      return "Error, already a menu button:" && newButtonName && "of"  && mGroup
   end if
   
   put the stack_Name of mGroup into menuBarStackName
   set the defaultStack to menuBarStackName -- for safety
   put the menuBar of stack menuBarStackName into tOriginalMenuBar
   
   lock screen
   lock menus
   -- 
   # Create button in mGroup
   menuBar_SetButtonTemplate newButtonName
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
   
   --
   menuBar_Refresh tOriginalMenuBar
   unlock menus
   unlock screen
   --
   return newButtonID
end menuBar_CreateButton

command menuBar_SetButtonTemplate tButtonName
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
   
   # Other properties    
   set the name of the templateButton to tButtonName
   set the label of the templateButton to tButtonName
   set the text of the templateButton to "Item 1"
end menuBar_SetButtonTemplate

command menuBar_RelayerMenuButtons mGroup, pMenuButtonIDs
   # Layout buttons from left to right according to order in Menu Buttons field
   if pMenuButtonIDs is empty then
      put the childControlIDs of mGroup into pMenuButtonIDs
   end if
   
   set the menuBar_IdOrder of mGroup to pMenuButtonIDs
   return the result
end menuBar_RelayerMenuButtons


--> Menubar
-
function menubar_IsDefault
   -- put the long name of group "revMenuBar" of stack revIDEPaletteToStackName ("menubar") into ideDefaultMenuBar
   put the defaultMenuBar into dBar -- in long name format
   put ide_DefaultMenuGroup() into ideDefaultMenuBar
   return ideDefaultMenuBar = the long id of dBar
end menubar_IsDefault

command menubar_TogglePreview mGroup
   put menubar_IsDefault() into isDefault
   --
   put the stack_Name of mGroup into sName    
   if isDefault is true then
      put the short name of mGroup into mName
      set the menubar of stack sName to mName
      set the defaultMenuBar to mName
   else
      set the menubar of stack sName to empty
      ide_ResetDefaultmenubar
   end if
end menubar_TogglePreview

function menuManager_GetArray
   put revIDEPaletteToStackName("menubar") into mmStackName
   put the customKeys of stack mmStackName into mmArray
   return mmStackName
end menuManager_GetArray

command menuBar_ToggleShowMenu mGroup
   put the show_Menu of mGroup into sBoolean
   set the show_Menu of mGroup to (sBoolean is false)
   return sBoolean is false
end menuBar_ToggleShowMenu

command menuBar_ToggleEditMenus mGroup
   put the stack_Name of mGroup into stackName
   --
   put the editMenus of stack stackName into sBoolean
   set the editMenus of stack stackName to (sBoolean is false)
   return sBoolean is false
end menuBar_ToggleEditMenus

command menuBar_Refresh tOriginalMenuBar
   # Need to reset the menubar to have it update
   put the defaultMenuBar into tOriginalDefaultMenuBar
   
   set the menuBar of this stack to empty
   set the defaultMenuBar to ide_DefaultMenuGroup()
   --
   set the menuBar of this stack to tOriginalMenuBar
   set the defaultMenuBar to tOriginalDefaultMenuBar
end menuBar_Refresh


--> Objects
-
function menuManager_Stack
   put the name of stack "revMenuManager" into menuManagerStack
   return menuManagerStack   
end menuManager_Stack

-- function menuManager_MenuCardID
-- seems to be empty
put menuManager_Stack() into menuManagerStack
--
put the cREVMenuButtonCardID of menuManagerStack into tCardID
return tCardID
end menuManager_MenuCardID

function menuManager_Card
   put menuManager_Stack() into menuManagerStack
   --
   put the long id of card "Menu Manager" of menuManagerStack into menuManagerCard
   return menuManagerCard
end menuManager_Card


--> MenuManager
-
function menuManager_Name
   put the num of lines in fld "Menu Buttons" + 1 into tNum  
   put revNewMenuName (mGroup, tNum) into tButtonName
   return tButtonName
end menuManager_Name

function menuManager_MenubarStack
   put menuManager_MenubarStackName() into mBarStackName
   if exists (stack mBarStackName) is false then return empty
   
   return the name of stack mBarStackName
end menuManager_MenubarStack

function menuManager_MenubarStackName
   put menuManager_Stack() into mManagerStack
   --
   put the cREVDefaultStack of mManagerStack into menuBarStackName
   return menuBarStackName
end menuManager_MenubarStackName

function menuManager_MenuID
   put menuManager_Stack() into mManagerStack
   --
   put the cREVMenuID of mManagerStack into mGroupID
   return mGroupID
end menuManager_MenuID

function menuManager_MenuButtonIDs
   put menuManager_Stack() into mManagerStack
   --
   put the cREVMenuButtonIDs of mManagerStack into tMenuButtonIDs
   return tMenuButtonIDs
end menuManager_MenuButtonIDs

function menuManager_MenuGroup
   put menuManager_MenubarStackName() into mBarStackName
   if exists (stack mBarStackName) is false then return empty
   
   put menuManager_MenuID() into mGroupID 
   if exists (bg id mGroupID of stack mBarStackName) is false then return empty
   
   put the long id of bg id mGroupID of stack mBarStackName into mGroup
   return mGroup
end menuManager_MenuGroup
