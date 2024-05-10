-- onscreen information for researched combat technologies
-- requires S5Hook
--------------------------------------------------------------------------------
MPW.OSI = MPW.OSI or {}
--------------------------------------------------------------------------------
MPW.OSI.DrawCalls = MPW.OSI.DrawCalls or {}
--------------------------------------------------------------------------------
function MPW.OSI.PostInit()
	
	local path = MPW_Debug and "MP_SettlerServer\\Mods\\MPW\\Ingame\\Core\\script\\mpw\\" or "data\\script\\mpw\\"
	
	Script.Load( path .. "OSILeader.lua" )
	Script.Load( path .. "OSIHeroTroops.lua" )
	Script.Load( path .. "OSITechnologies.lua" )
	
	MPW.OSI.Leader.PostInit()
	MPW.OSI.HeroTroops.PostInit()
	MPW.OSI.Technologies.PostInit()
end
--------------------------------------------------------------------------------
function MPW.OSI.PostLoad()
	
	MPW.OSI.Leader.PostLoad()
	MPW.OSI.Technologies.PostLoad()

	S5Hook.OSISetDrawTrigger( MPW.OSI.DrawCall )
end
--------------------------------------------------------------------------------
function MPW.OSI.DrawCall( _Id, _Active, _X, _Y )
	
	-- flag is required for TAB
	if _Active or gvKeyBindings_OnScreenInformationFlag == 0 then
		
		for _, func in pairs( MPW.OSI.DrawCalls ) do
			
			func( _Id, _Active, _X, _Y )
		end
	end
end