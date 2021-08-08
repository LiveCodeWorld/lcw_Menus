script "Global | Display | MenuIndex | Line | Menu"
--> MetaData
-
license: GPLv3
name: Global | Display | MenuIndex | Line | Menu
type: controller
version: 0.3


--> Menu | Init
-

getprop disabled_DeleteOldMenuCard [indexView]
   put the selected_Line of indexView into cardName
   if exists (card cardName of stack "libOPN_Menus") is true then
      put the revAvailablehandlers of card cardName of stack "libOPN_Menus" into mHandlers
      if mHandlers is empty then
         return false
      else
         return true
      end if
   else
      return "delete"
   end if
end disabled_DeleteOldMenuCard


--> Global | Display | MenuIndex | Line | Menu
-
on menu_DeleteOldMenuCard indexView
   put the selected_Line of indexView into cardName
   put merge ("Are you sure you want to delete card '[[cardName]]' of stack libOPN_Menus?") into someQuestion
   lcw_Answer someQuestion
   
   put "libOPN_Menus" into stackName
   delete card cardName of stack stackName
   put the cardnames of stack stackName into globalMenuCardNames
   sort globalMenuCardNames
   set the view_Index of indexView to globalMenuCardNames
end menu_DeleteOldMenuCard
