script "lib_DisplayMenus"
--> MetaData
-
license: GPLv3
name: lib_DisplayMenus
type: library
version: 0.3

/*
See also lib_DisplayController
*/


--> Working on
-
command display_MenuManager mView
   put the long id of mView into mView
   if matchChunk (mView, "group id .+ of card .*" ) is false then
      return empty
   end if
   put the stack_Name of mView into sName
   --
   get the menubar of stack sName
   put the id of mView into menuID
   put the short name of mView into mName
   set the menubar of stack sName to mName
   --   
   set the cREVMenuID of stack "revMenuManager" to menuID
   set the cREVDefaultStack of stack "revMenuManager" to sName
   set the cREVMenubar of stack "revMenuManager" to mName
   
   -- dispatch "revEditMenubar" to card "Menu Manager" of stack "revMenuManager"
   go to stack "revMenuManager"
   send "revEditMenubar" to card "Menu Manager" of stack "revMenuManager" in 20 ticks
   return mName
end display_MenuManager

command display_EnvironmentMenus pRefreshOnly, pFilterText
   put display_FindArrayView ("Global Menus") into displayView
   --
   if pRefreshOnly is true AND displayView is empty then
      return empty -- display is not open so do nothing
   end if
   --
   put menu_GetGlobalData (pFilterText) into mData
   --
   if pFilterText is empty then
      put "From Disk" into sTitle
   else
      put pFilterText into sTitle
   end if
   --
   display_Data mData, sTitle, "Global Menus", displayView
   --
   put the result into displayView
   set the data_MenuBit of displayView to "Menu | Global"
   return displayView
end display_EnvironmentMenus

function menu_ConstructFilter gMenuTitle, pItemNum
   if pItemNum is empty then put 2 into pItemNum
   set the itemdelimiter to "|"
   get word 1 to -1 of item 1 to pItemNum of gMenuTitle
   put it && "| *"  into sFilter
   return sFilter
end menu_ConstructFilter
    
on mDoubleUp_MenuGlobal displayView, someLine
   put the parent_Array ["mController"] of displayView into mController
   put the selected_Line of displayView into someKey
   --
   switch someKey
      case "gMenuTable"
         display_MenuItems mController
         break
      default
         put someKey
   end switch
   --
   edit the script of mController
end mDoubleUp_MenuGlobal


--> Display | Events
-
on mDoubleUp_ProjectArrayTreeBad arrayView, projectName
   breakpoint
end mDoubleUp_ProjectArrayTreeBad

on mDoubleUp_MenuTree displayView, mItem
   put the title_Text of displayView into gMenuTitle
   --
   if there is not a stack gMenuTitle then
      lcw_Answer "Cannot locate stack '[[gMenuTitle']]", displayView, gMenuTitle
      breakpoint
      exit to top
   end if
   --
   put the name of stack gMenuTitle into hObject
   put hkey_Construct (mItem, "M", hObject) into hKey
   hkey_Edit hKey
   --
   return displayView
end mDoubleUp_MenuTree


--> Display | Menus
-
command display_MenuItems mController
   -- put the short name of mController into mControllerStackName
   -- put the script_MenuTitles of mController into mTitles
   -- put line 1 of the script_GlobalMenuTitles of mController into gMenuTitle
   put the script_Type of mController into sType
   if sType is not among the items of "controller,menu" then return empty
   
   put the script_metadata ["name"] of mController into gMenuTitle
   put the menu_Handlers [gMenuTitle] of mController into mHandlers
   --
   display_Data mHandlers, gMenuTitle, "Menu"
   put the result into displayView
   --
   -- display_SetInteractions displayView, "Menu | Tree", "mDoubleUp_MenuTree"
   set the data_MenuBit of displayView to "Menu | Tree"
   --
   return displayView
end display_MenuItems

command display_BadProjectArray badArray
   display_Array badArray, "Bad Project Array", "LCW Projects"
   set the toll_Menus of the result to "ProjectArray | Tree | Bad"
end display_BadProjectArray

command display_BadMenuArray badMenuArray
   display_Array badMenuArray, "Bad Menu Controllers", "Global Menus"
   put the result into displayView
   display_SetInteractions displayView, "Menu | Global", "mDoubleUp_EditMenuScript"
   --
   return displayView
end display_BadMenuArray

command display_OldMenus
   --/Users/fortyfoxes
   -- /Users/fortyfoxes/Documents/git-repos/LiveCodeWorld/lcw/lcw.livecode
   put $HOME & "/Documents/My Revolution Enterprise/Plugins/opn_Plugins/opn_Libraries/libOPN_Menus.rev" into longStackFile
   if exists (stack longStackFile) is false then
      answer file "Choose the old libOPN_Menus.rev stack..."
      put it into longStackFile
      if longStackFile is empty then
         exit to top
      end if
   end if
   put the cardnames of stack longStackFile into globalMenuCardNames
   sort globalMenuCardNames
   
   put "" into titleMenu
   put "Global | Display | MenuIndex | Line | Menu" into lineMenu
   
   put "mDoubleUp_EditOldMenuScript" into doubleCommand
   put "" into dragCommand
   
   put "Old Global Menus,libOPN_Menus" into displayTitle
   display_Index globalMenuCardNames, displayTitle, titleMenu, lineMenu, empty, doubleCommand, dragCommand
   put the result into displayView
   set the multiple_Hilites of displayView to false
   
   go to stack longStackFile
end display_OldMenus

command display_GlobalMenu mTitle, pAnywhere
   put spotlight_FindGlobalMenu (mTitle, pAnywhere) into foundFiles
   
   put foundFiles
   put lcw_UserMetadataFolder() into inFolder
   display_Files foundFiles, inFolder
   
   put stack_PathsToNames (foundFiles) into stackNames
   if stackNames is empty then
      answer "No stacks!"
      exit to top
   end if
   
   put merge ("[[mTitle]],Found Global Menus") into someTitle
   display_Index stackNames, someTitle,"Global | View | Tree | Menu", mLineTitle, mUp, "mDouble_DisplayStack"
   put the result into indexView
   set the multiple_Hilites of indexView to false
end display_GlobalMenu
