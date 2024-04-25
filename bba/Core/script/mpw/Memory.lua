--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- memory access by RobbiTheFox
-- thanks to mcb and kimichura
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
Memory = {}
Memory.Saved = {}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
if CUtilMemory then
	Memory.GetMemory = CUtilMemory.GetMemory
	Memory.GetEntityMem = function( _entity )
		return CUtilMemory.GetMemory( CUtilMemory.GetEntityAddress( _entity ) )
	end
elseif S5Hook then
	Memory.GetMemory = S5Hook.GetRawMem
	Memory.GetEntityMem = S5Hook.GetEntityMem
else
	assert( false, "memory.lua requires S5Hook or CUtilMemory" )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Behaviors = {
	CAbilityScoutBinocular = 7836184,
	CAffectMotivationBehavior = 7836044,
	CAutoCannonBehavior = 7834864,
	CBarrackBehavior = 7834216,
	CBattleSerfBehavior = 7833796,
	CBehaviorAnimalMovement = 7833612,
	CBehaviorWalkCommand = 7812772,
	CBombBehavior = 7832680,
	CBombPlacerBehavior = 7832536,
	CBuildingBehavior = 7831484,
	CCamouflageBehavior = 7813364,
	CCampBehavior = 7829604,
	CCamperBehavior = 7829372,
	CCannonBuilderBehavior = 7828692,
	CCircularAttack =7828580,
	CConstructionSiteBehavior = 7828516,
	CConvertSettlerAbility = 7828116,
	CDefendableBuildingBehavior = 7827932,
	CEvadeExecutionBehavior = 7827228,
	CFarmBehavior = 7827132,
	CFormationBehavior = 7826784,
	CFoundationBehavior = 7826592,
	CFoundryBehavior = 7834252,
	CGLBehaviorAnimationEx = 7826276,
	CGLBehaviorDying = 7833060,
	CHeroBehavior = 7825276,
	CHeroHawkBehavior = 7825136,
	CInflictFearAbility = 7824952,
	CKeepBehavior = 7824840,
	CKegBehavior = 7824600,
	CKegPlacerBehavior = 7824232,
	CLeaderBehavior = 7823840,
	CLeaderEvadeBehavior = 7823144,
	CLeaderMovement = 7823060,
	CLimitedAttachmentBehavior = 7822980,
	CLimitedLifespanBehavior = 7822748,
	CMarketBehavior = 7822540,
	CMineBehavior = 7821260,
	CMotivateWorkersAbility = 7821132,
	CNeutralBridgeBehavior = 7838660,
	CParticleEffectAttachmentBehavior = 7886272,
	CParticleEffectSwitchBehavior = 7886220,
	CPointToResourceBehavior = 7819184,
	CRangedEffectAbility = 7818836,
	CReplaceableEntityBehavior = 7818732,
	CResourceDependentBuildingBehavior = 7818644,
	CResourceDoodadBehavior = 7818444,
	CResourceRefinerBehavior = 7818188,
	CSentinelBehavior = 7818092,
	CSerfBattleBehavior = 7817880,
	CSerfBehavior = 7817332,
	CSettlerMovement = 7816988,
	CShurikenAbility = 7816792,
	CSniperAbility = 7816620,
	CSoldierBehavior = 7814344,
	CSoldierEvadeBehavior = 7816568,
	CSoldierMovement = 7816076,
	CSummonBehavior = 7814160,
	CSummonedBehavior = 7814072,
	CThiefBehavior = 7813552,
	CThiefCamouflageBehavior = 7813428,
	CTorchBehavior = 7813192,
	CTorchPlacerBehavior = 7812920,
	CUniversityBehavior = 7812852,
	CUVAnimBehavior = 7886048,
	CWorkerAlarmModeBehavior = 7812316,
	CWorkerBehavior = 7809840,
	CWorkerEvadeBehavior = 7809692,
	CWorkerFleeBehavior = 7809532,
	GLEBehaviorMultiSubAnims = 7888620,
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
BehaviorProperties = {
	CAbilityScoutBinocularProps = 7836244,
	CAffectMotivationBehaviorProps = 7836116,
	CAnimationBehaviorProps = 7826356,
	CAutoCannonBehaviorProps = 7834836,
	CBarrackBehaviorProperties = 7834420,
	CBattleBehaviorProps = 7811520,
	CBattleSerfBehaviorProps = 7833756,
	CBombBehaviorProperties = 7832736,
	CBuildingMerchantBehaviorProps = 7832504,
	CCamouflageBehaviorProps = 7829720,
	CCampBehaviorProperties = 7829588,
	CCamperBehaviorProperties = 7829460,
	CCannonBuilderBehaviorProps = 7828752,
	CCircularAttackProps = 7828640,
	CConvertBuildingAbilityProps = 7828440,
	CConvertSettlerAbilityProps = 7828176,
	CDefendableBuildingBehaviorProps = 7828020,
	CFormationBehaviorProperties = 7826916,
	CFoundationBehaviorProps = 7826696,
	CFoundryBehaviorProperties = 7834496,
	CGLAnimationBehaviorExProps = 7826504,
	CGLBehaviorPropsDying = 7833140,
	CGLResourceDoodadBehaviorProps = 7818560,
	CHawkBehaviorProps = 7826044,
	CHeroAbilityProps = 7812980,
	CHeroBehaviorProps = 7825396,
	CHeroHawkBehaviorProps = 7825196,
	CInflictFearAbilityProps = 7825012,
	CKeepBehaviorProperties = 7824896,
	CKegBehaviorProperties = 7824728,
	CKegPlacerBehaviorProperties = 7824308,
	CLeaderBehaviorProps = 7823268,
	CLimitedAttachmentBehaviorProperties = 7823028,
	CLimitedLifespanBehaviorProps = 7822820,
	CMineBehaviorProperties = 7821340,
	CMotivateWorkersAbilityProps = 7821192,
	CMovementBehaviorProps = 7883064,
	CNeutralBridgeBehaviorProperties = 7838620,
	CPointToResourceBehaviorProperties = 7819244,
	CRangedEffectAbilityProps = 7818908,
	CReplaceableEntityBehaviorProperties = 7818788,
	CResourceDependentBuildingBehaviorProperties = 7818700,
	CResourceRefinerBehaviorProperties = 7818276,
	CSentinelBehaviorProps = 7818156,
	CSerfBattleBehaviorProps = 7818064,
	CSerfBehaviorProps = 7817748,
	CServiceBuildingBehaviorProperties = 7817264,
	CSettlerMerchantBehaviorProps = 7817180,
	CShurikenAbilityProps = 7816884,
	CSniperAbilityProps = 7816680,
	CSoldierBehaviorProps = 7814416,
	CSummonBehaviorProps = 7814224,
	CSummonedBehaviorProps = 7814128,
	CThiefBehaviorProperties = 7813600,
	CTorchBehaviorProperties = 7813248,
	CTorchPlacerBehaviorProperties = 7813008,
	CWorkerAlarmModeBehaviorProps = 7812420,
	CWorkerBehaviorProps = 7809936,
	CWorkerFleeBehaviorProps = 7809632,
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
DisplayBehaviors = {
	CDisplayBehaviorMovement = 8055460,
}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Modifiers = {
	Speed		= 0,
	Exploration	= 1,
	Hitpoints	= 2,
	Damage		= 3,
	Armor		= 4,
	DodgeChance	= 5,
	MaxRange	= 6,
	MinRange	= 7,
	DamageBonus	= 8,
	GroupLimit	= 9,
}
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- behaviors
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- use simis func if available
if CUtil then
	
	function Memory.GetEntityBehavior( _EntityId, _Behavior )
		local behavioraddress = tonumber( CUtil.GetBehaviour( _EntityId, _Behavior ), 16 )
		if behavioraddress ~= 0 then
			return Memory.GetMemory( behavioraddress )
		end
	end
else
	
	function Memory.GetEntityBehavior( _EntityId, _Behavior )
		
		if Logic.IsEntityAlive( _EntityId ) then
			
			local entityadress = Memory.GetEntityMem( _EntityId )
			
			local startadress = entityadress[ 31 ]
			local endadress = entityadress[ 32 ]
			local lastindex = ( endadress:GetInt() - startadress:GetInt() ) / 4 - 1
			
			for i = 0, lastindex do
				
				local behavioraddress = startadress[ i ]
				
				if behavioraddress:GetInt() ~= 0 and behavioraddress[ 0 ]:GetInt() == _Behavior then
					return behavioraddress
				end
			end
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityBehaviorProperties( _EntityId, _Behavior )
	return Memory.GetEntityTypeBehaviorProperties( Logic.GetEntityType( _EntityId ), _Behavior )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityTypeBehaviorProperties( _EntityType, _Behavior )
	
	if _EntityType ~= 0 then
		
		local entitytypeadress = Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ _EntityType ]
		
		local startadress = entitytypeadress[ 26 ]
		local endadress = entitytypeadress[ 27 ]
		local lastindex = ( endadress:GetInt() - startadress:GetInt() ) / 4 - 1
		
		for i = 0, lastindex do
			
			local behavioraddress = startadress[ i ]
			
			if behavioraddress:GetInt() ~= 0 and behavioraddress[ 0 ]:GetInt() == _Behavior then
				return behavioraddress
			end
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityDisplayBehavior( _EntityId, _Behavior )

	local ed = Memory.GetMemory( tonumber( "0x8581EC", 16 ) )[ 0 ][ 19 ][ 4 + CUtilBit32.BitAnd( _EntityId, 65535 ) ]

	if ed:GetInt() ~= 0 then
		local startadress = ed[ 8 ]
		local endadress = ed[ 9 ]
		local lastindex = ( endadress:GetInt() - startadress:GetInt() ) / 4 - 1
		
		for i = 0, lastindex do
			
			local behavioraddress = startadress[ i ]
			
			if behavioraddress:GetInt() ~= 0 and behavioraddress[ 0 ]:GetInt() == _Behavior then
				return behavioraddress
			end
		end
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- technologies
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetEntityModifierTechnologies( _EntityId, _Modifier )
	return Memory.GetEntityTypeModifierTechnologies( Logic.GetEntityType( _EntityId ), _Modifier )
end
function Memory.GetEntityTypeModifierTechnologies( _EntityType, _Modifier )
	
	local techs = {}
	local offsets = {
		[ Modifiers.Exploration ]	=  88,
		[ Modifiers.Hitpoints ]		=  93,
		[ Modifiers.Speed ]			=  98,
		[ Modifiers.Damage ]		= 103,
		[ Modifiers.Armor ]			= 108,
		[ Modifiers.DodgeChance ]	= 113,
		[ Modifiers.MaxRange ]		= 118,
		[ Modifiers.MinRange ]		= 123,
		[ Modifiers.DamageBonus ]	= 128,
		[ Modifiers.GroupLimit ]	= 133,
	}
	local offset = offsets[ _Modifier ]
	
	if _EntityType ~= 0 and offset then
	
		local entitytypeadress = Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ _EntityType ]
		
		local startadress = entitytypeadress[ offset ]
		local endadress = entitytypeadress[ offset + 1 ]
		local lastindex = ( endadress:GetInt() - startadress:GetInt() ) / 4 - 1
		
		for i = 0, lastindex do
			table.insert( techs, startadress[ i ]:GetInt() )
		end
	end
	
	return techs
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetTechnologyModifierValue( _Technology, _Modifier )
	
	local offsets = {
		[ Modifiers.Exploration ]	=  48,
		[ Modifiers.Speed ]			=  56,
		[ Modifiers.Hitpoints ]		=  64,
		[ Modifiers.Damage ]		=  72,
		[ Modifiers.DamageBonus ]	=  80,
		[ Modifiers.MaxRange ]		=  88,
		[ Modifiers.MinRange ]		=  96,
		[ Modifiers.Armor ]			= 104,
		[ Modifiers.DodgeChance ]	= 112,
		[ Modifiers.GroupLimit ]	= 120,
	}
	local offset = offsets[ _Modifier ]
	
	if offset then
		return Memory.GetMemory( 8758176 )[ 0 ][ 13 ][ 1 ][ _Technology - 1 ][ offset ]:GetFloat()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.SetTechnologyModifierValue( _Technology, _Modifier, _Value )
	
	local offsets = {
		[ Modifiers.Exploration ]	=  48,
		[ Modifiers.Speed ]			=  56,
		[ Modifiers.Hitpoints ]		=  64,
		[ Modifiers.Damage ]		=  72,
		[ Modifiers.DamageBonus ]	=  80,
		[ Modifiers.MaxRange ]		=  88,
		[ Modifiers.MinRange ]		=  96,
		[ Modifiers.Armor ]			= 104,
		[ Modifiers.DodgeChance ]	= 112,
		[ Modifiers.GroupLimit ]	= 120,
	}
	local offset = offsets[ _Modifier ]
	
	if offset then
		return Memory.GetMemory( 8758176 )[ 0 ][ 13 ][ 1 ][ _Technology - 1 ][ offset ]:SetFloat( _Value )
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- speed
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetEntityMovementBehavior( _EntityId )

	local behaviors = {
		Behaviors.CLeaderMovement,
		Behaviors.CSettlerMovement,
		Behaviors.CSoldierMovement,
	}
	
	for _, behavior in ipairs( behaviors ) do
		
		local movementbehavior = Memory.GetEntityBehavior( _EntityId, behavior )

		if movementbehavior then
			return movementbehavior
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityBaseMovementSpeed( _EntityId )
	
	local movementbehavior = Memory.GetEntityMovementBehavior( _EntityId )
		
	if movementbehavior then
		return movementbehavior[ 5 ]:GetFloat(), movementbehavior[ 7 ]:GetFloat()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityMovementSpeed( _EntityId )
	
	if Logic.IsSettler( _EntityId ) == 1 and Memory.GetEntityMem( _EntityId )[88]:GetInt() == 0 then
		return Memory.GetEntityMem( _EntityId )[89]:GetFloat()
	end

	local speed, factor = Memory.GetEntityBaseMovementSpeed( _EntityId )
	
	if speed then
		
		local techs = Memory.GetEntityModifierTechnologies( _EntityId, Modifiers.Speed )
		local player = GetPlayer( _EntityId )
		
		for _, tech in ipairs( techs ) do
			if Logic.GetTechnologyState( player, tech ) == 4 then
				speed = speed + Memory.GetTechnologyModifierValue( tech, Modifiers.Speed )
			end
		end
		
		return speed * factor
	end
	
	return 0
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetEntitiyCamperRange( _EntityId )
	
	local camperbehaviorprops = Memory.GetEntityBehaviorProperties( _EntityId, BehaviorProperties.CCamperBehaviorProperties )
	
	if camperbehaviorprops then
		return camperbehaviorprops[ 4 ]:GetFloat()
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- healing
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetEntityHealingPointsAndSeconds( _EntityId )
	Memory.GetEntityTypeHealingPointsAndSeconds( Logic.GetEntityType( _EntityId ) )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityTypeHealingPointsAndSeconds( _EntityType )
	
	local behaviors = {
		BehaviorProperties.CLeaderBehaviorProps,
		BehaviorProperties.CBattleSerfBehaviorProps,
	}
	
	for _, behavior in ipairs( behaviors ) do
		
		local battlebehavior = Memory.GetEntityTypeBehaviorProperties( _EntityType, behavior )
		
		if battlebehavior then
			return battlebehavior[28]:GetInt(), battlebehavior[29]:GetInt()
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityTypeMaxAttackRange( _EntityType )
	return Memory.GetLeaderMaxAttackRange( _EntityType ) or Memory.GetAutoCannonMaxAttackRange( _EntityType )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetLeaderMaxAttackRange( _LeaderType )

	local maxrange = Memory.GetEntityTypeBehaviorProperties( _LeaderType, BehaviorProperties.CLeaderBehaviorProps )

	if maxrange then
		return maxrange[23]:GetFloat()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetAutoCannonMaxAttackRange( _AutoCannonType )

	local maxrange = Memory.GetEntityTypeBehaviorProperties( _AutoCannonType, BehaviorProperties.CAutoCannonBehaviorProps )
	
	if maxrange then
		return maxrange[11]:GetFloat()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetEntityTypeDamageRange( _EntityType )
	return Memory.GetLeaderMaxAttackRange( _EntityType ) or Memory.GetAutoCannonMaxAttackRange( _EntityType )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetLeaderDamageRange( _LeaderType )

	local maxrange = Memory.GetEntityTypeBehaviorProperties( _LeaderType, BehaviorProperties.CLeaderBehaviorProps )

	if maxrange then
		return maxrange[16]:GetFloat()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetAutoCannonDamageRange( _AutoCannonType )

	local maxrange = Memory.GetEntityTypeBehaviorProperties( _AutoCannonType, BehaviorProperties.CAutoCannonBehaviorProps )
	
	if maxrange then
		return maxrange[15]:GetFloat()
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- resources
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetSerfExtractionDelayAndAmount( _ResourceEntityType, _EntityType )
	
	-- only for modding compatibility (eg if there are multiple types of serfs)
	_EntityType = _EntityType or Entities.PU_Serf
	
	-- get entity type if _ResourceEntityType is an entity id
	if _ResourceEntityType > 65000 then
		_ResourceEntityType = Logic.GetEntityType( _ResourceEntityType )
	end
	
	local serfbehaviorprops = Memory.GetEntityTypeBehaviorProperties( _EntityType, BehaviorProperties.CSerfBehaviorProps )
	
	if serfbehaviorprops then
		
		local startadress = serfbehaviorprops[ 8 ]
		local endadress = serfbehaviorprops[ 9 ]
		local lastindex = ( endadress:GetInt() - startadress:GetInt() ) / 4 - 1
		
		for i = 0, lastindex, 3 do
			if startadress[ i ]:GetInt() == _ResourceEntityType then
				return startadress[ i + 1 ]:GetFloat(), startadress[ i + 2 ]:GetInt()
			end
		end
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- buildings
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetBuildingBaseMiningValue( _BuildingId )
	
	local minebehaviorprops = Memory.GetEntityBehaviorProperties( _BuildingId, BehaviorProperties.CMineBehaviorProperties )
	
	if minebehaviorprops then
		return minebehaviorprops[ 4 ]:GetInt()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetBuildingBaseRefiningValue( _BuildingId )
	
	local refinerbehaviorprops = Memory.GetEntityBehaviorProperties( _BuildingId, BehaviorProperties.CResourceRefinerBehaviorProperties )
	
	if refinerbehaviorprops then
		return refinerbehaviorprops[ 5 ]:GetFloat(), refinerbehaviorprops[ 4 ]:GetInt()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetBuildingAproachAndDoorPosition( _BuildingId )
	
	local position = GetPosition( _BuildingId )
	local xa, ya, xd, yd = Memory.GetBuildingTypeAproachAndDoorPosition( Logic.GetEntityType( _BuildingId ) )
	
	if xa then
		return position.X + xa, position.Y + ya, position.X + xd, position.Y + yd
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetBuildingTypeAproachAndDoorPosition( _BuildingType )
	
	if _BuildingType ~= 0 then
		
		local entitytypeadress = Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ _BuildingType ]
		
		return entitytypeadress[ 7 ]:GetFloat(), entitytypeadress[ 8 ]:GetFloat(), entitytypeadress[ 46 ]:GetFloat(), entitytypeadress[ 47 ]:GetFloat()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetBuildingMaxNumWorkers( _BuildingId )
	
	if Logic.IsEntityAlive( _BuildingId ) then
		return Memory.GetEntityMem( _BuildingId )[ 72 ]:GetInt()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.SetBuildingMaxNumWorkers( _BuildingId, _Amount )
	
	if Logic.IsEntityAlive( _BuildingId ) then
		Memory.GetEntityMem( _BuildingId )[ 72 ]:SetInt( _Amount )
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- workers
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetRefinerRawResourceType( _WorkerId )
	
	local workerbehaviorprops = Memory.GetEntityBehaviorProperties( _WorkerId, BehaviorProperties.CWorkerBehaviorProps )
	
	if workerbehaviorprops then
		return workerbehaviorprops[ 27 ]:GetInt()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetRefinerTransportAmount( _WorkerId )
	
	local workerbehaviorprops = Memory.GetEntityBehaviorProperties( _WorkerId, BehaviorProperties.CWorkerBehaviorProps )
	
	if workerbehaviorprops then
		return workerbehaviorprops[ 24 ]:GetInt()
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetWorkerWorkWaitUntil( _WorkerId )
	
	local workerbehaviorprops = Memory.GetEntityBehaviorProperties( _WorkerId, BehaviorProperties.CWorkerBehaviorProps )
	
	if workerbehaviorprops then
		return workerbehaviorprops[ 7 ]:GetInt()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetWorkerWorkTimeChangeWork( _WorkerId )
	
	local workerbehaviorprops = Memory.GetEntityBehaviorProperties( _WorkerId, BehaviorProperties.CWorkerBehaviorProps )
	
	if workerbehaviorprops then
		return workerbehaviorprops[ 17 ]:GetInt()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetWorkerWorkTimeChangeFarmAndMax( _WorkerId )
	
	local workerbehaviorprops = Memory.GetEntityBehaviorProperties( _WorkerId, BehaviorProperties.CWorkerBehaviorProps )
	
	if workerbehaviorprops then
		return workerbehaviorprops[ 18 ]:GetFloat(), workerbehaviorprops[ 21 ]:GetInt()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetWorkerWorkTimeChangeResidenceAndMax( _WorkerId )
	
	local workerbehaviorprops = Memory.GetEntityBehaviorProperties( _WorkerId, BehaviorProperties.CWorkerBehaviorProps )
	
	if workerbehaviorprops then
		return workerbehaviorprops[ 19 ]:GetFloat(), workerbehaviorprops[ 22 ]:GetInt()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetWorkerWorkTimeChangeCamp( _WorkerId )
	
	local workerbehaviorprops = Memory.GetEntityBehaviorProperties( _WorkerId, BehaviorProperties.CWorkerBehaviorProps )
	
	if workerbehaviorprops then
		return workerbehaviorprops[ 20 ]:GetFloat()
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- thiefs
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function CamouflageThief( _ThiefId )
	
	local behavior = Memory.GetEntityBehavior( _ThiefId, Behaviors.CThiefCamouflageBehavior )
	
	if behavior then
		
		--> 0 "aufgedeckt", 15 "nicht aufgedeckt"
		Memory.GetMemory( behavior + 32 )[ 0 ]:SetInt( 15 )
		
		--> Aufgedeckte Zeit in Sekunden
		Memory.GetMemory( behavior + 36 )[ 0 ]:SetInt( 0 )
		
		return true
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function DecamouflageThief( _ThiefId )
	
	local behavior = Memory.GetEntityBehavior( _ThiefId, Behaviors.CThiefCamouflageBehavior )
	
	if behavior then
		
		--> 0 "aufgedeckt", 15 "nicht aufgedeckt"
		CUtilMemory.GetMemory( behavior + 32 )[ 0 ]:SetInt( 0 )
		
		return true
	end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function DecamouflageThiefForPeriod( _ThiefId, _TimeInSeconds )
	
	local behavior = Memory.GetEntityBehavior( _ThiefId, Behaviors.CThiefCamouflageBehavior )
	
	if behavior then
		
		--> 0 "aufgedeckt", 15 "nicht aufgedeckt"
		CUtilMemory.GetMemory( behavior + 32 )[ 0 ]:SetInt( 0 )
		
		--> Aufgedeckte Zeit in Sekunden
		CUtilMemory.GetMemory( behavior + 36 )[ 0 ]:SetInt( _TimeInSeconds )
		
		return true
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- players
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetPlayerState( _PlayerId )
	return Memory.GetMemory( 8758176 )[ 0 ][ 10 ][ _PlayerId * 2 + 1 ]
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.ResetPayday( _PlayerId )
	
	local playerstate = Memory.GetPlayerState( _PlayerId )
	
	-- 197 in player
	-- 3 in player attraction handler
	playerstate[ 197 ][ 3 ]:SetInt( Logic.GetCurrentTurn() )
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- logic
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.GetWorkTimeThresholds()
	
	local logicproperties = Memory.GetMemory( 8758240 )[ 0 ]
	
	return logicproperties[ 74 ]:GetInt(), logicproperties[ 75 ]:GetInt()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetMaxDistanceWorkplaceToFarm()
	return Memory.GetMemory( 8809088)[ 0 ][ 6 ]:GetFloat()
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.GetMaxDistanceWorkplaceToResidence()
	return Memory.GetMemory( 8809088)[ 0 ][ 7 ]:GetFloat()
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--int newptr = S5Hook.ReAllocMem( ptr as int, newSize in bytes )
--[[
-- add speed tech
ptr = S5Hook.ReAllocMem( Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 98 ]:GetInt(), 8 )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 98 ]:SetInt( ptr )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 99 ]:SetInt( ptr + 8 )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 100 ]:SetInt( ptr + 8 )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 98 ][ 1 ]:SetInt( 129 )

-- add armor tech
ptr = S5Hook.ReAllocMem( Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 108 ]:GetInt(), 8 )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 108 ]:SetInt( ptr )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 109 ]:SetInt( ptr + 8 )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 110 ]:SetInt( ptr + 8 )
Memory.GetMemory( 9002416 )[ 0 ][ 7 ][ Entities.PU_Serf ][ 108 ][ 1 ]:SetInt( Technologies.T_SoftArcherArmor )


-- create new tech
ptr = S5Hook.ReAllocMem( 0, 516 )
Memory.GetMemory( 8758176 )[ 0 ][ 13 ][ 1 ][ 199 ]:SetInt( ptr )

ptr2 = Memory.GetMemory( 8758176 )[ 0 ][ 13 ][ 2 ]:GetInt()
Memory.GetMemory( 8758176 )[ 0 ][ 13 ][ 2 ]:SetInt( ptr2 + 4 )
]]
function Memory.SetTechnology()
	
	local tech = Memory.GetMemory( 8758176 )[ 0 ][ 13 ][ 1 ][ 199 ]
	
	tech[ 0 ]:SetInt( 9 ) -- tech cat
	tech[ 1 ]:SetFloat( 9 ) -- time to research
	tech[ 2 ]:SetInt( 0 ) -- auto research
	tech[ 3 ]:SetFloat( 0 ) -- time to research
	
	tech[ 4 ]:SetFloat( 0 ) -- costs
	tech[ 5 ]:SetFloat( 0 ) -- costs
	tech[ 6 ]:SetFloat( 0 ) -- costs
	tech[ 7 ]:SetFloat( 0 ) -- costs
	tech[ 8 ]:SetFloat( 0 ) -- costs
	tech[ 9 ]:SetFloat( 0 ) -- costs
	tech[ 10 ]:SetFloat( 0 ) -- costs
	tech[ 11 ]:SetFloat( 0 ) -- costs
	tech[ 12 ]:SetFloat( 0 ) -- costs
	tech[ 13 ]:SetFloat( 0 ) -- costs
	tech[ 14 ]:SetFloat( 0 ) -- costs
	tech[ 15 ]:SetFloat( 0 ) -- costs
	tech[ 16 ]:SetFloat( 0 ) -- costs
	tech[ 17 ]:SetFloat( 0 ) -- costs
	tech[ 18 ]:SetFloat( 0 ) -- costs
	tech[ 19 ]:SetFloat( 0 ) -- costs
	tech[ 20 ]:SetFloat( 0 ) -- costs
	
	tech[ 21 ]:SetInt( 0 ) -- req tech
	tech[ 22 ]:SetInt( 0 ) -- 
	tech[ 23 ]:SetInt( 0 ) -- 
	tech[ 24 ]:SetInt( 0 ) -- 
	tech[ 25 ]:SetInt( 0 ) -- 
	tech[ 26 ]:SetInt( 0 ) -- req entity
	tech[ 27 ]:SetInt( 0 ) -- 
	tech[ 28 ]:SetInt( 0 ) -- 
	tech[ 29 ]:SetInt( 0 ) -- 
	tech[ 30 ]:SetInt( 0 ) -- 
	tech[ 31 ]:SetInt( 0 ) -- req ecat
	tech[ 32 ]:SetInt( 0 ) -- 
	tech[ 33 ]:SetInt( 0 ) -- 
	tech[ 34 ]:SetInt( 0 ) -- 
	tech[ 35 ]:SetInt( 0 ) -- 
	tech[ 36 ]:SetInt( 0 ) -- req ucat
	tech[ 37 ]:SetInt( 0 ) -- 
	tech[ 38 ]:SetInt( 0 ) -- 
	tech[ 39 ]:SetInt( 0 ) -- 
	tech[ 40 ]:SetInt( 0 ) -- 
	
	Memory.SetString( tech, 41, "" ) -- effect script ?
	
	tech[ 48 ]:SetFloat( 0 )
	Memory.SetString( tech, 49, "" ) -- Exploration
	
	tech[ 56 ]:SetFloat( 500 )
	Memory.SetString( tech, 57, "+" ) -- Speed
	
	tech[ 64 ]:SetFloat( 0 )
	Memory.SetString( tech, 65, "" ) -- Hitpoints
	
	tech[ 72 ]:SetFloat( 0 )
	Memory.SetString( tech, 73, "" ) -- Damage
	
	tech[ 80 ]:SetFloat( 0 )
	Memory.SetString( tech, 81, "" ) -- DamageBonus
	
	tech[ 88 ]:SetFloat( 0 )
	Memory.SetString( tech, 89, "" ) -- MaxRange
	
	tech[ 96 ]:SetFloat( 0 )
	Memory.SetString( tech, 97, "" ) -- MinRange
	
	tech[ 104 ]:SetFloat( 0 )
	Memory.SetString( tech, 105, "" ) -- Armor
	
	tech[ 112 ]:SetFloat( 0 )
	Memory.SetString( tech, 113, "" ) -- DodgeChance
	
	tech[ 120 ]:SetFloat( 0 )
	Memory.SetString( tech, 121, "" ) -- GroupLimit
	
	tech[ 128 ]:SetInt( 0 ) -- use for statistics
end
-- supports only 1 character atm
function Memory.SetString( _Object, _Offset, _String )
	
	local numbers = {
		["*"] = 42,
		["+"] = 43,
		["-"] = 45,
		--["/"] = 47,
	}
	
	local number = numbers[ _String ] or 43
	
	_Object[ _Offset ]:SetInt( 0 ) -- dbg
	_Object[ _Offset + 1 ]:SetInt( number ) -- actual string
	_Object[ _Offset + 2 ]:SetInt( 0 )
	_Object[ _Offset + 3 ]:SetInt( 0 )
	_Object[ _Offset + 4 ]:SetInt( 0 )
	_Object[ _Offset + 5 ]:SetInt( 1 ) -- character amount
	_Object[ _Offset + 6 ]:SetInt( 15 ) -- ?
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- asm manipulation
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.SetMemory( _Address, _Offset, _Value )
	
	-- convert address to dez number if needed
	if type( _Address ) == "string" then
		_Address = tonumber( _Address, 16 )
	end
	
	-- convert address to dez number if needed
	if type( _Value ) == "string" then
		_Value = tonumber( _Value, 16 )
	end
	
	-- create backup of original value
	if not Memory.Saved[ _Address ] then
		Memory.Saved[ _Address ] = Memory.GetMemory( _Address )[ 0 ]:GetByte( _Offset )
	end
	
	Memory.GetMemory( _Address )[ 0 ]:SetByte( _Offset, _Value )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.Reset()
	for address, value in pairs( Memory.Saved ) do
		Memory.GetMemory( address )[ 0 ]:SetByte( 0, value )
	end
end
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
function Memory.EnableCustomRefineAmount()
	
	--mov eax, [eax + F8h] # sv4 at 62 * 4 = 248
	Memory.SetMemory( "4E122B", 0, "8B" )
	Memory.SetMemory( "4E122B", 1, "80" )
	Memory.SetMemory( "4E122B", 2, "F8" )
	Memory.SetMemory( "4E122B", 3, "00" )
	Memory.SetMemory( "4E122B", 4, "00" )
	Memory.SetMemory( "4E122B", 5, "00" )

	--test eax, eax # is sv4 != 0
	Memory.SetMemory( "4E1231", 0, "85" )
	Memory.SetMemory( "4E1231", 1, "C0" )

	--jnz 0x4E1238 # jump if tested register is != 0
	Memory.SetMemory( "4E1233", 0, "75" )
	Memory.SetMemory( "4E1233", 1, "03" )

	--mov eax, [esi + 14h]
	Memory.SetMemory( "4E1235", 0, "8B" )
	Memory.SetMemory( "4E1235", 1, "46" )
	Memory.SetMemory( "4E1235", 2, "14" )

	--mov [ebp-4], eax # set return value
	Memory.SetMemory( "4E1238", 0, "89" )
	Memory.SetMemory( "4E1238", 1, "45" )
	Memory.SetMemory( "4E1238", 2, "FC" )

	--jmp 0x4E1284 # jump to end of function
	Memory.SetMemory( "4E123B", 0, "EB" )
	Memory.SetMemory( "4E123B", 1, "47" )
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Memory.EnableBlockingUpdateWeatherChange()
	
	-- override GUI.DEBUG_ActivateUpgradeSingleBuildingState at 0x5381CB
	
	--5381CB | A1 AC5D8900 | mov eax,dword ptr ds:[895DAC]
	Memory.SetMemory( "5381CB", 0, "A1" )
	Memory.SetMemory( "5381CB", 1, "AC" )
	Memory.SetMemory( "5381CB", 2, "5D" )
	Memory.SetMemory( "5381CB", 3, "89" )
	Memory.SetMemory( "5381CB", 4, "00" )
	--5381D0 | 8B48 24	 | mov ecx,dword ptr ds:[eax+24]
	Memory.SetMemory( "5381D0", 0, "8B" )
	Memory.SetMemory( "5381D0", 1, "48" )
	Memory.SetMemory( "5381D0", 2, "24" )
	--5381D3 | 6A 00	   | push 0
	Memory.SetMemory( "5381D3", 0, "6A" )
	Memory.SetMemory( "5381D3", 1, "01" )
	--5381D5 | E8 39140400 | call settlershok.579613
	Memory.SetMemory( "5381D5", 0, "E8" )
	Memory.SetMemory( "5381D5", 1, "39" )
	Memory.SetMemory( "5381D5", 2, "14" )
	Memory.SetMemory( "5381D5", 3, "04" )
	Memory.SetMemory( "5381D5", 4, "00" )
	--5381DA | 33C0		| xor eax,eax
	Memory.SetMemory( "5381DA", 0, "33" )
	Memory.SetMemory( "5381DA", 1, "C0" )
	--5381DC | C3		  | ret
	Memory.SetMemory( "5381DC", 0, "C3" )
	-- fill rest of func with ret for readability in debugger
	Memory.SetMemory( "5381DD", 0, "C3" )
	Memory.SetMemory( "5381DE", 0, "C3" )
	Memory.SetMemory( "5381DF", 0, "C3" )
	Memory.SetMemory( "5381E0", 0, "C3" )
	Memory.SetMemory( "5381E1", 0, "C3" )
	Memory.SetMemory( "5381E2", 0, "C3" )
	Memory.SetMemory( "5381E3", 0, "C3" )
	Memory.SetMemory( "5381E4", 0, "C3" )
	Memory.SetMemory( "5381E5", 0, "C3" )
	Memory.SetMemory( "5381E6", 0, "C3" )
	
	-- make func
	Memory.BlockingUpdateWeatherChange = GUI.DEBUG_ActivateUpgradeSingleBuildingState
end