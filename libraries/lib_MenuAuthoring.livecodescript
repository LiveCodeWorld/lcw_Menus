script "lib_MenuAuthoring"
--> MetaData
-
license: GPLv3
name: lib_MenuAuthoring
type: library
version: 0.6


/*
Here we put only those handlers that are required to do dynamic indexing of menus for a project,
whether this is when a script is compiled or menu it is indexed when a project is launched or saved.

The key handlers are:

- set the menu_Update
- put the script_MenuTitleTable

We try to make this as fast and simple as possible, 
while making it compatible with more complex indexing.

## Future Enhancements

- Rationalise these scripts to only parse the script once!
- Change the menu tabe to an array
*/


--> Working on
-
getprop menuItem_CaseParams [theParams]
   -- put the menuItem_CaseParams [the params] of me
   put the short name of the target into mTitle -- requires correctly named mController
   return menuItem_GetCaseParams (theParams, mTitle)
end menuItem_CaseParams

function menuItem_GetCaseParams theParams, pMenuTitle
   if pMenuTitle is empty then put menu_MyTitle() into pMenuTitle
   
   set the itemdelimiter to "_"
   put word 1 of theParams into gName
   put "menu_" & item 1 of gName into hName
   put "M" && hName into shortHkey -- "menu_Show"
   --
   get the hkey_CaseConditions [shortHkey] of stack pMenuTitle
   return it
end menuItem_GetCaseParams

function menu_MyTitle
   -- called from correctly named mController
   put debug_CallingObject() into mController
   put the short name of mController into mTitle
   return mTitle
end menu_MyTitle

command menu_Create mTitle, stackName, pDevBit
   put menu_GetGlobalController (mTitle) into mController
   if exists (mController) then
      lcw_Notify "Menu '[[var]]' exists already!", "menu_Create", mTitle
      breakpoint
      return empty
   end if
   
   if exists (stack stackName) is false then
      breakpoint
      return empty
   end if
   
   # Find mFolder
   put the module_Folder of the target into mFolder
   if there is not a folder mFolder then
      put the project_Folder of the target into mFolder
   end if
   
   if there is not a folder mFolder then
      breakpoint
      return empty
   end if
   
   menu_CreateFromTitle mTitle, mFolder, pDevBit
   put the result into mController
   --
   if exists (mController) is false then
      breakpoint
      put menu_GetGlobalController (mTitle) into mController
      return empty
   end if
   
   return mController
end menu_Create

command module_CreateMenu moduleStackName, pGlobalMenuTitle, pControllerScript
   put the module_Folder of stack moduleStackName into moduleFolder
   --
   module_CreateMenuFromFolder moduleFolder, pGlobalMenuTitle, pControllerScript
   put the result into mController
   return mController
end module_CreateMenu

command project_CreateMenu gMenuTitle, projectName, pControllerScript
   # Quick check of projectFolder
   put project_GetFolder (projectName) into projectFolder
   if projectFolder is empty then return "Error, project folder does not exists for project:" && projectName
   --
   project_CreateMenuFromFolder projectFolder, gMenuTitle, pControllerScript
   put the result into mController
   --
   return mController
end project_CreateMenu

function controller_ConstructMenuScript mTitle
   if mTitle ends with "| Dev | Menu" then
      -- must not have "on submenu_Dev" handler to avoid recusion
      put scaffold_Get ("Global Dev Menu Template") into menuScriptTemplate
   else
      put scaffold_Get ("Global Menu Template") into menuScriptTemplate
   end if
   --
   put mTitle into controllerName
   put lcw_GetAuthor() into authorName
   put menu_DefaultHandler (mTitle) into defaultMenuHandler
   --
   put merge (menuScriptTemplate) into controllerScript
   return controllerScript
end controller_ConstructMenuScript

function menu_DefaultHandler mTitle
   put "menu_" into mHandler
   put menu_Bit (mTitle) into menuBit
   set the itemdelimiter to "|"
   repeat with itemNum = 1 to the number of items of menuBit
      put item itemNum of menuBit into sText
      put text_CamelWord (sText) into camelWord
      put camelWord after mHandler
   end repeat
   return mHandler
end menu_DefaultHandler

function text_CamelWord sText
   get word 1 to -1 of sText
   put text_InitialCaps (it) into camelWord
   replace space with empty in camelWord
   return camelWord
end text_CamelWord

function menu_Bit mTitle
   set the itemdelimiter to "|"
   put mTitle into middleBit
   put word 1 to -1 of item 1 of mTitle into firstBit
   if firstBit = "Global" then
      delete item 1 of middleBit
   end if
   --
   put word 1 to -1 of item -1 of mTitle into lastBit
   if lastBit = "Menu" then
      delete item -1 of middleBit
   end if
   --
   return word 1 to -1 of middleBit
end menu_Bit

function menu_DevTitle pMenuTitle, pMenuFolder
   put the long name of target into mController
   
   # Set pMenuTitle
   if pMenuTitle is empty then
      put line 1 of the script_MenuTitles of mController into pMenuTitle
   end if
   if pMenuTitle is empty then
      breakpoint
      return empty
   end if
   
   # Set mFolder
   if pMenuFolder is empty then
      put the stack_Folder of mController into mFolder
   else
      put pMenuFolder into mFolder
   end if
   
   # Create Dev Menu
   put "Dev | " before word -1 of pMenuTitle
   put menu_GetGlobalController (pMenuTitle) into testController
   if exists (testController) is true then return pMenuTitle
   
   # Ask to create
   -- get menu_GetGlobalController (pMenuTitle)
   menu_CreateController pMenuTitle, mFolder
   put the result into mController
   return pMenuTitle
end menu_DevTitle

command menu_CreateFromTitle mTitle, mFolder, pDevBit
   # Add Dev Bit (if provided)
   if pDevBit is not empty then
      put pDevBit && "| " before word -1 of mTitle
      put "Create developer menu '[[mTitle]]'?" into sComment
   else
      put "Create menu '[[mTitle]]'?" into sComment
   end if
   
   put menu_GetGlobalController (mTitle) into testController
   if exists (testController) then
      -- return "Error, controller for menu '[[mTitle]]' exists:" && testController
      return testController
   else
      # Ask to create
      menu_CreateController mTitle, mFolder, sComment
      put the result into mController
      return mController
   end if
end menu_CreateFromTitle

command menu_CreateController menuTitle, mFolder, pAskQuestion, pDisplayView
   if pAskQuestion is not empty then
      if exists (pDisplayView) is false then put menu_GetTopTargetObject() into pDisplayView
      lcw_Answer pAskQuestion, pDisplayView, menuTitle
   end if
   --
   folder_CreateNested mFolder
   menu_CreateScriptOnlyStack menuTitle, mFolder
   put the result into mController
   return mController
end menu_CreateController

private command _CheckCreateScriptOnlyStack mName, mFolder, mControllerPath, pDisplayView
   /*
   There should be no existing stack mName in memory.
   The folder should exist
   There should be no existing file mControllerPath
   */
   
   if exists (stack mName) then
      breakpoint
      exit to top
   end if
   
   if there is not a folder mFolder then
      breakpoint
      exit to top
   end if
   
   if there is a file mControllerPath then
      -- probably needs indexing?
      put the project_Name of stack mControllerPath into projectName
      put "Fix stack files and project array for project '[[projectName]]'?" into someQuestion 
      lcw_Answer someQuestion, pDisplayView, projectName
      --
      project_UpdateArray projectName
      put the result into projectArray
      --
      exit to top
   end if
end _CheckCreateScriptOnlyStack

command menu_CreateScriptOnlyStack mName, mFolder, pControllerScript
   /*
   For creating a script only menu in a folder you know
   */
   
   ## Construct stack path
   put lcw_PipesToUnderscore (mName) & ".livecodescript" into shortFile -- would have been better to leave plain?
   put mFolder & shortFile into mControllerPath
   
   ## Checks
   _CheckCreateScriptOnlyStack mName, mFolder, mControllerPath
   
   ## Set the default script metadata
   if pControllerScript is empty then put controller_ConstructMenuScript (mName) into pControllerScript
   
   ## Create menu stack
   create script only stack mName -- revIDENewScriptOnlyStackWithScript pName, pScript
   set the filename of stack mName to mControllerPath
   set the script of stack mName to pControllerScript
   save stack mName
   
   ## Add to stackfiles
   set the stack_IsKnown of stack mName to true -- this also saves the stack
   
   ## Reindex
   put the name of stack mName into mController
   menu_ReIndexController mController
   
   return mController
end menu_CreateScriptOnlyStack

setprop custom_Delete [pSetName] propName
   put the long id of the target into tObject
   custom_DeleteProperty propName, tObject, pSetName
   put the result into propValue
   return propValue
end custom_Delete

command custom_DeleteProperty propName, targetObject, pSetName
   put the custompropertyset of targetObject into oSetName
   set the custompropertyset of targetObject to pSetName
   put the customproperties of targetObject into propArray
   put propArray [propName] into propValue
   put the customkeys of targetObject into cKeys
   line_Delete propName, cKeys
   set the customkeys of targetObject to cKeys
   if cKeys is empty then
      custom_DeleteSet pSetName, targetObject
   end if
   set the custompropertyset of targetObject to oSetName
   return propValue
end custom_DeleteProperty

command custom_DeleteSet setName, someObject
   put the custompropertysets of someObject into setNames
   line_Delete setName, setNames
   set the custompropertysets of someObject to setNames
   return setNames
end custom_DeleteSet


--> Menu | Create
-
command module_CreateMenuFromFolder moduleFolder, pGlobalMenuTitle, pControllerScript
   set the itemdelimiter to slash
   put item -1 of moduleFolder into shortFolder
   put shortFolder into moduleStackName
   --
   if pGlobalMenuTitle is empty then
      put module_ConstructGlobalMenuTitle (moduleStackName, true) into gMenuTitle
   else
      put pGlobalMenuTitle into gMenuTitle
   end if
   if pControllerScript is empty then put controller_ConstructMenuScript (gMenuTitle) into pControllerScript
   --
   project_CreateMenuFromFolder moduleFolder, gMenuTitle, pControllerScript
   put the result into controllerStackObject
   --
   module_UpdateToolsMenu moduleStackName
   --
   return controllerStackObject
end module_CreateMenuFromFolder

command menu_Create gMenuTitle, pStackName, pControllerScript
   if exists (stack pStackName) is false then
      put "lcw_Menus" into projectName
   else
      put the project_Name of stack pStackName into projectName
   end if
   --
   project_CreateMenu gMenuTitle, projectName, pControllerScript
   put the result into mController -- a script only stack
   return mController
end menu_Create

command project_CreateMenuFromFolder moduleOrProjectFolder, gMenuTitle, pControllerScript
   if pControllerScript is empty then put controller_ConstructMenuScript (gMenuTitle) into pControllerScript
   --
   project_CreateStack moduleOrProjectFolder, gMenuTitle, "controllers", "controller", pControllerScript, false
   put the result into controllerStackPath
   --
   -- save stack controllerStackPath -- already saved
   put the name of stack controllerStackPath into mController
   --
   menu_ReIndexController mController
   --
   return mController
end project_CreateMenuFromFolder

function menu_CommandToText handlerName
   set the itemdelimiter to "_"
   put item 2 of handlerName into mSuffix
   put text_SplitCaps (mSuffix) into mLine
   return mLine
end menu_CommandToText


--> Menu | Param | Names | Old
-
function script_ParamToHandlerName customParam
   put word 1 of customParam into customParam
   put tolower(char 1 of customParam) into char 1 of customParam
   
   repeat with charNum = 1 to the number of chars of customParam
      if text_StartsWithCaps(char charNum of customParam) is true then
         put "_" before char charNum of customParam
         return customParam
      end if
   end repeat
   return customParam
end script_ParamToHandlerName

private function param_IsBoolean customParam
   return customParam is among the items of "boolean,someBoolean,isBoolean"
end param_IsBoolean


--> Menu | Update
-
function menu_ExtractTableFromScript mTitle, someScript, hTable, mController
   -- not used for mArray
   -- used by "script_MenuTitleTableArray"
   local mLine, mTableLine, mFormatProp, submenuProp, paramProp, fixedSubMenu
   
   -- need a recursion check here???
   menu_CheckRecursionOnExtract mTitle, mController
   if the result is true then breakpoint
   
   -- is there a clever way to use hTable an "on" ???
   put script_GetSuite (mTitle, someScript) into scriptSuite
   -- let's not allow "command" for "menus" for speed reasons (they are message handlers after all)
   filter scriptSuite with "on *"
   
   put empty into mTable
   repeat for each line scriptLine in scriptSuite
      put word 2 to -1 of of scriptLine into comLine
      
      menu_TableLineFromScript mVersion, mTitle, comLine, mController, someScript, hTable, mLine, mTableLine, mFormatProp, submenuProp, paramProp, fixedSubMenu
      put mTableLine & CR after mTable
      
      -- set the subMenuFixed custom prop
      put the result into mItemType
      menu_SetSubmenuFixedProp mItemType, comLine, mTitle, mController, fixedSubMenu, paramProp
   end repeat
   delete char -1 of mTable
   return mTable
end menu_ExtractTableFromScript

command menu_TableLineFromScript mVersion, mTitle, comLine, scriptObject, someScript, hTable, @mLine, @mTableLine, @mFormatProp, @submenuProp, @paramProp, @fixedSubMenu 
   -- uses "someScript" rather than "scriptSuite" in case usefull bits are outside of suite
   -- see "menu_ConvertTable" for counterpart that creates menu from the stored mTable created here
   
   menu_DeconstructCommandLine mVersion, comLine, mCommand, mPrefix, mSuffix, customParam
   put empty into mItemType
   switch
      case mSuffix is empty
         put "-" into mLine
         put mLine into mTableLine
         put empty into mFormatProp
         put empty into submenuProp
         put empty into paramProp
         put empty into fixedSubMenu
         return empty
      case mPrefix is "submenu"
         put "submenu" into mItemType
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         
         _extractInsertedTitle mCommand, mController, someScript, hTable, subMenuTitle, customControllerParam, dynamicTitleProp, mLine, pigeon, mItemType
         
         -- find subMenuController
         put menu_GetDefaultController (subMenuTitle, scriptObject, true) into subMenuController
         put revRuggedID (subMenuController) into subMenuController
         
         put _constructDisabledGetpropName (mSuffix,  someScript, hTable) into mFormatProp
         
         put text_SplitCaps (mSuffix) into mLine
         put menu_ConstructTableLine (mController, dynamicTitleProp, mTitle, mLine, mFormatProp, mItemType, subMenuTitle, subMenuController) into mTableLine
         return mItemType
      case mPrefix is "insert"
         put "insert" into mItemType
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         put revRuggedID (subMenuController) into subMenuController
         
         _extractInsertedTitle mCommand, mController, someScript, hTable, insertedMenuTitle, customControllerParam, dynamicTitleProp, mLine, pigeon, mItemType
         
         if pigeon is empty then -- the number of items of insertedMenuTitle = 1 then
            -- it's a whole menu to insert
            -- could insert the whole thing into the table now rather than late with "menu_CovertTable"
            
            put _constructDisabledGetpropName (mSuffix,  someScript, hTable) into mFormatProp
            
            -- find inserted mControllers
            put menu_GetDefaultController (insertedMenuTitle, scriptObject, true) into insertedMenuController
            put revRuggedID (insertedMenuController) into insertedMenuController
            put menu_ConstructTableLine (mController, dynamicTitleProp, mTitle, "insert", mFormatProp, mItemType, insertedMenuTitle, insertedMenuController) into mTableLine
         else
            -- this is a single menu script item!
            put menu_GetDefaultController (insertedMenuTitle, scriptObject, true) into insertedMenuController
            put revRuggedID (insertedMenuController) into insertedMenuController
            put menu_ConstructTableLine (mController, dynamicTitleProp, mTitle, mLine, mFormatProp, "inserted", insertedMenuTitle, insertedMenuController) into mTableLine
         end if
         return "insert"
      default
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         put revRuggedID (subMenuController) into subMenuController
         if exists(mController) is false then
            put "Cannot find Global menu" && kwote(mTitle) & "!" into someError
            -- lcw_Notify someError, true
            breakpoint
            -- put menu_GetDefaultController (mTitle, scriptObject, true) into mController
            return mItemType
         end if
         menu_DefaultTableLine mVersion, comLine, mCommand, mSuffix, customParam, someScript, hTable, mController, mTitle, mFormatProp, mLine, mTableLine, mItemType, submenuProp, paramProp, fixedSubMenu
         return mItemType
   end switch
end menu_TableLineFromScript

command menu_DeconstructCommandLine mVersion, handlerLine, @handlerName, @handlerPrefix, @handlerSuffix, @customParam
   put token 1 of handlerLine into handlerName
   put token 2 of item 1 of handlerLine into firstParam
   put token 1 of item 2 of handlerLine into secondParam
   put secondParam into customParam -- new way (always pass mTarget as first param)
   set the itemdelimiter to "_"
   put item 1 of handlerName into handlerPrefix
   put item 2 of handlerName into handlerSuffix
end menu_DeconstructCommandLine


--> menu_DefaultTableLine
-
command menu_DefaultTableLine mVersion, comLine, mCommand, mSuffix, customParam, someScript, hTable, mController, mTitle, @mFormatProp, @mLine, @mTableLine, @mItemType, @submenuProp, @paramProp, @fixedSubMenu
   -- ignoreCall: menu_Version
   -- only add disabled_Prop if it exists in the menu_Controller (optional)
   put "disabled_" & mSuffix into mFormatProp
   
   put "G" && mFormatProp into shortHkeyLine
   put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler  -- doing this twice
   if getpropHandler is empty then put empty into mFormatProp
   -- if script_GetGetProp (mFormatProp, someScript) is empty then put empty into mFormatProp
   
   put text_SplitCaps (mSuffix) into mLine
   
   -- new way (assumes mTarget is always passed as the ifirst param
   if the number of items of comLine > 1 then
      -- there is more than one param
      menu_ConstructParamProp someScript, hTable, mCommand, customParam, mController, paramProp, submenuProp, fixedSubMenu
      put the result into mItemType
      put mCommand && "subMenuPath," && mTarget into pigeon
      put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp) into mTableLine
   else
      put mCommand && "mTarget" into pigeon
      put menu_ConstructTableLine (mController, pigeon, mTitle, mLine, mFormatProp, mItemType) into mTableLine
   end if
   
   return mTableLine
end menu_DefaultTableLine


--> menu_ConstructParamProp
-
command menu_ConstructParamProp someScript, hTable, mCommand, customParam, mController, @paramProp, @submenuProp, @fixedSubMenu
   /*
   A complicated handler that introspects to check if there are disables_ and getprops for menus.
   
   These issues may not still be true???
   Putting a cProp handler with a param into a variable works
   But no space between handler and "["
   Also no quotes around variable
   */
   
   put empty into mFormatProp
   put empty into submenuProp
   put empty into paramProp
   put empty into fixedSubMenu
   
   switch
      case customParam is empty
         return empty
      case param_IsBoolean (customParam)
         set the itemdelimiter to "_"
         put item 2 of mCommand into commandBody
         if commandBody is empty then return empty
         
         put script_ParamToHandlerName (commandBody) into paramProp
         put "submenu_Boolean" into submenuProp
         return "boolean"
      default
         -- not a special case
         -- so it is either a fixed menu based on the "Case conditions"
         -- or a "custom" menu based on a getprop submenuProp handler
         
         put script_ParamToHandlerName (customParam) into paramProp
         if last char of paramProp = "y" then
            put char 1 to -2 of paramProp & "ies" into submenuProp
         else
            put paramProp & "s" into submenuProp
         end if
         
         put token 1 of submenuProp into getPropName
         
         put "G" && getPropName into shortHkeyLine
         put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler
         
         if getpropHandler is not empty then
            -- there is a getprop submenuProp handler in the mController script
            return "custom submenu"
         end if
         
         try
            -- should be same as menu_ConvertTable (but on compile I do not know mTarget)
            put submenuProp into submenuProperty
            put the submenuProperty of mController into testSubMenu
            if testSubMenu is not empty then
               -- allows global submenu properties to be defined
               return "custom external"
            end if
         catch tError
            -- looks like submenuProperty could require a param (ie mTarget)
            -- so let's see if we can find some case conditions
         end try
         
         -- is there a "case" statement in the script?
         put "M" && mCommand into shortHkeyLine
         put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into menuHandler
         -- put script_GetCommand (mCommand, someScript) into menuHandler
         
         put handler_ExtractCaseConditions (menuHandler) into fixedSubMenu
         
         line_Delete "default", fixedSubMenu
         if fixedSubMenu is not empty then
            put "submenu_Fixed[" & mCommand & "]" into submenuProp
            return "fixed"
         else
            -- even though the custom prop has failed
            -- this may just be a requirement for a param (and so is fine in real use)
            -- allows (global) getprop handlers outside of the controllers script
            return "custom external"
         end if
   end switch
end menu_ConstructParamProp


--> Deps
-
function menu_ConstructTableLine mController, pigeon, mTitle, mLine, mFormatProp, mItemType, submenuProp, paramProp
   set the itemdelimiter to tab
   
   put mLine into item 1 of mTableLine
   put pigeon into item 2 of mTableLine
   if exists(mController) is false then
      -- could have a menu without a defined inserted Global menu?
      put empty into item 3 of mTableLine
   else
      put revRuggedID (mController) into item 3 of mTableLine
      -- put mController into item 3 of mTableLine
   end if
   put mTitle into item 4 of mTableLine
   put mFormatProp into item 5 of mTableLine
   put mItemType into item 6 of mTableLine
   put submenuProp into item 7 of mTableLine
   put paramProp into item 8 of mTableLine
   
   put menu_CleanLine (mLine) into mSendLine
   put mSendLine into item 9 of mTableLine
   
   return mTableLine
end menu_ConstructTableLine

command menu_SetSubmenuFixedProp mItemType, comLine, mTitle, scriptObject, fixedSubMenu, paramProp
   -- ignoreCall: submenu_Fixed,s
   switch mItemType
      case empty
         break
      case "submenu"
         break
      case "fixed"
         put token 1 of comLine into mCommand
         put menu_GetDefaultController (mTitle, scriptObject, true) into mController
         set the submenu_Fixed [mCommand] of mController to fixedSubMenu
         break
      default
         if paramProp is not empty then
            put menu_GetDefaultController (mTitle, scriptObject, true) into mController
            custom_DeleteProperty paramProp, mController, "submenu_Fixed"	# lets clear it to be tidy ?
         end if
   end switch
end menu_SetSubmenuFixedProp

function menu_GetDefaultController mTitle, targetObject, pSearchScript
   -- key handler in menu_Authoring used by the menu_Update
   -- careful to avoid recursion 
   
   -- check if it is a global menu
   if menu_TitleIsGlobal (mTitle) then
      put menu_GetGlobalController (mTitle) into mController
      if exists (mController) is true then
         return mController
      end if
   end if
   
   -- look up menu in script hierarchy (adds a lot of complexity)
   -- handlers are in "model_MenuSubStacks" for searching menu_SubStackCard's and the script_Hierarchy
   -- but if that library or a local "getprop menu_FoundController" is not present it fails gracefully
   put the menu_FoundController [mTitle] of targetObject into mController
   if exists (mController) then return mController
   
   return targetObject
end menu_GetDefaultController

function menu_TitleIsGlobal mTitle
   -- check if it is a global menu
   set the itemdelimiter to "|"
   put word 1 to -1 of item 1 of mTitle into mTitleStem
   return mTitleStem is "Global"
end menu_TitleIsGlobal


--> Deps
-
function script_GetSuite suiteTitle, someScript
   -- get rid of
   script_SetSuiteOffsets suiteTitle, someScript, startLineNum, endLineNum
   if the result is true then
      put line startLineNum to endLineNum of someScript into suiteScript
      return word 1 to -1 of suiteScript
   else
      return empty
   end if
end script_GetSuite

command script_SetSuiteOffsets suiteTitle, someScript, @startLineNum, @endLineNum
   -- get rid of
   set wholematches to true
   put 0 into startLineNum
   put 0 into endLineNum
   put lineoffset("-->" &&  suiteTitle, someScript) into startLineNum
   if startLineNum is zero then
      put lineoffset("-->" &  suiteTitle, someScript) into startLineNum
   end if
   if startLineNum is zero then return false
   
   put someScript into suiteTitleLines
   filter suiteTitleLines with "-->*"
   put lineoffset("-->" &&  suiteTitle, suiteTitleLines) into titleLineNum
   put line titleLineNum + 1 of suiteTitleLines into nextTitleLine
   if nextTitleLine is empty then
      put the number of lines in someScript into endLineNum
   else
      put lineoffset(nextTitleLine, someScript, startLineNum) into afterStartlineNum
      
      if afterStartlineNum is zero then
         put the number of lines in someScript into endLineNum
      else
         put startLineNum + afterStartlineNum - 1 into endLineNum
      end if
   end if
   return true
end script_SetSuiteOffsets


--> Private
-
private function kwote someText, pQuoteChar
   if pQuoteChar is empty then put quote into pQuoteChar
   return pQuoteChar & someText & pQuoteChar
end kwote

private function text_InitialCaps someText
   repeat with wordNum = 1 to the number of words of someText
      put tolower(word wordNum of someText) into someWord
      put toupper(char 1 of someWord ) into char 1 of someWord
      put someWord into word wordNum of someText
   end repeat
   return someText
end text_InitialCaps

private function text_SplitCaps someWord
   -- was "capsSplit"
   put 1 into charNum
   repeat the number of chars of someWord
      put char charNum of someWord into someChar
      if text_StartsWithCaps (someChar) is true then
         put space before char charNum of someWord
         add 2 to charNum
      else
         add 1 to charNum
      end if
   end repeat
   put text_InitialCaps (word 1 of someWord) into word 1 of someWord
   return word 1 to -1 of someWord
end text_SplitCaps

private function text_StartsWithCaps someText
   put char 1 of sometext into testChar
   put nativeCharToNum (testChar) into someCharNum
   if someCharNum >= 97 and someCharNum <= 122 then
      return false
   else
      return true
   end if
end text_StartsWithCaps

private command line_Delete someLine, @someIndex
   set the wholematches to true
   put lineoffset (someLine, someIndex) into lineNum
   delete line lineNum of someIndex
end line_Delete

private function _constructDisabledGetpropName mSuffix, someScript, hTable
   /*
   To save a lot of dependency code we could use:
   -- put the revAvailableHandlers of scriptObject into mTable
   for speed we should work out mTable in advance (when we get the script) and pass it as a param
   */
   
   put "disabled_" & mSuffix into mFormatProp
   
   -- put script_GetGetProp (mFormatProp, someScript) into getpropHandler
   put "G" && mFormatProp into shortHkeyLine
   put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler
   
   if getpropHandler is empty then put empty into mFormatProp
   return mFormatProp
end _constructDisabledGetpropName

private command _extractInsertedTitle mCommand, mController, someScript, hTable, @insertedMenuTitle, @customControllerParam, @dynamicTitleProp, @mLine, @pigeon, mItemType
   -- ignoreCall: mCommand,c
   
   if mItemType = "insert" then -- inserted version
      -- this is a single menu script item!
      -- should be the same structure as an mvc controller
      -- "Global | Library | Menu,menu_StartupLibrary sillyChoice, mTarget"
      -- with the first item refering to the controller object (or named shortcut), and the second the command
      
      try
         send mCommand to mController
         put the result into insertedInfo
      catch someError -- often a compile error
         return empty
      end try
      
      put item 1 of insertedInfo into insertedMenuTitle
      put item 2 to -1 of insertedInfo into pigeon
      put menu_CommandToText (word 1 of pigeon) into mLine
      
      put empty into customControllerParam
      put empty into dynamicTitleProp
   else if mItemType = "submenu" then -- submenu version
      
      put empty into mLine
      
      -- put script_GetCommand (mCommand, someScript) into menuHandler
      put "M" && mCommand into shortHkeyLine
      put hkeyLine_GetHandler (shortHkeyLine, hTable, someScript) into getpropHandler
      
      
      set the wholematches to true
      put wordoffset ("menu_DoSub", menuHandler) into wordNum
      if wordNum = 0 then
         -- now lets try the return technique used by "insert"
         try
            send mCommand to mController
            put the result into insertedInfo
            put item 1 of insertedInfo into insertedMenuTitle
            put item 2 of insertedInfo into customControllerParam
         catch someError -- often a compile error
            put empty into insertedMenuTitle
            put empty into customControllerParam
            return empty
         end try
      else
         delete word 1 to wordNum of menuHandler
         put token 1 of line 1 of menuHandler into insertedMenuTitle
         put token 3 of line 1 of menuHandler into customControllerParam
      end if
      
      -- no longer stores pigeon to send, but calculates from subMenuTitle + scriptObject
      -- put mCommand && "subMenuPath, mTarget" into pigeon
      put empty into pigeon
      put empty into dynamicTitleProp
   end if
end _extractInsertedTitle
