--------------------------------------------------------------------------------
MPW.OSI.Technologies = {}
--------------------------------------------------------------------------------
function MPW.OSI.Technologies.PostInit( _TexturePath, _X, _Y, _W, _H )
	table.insert( MPW.OSI.DrawCalls, MPW.OSI.Technologies.DrawCall )
end
--------------------------------------------------------------------------------
function MPW.OSI.Technologies.PostLoad( _TexturePath, _X, _Y, _W, _H )
	MPW.OSI.Technologies.Image = S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_techstar" )
end
--------------------------------------------------------------------------------
function MPW.OSI.Technologies.DrawCall( _Id, _Active, _X, _Y )
	
	if Logic.IsLeader( _Id ) == 1 and Logic.IsHero( _Id ) == 0 then
	
		local amount = MPW.OSI.Technologies.GetAmountOfResearchedCombatTechnologiesForLeader( _Id )
		
		for i = 1, amount do
			S5Hook.OSIDrawImage( MPW.OSI.Technologies.Image, _X - 8, _Y - 12, 9, 9 )
			_X = _X + 7
		end
	end
end
--------------------------------------------------------------------------------
function MPW.OSI.Technologies.GetAmountOfResearchedCombatTechnologiesForLeader( _Id )
	
	local lut  = MPW.OSI.Technologies.LUT[ Logic.GetEntityType( _Id ) ]
	
	if lut then
		local player = GetPlayer( _Id )
		local amount = 0
		
		for _, technology in pairs( lut ) do
			if Logic.GetTechnologyState( player, technology ) == 4 then
				amount = amount + 1
			end
		end
	
		return amount
	end
	
	return 0
end
--------------------------------------------------------------------------------
-- predefined technology sets, which give one star each
--------------------------------------------------------------------------------
MPW.OSI.Technologies.Sets = {
	Sword = {
		Technologies.T_IronCasting,
		Technologies.T_MasterOfSmithery,
		Technologies.T_LeatherMailArmor,
		Technologies.T_ChainMailArmor,
		Technologies.T_PlateMailArmor,
	},
	PoleArm = {
		Technologies.T_WoodAging,
		Technologies.T_Turnery,
		Technologies.T_SoftArcherArmor,
		Technologies.T_PaddedArcherArmor,
		Technologies.T_LeatherArcherArmor,
	},
	Bow = {
		Technologies.T_Fletching,
		Technologies.T_BodkinArrow,
		Technologies.T_SoftArcherArmor,
		Technologies.T_PaddedArcherArmor,
		Technologies.T_LeatherArcherArmor,
	},
	Rifle = {
		Technologies.T_LeadShot,
		Technologies.T_Sights,
		Technologies.T_FleeceArmor,
		Technologies.T_FleeceLinedLeatherArmor,
	},
	Cannon = {
		Technologies.T_EnhancedGunPowder,
		Technologies.T_BlisteringCannonballs,
	},
}
--------------------------------------------------------------------------------
-- which technology set to use for which soldier ucat (soldier, because this is the only simple way to get a ucat from a leader entity id)
--------------------------------------------------------------------------------
MPW.OSI.Technologies.LUT = {
	[Entities.PU_LeaderSword1]			= MPW.OSI.Technologies.Sets.Sword,
	[Entities.PU_LeaderSword2]			= MPW.OSI.Technologies.Sets.Sword,
	[Entities.PU_LeaderSword3]			= MPW.OSI.Technologies.Sets.Sword,
	[Entities.PU_LeaderSword4]			= MPW.OSI.Technologies.Sets.Sword,
	[Entities.PU_LeaderRifle1]			= MPW.OSI.Technologies.Sets.Rifle,
	[Entities.PU_LeaderRifle2]			= MPW.OSI.Technologies.Sets.Rifle,
	[Entities.PU_LeaderPoleArm1]		= MPW.OSI.Technologies.Sets.PoleArm,
	[Entities.PU_LeaderPoleArm2]		= MPW.OSI.Technologies.Sets.PoleArm,
	[Entities.PU_LeaderPoleArm3]		= MPW.OSI.Technologies.Sets.PoleArm,
	[Entities.PU_LeaderPoleArm4]		= MPW.OSI.Technologies.Sets.PoleArm,
	[Entities.PU_LeaderBow1]			= MPW.OSI.Technologies.Sets.Bow,
	[Entities.PU_LeaderBow2]			= MPW.OSI.Technologies.Sets.Bow,
	[Entities.PU_LeaderBow3]			= MPW.OSI.Technologies.Sets.Bow,
	[Entities.PU_LeaderBow4]			= MPW.OSI.Technologies.Sets.Bow,
	[Entities.PU_LeaderHeavyCavalry1]	= MPW.OSI.Technologies.Sets.Sword,
	[Entities.PU_LeaderHeavyCavalry2]	= MPW.OSI.Technologies.Sets.Sword,
	[Entities.PU_LeaderCavalry1]		= MPW.OSI.Technologies.Sets.Bow,
	[Entities.PU_LeaderCavalry2]		= MPW.OSI.Technologies.Sets.Bow,
	[Entities.PV_Cannon1]				= MPW.OSI.Technologies.Sets.Cannon,
	[Entities.PV_Cannon2]				= MPW.OSI.Technologies.Sets.Cannon,
	[Entities.PV_Cannon3]				= MPW.OSI.Technologies.Sets.Cannon,
	[Entities.PV_Cannon4]				= MPW.OSI.Technologies.Sets.Cannon,
}