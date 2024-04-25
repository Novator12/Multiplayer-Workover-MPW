--MPW Army inspired by Ghoul

--includes all comfort funcs for MPW army
function MPW.Army.InitComforts()
	---Returns a random element of a table
	---@param _table table - The input table object from which the random element is selected.
	---@return any - The randomly selected table element.
	function GetRandomTableElement(_table)
		if table.getn(_table) > 0 then
			return _table[math.random(table.getn(_table))]
		end
	end


	---Returns first free army slot from an ai-army
	---@param _player number - PlayerId from army
	---@return integer - Free army spot 
	GetFirstFreeArmySlot = function(_player)
		if not (ArmyTable and ArmyTable[_player]) then
			return 0
		end
		local count
		for k, v in pairs(ArmyTable[_player]) do
			if not v or IsDead(v) then
				ArmyTable[_player][k] = nil
				ArmyHomespots[_player][k] = nil
				return k - 1
			end
			count = k - 1
		end
		return count + 1
	end

	---Returns one of the ucats, which is used by x troops
	---@param _dclass table - DamageClass
	---@return table|integer -Returns ucat
	GetUpgradeCategoryInDamageClass = function(_dclass)
		if type(MPW.Army.GetUpgradeCategoryByDamageClass[_dclass]) == "table" then
			return MPW.Army.GetUpgradeCategoryByDamageClass[_dclass][math.random(table.getn(MPW.Army.GetUpgradeCategoryByDamageClass[_dclass]))]
		else
			return MPW.Army.GetUpgradeCategoryByDamageClass[_dclass]
		end
	end

	---Returns if entities of a diplomacy state in an area
	---@param _player number - PlayerId from army
	---@param _position table - Table with X and Y coordinate of the area
	---@param _range number - Range for the area check
	---@param _state number -DiplomacyState: 1 -> Friendly, 2 -> Neutral, 3 -> Hostile
	---@return true|false boolean - Returns true, when there are entities, false when not
	function AreEntitiesOfDiplomacyStateInArea(_player, _position, _range, _state)
		local maxplayers = 8
		if CNetwork then
			maxplayers = 16
		end
		local flag = false
		for i = 1, maxplayers do
			if Logic.GetDiplomacyState(_player, i) == _state then
				flag = AreEntitiesInArea(i, 0, _position, _range, 1)
				if flag then
					return true
				end
			end
		end
		return false
	end

	---Checks if entity is a military leader
	---@param _entityID number - Entity ID
	---@return true|false boolean - Returns true or false
	function IsMilitaryLeader(_entityID)
		return Logic.IsHero(_entityID) == 0 and Logic.IsSerf(_entityID) == 0 and Logic.IsEntityInCategory(_entityID, EntityCategories.Soldier) == 0 and Logic.IsBuilding(_entityID) == 0 and Logic.IsWorker(_entityID) == 0 and string.find(string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(_entityID))), "soldier") == nil and Logic.IsLeader(_entityID) == 1 and Logic.IsEntityInCategory(_entityID, EntityCategories.MilitaryBuilding) == 0
	end

	---Used to find a defined value in a table
	---@param _tid table - Table which will be scanned
	---@param _value any - value which will be searched
	---@return integer - Returns tableposition or 0
	function table_findvalue(_tid, _value)
		local tpos
		if type(_value) == "number" then
			for i,val in pairs(_tid) do
				if val == _value then
					tpos = i
					break
				end
			end
		elseif type(_value) == "table" then
			if type(_tid[1]) == "table" then
				if _tid[1].X and _tid[1].Y then
					for i,_ in pairs(_tid) do
						if _tid[i].X == _value.X and _tid[i].Y == _value.Y then
							tpos = i
							break
						end
					end
				else
					for i,_ in pairs(_tid) do
						for k,_ in pairs(_tid[i]) do
							if _tid[i][k] == _value then
								tpos = i
								break
							end
						end
					end
				end
			else
				for i,_ in pairs(_tid) do
					if _tid[i] == _value then
						tpos = i
						break
					end
				end
			end
		end
		return tpos or 0
	end

	---Used to remove a tablekeyvalue out of a table
	---@param _tid table - Table which will be scanned
	---@param _key any - Key which will be deleted
	---@return integer - Returns the key which was deleted
	function removetablekeyvalue(_tid, _key)
		local tpos
		if type(_key) == "string" then
			for i,_ in pairs(_tid) do
				if string.find(_tid[i],_key) ~= nil then
					tpos = i
					break
				end
			end
		elseif type(_key) == "number" then
			for i,_ in pairs(_tid) do
				if _tid[i] == _key then
					tpos = i
					break
				end
			end
		elseif type(_key) == "table" then
			if type(_tid[1]) == "table" then
				if _tid[1].X and _tid[1].Y then
					for i,_ in pairs(_tid) do
						if _tid[i].X == _key.X and _tid[i].Y == _key.Y then
							tpos = i
							break
						end
					end
				else
					for i,_ in pairs(_tid) do
						for k,_ in pairs(_tid[i]) do
							if _tid[i][k] == _key then
								tpos = i
								break
							end
						end
					end
				end
			else
				for i,_ in pairs(_tid) do
					if _tid[i] == _key then
						tpos = i
						break
					end
				end

			end
		else
			return
		end
		table.remove(_tid,tpos)
		return _key
	end

	---Returns the percentage of leaders per different armor classes from a table
	---@param _table table -Table which getting scanned
	---@return table - Table with the percentage of the different leaders per armor class
	function GetPercentageOfLeadersPerArmorClass(_table)
		assert(type(_table) == "table", "input type must be a table")
		assert(_table.total ~= nil, "invalid input")
		local perctable = {}
		for i = 1,7 do
			perctable[i] = {id = i, count = table.getn(_table[i]) * 100 / _table.total}
		end
		table.sort(perctable, function(p1, p2)
			return p1.count > p2.count
		end)
		return perctable
	end

	---Checks if there is a free training slot in a military building
	---@param _id number - Entity ID of the military building
	---@return true|false boolean - Returns true when the number of trained leaders is less then 3, else return false. Also checks cannon production.
	MilitaryBuildingIsTrainingSlotFree = function(_id)
		if not _id or not Logic.IsEntityAlive(_id) then
			return
		end
		local IsFoundry = (Logic.GetEntityType(_id) == Entities.PB_Foundry1 or Logic.GetEntityType(_id) == Entities.PB_Foundry2)
		if IsFoundry then
			return Logic.GetCannonProgress(_id) == 100
		else
			local count = 0
			local attach = CEntity.GetAttachedEntities(_id)[42]
			if attach and attach[1] then
				for i = 1, table.getn(attach) do
					if Logic.IsEntityInCategory(attach[i], EntityCategories.Soldier) == 0 then
						count = count + 1
					end
				end
			end
			return count < 3
		end
	end

	---Checks if entity type is cannon
	---@param _type number - Entity type
	---@return true|false boolean - Returns true when entity type is a cannon, else false
	function IsCannonType(_type)
		assert(type(_type) == "number" and _type > 0, "invalid entity type")
		if _type == Entities.PV_Cannon1 or _type == Entities.PV_Cannon2 or _type == Entities.PV_Cannon3
		or _type == Entities.PV_Cannon4 or _type == Entities.PV_Cannon5 or _type == Entities.PV_Cannon5
		or _type == Entities.PV_Catapult then
			return true
		end
		return false
	end

	---Checks where the nearest free sector is based on a inserted position to an offset
	---@param _posX number - X-position of start point
	---@param _posY number - Y-position of start point
	---@param _offset number - Offset to the starting point
	---@param _step number - Scan width 
	---@return number - Returns the free sector
	EvaluateNearestUnblockedSector = function(_posX, _posY, _offset, _step)
		local xmax, ymax = Logic.WorldGetSize()
		local dmin, xspawn, yspawn

		for y_ = _posY - _offset, _posY + _offset, _step do
			for x_ = _posX - _offset, _posX + _offset, _step do
				if y_ > 0 and x_ > 0 and x_ < xmax and y_ < ymax then

					local d = (x_ - _posX)^2 + (y_ - _posY)^2
					local sector = CUtil.GetSector(x_ /100, y_ /100)
					if sector > 0 then
						return sector
					end
				end
			end
		end
		return 1
	end

	---Returns Pointer of EntityType
	---@param _entityType number - Entity Type
	---@return number - Pointer
	function GetEntityTypePointer(_entityType)
		return CUtilMemory.GetMemory(tonumber("0x895DB0", 16))[0][16][_entityType * 8 + 2]
	end

	-- Returns if building id is either a hero ability building (e.g. salim trap) or a construction site and thus inappropiate for certain purposes
	---@param _id integer entityID of building
	---@return boolean
	function IsInappropiateBuilding(_id)
		local str = string.lower(Logic.GetEntityTypeName(Logic.GetEntityType(_id)))
		return (string.find(str, "hero") ~= nil or string.find(str, "zb") ~= nil)
	end

	--- Returns the distance between two points
	---@param _a integer|string|table entityID or entityName or positionTable
	---@param _b integer|string|table entityID or entityName or positionTable
	---@return number distance
	GetDistance = function(_a, _b)

		if type(_a) ~= "table" then
			_a = GetPosition(_a)
		end

		if type(_b) ~= "table" then
			_b = GetPosition(_b)
		end

		if _a.X ~= nil then
			return math.sqrt((_a.X - _b.X)^2+(_a.Y - _b.Y)^2)
		else
			return math.sqrt((_a[1] - _b[1])^2+(_a[2] - _b[2])^2)
		end

	end

	--- Returns entity type max attack range (affected by weather and technologies)
	---@param _entity integer entityID
	---@param _player integer playerID
	---@return number attack range
	function GetEntityTypeMaxAttackRange(_entity, _player)
		local entityType = Logic.GetEntityType(_entity)
		local RangeTechBonusFlat
		local RangeTechBonusMultiplier
		--check technology modifiers
		for k,v in pairs(MPW.Army.EntityCatModifierTechs.AttackRange) do
			if Logic.IsEntityInCategory(_entity, k) == 1 then
				RangeTechBonusFlat = 0
				RangeTechBonusMultiplier = 1
				for i = 1,table.getn(v) do
					if Logic.GetTechnologyState(_player,v[i]) == 4 then
						local val, op = GetTechnologyAttackRangeModifier(v[i])
						if op == 0 then
							RangeTechBonusMultiplier = RangeTechBonusMultiplier + (val -1)
						elseif op == 1 then
							RangeTechBonusFlat = RangeTechBonusFlat + val
						end
					end
				end
			end
		end

		return GetEntityTypeBaseAttackRange(entityType) + (RangeTechBonusFlat or 0) * (RangeTechBonusMultiplier or 1)
	end

	---Returns the technology raw attack range modifier and the operation (+/*), both defined in the respective xml
	---@param _techID integer technology ID (Technologies.XXX)
	---@return number attack range modifier
	---@return string technology math operation (+/*)
	function GetTechnologyAttackRangeModifier(_techID)
		if not MPW.Army.MemValues.TechnologyAttackRangeModifier then
			MPW.Army.MemValues.TechnologyAttackRangeModifier = {}
		end
		if not MPW.Army.MemValues.TechnologyAttackRangeModifier[_techID] then
			MPW.Army.MemValues.TechnologyAttackRangeModifier[_techID] = GetTechnologyPointer(_techID)[88]:GetFloat(), CUtilBit32.BitAnd(GetTechnologyPointer(_techID)[90]:GetInt(), 2^8-1)-42
		end
		return MPW.Army.MemValues.TechnologyAttackRangeModifier[_techID]
	end

	---Returns Pointer of a technology
	---@param _techID number - Technology ID
	---@return number - Pointer
	function GetTechnologyPointer(_techID)
		return CUtilMemory.GetMemory(tonumber("0x85A3A0", 16))[0][13][1][_techID-1]
	end

	---Returns entity type base attack range (not affected by weather or technologies, just the raw value defined in the respective xml)
	---@param _EntityType integer
	---@return number BaseAttackRange
	function GetEntityTypeBaseAttackRange(_EntityType)
		if not MPW.Army.MemValues.EntityTypeBaseAttackRange[_EntityType] then
			MPW.Army.MemValues.EntityTypeBaseAttackRange[_EntityType] = Memory.GetEntityTypeMaxAttackRange( _EntityType )
		end
		return MPW.Army.MemValues.EntityTypeBaseAttackRange[_EntityType] or 0
	end

	---Gets entity type damage range
	---@param _EntityType integer
	---@return number DamageRange
	function GetEntityTypeDamageRange(_EntityType)
		if not MPW.Army.MemValues.EntityTypeDamageRange[_EntityType] then
			MPW.Army.MemValues.EntityTypeDamageRange[_EntityType] = Memory.GetEntityTypeDamageRange( _EntityType )
		end
		return MPW.Army.MemValues.EntityTypeDamageRange[_EntityType] or 0
	end

	---Get entity ID's nearest appropiate military building
    ---@param _playerId integer playerID
    ---@param _id integer entityID
    ---@return integer entityID
    function GetNearestBarracks(_playerId, _id)
        local ucat = GetUpgradeCategoryByEntityID(_id)
        local btype
        for k, v in pairs(MPW.Army.CategoriesInMilitaryBuilding) do
            for i = 1, table.getn(v) do
                if v[i] == ucat then
                    btype = k
                    break
                end
            end
        end
        local bt = {}
        for eID in CEntityIterator.Iterator(CEntityIterator.OfPlayerFilter(_playerId), CEntityIterator.OfAnyTypeFilter(Entities["PB_".. btype .."1"], Entities["PB_".. btype .."2"])) do
            table.insert(bt, {id = eID, dist = GetDistance(_id, eID)})
        end
        table.sort(bt, function(p1, p2)
            return p1.dist < p2.dist
        end)
        if bt[1] and bt[1].id then
            return bt[1].id
        else
            return 0
        end
    end

	---Creates a height map with given positions (via position interferences)
    ---Returns position with most other positions nearby (by highscore or numeric count)
    ---@param _postable table table filled with positions. Optional: use key factor to get individual inteference count results
    ---@param _infrange integer range used for interference. Each position given creates an inteference at any position within this range
    ---@param _step integer limits the steps made for interference creation. FYI: Larger steps increase performance significantly, but also reduce output quality
    ---@return table positionTable
    ---@return integer|number highscore value of clump; if individual factor was assigned, returns float, not integer
    function GetPositionClump(_postable, _infrange, _step)
        assert(type(_postable) == "table", "first input param type must be a table")
        assert(type(_infrange) == "number", "second input param type must be a number")
        assert(type(_step) == "number", "third input param type must be a number")
        local tab = {}
        for k, v in pairs(_postable) do
            if v.pos then
                v.X = v.pos.X
                v.Y = v.pos.Y
            end
            v.X = dekaround(v.X)
            for i = v.X - _infrange, v.X + _infrange, _step do
                tab[i] = {}
                v.Y = dekaround(v.Y)
                for j = v.Y - _infrange, v.Y + _infrange, _step do
                    if not tab[i][j] then
                        tab[i][j] = 0
                    end
                    tab[i][j] = tab[i][j] + (v.factor or 1)
                end
            end
        end
        local highscore = 0
        local clumppos = {}
        for _X, v in pairs(tab) do
            for _Y, x in pairs(v) do
                if x > highscore then
                    highscore = x
                    clumppos.X = _X
                    clumppos.Y = _Y
                end
            end
        end
        return clumppos, highscore
    end

	---Rounding comfort to next 100 step
    ---@param _n number number to be rounded
    ---@return number number
    function dekaround(_n)
        assert(type(_n) == "number", "round val needs to be a number")
        return math.floor( _n / 100 + 0.5 ) * 100
    end

	MPW.Army.UCatByType = {}
	---Gets upgrade category by entity type
	---@param _type integer EntityType
	---@param _flag boolean is EntityType a building? (true for building, false for settler)
	---@return integer upgradeCategory
	function GetUpgradeCategoryByEntityType(_type, _flag)
		if _flag then
			return Logic.GetUpgradeCategoryByBuildingType(_type)
		end
		if not MPW.Army.UCatByType[_type] then
			for k, v in pairs(UpgradeCategories) do
				local t = {Logic.GetSettlerTypesInUpgradeCategory(v)}
				for i = 2, t[1]+1 do
					MPW.Army.UCatByType[t[i]] = v
				end
			end
		end
		return MPW.Army.UCatByType[_type]
	end

	---Gets damage factor related to the damageclass/armorclass
	---@param _damageclass integer damage class
	---@param _armorclass integer armor class
	---@return number damage factor
	function GetDamageFactor(_damageclass, _armorclass)
		assert(_damageclass > 0 and _damageclass <= 10, "invalid damageclass") --muss je nach MPW Module angepasst werden
		assert(_armorclass > 0 and _armorclass <= 7, "invalid armorclass") --muss je nach MPW Module angepasst werden
		return GetDamageModifierPointer()[_damageclass][_armorclass]:GetFloat()
	end

	---Returns Pointer of the DamageModifier
	---@return number - Pointer
	function GetDamageModifierPointer()
		return CUtilMemory.GetMemory(tonumber("0x85A3DC", 16))[0][2]
	end

	---Gets upgrade category by entityID
	---@param _id integer entityID
	---@return integer upgradeCategory
	function GetUpgradeCategoryByEntityID(_id)
		local building = (Logic.IsBuilding(_id) == 1)
		local type = Logic.GetEntityType(_id)
		return GetUpgradeCategoryByEntityType(type, building)
	end
end

---Return all enemy player ids of an ai player
---@param _playerId number - AI PlayerID
---@return table - Table with all enemy player ids
function MPW.Army.GetAIEnemies( _playerId )
	local enemytab = {}
	if CNetwork then
		for i= 1,16 do
			if Logic.GetDiplomacyState( _playerId , i ) == 3 then
				table.insert(enemytab,i)
			end
		end
	else 
		for i= 1,8 do
			if Logic.GetDiplomacyState( _playerId , i ) == 3 then
				table.insert(enemytab,i)
			end
		end
	end
	return enemytab
end

function table.getnumberofelements(_table)
    local n = 0
    for _,_ in pairs(_table) do
        n = n + 1
    end
    return n
end

function table.getrandomelement(_table)
    local n = 0
    for _,_ in pairs(_table) do
        n = n + 1
    end
    local r = math.random(n)
    for k,_ in pairs(_table) do
        n = n + 1
        if n >= r then
            return k
        end
    end
end

---Checks if an entity is inside of a given range, based on a selected position
---@param _EntityId number - EntityID
---@param _Pos string|table - Position of the entity
---@param _Range number - Range checked from the position
---@return true|false boolean
function IsEntityInRange(_EntityId,_Pos,_Range)
	local pos
	if type(_Pos) == "string" then
		pos = GetPosition(_Pos)
	else
		pos = _Pos
	end
	local x, y = Logic.GetEntityPosition(_EntityId)
	return (pos.X-x)^2+(pos.Y-y)^2 <= _Range^2
end

function IsEntityInRangeFast(_EntityId,_X,_Y,_Range)
	local x, y = Logic.GetEntityPosition(_EntityId)
	return (_X-x)^2+(_Y-y)^2 <= _Range^2
end

---Returns if a value is already listet in a numbered table
---@param _value any - Value which needs to be checked
---@param _table table - Table which is getting checked
---@return true|false boolean - Returns true if its already listed in the table
function IsValueInTable(_value,_table)
    for _, v in ipairs(_table) do
        if v == _value then
            return true
        end
    end
    return false
end