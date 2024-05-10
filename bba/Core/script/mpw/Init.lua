--------------------------------------------------------------------------------
MPW = {}
MPW.Version = 0.1
--------------------------------------------------------------------------------
-- call this function on first load of the map
--------------------------------------------------------------------------------
function MPW.Init()
	
	-- simis stuff is loaded in GameCallback_OnGameStart
	MPW.GameCallback_OnGameStart = GameCallback_OnGameStart
	GameCallback_OnGameStart = function()
		
		-- undo override
		GameCallback_OnGameStart = MPW.GameCallback_OnGameStart
		MPW.GameCallback_OnGameStart = nil

		-- load simis stuff first
		GameCallback_OnGameStart()
		
		-- load mpw overrides
		MPW.PostInit()
	end
	
	-- call unload func on leave map
	MPW.CloseGame = Framework.CloseGame
	Framework.CloseGame = function()
		MPW.Unload()
		MPW.CloseGame()
	end
	MPW.ExitGame = Framework.ExitGame
	Framework.ExitGame = function()
		MPW.Unload()
		MPW.ExitGame()
	end
	MPW.LoadGame = Framework.LoadGame
	Framework.LoadGame = function( _SaveGameFolder )
		MPW.Unload()
		MPW.LoadGame( _SaveGameFolder )
	end
	MPW.RestartMap = Framework.RestartMap
	Framework.RestartMap = function()
		MPW.Unload()
		MPW.RestartMap()
	end
	
	-- check if its an EMS map
	MPW.IsEMS = ( EMS ~= nil )
	
	local path = MPW_Debug and "MP_SettlerServer\\Mods\\MPW\\Ingame\\Core\\script\\mpw\\" or "data\\script\\mpw\\"
	
	-- load S5Hook if not yet done
	if not S5Hook then
		Script.Load( path .. "S5Hook.lua" )
	end
	if CNetwork then --or MPW_Debug then
		Script.Load( path .. "S5HookOSIReplacement.lua" )
		MPW.OSIReplacement.Init()
	end

	-- load trigger fix before other scripts - some need it
	Script.Load( path .. "TriggerFix.lua" )
	Script.Load("maps\\user\\EMS\\tools\\s5CommunityLib\\comfort\\other\\NextTick.lua")
	
	-- load scripts
	Script.Load( "MP_SettlerServer\\WidgetHelper.lua" )
	Script.Load( path .. "AttractionLimit.lua" )
	Script.Load( path .. "Camera.lua" )
	Script.Load( path .. "Defeat.lua" )
	Script.Load( path .. "EntityCategories.lua" )
	Script.Load( path .. "GUIAction.lua" )
	Script.Load( path .. "GUITooltip.lua" )
	Script.Load( path .. "GUIUpdate.lua" )
	Script.Load( path .. "Memory.lua" )
	Script.Load( path .. "Motivation.lua" )
	Script.Load( path .. "QOL.lua" )
	Script.Load( path .. "Weather.lua" )
	Script.Load( path .. "Widgets.lua" )
	
	-- init scripts
	MPW.AttractionLimit.Init()
	MPW.Camera.Init()
	MPW.EntityCategories.Init()
	MPW.Motivation.Init()
	MPW.Motivation.InitBuildingLimit()
	MPW.QOL.Init()
	MPW.Weather.Init()
	MPW.Widgets_Init()

	--Army implementation
	Script.Load( path .. "Memory.lua" )
	-- Script.Load( path .. "army\\army_init.lua")
	-- Script.Load( path .. "army\\army_comforts.lua")
	-- Script.Load( path .. "army\\army_chunk.lua" )
    -- Script.Load( path .. "army\\army_recruiter.lua")
    -- Script.Load( path .. "army\\army_astar_controller.lua")
	
	-- MPW.Army.Init()

	-- init modules
	MPW.Modules = {}

	if not MPW_Debug then
		Script.LoadFolder( path .. "modules\\" )
	else
		-- load modules manually here
		Script.Load( "MP_SettlerServer\\Mods\\MPW\\Ingame\\aoe\\script\\mpw\\modules\\aoe.lua" )
		Script.Load( "MP_SettlerServer\\Mods\\MPW\\Ingame\\aoe\\script\\mpw\\modules\\aoe_gui.lua" )
		Script.Load( "MP_SettlerServer\\Mods\\MPW\\Ingame\\CombatPlus\\script\\mpw\\modules\\CombatPlus.lua" )
		Script.Load( "MP_SettlerServer\\Mods\\MPW\\Ingame\\Territory\\script\\mpw\\modules\\Territory.lua" )
		--Script.Load( "MP_SettlerServer\\Mods\\MPW\\Ingame\\unlimited\\script\\mpw\\modules\\unlimited.lua" )
	end
	
	for _, name in pairs( MPW.Modules ) do
		if MPW[ name ].Init then
			MPW[ name ].Init()
		end
	end
	
	-- load savegame stuff
	MPW.Load()
end
--------------------------------------------------------------------------------
-- call this function on savegame load
--------------------------------------------------------------------------------
function MPW.Load()
	
	-- the safety check is now done by the hook itself
	InstallS5Hook()
	if CNetwork then --or MPW_Debug then
		MPW.OSIReplacement.Load()
	end

	-- init scripts
	MPW.AttractionLimit.Load()
	MPW.EntityCategories.Load()
	MPW.QOL.Load()
	MPW.Widgets_Load()
	
	-- load modules
	for _, name in pairs( MPW.Modules ) do
		if MPW[ name ].Load then
			MPW[ name ].Load()
		end
	end
end
--------------------------------------------------------------------------------
-- call this function on first load after simis stuff ( and EMS ) has loaded
--------------------------------------------------------------------------------
function MPW.PostInit()
	
	if CNetwork then --or MPW_Debug then
		MPW.OSIReplacement.PostInit()
	end
	
	local path = MPW_Debug and "MP_SettlerServer\\Mods\\MPW\\Ingame\\Core\\script\\mpw\\" or "data\\script\\mpw\\"
	
	-- load scripts
	Script.Load( path .. "GFXSets.lua" )
	Script.Load( path .. "HeroSummonHandler.lua" )
	Script.Load( path .. "OSI.lua" )
	Script.Load( path .. "Selection.lua" )
	Script.Load( path .. "ThiefLoot.lua" )
	Script.Load( path .. "Trading.lua" )
	
	-- init scripts
	MPW.AttractionLimit.PostInit()
	MPW.Camera.PostInit()
	MPW.Defeat.PostInit()
	MPW.HeroSummonHandler.PostInit() -- here because network handlers neeed to be setup after simis stuff has loaded
	MPW.OSI.PostInit()
	MPW.QOL.PostInit()
	MPW.ThiefLoot.PostInit() -- here because network handlers neeed to be setup after simis stuff has loaded
	MPW.Trading.PostInit()
	MPW.Weather.PostInit()
	
	-- init modules
	for _, name in pairs( MPW.Modules ) do
		if MPW[ name ].PostInit then
			MPW[ name ].PostInit()
		end
	end
	
	-- load savegame stuff
	MPW.PostLoad()
end
--------------------------------------------------------------------------------
-- call this function on savegame load after simis stuff ( and EMS ) has loaded
--------------------------------------------------------------------------------
function MPW.PostLoad()

	-- enable Simis aoe damage fix
	CEntity.EnableLogicAoEDamage()
	CEntity.EnableDamageClassAoEDamage()

	-- init scripts
	MPW.GFXSetHandler.PostLoad()
	MPW.OSI.PostLoad()
	MPW.QOL.PostLoad()
	MPW.Widgets_PostLoad()
	
	-- load modules
	for _, name in pairs( MPW.Modules ) do
		if MPW[ name ].PostLoad then
			MPW[ name ].PostLoad()
		end
	end
end
--------------------------------------------------------------------------------
-- call this function on restart, load, leave map or game
--------------------------------------------------------------------------------
function MPW.Unload()
	
	-- unload modules
	for _, name in pairs( MPW.Modules ) do
		if MPW[ name ].Unload then
			MPW[ name ].Unload()
		end
	end
end