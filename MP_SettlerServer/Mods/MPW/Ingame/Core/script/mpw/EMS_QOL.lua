-- QualityOfLifeChanges

-- Makes your life easier

--Done:
-- Refresh all troops in selection
-- Expel all entities in selection
-- Host is shown if player leaves
-- Pressing [Space] deselects all serfs tasked with constructing something
-- Holding [Alt] while pressing the serf button on the top of the screen selects all idle serfs
-- Holding [Strg] while pressing button in markets changes buy amount by 250
-- Holding [Alt] while pressing button in markets changes buy amount by 1 000
-- Holding [Strg] and [Alt] while pressing button in markets changes buy amount by 5 000

--Planned:
-- Upgrade all buildings of same type in range?

EMS.QoL = {}
EMS.QoL.LeaderTypes = {}
function EMS.QoL.Setup()
	Input.KeyBindDown(Keys.Space, "EMS.QoL.RemoveWorkingSerfsInSelection()", 2);
	Input.KeyBindDown(Keys.ModifierControl + Keys.Space, "EMS.QoL.RemoveSerfsAndScoutsInSelection()", 2);
	Input.KeyBindDown(Keys.Enter, "EMS.QoL.ActivateOvertime()", 2);
	for k,v in pairs(Entities) do
		if string.find(k,"Leader") then
			EMS.QoL.LeaderTypes[v] = true
		end
	end
	EMS.QoL.GameCallback_GUI_SelectionChanged = GameCallback_GUI_SelectionChanged
	GameCallback_GUI_SelectionChanged = function()
		EMS.QoL.GameCallback_GUI_SelectionChanged()
		if EMS.QoL.LeaderTypes[Logic.GetEntityType(GUI.GetSelectedEntity())] then
			XGUIEng.ShowWidget("Buy_Soldier",1)
			XGUIEng.ShowWidget("Buy_Soldier_Button",1)
		end
	end
	EMS.QoL.GUIAction_BuySoldier = GUIAction_BuySoldier
	GUIAction_BuySoldier = function()
		if XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
			EMS.QoL.DoForAllEntitiesInSelection(EMS.QoL.BuySoldier)
		else
			EMS.QoL.GUIAction_BuySoldier()
		end
	end
	EMS.QoL.GUIAction_ExpelSettler = GUIAction_ExpelSettler
	GUIAction_ExpelSettler = function()
		if XGUIEng.IsModifierPressed(Keys.ModifierControl) == 1 then
			EMS.QoL.DoForAllEntitiesInSelection(EMS.QoL.ExpelSettler)
		else
			EMS.QoL.GUIAction_ExpelSettler()
		end
	end
	Input.KeyBindDown(Keys.Back, "GUI.SellBuilding(GUI.GetSelectedEntity())", 2);
	EMS.QoL.InitSelectingIdleSerfs()

	EMS.QoL.ClockHotkey = function()
		if Logic.GetEntityType(GUI.GetSelectedEntity()) ~= Entities.PU_Serf then
			return;
		end
		if Logic.IsTechnologyResearched(GUI.GetPlayerID(), Technologies.GT_Printing) == 0 then
			return;
		end
		GUIAction_PlaceBuilding(UpgradeCategories.Beautification07);
	end
	if EMS.RD.AdditionalConfig.ActivateDebug then
		 -- in debug mode, Q is already in use
		 Input.KeyBindDown(Keys.ModifierControl + Keys.Y, "EMS.QoL.ClockHotkey()", 2);
	else
		Input.KeyBindDown(Keys.Q, "EMS.QoL.ClockHotkey()", 2);
	end
end
-- Calls the  given func for all entities in selection
-- During each call, only one entity is selected
-- While working, only one call of GUI.AddNote is allowed
function EMS.QoL.DoForAllEntitiesInSelection(_func)
	EMS.QoL.AddNote = GUI.AddNote
	GUI.AddNote = function(_s)
		EMS.QoL.AddNote(_s)
		GUI.AddNote = function() end
	end
	local selection = {GUI.GetSelectedEntities()}
	GUI.ClearSelection()
	for i = 1, table.getn(selection),1 do
		GUI.SelectEntity(selection[i])
		_func()
		GUI.ClearSelection()
	end
	for i = 1,table.getn(selection) do
		GUI.SelectEntity(selection[i])
	end 
	GUI.AddNote = EMS.QoL.AddNote
end
function EMS.QoL.BuySoldier()
	local sel = GUI.GetSelectedEntity()
	if EMS.QoL.LeaderTypes[Logic.GetEntityType(sel)] then
		local maxSol = Logic.LeaderGetMaxNumberOfSoldiers( sel)
		local curSol = Logic.GetSoldiersAttachedToLeader( sel)
		for i = 1, maxSol-curSol do
			EMS.QoL.GUIAction_BuySoldier()
		end
	end
end
function EMS.QoL.ExpelSettler()
	local sel = GUI.GetSelectedEntity()
	if EMS.QoL.LeaderTypes[Logic.GetEntityType(sel)] then
		local curSol = Logic.GetSoldiersAttachedToLeader( sel)
		for i = 1, curSol do
			GUI.ExpelSettler( sel)
		end
	end
	GUI.ExpelSettler( sel)
end
function EMS.QoL.IsSerfInSelection()
	local selection = {GUI.GetSelectedEntities()}
	for k,v in pairs(selection) do
		if Logic.GetEntityType( v) == Entities.PU_Serf then return true end
	end
	return false
end
function EMS.QoL.RemoveSerfsAndScoutsInSelection()
	local sel = {GUI.GetSelectedEntities()};
	local tl, e;
	local type;
	for i = 1, table.getn(sel) do
		type = Logic.GetEntityType(sel[i]);
		if type == Entities.PU_Serf or 
			type == Entities.PU_Scout then
			GUI.DeselectEntity(sel[i])
		end
	end
end
function EMS.QoL.RemoveWorkingSerfsInSelection()
	if not EMS.QoL.IsSerfInSelection() then
		-- original key bind of space
		KeyBindings_JumpToLastHotSpot();
		return;
	end
	local sel = {GUI.GetSelectedEntities()};
	local tl, e;
	for i = 1, table.getn(sel) do
		if Logic.GetEntityType(sel[i]) == Entities.PU_Serf then
			e = sel[i];
			tl = Logic.GetCurrentTaskList(e);
			if Logic.GetCurrentTaskList(e) == "TL_SERF_GO_TO_CONSTRUCTION_SITE"
			or Logic.GetCurrentTaskList(e) == "TL_SERF_BUILD" then
				GUI.DeselectEntity(e);
			end
		else
			GUI.DeselectEntity(sel[i])
		end
	end
end
function EMS.QoL.InitSelectingIdleSerfs()
	EMS.QoL.GUIAction_FindIdleSerf = GUIAction_FindIdleSerf
	GUIAction_FindIdleSerf = function(_arg)
		if XGUIEng.IsModifierPressed( Keys.ModifierAlt) == 1 then
			GUI.ClearSelection()
			local pId = GUI.GetPlayerID()
			local maxx = math.min( 20, Logic.GetNumberOfIdleSerfs( pId))
			local currId = 0
			for i = 1, maxx do
				currId = Logic.GetNextIdleSerf( 1, currId)
				GUI.SelectEntity( currId)
			end
		else
			EMS.QoL.GUIAction_FindIdleSerf( _arg)
		end
	end
end
EMS.QoL.NoOvertime = {
	[Entities.PB_Farm1] = true,
	[Entities.PB_Farm2] = true,
	[Entities.PB_Farm3] = true,
	[Entities.PB_Residence1] = true,
	[Entities.PB_Residence2] = true,
	[Entities.PB_Residence3] = true,
	[Entities.PB_Headquarters1] = true,
	[Entities.PB_Headquarters2] = true,
	[Entities.PB_Headquarters3] = true,
	[Entities.PB_Market1] = true,
	[Entities.PB_WeatherTower1] = true,
	[Entities.PB_Archery1] = true,
	[Entities.PB_Archery2] = true,
	[Entities.PB_Barracks1] = true,
	[Entities.PB_Barracks2] = true,
	[Entities.PB_Stable1] = true,
	[Entities.PB_Stable2] = true,
	[Entities.PB_DarkTower1] = true,
	[Entities.PB_DarkTower2] = true,
	[Entities.PB_DarkTower3] = true,
	[Entities.PB_Tower1] = true,
	[Entities.PB_Tower2] = true,
	[Entities.PB_Tower3] = true,
	[Entities.PB_VillageCenter1] = true,
	[Entities.PB_VillageCenter2] = true,
	[Entities.PB_VillageCenter3] = true,
	-- beauti, recrutiment,..
}
function EMS.QoL.ActivateOvertime()
	local sel = GUI.GetSelectedEntity();
	local type = Logic.GetEntityType(sel);
	if Logic.IsBuilding(sel) == 0 then
		return;
	end
	if EMS.QoL.NoOvertime[type] then
		return;
	end
	if string.find(Logic.GetEntityTypeName(type), "Beautification" ,1,true) then
		return;
	end
	if Logic.IsConstructionComplete(sel) == 0 then
		return;
	end
	GUI.ToggleOvertimeAtBuilding(sel);
end