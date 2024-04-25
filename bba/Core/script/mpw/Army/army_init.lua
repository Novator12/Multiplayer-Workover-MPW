--MPW Army inspired by Ghoul

--initialisation of army
MPW.Army = MPW.Army or {} 

function MPW.Army.Init()
    Chunk.Init()
    MPW.Army.InitComforts()
    MPW.Army.MemValues = MPW.Army.MemValues or {}
    MPW.Army.MemValues.EntityTypeBaseAttackRange = MPW.Army.MemValues.EntityTypeBaseAttackRange or {}
    MPW.Army.MemValues.EntityTypeDamageRange = MPW.Army.MemValues.EntityTypeDamageRange or {}

    --Dmg-Classes wie in xml numeriert
    local Unit = {
        Sword = 1,
        CrossBow = 2,
        PoleArm = 3,
        Bow = 4,
        HeavyCavalry = 5,
        LightCavalry = 6,
        LightCannons = 7,
        Axe = 8,
        Rifle = 9,
        HeavyCannons = 10,
    }
    --Armor-Classes 
    local Armor = {
        Leather = 1,
        Jerkin = 2,
        Fur = 3,
        None = 4,
        Iron = 5,
        Hero = 6,
        Fortification = 7
    }
    --describes whats good against the different armor classes
    MPW.Army.GetBestDamageClassesByArmorClass = {	[Armor.Leather] = {{id = Unit.LightCannons, val = 3},{id = Unit.Axe, val = 4},{id = Unit.Rifle, val = 6}},
                                                    [Armor.Jerkin] = {{id = Unit.Sword, val = 2}, {id = Unit.CrossBow, val = 2},{id = Unit.Axe, val = 2},{id = Unit.Rifle, val = 7}},
                                                    [Armor.Fur] = {{id = Unit.Sword, val = 2}, {id = Unit.CrossBow, val = 2}, {id = Unit.PoleArm, val = 2}, {id = Unit.Bow, val = 7}},
                                                    [Armor.None] = {{id = Unit.PoleArm, val = 2}, {id = Unit.Bow, val = 2}, {id = Unit.HeavyCavalry, val = 2}, {id = Unit.LightCavalry, val = 7}},
                                                    [Armor.Iron] = {{id = Unit.HeavyCavalry, val = 3},{id = Unit.LightCavalry, val = 4},{id = Unit.LightCannons, val = 6}},
                                                    [Armor.Hero] = {{id = Unit.CrossBow, val = 2},{id = Unit.PoleArm, val = 2},{id = Unit.HeavyCavalry, val = 2},{id = Unit.LightCavalry, val = 7}},
                                                    [Armor.Fortification] = {{id = Unit.HeavyCannons, val = 10}}
                                                    }
    --Für MPW Anpassen
    MPW.Army.GetUpgradeCategoryByDamageClass = {	[1] = UpgradeCategories.LeaderSword, --DC_Strike
                                                    [2] = UpgradeCategories.LeaderCrossBow, --DC_CrossBow
                                                    [3] = UpgradeCategories.LeaderPoleArm, --DC_Pole
                                                    [4] = UpgradeCategories.LeaderBow, --DC_Pierce
                                                    [5] = UpgradeCategories.LeaderHeavyCavalry, --DC_HeavyCavalry
                                                    [6] = UpgradeCategories.LeaderCavalry, --DC_LightCavalry
                                                    [7] = {Entities.PV_Cannon1,Entities.PV_Cannon3}, --DC_Chaos
                                                    [8] = UpgradeCategories.LeaderAxe, --DC_Axe
                                                    [9] = UpgradeCategories.LeaderRifle,  --DC_Bullet
                                                    [10] = {Entities.PV_Cannon2,Entities.PV_Cannon4},   --DC_Siege
                                                    -- [11] = UpgradeCategories.LeaderCavalry,  --DC_Hero
                                                    -- [12] = UpgradeCategories.LeaderCavalry,   --DC_Evil
                                                    -- [13] = UpgradeCategories.LeaderCavalry,   --DC_Building
                                                    -- [14] = UpgradeCategories.LeaderCavalry,   --DC_Fist
                                                    }
                            
    MPW.Army.CategoriesInMilitaryBuilding = {   ["Barracks"] = {UpgradeCategories.LeaderSword, UpgradeCategories.LeaderPoleArm, UpgradeCategories.LeaderAxe},
                                                ["Archery"] = {UpgradeCategories.LeaderBow, UpgradeCategories.LeaderRifle, UpgradeCategories.LeaderCrossBow},
                                                ["Stables"] = {UpgradeCategories.LeaderCavalry, UpgradeCategories.LeaderHeavyCavalry},
                                                ["Foundry"] = {Entities.PV_Cannon1, Entities.PV_Cannon2, Entities.PV_Cannon3, Entities.PV_Cannon4}
                                            }

    MPW.Army.EntityCatModifierTechs = {
                --                          ["Speed"] = {	[EntityCategories.Hero] = {Technologies.T_HeroicShoes},
                -- 										    [EntityCategories.Serf] = {Technologies.T_Shoes, Technologies.T_Alacricity},
                -- 										    [EntityCategories.Bow] = {Technologies.T_BetterTrainingArchery},
                -- 										    [EntityCategories.Rifle] = {Technologies.T_BetterTrainingArchery},
                -- 										    [EntityCategories.Sword] = {Technologies.T_BetterTrainingBarracks},
                -- 										    [EntityCategories.Spear] = {Technologies.T_BetterTrainingBarracks},
                -- 										    [EntityCategories.CavalryHeavy] = {Technologies.T_Shoeing},
                -- 									    	[EntityCategories.CavalryLight] = {Technologies.T_Shoeing},
                -- 										    [EntityCategories.Cannon] = {Technologies.T_BetterChassis},
                -- 										    [EntityCategories.Thief] = {Technologies.T_Agility, Technologies.T_Chest_ThiefBuff}
                -- 										},
                                        ["AttackRange"] = {	[EntityCategories.Bow] = {Technologies.T_Fletching},
                                                            [EntityCategories.CavalryLight] = {Technologies.T_Fletching},
                                                            [EntityCategories.Rifle] = {Technologies.T_Sights}
                                                            }
                                        }

    MPW.Army.BehaviorExceptionEntityTypeTable = { 	[Entities.PU_Hero1]  = true,
                                            [Entities.PU_Hero1a] = true,
                                            [Entities.PU_Hero1b] = true,
                                            [Entities.PU_Hero1c] = true,
                                            [Entities.PU_Hero11] = true,
                                            [Entities.CU_Mary_de_Mortfichet] = true,
                                            [Entities.PU_Serf] = true
                                        }
    MPW.Army.gvAntiBuildingCannonsRange = {	[Entities.PV_Cannon2] = 950,
                                            [Entities.PV_Cannon4] = 1300,
                                        }

    MPW.Army.DamageFactorToArmorClass =  MPW.Army.DamageFactorToArmorClass or {}
    for i = 1,10 do             --muss je nach MPW Module angepasst werden
        MPW.Army.DamageFactorToArmorClass[i] = {}
        for k = 1,7 do  --muss je nach MPW Module angepasst werden
            MPW.Army.DamageFactorToArmorClass[i][k] = GetDamageFactor(i, k)
        end
    end

    MPW.Army.PostInit()
end

function MPW.Army.PostInit()

    ---Selects the best damage class against the given armorclass
    ---@param _ACid number - Id of armor class (hierachie: based on dmgclass.xml)
    ---@return integer - Returns id of the best dmg class (hierachie: based on dmgclass.xml)
    MPW.Army.GetBestDamageClassByArmorClass = function(_ACid)
        local rand = math.random(1, 9)
		local rand2 = math.random(1, 8)
        if not MPW.Army.GetBestDamageClassesByArmorClass[_ACid][2] then	--bei 1 Kontertruppe
            return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].id
        elseif table.getn(MPW.Army.GetBestDamageClassesByArmorClass[_ACid]) == 2 then --bei 2 Kontertruppe
            if rand2 <= MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].val then
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].id
            else
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][2].id
            end
        elseif table.getn(MPW.Army.GetBestDamageClassesByArmorClass[_ACid]) == 3 then --bei 3 Kontertruppe
            if rand <= MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].val then
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].id
            elseif rand > MPW.Army.GetBestDamageClassesByArmorClass[_ACid][3].val then
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][3].id
            else
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][2].id
            end
        else
            if rand2 <= MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].val then --bei 4 Kontertruppe
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].id
            elseif rand2 > MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].val and rand2 <= MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].val + MPW.Army.GetBestDamageClassesByArmorClass[_ACid][2].val then
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][2].id
            elseif rand2 > MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].val + MPW.Army.GetBestDamageClassesByArmorClass[_ACid][2].val and rand2 <= MPW.Army.GetBestDamageClassesByArmorClass[_ACid][1].val + MPW.Army.GetBestDamageClassesByArmorClass[_ACid][2].val + MPW.Army.GetBestDamageClassesByArmorClass[_ACid][3].val then
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][3].id
            else
                return MPW.Army.GetBestDamageClassesByArmorClass[_ACid][4].id
            end
        end
    end

    ---comment
    ---@param _playerId any
    ---@return table
    MPW.Army.GetAllEnemyPlayerIDs = function(_playerId)
        local playerIDTable = {}
        local maxplayers
        if CNetwork then
            maxplayers = 16
        else
            maxplayers = 8
        end
        for i = 1, maxplayers do
            if Logic.GetDiplomacyState(i, _playerId) == Diplomacy.Hostile then
                table.insert(playerIDTable, i)
            end
        end
        return playerIDTable
    end

    MPW.Army.CheckForNearestHostileBuildingInAttackRange = function(_entity, _range)

        if not Logic.IsEntityAlive(_entity) then
            return
        end
    
        local playerID = Logic.EntityGetPlayer(_entity)
        local posX, posY = Logic.GetEntityPosition(_entity)
        local distancepow2table	= {}
    
        for eID in CEntityIterator.Iterator(CEntityIterator.OfAnyPlayerFilter(unpack(MPW.Army.GetAllEnemyPlayerIDs(playerID))), CEntityIterator.IsBuildingFilter(), CEntityIterator.InCircleFilter(posX, posY, _range)) do
            if Logic.IsEntityInCategory(eID, EntityCategories.Wall) == 0 and not IsInappropiateBuilding(eID) then
                local _X, _Y = Logic.GetEntityPosition(eID)
                local distancepow2 = (_X - posX)^2 + (_Y - posY)^2
                if Logic.GetFoundationTop(eID) ~= 0 or Logic.IsEntityInCategory(eID, EntityCategories.Bridge) == 1 then
                    distancepow2 = distancepow2 / 2
                end
                table.insert(distancepow2table, {id = eID, dist = distancepow2})
            end
        end
    
        table.sort(distancepow2table, function(p1, p2)
            return p1.dist < p2.dist
        end)
    
        return (distancepow2table[1] and distancepow2table[1].id)
    
    end
end

AIEnemiesAC = AIEnemiesAC or {}
for _playerId = 2,12 do
	AIEnemiesAC[_playerId] = AIEnemiesAC[_playerId] or {}
	AIEnemiesAC[_playerId].total = AIEnemiesAC[_playerId].total or 0
	for i = 1,7 do
		AIEnemiesAC[_playerId][i] = AIEnemiesAC[_playerId][i] or {}
	end
end

---Defines the baseparameters of an ai controlled player
---@param _playerId number - [1-16] PlayerID of the Ai
---@param _strength number - [1-3] Describes the resourceamount, resourcerefreshment and size of the ai army (strenght x 8 = Amount of offensive leaders, strenght x 4 = Amount of defensive leaders)
---@param _range number - Attack range of the ai army
---@param _techlevel number - [0-3] Describes techLVL of the ai (0 = Level 1 Troops, 1 = Level 2 Troops,...)
---@param _position string|number|table - Main spot of the army from which will be defended or attacked
---@param _aggressiveLevel number - [0-3] Describes the attack amount from an ai army (higher value = more attacks)
---@param _peaceTime number - [in Seconds] Time in which the ai will not attack (starting after this function is called)
---@param _multiTrain boolean - [true/false] true = Army will recruit in different buildings at the same time, false = only recruits in one building at the time 
---@param _defenseRange number - Defense range of the ai army
MapEditor_SetupAI = function(_playerId, _strength, _range, _techlevel, _position, _aggressiveLevel, _peaceTime, _multiTrain, _defenseRange)
    -- Valid
	if _playerId < 1 or _playerId > 16 then
		return
	end
    --when wierd numbers are given choose nearest in bounce
    _strength = math.max(math.min(_strength,3),1)

    _techlevel = math.max(math.min(_techlevel,3),0)

    _aggressiveLevel = math.max(math.min(_aggressiveLevel,3),0)

    if _peaceTime < 0 or type(_peaceTime) ~= "number" then
        _peaceTime = 0
    end

    if not _multiTrain then
        _multiTrain = true
    end

    if not _defenseRange then
        local X = Logic.WorldGetSize()
        _defenseRange = 1/3 * X
    end

    local position
    if type(_position) == "table" then
        position = _position
    elseif (type(_position) == "string" and _position ~= "" )or type(_position) == "number" then
        position = GetPosition(_position)
    else
        return 
    end

	-- TODO: check for buildings !!!CHECKEN BEI ARMEE UMSCHREIBUNG!!!
	if Logic.GetPlayerEntitiesInArea(_playerId, 0, position.X, position.Y, 0, 1, 8) == 0 then
		return
	end

	--	set up default information
	local description = {}
		description = {

			serfLimit				=	12,
			--------------------------------------------------
			extracting				=	1,
			--------------------------------------------------
			resources = {
				gold				=	_strength*15000,
				clay				=	_strength*12500,
				iron				=	_strength*12500,
				sulfur				=	_strength*12500,
				stone				=	_strength*12500,
				wood				=	_strength*12500
			},
			--------------------------------------------------
			refresh = {
				gold				=	_strength*3300,
				clay				=	_strength*400,
				iron				=	_strength*3100,
				sulfur				=	_strength*3550,
				stone				=	_strength*400,
				wood				=	_strength*3750,
				updateTime			=	10
			},
			--------------------------------------------------
			constructing			=	true,
			--------------------------------------------------
			rebuild = {
				delay				=	30,
				randomTime			=	5
			},
		}
	SetupPlayerAi(_playerId, description)

	local CannonEntityType1
	local CannonEntityType2
    -- MPW-Anpassen für Modularität
	-- Tech level
	if _techlevel <= 2 then
		CannonEntityType1 = Entities.PV_Cannon1
		CannonEntityType2 = Entities.PV_Cannon2
	elseif _techlevel == 3 then
		CannonEntityType1 = Entities.PV_Cannon3
		CannonEntityType2 = Entities.PV_Cannon4
	end

    -- MPW-Anpassen für Modularität
	for i=1,_techlevel do
        if not MPW.PU_Axe then
            Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderBow, _playerId)
            Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierBow, _playerId)
        end
        Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderSword, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierSword, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderPoleArm, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierPoleArm, _playerId)
        if MPW.PU_Axe then
            Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderAxe, _playerId)
            Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierAxe, _playerId)
        end
    end
    for i=2, ((_techlevel+1)/2) do
        if MPW.PU_Axe then
            Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderBow, _playerId)
            Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierBow, _playerId)
            Logic.UpgradeSettler(UpgradeCategories.LeaderCrossBow, _playerId)
            Logic.UpgradeSettler(UpgradeCategories.SoldierCrossBow, _playerId)
        end
        Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderCavalry, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierCavalry, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderHeavyCavalry, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierHeavyCavalry, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.LeaderRifle, _playerId)
        Logic.UpgradeSettlerCategory(UpgradeCategories.SoldierRifle, _playerId)
    end

	-- army
	if MapEditor_Armies == nil then
		MapEditor_Armies = {}
	end
	if MapEditor_Armies.Trigger == nil then
		MapEditor_Armies.Trigger = {offensiveArmies = {}, defensiveArmies = {}}
	end
    -- MPW-Anpassen für Modularität
    if not MPW.PU_Axe then
        MapEditor_Armies[_playerId] = {
            prioritylist = {},
            prioritylist_lastUpdate = 0,
            multiTraining = _multiTrain or true,
            player = _playerId,
            id = 0,
            techLVL = _techlevel,
            aggressiveLVL =	_aggressiveLevel,
            AllowedTypes = {UpgradeCategories.LeaderBow,
                            UpgradeCategories.LeaderSword,
                            UpgradeCategories.LeaderPoleArm,
                            UpgradeCategories.LeaderCavalry,
                            UpgradeCategories.LeaderHeavyCavalry,
                            UpgradeCategories.LeaderRifle,
                            CannonEntityType1,
                            CannonEntityType2
                            },
            offensiveArmies = {strength	= _strength * 4,
                                position = position,
                                rodeLength = _range,
                                baseDefenseRange = _defenseRange or (_range*2)/3,
                                AttackAllowed =	false,
                                IDs	= {},
                                Anchor = {X = position.X,Y = position.Y}
                                },
            defensiveArmies = {strength	= _strength * 2,
                                position = position,
                                baseDefenseRange = _defenseRange or 10000,
                                IDs	= {},
                                Anchor = {X = position.X,Y = position.Y}
                                }
            }
    else
        MapEditor_Armies[_playerId] = {
            prioritylist = {},
            prioritylist_lastUpdate = 0,
            multiTraining = _multiTrain or true,
            player = _playerId,
            id = 0,
            techLVL = _techlevel,
            aggressiveLVL =	_aggressiveLevel,
            AllowedTypes  =	{UpgradeCategories.LeaderBow,
                            UpgradeCategories.LeaderCrossBow,
                            UpgradeCategories.LeaderSword,
                            UpgradeCategories.LeaderAxe,
                            UpgradeCategories.LeaderPoleArm,
                            UpgradeCategories.LeaderCavalry,
                            UpgradeCategories.LeaderHeavyCavalry,
                            UpgradeCategories.LeaderRifle,
                            CannonEntityType1,
                            CannonEntityType2
                            },
            offensiveArmies = {strength	= _strength * 4,
                                position = position,
                                rodeLength = _range,
                                baseDefenseRange = _defenseRange or (_range*2)/3,
                                PTAttackAllowed =	false,
                                IDs	= {}
                                },
            defensiveArmies = {strength	= _strength * 4,
                                position = position,
                                baseDefenseRange = _defenseRange or 10000,
                                IDs	= {}
                                }
            }
    end

    local x,y = GetNearbyWalkablePosition(position.X, position.Y)
    MapEditor_Armies[_playerId]["offensiveArmies"].Anchor = {X = x, Y=y}
    MapEditor_Armies[_playerId]["defensiveArmies"].Anchor = {X = x, Y=y}

    local x,y = GetNearbyWalkablePosition(position.X, position.Y)
    MapEditor_Armies[_playerId]["offensiveArmies"].Anchor.Homespot = {X = x, Y=y}
    MapEditor_Armies[_playerId]["defensiveArmies"].Anchor.Homespot = {X = x, Y=y}

	-- Spawn generator
	-- Setup trigger
	if not MapEditor_Armies[_playerId].generatorID then
		MapEditor_Armies[_playerId].generatorID = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "MapEditor_Armies_RecruiterAction", 1, nil, {_playerId})
	end
	if not MapEditor_Armies[_playerId].collectLeaderID then
		MapEditor_Armies[_playerId].collectLeaderID = Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_CREATED, "", "MapEditor_Armies_GetLeader", 1, {}, {_playerId})
	end

    --ArmyTrigger

    --PeactimeTrigger
	local peaceTimeTriggerId = Trigger.RequestTrigger( Events.LOGIC_EVENT_EVERY_SECOND, nil, "Army_PeactimeTrigger", 1, nil, {_playerId, _peaceTime})
    table.insert(MapEditor_Armies.Trigger,peaceTimeTriggerId)

    --EnemyLeader
	if MapEditor_Armies.Trigger.offensiveArmies[_playerId] == nil then
		MapEditor_Armies.Trigger.offensiveArmies[_playerId] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "EnemyLeaderScanDelay", 1, {}, {_playerId, "offensiveArmies"})
    end

	if MapEditor_Armies.Trigger.defensiveArmies[_playerId] == nil then
		MapEditor_Armies.Trigger.defensiveArmies[_playerId] = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, "", "EnemyLeaderScanDelay", 1, {}, {_playerId, "defensiveArmies"})
    end

	--ArmyTrigger
	local aiDiplomacyTriggerId = Trigger.RequestTrigger(Events.LOGIC_EVENT_DIPLOMACY_CHANGED, "", "OnAIDiplomacyChanged", 1, {}, {_playerId})
    table.insert(MapEditor_Armies.Trigger,aiDiplomacyTriggerId)

    MapEditor_Armies[_playerId].EnemyPlayers = {}
    MapEditor_Armies[_playerId].EnemyPlayers = MPW.Army.GetAIEnemies( _playerId )
end

function EnemyLeaderScanDelay(_playerId , _type)
    if Counter.Tick2("EnemyLeaderScanDelay_".._playerId.."_".._type,10) then
        MPW.Army.FillEnemyLeaderTable( _playerId , _type )
    end
end

-------------------------------------------------------------------------------------------------------
--
--	                SetupPlayerAi(<playerId>,<description table>)
--
-------------------------------------------------------------------------------------------------------
---Setup AI Table -> Resources: Resourcetable, Refresh: Refreshmenttable, Serflimit: Number, ResourceFocus: Resourcetype, Extracting: Flag, Rebuild: delay = number, randomTime = number, Construction: boolean  
---@param _playerId number - [1-16] PlayerID of the Ai
---@param _description table - Table with AI description 
SetupPlayerAi = function(_playerId,_description)

    Logic.SetPlayerPaysLeaderFlag(_playerId,0)
    
    AI.Player_EnableAi(_playerId)

    if _description.resources ~= nil then		
    
        AI.Player_SetResources(_playerId,_description.resources.gold,_description.resources.clay,_description.resources.iron,_description.resources.sulfur,_description.resources.stone,_description.resources.wood)
    
        end

    if _description.refresh ~= nil then		
    
        AI.Player_SetResourceRefreshRates(_playerId,_description.refresh.gold,_description.refresh.clay,_description.refresh.iron,_description.refresh.sulfur,_description.refresh.stone,_description.refresh.wood,_description.refresh.updateTime)
    
        end
    
    if _description.serfLimit ~= nil then
    
        AI.Village_SetSerfLimit(_playerId,_description.serfLimit)
    
        end
        
    if _description.resourceFocus ~= nil then
    
        AI.Village_SetResourceFocus(_playerId,_description.resourceFocus)
    
        end

    if _description.extracting ~= nil then
    
        AI.Village_EnableExtracting(_playerId,_description.extracting)
    
        end
                
    if _description.rebuild ~= nil then
    
        AI.Entity_ActivateRebuildBehaviour(_playerId,_description.rebuild.delay,_description.rebuild.randomTime)
        
        AI.Village_EnableConstructing(_playerId,1)
        
    else

        AI.Village_DeactivateRebuildBehaviour(_playerId)
        
        AI.Village_EnableConstructing(_playerId,0)
        
        end

    if _description.constructing ~= nil then
                    
        if _description.constructing == true then			
        
            AI.Village_EnableConstructing(_playerId,1)		
                            
        else
    
            AI.Village_EnableConstructing(_playerId,0)		
            
        end
        
    end
        
end

---Reinits the chunk data after a diplomacy change between the AI Player and the target player. Removes all targets  
---@param _playerId number - Player ID of the ai
function OnAIDiplomacyChanged(_playerId)
	local p = Event.GetSourcePlayerID()
	local p2 = Event.GetTargetPlayerID()
	local state = Event.GetDiplomacyState()

	if p == _playerId or p2 == _playerId then
		RemoveCurrentTargetData(_playerId)
	end
	MapEditor_Armies[_playerId].EnemyPlayers = {}
	MapEditor_Armies[_playerId].EnemyPlayers = MPW.Army.GetAIEnemies( _playerId )
end 

---Removes the current targets of an AI Player (offensive and defensive armies)
---@param _playerId number - Player ID of the ai
RemoveCurrentTargetData = function(_playerId)
	if MapEditor_Armies and MapEditor_Armies[_playerId] then
		for k, v in pairs(MapEditor_Armies[_playerId].defensiveArmies) do
			if type(k) == "number" then
				v.currenttarget = nil
			end
		end
		for k, v in pairs(MapEditor_Armies[_playerId].offensiveArmies) do
			if type(k) == "number" then
				v.currenttarget = nil
			end
		end
	end
end 

---Checks for peacetime delay/attack delay of an ai player army
---@param _playerId number - Player of ai army
---@param _delay number - Peactime [in seconds]
---@return true|false boolean - Ends the Counter
Army_PeactimeTrigger = function(_playerId, _delay)
	if Counter.Tick2("Army_PeactimeTrigger_".._playerId, _delay) then
		MapEditor_Armies[_playerId].offensiveArmies.PTAttackAllowed = true
		return true
    else
        return false
    end
end
