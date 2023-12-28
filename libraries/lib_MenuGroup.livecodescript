script "lib_MenuGroup"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_MenuGroup
type: library
version: 0.1

/*Some help*/


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


--> Props | Move to behavior?
-
getprop menubar_Name
   put the menubar_View of the target into mView
   put the short name of mView into mName
   return mName
end menubar_Name

setprop menubar_Name mName
   put the menubar_View of the target into mView
   set the name of mView to mName
   return mView
end menubar_Name

getprop menubar_View
   put the card_Object of the target into cObject
   put the childControlIDs of cObject into someIDs
   repeat for each line someID in someIDs
      put the long id of control id someID into testObject
      if word 1 of testObject = "group" then
         put the uRIP["name"] of testObject into viewName
         if viewName begins with "View|Menu|" then
            return testObject
         end if
      end if
   end repeat
   return empty
end menubar_View


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
   dispatch "revEditMenubar" to card "Menu Manager" of stack "revMenuManager"
end display_MenuManager


--> Menubar | IDE
-
function menubar_IsDefault
   -- put the long name of group "revMenuBar" of stack revIDEPaletteToStackName ("menubar") into ideDefaultMenuBar
   put the defaultMenuBar into dBar -- in long name format
   put ide_DefaultMenubar() into ideDefaultMenuBar
   return ideDefaultMenuBar = the long id of dBar
end menubar_IsDefault


--> Menubar
-
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
