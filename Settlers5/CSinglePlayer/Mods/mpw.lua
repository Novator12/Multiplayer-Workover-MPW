-- MainMenu only
if not MPW then
	local OnInitialize
	local OnGUILoaded
	--------------------------------------------------------------------------------
	MPW = {}
	MPW.Log = LuaDebugger.Log or function() end
	MPW.Core = { OnInitialize = function() return true end }
	MPW.Modules = {
		Core = {
			Priority = 0,
			Name = "Core",
			Description = {
				DE = "Schaltet das Multiplayer Workover ein oder aus. @cr Wenn das Kernmodul deaktiviert ist, können auch keine anderen Module geladen werden.",
				GB = "Turns the Multiplayer Workover on or off. @cr If the Core module is deactivated, no other modules can be loaded.",
			},
		},
	}
	--------------------------------------------------------------------------------
	function OnInitialize()
		
		MPW.Log( "MPW: OnInitialize" )

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
		
		MPW.Log( "MPW: OnGUILoaded" )
		
		local title = (XNetworkUbiCom.Tool_GetCurrentLanguageShortName() == "DE" and "@center «MPW Module»") or "@center «MPW Modules»"

		-- right button name for each menu
		XGUIEng.SetText( "OptionsMenu00_ToModules", title )
		XGUIEng.SetText( "OptionsMenu10_ToModules", title )
		XGUIEng.SetText( "OptionsMenu20_ToModules", title )
		XGUIEng.SetText( "OptionsMenu30_ToModules", title )
		XGUIEng.SetText( "OptionsMenu40_ToModules", title )
		XGUIEng.SetText( "OptionsMenu50_ToModules", title )
		XGUIEng.SetText( "MPWMenu_ToModules", title)
		
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
		
		MPW.Log( "MPW: OnMapStart" )

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