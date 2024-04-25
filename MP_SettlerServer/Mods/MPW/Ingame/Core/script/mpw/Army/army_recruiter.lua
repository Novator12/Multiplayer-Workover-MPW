--MPW Army inspired by Ghoul

--includes all information about adding and removing leaders and cannons to offensive and defensive armies, which types of troops are getting recruited, ...

QueueCommandQueue = {}

---Checks if the current offensive|defensive army is at its maximum troop amount
---@param _army table - offensive|defensive army table
---@return true boolean - Returns if the number of the current troops is bigger or equal to the army strength
MPW.Army.IsArmyAtTroopLimit = function(_army,_playerId)

	local numtroops = table.getn(_army.offensiveArmies.IDs) + table.getn(_army.defensiveArmies.IDs)
	local maxstrength = _army.offensiveArmies.strength + _army.defensiveArmies.strength

	for id in CEntityIterator.Iterator( CEntityIterator.OfAnyTypeFilter( Entities.PB_Foundry1, Entities.PB_Foundry2 ), CEntityIterator.OfPlayerFilter(_playerId) ) do
		if Logic.GetCannonProgress( id ) ~= 100 then
			
			local _, smelter = Logic.GetAttachedWorkersToBuilding( id )
			if smelter ~= 0 then
				numtroops = numtroops + 1
			end
		end
	end
	return numtroops >= maxstrength
end

---Setup the AI Troop Generator for player x. Requests the trigger, which handles the generator conditions and actions and also the trigger for adding and removing a leader from an army
---@param _Name string - Name of the army based on the player id in MapEditor_SetupAI
---@param _playerId number - PlayerID of the army
SetupAITroopGenerator = function(_Name, _playerId)
	if type(_playerId) == "table" then --workaround for ubi campaign setup
		local tab = _playerId
		MapEditor_SetupAI(tab.player, tab.strength, tab.rodeLength, tab.strength, tab.position, tab.strength, tab.control.delay, true, tab.outerDefenseRange)
		if not MapEditor_Armies[tab.player].RangeJob then
			MapEditor_Armies[tab.player].RangeJob = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "AI_SP_RangeEnlarger", 1,nil,{_Name,tab.player})
		end
		return
	end
end

function AI_SP_RangeEnlarger(_Name,_playerId)
	if Counter.Tick2("MapEditor_Armies".._Name.._playerId,60*15) then
		MapEditor_Armies[_playerId]["offensiveArmies"].rodeLength = MapEditor_Armies[_playerId]["offensiveArmies"].rodeLength + 10000
		MapEditor_Armies[_playerId]["offensiveArmies"].baseDefenseRange = MapEditor_Armies[_playerId]["offensiveArmies"].baseDefenseRange + 10000
		MapEditor_Armies[_playerId]["defensiveArmies"].baseDefenseRange = MapEditor_Armies[_playerId]["defensiveArmies"].baseDefenseRange + 10000
		if MapEditor_Armies[_playerId]["defensiveArmies"].baseDefenseRange >= Logic.WorldGetSize() and MapEditor_Armies[_playerId]["offensiveArmies"].rodeLength >= Logic.WorldGetSize() then
			MapEditor_Armies[_playerId]["defensiveArmies"].baseDefenseRange = Logic.WorldGetSize()
			MapEditor_Armies[_playerId]["offensiveArmies"].baseDefenseRange = Logic.WorldGetSize()
			MapEditor_Armies[_playerId]["offensiveArmies"].rodeLength = Logic.WorldGetSize()
			return true
		end
	end
end

---Actions for the AI armies: Building priority, which troops getting trained (based on techLVL)
---@param _playerId number - PlayerID of the army
---@return false boolean 
MapEditor_Armies_RecruiterAction = function(_playerId)

	local _army = MapEditor_Armies[_playerId]
	-- Get entityType/Category
	local eTyp, id = MapEditor_Armies_EvaluateMilitaryBuildingsPriority(_playerId)
	eTyp = eTyp or _army.AllowedTypes[math.random(table.getn(_army.AllowedTypes))]
	if _army.techLVL == 3 then
		if eTyp == Entities.PV_Cannon1 then
			eTyp = Entities.PV_Cannon3
		elseif eTyp == Entities.PV_Cannon2 then
			eTyp = Entities.PV_Cannon4
		end
	end
	local armylimit = MPW.Army.IsArmyAtTroopLimit(_army,_playerId)
	if not armylimit then
		if MapEditor_Armies[_playerId].multiTraining and id then
			if IsCannonType(eTyp) then
				if Logic.GetEntityType(id) == Entities.PB_Foundry1 and (eTyp == Entities.PV_Cannon3 or eTyp == Entities.PV_Cannon4) then --safety if during the match the techlevel changes because of upgrading ai
					GUI.UpgradeSingleBuilding(id)
				else 
					(SendEvent or CSendEvent).BuyCannon(id, eTyp)
				end
			else
				Logic.BarracksBuyLeader(id, eTyp)
			end
		else
            local UpgradeCategoryCount = table.getn(_army.AllowedTypes)

            -- Get random category
            local UpgradeCategoryIndex = Logic.GetRandom(UpgradeCategoryCount)+1
            local militarybarracks = {}
            local militaryarcherys = {}
            for eId in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerId),CEntityIterator.OfAnyTypeFilter(Entities.PB_Barracks1,Entities.PB_Barracks2)) do
                table.insert(militarybarracks,eId)
            end
            for eId in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerId),CEntityIterator.OfAnyTypeFilter(Entities.PB_Archery1,Entities.PB_Archery2)) do
                table.insert(militaryarcherys,eId)
            end

            if not MPW.PU_Axe then
                AI.Army_BuyLeader(_playerId, _army.id, eTyp)
            elseif _army.AllowedTypes[UpgradeCategoryIndex] == UpgradeCategories.LeaderAxe and table.getn(militarybarracks) > 0  then
                Logic.BarracksBuyLeader(GetRandomTableElement(militarybarracks),UpgradeCategories.LeaderAxe)
            elseif _army.AllowedTypes[UpgradeCategoryIndex] == UpgradeCategories.LeaderCrossBow and table.getn(militaryarcherys) > 0 then
                Logic.BarracksBuyLeader(GetRandomTableElement(militaryarcherys),UpgradeCategories.LeaderCrossBow)
            else
                AI.Army_BuyLeader(_playerId, _army.id, eTyp)
            end
		end
	end
	return false
end

---Trigger which evaluates if an entity is connected to an army. If the leader|cannon is connected a trigger, which checks, if the leader|cannon is currently at training, is getting started.
---@param _playerId number - PlayerID of the army
MapEditor_Armies_GetLeader = function(_playerId)
	local entityID = Event.GetEntityID()
	local playerID = Logic.EntityGetPlayer(entityID)

	if playerID == _playerId and IsMilitaryLeader(entityID) and AI.Entity_GetConnectedArmy(entityID) == -1 then
		Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_TURN, "", "MapEditor_Armies_CheckLeaderAttachedToBarracks", 1, {}, {_playerId, entityID})
	end
end



---Trigger which checks if an leader|cannon is currently at training. After the training the leader|cannon gets connected to the offensive or defensive army of the player. A trigger starts, which is checking if the leader|cannon is dead, so he can get removed from the army.
---@param _playerId number - PlayerID of the army
---@param _id number - EntityID of leader|cannon
---@return true boolean
MapEditor_Armies_CheckLeaderAttachedToBarracks = function(_playerId, _id)
	if Logic.LeaderGetBarrack(_id) ~= 0 then
		local _type
		local tab = MapEditor_Armies[_playerId]
		if Logic.IsEntityInCategory(_id, EntityCategories.Cannon) == 1 then
			_type = "offensiveArmies"
		end
		if not _type then
			if table.getn(tab.defensiveArmies.IDs) < tab.defensiveArmies.strength then
				_type = "defensiveArmies"
			--elseif table.getn(tab.offensiveArmies.IDs) < tab.offensiveArmies.strength then
			else
				_type = "offensiveArmies"
			end
		end
		if not IsValueInTable(_id,MapEditor_Armies[_playerId][_type].IDs) then	
			table.insert(MapEditor_Armies[_playerId][_type].IDs, _id)
		end
		MapEditor_Armies[_playerId][_type][_id] = MapEditor_Armies[_playerId][_type][_id] or {}
		--Logic.LeaderChangeFormationType(_id, math.random(1, 7))
		if not MapEditor_Armies[_playerId][_type].TriggerID then
			MapEditor_Armies[_playerId][_type].TriggerID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, "", "AITroopGenerator_RemoveLeader", 1, {}, {_playerId, _type})
		end
	end
	return true
end


-- --Queue
---Trigger which checks on Entity_Destroyed, if the destroyed entity is part of an army. If the entity belongs to an army, it will get removed out of the army table.
---@param _playerId number - PlayerID of the army
---@param _type string - decides between offensive and defensive army
AITroopGenerator_RemoveLeader = function(_playerId, _type)
	local entityID = Event.GetEntityID()
	QueueCommandAdd(HelperQueue, {entityID,_playerId, _type})
end

function HelperQueue(arg)
	local entityID,_playerId,_type = unpack(arg)
	for leaderpos = table.getn(MapEditor_Armies[_playerId][_type].IDs),1,-1 do
		local leaderid = MapEditor_Armies[_playerId][_type].IDs[leaderpos]
		if entityID == leaderid or IsDead(leaderid) then
			removetablekeyvalue(MapEditor_Armies[_playerId][_type].IDs, leaderid)
			MapEditor_Armies[_playerId][_type][leaderid] = nil
		end
	end
end

---Reads the amount of military buildings and checks how many leaders of which category are part of the army. Based on this information the prioritylist will be filled with new entries. If multiTraining is activated in Mapeditor_SetupAI then multiple training types are getting returned.
---@param _playerId number - PlayerID of the army
---@return number _type - Returns entity type which will be recruited
---@return number _id - Returns id of the military building in which will be recruited
MapEditor_Armies_EvaluateMilitaryBuildingsPriority = function(_playerId)
	local _army = MapEditor_Armies[_playerId]
	local armylimit = MPW.Army.IsArmyAtTroopLimit(_army,_playerId)
	if armylimit then
		return 0,0
	end

	local num = {}
	num.Barracks, num.Archery, num.Stables, num.Foundry = AI.Village_GetNumberOfMilitaryBuildings(_playerId)
	if MapEditor_Armies[_playerId].prioritylist_lastUpdate == 0 or Logic.GetTime() > MapEditor_Armies[_playerId].prioritylist_lastUpdate + 30 then
		local armorclasspercT = GetPercentageOfLeadersPerArmorClass(AIEnemiesAC[_playerId])
		for AC = 1,7 do
			local bestdclass = MPW.Army.GetBestDamageClassByArmorClass(armorclasspercT[AC].id)
			local ucat = GetUpgradeCategoryInDamageClass(bestdclass)
			for militarybuilding,UCatTab in pairs(MPW.Army.CategoriesInMilitaryBuilding) do
				local tpos = table_findvalue(UCatTab, ucat)
				if tpos ~= 0 then
					if num[militarybuilding] > 0 then
						MapEditor_Armies[_playerId].prioritylist[AC] = {name = militarybuilding, typ = MPW.Army.CategoriesInMilitaryBuilding[militarybuilding][tpos]}
					end
				end
			end
		end
		MapEditor_Armies[_playerId].prioritylist_lastUpdate = Logic.GetTime()
	end
	if MapEditor_Armies[_playerId].multiTraining then
		if num.Foundry > 0 then
			for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerId), CEntityIterator.OfAnyTypeFilter(Entities.PB_Foundry2)) do
				if MilitaryBuildingIsTrainingSlotFree(id) then
					return Entities["PV_Cannon".. math.random(1, 4)], id
				end
			end
			for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerId), CEntityIterator.OfAnyTypeFilter(Entities.PB_Foundry1)) do
				if MilitaryBuildingIsTrainingSlotFree(id) then
					return Entities["PV_Cannon".. math.random(1, 2)], id
				end
			end
		end
		for k, v in pairs(MapEditor_Armies[_playerId].prioritylist) do
			for id in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerId), CEntityIterator.OfAnyTypeFilter(Entities["PB_"..v.name.."1"], Entities["PB_"..v.name.."2"])) do
				if MilitaryBuildingIsTrainingSlotFree(id) then
					return v.typ, id
				end
			end
		end
	else
		if num.Foundry > 0 and MilitaryBuildingIsTrainingSlotFree( MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(_playerId, Entities.PB_Foundry2, 1)})[2])) then
			return Entities["PV_Cannon".. math.random(1, 4)]
		end
		if num.Foundry > 0 and MilitaryBuildingIsTrainingSlotFree(({Logic.GetPlayerEntities(_playerId, Entities.PB_Foundry1, 1)})[2]) then
			return Entities["PV_Cannon".. math.random(1, 2)]
		end
		for k, v in pairs(MapEditor_Armies[_playerId].prioritylist) do
			local entity = ({Logic.GetPlayerEntities(_playerId, Entities["PB_"..v.name.."1"], 1)})[2] or ({Logic.GetPlayerEntities(_playerId, Entities["PB_"..v.name.."2"], 1)})[2]
			if entity then
				if MilitaryBuildingIsTrainingSlotFree(entity) then
					return v.typ
				end
			end
		end
	end
end


function QueueCommandAdd(_func, ...)
    if table.getn(QueueCommandQueue) == 0 then
        StartSimpleHiResJob("QueueCommandJob")
    end
    table.insert(QueueCommandQueue, {_func, arg})
end

function QueueCommandJob()
    if table.getn(QueueCommandQueue) == 0 then
        return true
    end
    local command = QueueCommandQueue[1]
    command[1](unpack(command[2]))
    table.remove(QueueCommandQueue, 1)
end
