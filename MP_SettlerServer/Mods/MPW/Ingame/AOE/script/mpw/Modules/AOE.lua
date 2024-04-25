--------------------------------------------------------------------------------
-- replace "AOE" in this file with any unique name
-- Module Version v1.2
--------------------------------------------------------------------------------
MPW.AOE = {}
table.insert(MPW.Modules, "AOE")
--------------------------------------------------------------------------------
function MPW.AOE.Init()
	LuaDebugger.Log( "AOE.Init()" )

	WidgetHelper.AddPreCommitCallback(
		function()
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\AOE_GUI.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\MultiSelectionSource_Founder_Cart.xml")
		end
	)
	Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\comfort\\other\\NextTick.lua")

	MPW.GUIUpdate_MultiSelectionButton = GUIUpdate_MultiSelectionButton
	function GUIUpdate_MultiSelectionButton()
		local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
		local MotherContainer= XGUIEng.GetWidgetsMotherID(CurrentWidgetID)
		
		local SourceButton

		if Logic.GetEntityType(XGUIEng.GetBaseWidgetUserVariable(MotherContainer, 0)) == Entities.PU_Founder_Cart then
			SourceButton = "MultiSelectionSource_Founder_Cart"
		end

		if SourceButton then
			XGUIEng.TransferMaterials(SourceButton, CurrentWidgetID)
			for i = 0, 4 do
				XGUIEng.SetMaterialColor(SourceButton, i, 255, 255, 255, 255)
			end	
			return
		end

		MPW.GUIUpdate_MultiSelectionButton()
	end

	MPW.AOE.ReplacePlayerBuildingsWithTravelingSalesmen()
	MPW.AOE.MaxAdditionalSerfs = MPW.AttractionLimit.MaxAdditionalSerfs
	MPW.AttractionLimit.MaxAdditionalSerfs = 0
end
--------------------------------------------------------------------------------
function MPW.AOE.Load()
	--LuaDebugger.Log( "AOE.Load()" )
end
--------------------------------------------------------------------------------
function MPW.AOE.PostInit()
	LuaDebugger.Log( "AOE.PostInit()" )

	--Nötig damit auf 0 gesetzt werden kann
	Score.Player[0] = { buildings = 0, all = 0 }

	-- show salesmen build menu
	MPW.AOE.GameCallback_GUI_SelectionChanged = GameCallback_GUI_SelectionChanged
    function GameCallback_GUI_SelectionChanged()
		-- deselect newly selected salesmen with build target
        local selectedentities = {GUI.GetSelectedEntities()}
		for i = 1, table.getn(selectedentities) do
			local selectedentity = selectedentities[i]
			local tasklist = Logic.GetCurrentTaskList(selectedentity)
			if tasklist == "TL_SALESMAN_GO_TO_CONSTRUCTION_SITE" or tasklist == "TL_SALESMAN_BUILD" or (tasklist == "TL_WORKER_LEAVE" and Logic.GetEntityType(selectedentity) == Entities.PU_Founder_Cart) then
				GUI.DeselectEntity(selectedentity)
				return
			end
		end
		-- call orig
        MPW.AOE.GameCallback_GUI_SelectionChanged()
		-- show salesmen selection if only salesmen selected
		local showserftradermenu = 0
		for i = 1, table.getn(selectedentities) do
			local entitytype = Logic.GetEntityType(selectedentities[i])
			if entitytype == Entities.PU_Founder_Cart then
				showserftradermenu = 1
			else
				showserftradermenu = 0
				break
			end
		end
		XGUIEng.ShowWidget("Selection_SerfTrader", showserftradermenu)
	end

	-- delete salesmen on construction complete
	MPW.AOE.GameCallback_OnBuildingConstructionComplete = GameCallback_OnBuildingConstructionComplete
    function GameCallback_OnBuildingConstructionComplete(_buildingId,_playerId)
        MPW.AOE.GameCallback_OnBuildingConstructionComplete(_buildingId,_playerId)
        local EntityType = Logic.GetEntityType(_buildingId)
		if EntityType == Entities.XD_VillageCenter or EntityType == Entities.PB_Headquarters1 then
			local x,y = Logic.EntityGetPos(_buildingId)
			local csite
			local csitetype
			if EntityType == Entities.XD_VillageCenter then
				csitetype = Entities.ZB_ConstructionSiteVillageCenter1
			else
				csitetype = Entities.ZB_ConstructionSite4
				MPW.AttractionLimit.MaxAdditionalSerfs = MPW.AOE.MaxAdditionalSerfs or MPW.AttractionLimit.MaxAdditionalSerfs
				MPW.AOE.MaxAdditionalSerfs = nil
			end
			for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(csitetype), CEntityIterator.InRangeFilter(x, y, 0)) do
				csite = id
				break
			end
			if csite then
				--local id = ReplaceEntity(CUtil.GetAttachedSerfs(csite), Entities.PU_Trader)
				--Logic.SetTaskList(id, TaskLists.TL_WORKER_LEAVE)
				DestroyEntity(CUtil.GetAttachedSerfs(csite))
			end
		end
    end

	-- prevent village centers from placement on unfinished settlement sites
	MPW.AOE.GameCallback_PlaceBuildingAdditionalCheck = GameCallback_PlaceBuildingAdditionalCheck
	function GameCallback_PlaceBuildingAdditionalCheck(_EntityType, _X, _Y, _Rotation, _IsBuildOn)

		local result = (MPW.AOE.GameCallback_PlaceBuildingAdditionalCheck or function() end)(_EntityType, _X, _Y, _Rotation, _IsBuildOn)

		if _EntityType == Entities.PB_VillageCenter1 then
			local _,neutralVC = Logic.GetEntitiesInArea(Entities.XD_VillageCenter, _X, _Y, 10, 1)
			if neutralVC ~= 0 and Logic.IsConstructionComplete(neutralVC) == 1 then
				for id in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(Entities.PB_VillageCenter1,Entities.PB_VillageCenter2,Entities.PB_VillageCenter3),CEntityIterator.InRangeFilter(_X, _Y, 0)) do
					return false
				end
			else
				return false
			end
		end

		return result
	end

	-- prevent salesmen from chopping trees
	MPW.AOE.GameCallback_TastListChanged = GameCallback_TastListChanged
	function GameCallback_TastListChanged(_Id, _OldTaskList, _NewTaskList)

		(MPW.AOE.GameCallback_TastListChanged or function() end)(_Id, _OldTaskList, _NewTaskList)

		if Logic.GetEntityType(_Id) == Entities.PU_Founder_Cart and Logic.EntityGetPlayer(_Id) == GUI.GetPlayerID() then
			if _NewTaskList == TaskLists.TL_SERF_GO_TO_TREE or _NewTaskList == TaskLists.TL_SERF_GO_TO_RESOURCE then
				local x, y = GUI.Debug_GetMapPositionUnderMouse()
				NextTick(SendEvent.Move, _Id, x, y)
			end
		end
	end

	-- prevent game from losig if player has founder carts left
	MPW.AOE.AdditionalCheck = MPW.Defeat.AdditionalCheck
	function MPW.Defeat.AdditionalCheck(_PlayerId)
		local result = MPW.AOE.AdditionalCheck(_PlayerId)
		for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.PU_Founder_Cart), CEntityIterator.OfPlayerFilter(_PlayerId)) do
			return false
		end
		return result
	end

	-- deselect salesmen on construction site placement
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, nil, MPW.AOE.CreatedTrigger, 1)

	-- add the costs of one vc to human players resources
	local costtable = {}
	Logic.FillBuildingCostsTable(Entities.PB_VillageCenter1, costtable)
	if CNetwork then
		for p = 1, 16 do
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(p) == 1 then
				for resourcetype, amount in pairs(costtable) do
					Logic.AddToPlayersGlobalResource(p, resourcetype, amount)
				end
			end
		end
	else
		for resourcetype, amount in pairs(costtable) do
			Logic.AddToPlayersGlobalResource(GUI.GetPlayerID(), resourcetype, amount)
		end
	end
end
--------------------------------------------------------------------------------
function MPW.AOE.PostLoad()
	--LuaDebugger.Log( "AOE.PostLoad()" )
end
--------------------------------------------------------------------------------
function MPW.AOE.Unload()
	--LuaDebugger.Log( "AOE.Unload()" )
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function MPW.AOE.CreatedTrigger()
	local buildingId = Event.GetEntityID()
	local type = Logic.GetEntityType(buildingId)
	if type == Entities.XD_VillageCenter or type == Entities.PB_Headquarters1 then
		local x,y = Logic.EntityGetPos(buildingId)
		local csite
		local csitetype = (type == Entities.XD_VillageCenter and Entities.ZB_ConstructionSiteVillageCenter1) or Entities.ZB_ConstructionSite4
		for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(csitetype), CEntityIterator.InRangeFilter(x, y, 0)) do
			csite = id
			break
		end
		NextTick(MPW.AOE.DeselectSalesman, csite)
	end
end
--------------------------------------------------------------------------------
function MPW.AOE.DeselectSalesman(csite)
	local serf = CUtil.GetAttachedSerfs(csite)
	local pId = Logic.EntityGetPlayer(serf)
	if Logic.GetEntityType(csite) == Entities.ZB_ConstructionSiteVillageCenter1 then
		MPW.AOE.VC[pId].Amount = MPW.AOE.VC[pId].Amount + 1
	else
		MPW.AOE.HQ[pId].Amount = MPW.AOE.HQ[pId].Amount + 1
	end
	GUI.DeselectEntity(serf)
end
--------------------------------------------------------------------------------
function MPW.AOE.ReplacePlayerBuildingsWithTravelingSalesmen()

	MPW.AOE.VC = {}
	MPW.AOE.HQ = {}
	local humanplayers = {}
	if CNetwork then
		for p = 1,16 do
			if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(p) == 1 then
				MPW.AOE.VC[p] = {Amount = 0, Limit = 0}
				MPW.AOE.HQ[p] = {Amount = 0, Limit = 0}
				table.insert(humanplayers, p)
			end
		end
	else
		MPW.AOE.VC[GUI.GetPlayerID()] = {Amount = 0, Limit = 0}
		MPW.AOE.HQ[GUI.GetPlayerID()] = {Amount = 0, Limit = 0}
		table.insert(humanplayers, GUI.GetPlayerID())
	end

	local headquarters = {}
	for headquarter in CEntityIterator.Iterator(CEntityIterator.OfAnyTypeFilter(Entities.PB_Headquarters1, Entities.PB_Headquarters2, Entities.PB_Headquarters3)) do
		local player = Logic.EntityGetPlayer(headquarter)
		headquarters[player] = headquarters[player] or {}
		table.insert(headquarters[player], headquarter)
		-- dont delete them yet, we still need them later

		if MPW.AOE.HQ[player] then
			MPW.AOE.HQ[player].Limit = MPW.AOE.HQ[player].Limit + 1
		end
	end

	local neutralvillagecenters = {}
	for neutralvillagecenter in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.XD_VillageCenter)) do
		if not CEntity.GetAttachedEntities(neutralvillagecenter)[36] then
			table.insert(neutralvillagecenters, neutralvillagecenter)
			-- dont delete them yet, we still need them later
			-- some may even stay
		else
			local playervillagecenter = CEntity.GetAttachedEntities(neutralvillagecenter)[36][1]
			local player = Logic.EntityGetPlayer(playervillagecenter)
			
			if MPW.AOE.VC[player] then
				MPW.AOE.VC[player].Limit = MPW.AOE.VC[player].Limit + 1
				Logic.DestroyEntity(playervillagecenter)
				Logic.DestroyEntity(neutralvillagecenter)
			end
		end
	end

	local playerspersectors = {} -- k = sector, v = player
	for player, playerheadquarters in pairs(headquarters) do
		for i = 1, table.getn(playerheadquarters) do
			local headquarter = playerheadquarters[i]
			local sector = Logic.GetSector(headquarter)
			playerspersectors[sector] = playerspersectors[sector] or {}
			table.insert(playerspersectors[sector], player)
		end
	end

	local villagecenterspersector = {}
	for i = 1, table.getn(neutralvillagecenters) do
		local villagecenter = neutralvillagecenters[i]
		local sector = Logic.GetSector(villagecenter)
		villagecenterspersector[sector] = villagecenterspersector[sector] or {}
		table.insert(villagecenterspersector[sector], villagecenter)
	end

	for sector, players in pairs(playerspersectors) do
		local numberofplayers = table.getn(players)
		local numberofvillagecenters = table.getn(villagecenterspersector[sector] or {})

		local villagecentersperplayer = math.floor(numberofvillagecenters / numberofplayers)
		for _ = 1, villagecentersperplayer do
			for i = 1, table.getn(players) do
				local player = players[i]
				
				if MPW.AOE.VC[player] then
					local x, y = Logic.GetEntityPosition(headquarters[player])
					-- Logic.GetEntitiesInArea doesnt work this early
					local _,villagecenter = MPW.AOE.GetEntitiesInArea(Entities.XD_VillageCenter, x, y, 0, 1)

					MPW.AOE.VC[player].Limit = MPW.AOE.VC[player].Limit + 1
					Logic.DestroyEntity(villagecenter)
				end
			end
		end
	end

	for i = 1, table.getn(humanplayers) do
		local player = humanplayers[i]
		local x, y = Logic.GetEntityPosition(headquarters[player][1])
		for j = 1, MPW.AOE.HQ[player].Limit + MPW.AOE.VC[player].Limit do
			Logic.CreateEntity(Entities.PU_Founder_Cart, x + math.random(-500,500), y + math.random(-500,500), math.random(360), player)
		end
		for j = 1, table.getn(headquarters[player]) do
			Logic.DestroyEntity(headquarters[player][j])
		end
	end
end
--------------------------------------------------------------------------------
function MPW.AOE.GetEntitiesInArea(_EntityType, _X, _Y, _Range, _Amount)
	if _Range == 0 then
		_Range = Logic.WorldGetSize() * 2
	end
	local entities = {}
	for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(_EntityType), CEntityIterator.InRangeFilter(_X, _Y, _Range)) do
		table.insert(entities, id)
	end
	table.sort(entities,
		function(a, b)
			local ax, ay = Logic.GetEntityPosition(a)
			local bx, by = Logic.GetEntityPosition(b)
			return (_X-ax)^2+(_Y-ay)^2 < (_X-bx)^2+(_Y-by)^2
		end
	)
	if _Amount then
		for i = table.getn(entities), _Amount + 1, -1 do
			table.remove(entities, i)
		end
	end
	return unpack(entities)
end