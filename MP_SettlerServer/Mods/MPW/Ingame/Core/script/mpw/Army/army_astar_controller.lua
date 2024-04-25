--MPW Army

QueueArmyControllerQueue = {}

---Mapeditor Army Controller: 
---Iterates over all enemy players
---@param _playerId number - ID of ai-army
---@param _type table - Offensivearmy|defensivearmy from the ai 
MPW.Army.FillEnemyLeaderTable = function( _playerId , _type )
	MapEditor_Armies[_playerId][_type].eLeaders = {}
	--Iteration over all enemy leaders or buildings
	if _type == "defensiveArmies" then
		for playerPos = table.getn(MapEditor_Armies[_playerId].EnemyPlayers),1,-1 do
			QueueArmyControllerCommand(MPW.Army.IterateOverEnemies, {_playerId , _type , MapEditor_Armies[_playerId].EnemyPlayers[playerPos] , MapEditor_Armies[_playerId][_type].baseDefenseRange , MapEditor_Armies[_playerId][_type].Anchor.Homespot})
		end
	else
		for playerPos = table.getn(MapEditor_Armies[_playerId].EnemyPlayers),1,-1 do
			QueueArmyControllerCommand(MPW.Army.IterateOverEnemies, {_playerId , _type , MapEditor_Armies[_playerId].EnemyPlayers[playerPos] , MapEditor_Armies[_playerId][_type].rodeLength , MapEditor_Armies[_playerId][_type].Anchor.Homespot})
		end
	end
	if not MapEditor_Armies.Trigger[_type][_playerId].AnchorJobID  then
		MapEditor_Armies.Trigger[_type][_playerId].AnchorJobID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND,nil,ArmyControllerCommandDelay,1,nil,{_playerId, _type})
	end
end

function MPW.Army.IterateOverEnemies(arg)
	local _playerId,_type,enemyID,_range,pos = unpack(arg)
	for eID in CEntityIterator.Iterator(CEntityIterator.InCircleFilter(pos.X,pos.Y,_range), CEntityIterator.OfPlayerFilter(enemyID), CEntityIterator.OfCategoryFilter(EntityCategories.Leader)) do
		local pos2X,pos2Y = Logic.GetEntityPosition(eID)
		local int_pos2X = math.floor(pos2X)
		local int_pos2Y = math.floor(pos2Y)
		if Chunk.GetSectorPathDistance( pos.X, pos.Y, int_pos2X, int_pos2Y,_range) then
			local eLeaderInfo = {eID} --optional erweiterbar durch die Chunklength
			if Logic.IsHero(eID) and IsAlive(eID) then --Herosafety for dead heroes
				table.insert(MapEditor_Armies[_playerId][_type].eLeaders,eLeaderInfo)
			elseif not Logic.IsHero(eID) then
				table.insert(MapEditor_Armies[_playerId][_type].eLeaders,eLeaderInfo)
			end
		end
	end
end

function ArmyControllerCommandDelay(_playerId, _type)
	if Counter.Tick2("ArmyControllerCommandDelay_".._playerId.."_".._type,10) then
		QueueArmyControllerCommand(MPW.Army.ArmyController,{_playerId, _type})
	end
end


function MPW.Army.ArmyController(arg)
	local _playerId,_type = unpack(arg)
	local closestEnemySector, pathToClosestEnemySector = MPW.Army.GetClosestEnemySectorToAnchor(_playerId,_type)
	local IsAllowedToAttack = false
	if not closestEnemySector then
		MapEditor_Armies[_playerId][_type].Anchor.ClosestEnemySector = nil
        MPW.Army.MoveAnchorTowardsHome(_playerId,_type)
    else
		if MapEditor_Armies[_playerId].offensiveArmies.PTAttackAllowed == false then
			return
		end
		if MapEditor_Armies[_playerId][_type].Anchor.ClosestEnemySector ~= closestEnemySector then
			MapEditor_Armies[_playerId][_type].Anchor.ClosestEnemySector = closestEnemySector
			MapEditor_Armies[_playerId][_type].Anchor.PathToClosestEnemySector = pathToClosestEnemySector
		end
		if MPW.Army.AreEnoughLeadersInAnchorRange(_playerId, _type) then
			if table.getn(MapEditor_Armies[_playerId][_type].Anchor.PathToClosestEnemySector) < 3 then
				IsAllowedToAttack = true
			end
			MPW.Army.MoveAnchorTowardsEnemy(_playerId,_type) 
		end
	end

	if IsAllowedToAttack then
		for leaderIndex = table.getn(MapEditor_Armies[_playerId][_type].IDs),1,-1 do
			MPW.Army.AttackBestPossibleTarget(_playerId,_type,MapEditor_Armies[_playerId][_type].IDs[leaderIndex])
		end
	else
		local posX = MapEditor_Armies[_playerId][_type].Anchor.X
		local posY = MapEditor_Armies[_playerId][_type].Anchor.Y
		for leaderIndex = table.getn(MapEditor_Armies[_playerId][_type].IDs),1,-1 do
			local id = MapEditor_Armies[_playerId][_type].IDs[leaderIndex]
			if not IsEntityInRangeFast(id,posX,posY,3000) then
				local randomAnchorSpotX,randomAnchorSpotY =  MPW.Army.GetRandomPositionAtAnchor(MapEditor_Armies[_playerId][_type].Anchor.X, MapEditor_Armies[_playerId][_type].Anchor.Y)
				randomAnchorSpotX,randomAnchorSpotY = GetNearbyWalkablePosition(randomAnchorSpotX, randomAnchorSpotY)
				if Logic.GetCurrentTaskList(id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(id) == "TL_VEHICLE_IDLE" then
					Logic.GroupAttackMove(id,randomAnchorSpotX,randomAnchorSpotY)
				end
			end
		end
	end
end

---Checks for all leaders of the army if they are in range of the anchor spot and moves the anchor afterwards
---@param _playerId number - PlayerID of the army
---@param _type string - Armytype (Offensive or Defensive)
---@return true|false boolean - Returns if all leaders are in anchor
function MPW.Army.AreEnoughLeadersInAnchorRange(_playerId, _type)
	local leadersOutAnchor = 0
	local leaderAmount = table.getn(MapEditor_Armies[_playerId][_type].IDs)
	for leaderPos = table.getn(MapEditor_Armies[_playerId][_type].IDs),1,-1 do
		if not IsEntityInRangeFast(MapEditor_Armies[_playerId][_type].IDs[leaderPos],MapEditor_Armies[_playerId][_type].Anchor.X,MapEditor_Armies[_playerId][_type].Anchor.Y,3000) then
			leadersOutAnchor = leadersOutAnchor + 1
		end
		if leadersOutAnchor/leaderAmount > 0 then
			return false
		end
	end
	return leaderAmount > 0
end

function MPW.Army.MoveAnchorTowardsHome(_playerId,_type)
	MapEditor_Armies[_playerId][_type].Anchor.X = MapEditor_Armies[_playerId][_type].Anchor.Homespot.X
	MapEditor_Armies[_playerId][_type].Anchor.Y = MapEditor_Armies[_playerId][_type].Anchor.Homespot.Y
	local leaderTab = MapEditor_Armies[_playerId][_type].IDs
	for leaderPos = table.getn(leaderTab),1,-1 do
		if not IsEntityInRangeFast(leaderTab[leaderPos],MapEditor_Armies[_playerId][_type].Anchor.Homespot.X,MapEditor_Armies[_playerId][_type].Anchor.Homespot.Y,3000) then
			local randomAnchorHomespotX, randomAnchorHomespotY = MPW.Army.GetRandomPositionAtAnchor(MapEditor_Armies[_playerId][_type].Anchor.Homespot.X, MapEditor_Armies[_playerId][_type].Anchor.Homespot.Y)
			randomAnchorHomespotX, randomAnchorHomespotY = GetNearbyWalkablePosition(randomAnchorHomespotX, randomAnchorHomespotY)
			if Logic.LeaderGetBarrack(leaderTab[leaderPos]) == 0 and (Logic.GetCurrentTaskList(leaderTab[leaderPos]) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(leaderTab[leaderPos]) == "TL_VEHICLE_IDLE") then
				Logic.GroupAttackMove(leaderTab[leaderPos],randomAnchorHomespotX,randomAnchorHomespotY)
			end
		end
	end
end

function MPW.Army.GetClosestEnemySectorToAnchor(_playerId,_type)
	local eleaders = MapEditor_Armies[_playerId][_type].eLeaders
    local sectors = {}
    -- key war die LeaderId, oder?
    for _,eleadertab in pairs(eleaders) do
		local sector = Chunk.GetSectorByEntity(eleadertab[1])
		if sector then
			table.addunique(sectors, sector)
		end
    end

    local shortestpath, shortestpathlength, closestsector
	MapEditor_Armies[_playerId][_type].Anchor.X, MapEditor_Armies[_playerId][_type].Anchor.Y = GetNearbyWalkablePosition(MapEditor_Armies[_playerId][_type].Anchor.X, MapEditor_Armies[_playerId][_type].Anchor.Y)
    local anchorsector = Chunk.GetSectorByLocation(MapEditor_Armies[_playerId][_type].Anchor.X, MapEditor_Armies[_playerId][_type].Anchor.Y)

    for i = 1,table.getn(sectors) do
        -- only search for paths shorter or equal to shortestpathlenght
        local path = Chunk.FindSectorPathBySectors(anchorsector, sectors[i], shortestpathlength)
        if path then
            -- additional checks are redundant, since the found path cant be longer than the current shortest path
            -- because we allready limited the path length by passing shortestpathlength to the pathfinder
            shortestpath = path
            shortestpathlength = table.getn(path)
			closestsector = sectors[i]
        end
    end

    return closestsector, shortestpath
end

---Moves the army anchor in the direction of the nearest enemy
---@param _playerId number - PlayerID of the army
---@param _type string - Type of the army (Defensive or Offensive)
function MPW.Army.MoveAnchorTowardsEnemy(_playerId,_type) 
	
	local armyAnchor = MapEditor_Armies[_playerId][_type].Anchor
	if table.getn(armyAnchor.PathToClosestEnemySector) <= 1 then
		return
	end
	table.remove(armyAnchor.PathToClosestEnemySector, 1)

	if _playerId == 3 then
		GUI.DestroyMinimapPulse(armyAnchor.X,armyAnchor.Y)
	end

    armyAnchor.X = armyAnchor.PathToClosestEnemySector[1].X*Chunk.Size*100
	armyAnchor.Y = armyAnchor.PathToClosestEnemySector[1].Y*Chunk.Size*100
	armyAnchor.X, armyAnchor.Y = GetNearbyWalkablePosition(armyAnchor.X, armyAnchor.Y,nil,Logic.GetSector(MapEditor_Armies[_playerId][_type].IDs[1]))
	

	if _playerId == 3 then
		GUI.CreateMinimapMarker(armyAnchor.X,armyAnchor.Y,1)
	end

end


function MPW.Army.AttackBestPossibleTarget(_playerId,_type,_id)
	local randomenemyleader = MapEditor_Armies[_playerId][_type].eLeaders[math.random(1,table.getn(MapEditor_Armies[_playerId][_type].eLeaders))][1]
	Logic.GroupAttack(_id,randomenemyleader)

	-- local newtarget
	-- local range = 5000
	-- if _type == "offensiveArmies" then
	-- 	range = MapEditor_Armies[_playerId][_type].rodeLength
	-- else
	-- 	range = MapEditor_Armies[_playerId][_type].baseDefenseRange
	-- end
	-- local currentTarget = MapEditor_Armies[_playerId][_type][_id].currentTarget

	-- if currentTarget then
	-- 	newtarget = CheckForBetterTarget(_id, currentTarget, range, _playerId, _type)
	-- 	if newtarget then
	-- 		MapEditor_Armies[_playerId][_type][_id].currentTarget = newtarget
	-- 	end
	-- else
	-- 	newtarget = GetNearestTarget(_playerId, _id,_type)
	-- 	if newtarget then
	-- 		MapEditor_Armies[_playerId][_type][_id].currentTarget = newtarget
	-- 	end
	-- end

	-- if Logic.GetCurrentTaskList(_id) == "TL_MILITARY_IDLE" or Logic.GetCurrentTaskList(_id) == "TL_VEHICLE_IDLE" then
	-- 	Logic.GroupAttack(_id,MapEditor_Armies[_playerId][_type][_id].currentTarget)
	-- end

end


---Checks if there is any better target for the entity based on range,dmgclass,dmgrange,attacktype
---@param _eID number - EntityId from leader for who the check will be started
---@param _target number - ID of current target of the leader
---@param _range number - BaseDefenseRange of the army
---@return number -Returns the new target
function CheckForBetterTarget(_eID, _target, _range,_playerId,_type)

	if not Logic.IsEntityAlive(_eID) then
		return
	end

	local sector = Logic.GetSector(_eID)
	local player = Logic.EntityGetPlayer(_eID)
	local etype = Logic.GetEntityType(_eID)
	local IsTower = (Logic.IsEntityInCategory(_eID, EntityCategories.MilitaryBuilding) == 1 and Logic.GetFoundationTop(_eID) ~= 0)
	local IsMelee = (Logic.IsEntityInCategory(_eID, EntityCategories.Melee) == 1)
	local posX, posY = Logic.GetEntityPosition(_eID)
	local maxrange = GetEntityTypeMaxAttackRange(_eID, player)
	local bonusRange = 500
	local damageclass = CInterface.Logic.GetEntityTypeDamageClass(etype)
	local damagerange = GetEntityTypeDamageRange(etype)
	local calcT = {}
	if IsMelee then
		bonusRange = 800
	end
	if MPW.Army.gvAntiBuildingCannonsRange[etype] then
		local target = MPW.Army.CheckForNearestHostileBuildingInAttackRange(_eID, (_range or maxrange) + MPW.Army.gvAntiBuildingCannonsRange[etype])
		if _target and Logic.IsBuilding(_target) == 0 and target then
			return target
		elseif not _target and target then
			return target
		end
	end
	if _target and Logic.IsEntityAlive(_target) and sector == Logic.GetSector(_target) then
		calcT[1] = {id = _target, factor = MPW.Army.DamageFactorToArmorClass[damageclass][CInterface.Logic.GetEntityTypeArmorClass(Logic.GetEntityType(_target))], dist = GetDistance(_eID, _target)}
	end

	local postable = {}
	local clumpscore
	local attach
	local entities = {}
	for _,eleadertab in pairs(MapEditor_Armies[_playerId][_type].eLeaders) do
		table.insert(entities,eleadertab[1])
	end
	

	if not next(entities) then
		return
	end
	for i = 1, table.getn(entities) do
		if Logic.IsEntityAlive(entities[i]) then
			local ety = Logic.GetEntityType(entities[i])
			local threatbonus
			if Logic.GetFoundationTop(entities[i]) ~= 0 or (Logic.IsBuilding(entities[i]) == 0 and GetEntityTypeDamageRange(ety) > 0)
			or (Logic.IsHero(entities[i]) == 1 and not IsMelee)
			or Logic.IsEntityInCategory(entities[i], EntityCategories.Cannon) == 1 then
				threatbonus = 1
			end
			attach = CEntity.GetAttachedEntities(entities[i])[37]
			local damagefactor = MPW.Army.DamageFactorToArmorClass[damageclass][CInterface.Logic.GetEntityTypeArmorClass(ety)]
			if damagerange > 0 and not MPW.Army.gvAntiBuildingCannonsRange[etype] then
				local mul = 1
				if Logic.IsLeader(entities[i]) == 1 then
					mul = 1 + Logic.LeaderGetNumberOfSoldiers(entities[i])
				end
				table.insert(postable, {pos = GetPosition(entities[i]), factor = damagefactor * mul + (threatbonus or 0)})
			end
			table.insert(calcT, {id = entities[i], factor = damagefactor + (threatbonus or 0), dist = GetDistance(_eID, entities[i])})
		end
	end
	local attachN = attach and table.getn(attach) or 0
	if damagerange > 0 and not MPW.Army.gvAntiBuildingCannonsRange[etype] then
		if next(postable) then
			clumppos, score = GetPositionClump(postable, damagerange, 100)
			for i = 1, table.getn(calcT) do
				if IsTower then
					calcT[i].clumpscore = score
				else
					calcT[i].clumpscore = score / GetDistance(clumppos, GetPosition(calcT[i].id))
				end
			end
		end
	end
	local distval = function(_dist, _range)
		if _dist > _range then
			if IsMelee then
				return (_dist - _range) / _range
			else
				return math.sqrt((_dist - _range) / _range)
			end
		else
			return 0
		end
	end
	table.sort(calcT, function(p1, p2)
		if p1.clumpscore then
			if IsTower then
				return p1.clumpscore > p2.clumpscore
			else
				return p1.clumpscore + p1.factor - distval(p1.dist, maxrange) > p2.clumpscore + p2.factor - distval(p2.dist, maxrange)
			end
		else
			return (p1.factor * 10 - distval(p1.dist, maxrange) - attachN) > (p2.factor * 10 - distval(p2.dist, maxrange) - attachN)
		end
	end)
	if next(calcT) then
		for i = 1, table.getn(calcT) do
			if sector == Logic.GetSector(calcT[i].id) then
				return calcT[i].id
			end
		end
	end
end

---Checks for the nearest enemy target from the chunck where the entity stands and enlarges the area check everytime over 5000 to find the next enemy
---@param _playerId number - PlayerID of the ai army
---@param _id number - EntityID of the leader from where the scan starts
---@return number|boolean - [ID] Returns entity id of possible enemies or returns false, when none is found
function GetNearestTarget(_playerId, _id,_type)
	if not Logic.IsEntityAlive(_id) then
		return
	end
	local posX, posY = Logic.GetEntityPosition(_id)
	local range = 5000
	local maxrange = Logic.WorldGetSize()
	local sector = Logic.GetSector(_id)
	repeat
		local entities = {}
		for _,eleadertab in pairs(MapEditor_Armies[_playerId][_type].eLeaders) do
			table.insert(entities,eleadertab[1])
		end
		for i = 1, table.getn(entities) do
			if entities[i] and Logic.IsEntityAlive(entities[i]) and Logic.GetSector(entities[i]) == sector then
				return entities[i]
			end
		end
		range = range + 5000
	until range >= maxrange
	do
		local enemies = MPW.Army.GetAllEnemyPlayerIDs(_playerId)
		local IDs
		for i = 1, table.getn(enemies) do
			IDs = {Logic.GetPlayerEntities(enemies[i], 0, 16)}
			for k = 1, IDs[1] do
				if Logic.IsBuilding(IDs[k]) == 1 and Logic.GetSector(IDs[k]) == sector and Logic.IsEntityInCategory(IDs[k], EntityCategories.Wall) == 0 and not IsInappropiateBuilding(IDs[k]) then
					return IDs[k]
				end
			end
		end
	end
	return false
end

---Evaluates a random position in the anchor spot
---@param _posX number - x-position which will be referred to
---@param _posY number - y-position which will be referred to
---@return number x  - Return the x coordinate of the random spot
---@return number y - Return the y coordinate of the random spot
function MPW.Army.GetRandomPositionAtAnchor(_posX, _posY)
	for i=1,500 do
		local randomAnchorSpotX = _posX+math.random(-1000,1000)
		local randomAnchorSpotY = _posY+math.random(-1000,1000)
		if Chunk.GetSectorPathLength(_posX, _posY,randomAnchorSpotX, randomAnchorSpotY, 2) then
			return randomAnchorSpotX,randomAnchorSpotY
		end
	end
	return _posX+math.random(-1000,1000), _posY+math.random(-1000,1000)
end

function QueueArmyControllerCommand(_func, ...)
    if table.getn(QueueArmyControllerQueue) == 0 then
        StartSimpleHiResJob("QueueArmyControllerCommandJob")
    end
    table.insert(QueueArmyControllerQueue, {_func, arg})
end

function QueueArmyControllerCommandJob()
    if table.getn(QueueArmyControllerQueue) == 0 then
        return true
    end
    local command = QueueArmyControllerQueue[1]
    command[1](unpack(command[2]))
    table.remove(QueueArmyControllerQueue, 1)
end