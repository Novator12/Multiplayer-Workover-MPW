--------------------------------------------------------------------------------
MPW.Motivation = {}
--------------------------------------------------------------------------------
MPW.Motivation.Buildings = {
	[Entities.PB_Monastery1] = 0.24,
	[Entities.PB_Monastery2] = 0.3,
	[Entities.PB_Monastery3] = 0.47,
	[Entities.PB_Beautification01] = 0.12,
	[Entities.PB_Beautification02] = 0.12,
	[Entities.PB_Beautification03] = 0.18,
	[Entities.PB_Beautification04] = 0.06,
	[Entities.PB_Beautification05] = 0.15,
	[Entities.PB_Beautification06] = 0.06,
	[Entities.PB_Beautification07] = 0.15,
	[Entities.PB_Beautification08] = 0.15,
	[Entities.PB_Beautification09] = 0.06,
	[Entities.PB_Beautification10] = 0.18,
	[Entities.PB_Beautification11] = 0.18,
	[Entities.PB_Beautification12] = 0.12,
}
--------------------------------------------------------------------------------
-- init
--------------------------------------------------------------------------------
function MPW.Motivation.Init()
	
	-- decrease motivation and enable button if moti building got destroyed
	MPW.Motivation.BuildingDestroyed = function()
		
		local entityType = Logic.GetEntityType( Event.GetEntityID() )
		
		if MPW.Motivation.Buildings[ entityType ] then
			
			-- decrease motivation
			local player = GetPlayer( Event.GetEntityID() )
			local bonus = -MPW.Motivation.GetBuildingBonus( player, Logic.GetEntityType( Event.GetEntityID() ), 1 )
		
			MPW.Motivation.AddToSoftcap( player, bonus )
			
			-- enable button
			if player == GUI.GetPlayerID() then
				
				local button = string.sub( Logic.GetEntityTypeName( entityType ), 4, -1 )
				
				if string.find( button, "Monastery" ) then
					button = string.sub( button, 1, -2 )
				end

				button = "Build_" .. button
				
				XGUIEng.DisableButton( button, 0 )
			end
		end
	end
	
	Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, MPW.Motivation.BuildingDestroyed, 1, {}, {})
	
	-- increase motivation on building completed
	MPW.Motivation.GameCallback_OnBuildingConstructionComplete = GameCallback_OnBuildingConstructionComplete
	GameCallback_OnBuildingConstructionComplete = function( _Building, _Player )
		
		local entityType = Logic.GetEntityType( _Building )
		
		if MPW.Motivation.Buildings[ entityType ] then
			
			-- increase motivation
			local bonus = MPW.Motivation.GetBuildingBonus( _Player, Logic.GetEntityType( _Building ) )
			
			MPW.Motivation.AddToSoftcap( _Player, bonus )
		end
		
		MPW.Motivation.GameCallback_OnBuildingConstructionComplete( _Building, _Player )
	end
	
	-- construction callback does all we want, even on upgrade
	--[[MPW.Motivation.GameCallback_OnBuildingUpgradeComplete = GameCallback_OnBuildingUpgradeComplete
	GameCallback_OnBuildingUpgradeComplete = function( _OldID, _NewID )
		
		MPW.Motivation.GameCallback_OnBuildingUpgradeComplete( _OldID, _NewID )
	end]]
	
	for p = 1, 1 do
		MPW.Motivation.AddToSoftcap( p, MPW.Motivation.GetSoftcap( p ) )
	end
end
--------------------------------------------------------------------------------
-- limit can be turned off separately by not calling this init function
--------------------------------------------------------------------------------
function MPW.Motivation.InitBuildingLimit()
	
	-- disable button on building created
	-- construction complete callback is too late
	function MPW.Motivation.BuildingCreated()
		
		local entityType = Logic.GetEntityType( Event.GetEntityID() )
		
		if MPW.Motivation.Buildings[ entityType ] then
			
			-- disable button
			if GetPlayer( Event.GetEntityID() ) == GUI.GetPlayerID() then
			
				local button = string.sub( Logic.GetEntityTypeName( entityType ), 4, -1 )
				
				if string.find( button, "Monastery" ) then
					button = string.sub( button, 1, -2 )
				end

				button = "Build_" .. button
				
				XGUIEng.DisableButton( button, 1 )
			end
		end
	end
	
	-- trigger for button disable
	Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_CREATED, nil, MPW.Motivation.BuildingCreated, 1, {}, {})
	
	-- disable button if max number of buildings reached
	MPW.Motivation.GUIUpdate_BuildingButtons = GUIUpdate_BuildingButtons
	GUIUpdate_BuildingButtons = function( _Button, _Technology )
		
		MPW.Motivation.GUIUpdate_BuildingButtons( _Button, _Technology )
		
		-- moti fix
		if _Button == "Build_Monastery" then
			
			for i = 1,3 do
				if Logic.GetNumberOfEntitiesOfTypeOfPlayer( GUI.GetPlayerID(), Entities[ "PB_Monastery"..i ] ) > 0 then
					
					XGUIEng.DisableButton( _Button, 1 )
					break
				end
			end
			
		elseif string.find( _Button, "Build_Beautification") then
			
			if Logic.GetNumberOfEntitiesOfTypeOfPlayer( GUI.GetPlayerID(), Entities[ string.gsub( _Button, "Build_", "PB_" ) ] ) > 0 then
				
				XGUIEng.DisableButton( _Button, 1 )
			end
		end
	end
	
	-- this works but needs some changes
	MPW.Motivation.GUITooltip_ConstructBuilding = GUITooltip_ConstructBuilding
	GUITooltip_ConstructBuilding = function( _CategoryType, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut )
		
		local CostString, TooltipText, ShortCutToolTip = MPW.Motivation.GUITooltip_ConstructBuilding( _CategoryType, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut )
		
		local entities = { Logic.GetBuildingTypesInUpgradeCategory( _CategoryType ) }
		table.remove( entities, 1 )
		
		if string.find( Logic.GetEntityTypeName( entities[1] ), "Monastery" ) or string.find( Logic.GetEntityTypeName( entities[1] ), "Beautification" ) then
		
			local limit = 1
			local amount = 0
			
			for _,v in pairs( entities ) do
				amount = amount + Logic.GetNumberOfEntitiesOfTypeOfPlayer( GUI.GetPlayerID(), v )
			end
			
			TooltipText = TooltipText .. " @cr @cr @color:255,204,51,255 Limit: "
			--" Ihr könnt nur " .. limit .. " Gebäude dieses Typs bauen."

			if amount >= limit then
				TooltipText = TooltipText .. "@color:220,64,16,255 "
			else
				TooltipText = TooltipText .. "@color:255,255,255,255 "
			end
			
			TooltipText = TooltipText .. amount .. " / " .. limit
			
			XGUIEng.SetText( gvGUI_WidgetID.TooltipBottomText, TooltipText )
		end
		
		return CostString, TooltipText, ShortCutToolTip
	end
end
--------------------------------------------------------------------------------
-- adds to players motivation softcap and settlers motivation
--------------------------------------------------------------------------------
function MPW.Motivation.AddToSoftcap( _Player, _Bonus )
	
	CUtil.AddToPlayersMotivationSoftcap( _Player, _Bonus )
	
	for id in CEntityIterator.Iterator( CEntityIterator.OfPlayerFilter( _Player ) ) do
		if Logic.IsWorker( id ) == 1 then
		
			CEntity.SetMotivation( id, CEntity.GetMotivation( id ) + _Bonus )
		end
	end
end
--------------------------------------------------------------------------------
-- get the shall be motivation limit for the passed player
--------------------------------------------------------------------------------
function MPW.Motivation.GetSoftcap( _Player )
	
	local softcap = 0
	
	for k,v in pairs( MPW.Motivation.Buildings ) do
	
		local amount = Logic.GetNumberOfEntitiesOfTypeOfPlayer( _Player, k )
		
		for i = 1, amount do
			softcap = softcap + MPW.Motivation.GetBonus( v, i )
		end
	end
	
	return softcap
end
--------------------------------------------------------------------------------
-- get the motivation bonus for passed building type of player
-- depends on the amount which gets calculated here
--------------------------------------------------------------------------------
function MPW.Motivation.GetBuildingBonus( _Player, _BuildingType, _Offset )
	return MPW.Motivation.GetBonus( MPW.Motivation.Buildings[ _BuildingType ], Logic.GetNumberOfEntitiesOfTypeOfPlayer( _Player, _BuildingType ) + (_Offset or 0) )
end
--------------------------------------------------------------------------------
-- define the decrease function for motivation effect here
--------------------------------------------------------------------------------
function MPW.Motivation.GetBonus( _Value, _Amount )

	if _Value and _Amount and _Amount > 0 then
		return _Value / _Amount
	end
	
	return 0
end