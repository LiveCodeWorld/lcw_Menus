script "lib_DisplayMenus"
--> MetaData
-
license: GPLv3
name: lib_DisplayMenus
type: library
version: 0.2


--> Display | Events
-
on mDoubleUp_EditMenuScript arrayView, mControllerOrTable
   if exists (mControllerOrTable) is true then
      put mControllerOrTable into mController
      edit the script of mControllerOrTable
   else
      put mControllerOrTable
   end if
end mDoubleUp_EditMenuScript


--> Display | Menus | Old
-
command display_ActiveMenuArray
   global gLCW
   
   put gLCW ["activeMenuArray"] into activeMenuArray
   -- put "Recursion:" && pMenuTitle & ",menu_CheckRecursionOnExtract" into someTitle
   display_Array activeMenuArray, "gLCW ['activeMenuArray']"
end display_ActiveMenuArray


--> Display | Menus
-
command display_Menus
   put menu_GetGlobalArray() into globalMenuArray
   --
   put "mDoubleUp_EditMenuScript" into mDoubleUp
   put empty into iCommand
   put "Global | Menu | Global | Line | Menu" into lineMenu
   put "Global | Menu | Global | Menu" into titleMenu
   --
   display_Array globalMenuArray, "From Disk,Global Menus", lineMenu, lineMenu, iCommand, mDoubleUp
   --
   return the result
end display_Menus

command display_BadMenuArray badMenuArray
   put "mDoubleUp_EditMenuScript" into mDoubleUp
   put empty into iCommand
   put "Global | Menu | Global | Line | Menu" into lineMenu
   put "Global | Menu | Global | Menu" into titleMenu
   --
   display_Array badMenuArray, "Bad Menu Controllers,Global Menus", lineMenu, lineMenu, iCommand, mDoubleUp
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
