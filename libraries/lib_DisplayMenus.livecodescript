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
function menu_GetGlobalData pFilterText
   put menu_GetGlobalArray() into mGlobalArray
   --
   set the itemdelimiter to "|"
   repeat for each key gMenuTitle in mGlobalArray
      if pFilterText is not empty then
         put item 2 to -2 of gMenuTitle into mBit
         put mBit contains pFilterText into isGood
         if isGood is false then
            next repeat
         end if
      end if
      
      put mGlobalArray [gMenuTitle] into mData [gMenuTitle]
      put mData [gMenuTitle]["mController"] into mController
      if exists (mController) is false then
         put empty into mData [gMenuTitle]["stack name"]
      else
         put the short name of mController into mData [gMenuTitle]["stack name"]
      end if
   end repeat
   --
   return mData
end menu_GetGlobalData


--> Display | Events
-
on mDoubleUp_DisplayProject arrayView, projectName
   put the params
end mDoubleUp_DisplayProject

on mDoubleUp_EditMenuScript displayView, someLine
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
end mDoubleUp_EditMenuScript

on mDoubleUp_MenuItem displayView, mItem
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
end mDoubleUp_MenuItem


--> Display | Menus
-
command display_EnvironmentMenus pFilterText
   put menu_GetGlobalData (pFilterText) into mData
   --
   display_Data mData, "From Disk", "Global Menus"
   put the result into displayView
   display_SetInteractions displayView, "Menu | Global", "mDoubleUp_EditMenuScript"
   --
   return displayView
end display_EnvironmentMenus

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
   display_SetInteractions displayView, "Menu | Tree", "mDoubleUp_MenuItem"
   --
   return displayView
end display_MenuItems

command display_BadProjectArray badArray
   local lineMenu, iCpmmand
   
   put "mDoubleUp_DisplayProject" into mDoubleClick
   put "Global | ProjectArray | Tree | Bad" into titleMenu
   --
   display_Array badArray, "Bad Project Array,LCW Projects", titleMenu, lineMenu, iCpmmand, mDoubleClick
end display_BadProjectArray

command display_BadMenuArray badMenuArray
   put "mDoubleUp_EditMenuScript" into mDoubleClick
   put empty into iCommand
   put "Global | Menu | Global | Line | Menu" into lineMenu
   put "Global | Menu | Global | Menu" into titleMenu
   --
   display_Array badMenuArray, "Bad Menu Controllers,Global Menus", titleMenu, lineMenu, iCommand, mDoubleClick
   --
   return the result
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
