--------------------------------------------------------------------------------
-- TODO:
-- fix excludes
-- add borderstones on straight edges
-- add terrain restrictions to border
--------------------------------------------------------------------------------
MPW.Territory = {}
MPW.Territory.TerritoryBuildingTypes = {
	[Entities.PB_Headquarters1] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_Headquarters2] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_Headquarters3] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_VillageCenter1] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_VillageCenter2] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_VillageCenter3] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_Outpost1] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_Outpost2] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_Outpost3] = {Range = 10000, NeedsTerritory = false},
	[Entities.PB_Tower1] = {Range = 5000, NeedsTerritory = true},
	[Entities.PB_Tower2] = {Range = 5000, NeedsTerritory = true},
	[Entities.PB_Tower3] = {Range = 5000, NeedsTerritory = true},
}
MPW.Territory.TerritoryBuildings = {}
MPW.Territory.BorderStones = {}
table.insert(MPW.Modules, "Territory")
--------------------------------------------------------------------------------
function MPW.Territory.Init()
	LuaDebugger.Log( "Territory.Init()" )
	--Script.Load("maps\\user\\ems\\tools\\s5CommunityLib\\comfort\\other\\nexttick.lua")

	WidgetHelper.AddPreCommitCallback(
		function()
			CWidget.Transaction_RemoveWidget("Build_Outpost")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\build_outpost.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\upgrade_outpost1.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\upgrade_outpost2.xml")
		end
	)

	for p = 1, (CNetwork and 16) or 8 do
		MPW.Territory.BorderStones[p] = {}
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.PostInit()
	LuaDebugger.Log( "Territory.PostInit()" )

	MPW.Territory.GameCallback_GUI_SelectionChanged = GameCallback_GUI_SelectionChanged
	function GameCallback_GUI_SelectionChanged()
		MPW.Territory.GameCallback_GUI_SelectionChanged()

		local id = GUI.GetSelectedEntity()
		if Logic.IsBuilding(id) == 1 and Logic.IsConstructionComplete(id) == 1 then
			local entitytype = Logic.GetEntityType(id)
			local upgradecategory = Logic.GetUpgradeCategoryByBuildingType(entitytype)

			if upgradecategory == UpgradeCategories.Outpost then
				XGUIEng.ShowWidget(gvGUI_WidgetID.Outpost,0)
				XGUIEng.ShowWidget(gvGUI_WidgetID.Headquarter,1)
				XGUIEng.ShowWidget("Research_Tracking", 0)
				XGUIEng.ShowWidget("Upgrade_Headquarter1", 0)
				XGUIEng.ShowWidget("Upgrade_Headquarter2", 0)
			elseif upgradecategory == UpgradeCategories.Headquarters then
				XGUIEng.ShowWidget("Research_Tracking", 1)
				XGUIEng.ShowWidget("Upgrade_Outpost1", 0)
				XGUIEng.ShowWidget("Upgrade_Outpost2", 0)
			end
		end
	end

	-- check placement
	MPW.Territory.GameCallback_PlaceBuildingAdditionalCheck = GameCallback_PlaceBuildingAdditionalCheck
	function GameCallback_PlaceBuildingAdditionalCheck(_EntityType, _X, _Y, _Rotation, _IsBuildOn)

		local result = (MPW.Territory.GameCallback_PlaceBuildingAdditionalCheck or function() end)(_EntityType, _X, _Y, _Rotation, _IsBuildOn)
		local territorybuilding = MPW.Territory.TerritoryBuildingTypes[_EntityType]

		if not territorybuilding or territorybuilding.NeedsTerritory then
			if not MPW.Territory.IsOwnTerritory(_X, _Y) then --and not MPW.Territory.IsAlliedTerritory(_X, _Y) then
				return false
			end
		else
			if MPW.Territory.IsHostileTerritory(_X, _Y) then
				return false
			end
		end

		return result
	end
	
	-- register new buildings
	MPW.Territory.GameCallback_OnBuildingConstructionComplete = GameCallback_OnBuildingConstructionComplete
	function GameCallback_OnBuildingConstructionComplete(_BuildingId, _PlayerId)
		MPW.Territory.GameCallback_OnBuildingConstructionComplete(_BuildingId, _PlayerId)
		if MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(_BuildingId)] then
			MPW.Territory.AddTerritoryBuilding(_BuildingId)
			MPW.Territory.UpdateBorder()
			MPW.Territory.UpdateBuildingsByBuilding(_BuildingId)
		end
	end

	-- update upgraded buildings
	MPW.Territory.GameCallback_OnBuildingUpgradeComplete = GameCallback_OnBuildingUpgradeComplete
	function GameCallback_OnBuildingUpgradeComplete(_OldId, _NewId)
		MPW.Territory.GameCallback_OnBuildingUpgradeComplete(_OldId, _NewId)
		if MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(_OldId)] then
			MPW.Territory.UpdateTerritoryBuilding(_OldId, _NewId)
		end
	end

	-- remove destroyed buildings
	function MPW.Territory.EventOnEntityDestroyed()
		local id = Event.GetEntityID()
		if MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(id)] then
			MPW.Territory.RemoveTerritoryBuilding(id)
			MPW.Territory.UpdateBorder()
			MPW.Territory.UpdateBuildingsByBuilding(id)
		end
	end

	-- prevent removing player buildings on defeat
	function MPW.Defeat.PlayerLost(_PlayerId)
		Logic.PlayerSetGameStateToLost(_playerId);
		-- remove territory buildings and all settlers
		for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_PlayerId), CEntityIterator.OfAnyTypeFilter(
			Entities.PB_Outpost1,
			Entities.PB_Outpost2,
			Entities.PB_Outpost3,
			Entities.PB_Tower1,
			Entities.PB_Tower2,
			Entities.PB_Tower3
		)) do
			Logic.DestroyEntity(id)
		end
		for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_PlayerId), CEntityIterator.IsSettlerFilter()) do
			Logic.DestroyEntity(id)
		end
	end

	MPW.Territory.EventOnEntityDestroyedId = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, MPW.Territory.EventOnEntityDestroyed, 1)

	-- register buildings on mapstart and equaly distribute overlapping areas
	for id in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(unpack(MPW.Territory.GetTerritoryBuildingTypes()))) do
		MPW.Territory.AddTerritoryBuilding(id)
	end
	MPW.Territory.InitExcludes()

	MPW.Territory.UpdateBorder()
	MPW.Territory.UpdateAllBuildings()
end
--------------------------------------------------------------------------------
function MPW.Territory.Unload()
	LuaDebugger.Log( "Territory.Unload()" )
	Trigger.UnrequestTrigger(MPW.Territory.EventOnEntityDestroyedId)
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Territories
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function MPW.Territory.IsOwnTerritory(_X, _Y, _PlayerId)
	_PlayerId = _PlayerId or GUI.GetPlayerID()
	return MPW.Territory.GetTerritoryPlayer(_X, _Y) == _PlayerId
end
--------------------------------------------------------------------------------
function MPW.Territory.IsAlliedTerritory(_X, _Y, _PlayerId)
	local playerid = MPW.Territory.GetTerritoryPlayer(_X, _Y)
	local playerids = MPW.Territory.GetAlliedPlayerIds(_PlayerId)
	for i = 1, table.getn(playerids) do
		if playerids[i] == playerid then
			return true
		end
	end
	return false
end
--------------------------------------------------------------------------------
function MPW.Territory.IsHostileTerritory(_X, _Y, _PlayerId)
	local playerid = MPW.Territory.GetTerritoryPlayer(_X, _Y)
	local playerids = MPW.Territory.GetHostilePlayerIds(_PlayerId)
	for i = 1, table.getn(playerids) do
		if playerids[i] == playerid then
			return true
		end
	end
	return false
end
--------------------------------------------------------------------------------
function MPW.Territory.IsNeutralTerritory(_X, _Y)
	return MPW.Territory.GetTerritoryPlayer(_X, _Y) == 0
end
--------------------------------------------------------------------------------
function MPW.Territory.GetTerritoryPlayer(_X, _Y)
	for i = 1, table.getn(MPW.Territory.TerritoryBuildings) do
		local territorybuilding = MPW.Territory.TerritoryBuildings[i]
		if MPW.Territory.IsInRangeOfTerritoryBuilding(_X, _Y, territorybuilding) then
			return Logic.EntityGetPlayer(territorybuilding.Id)
		end
	end
	return 0
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Territory Building Types
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function MPW.Territory.GetTerritoryBuildingTypes()
	local territorybuildings = {}
	for territorybuilding, _ in pairs(MPW.Territory.TerritoryBuildingTypes) do
		table.insert(territorybuildings, territorybuilding)
	end
	return territorybuildings
end
--------------------------------------------------------------------------------
function MPW.Territory.GetTerritoryBuildingMaxRange()
	local maxrange = 0
	for _, territorybuildingprops in pairs(MPW.Territory.TerritoryBuildingTypes) do
		maxrange = math.max(maxrange, territorybuildingprops.Range)
	end
	return maxrange
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Player Id Diplomacy
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function MPW.Territory.GetAlliedPlayerIds(_PlayerId)
	_PlayerId = _PlayerId or GUI.GetPlayerID()
	return MPW.Territory.GetPlayerIdsOfDiplomacy(_PlayerId, Diplomacy.Friendly)
end
--------------------------------------------------------------------------------
function MPW.Territory.GetHostilePlayerIds(_PlayerId)
	_PlayerId = _PlayerId or GUI.GetPlayerID()
	return MPW.Territory.GetPlayerIdsOfDiplomacy(_PlayerId, Diplomacy.Hostile)
end
--------------------------------------------------------------------------------
function MPW.Territory.GetPlayerIdsOfDiplomacy(_PlayerId, _Diplomacy)
	local playerids = {}
	for p = 1, (CNetwork and 16) or 8 do
		if p ~= _PlayerId and Logic.GetDiplomacyState(_PlayerId, p) == _Diplomacy then
			table.insert(playerids, p)
		end
	end
	return playerids
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Update Borders
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function MPW.Territory.UpdateBorder()
	-- get all existing borderstones
	local borderstones = {}
	for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Border)) do
		borderstones[id] = false
	end

	-- get required locations for borderstones
	local borderstonelocations = {}
	for i = table.getn(MPW.Territory.TerritoryBuildings), 1, -1 do
		local id = MPW.Territory.TerritoryBuildings[i].Id
		local range = MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(id)].Range
		local posx, posy = Logic.GetEntityPosition(id)
		local player = Logic.EntityGetPlayer(id)

		local angle, amount = 0, 2 * range * math.pi / 750
 
		while angle < math.pi * 2 do
			local sin, cos = math.sin(angle), math.cos(angle)
			local playeroutside = MPW.Territory.GetTerritoryPlayer(posx + (range+1) * sin, posy + (range+1) * cos)

			if playeroutside ~= player then
				local playerinside = MPW.Territory.GetTerritoryPlayer(posx + (range-1) * sin, posy + (range-1) * cos)
				if playerinside == player then
					table.insert(borderstonelocations, {P = player, X = posx + range * sin, Y = posy + range * cos})
				end
				if playeroutside ~= 0 and playerinside ~= playeroutside then
					table.insert(borderstonelocations, {P = playeroutside, X = posx + (range+100) * sin, Y = posy + (range+100) * cos})
				end
			end

			angle = angle + math.pi * 2 / amount
		end
	end

	-- compare existing borderstones with required locations
	for i = table.getn(borderstonelocations), 1, -1 do
		local borderstone = borderstonelocations[i]
		local _, id = Logic.GetPlayerEntitiesInArea(borderstone.P, Entities.XD_Border, borderstone.X, borderstone.Y, 1, 1, 16)
		if id then
			borderstones[id] = true
			MPW.Territory.ShowBorderStone(id)
			table.remove(borderstonelocations, i)
		end
	end

	-- move unneeded borderstones out of sight
	for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Border)) do
		if not borderstones[id] then
			MPW.Territory.HideBorderStone(id)
		end
	end

	-- create remaining borderstones
	for i = 1, table.getn(borderstonelocations) do
		local borderstone = borderstonelocations[i]
		MPW.Territory.CreateBorderStone(borderstone.P, borderstone.X, borderstone.Y)
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.CreateBorderStone(_Player, _X, _Y)
	local mapcenter = Logic.WorldGetSize() / 2
	if IsInRange(_X, _Y, mapcenter, mapcenter, mapcenter) then
		local id = MPW.Territory.PopUnusedBorderStoneOfPlayer(_Player)
		if id then
			MPW.Territory.MoveBorderStone(id, _X, _Y)
		else
			Logic.CreateEntity(Entities.XD_Border, _X, _Y, math.random(360), _Player)
		end
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.MoveBorderStone(_Id, _X, _Y)
	CUtil.EntitySetPosition(_Id, _X, _Y)
	Logic.SetModelAndAnimSet(_Id, Models.XD_Border)
	--NextTick( Logic.SetModelAndAnimSet, _Id, Models.XD_Border)
end
--------------------------------------------------------------------------------
function MPW.Territory.HideBorderStone(_Id)
	Logic.SetModelAndAnimSet(_Id, Models.Effects_XF_Die)
	MPW.Territory.BorderStones[Logic.EntityGetPlayer(_Id)][_Id] = true
end
--------------------------------------------------------------------------------
function MPW.Territory.ShowBorderStone(_Id)
	Logic.SetModelAndAnimSet(_Id, Models.XD_Border)
	MPW.Territory.BorderStones[Logic.EntityGetPlayer(_Id)][_Id] = nil
end
--------------------------------------------------------------------------------
function MPW.Territory.PopUnusedBorderStoneOfPlayer(_Player)
	for id, _ in pairs(MPW.Territory.BorderStones[_Player]) do
		MPW.Territory.BorderStones[_Player][id] = nil
		return id
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Update Player Buildings in Territories
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function MPW.Territory.UpdateAllBuildings()
	local mapcenter = Logic.WorldGetSize()/2
	MPW.Territory.UpdateBuildingsInArea(mapcenter, mapcenter, mapcenter)
end
--------------------------------------------------------------------------------
function MPW.Territory.UpdateBuildingsByBuilding(_BuildingId)
	local x, y = Logic.GetEntityPosition(_BuildingId)
	MPW.Territory.UpdateBuildingsInArea(x, y, MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(_BuildingId)].Range)
end
--------------------------------------------------------------------------------
function MPW.Territory.UpdateBuildingsInArea(_X, _Y, _Range)
	for id in CEntityIterator.Iterator(CEntityIterator.NotOfPlayerFilter(0), CEntityIterator.IsBuildingFilter(), CEntityIterator.InRangeFilter(_X, _Y, _Range)) do
		local x, y = Logic.GetEntityPosition(id)
		local buildingplayer = Logic.EntityGetPlayer(id)
		local territoryplayer = MPW.Territory.GetTerritoryPlayer(x, y)
		if territoryplayer ~= buildingplayer then
			if territoryplayer == 0 then
				Logic.SuspendEntity(id)
				Logic.SetEntitySelectableFlag(id, 0)
				Logic.SetCurrentMaxNumWorkersInBuilding(id, 0)
			else
				Logic.ChangeEntityPlayerID(id, territoryplayer)
				Logic.SetEntitySelectableFlag(id, 1)
				Logic.SetCurrentMaxNumWorkersInBuilding(id, Logic.GetMaxNumWorkersInBuilding(id))
			end
		else
			Logic.ResumeEntity(id)
			Logic.SetEntitySelectableFlag(id, 1)
			Logic.SetCurrentMaxNumWorkersInBuilding(id, Logic.GetMaxNumWorkersInBuilding(id))
		end
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Territory Buildings
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function MPW.Territory.AddTerritoryBuilding(_BuildingId)
	table.insert(MPW.Territory.TerritoryBuildings, {Id = _BuildingId, Excludes = {}})
end
--------------------------------------------------------------------------------
function MPW.Territory.GetTerritoryBuilding(_BuildingId)
	for i = 1, table.getn(MPW.Territory.TerritoryBuildings) do
		if MPW.Territory.TerritoryBuildings[i].Id == _BuildingId then
			return MPW.Territory.TerritoryBuildings[i]
		end
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.UpdateTerritoryBuilding(_OldId, _NewId)
	for i = 1, table.getn(MPW.Territory.TerritoryBuildings) do
		local territorybuilding = MPW.Territory.TerritoryBuildings[i]
		if territorybuilding.Id == _OldId then
			MPW.Territory.TerritoryBuildings[i].Id = _NewId
		end
		if territorybuilding.Excludes[_OldId] then
			territorybuilding.Excludes[_NewId] = territorybuilding.Excludes[_OldId]
			territorybuilding.Excludes[_OldId] = nil
		end
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.RemoveTerritoryBuilding(_BuildingId)
	for i = 1, table.getn(MPW.Territory.TerritoryBuildings) do
		if MPW.Territory.TerritoryBuildings[i].Id == _BuildingId then
			table.remove(MPW.Territory.TerritoryBuildings, i)
			return
		end
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.AddTerritoryBuildingExcludes(_BuildingId1, _BuildingId2)

	local ax, ay = Logic.GetEntityPosition(_BuildingId1)
	local ar = MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(_BuildingId1)].Range

	local bx, by = Logic.GetEntityPosition(_BuildingId2)
	local br = MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(_BuildingId2)].Range

	local x1, y1, x2, y2 = GetCircleIntersections(ax, ay, ar, bx, by, br)

	if x2 then
		local dir = math.atan2(x1-x2, y1-y2)
		MPW.Territory.AddTerritoryBuildingExclude(_BuildingId1, _BuildingId2, x1, y1, dir)
		MPW.Territory.AddTerritoryBuildingExclude(_BuildingId2, _BuildingId1, x2, y2, dir + math.rad(180))
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.AddTerritoryBuildingExclude(_BuildingId1, _BuildingId2, _X, _Y, _Dir)
	local territorybuilding = MPW.Territory.GetTerritoryBuilding(_BuildingId1)
	if territorybuilding then
		table.insert(territorybuilding.Excludes, {Id = _BuildingId2, X = _X, Y = _Y, Dir = _Dir})
	end
end
--------------------------------------------------------------------------------
function MPW.Territory.IsInRangeOfBuilding(_X, _Y, _BuildingId)
	local x, y = Logic.GetEntityPosition(_BuildingId)
	local r = MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(_BuildingId)].Range

	if IsInRange(_X, _Y, x, y, r) then
		local territorybuilding = MPW.Territory.GetTerritoryBuilding(_BuildingId)
		if territorybuilding then
			for id, exclude in pairs(territorybuilding.Excludes) do
				if GetPositionsSideToLine(_X, _Y, exclude.X, exclude.Y, exclude.Dir) < 0 then
					return false
				end
			end
		end
		return true
	end
	return false
end
--------------------------------------------------------------------------------
function MPW.Territory.IsInRangeOfTerritoryBuilding(_X, _Y, _TerritoryBuilding)
	local id = _TerritoryBuilding.Id
	local x, y = Logic.GetEntityPosition(id)
	local r = MPW.Territory.TerritoryBuildingTypes[Logic.GetEntityType(id)].Range

	if IsInRange(_X, _Y, x, y, r) then
		for _, exclude in pairs(_TerritoryBuilding.Excludes) do
			if GetPositionsSideToLine(_X, _Y, exclude.X, exclude.Y, exclude.Dir) < 0 then
				return false
			end
		end
		return true
	end
	return false
end
--------------------------------------------------------------------------------
function MPW.Territory.InitExcludes()
	for i = 1, table.getn(MPW.Territory.TerritoryBuildings) do
		for j = 1, table.getn(MPW.Territory.TerritoryBuildings) do
			if i ~= j then
				--MPW.Territory.AddTerritoryBuildingExcludes(MPW.Territory.TerritoryBuildings[i].Id, MPW.Territory.TerritoryBuildings[j].Id)
			end
		end
	end
end
--------------------------------------------------------------------------------
--[[
data = {
    Id = BuildingId,
    Excludes = {
        [Id1] = {X, Y, Dir},
        [Id2] = {X, Y, Dir},
        ...
    },
}
]]
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Util
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function IsInRange(_X1, _Y1, _X2, _Y2, _Range)
	return (_X1-_X2)^2 + (_Y1-_Y2)^2 <= _Range^2
end
--------------------------------------------------------------------------------
function GetCircleIntersections(_AX, _AY, _AR, _BX, _BY, _BR)
	local distAB = math.sqrt((_AX-_BX)^2 + (_AY-_BY)^2)

	if distAB == _AR + _BR then
		return (_AX+_BX)/2, (_AX+_BX)/2

	elseif distAB < _AR + _BR then
		local a, b, c = _BR, _AR, distAB
		local alpha = math.acos((a^2 - b^2 - c^2) / (-2 * b * c))
		local angleAB = math.atan2(_AX-_BX, _AY-_BY)

		local angle1 = angleAB + alpha
		local x1, y1 = _AR * math.cos(angle1) + _AX, _AR * math.sin(angle1) + _AY
		local angle2 = angleAB - alpha
		local x2, y2 = _AR * math.cos(angle2) + _AX, _AR * math.sin(angle2) + _AY

		return x1, y1, x2, y2
	end
end
--------------------------------------------------------------------------------
function GetCircleIntersectionAndDirection(_AX, _AY, _AR, _BX, _BY, _BR)
	local distAB = math.sqrt((_AX-_BX)^2 + (_AY-_BY)^2)
	
	if distAB < _AR + _BR then
		local a, b, c = _BR, _AR, distAB
		local alpha = math.acos((a^2 - b^2 - c^2) / (-2 * b * c))
		local angleAB = math.atan2(_AX-_BX, _AY-_BY)
		
		local angle = angleAB + alpha
		local x, y = _AR * math.cos(angle) + _AX, _AR * math.sin(angle) + _AY
        local dir = angleAB + math.rad(90)
		
        return x, y, dir
	end
end
--------------------------------------------------------------------------------
-- return pos = left, neg = right
function GetPositionsSideToLine(_X1, _Y1, _X2, _Y2, _Dir)
	return NormalizeAngle(math.atan2(_X2-_X1, _Y2-_Y1) - NormalizeAngle(_Dir), -math.pi)
end
--------------------------------------------------------------------------------
function NormalizeAngle(_Angle, _Offset)
	_Offset = _Offset or 0
	local pi2 = math.pi*2
	while _Angle >= pi2 + _Offset do
		_Angle = _Angle - pi2
	end
	while _Angle < _Offset do
		_Angle = _Angle - pi2
	end
	return _Angle
end
--------------------------------------------------------------------------------
function DebugGetNumberOfBorderStones()
	local n = 0
	for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Border)) do
		n = n + 1
	end
	return n
end
function DebugShowAllBorderStones()
	for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_Border)) do
		Logic.SetModelAndAnimSet(id, Models.XD_Border)
	end
end