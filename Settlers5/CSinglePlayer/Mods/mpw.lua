-- MainMenu only
if not MPW then
	local OnInitialize
	local OnGUILoaded
	--------------------------------------------------------------------------------
	local print = function(...)
		if LuaDebugger and LuaDebugger.Log then
			if table.getn(arg) > 1 then
				LuaDebugger.Log(arg)
			else
				LuaDebugger.Log(unpack(arg))
			end
		end
	end
	--------------------------------------------------------------------------------
	MPW = {}
	MPW.Modules = {
		Core = { Priority = 0 },
	}
	--------------------------------------------------------------------------------
	function OnInitialize()
		
		print( "MPW: OnInitialize" )
		
		-- push our widgets in front of the potential hd menu buttons
		for i = 0, 5 do
			CWidget.Transaction_AddRawWidgetsFromFile( "CSinglePlayer\\Mods\\MPW\\MainMenu\\OptionsMenu" .. i .. "0_ToModules.xml", "OptionsMenu" .. i .. "0_ToNetwork" )
		end
		
		CWidget.Transaction_AddRawWidgetsFromFile( "CSinglePlayer\\Mods\\MPW\\MainMenu\\MPWMenu.xml", "MPMenu77" )
		
		-- workaround for missing OnMapStart callback
		MPW.StartMap = Framework.StartMap
		Framework.StartMap = function( _MapName, _MapType, _CampaignName )
			OnMapStart()
			MPW.StartMap( _MapName, _MapType, _CampaignName )
		end
		MPW.LoadGame = Framework.LoadGame
		Framework.LoadGame = function( _SaveGame )
			OnMapStart()
			MPW.LoadGame( _SaveGame )
		end
		
		Script.Load( "CSinglePlayer\\Mods\\MPW\\MainMenu\\MPWMenu.lua" )
		MPW.LoadModules()
	end
	--------------------------------------------------------------------------------
	function OnGUILoaded()
		
		print( "MPW: OnGUILoaded" )
		
		-- right button name for each menu
		XGUIEng.SetText( "OptionsMenu00_ToModules", "@center «MPW Module»" )
		XGUIEng.SetText( "OptionsMenu10_ToModules", "@center «MPW Module»" )
		XGUIEng.SetText( "OptionsMenu20_ToModules", "@center «MPW Module»" )
		XGUIEng.SetText( "OptionsMenu30_ToModules", "@center «MPW Module»" )
		XGUIEng.SetText( "OptionsMenu40_ToModules", "@center «MPW Module»" )
		XGUIEng.SetText( "OptionsMenu50_ToModules", "@center «MPW Module»" )
		XGUIEng.SetText( "MPWMenu_ToModules", "@center «MPW Module»")
		
		-- mpw menu button names
		XGUIEng.SetText( "MPWMenu_Core", "@center Core" )
		
		-- init modules
		for name, _ in pairs( MPW.Modules ) do
			if MPW[ name ] and MPW[ name ].OnGUILoaded then
				MPW[ name ].OnGUILoaded()
			end
		end
		
		-- update buttons
		MPW.UpdateModuleButtons()
	end
	--------------------------------------------------------------------------------
	function OnMapStart()
		
		local modules = {}
		local priorities = {}
		
		-- get all modules to be loaded
		for name, mod in pairs( MPW.Modules ) do
			if MPW.IsModuleActive( name ) then
				
				local priority = mod.Priority or 1
				
				if not modules[ priority ] then
					modules[ priority ] = {}
					table.insert( priorities, priority )
				end
				
				table.insert( modules[ priority ], name )
			end
		end
		
		-- sort from lowest to highest priority
		table.sort(
			priorities,
			function( a, b )
				return a < b
			end
		)
		
		-- load module archives
		-- low priority modules will be loaded first and then be overloaded by higher priority modules
		for _, priority in ipairs( priorities ) do
			for _, name in pairs( modules[ priority ] ) do
				
				-- if normal load fails, try load with value as suffix if a module has multiple versions
				if not CMod.PushArchiveRelative("MP_SettlerServer\\Mods\\MPW\\Ingame\\" .. name .. ".bba") then
				
					local value = MPW.GetModuleValue( name )
					CMod.PushArchiveRelative("MP_SettlerServer\\Mods\\MPW\\Ingame\\" .. name .. value .. ".bba")
				end
				
				-- init modules
				if MPW[ name ] and MPW[ name ].OnMapStart then
					MPW[ name ].OnMapStart()
				end
			end
		end
	end
	--------------------------------------------------------------------------------
	local Callbacks = {
		
		OnInitialize = OnInitialize,
		OnGUILoaded = OnGUILoaded,
		
		-- not yet implemented by Simi
		--OnMapStart = OnMapStart,
		
		-- Metadata
		Name = "MPW",
	}
	--------------------------------------------------------------------------------
	ModLoader_Register( Callbacks )
end