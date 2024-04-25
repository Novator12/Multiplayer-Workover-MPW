----------------------------------------------------------------------------------------------------
-- Modules
----------------------------------------------------------------------------------------------------
function MPW.ToggleModule( _Name, _Limit )
	
	_Limit = _Limit or 1
	
	-- get value from server ruleset
	local value = MPW.GetModuleValue( _Name )
	
	value = value + 1
	
	if value > _Limit then
		value = 0
	end
	
	MPW.SetModuleActive( _Name, value )
end
----------------------------------------------------------------------------------------------------
function MPW.GetModuleValue( _Name )
	return CustomStringHelper.GetValue( CustomStringHelper.FromString( XNetwork.EXTENDED_GameInformation_GetCustomString() ), "MPW_" .. _Name ) or 0
end
----------------------------------------------------------------------------------------------------
function MPW.IsModuleSetActive( _Name )
	return MPW.GetModuleValue( _Name ) ~= 0
end
----------------------------------------------------------------------------------------------------
function MPW.SetModuleActive( _Name, _Value )
	
	_Value = _Value or 1
	
	-- get current ruleset from server
	local d = CustomStringHelper.FromString( XNetwork.EXTENDED_GameInformation_GetCustomString() )
	
	-- set key in local ruleset
	CustomStringHelper.SetKeyValue( d, "MPW_" .. _Name, _Value )
	
	-- push local ruleset to server
	XNetwork.EXTENDED_GameInformation_SetCustomString( CustomStringHelper.ToString( d ) )
	
	--MPW.UpdateModuleButtons()
end
----------------------------------------------------------------------------------------------------
function MPW.CheckModuleDependencies( _Name )
	
	if MPW.Modules[ _Name ].Dependencies then
		for _, dependency in pairs( MPW.Modules[ _Name ].Dependencies ) do
			if not MPW.IsModuleSetActive( dependency ) then
				return false
			end
		end
	end
	
	return true
end
----------------------------------------------------------------------------------------------------
function MPW.CheckModuleIncompatibilities( _Name )
	
	if MPW.Modules[ _Name ].Incompatibilities then
		for _, incompatible in pairs( MPW.Modules[ _Name ].Incompatibilities ) do
			if MPW.IsModuleSetActive( incompatible ) then
				return false
			end
		end
	end
	
	return true
end
----------------------------------------------------------------------------------------------------
function MPW.CanModuleBeActive( _Name )
	return MPW.CheckModuleDependencies( _Name ) and MPW.CheckModuleIncompatibilities( _Name )
end
----------------------------------------------------------------------------------------------------
function MPW.IsModuleActive( _Name )
	return MPW.IsModuleSetActive( _Name ) and MPW.CanModuleBeActive( _Name )
end
----------------------------------------------------------------------------------------------------
function MPW.UpdateModuleButtons()
	
	-- allways update every button, due to denpendencies and Incompatibilities
	for name, mod in pairs( MPW.Modules ) do
		
		-- check state of current module
		local ButtonName = "MPM20_MPWMenu_" .. name
		local HighLightFlag = 0
		local DisableFlag = 0
		
		if MPW.IsModuleSetActive( name ) then
			HighLightFlag = 1
		end
		
		XGUIEng.HighLightButton( ButtonName, HighLightFlag )
		
		-- check state of dependent and incompatible modules
		if not MPW.CanModuleBeActive( name ) then
			DisableFlag = 1
		end
		
		-- set actual state of current module
		XGUIEng.DisableButton( ButtonName, DisableFlag )
	end
end
----------------------------------------------------------------------------------------------------
-- module loader
----------------------------------------------------------------------------------------------------
function MPW.LoadModules()
	
	-- load all modules
	Script.LoadFolder( "MP_SettlerServer\\Mods\\MPW\\MainMenu\\Modules\\" )
	
	local index, rows = 0, 6
	local x, y, w, h, d = 32, 75, 100, 40, 10
	
	for name, mod in pairs( MPW.Modules ) do
		if MPW[ name ] and MPW[name].OnInitialize then
			if MPW[ name ].OnInitialize() then
				
				local r, c = math.floor( index / rows ), math.mod( index, rows )
				
				-- create toggle button
				CWidget.Transaction_AddTextButton(
					{
						Name = "MPM20_MPWMenu_" .. name,
						MotherID = "MPM20_MPWMenu",
						IsShown = true,
						Rectangle = {
							X = x + c * ( w + d ),
							Y = y + r * ( h + d ),
							W = w,
							H = h,
						},
						ZPriority = 0,
						ForceToHandleMouseEventsFlag = false,
						ForceToNeverBeFoundFlag = false,
						StringHelper = {
							Font = {
								FontName = "data\\menu\\fonts\\mainmenularge.met",
							},
							String = {
								StringTableKey = "",
								RawString = "@center " .. ( mod.Name or name ),
							},
							StringFrameDistance = 3,
							Color = {
								Red = 255,
								Green = 255,
								Blue = 255,
								Alpha = 255,
							},
						},
						UpdateFunction = {
							LuaCommand = "",
						},
						UpdateManualFlag = true,
						ButtonHelper = {
							DisabledFlag = false,
							HighLightedFlag = false,
							ActionFunction = {
								LuaCommand = "MPW.ToggleModule( \"" .. name .. "\" )"
							},
							ShortCutString = {
								StringTableKey = "",
								RawString = "",
							},
						},
						Materials = {
							{ 
								Texture = "data\\graphics\\textures\\gui\\mainmenu\\sub.png",
								TextureCoordinates = { X = 0, Y = 0, W = 1, H = 0.8510638 },
								Color = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
							}, -- normal
							{ 
								Texture = "data\\graphics\\textures\\gui\\mainmenu\\sub_hi.png",
								TextureCoordinates = { X = 0, Y = 0, W = 1, H = 0.8510638 },
								Color = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
							}, -- hover
							{ 
								Texture = "data\\graphics\\textures\\gui\\mainmenu\\sub_sel.png",
								TextureCoordinates = { X = 0, Y = 0, W = 1, H = 0.8510638 },
								Color = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
							}, -- pressed
							{ 
								Texture = "data\\graphics\\textures\\gui\\mainmenu\\sub_in.png",
								TextureCoordinates = { X = 0, Y = 0, W = 1, H = 0.8510638 },
								Color = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
							}, -- disabled
							{ 
								Texture = "data\\graphics\\textures\\gui\\mainmenu\\sub_akt.png",
								TextureCoordinates = { X = 0, Y = 0, W = 1, H = 0.8510638 },
								Color = { Red = 255, Green = 255, Blue = 255, Alpha = 255 },
							}, -- highlighted
						},
						ToolTipHelper = {
							ToolTipEnabledFlag = true,
							ToolTipString = {
								StringTableKey = "",
								RawString = mod.Description,
							},
							TargetWidget = "StartMenu_TooltipText",
							ControlTargetWidgetDisplayState = true,
							UpdateFunction = {
								LuaCommand = "",
							},
						},
					}
				)
				
				index = index + 1
			end
		end
	end
end