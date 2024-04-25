--------------------------------------------------------------------------------
MPW.QOL = {}
--------------------------------------------------------------------------------
function MPW.QOL.Init()
	
	-- load EMS QoL if its not an EMS maps
	if not MPW.IsEMS then
		EMS = { RD = { AdditionalConfig = {} } }
		Script.Load("data\\script\\mpw\\ems_qol.lua")
		EMS.QoL.Setup()
	end
end
--------------------------------------------------------------------------------
function MPW.QOL.Load()
	
	-- return an empty string instead of nil
	MPW.GetCurrentTaskList = MPW.GetCurrentTaskList or Logic.GetCurrentTaskList
	Logic.GetCurrentTaskList = function( _Id )
		return MPW.GetCurrentTaskList( _Id ) or ""
	end
end
--------------------------------------------------------------------------------
function MPW.QOL.PostInit()
	
	-- restore some ems stuff
	EMS.QoL.GameCallback_GUI_SelectionChanged = GameCallback_GUI_SelectionChanged
	GameCallback_GUI_SelectionChanged = function()
	
		EMS.QoL.GameCallback_GUI_SelectionChanged()
		local SelectedEntites = { GUI.GetSelectedEntities() }
		
		for _, SelectedEntity in ipairs( SelectedEntites ) do
			if EMS.QoL.LeaderTypes[ Logic.GetEntityType( SelectedEntity ) ] then
				XGUIEng.ShowWidget( "Buy_Soldier", 1 )
				XGUIEng.ShowWidget( "Buy_Soldier_Button", 1 )
			end
		end
	end
end
--------------------------------------------------------------------------------
function MPW.QOL.PostLoad()
	
	-- ems hotkeys
	Input.KeyBindDown(Keys.Space, "EMS.QoL.RemoveWorkingSerfsInSelection()", 2)
	Input.KeyBindDown(Keys.ModifierControl + Keys.Space, "EMS.QoL.RemoveSerfsAndScoutsInSelection()", 2)
	Input.KeyBindDown(Keys.Enter, "EMS.QoL.ActivateOvertime()", 2)
	
	-- mpw hotkeys
	
	-- hotkeys for mines, taverns and architects
	Input.KeyBindDown( Keys.ModifierControl + Keys[ XGUIEng.GetStringTableText( "KeyBindings/SelectMine" )], 	"KeyBindings_SelectUnit( { UpgradeCategories.ClayMine, UpgradeCategories.StoneMine, UpgradeCategories.IronMine, UpgradeCategories.SulfurMine }, 1 )", 2 )
	Input.KeyBindDown( Keys.ModifierControl + Keys[ XGUIEng.GetStringTableText( "AOKeyBindings/SelectTavern" )], 	"KeyBindings_SelectUnit( UpgradeCategories.Tavern, 1 )", 2 )
	Input.KeyBindDown( Keys.ModifierControl + Keys[ XGUIEng.GetStringTableText( "AOKeyBindings/SelectMasterBuilderWorkshop" )], 	"KeyBindings_SelectUnit( UpgradeCategories.MasterBuilderWorkshop, 1 )", 2 )
	
	-- solve hq selecton and fill up soldiers interference
	Input.KeyBindDown( Keys.ModifierControl + Keys.Q, "MPW.QOL.CtrlQ()", 2 )

	-- extend backspace to units
	Input.KeyBindDown( Keys.Back, "MPW.QOL.Back()", 2 )
	Input.KeyBindDown( Keys.ModifierControl + Keys.Back, "MPW.QOL.CtrlBack()", 2 )
	Input.KeyBindDown( Keys.ModifierShift + Keys.Back, "MPW.QOL.ShiftBack()", 2 )
end
--------------------------------------------------------------------------------
-- override for multiple ucats and idle units
--------------------------------------------------------------------------------
function KeyBindings_SelectUnit( _UpgradeCategory, _Type, _IdleOnly )
	
	if XGUIEng.IsModifierPressed( Keys.ModifierShift ) == 1 then
		_IdleOnly = true
	end
	
	-- Do not jump in cutscene!
	if gvInterfaceCinematicFlag == 1 then
		return
	end
	
	if type( _UpgradeCategory ) ~= "table" then
		_UpgradeCategory = { _UpgradeCategory }
	end
	
	local entitytable = {}
	local idleentitytable = {}
	local entitytypes = {}
	
	for _, upgradecategory in ipairs( _UpgradeCategory ) do
		
		local tempentitytypes = {}
		
		if _Type == 1 then
			tempentitytypes = { Logic.GetBuildingTypesInUpgradeCategory( upgradecategory ) }
			
			-- just dont search for idle buildings ...
			_IdleOnly = nil
		else
			tempentitytypes = { Logic.GetSettlerTypesInUpgradeCategory( upgradecategory ) }
		end
		
		for i = 1, tempentitytypes[1] do
			table.insert( entitytypes, tempentitytypes[i + 1] )
		end
	end
	
	-- get all entity types
	for _, entitytype in ipairs( entitytypes ) do
		for id in CEntityIterator.Iterator( CEntityIterator.OfPlayerFilter( GUI.GetPlayerID() ), CEntityIterator.OfTypeFilter( entitytype ) ) do
			table.insert( entitytable, id )
			
			if _IdleOnly and string.find( Logic.GetCurrentTaskList( id ), "IDLE" ) then
				table.insert( idleentitytable, id )
			end
		end
	end
	
	if _IdleOnly and table.getn( idleentitytable ) > 0 then
		entitytable = idleentitytable
	end
	
	if table.getn( entitytable ) == 0 then
		return
	end
	
	local counter = gvKeyBindings_LastSelectedEntityPos + 1
	
	if counter >= table.getn( entitytable ) then
		counter = 0
	end
	
	gvKeyBindings_LastSelectedEntityPos = counter
	
	local id = entitytable[ 1 + counter ]
	
	local x, y = Logic.EntityGetPos( id )
	Camera.ScrollSetLookAt(x, y)
	
	GUI.SetSelectedEntity( id )
end
--------------------------------------------------------------------------------
-- check for all selected entities, if it can buy soldiers
--------------------------------------------------------------------------------
function GUIUpdate_BuySoldierButton()
	
	local SelectedEntities = { GUI.GetSelectedEntities() }
	
	for _, LeaderID in ipairs( SelectedEntities ) do
		
		local MilitaryBuildingID = Logic.LeaderGetNearbyBarracks( LeaderID )
		local test = Logic.IsEntityInCategory( LeaderID, EntityCategories.Cannon )
		
		if MilitaryBuildingID ~= 0	then
			if Logic.IsConstructionComplete( MilitaryBuildingID ) == 1 then
				XGUIEng.DisableButton( gvGUI_WidgetID.BuySoldierButton, 0 )
				return true
			end
		end
	end
	
	XGUIEng.DisableButton( gvGUI_WidgetID.BuySoldierButton, 1 )
	return false
end
--------------------------------------------------------------------------------
-- swith between buy soldier and select hq
--------------------------------------------------------------------------------
function MPW.QOL.CtrlQ()
	if Logic.IsLeader( GUI.GetSelectedEntity() ) == 1 then --and Logic.IsHero( GUI.GetSelectedEntity() ) == 0 then
		EMS.QoL.DoForAllEntitiesInSelection( EMS.QoL.BuySoldier )
	else
		KeyBindings_SelectUnit( UpgradeCategories.Headquarters, 1 )
	end
end
--------------------------------------------------------------------------------
-- expel selected entity or sell selected building
--------------------------------------------------------------------------------
function MPW.QOL.Back()
	
	local SelectedEntity = GUI.GetSelectedEntity()
	
	if SelectedEntity ~= 0 then
		if Logic.IsBuilding( SelectedEntity ) == 1 then
			
			MPW.QOL.ExpelAllWorkersOfBuilding( SelectedEntity )
			GUI.SellBuilding( SelectedEntity )
		else
			if Logic.IsHero( SelectedEntity ) == 0 then
				GUI.ExpelSettler( SelectedEntity )
			else
				GUIAction_TrollHeroExpell()
			end
		end
	end
end
--------------------------------------------------------------------------------
-- expel all selected entities or sell all buildings of selected type
--------------------------------------------------------------------------------
function MPW.QOL.CtrlBack()
	
	local SelectedEntities = { GUI.GetSelectedEntities() }
	local SelectedEntity = SelectedEntities[1]
	
	if SelectedEntity then
		if Logic.IsBuilding( SelectedEntity ) == 1 then
			
			-- get alle building types in buildings upgrade category
			local entitytypes = { Logic.GetBuildingTypesInUpgradeCategory( Logic.GetUpgradeCategoryByBuildingType( Logic.GetEntityType( SelectedEntity ) ) ) }
			
			for i = 1, entitytypes[1] do
				for id in CEntityIterator.Iterator( CEntityIterator.OfPlayerFilter( GUI.GetPlayerID() ), CEntityIterator.OfTypeFilter( entitytypes[i + 1] ) ) do
					MPW.QOL.ExpelAllWorkersOfBuilding( id )
					GUI.SellBuilding( id )
				end
			end
			
			MPW.QOL.ExpelAllWorkersOfBuilding( SelectedEntity )
			GUI.SellBuilding( SelectedEntity )
		else
			for _, entity in ipairs( SelectedEntities ) do
				if Logic.IsHero( entity ) == 0 then
					
					MPW.QOL.ExpelAllSoldiersOfLeader( entity )
					GUI.ExpelSettler( entity )
				end
			end
		end
	end
end
--------------------------------------------------------------------------------
-- toggle expel workers on sell building
--------------------------------------------------------------------------------
function MPW.QOL.ShiftBack()
	
	if MPW.QOL.ExpelWorkersOnSellBuilding == 1 then
		MPW.QOL.ExpelWorkersOnSellBuilding = 0
		Message( "Entlasse Arbeiter beim abreißen von Gebäuden: @color:220,64,16 AUS @color:255,255,255" )
	else
		MPW.QOL.ExpelWorkersOnSellBuilding = 1
		Message( "Entlasse Arbeiter beim abreißen von Gebäuden: @color:64,220,16 EIN @color:255,255,255" )
	end
end
--------------------------------------------------------------------------------
function MPW.QOL.ExpelAllWorkersOfBuilding( _Building )
	
	if MPW.QOL.ExpelWorkersOnSellBuilding == 1 then
		
		_Building = _Building or GUI.GetSelectedEntity()
		local workers = { Logic.GetAttachedWorkersToBuilding( _Building ) }
		
		for _, worker in ipairs( workers ) do
			GUI.ExpelSettler( worker )
		end
	end
end
--------------------------------------------------------------------------------
function MPW.QOL.ExpelAllSoldiersOfLeader( _Leader )
	
	_Leader = _Leader or GUI.GetSelectedEntity()
	
	if Logic.IsLeader( _Leader ) == 1 then
		
		local soldiers = Logic.GetSoldiersAttachedToLeader( _Leader )
		
		for i = 1, soldiers do
			GUI.ExpelSettler( _Leader )
		end
	end
end
--------------------------------------------------------------------------------
-- override to only find idle leaders
--------------------------------------------------------------------------------
MPW.KeyBindings_FindIdleUnit = KeyBindings_FindIdleUnit
function KeyBindings_FindIdleUnit()
	
	local player = GUI.GetPlayerID()
	local firstleaderid = Logic.GetNextLeader( player, gvInterface_LastLeaderID )
	local currentleaderid = firstleaderid
	
	repeat
		if string.find( Logic.GetCurrentTaskList( currentleaderid ), "IDLE" ) then
			
			gvInterface_LastLeaderID = currentleaderid

			local x, y = Logic.EntityGetPos( currentleaderid )
			Camera.ScrollSetLookAt( x, y )
			
			GUI.SetSelectedEntity( currentleaderid )
			return
		end
		
		currentleaderid = Logic.GetNextLeader( player, currentleaderid )
		
	until( currentleaderid == firstleaderid )
	
	-- optional: call the orig
	MPW.KeyBindings_FindIdleUnit()
end