script "behavior_MenuGroupDev" with behavior "behavior_MenuGroupCreate"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: behavior_MenuGroupDev
type: behavior
version: 0.3

/*Here you make make notes as a basic form of help for this view.
Full help text can be found on the linked wiki for the view.
*/

--> Variables
-
local LocalArray


--> Working on
-
function mArray_GetParamValues propLabel, mController, mTarget
   put propLabel & "_Params" & "[" & mTarget & "]" into mProperty
   try
      put the mProperty of mController into paramValues
      return paramValues
   catch e
      -- edit the script of mController
      lcw_Notify the params
      breakpoint
      put the mProperty of mController into paramValues
   end try
end mArray_GetParamValues

setprop menu_Controller [pMenuTitle] mController
   -- put _MenuButton() into mButton -- should not use
   put the menu_Button of the target into mButton
   breakpoint
   --
   set the uOPN ["menu_Controller"] of mButton to mController
end menu_Controller

function _MenuTitleController tObject, mTitle
   -- changed param order
   -- put _MenuButton() into mButton -- should not use
   
   put the menu_Button of tObject into mButton
   
   # Stored custom property (ie for script fork)
   put the uOPN ["menu_Controller"] of mButton into mController
   if exists (mController) then return mController
   
   # Default to stack name mTitle
   put menu_GetGlobalController (mTitle) into mController
   if exists (mController) is true then return mController
   
   return mButton
end _MenuTitleController


--> MenuController
-
getprop menuController_Array [tObject]
   # menuButton = menuController  and the menuButton_title is set
   local mArray, recursionArray
   put the long id of the target into mController
   if exists (tObject) is false then
      put the menuBar_Owner of mController into tObject
   end if
   put the menu_Target [tObject] of mController into mTarget
   put the menuButton_Title of mController into mTitle
   --
   _AddScriptMenu mArray, mTitle, tObject, mController, recursionArray, mTarget
   return mArray
end menuController_Array

getprop menu_Controller [mTitle]
   put the long id of the target into tObject
   put _MenuTitleController (tObject, mTitle) into mController
   return mController
end menu_Controller

function menu_GetGlobalController mTitle
   if there is a stack mTitle then
      return the name of stack mTitle
   else
      return empty
   end if
end menu_GetGlobalController

function mArray_FromTitleTable mTitleTable, tObject
   local mArray, recursionArray
   --
   replace comma with tab in mTitleTable
   set the itemdelimiter to tab
   repeat for each line mTitleLine in mTitleTable
      -- tables are not often used
      put item 1 of mTitleLine into mTitle
      
      put item 2 of mTitleLine into mType
      if mTitle = "-" then
         _AddDivider mArray
         next repeat
      end if
      
      put _MenuTitleController (tObject, mTitle) into topMenuController
      if exists (topMenuController) is false then next repeat
      
      mArray_SetTopTitle mTitle
      -- mArray_SetActiveTitle mTitle
      dispatch "menu_Init" to topMenuController with tObject -- top only
      
      -- insert has not been done for tables yet
      switch mType
         case "insert"
            breakpoint
            break
         case "submenu"
            try
               put item 3 of mTitleLine into prettyTitle
               if prettyTitle is empty then
                  put menu_ConstructItemText (mTitle) into prettyTitle
               end if
               _AddSubmenu mArray, prettyTitle, prettyTitle, mTitle, tObject, topMenuController, recursionArray
               put the result into goodMenu
            catch e
               -- next repeat
               put false into goodMenu
            end try
            break
         default
            put _MenuTitleController (tObject, mTitle) into newMenuController
            _AddScriptMenu mArray, mTitle, tObject, newMenuController, recursionArray
            put the result into goodMenu
      end switch
      
      if goodMenu is false then
         get _MenuCheckFailed (mTitle, mType, tObject, topMenuController, mTitleTable, mArray)
         put menu_GetGlobalController ("Global | Menu | Error | Menu") into mController
         _AddMenuItem mArray, "display_Error", mController, tObject
         -- exit repeat -- ideally we add and loop
      end if
   end repeat
   --
   mArray_SetActiveArray mArray
   --
   return mArray
end mArray_FromTitleTable


--> Working on
-
command hkey_Edit hKey
   if hKey is empty then
      return "Error, hkey is empty"
   end if
   
   # Find Hkey
   hkey_Deconstruct hKey, hName, hType, hObject, hNum
   put the result into shortHkey
   if exists (hObject) is true then
      # Private and non-private handlers in targetObject and non-private handlers in hkey_ScriptHierarchy
      put walk_SearchHierachy (hObject) into searchObjects
      put hkey_FindShortHkey (shortHkey, hObject, searchObjects) into foundHkey
   else
      put hkey_Find (hKey) into foundHkey          
   end if
   
   # Edit found script and scroll
   hkey_Deconstruct foundHkey, fName, fType, fObject, fNum
   if exists (fObject) is false then return empty
   
   put the revAvailableHandlers of fObject into hTable
   put hTable_StartLine (shortHkey, hTable) into scriptLineNum
   --
   scriptEditor_EditAndScroll fObject, scriptLineNum, fName  
   
   return foundHkey
end hkey_Edit

command hkey_OptionEdit hKey, pQuestion
   if pQuestion is empty then
      put "Edit script of the handler '[[var]]'?" into pQuestion
   end if
   put scriptEditor_GetTop() into sObject
   lcw_AnswerSheet pQuestion, sObject, hKey
   hkey_Edit hKey
end hkey_OptionEdit

function hTable_StartLine hkeyLine, hTable
   put word 1 to 2 of hkeyLine into shortHkey
   repeat for each line someLine in hTable
      if word 1 to 2 of someLine = shortHkey then
         put word 3 of someLine into startLineNum
         return startLineNum
      end if
   end repeat
   return 0
end hTable_StartLine

function module_ConstructName tObject
   -- put the module_ShortFolder of tObject into moduleName
   put token -1 of the long id of tObject into sPath
   put module_ConstructShortFolder (sPath) into moduleName
   
   replace "_" with "|" in moduleName
   return moduleName
end module_ConstructName

function module_ConstructName tObject
   -- put the module_ShortFolder of tObject into moduleName
   put token -1 of the long id of tObject into sPath
   put module_ConstructShortFolder (sPath) into moduleName
   
   replace "_" with "|" in moduleName
   return moduleName
end module_ConstructName

function module_ConstructShortFolder sPath
   put module_ConstructFolder (sPath) into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   return shortFolder
end module_ConstructShortFolder

function module_ConstructFolder stackPath
   put project_FolderFromPath (stackPath) into projectFolder
   if there is not a folder projectFolder then return empty
   
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   if item (pNum + 1) of stackPath is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of stackPath & slash into moduleFolder
   return moduleFolder
end module_ConstructFolder

function module_ListBehaviorPaths sPath
   put module_ConstructFolder (sPath) into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_ListBehaviorPaths

function module_ListBehaviors sPath
   put module_ListBehaviorPaths (sPath) into stackPaths
   --
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_ListBehaviors

function project_FolderFromPath stackPath
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_FolderFromPath

function walk_SearchHierachy tObject
   put revRuggedID (tObject) into tObject
   --
   put module_ConstructName (tObject) into moduleName
   if moduleName is empty then
      put hierarchy_Construct (tObject) into walkHierarchy
      hierarchy_AddEnv walkHierarchy
   else
      put walk_GetBehaviorHierarchy (tObject) into walkHierarchy
   end if
   return walkHierarchy
end walk_SearchHierachy

function walk_GetBehaviorHierarchy tObject, fromFolder
   local oHierarchy, bHierarchy
   if exists (tObject) is false then return "Error, tObject does not exist:" && tObject
   put revRuggedId (tObject) into rObject
   --
   put module_ConstructName (tObject) into moduleName
   put view_GetTemplateObject (moduleName) into mObject
   if exists (mObject) is false then return "Error, module Object does not exist:" && mObject
   
   # Behaviors and object hieararchy
   if fromFolder is not false then
      put token -1 of the long id of stack moduleName into sPath
      put module_ListBehaviors (sPath) into moduleBehaviors
   else
      put behavior_GetHierarchy (mObject) into oHierarchy
   end if
   --
   line_Delete rObject, oHierarchy
   put rObject & CR before oHierarchy
   put word 1 to -1 of oHierarchy into oHierarchy
   
   # Rest of object hierarchy
   hierachy_AddStackObjects bHierarchy, mObject
   put oHierarchy & CR & word 1 to -1 of bHierarchy into walkHierarchy
   
   # Is this missing stack object?
   
   # Add Env hierarchy
   hierarchy_AddEnv walkHierarchy
   return walkHierarchy
end walk_GetBehaviorHierarchy

command lcw_AnswerSheet someQuestion, pDisplayView, pQVar, pCancel, pOk
   if pCancel is empty then put "Cancel" into pCancel
   if pOk is empty then put "OK" into pOk
   
   put lcw_Question (someQuestion, pQVar) into someQuestion
   answer someQuestion with pCancel or pOk as sheet
   if it is "Cancel" then exit to top
   return it
end lcw_AnswerSheet


--> Working on
-
function json_ToArray pJSON, pUseMerge
   local tArray,tKeys
   if pJSON is empty then
      return false
   else if pUseMerge is false then -- not the same
      put jsonImport (pJSON) into tArray
      return tArray
   end if
   
   try -- as otherwise an error with non-json causes script to exit
      if pJSON is empty then return empty
      repeat for each line tKey in mergJSONDecode(pJSON,"tArray")
         put json_ToArray(tArray[tKey]) into tArray[tKey]
      end repeat
      return tArray
   catch e
      return empty
   end try
end json_ToArray

function menu_GetGlobalController mTitle
   if exists (stack mTitle) then
      return the name of stack mTitle
   else
      -- put menu_GetModel() into gMenuModel
      -- put gMenuModel [gMenuTitle]["mController"] into mController
      -- return mController
      return empty
   end if
end menu_GetGlobalController

function menu_IsGlobal mTitle
   set the itemdelimiter to "|"
   if word 1 to -1 of item 1 of mTitle = "Global" \
         AND word 1 to -1 of item -1 of mTitle = "Menu" then
      return true
   else
      return false
   end if
end menu_IsGlobal


--> LocalArray | Model
-
function menu_GetTopTargetObject
   return LocalArray ["active_TopTargetObject"]
end menu_GetTopTargetObject

command menu_SetTopTargetObject tObject
   put tObject into LocalArray ["active_TopTargetObject"]
end menu_SetTopTargetObject


--> LCW | Model
-
function lcw_FetchArray pShortFile
   set the itemdelimiter to "."
   if the number of items of pShortFile = 1 then put ".array" after pShortFile -- alows pretty short names
   
   put env_GetLcwFolder() into projectFolder
   put model_FetchArray ("model_Library", projectFolder, pShortFile) into modelArray
   return modelArray
end lcw_FetchArray

function model_FetchArray modelStackName, projectFolder, pShortFile 
   put model_GetDataFolder (modelStackName, projectFolder) into modelDataFolder
   put _ConstructModelDataFile (modelDataFolder, pShortFile) into modelArrayFile
   put array_FromFile (modelArrayFile) into modelArray
   return modelArray
end model_FetchArray

private function _ConstructModelDataFile modelDataFolder, pShortFile
   -- rename / replace
   if pShortFile is empty then
      set the itemdelimiter to slash
      put item -1 of modelDataFolder into modelName
      put modelName & ".array" into pShortFile
   end if
   put modelDataFolder & pShortFile into modelDataFile
   return modelDataFile
end _ConstructModelDataFile

function model_GetDataFolder modelStackName, projectFolder
   put folder_AddShort (projectFolder, "models") into rootModelsFolder
   put rootModelsFolder & modelStackName & slash into modelDataFolder
   return modelDataFolder
end model_GetDataFolder


--> MenuPick
-
command ide_RevMenubarMenuPick mName, mItem
   switch mName
      case "File"
         dispatch "revMenubarFileMenuPick" to stack "revMenuBar" with mItem
         break
      case "Edit"
         dispatch "revMenubarEditMenuPick" to stack "revMenuBar" with mItem
         break
      case "Tools"
         dispatch "revMenubarToolsMenuPick" to stack "revMenuBar" with mItem
         break
      case "Object"
         dispatch "revMenubarObjectMenuPick" to stack "revMenuBar" with mItem
         break
      case "Text"
         dispatch "revMenubarTextMenuPick" to stack "revMenuBar" with mItem
         break
      case "Development"
         dispatch "revMenubarDevelopmentMenuPick" to stack "revMenuBar" with mItem
         break
      case "View"
         dispatch "revMenubarViewMenuPick" to stack "revMenuBar" with mItem
         break
      case "Window"
         dispatch "revMenubarWindowMenuPick" to stack "revMenuBar" with mItem
         break
      case "Help"
         dispatch "revMenubarHelpMenuPick" to stack "revMenuBar" with mItem
         break
   end switch
end ide_RevMenubarMenuPick

function ide_RevMenubarText mName, pContext
   put the name of stack "revMenuBar" into revMbar
   --
   switch mName
      case "File"
         return value ("revMenubarFileMenu(pContext)" , revMbar)
      case "Edit"
         return value ("revMenubarEditMenu(pContext)" , revMbar)
      case "Tools"
         return value ("revMenubarToolsMenu(pContext)" , revMbar)
      case "Object"
         return value ("revMenubarObjectMenu(pContext)" , revMbar)
      case "Text"
         return value ("revMenubarTextMenu(pContext)" , revMbar)
      case "Development"         
         return value ("revMenubarDevelopmentMenu(pContext)" , revMbar)
      case "View"
         return value ("revMenubarViewMenu(pContext)" , revMbar)
      case "Window"
         return value ("revMenubarWindowMenu(pContext)" , revMbar)
      case "Help"
         return value ("revMenubarHelpMenu(pContext)" , revMbar)
      default
         break
   end switch
   
   return empty
end ide_RevMenubarText

command menu_DispatchTextPick mItem, pMenuArray
   if pMenuArray is not an array then
      put mArray_GetActiveArray() into pMenuArray
   end if
   --
   mArray_SetActiveItem mItem
   put menu_GetTopTargetObject() into tObject
   
   _FindActiveHkey pMenuArray, mItem, hKey, paramValue
   
   mArray_UnMarshal hKey
   hkeyLine_Deconstruct hKey, hName, hType, mController
   if exists (mController) is false then
      breakpoint
      return "Error, mController does not exist:" && mController
   end if
   
   -- put mArray_FindMenuTarget (mController, tObject) into mTarget -- overkill
   put the menu_Target [tObject] of mController into mTarget
   --
   if the optionKey is "Down" then
      hkey_OptionEdit hKey
      return empty
   else
      handler_Do hName, mController, mTarget, paramValue
      return hKey
   end if
end menu_DispatchTextPick

function mArray_FindMenuTarget mController, tObject
   -- logic: controller, target (called for every nested menu)
   
   if exists (tObject) is false then
      put menu_GetTopTargetObject() into tObject -- bug: should exist
   end if
   --
   if exists (mController) is true then
      put the menu_Target [tObject] of mController into mTarget
      if mTarget is not empty then return mTarget
   end if
   --
   put the menu_Target [tObject] of tObject into mTarget
   if mTarget is empty then
      return tObject
   else
      return mTarget
   end if
end mArray_FindMenuTarget

private command _FindActiveHkey mArray, mItemPath, @hkey, @paramValue
   -- was "mArray_FindActiveItem"
   -- only used by "menu_DispatchTextPick"
   -- need to check if mItemPath is now just mItem?
   
   set the itemdelimiter to "|"
   put mItemPath into subItemPath
   repeat the number of items of mItemPath
      put item 1 of subItemPath into itemText
      put _FindItemArray (mArray, itemText) into nextItemArray
      --
      if nextItemArray is not an array then
         -- was the last one -- probably because itemText caontained a param like "Hello|World"
         exit repeat
      else
         put nextItemArray into itemArray
      end if
      
      delete item 1 of subItemPath
      --
      put itemArray ["menu"] into subMenuArray
      if subMenuArray is an array then
         -- do we need to check that mItemPath is not emmpty?
         put itemArray ["name"] into hkey
         put subMenuArray into mArray
      else
         exit repeat -- at end (no more submenus)
      end if
   end repeat
   --
   put itemArray ["name"] into itemName
   if word 1 of itemName is "param" then
      put word 2 to -1 of itemName into paramValue
   else
      put itemName into hkey
      put subItemPath into paramValue -- should be empty unless parramm contains "|"
   end if
end _FindActiveHkey

private function _FindItemArray mArray, itemText
   -- forgot why this is indexed with "01" rather thaan "1"
   -- something to do with display sorting, but a bad solution I think
   -- repeat with indexNum = 1 to item 2 of the extents of mArray
   put keys (mArray) into orderedNums
   sort numeric orderedNums
   repeat for each line indexNum in orderedNums
      put mArray [indexNum] into itemArray
      if itemArray ["label"] = itemText then
         return itemArray
      end if
   end repeat
   return empty
end _FindItemArray


--> Deps
-
private command _AddDivider @mArray
   put _NextIndexNum (mArray) into indexNum
   put "-" into mArray [indexNum]["name"]
   put "-" into mArray [indexNum]["label"]
   put false into mArray [indexNum]["checked"]
   return indexNum
end _AddDivider

private command _AddMenu @mArray, mTitle, mController, tObject, mTarget, @recursionArray
   put mArray_FromScript (mTitle, tObject, mController, recursionArray) into addMenuArray
   if addMenuArray is not an array then return false
   --
   put keys (addMenuArray) into insertNum
   sort numeric insertNum
   repeat for each line insertNum in insertNum
      put _NextIndexNum (mArray) into indexNum
      put addMenuArray [insertNum] into mArray [indexNum]
   end repeat
   return true
end _AddMenu

private command _AddMenuItem @mArray, hName, mController, mTarget
   _DeconstructHandlerName hName, propLabel, shortCut
   --
   put mArray_GetParamValues (propLabel, mController, mTarget) into paramValues
   put paramValues into LocalArray ["Params"][mController][hName]["mParams"]
   --
   put _NextIndexNum (mArray) into indexNum
   put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   put text_SplitCaps (propLabel) into mArray [indexNum]["label"] -- menu_CommandToText (hName)
   put shortCut into mArray [indexNum]["shortCut"]
   --
   if paramValues is empty then
      put mArray_GetCheckItem (hName, mController, mTarget) into hNameIsChecked
      put mTarget into LocalArray ["Params"][mController][hName]["hNameIsChecked"][hNameIsChecked]
      --
      -- bizarre bug in Livecode widget being strict on boolean type an text type
      -- put true into mArray [indexNum]["disabled"] does not seem possible
      -- put itemChecked into mArray [indexNum]["checked"] -- does nto work!
      
      -- put item 2 of the extents of mArray into indexNum
      -- number_PadLeft indexNum, 2
      put hNameIsChecked is true into mArray [indexNum]["checked"]
   else
      put mArray_GetCheckParams (propLabel, mController, mTarget) into checkParams
      put checkParams into LocalArray ["Params"][mController][hName]["mCheckParams"]
      --
      _SetParamMenuItem mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   end if
   return true
end _AddMenuItem

private command _AddObjectAndBehaviors @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return empty
   
   if pPretty is not false then
      -- put the long id of tObject into tObject
      put CR & the name of tObject after objectHierarchy
   else
      put CR & revRuggedId (tObject) after objectHierarchy
   end if
   
   put the behavior_Objects of tObject into bObjects
   if bObjects is empty then return false
   put CR & bObjects after objectHierarchy
   return true
end _AddObjectAndBehaviors

private command _AddScriptMenu @mArray, mTitle, tObject, newMenuController, @recursionArray, mTarget
   -- this is the one place where menu drawing happens that dispatches a message
   -- it contains the core logic and messaging order
   -- messaging logic: menu_Target, menu_CheckTarget, menu_Init
   
   ## Menu Target
   if exists (mTarget) is false then
      put mArray_FindMenuTarget (newMenuController, tObject) into mTarget
   end if
   put the menu_CheckTarget [mTarget] of newMenuController into targetOK
   if targetOk is false then return false
   
   # Checks and logging
   switch
      case exists (newMenuController) is false
      case _RecursionCheck (recursionArray, tObject, newMenuController, mTitle) is false
      case _MenuLogActivated (newMenuController, tObject, mTitle) is true
         return false
   end switch
   
   # Get Handlers
   put _FastMenuHandlers (newMenuController) into scriptHandlers
   --
   repeat for each line hName in scriptHandlers       
      if hName ends with "_" then
         _AddDivider mArray
         next repeat
      end if
      
      put mArray_GetDisabled (hName, newMenuController, mTarget) into isDisabled
      switch
         -- case isDisabled = true -- we can delete it as right now there is no graying out
         case isDisabled = "delete"
            next repeat
         case hName begins with "submenu_"
            _SubmenuBit mArray, hName, newMenuController, tObject, recursionArray, mTarget
            _SetDisabled mArray, isDisabled
            break
         case hName begins with "insert_"
            try
               _InsertBit mArray, hName, newMenuController, tObject, mTarget, recursionArray
               _SetDisabled mArray, isDisabled
            catch sError
               breakpoint
               _InsertBit mArray, hName, newMenuController, tObject, mTarget, recursionArray
            end try
            break
         default
            _AddMenuItem mArray, hName, newMenuController, mTarget
            _SetDisabled mArray, isDisabled
      end switch
   end repeat
   return true
end _AddScriptMenu

private command _AddSubmenu @mArray, mName, mLabel, mTitle, tObject, mController, @recursionArray
   put mArray_FromScript (mTitle, tObject, mController, recursionArray) into subMenuArray
   if subMenuArray is not an array then
      return false
   end if
   --
   put _NextIndexNum (mArray) into indexNum
   --
   put subMenuArray into mArray [indexNum]["menu"]
   put mName into mArray [indexNum]["name"]
   put mLabel into mArray [indexNum]["label"]
   return true
end _AddSubmenu

private command _ClearBehaviors tObject
   put the behavior of tObject into myBehavior
   put behavior_GetHierarchy (tObject) into oObjects
   
   repeat for each line bObject in bObjects
      switch
         case exists (bObject) is false
         case the long id of bObject = the long id of myBehavior
            next repeat
         default
            set the behavior of bObject to empty
      end switch
   end repeat
   return empty
end _ClearBehaviors

private function _ConstructDoScript someQuestion, pQVar, pQVar2, pQVar3
   put text_GetMergeVars (someQuestion) into mergeVars
   repeat with lineNum = 1 to the number of lines of mergeVars
      put line lineNum of mergeVars into varName
      put lineNum + 1 into pNum
      put param (pNum) into pValue
      replace quote with "'" in pValue
      --
      if pValue is not empty then
         put "put" && kwote (pValue) && "into" && varName & CR after doScript
      end if
   end repeat
   delete char -1 of doScript
   return doScript
end _ConstructDoScript

private command _DeconstructHandlerName hName, @propLabel, @shortCut
   set the itemdelimiter to "_"
   get item 2 of hName
   set the itemdelimiter to "."
   put item 1 of it into propLabel
   put item 2 to -1 of it into shortCut
end _DeconstructHandlerName

private function _FastMenuHandlers mController
   local hNames
   /*
   Assumes only one menu and all named "menu_"
   */
   
   put the revAvailableHandlers of mController into hTable
   sort numeric hTable by word 3 of each
   -- filter hTable with "M menu_*"
   repeat for each line hLine in hTable
      put word 1 to 2 of hLine into shortKey
      put word 2 of hLine into hName
      --
      switch
         case shortKey = "M submenu_Dev"
            if the shiftKey is "Down" then
               put hName & CR after hNames
            end if
            break
         case hName = "menu_Init"
            break
         case hName ends with "_"
            ## Divider is a command ending with "_"
            put "_" & CR after hNames
            break
         case hLine begins with "M submenu_"
         case hLine begins with "M insert_"
         case hLine begins with "M menu_"
            put word 2 of hLine into hName
            put hName & CR after hNames
            break
         default
            -- not a menu
      end switch
   end repeat
   delete char -1 of hNames
   return hNames
end _FastMenuHandlers

private command _InsertBit @mArray, hName, mController, tObject, mTarget, @recursionArray
   dispatch hName to mController with mTarget
   put the result into insertMenuTitle
   --
   switch
      case insertMenuTitle is empty
         return false
      case menu_IsGlobal (insertMenuTitle)
         put _MenuTitleController (tObject, insertMenuTitle) into insertController
         if exists (insertController) is false then
            return empty
         end if
         break
      default
         -- assume it is a non-global menu in the same mController
         put mController into insertController
   end switch
   --
   -- mArray_SetActiveTitle insertMenuTitle
   --
   _AddMenu mArray, insertMenuTitle, insertController, tObject, mTarget, recursionArray
   return the result
end _InsertBit

private function _MenuCheckFailed mTitle, mType, tObject, topMenuController, mTitleTable, mArray
   # Error due to "menu_CheckTarget" returns false (or menu does not exist)
   # We should just disable the menu, but now there is an issue with that that is hard to debug.
   
   # Gather info
   put mTitle into errorData ["mTitle"]
   put mType into errorData ["mType"]
   put mType into errorData ["mType"]
   put topMenuController into errorData ["topMenuController"]
   put mTitleTable into errorData ["mTitleTable"]
   put mArray into errorData ["mArray"]
   --
   global gLCW
   put errorData into gLCW ["Error"]["menu_CheckTarget"]
   
   # Get a simple safe menu to display
   local recursionArray
   put mArray_FromScript ("Global | Menu | Error | Menu", tObject, tObject, recursionArray) into mArray
   return mArray
   
   # Don't do this
   -- AddScriptMenu mArray, "Global | Menu | Error | Menu", tObject, tObject, recursionArray -- error, recurses!
end _MenuCheckFailed

private function _MenuLogActivated newMenuController, tObject, mTitle
   -- checks for double menus in an object
   -- and logs menus that have been activated
   
   put LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] is true into mInitialised
   if mInitialised is not true then      
      put mInitialised into LocalArray ["MenuControllerInit"][newMenuController]["mInitialised"] -- check recursion
      
      -- for debugging
      put mTitle into LocalArray ["MenuControllerInit"][newMenuController]["mTitle"] -- to find mController from mTitle
      put tObject into LocalArray ["MenuControllerInit"][newMenuController]["tObject"]
   end if
   return mInitialised
end _MenuLogActivated

private function _NextIndexNum mArray
   -- padding added due to ordering issue with widget
   if mArray is an array then
      put item 2 of the extents of mArray into indexNum
      add 1 to indexNum
   else
      put 01 into indexNum
   end if
   number_PadLeft indexNum, 2
   return indexNum
end _NextIndexNum

private function _PropLabel hName
   _DeconstructHandlerName hName, propLabel, shortCut
   return propLabel
end _PropLabel

private function _RecursionCheck @recursionArray, tObject, mController, mTitle
   put recursionArray [mController][mTitle] into testObject
   if testObject is not empty then
      -- already indexed. Don't allow a menu to be there twice.
      return false
   else
      put tObject into recursionArray [mController][mTitle]
      return true
   end if
end _RecursionCheck

private command _SetDisabled @mArray, isDisabled
   if isDisabled is not empty then
      put item 2 of the extents of mArray into indexNum
      number_PadLeft indexNum, 2
      put isDisabled is true into mArray [indexNum]["disabled"]
   end if
end _SetDisabled

private command _SetParamMenuItem @mArray, propLabel, hName, mController, paramValues, checkParams, indexNum
   replace comma with CR in paramValues
   replace comma with CR in checkParams
   set the wholematches to true
   
   -- not safe for widget bug ordering
   put 1 into subIndexNum
   repeat for each line paramValue in paramValues
      put paramValue into subMenuArray [subIndexNum]["label"]
      --
      put "param" && paramValue into subMenuArray [subIndexNum]["name"]
      --
      put paramValue is among the lines of checkParams into someBoolean
      put someBoolean is true into subMenuArray [subIndexNum]["checked"]
      --
      add 1 to subIndexNum
   end repeat
   
   put subMenuArray into mArray [indexNum]["menu"]
   
   # Set mArray
   -- put mArray_ConstructHkey (hName, mController) into mArray [indexNum]["name"]
   -- put text_SplitCaps (propLabel) into mArray [indexNum]["label"]
end _SetParamMenuItem

private function _SimpleRecursionCheck mController, mTitle
   put mArray_GetActiveControllerArray() into mControllerArray
   put mControllerArray [mController] into testArray
   return testArray is an array
end _SimpleRecursionCheck

private command _SubmenuBit @mArray, hName, mController, tObject, @recursionArray, mTarget
   -- bug: can recurse
   dispatch hName to mController with mTarget
   put the result into subMenuTitle
   if subMenuTitle is empty then return false
   --
   -- mArray_SetActiveTitle subMenuTitle
   put _MenuTitleController (tObject, subMenuTitle) into newMenuController
   put menu_CommandToText (hName) into mLabel
   _AddSubmenu mArray, hName, mLabel, subMenuTitle, tObject, newMenuController, recursionArray
   --
   return true
end _SubmenuBit

function array_FromFile someFile, pUseMerge
   put url ("binfile:" & someFile) into someData
   if someData is empty then return empty
   
   # Switch depending on file type
   set the itemdelimiter to "."
   switch item -1 of someFile
      case "json"
         -- put jsonImport (someData) into modelArray
         put json_ToArray (someData, pUseMerge) into modelArray
         return modelArray
      case "array"
         put arraydecode (someData) into modelArray
         return modelArray
      default
         return someData
   end switch
end array_FromFile

function array_Get someFile
   put url ("binfile:" & someFile) into encodedDataArray
   if encodedDataArray is empty then return empty
   put arraydecode (encodedDataArray) into modelArray
   return modelArray
end array_Get

function behavior_GetHierarchy tObject, pUseRugged
   repeat
      put the behavior of tObject into bObject
      if exists (bObject) is false then exit repeat
      if pUseRugged is not false then
         put revRuggedId (bObject) into bObject
      end if
      put bObject & CR after bObjects
      put bObject into tObject
   end repeat
   delete char -1 of bObjects
   return bObjects
end behavior_GetHierarchy

getprop behavior_Objects [useRugged]
   put the long id of the target into tObject
   put behavior_GetHierarchy (tObject, useRugged) into bObjects
   return bObjects
end behavior_Objects

setprop behavior_StackNames stackNames
   if stackNames is empty then return empty
   replace comma with CR in stackNames
   put the long id of the target into tObject
   
   # Clear any behaviors (or we might cause a loop)
   _ClearBehaviors tObject
   
   repeat for each line stackName in stackNames
      if exists (stack stackName) is false then next repeat
      put the long id of stack stackName into bObject
      if tObject = bObject then next repeat
      
      set the behavior of tObject to bObject
      put bObject into tObject
      put bObject & CR after bObjects
   end repeat
   delete char -1 of bObjects
   return bObjects
end behavior_StackNames

function colour_GetRandom
   -- was "randomColour"
   put random(255) into item 1 of someColour
   put random(255) into item 2 of someColour
   put random(255) into item 3 of someColour
   return someColour
end colour_GetRandom

function env_ConstructProjectFolder projectName, pRepoFolder
   if pRepoFolder is empty then put env_GetRepoFolder() into pRepoFolder
   --
   put folder_AddShort (pRepoFolder, projectName) into projectFolder
   if there is a folder projectFolder then
      return projectFolder
   else
      return empty
   end if
end env_ConstructProjectFolder

function env_GetLcwFolder
   global gLCW
   put "lcwFolder" into prefName
   --
   put pref_GetValue (prefName) into lcwFolder
   if lcwFolder is not empty then return lcwFolder
   
   put pref_FetchValue (prefName) into lcwFolder
   return lcwFolder
end env_GetLcwFolder

function env_GetRepoFolder
   put env_GetLcwFolder() into pLcwFolder
   --
   set the itemdelimiter to slash
   delete item -1 of pLcwFolder
   return pLcwFolder
end env_GetRepoFolder

function env_ListBackScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the backscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListBackScripts

function env_ListFrontScripts
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/Tools/Toolset/libraries/revshortcutslibrary.livecodescript
   put the frontscripts into longIDs
   ide_FilterOutStacks longIDs
   return longIDs
end env_ListFrontScripts

function env_ScriptHierarchy pRemoveTransportBehavior
   put env_ListFrontScripts() into frontObjects
   -- _RemoveTransporterTools frontObjects, pRemoveTransportBehavior
   --
   put env_ListBackScripts() into backObjects
   put stack_PathsToObjects (the stacksinUse) into usedStacks
   --
   object_AddBehaviors usedStacks
   object_AddBehaviors frontObjects
   object_AddBehaviors backObjects
   --
   if usedStacks is not empty then put usedStacks into scriptHierarchy
   if backObjects is not empty then put backObjects & CR before scriptHierarchy
   if frontObjects is not empty then put CR & frontObjects after scriptHierarchy
   --
   return scriptHierarchy
end env_ScriptHierarchy

command field_ScrollToLine lineNum, fieldObject, pSelectLine
   -- does not seem accurate for large line numbers (it's an underestimate) ???
   
   if lineNum = 0 then
      put 0 into someScroll
   else if lineNum is a number then
      put the effective textHeight of fieldObject into lineHeight
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   else -- any text = "bottom"
      -- bit of a hack (but works :)
      put the effective textHeight of fieldObject into lineHeight
      put the number of lines of the text of fieldObject into lineNum
      put ((lineNum - 1) * lineHeight) - 0 * the height of fieldObject into someScroll
   end if
   set the scroll of fieldObject to someScroll
   if pSelectLine is not false then
      select line lineNum of fieldObject
   end if
end field_ScrollToLine

function folder_AddShort projectFolder, shortFolder
   text_AddTrailing projectFolder, slash
   if shortFolder is not empty then put shortFolder & slash after projectFolder
   return projectFolder
end folder_AddShort

function folder_ListStackPaths someFolder
   if there is not a folder someFolder then return empty
   
   if char -1 of someFolder is not slash then put slash after someFolder
   put the defaultfolder into oFolder
   set the defaultfolder to someFolder
   put the files into shortFiles
   
   set the itemdelimiter to "."
   repeat for each line shortFile in shortFiles
      put someFolder & shortFile into stackFilePath
      if there is a stack stackFilePath then
         put stackFilePath & CR after stackFilePaths
      end if
   end repeat
   delete char -1 of stackFilePaths
   set the defaultfolder to oFolder
   return stackFilePaths
end folder_ListStackPaths

getprop found_Hkey [shortHkey]
   # Private and non-private handlers in targetObject
   -- and non-private handlers in hkey_ScriptHierarchy
   put the long id of the target into tObject
   --
   put the walk_Hierarchy of tObject into searchObjects
   put hkey_FindShortHkey (shortHkey, tObject, searchObjects) into foundHkey
   return foundHkey
end found_Hkey

command handler_Do hName, hObject, pTarget, pValue
   if exists (hObject) is false then
      -- display_DebugHistory hName
      return "Error, hObject does not exists."
   end if
   
   put hName && "pTarget,pValue" into callCommand
   call callCommand of hObject
   return the result
end handler_Do

command hierachy_AddStackObjects @objectHierarchy, tObject, pPretty
   if exists (tObject) is false then return false
   put tObject into objectOwner
   put empty into skipThisBackgroundID
   
   repeat
      switch word 1 of objectOwner
         case "stack"
            -- previously added a stack, check if it was a substack
            put objectOwner into stackObject
            put the owner of stackObject into mainStackObject
            if exists (mainStackObject) then
               _AddObjectAndBehaviors objectHierarchy, mainStackObject, pPretty
            end if
            
            delete word 1 to 3 of objectOwner
            if exists (objectOwner) is false then exit repeat
            break
         case "card"
            -- previously added a card, so check for backgrounds
            put objectOwner into cardObject
            put the backgroundIDs of cardObject into bgIDs
            -- need to add in reverse to mirror message path
            repeat with bgNum = the number of lines of bgIDs down to 1
               put line bgNum of bgIDs into someID
               if someID = skipThisBackgroundID then next repeat
               put the long ID of bg ID someID of cardObject into backgroundObject
               _AddObjectAndBehaviors objectHierarchy, backgroundObject
            end repeat
            
            # Above a card must be a stack
            put objectOwner into stackObject
            delete word 1 to 4 of stackObject
            _AddObjectAndBehaviors objectHierarchy, stackObject
            
            exit repeat
            break
         case "group"
            -- previously added a group, check to see if was a bg
            if the backgroundbehavior of objectOwner is true then
               -- will need to skip it's own "card" background
               put the short ID of objectOwner into skipThisBackgroundID
            end if
            --
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
            break
         default
            -- previously added a normal control
            delete word 1 to 4 of objectOwner
            if exists (objectOwner) is false then exit repeat
            --
            _AddObjectAndBehaviors objectHierarchy, objectOwner
      end switch
   end repeat
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierachy_AddStackObjects

command hierarchy_AddEnv @objectHierarchy
   put env_ScriptHierarchy (true) into externalObjects
   if externalObjects is empty then return false
   
   set the wholematches to true
   repeat for each line sObject in objectHierarchy
      put lineOffset (sObject, externalObjects) into lineNum
      delete line lineNum of externalObjects
   end repeat
   if externalObjects is empty then return false
   
   put CR & word 1 to -1 of externalObjects after objectHierarchy
   put word 1 to -1 of objectHierarchy into objectHierarchy
   return true
end hierarchy_AddEnv

function hierarchy_Construct tObject, pPretty
   -- was "object_GetHierarchy"
   local objectHierarchy
   put the long id of tObject into tObject
   put pPretty is not false into pPretty
   
   put the hierarchy_ObjectAndBehaviors [pPretty] of tObject into objectHierarchy
   hierachy_AddStackObjects objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_Construct

getprop hierarchy_ObjectAndBehaviors [pPretty]
   local objectHierarchy
   put pPretty is not false into pPretty
   put the long id of the target into tObject
   
   _AddObjectAndBehaviors objectHierarchy, tObject, pPretty
   return word 1 to -1 of objectHierarchy
end hierarchy_ObjectAndBehaviors

function hkey_Construct hName, hType, tObject
   if exists (tObject) is false then
      put "Missing" into hObject
   end if
   replace "C" with "M" in hType
   put hKeyLine_Construct (hName, hType, tObject) into hKeyLine
   return hKeyLine
end hkey_Construct

command hkey_Deconstruct hKey, @hName, @hType, @hObject, @hNum
   -- will deconstruct both
   -- move over to hkeyLine_Deconstruct
   
   if the number of items of hkey = 1 then
      hkeyLine_Deconstruct hKey, hName, hType, hObject
      put 1 into hNum
   else
      -- old version
      put word 1 to -1 of item 1 of hKey into hName
      put word 1 to -1 of item 2 of hKey into hType
      if hType is empty then put "c" into hType
      put word 1 to -1 of item 3 of hKey into hObject
      put item 4 of hKey into hNum
      if hNum is empty then put 1 into hNum
   end if
   
   put hKeyLine_Construct (hName, hType, hObject) into hkeyLine
   return hkeyLine
end hkey_Deconstruct

getprop hkey_Either [shortHkey]
   -- returns public or private hkey in tObject
   put the revAvailableHandlers of the target into hTable
   put hTable_GetEither (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Either

function hkey_Find hKey, pSearchObjects
   hkeyLine_Deconstruct hKey, hName, hType, hObject
   put the result into shortHkey
   
   if pSearchObjects is empty then
      if exists (hObject) then
         put the walk_Hierarchy of hObject into pSearchObjects
      else
         put env_ScriptHierarchy (true) into pSearchObjects
      end if
   end if
   --
   put hkey_FindShortHkey (shortHkey, hObject, pSearchObjects) into foundHkey
   return foundHkey
end hkey_Find

function hkey_FindShortHkey shortHkey, pObject, pSearchObjects
   put word 1 to 2 of shortHkey into shortHkey
   
   # Make shortHkey public
   if char 1 of shortHkey = "P" then delete char 1 of shortHkey
   
   if exists (pObject) then
      # Search for private handlers
      put the hkey_Either [shortHkey] of pObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
      line_Delete pSearchObjects, pObject -- so we dont search it again later
   end if
   
   # Search for public handlers in pSearchObjects
   repeat for each line foundObject in pSearchObjects
      if exists (foundObject) is false then next repeat
      
      put the hkey_Or [shortHkey] of foundObject into foundHkey
      if foundHkey is not empty then
         return foundHkey
      end if
   end repeat
   return empty  
end hkey_FindShortHkey

getprop hkey_Or [shortHkey]
   put the revAvailableHandlers of the target into hTable
   put htable_GetOr (shortHkey, hTable) into foundHkey
   return foundHkey
end hkey_Or

getprop hkey_StartLine [hkeyLine]
   put word 1 to 2 of hkeyLine into shortHkey
   put the revAvailableHandlers of the target into hTable
   repeat for each line someLine in hTable
      if word 1 to 2 of someLine = shortHkey then
         put word 3 of someLine into startLineNum
         return startLineNum
      end if
   end repeat
   return 0
end hkey_StartLine

function hKeyLine_AddObject hkeyLine, tObject
   -- used quite a lot
   put revRuggedID (tObject) into hObject
   put word 1 to 2 of hkeyLine && "of" && hObject into hKeyLine
   return hKeyLine
end hKeyLine_AddObject

function hKeyLine_Construct hName, hType, tObject
   put hType && hName into shortHkeyLine
   if tObject is empty then return shortHkeyLine
   
   put hKeyLine_AddObject (shortHkeyLine, tObject) into hkeyLine
   return hkeyLine
end hKeyLine_Construct

command hkeyLine_Deconstruct hKeyLine, @hName, @hType, @hObject
   put toUpper (word 1 of hKeyLine) into hType
   put word 2 of hKeyLine into hName
   put word 4 to -1 of hKeyLine into hObject
   return hType && hName
end hkeyLine_Deconstruct

function htable_GetEither searchHkeyLine, hTable
   -- matches either private of public handlers
   -- returns just the foundHkey (we dont need line numbers)
   put char -1 of word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into searchName
   
   repeat for each line hLine in hTable
      put word 2 of hLine into foundName
      put word 1 of hLine into foundPublicType
      if foundName is not searchName then next repeat
      
      put char -1 of foundPublicType into fType
      switch
         case hType = fType
         case (hType = "C") AND (fType = "M")
         case (hType = "M") AND (fType = "C")
            put word 5 to -1 of line 1 of hTable into hObject
            put hKeyLine_Construct (foundName, foundPublicType, hObject) into foundHkey
            return foundHkey
      end switch
   end repeat
   return empty
end htable_GetEither

function htable_GetOr searchHkeyLine, hTable
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   --
   htable_OrLineOffsets hName, hType, hTable, startLineNum, endLineNum
   if the result is false then return empty
   
   put word 5 to -1 of line 1 of hTable into tObject
   put word 1 of searchHkeyLine into hType
   put word 2 of searchHkeyLine into hName
   put hKeyLine_Construct (hName, hType, tObject) into foundHkey
   return foundHkey
end htable_GetOr

command htable_OrLineOffsets hName, hType, hTable, @startLineNum, @endLineNum
   repeat for each line hLine in hTable
      if hName is not word 2 of hLine then next repeat
      
      switch
         case hType = word 1 of hLine
         case (hType = "C") AND (word 1 of hLine = "M")
         case (hType = "M") AND (word 1 of hLine = "C")
            put word 3 of hLine into startLineNum
            put word 4 of hLine into endLineNum
            return true
      end switch
   end repeat
   put 0 into startLineNum
   put 0 into endLineNum
   return false
end htable_OrLineOffsets

function ide_DefaultMenuBarStack
   put ide_DefaultMenubarStackName() into defaultMenubarStackName
   put the name of stack defaultMenubarStackName into revMenuBarStack
   return revMenuBarStack
end ide_DefaultMenuBarStack

function ide_DefaultMenubarStackName
   put revIDEPaletteToStackName ("menubar") into revMenuBarStackName
   return revMenuBarStackName
end ide_DefaultMenubarStackName

function ide_DefaultMenuGroup
   put ide_DefaultMenuBarStack() into revMenuBarStack
   put the long id of group "revMenuBar" of revMenuBarStack into revMenuGroup
   return revMenuGroup
end ide_DefaultMenuGroup

command ide_FilterOutStacks @longIDs
   put rev_AppContentsFolder() into revAppContentsFolder
   
   set the itemdelimiter to slash
   repeat for each line tObject in longIDs
      if exists(tObject) is false then next repeat
      put token -1 of tObject into stackPath
      if stackPath begins with revAppContentsFolder then next repeat
      put revRuggedId (tObject) & CR after filteredObjects
   end repeat
   delete char -1 of filteredObjects
   put filteredObjects into longIDs
end ide_FilterOutStacks

function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

command lcw_Notify someMessage, pTitle, pMergeValue
   -- needs to work cross platform
   replace quote with empty in someMessage
   replace "'" with empty in someMessage
   text_ReQuote someMessage, pMergeValue
   --
   try
      if pTitle is empty then put "LiveCode World Notification" into pTitle
      put "osascript -e" && "'" & "display notification" && quote & someMessage & quote into someShell
      put "with title" && quote & pTitle & quote after someShell
      put "'" after someShell
      put shell (someShell) into shellResult
   catch e
      put someMessage
   end try
end lcw_Notify

function lcw_Question someQuestion, pQVar
   put param (4) into pQVar2
   put param (5) into pQVar3
   --
   put _ConstructDoScript (someQuestion, pQVar, pQVar2, pQVar3) into doScript
   if doScript is not empty then
      do doScript
      put merge (someQuestion) into someQuestion
   end if
   text_ReQuote someQuestion
   return someQuestion
end lcw_Question

function library_FetchProjectData
   put lcw_FetchArray ("lcw_ProjectDataLibrary.array") into libraryProjectData
   return libraryProjectData
end library_FetchProjectData

function library_ListProjectModules
   put library_FetchProjectData() into libraryProjectData
   put "module" into projectType
   repeat for each key projectName in libraryProjectData
      put libraryProjectData [projectName]["projectType"] into someType
      -- put libraryProjectData [projectName]["projectFolder"] into someFolder
      if someType = projectType then
         put projectName & CR after projectNames
      end if
   end repeat
   delete char -1 of projectNames
   return projectNames
end library_ListProjectModules

command line_Delete someLine, @someIndex
   set the wholematches to true
   put lineoffset (someLine, someIndex) into lineNum
   delete line lineNum of someIndex
   return lineNum
end line_Delete

command mArray_ClearActiveMenuArray
   delete variable LocalArray
end mArray_ClearActiveMenuArray

function mArray_ConstructHkey hName, mController
   put hkey_Construct (hName, "M", mController) into hkeyController
   mArray_Marshal hkeyController
   return hkeyController
end mArray_ConstructHkey

function mArray_FromScript mTitle, tObject, mController, @recursionArray
   local mArray
   _AddScriptMenu mArray, mTitle, tObject, mController, recursionArray
   return mArray
end mArray_FromScript

function mArray_GetActiveArray
   return LocalArray ["active_MenuArray"]
end mArray_GetActiveArray

function mArray_GetActiveControllerArray
   put LocalArray ["MenuControllerInit"] into mControllerArray
   return mControllerArray
end mArray_GetActiveControllerArray

function mArray_GetCheckItem hName, mController, mTarget
   put _PropLabel(hName) into hText
   put "checked_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into someBoolean
   return someBoolean is true
end mArray_GetCheckItem

function mArray_GetCheckParams propLabel, mController, mTarget
   put propLabel & "_Param" & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into checkParams
   return checkParams
end mArray_GetCheckParams

function mArray_GetDisabled hName, mController, mTarget
   put _PropLabel(hName) into hText
   put "disabled_" & hText & "[" & mTarget & "]" into mProperty
   put the mProperty of mController into isDisabled
   return isDisabled
end mArray_GetDisabled

command mArray_Marshal @hkeyController
   replace "|" with "\" in hkeyController
end mArray_Marshal

command mArray_SetActiveArray mArray
   put mArray into LocalArray ["active_MenuArray"]
end mArray_SetActiveArray

command  mArray_SetActiveItem mItem
   put mItem into LocalArray ["active_MenuItemPath"]
end mArray_SetActiveItem

command mArray_SetTopTitle mTitle
   put mTitle into LocalArray ["active_TopMenuTitle"]
end mArray_SetTopTitle

command mArray_TextRecurse @mText, someIndent, mArray, pController, pMenuTarget
   put keys (mArray) into indexNums
   sort numeric indexNums
   repeat for each line indexNum in indexNums
      put mArray [indexNum] into itemArray
      --
      put itemArray ["name"] into mController
      put itemArray ["label"] into itemText
      
      # Set disabled
      if pController is empty then
         put itemArray ["checked"] into isChecked
         put itemArray ["disabled"] into isDisabled
      else
         -- check live (not sure if this is ever used?)
         -- put mArray_GetObjectCheckStatus (hName, pController, pMenuTarget) into isDisabled
         put mArray_GetDisabled (hName, pController, pMenuTarget) into isDisabled
      end if
      if isDisabled is true then put "(" before itemText
      
      # Set Shortcut
      put itemArray ["shortcut"] into shortcut
      if shortcut is not empty then
         put "/" & shortCut after itemText
      end if
      
      # Set checked
      if isChecked is true then
         put "!c" before itemText
      else
         -- put "!n" before itemText
      end if
      put someIndent & itemText & CR after mText
      
      # Recurse
      put itemArray ["menu"] into subArray
      if subArray is an array then
         put tab & someIndent into nextIndent
         mArray_TextRecurse mText, nextIndent, subArray
      end if
   end repeat
end mArray_TextRecurse

function mArray_ToText mArray
   local mText
   put empty into someIndent
   mArray_TextRecurse mText, someIndent, mArray
   delete char -1 of mText
   return mText
end mArray_ToText

command mArray_UnMarshal @hkeyController
   replace "\" with "|" in hkeyController
end mArray_UnMarshal

getprop menu_CheckTarget [mTarget]
   /*
   This is a default sent by  "menu_ConvertTable" 
   Usually - all you want to do is check that the topMenuTarget exists.
   But it could be a file or some other non-Rev structure.
   */
   return true
end menu_CheckTarget

function menu_CommandToText hName
   _DeconstructHandlerName hName, propLabel, shortCut
   put text_SplitCaps (propLabel) into mLine
   return mLine
end menu_CommandToText

function menu_ConstructItemText mTitle
   set the itemdelimiter to "|"
   delete item - 1 of mTitle
   if word 1 to -1 of item 1 of mTitle = "Global" then delete item 1 of mTitle
   
   replace " | " with " " in mTitle
   return word 1 to -1 of mTitle
end menu_ConstructItemText

getprop module_BehaviorHierarchy [fromFolder]
   local oHierarchy, bHierarchy
   put the long id of the target into tObject
   put revRuggedId (tObject) into rObject
   --
   put the module_Name of tObject into moduleName
   put view_GetTemplateObject (moduleName) into mObject
   
   # Behaviors and object hieararchy
   if fromFolder is not false then
      put the module_Behaviors of mObject into oHierarchy
   else
      put the behavior_Objects of mObject into oHierarchy
   end if
   --
   line_Delete rObject, oHierarchy
   put rObject & CR before oHierarchy
   put word 1 to -1 of oHierarchy into oHierarchy
   
   # Rest of object hierarchy
   hierachy_AddStackObjects bHierarchy, mObject
   put oHierarchy & CR & word 1 to -1 of bHierarchy into walkHierarchy
   
   # Is this missing stack object?
   
   # Add Env hierarchy
   hierarchy_AddEnv walkHierarchy
   return walkHierarchy
end module_BehaviorHierarchy

getprop module_BehaviorPaths
   put the module_Folder of the target into moduleFolder
   put moduleFolder & "behaviors/" into moduleBehaviorFolder
   put folder_ListStackPaths (moduleBehaviorFolder) into stackPaths
   return stackPaths
end module_BehaviorPaths

getprop module_Behaviors
   put the module_BehaviorPaths of the target into stackPaths
   repeat for each line stackPath in stackPaths
      if exists (stack stackPath) is false then next repeat
      put the name of stack stackPath & CR after moduleBehaviors
   end repeat
   delete char -1 of moduleBehaviors
   return moduleBehaviors
end module_Behaviors

getprop module_Folder
   put the project_Folder of the target into projectFolder
   if there is not a folder projectFolder then return empty
   
   put the effective filename of the defaultstack into sPath
   set the itemdelimiter to slash
   put the number of items of projectFolder into pNum
   if item (pNum + 1) of sPath is not "Modules" then return empty
   
   put item 1 to (pNum + 2) of sPath & slash into moduleFolder
   return moduleFolder
end module_Folder

getprop module_Name
   put the module_ShortFolder of the target into moduleName
   replace "_" with "|" in moduleName
   return moduleName
end module_Name

getprop module_ShortFolder
   put the module_Folder of the target into moduleFolder
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   return shortFolder
end module_ShortFolder

private command number_PadLeft @someNum, padNum
   put "%0" & padNum & "d" into fString
   put format (fString, someNum) into someNum
end number_PadLeft

command object_AddBehaviors @objectIndex
   repeat for each line someObject in objectIndex
      if exists (someObject) is false then next repeat 
      put the behavior of someObject into objectBehavior
      if exists (objectBehavior) then
         put revRuggedId (objectBehavior) & CR after newObjectIndex
      end if
      put someObject & CR after newObjectIndex
   end repeat
   delete char -1 of newObjectIndex
   put newObjectIndex into objectIndex
end object_AddBehaviors

function pref_FetchArray pProjectName
   if pProjectName is empty then put "Default" into pProjectName
   put pref_FetchData() into dataArray
   return dataArray [pProjectName]
end pref_FetchArray

function pref_FetchData
   put pref_File() into someFile
   put array_Get (someFile) into dataArray
   return dataArray
end pref_FetchData

function pref_FetchValue prefName, pPrefKey
   if pPrefKey is empty then put "Default" into pPrefKey
   --
   put pref_FetchArray (pPrefKey) into prefArray
   put prefArray [prefName] into someValue
   return someValue
end pref_FetchValue

function pref_File
   put specialfolderpath ("preferences") & "/lcw_Preferences.array" into prefFile
   return prefFile
end pref_File

function pref_GetValue prefName
   global gLCW
   return gLCW ["prefsArray"][prefName]
end pref_GetValue

getprop project_Folder
   -- latest simplest version based on naming conventions and folder structure
   -- does not allow projects outside of the LCW reop folder  
   
   put the effective filename of the defaultstack into stackPath
   --
   set the itemdelimiter to slash
   put env_GetRepoFolder() into repoFolder
   put the number of items of repoFolder + 1 into itemNum
   put item 1 to itemNum of stackPath & slash into projectFolder
   --
   return projectFolder
end project_Folder

function project_GetShortFolder projectFolder
   set the itemdelimiter to slash
   put item -1 of projectFolder into projectName
   return projectName
end project_GetShortFolder

function project_PathFromFolder projectFolder
   text_AddTrailing projectFolder, slash
   put project_GetShortFolder (projectFolder) into projectShortFolder
   put projectFolder & projectShortFolder & ".livecode" into projectHomeStackPath
   return projectHomeStackPath
end project_PathFromFolder

function rev_AppContentsFolder
   -- /Applications/LiveCode Community 8.1.0 (dp 3).app/Contents/
   set the itemdelimiter to slash
   put the engine folder into appContentsFolder
   put empty into item -1 of appContentsFolder
   return appContentsFolder
end rev_AppContentsFolder

function rev_HandlerTreeField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (field "handlers" of group "Left Bar" of cd "Main" of editorStack) is false then return empty
   put the long id of field "handlers" of group "Left Bar" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_HandlerTreeField

function rev_ScriptEditorField pEditorNum
   put rev_ScriptEditorStack (pEditorNum) into editorStack
   if exists (fld "Script" of group "Editor" of cd "Main" of editorStack) is false then return empty
   put the long id of fld "Script" of group "Editor" of cd "Main" of editorStack into someObject
   return revRuggedID (someObject)
end rev_ScriptEditorField

function rev_ScriptEditorStack pEditorNum
   switch
      case pEditorNum is empty
         return scriptEditor_GetTop()
      case pEditorNum = 0
         put the long id of stack "revSETemplate" of stack "revNewScriptEditor" into stackObject
         return revRuggedID (stackObject)
      case pEditorNum is a number
         put "revNewScriptEditor" && pEditorNum into stackName
         if exists (stack stackName) is false then return empty
         return the name stack stackName
      default
         return scriptEditor_GetTop()
   end switch
end rev_ScriptEditorStack

command scriptEditor_EditAndScroll hObject, scriptLineNum, hName
   edit the script of hObject
   put rev_HandlerTreeField() into handlerTreeField
   put rev_ScriptEditorField() into scriptEditorField
   --
   put the text of handlerTreeField into hIndex
   --
   try
      lock screen
      if hName is not empty then
         put lineOffset (hName, hIndex) into hLineNum
         set the hilitedLine of handlerTreeField to hLineNum
      end if
      --
      field_ScrollToLine scriptLineNum, scriptEditorField, true
      dispatch "closeAccept" to handlerTreeField
      unlock screen
      --
      return empty
   catch e
      return the executioncontexts
   end try
end scriptEditor_EditAndScroll

function scriptEditor_GetTop
   -- was "scriptEditor_GetTop()"
   
   put the short name of the defaultstack into stackName
   if word 1 of stackName is "revNewScriptEditor" then
      return the long id of stack stackName
   else
      put the openstacks into stackNames
      filter stackNames with "revNewScriptEditor*"
      if stackNames is empty then return empty
      put line 1 of stackNames into firstEditorStackName
      return the long id of stack firstEditorStackName
   end if
end scriptEditor_GetTop

getprop stack_Name
   return the short name of the defaultstack
end stack_Name

function stack_PathsToObjects stackNameOrPaths
   repeat for each line stackName in stackNameOrPaths
      if exists (stack stackName) is false then next repeat
      put the name of stack stackName & CR after stackObjects
   end repeat
   delete char -1 of stackObjects
   return word 1 to -1 of stackObjects
end stack_PathsToObjects

command text_AddTrailing @someText, someChar
   if char -1 of someText is not someChar then
      put someChar after someText
   end if
end text_AddTrailing

function text_GetMergeVars mergeText
   -- put text_GetBetween ("[[", "]]", someText, startAfterCharNum)
   put "\[\[" into someReg
   put "[^\]]*" into notaSquareClosingBracket
   put "(" & notaSquareClosingBracket & ")" after someReg
   put "\]\]" after someReg
   --
   repeat 100 -- for safety
      if matchChunk (mergeText, someReg , startMatch, endMatch) is true then
         put char startMatch to endMatch of mergeText into varName
         put varName & CR after varNames
         delete char 1 to (endMatch + 2) of mergeText
      else
         delete char -1 of varNames
         return varNames
      end if
   end repeat
end text_GetMergeVars

function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower (word wordNum of someText) into someWord
      put toupper (char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps

command text_ReQuote @someText, pMergeValue
   replace "'" with quote in someText
   if pMergeValue is not empty then
      put pMergeValue into var
      put merge (someText) into someText
   end if
end text_ReQuote

function text_SplitCaps someWord
   -- was "capsSplit"
   put 1 into charNum
   repeat the number of chars of someWord
      put char charNum of someWord into someChar
      if text_StartsWithCaps(someChar) is true then
         put space before char charNum of someWord
         add 2 to charNum
      else
         add 1 to charNum
      end if
   end repeat
   put text_InitialCaps(word 1 of someWord) into word 1 of someWord
   return word 1 to -1 of someWord
end text_SplitCaps

function text_StartsWithCaps someText
   put char 1 of sometext into testChar
   put nativeCharToNum (testChar) into someCharNum
   if someCharNum >= 97 and someCharNum <= 122 then
      return false
   else
      return true
   end if
end text_StartsWithCaps

getprop top_Controls
   get word  1 of the name of the target
   if it is not among the items of "group,card" then return empty
   --
   put the childControlIDs of the target into topIDs
   repeat for each line someID in topIDs
      put the long id of control id someID & CR after topControls
   end repeat
   delete char -1 of topControls
   return topControls
end top_Controls

function view_GetTemplateObject viewName, pRepoFolder
   view_NormalizeName viewName
   if exists (control 1 of stack viewName) then
      put the long id of control 1 of stack viewName into templateObject
      return templateObject
   end if
   
   put library_ListProjectModules() into moduleStackNames
   put env_ConstructProjectFolder (viewName, pRepoFolder) into moduleFolder
   -- put library_FetchProjectFolder (viewName) into moduleFolder
   if moduleFolder is empty then return empty
   
   put project_PathFromFolder (moduleFolder) into moduleHomeStackPath
   if exists (control 1 of card 1 of stack moduleHomeStackPath) then
      return the long id of control 1 of card 1 of stack moduleHomeStackPath
   end if
   
   return empty
end view_GetTemplateObject

command view_NormalizeName @viewPath
   if viewPath is empty then return false
   view_NormalizePiped viewPath
   
   set the itemdelimiter to "|"
   if item 1 of viewPath is not among the items of "View|Layout" then put "View|" before viewPath
   return true
end view_NormalizeName

command view_NormalizePiped @viewPath, pMakePretty
   if viewPath is empty then return false
   put word 1 to -1 of viewPath into viewPath
   
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of viewPath
      put word 1 to -1 of item itemNum of viewPath into someItem
      if pMakePretty is true then
         repeat for each word someWord in someItem
            put toUpper (char 1 of someWord) into char 1 of someWord
            put someWord & space after prettyItem
         end repeat
         put char 1 to -2 of prettyItem into someItem
      end if
      put someItem into item itemNum of viewPath
   end repeat
   return true
end view_NormalizePiped

getprop walk_Hierarchy
   put the long id of the target into tObject
   put revRuggedID (tObject) into tObject
   --
   if the module_Name of the target is empty then
      put hierarchy_Construct (tObject) into walkHierarchy
      hierarchy_AddEnv walkHierarchy
   else
      put the module_BehaviorHierarchy of tObject into walkHierarchy
   end if
   return walkHierarchy
end walk_Hierarchy
