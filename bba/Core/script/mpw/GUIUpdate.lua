--------------------------------------------------------------------------------
-- added technology param and return values to this function, to be easyer overwritten
--------------------------------------------------------------------------------
function GUIUpdate_HeroAbility( _Ability, _Button, _Technology )
	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local SelectedEntityID = GUI.GetSelectedEntity()
	
	if Logic.IsHero(SelectedEntityID) == 1 then
		SelectedEntityID = HeroSelection_GetCurrentSelectedHeroID()	
	end
	
	local RechargeTime = Logic.HeroGetAbilityRechargeTime(SelectedEntityID, _Ability)
	local TimeLeft = Logic.HeroGetAbiltityChargeSeconds(SelectedEntityID, _Ability)
	
	if TimeLeft == RechargeTime then
		XGUIEng.SetMaterialColor(CurrentWidgetID,1,0,0,0,0)
		
		local PlayerID = GUI.GetPlayerID()
		local TechState = 2
		
		if _Technology then
			TechState = Logic.GetTechnologyState(PlayerID, _Technology)
		end
		
		--Building is interdicted
		if TechState == 0 then
			XGUIEng.DisableButton(_Button,1)
		
		--Building is not available yet or Technology is to far in the futur
		elseif TechState == 1 or TechState == 5 then
			XGUIEng.DisableButton(_Button,1)
			
		--Building is enabled and visible	
		elseif TechState == 2 or TechState == 3 or TechState == 4 then
			XGUIEng.DisableButton(_Button,0)
		
		end
		
	elseif TimeLeft < RechargeTime then
		XGUIEng.SetMaterialColor(CurrentWidgetID,1,214,44,24,189)
		XGUIEng.DisableButton(_Button,1)
	end
	
	XGUIEng.SetProgressBarValues(CurrentWidgetID,TimeLeft, RechargeTime)
end
--------------------------------------------------------------------------------
function GUIUpdate_GroupStrength()
	local LeaderID = GUI.GetSelectedEntity()
	if LeaderID == nil then
		return
	end
	
	local AmountOfSoldiers = Logic.LeaderGetNumberOfSoldiers( LeaderID )
	local MaxAmountOfSoldiers = Logic.LeaderGetMaxNumberOfSoldiers( LeaderID )
	XGUIEng.ShowAllSubWidgets( gvGUI_WidgetID.DetailsGroupStrengthSoldiersContainer, 0 )
	
	-- show Buttons for each Soldier 
	for i = 1, MaxAmountOfSoldiers do
		XGUIEng.ShowWidget( gvGUI_WidgetID.DetailsGroupStrengthSoldiers[i], 1 )
		XGUIEng.DisableButton(gvGUI_WidgetID.DetailsGroupStrengthSoldiers[i], (i <= AmountOfSoldiers and 0) or 1 )
	end
end
--------------------------------------------------------------------------------
function GUIUpdate_SettlersInBuilding()
	local EntityId = GUI.GetSelectedEntity()

	if EntityId == nil then
		return
	end
	if Logic.IsBuilding( EntityId ) ~= 1 then
		return
	end

	local BuildingType =  Logic.GetEntityType( EntityId )
	local BuildingCategory = Logic.GetUpgradeCategoryByBuildingType( BuildingType )

	local SettlersTable = {}
	local MaxSettlersAmount = 0

	--fill tables depending on the Building type	
	if BuildingCategory == UpgradeCategories.Residence then
		SettlersTable = {Logic.GetAttachedResidentsToBuilding(EntityId)}
		MaxSettlersAmount = Logic.GetMaxNumberOfResidents(EntityId)

	elseif BuildingCategory == UpgradeCategories.Farm or BuildingCategory == UpgradeCategories.Tavern then
		SettlersTable = {Logic.GetAttachedEaterToBuilding(EntityId)}
		MaxSettlersAmount = Logic.GetMaxNumberOfEaters(EntityId)

	else
		SettlersTable = {Logic.GetAttachedWorkersToBuilding(EntityId)}
		MaxSettlersAmount = Logic.GetCurrentMaxNumWorkersInBuilding(EntityId)
	end

	XGUIEng.ShowAllSubWidgets(gvGUI_WidgetID.WorkerButtonContainer, 0)

	--show settlers containers and set variable of container
	for i = 1, MaxSettlersAmount do
		local ButtonName = "WorkerContainer" .. i
		XGUIEng.ShowWidget(ButtonName,1)
		XGUIEng.SetBaseWidgetUserVariable(ButtonName, 0, SettlersTable[i + 1])
	end
end