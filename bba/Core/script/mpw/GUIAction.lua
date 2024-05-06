--------------------------------------------------------------------------------
-- NEW: Darios motivation ability
--------------------------------------------------------------------------------
function GUIAction_Hero1Motivate()
	GUI.SettlerMotivateWorkers( HeroSelection_GetCurrentSelectedHeroID() )
end
--------------------------------------------------------------------------------
-- NEW: for the ExpellButton of Heros
--------------------------------------------------------------------------------
function GUIAction_TrollHeroExpell()
	
	local heroID = HeroSelection_GetCurrentSelectedHeroID()
	local player = Logic.EntityGetPlayer( heroID )
	
	-- get "no" comment of hero
	-- use Dario as standard for safety
	local sound = Sounds.VoicesHero1_HERO1_NO_rnd_01
	
	if Logic.IsEntityInCategory( heroID, EntityCategories.Hero1 ) == 1 then
	
		sound = Sounds.VoicesHero1_HERO1_NO_rnd_01
		
	elseif Logic.IsEntityInCategory( heroID, EntityCategories.Hero2 ) == 1 then
	
		sound = Sounds.VoicesHero2_HERO2_NO_rnd_01
		
	elseif Logic.IsEntityInCategory( heroID, EntityCategories.Hero3 ) == 1 then
	
		sound = Sounds.VoicesHero3_HERO3_NO_rnd_01
		
	elseif Logic.IsEntityInCategory( heroID, EntityCategories.Hero4 ) == 1 then
	
		sound = Sounds.VoicesHero4_HERO4_NO_rnd_01
		
	elseif Logic.IsEntityInCategory( heroID, EntityCategories.Hero5 ) == 1 then
	
		sound = Sounds.VoicesHero5_HERO5_NO_rnd_01
		
	elseif Logic.IsEntityInCategory( heroID, EntityCategories.Hero6 ) == 1 then

		sound = Sounds.VoicesHero6_HERO6_NO_rnd_01
		
	elseif Logic.GetEntityType( heroID ) == Entities.CU_BlackKnight then
	
		sound = Sounds.VoicesHero7_HERO7_NO_rnd_01
		
	elseif Logic.GetEntityType( heroID ) == Entities.CU_Mary_de_Mortfichet then
	
		sound = Sounds.VoicesHero8_HERO8_NO_rnd_01
		
	elseif Logic.GetEntityType( heroID ) == Entities.CU_Barbarian_Hero then
	
		sound = Sounds.VoicesHero9_HERO9_NO_rnd_01
		
	elseif Logic.IsEntityInCategory( heroID, EntityCategories.Hero10 ) == 1 then
	
		sound = Sounds.AOVoicesHero10_HERO10_NO_rnd_01
	
	elseif Logic.IsEntityInCategory( heroID, EntityCategories.Hero11 ) == 1 then
	
		sound = Sounds.AOVoicesHero11_HERO11_NO_rnd_01
		
	elseif Logic.GetEntityType( heroID ) == Entities.CU_Evil_Queen then
	
		sound = Sounds.AOVoicesHero12_HERO12_NO_rnd_01
	end
	
	Sound.PlayFeedbackSound( sound, 127 )
	TrollExpelHero_SetRandomButtonPosition()
end
--------------------------------------------------------------------------------
function TrollExpelHero_SetRandomButtonPosition()
	
	--GUITooltip_NormalButton("MenuCommandsGeneric/expel")
	XGUIEng.ShowWidget( "TooltipBottom", 0 )
	
	--randomPos des ExpellWidgets
	local widgetID = XGUIEng.GetCurrentWidgetID()
	local xPos = XGUIEng.GetRandom( 291 )
	local yPos = XGUIEng.GetRandom( 37 )
	XGUIEng.SetWidgetPosition( widgetID, xPos, yPos )
end
--------------------------------------------------------------------------------
-- switched highlighting of buttons to enable shortcuts
--------------------------------------------------------------------------------
function GUIAction_ToggleSerfMenu( _Menu, _State )
	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	XGUIEng.ShowAllSubWidgets( gvGUI_WidgetID.SerfMenus, 0 )
	
	XGUIEng.UnHighLightGroup( gvGUI_WidgetID.InGame, "BuildingMenuGroup" )
	
	
	if _Menu == gvGUI_WidgetID.SerfConstructionMenu then
		XGUIEng.HighLightButton( gvGUI_WidgetID.ToSerfConstructionMenu, 1 )
	else
		XGUIEng.HighLightButton( gvGUI_WidgetID.ToSerfBeatificationMenu, 1 )
	end
	
	XGUIEng.ShowWidget( _Menu, _State )
	
	--Update all buttons in the visible container
	XGUIEng.DoManualButtonUpdate( gvGUI_WidgetID.InGame )
end
--------------------------------------------------------------------------------
-- switched highlighting of buttons to enable shortcuts
--------------------------------------------------------------------------------
function GUIAction_ChangeBuildingMenu( _Button )

	XGUIEng.UnHighLightGroup( gvGUI_WidgetID.InGame, "BuildingMenuGroup" )	
	
	Camera.FollowEntity( 0 )
	Camera.SetControlMode( 0 )
	
	if _Button == gvGUI_WidgetID.ToBuildingCommandMenu then
		--GameCallback_GUI_SelectionChanged()
		GUI.SetSelectedEntity( GUI.GetSelectedEntity() )
		XGUIEng.HighLightButton( gvGUI_WidgetID.ToBuildingCommandMenu, 1 )
	else
		XGUIEng.ShowAllSubWidgets( gvGUI_WidgetID.SelectionBuilding, 0 )
		XGUIEng.ShowWidget( gvGUI_WidgetID.WorkerInBuilding, 1 )
		XGUIEng.ShowWidget( gvGUI_WidgetID.BuildingTabs, 1 )
		XGUIEng.HighLightButton( gvGUI_WidgetID.ToBuildingSettlersMenu, 1 )
	end
end
--------------------------------------------------------------------------------
-- changed formations for cavalry
--------------------------------------------------------------------------------
function GUIAction_ChangeFormation( _FormationType )

	-- Get entities
	local SelectedEntityIDs = { GUI.GetSelectedEntities() }

	-- Do action
	for _,SelectedEntityID in pairs( SelectedEntityIDs ) do
		if SelectedEntityID ~= nil and SelectedEntityID > 0 then
			local iscavalry = Logic.IsEntityInCategory( SelectedEntityID, EntityCategories.CavalryHeavy ) == 1 or Logic.IsEntityInCategory( SelectedEntityID, EntityCategories.CavalryLight ) == 1
			
			if _FormationType == 1 then
				if iscavalry then
					GUI.LeaderChangeFormationType( SelectedEntityID, 8 )
				else
					GUI.LeaderChangeFormationType( SelectedEntityID, 1 )
				end
			elseif _FormationType == 2 then
				GUI.LeaderChangeFormationType( SelectedEntityID, 2 )
			elseif _FormationType == 3 then
				if iscavalry then
					GUI.LeaderChangeFormationType( SelectedEntityID, 6 )
				else
					GUI.LeaderChangeFormationType( SelectedEntityID, 3 )
				end
			elseif _FormationType == 4 then
				if iscavalry then
					GUI.LeaderChangeFormationType( SelectedEntityID, 7 )
				else
					GUI.LeaderChangeFormationType( SelectedEntityID, 4 )
				end
			end
		end
	end
		
	GUI.SendChangeFormationFeedbackEvent( _FormationType )
	-- Sound.PlayFeedbackSound( Sounds.Leader_LEADER_Formation_rnd_01, 0 )
	
	return
end
--------------------------------------------------------------------------------
-- add additional serfs to limit check
--------------------------------------------------------------------------------
function GUIAction_BuySerf()
	local BuildingID = GUI.GetSelectedEntity()
	local PlayerID = GUI.GetPlayerID()
	
	if Logic.GetRemainingUpgradeTimeForBuilding(BuildingID ) ~= Logic.GetTotalUpgradeTimeForBuilding (BuildingID) then	
		return
	end
	
	local VCThreshold = Logic.GetLogicPropertiesMotivationThresholdVCLock()
	local AverageMotivation = Logic.GetAverageMotivation(PlayerID)
	
	if AverageMotivation < VCThreshold then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_VillageCentersAreClosed"))
		return
	end
	
	if Logic.GetTechnologyResearchedAtBuilding(BuildingID) ~= 0 then
		return
	end
		
	-- Maximum number of settlers attracted?
	if Logic.GetPlayerAttractionUsage( PlayerID ) + MPW.AttractionLimit.GetNumberOfAdditionalSerfsOfPlayer( PlayerID ) >= Logic.GetPlayerAttractionLimit( PlayerID ) + MPW.AttractionLimit.MaxAdditionalSerfs[PlayerID] then
		GUI.SendPopulationLimitReachedFeedbackEvent( PlayerID )
		return
	end
	
	local VCThreshold = Logic.GetLogicPropertiesMotivationThresholdVCLock()
	local AverageMotivation = Logic.GetAverageMotivation(PlayerID)
	
	if AverageMotivation < VCThreshold then
		GUI.AddNote(XGUIEng.GetStringTableText("InGameMessages/Note_VillageCentersAreClosed"))
		return
	end
	
	Logic.FillSerfCostsTable( InterfaceGlobals.CostTable )
	
	if InterfaceTool_HasPlayerEnoughResources_Feedback( InterfaceGlobals.CostTable ) == 1 then
		GUI.BuySerf(BuildingID)
	end
end
--------------------------------------------------------------------------------
-- fix for unknown unit types
function GUIAction_AOOnlineHelp(_SelectedEntityID, _SpokenText, _Text)
	local AOSpokenText
	local AOText
	local EntityType = Logic.GetEntityType( _SelectedEntityID )
	local UpgradeCategory

	if Logic.IsBuilding( _SelectedEntityID ) == 1 then
		UpgradeCategory = Logic.GetUpgradeCategoryByBuildingType(EntityType)
	else
		UpgradeCategory = Logic.LeaderGetSoldierUpgradeCategory( _SelectedEntityID )
	end

	if UpgradeCategory ~= 0 and UpgradeCategory ~= nil and HintTable[UpgradeCategory] then
		AOSpokenText	= Sounds["AOVoicesMentorHelp_" .. HintTable[UpgradeCategory]]
		AOText 			= XGUIEng.GetStringTableText("AOVoicesMentorHelp/" .. HintTable[UpgradeCategory])
	end

	if EntityType == Entities.PU_Scout then
		AOSpokenText	= Sounds.AOVoicesMentorHelp_UNIT_Scout
		AOText 			= XGUIEng.GetStringTableText("AOVoicesMentorHelp/UNIT_Scout")
	elseif EntityType == Entities.PU_Thief then
		AOSpokenText	= Sounds.AOVoicesMentorHelp_UNIT_Thief
		AOText 			= XGUIEng.GetStringTableText("AOVoicesMentorHelp/UNIT_Thief")
	end

	if AOSpokenText ~= nil and AOText ~= nil then
		return AOSpokenText, AOText
	else
		return _SpokenText, _Text
	end
end