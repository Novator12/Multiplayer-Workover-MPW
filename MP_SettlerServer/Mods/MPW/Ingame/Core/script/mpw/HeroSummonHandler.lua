-- ************************************************************************************************
-- SummonAbility-Optimation
-- ************************************************************************************************
MPW.HeroTable = {}
MPW.HeroSummonHandler = {}
-- ************************************************************************************************
function GUIAction_HeroSummon() --new action func for pilgrim, ari and varg
	if CNetwork then
		CNetwork.SendCommand("HeroSummonHandler", HeroSelection_GetCurrentSelectedHeroID(), HeroSelection_GetCurrentHeroType() ); --syncer
	else
		MPW.HeroSummonHandler.Handler( nil, HeroSelection_GetCurrentSelectedHeroID(), HeroSelection_GetCurrentHeroType() )
	end
end
-- ************************************************************************************************
function MPW.HeroSummonHandler.Handler( _Name, _Entity, _Type )

	local player = Logic.EntityGetPlayer( _Entity )
	MPW.HeroTable[player] = MPW.HeroTable[player] or {}
	
	local pos
	local sector = Logic.GetSector( _Entity )
	
	repeat
		pos = GetRandomPos( GetPosition( _Entity ), -500, 500 )
	until( CUtil.GetSector( pos.X / 100, pos.Y / 100) == sector )
	
	local rot = Logic.GetEntityOrientation( _Entity )
	local isatfullstrengthbuffer
	local isatfullstrength = true
	
	-- Pilgrim
	if _Type == Entities.PU_Hero2 then
	
		MPW.HeroTable[player][1], isatfullstrength = SpawnOrRefreshTroop(MPW.HeroTable[player][1], player, Entities.PU_Hero2_Cannon3, 0, pos,rot)
	
	-- Ari
	elseif _Type == Entities.PU_Hero5 then
	
		MPW.HeroTable[player][2], isatfullstrength = SpawnOrRefreshTroop(MPW.HeroTable[player][2], player, Entities.PU_Hero5_LeaderBanditSword, 8, pos,rot) 
		
		repeat
			pos = GetRandomPos( GetPosition( _Entity ), -500, 500 )
		until( CUtil.GetSector( pos.X / 100, pos.Y / 100) == sector )
		
		MPW.HeroTable[player][3], isatfullstrengthbuffer = SpawnOrRefreshTroop(MPW.HeroTable[player][3], player, Entities.PU_Hero5_LeaderBanditBow, 4, pos,rot)
		isatfullstrength = isatfullstrength and isatfullstrengthbuffer
	
	-- Varg
	elseif _Type == Entities.CU_Barbarian_Hero then
	
		MPW.HeroTable[player][4], isatfullstrength = SpawnOrRefreshTroop(MPW.HeroTable[player][4], player, Entities.PU_Hero9_LeaderWolf, 6, pos,rot)
		
		repeat
			pos = GetRandomPos( GetPosition( _Entity ), -500, 500 )
		until( CUtil.GetSector( pos.X / 100, pos.Y / 100) == sector )
		
		MPW.HeroTable[player][5], isatfullstrengthbuffer = SpawnOrRefreshTroop(MPW.HeroTable[player][5], player, Entities.PU_Hero9_LeaderWolf, 6, pos,rot)
		isatfullstrength = isatfullstrength and isatfullstrengthbuffer
	end
	
	-- trigger internal cooldown for recharge timer widget
	-- only if troop was not full already
	if not isatfullstrength and player == GUI.GetPlayerID() then
		GUI.SettlerSummon( _Entity )
	end
end
-- ************************************************************************************************
function MPW.HeroSummonHandler.PostInit()
	
	-- setup handler for CNetwork.SendCommand
	if CNetwork then
		CNetwork.SetNetworkHandler("HeroSummonHandler", MPW.HeroSummonHandler.Handler)
	end
end
-- ************************************************************************************************
--Function to refresh or spawn a new troop
--- @param _EntityID number Entity which gets respawned or refreshed with soldiers
--- @param _Player number Player who controles the created entity
--- @param _LeaderType number EntityType of the leader to create
--- @param _MaxSoldierAmount number SoldierAmount of the leader to create
--- @param _Position table position from where the entity get spawned (combine it with GetRandomPos)
--- @param _Rotation? number rotation of the spawned entity
--- @return number, boolean returns new _EntityID when not refreshed and if there are any spawned troops
function SpawnOrRefreshTroop( _EntityID, _Player, _LeaderType, _MaxSoldierAmount, _Position, _Rotation )
	
	local isatfullstrength = true
	
	if IsDead( _EntityID ) then
		_EntityID = Tools.CreateGroup( _Player, _LeaderType, _MaxSoldierAmount, _Position.X, _Position.Y )
		isatfullstrength = false
	else
	
		local soldiers = { Logic.GetSoldiersAttachedToLeader( _EntityID ) }
		local n = soldiers[1]
		soldiers[1] = _EntityID
		
		for _,id in pairs(soldiers) do
			if GetHealth( id ) < 100 then
				SetHealth(id, 100)
				local pos = GetPosition(id)
				Logic.CreateEffect( GGL_Effects.FXSalimHeal, pos.X, pos.Y, 0 )
				isatfullstrength = false
			end
		end

		if _MaxSoldierAmount-n > 0 then
			Tools.CreateSoldiersForLeader( _EntityID, _MaxSoldierAmount-n )
			isatfullstrength = false
		end
	end
	
	return _EntityID, isatfullstrength
end
-- ************************************************************************************************
--Function to calculate a random offset from a given position
--- @param _Pos table position from where the random calculates the offset
--- @param _Min number minimum of random value.
--- @param _Max number maximum of random value.
--- @return table returns table with random x,y position.
function GetRandomPos(_Pos,_Min,_Max)
	local pos = { X = _Pos.X+math.random(_Min,_Max), Y = _Pos.Y+math.random(_Min,_Max)}
	return pos
end
-- ************************************************************************************************
function GetHealth(_Entity)
    local EntityID = GetID(_Entity);
    if not Tools.IsEntityAlive(EntityID) then
        return 0;
    end
    local MaxHealth = Logic.GetEntityMaxHealth(EntityID);
    local Health = Logic.GetEntityHealth(EntityID);
    return (Health / MaxHealth) * 100;
end