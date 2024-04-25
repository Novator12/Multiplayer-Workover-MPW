--------------------------------------------------------------------------------
MPW.AttractionLimit = {}
MPW.AttractionLimit.EntityTypesToIgnoreSupplyPlaces = {
	Entities.CB_Evil_Tower1_ArrowLauncher,
	Entities.PB_DarkTower2_Ballista,
	Entities.PB_DarkTower3_Cannon,
	Entities.PB_Tower2_Ballista,
	Entities.PB_Tower3_Cannon,
	-- TODO: add all NPCs here,
}
MPW.AttractionLimit.MaxAdditionalSerfs = 25
--------------------------------------------------------------------------------
function MPW.AttractionLimit.Init()
	
	-- check future population limit on ... 
	-- ... buy cannon
	MPW.AttractionLimit.GUIAction_BuyCannon = GUIAction_BuyCannon
	GUIAction_BuyCannon = function( _CannonType, _UpgradeCategory )
		
		local player = GUI.GetPlayerID()

		if Logic.GetPlayerAttractionLimit( player ) - Logic.GetPlayerAttractionUsage( player ) < Logic.GetAttractionLimitValueByEntityType( _CannonType ) then
			
			GUI.SendPopulationLimitReachedFeedbackEvent( player )
			return
		end
		
		MPW.AttractionLimit.GUIAction_BuyCannon( _CannonType, _UpgradeCategory )
	end
	
	-- ... upgrade tower
	MPW.AttractionLimit.GUIAction_UpgradeSelectedBuilding = GUIAction_UpgradeSelectedBuilding
	GUIAction_UpgradeSelectedBuilding = function()
		
		local entitytype = Logic.GetEntityType( GUI.GetSelectedEntity() )
		
		-- towers
		if Logic.GetUpgradeCategoryByBuildingType( entitytype ) == UpgradeCategories.Tower then
			
			local requiredslots = 0
			
			if entitytype == Entities.PB_Tower1 then
				requiredslots = Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower2_Ballista)
			elseif entitytype == Entities.PB_Tower2 then
				requiredslots = Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower3_Cannon) - Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower2_Ballista) -- do subtract here, the ballista is still there
			end
			
			local player = GUI.GetPlayerID()
			local blockedslots = MPW.AttractionLimit.GetFutureOccupiedAttractionSlots( player )

			if Logic.GetPlayerAttractionLimit( player ) - Logic.GetPlayerAttractionUsage( player ) < requiredslots then
				
				GUI.SendPopulationLimitReachedFeedbackEvent( player )
				return
			end
		end
		
		MPW.AttractionLimit.GUIAction_UpgradeSelectedBuilding()
	end
	
	-- ... buy serf
	--GUIAction_BuySerf()
	-- ... buy leader
	MPW.GUIAction_BuyMilitaryUnit = GUIAction_BuyMilitaryUnit
	function GUIAction_BuyMilitaryUnit( _UpgradeCategory )
		
		local player = GUI.GetPlayerID()
		local _, entitytype = Logic.GetSettlerTypesInUpgradeCategory( _UpgradeCategory )

		if Logic.GetPlayerAttractionLimit( player ) - Logic.GetPlayerAttractionUsage( player ) < Logic.GetAttractionLimitValueByEntityType( entitytype ) then
			
			GUI.SendPopulationLimitReachedFeedbackEvent( player )
			return
		end
		
		MPW.GUIAction_BuyMilitaryUnit( _UpgradeCategory )
	end
	-- ... buy soldier
	MPW.GUIAction_BuySoldier = GUIAction_BuySoldier
	function GUIAction_BuySoldier()
		
		local player = GUI.GetPlayerID()

		if Logic.GetPlayerAttractionLimit( player ) - Logic.GetPlayerAttractionUsage( player ) < Logic.GetAttractionLimitValueByEntityType( Logic.LeaderGetSoldiersType( GUI.GetSelectedEntity() ) ) then
			
			GUI.SendPopulationLimitReachedFeedbackEvent( player )
			return
		end
		
		MPW.GUIAction_BuySoldier()
	end
	-- ... by troops from merchant
	--GUIAction_BuyMerchantOffer( _Index )
	
	-- add population usage to towers
	MPW.AttractionLimit.GUITooltip_UpgradeBuilding = GUITooltip_UpgradeBuilding
	GUITooltip_UpgradeBuilding = function( _BuildingType, _DisabledTooltip, _NormalTooltip, _TechnologyType )
		
		local CostString, TooltipText, ShortCutToolTip = MPW.AttractionLimit.GUITooltip_UpgradeBuilding( _BuildingType, _DisabledTooltip, _NormalTooltip, _TechnologyType )
		
		-- towers
		if Logic.GetUpgradeCategoryByBuildingType( _BuildingType ) == UpgradeCategories.Tower then
		
			local requiredslots = 0

			if _BuildingType == Entities.PB_Tower1 then
				requiredslots = Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower2_Ballista )
			elseif _BuildingType == Entities.PB_Tower2 then
				 -- do subtract here, the player will only need the additional slots
				requiredslots = Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower3_Cannon ) - Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower2_Ballista )
			end

			local player = GUI.GetPlayerID()
			local costcolor = "@color:220,64,16,255 "
			local slotsused, slotamount = Logic.GetPlayerAttractionUsage(player), Logic.GetPlayerAttractionLimit(player)
			
			if slotsused + requiredslots <= slotamount then
				costcolor = "@color:155,230,112,255 "
			end

			CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NamePlaces") .. ": " .. costcolor .. requiredslots
			XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
		end
		
		return CostString, TooltipText, ShortCutToolTip
	end

	-- 25 bonus serfs
	function GameCallback_GetPlayerAttractionLimitForSpawningWorker(player, amount)
		return amount - MPW.AttractionLimit.MaxAdditionalSerfs
	end
	function GameCallback_GetPlayerAttractionUsageForSpawningWorker(player, amount)
		return amount - MPW.AttractionLimit.GetNumberOfAdditionalSerfsOfPlayer(player)
	end

	function GUIUpdate_AdditionalSerfs()
			
		local player = GUI.GetPlayerID()
		local serfamount = MPW.AttractionLimit.GetNumberOfAdditionalSerfsOfPlayer( player )
		local output = ""

		if serfamount < MPW.AttractionLimit.MaxAdditionalSerfs then
			output = "@color:114,134,124,255 "
		else
			output = "@color:255,120,120,255 "
		end

		output = output .. "@ra " .. serfamount .. "/" .. MPW.AttractionLimit.MaxAdditionalSerfs
		
		XGUIEng.SetText( XGUIEng.GetCurrentWidgetID(), output )
	end
end
--------------------------------------------------------------------------------
function MPW.AttractionLimit.Load()
	
	-- add tower upgrades and cannons in construction to attraction usage and sub additional serfs
	MPW.GetPlayerAttractionUsage = MPW.GetPlayerAttractionUsage or Logic.GetPlayerAttractionUsage
	Logic.GetPlayerAttractionUsage = function( _Player )
		return MPW.GetPlayerAttractionUsage( _Player ) + MPW.AttractionLimit.GetFutureOccupiedAttractionSlots( _Player ) - MPW.AttractionLimit.GetNumberOfAdditionalSerfsOfPlayer( _Player )
	end

	-- sub additional serfs from attraction limit
	MPW.GetPlayerAttractionLimit = MPW.GetPlayerAttractionLimit or Logic.GetPlayerAttractionLimit
	Logic.GetPlayerAttractionLimit = function( _Player )
		return MPW.GetPlayerAttractionLimit( _Player ) - MPW.AttractionLimit.MaxAdditionalSerfs
	end

	-- remove turrets and NPCs from eaters
	MPW.GetNumberOfWorkerWithoutEatPlace = MPW.GetNumberOfWorkerWithoutEatPlace or Logic.GetNumberOfWorkerWithoutEatPlace
	Logic.GetNumberOfWorkerWithoutEatPlace = function(_Player)
		return MPW.GetNumberOfWorkerWithoutEatPlace(_Player) - MPW.AttractionLimit.GetNumberOfMissingSupplyPlacesToIgnore(_Player)
	end

	-- remove turrets and NPCs from sleepers
	MPW.GetNumberOfWorkerWithoutSleepPlace = MPW.GetNumberOfWorkerWithoutSleepPlace or Logic.GetNumberOfWorkerWithoutSleepPlace
	Logic.GetNumberOfWorkerWithoutSleepPlace = function(_Player)
		return MPW.GetNumberOfWorkerWithoutSleepPlace(_Player) - MPW.AttractionLimit.GetNumberOfMissingSupplyPlacesToIgnore(_Player)
	end
end
--------------------------------------------------------------------------------
-- returns the number of slots that will be taken by currently constructed cannons and upgraded towers
--
-- add those kind of entities here
---@param _Player number PlayerID
---@return number returns slotnumber
--------------------------------------------------------------------------------
function MPW.AttractionLimit.GetFutureOccupiedAttractionSlots( _Player )
	
	local slots = 0
	
	-- get all working Foundry1
	for id in CEntityIterator.Iterator( CEntityIterator.OfAnyTypeFilter( Entities.PB_Foundry1, Entities.PB_Foundry2 ), CEntityIterator.OfPlayerFilter( _Player ) ) do
		if Logic.GetCannonProgress( id ) ~= 100 then
			
			local _, smelter = Logic.GetAttachedWorkersToBuilding( id )
			if smelter ~= 0 then
				local task = Logic.GetCurrentTaskList( smelter )
				
				if task == "TL_SMELTER_WORK1" or task == "TL_SMELTER_WORK3" then
					slots = slots + Logic.GetAttractionLimitValueByEntityType( Entities.PV_Cannon1 )
				elseif task == "TL_SMELTER_WORK2" or task == "TL_SMELTER_WORK4" then
					slots = slots + Logic.GetAttractionLimitValueByEntityType( Entities.PV_Cannon2 )
				elseif task == "TL_SMELTER_WORK5" then
					slots = slots + Logic.GetAttractionLimitValueByEntityType( Entities.PV_Cannon3 )
				elseif task == "TL_SMELTER_WORK6" then
					slots = slots + Logic.GetAttractionLimitValueByEntityType( Entities.PV_Cannon4 )
				end
			end
		end
	end
		
	-- get all currently upgrading ballista towers
	for id in CEntityIterator.Iterator( CEntityIterator.OfTypeFilter( Entities.PB_Tower1 ), CEntityIterator.OfPlayerFilter( _Player ) ) do
		if Logic.GetRemainingUpgradeTimeForBuilding( id ) < Logic.GetTotalUpgradeTimeForBuilding( id ) then
			slots = slots + Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower2_Ballista )
		end
	end
	
	-- get all currently upgrading cannon towers
	-- use this if cannon tower will take more slots
	for id in CEntityIterator.Iterator( CEntityIterator.OfTypeFilter( Entities.PB_Tower2 ), CEntityIterator.OfPlayerFilter( _Player ) ) do
		if Logic.GetRemainingUpgradeTimeForBuilding( id ) < Logic.GetTotalUpgradeTimeForBuilding( id ) then
			slots = slots + Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower3_Cannon ) -- - Logic.GetAttractionLimitValueByEntityType( Entities.PB_Tower2_Ballista ) -- do not subtract here, the ballista is removed in the upgrade progress
		end
	end
	
	return slots
end
--------------------------------------------------------------------------------
-- returns the number of missing eat- and sleepplaces to ignore
---@param _Player number
---@return number amount
--------------------------------------------------------------------------------
function MPW.AttractionLimit.GetNumberOfMissingSupplyPlacesToIgnore(_Player)
	local n = 0
	for id in CEntityIterator.Iterator( CEntityIterator.OfAnyTypeFilter( unpack(MPW.AttractionLimit.EntityTypesToIgnoreSupplyPlaces) ), CEntityIterator.OfPlayerFilter( _Player ) ) do
		n = n + 1
	end
	return n
end
--------------------------------------------------------------------------------
function MPW.AttractionLimit.GetNumberOfAdditionalSerfsOfPlayer(_Player)
	return math.min(Logic.GetNumberOfEntitiesOfTypeOfPlayer(_Player, Entities.PU_Serf), MPW.AttractionLimit.MaxAdditionalSerfs)
end