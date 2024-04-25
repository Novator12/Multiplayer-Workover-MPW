--------------------------------------------------------------------------------
MPW.OSI.HeroTroops = {}
--------------------------------------------------------------------------------
function MPW.OSI.HeroTroops.PostInit()
	
	table.insert( MPW.OSI.DrawCalls, MPW.OSI.HeroTroops.DrawCall )
end
--------------------------------------------------------------------------------
function MPW.OSI.HeroTroops.DrawCall( _Id, _Active, _X, _Y )
	
	-- Varg
	if Logic.IsLeader( _Id ) == 1 and Logic.GetEntityType( _Id ) == Entities.PU_Hero9_LeaderWolf then
		
		if Logic.GetSoldiersAttachedToLeader( _Id ) == 0 then
			S5Hook.OSIDrawText("Alphawolf", 3, _X - 8, _Y - 28, 255, 255, 255, 255)
		else
			S5Hook.OSIDrawText("Wolfsrudel", 3, _X - 8, _Y - 28, 255, 255, 255, 255)
		end
	
	-- -- Ari
	-- elseif Logic.IsLeader( _Id ) == 1 and ( Logic.GetEntityType( _Id ) == Entities.PU_Hero5_LeaderBanditSword or Logic.GetEntityType( _Id ) == Entities.PU_Hero5_LeaderBanditBow ) then
		
	-- 	if Logic.GetSoldiersAttachedToLeader( _Id ) == 0 then
	-- 		S5Hook.OSIDrawText("Vogelfreier", 3, _X - 8, _Y - 28, 255, 255, 255, 255)
	-- 	else
	-- 		S5Hook.OSIDrawText("Banditen", 3, _X - 8, _Y - 28, 255, 255, 255, 255)
	-- 	end
	end
end