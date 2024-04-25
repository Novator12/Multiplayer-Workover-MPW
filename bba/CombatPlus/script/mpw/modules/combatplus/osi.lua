--------------------------------------------------------------------------------
MPW.OSI.CombatPlus = {}
--------------------------------------------------------------------------------
function MPW.OSI.CombatPlus.PostInit()

	MPW.OSI.CombatPlus.ImageAxe = S5Hook.OSILoadImage( "graphics\\textures\\gui\\mo_emblem_axe" )
	MPW.OSI.CombatPlus.ImageCrossBow = S5Hook.OSILoadImage( "graphics\\textures\\gui\\mo_emblem_crossbow" )
	
	table.insert( MPW.OSI.DrawCalls, MPW.OSI.CombatPlus.DrawCall )
end
--------------------------------------------------------------------------------
function MPW.OSI.CombatPlus.DrawCall( _Id, _Active, _X, _Y )
	
    local entitytype = Logic.GetEntityType(_Id)
    local entitytypes = {Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategories.LeaderAxe)}

    for i = 2, entitytypes[1] + 1 do
        if entitytype == entitytypes[i] then
            S5Hook.OSIDrawImage( MPW.OSI.CombatPlus.ImageAxe, _X - 33, _Y - 16, 32, 32 )
            return
        end
    end

    entitytypes = {Logic.GetSettlerTypesInUpgradeCategory(UpgradeCategories.LeaderCrossBow)}

    for i = 2, entitytypes[1] + 1 do
        if entitytype == entitytypes[i] then
            S5Hook.OSIDrawImage( MPW.OSI.CombatPlus.ImageCrossBow, _X - 33, _Y - 16, 32, 32 )
            return
        end
    end
end
--------------------------------------------------------------------------------
-- predefined technology sets, which give one star each
--------------------------------------------------------------------------------
MPW.OSI.Technologies.Sets.Axe = {
    Technologies.T_IronCasting,
    Technologies.T_MasterOfSmithery,
    Technologies.T_LeatherMailArmor,
    Technologies.T_ChainMailArmor,
    Technologies.T_PlateMailArmor
}
MPW.OSI.Technologies.Sets.CrossBow = {
    Technologies.T_Fletching,
    Technologies.T_BodkinArrow,
    Technologies.T_SoftArcherArmor,
    Technologies.T_PaddedArcherArmor,
    Technologies.T_LeatherArcherArmor
}
table.insert(MPW.OSI.Technologies.Sets.Cannon, Technologies.T_ReinforcedChassis)
table.insert(MPW.OSI.Technologies.Sets.Cannon, Technologies.T_HardenedFrames)
--------------------------------------------------------------------------------
-- which technology set to use for which leader type
--------------------------------------------------------------------------------
MPW.OSI.Technologies.LUT[Entities.PU_LeaderAxe1] = MPW.OSI.Technologies.Sets.Axe
MPW.OSI.Technologies.LUT[Entities.PU_LeaderAxe2] = MPW.OSI.Technologies.Sets.Axe
MPW.OSI.Technologies.LUT[Entities.PU_LeaderAxe3] = MPW.OSI.Technologies.Sets.Axe
MPW.OSI.Technologies.LUT[Entities.PU_LeaderAxe4] = MPW.OSI.Technologies.Sets.Axe
MPW.OSI.Technologies.LUT[Entities.PU_LeaderCrossBow1] = MPW.OSI.Technologies.Sets.Bow
MPW.OSI.Technologies.LUT[Entities.PU_LeaderCrossBow2] = MPW.OSI.Technologies.Sets.Bow