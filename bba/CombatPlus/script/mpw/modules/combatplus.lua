--------------------------------------------------------------------------------
-- replace "CombatPlus" in this file with any unique name
--------------------------------------------------------------------------------
MPW.CombatPlus = {}
table.insert(MPW.Modules, "CombatPlus")
--------------------------------------------------------------------------------
function MPW.CombatPlus.Init()
	MPW.Log( "CombatPlus.Init()" )

	WidgetHelper.AddPreCommitCallback(
		function()
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\research_upgradeaxe3.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\research_upgradeaxe2.xml", "Research_UpgradeAxe3")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\research_upgradeaxe1.xml", "Research_UpgradeAxe2")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\buy_leaderaxe.xml", "Research_UpgradeAxe1")
			
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\research_upgradecrossbow1.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\buy_leadercrossbow.xml", "Research_UpgradeCrossBow1")
			
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\findaxemen.xml", "FindScout")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\findcrossbowmen.xml", "FindScout")
			
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\multiselectionsource_axe.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\multiselectionsource_crossbow.xml")
			
			-- TODO: find a way to hide widgets without removing them
			CWidget.Transaction_RemoveWidget("Research_UpgradeBow2")
			CWidget.Transaction_RemoveWidget("Research_UpgradeBow3")
			
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\research_reinforcedchassis.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\research_hardenedframes.xml")

			CWidget.Transaction_RemoveWidget("CannonInProgress")
			CWidget.Transaction_RemoveWidget("Commands_Foundry")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\commands_foundry.xml")
		end
	)

    MPW.EntityCategories.AddEntityCategory("CrossBow")

    MPW.EntityCategories.AssignEntityCategory(Entities.PU_LeaderCrossBow1, EntityCategories.CrossBow)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_LeaderCrossBow2, EntityCategories.CrossBow)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_SoldierCrossBow1, EntityCategories.CrossBow)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_SoldierCrossBow2, EntityCategories.CrossBow)

    MPW.EntityCategories.AssignEntityCategory(Entities.PU_LeaderAxe1, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_LeaderAxe2, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_LeaderAxe3, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_LeaderAxe4, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_SoldierAxe1, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_SoldierAxe2, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_SoldierAxe3, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.PU_SoldierAxe4, EntityCategories.Axe)
	
	MPW.CombatPlus.GUIUpdate_MultiSelectionButton = GUIUpdate_MultiSelectionButton
	function GUIUpdate_MultiSelectionButton()
		local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
		local MotherContainer= XGUIEng.GetWidgetsMotherID(CurrentWidgetID)
		local EntityTypeName = Logic.GetEntityTypeName(Logic.GetEntityType(XGUIEng.GetBaseWidgetUserVariable(MotherContainer, 0)))
		
		local SourceButton

		if string.find(EntityTypeName, "PU_LeaderAxe") then
			SourceButton = "MultiSelectionSource_Axe"
		elseif string.find(EntityTypeName, "PU_LeaderCrossBow") then
			SourceButton = "MultiSelectionSource_CrossBow"
		end

		if SourceButton then
			XGUIEng.TransferMaterials(SourceButton, CurrentWidgetID)
			for i = 0, 4 do
				XGUIEng.SetMaterialColor(SourceButton, i, 255, 255, 255, 255)
			end	
			return
		end

		MPW.CombatPlus.GUIUpdate_MultiSelectionButton()
	end

	-- hack for resarch in foundry
	function InterfaceTool_IsBuildingDoingSomething( _BuildingID )
		local EntityType = Logic.GetEntityType(_BuildingID )
		
		if Logic.GetTechnologyResearchedAtBuilding(_BuildingID) ~= 0 or Logic.GetRemainingUpgradeTimeForBuilding(_BuildingID) ~= Logic.GetTotalUpgradeTimeForBuilding (_BuildingID)	then
			return true
		elseif EntityType == Entities.PB_Market2 then
			if Logic.GetTransactionProgress(_BuildingID) ~= 100 then
				return true
			end
		end
		return false
	end
end
--------------------------------------------------------------------------------
function MPW.CombatPlus.Load()
	MPW.Log( "CombatPlus.Load()" )

	-- hack for foundry not having founrdy behavior anymore
	MPW.CombatPlus.GetCannonProgress = Logic.GetCannonProgress
	function Logic.GetCannonProgress(_BuildingID)
		if Logic.GetLeaderTrainingAtBuilding(_BuildingID) > 0 then
			return 0
		end
		return 100
	end
end
--------------------------------------------------------------------------------
function MPW.CombatPlus.PostInit()
	MPW.Log( "CombatPlus.PostInit()" )

	local path = MPW_Debug and "MP_SettlerServer\\Mods\\MPW\\Ingame\\CombatPlus\\script\\mpw\\modules\\CombatPlus\\" or "data\\script\\mpw\\modules\\CombatPlus\\"
	Script.Load( path .. "osi.lua" )

	MPW.OSI.CombatPlus.PostInit()

	MPW.CombatPlus.GameCallback_OnTechnologyResearched = GameCallback_OnTechnologyResearched
	function GameCallback_OnTechnologyResearched(_PlayerID, _TechnologyType)
		
		if _TechnologyType == Technologies.T_UpgradeAxe1 or _TechnologyType == Technologies.T_UpgradeAxe2 or _TechnologyType == Technologies.T_UpgradeAxe3 then
			--should be LOGIC not GUI
			Logic.UpgradeSettler(UpgradeCategories.LeaderAxe, _PlayerID)
			Logic.UpgradeSettler(UpgradeCategories.SoldierAxe, _PlayerID)
			
		elseif _TechnologyType == Technologies.T_UpgradeCrossBow1 then
			--should be LOGIC not GUI
			Logic.UpgradeSettler(UpgradeCategories.LeaderCrossBow, _PlayerID)
			Logic.UpgradeSettler(UpgradeCategories.SoldierCrossBow, _PlayerID)
		end
		
		MPW.CombatPlus.GameCallback_OnTechnologyResearched(_PlayerID, _TechnologyType)
	end

	-- additional find views for axe and crossbow
	-- the calls do the same thing as before, just a little optimized by removing the if condition
	-- TODO: complete overhaul
	function GUIUpdate_FindView()

		local PlayerID = GUI.GetPlayerID()

		--Serfs
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindIdleSerf, Logic.GetNumberOfEntitiesOfTypeOfPlayer(PlayerID, Entities.PU_Serf))
		
		--Groups
		
		--Sword
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindSwordLeader, Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderSword, PlayerID), 1 ))
		
		--Spear
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindSpearLeader, Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderPoleArm, PlayerID), 1 ))
		
		--Bow
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindBowLeader, Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderBow, PlayerID), 1 ))
		
		--light Cavalry
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindLightCavalryLeader, Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderCavalry, PlayerID), 1 ))
		
		--heavy Cavalry
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindHeavyCavalryLeader, Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderHeavyCavalry, PlayerID), 1 ))
		
		--cannons
		local Cannon1 = Logic.GetPlayerEntities( PlayerID, Entities.PV_Cannon1, 1 )	
		local Cannon2 = Logic.GetPlayerEntities( PlayerID, Entities.PV_Cannon2, 1 )	
		local Cannon3 = Logic.GetPlayerEntities( PlayerID, Entities.PV_Cannon3, 1 )	
		local Cannon4 = Logic.GetPlayerEntities( PlayerID, Entities.PV_Cannon4, 1 )	
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindCannon, Cannon1 + Cannon2 + Cannon3 + Cannon4) -- also works with numbers > 1
		
		--rifle
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindRifleLeader, Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderRifle, PlayerID), 1 ))
		
		--Scout
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindScout, Logic.GetPlayerEntities( PlayerID, Entities.PU_Scout, 1 )) 
		
		--Thief
		XGUIEng.ShowWidget(gvGUI_WidgetID.FindThief, Logic.GetPlayerEntities( PlayerID, Entities.PU_Thief, 1 ))

		--Axe
		XGUIEng.ShowWidget("FindAxemen", Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderAxe, PlayerID), 1 ))

		--CrossBow
		XGUIEng.ShowWidget("FindCrossBowmen", Logic.GetPlayerEntities( PlayerID, Logic.GetSettlerTypeByUpgradeCategory(UpgradeCategories.LeaderCrossBow, PlayerID), 1 ))
	end
end
--------------------------------------------------------------------------------
function MPW.CombatPlus.PostLoad()
	MPW.Log( "CombatPlus.PostLoad()" )
	
	XGUIEng.SetWidgetPosition("Research_BetterTrainingBarracks", 112, 4)
	XGUIEng.SetWidgetPosition("Research_BetterTrainingArchery", 112, 4)

	XGUIEng.SetWidgetPosition("FindSwordmen", 40, 2)
	XGUIEng.SetWidgetPosition("FindSpearmen", 70, 2)
	XGUIEng.SetWidgetPosition("FindAxemen", 101, 2)
	XGUIEng.SetWidgetPosition("FindCrossBowmen", 131, 2)
	XGUIEng.SetWidgetPosition("FindBowmen", 161, 2)
	XGUIEng.SetWidgetPosition("FindRiflemen", 192, 2)
	XGUIEng.SetWidgetPosition("FindLightCavalry", 228, 2)
	XGUIEng.SetWidgetPosition("FindHeavyCavalry", 259, 2)
	XGUIEng.SetWidgetPosition("FindCannon", 291, 2)
	XGUIEng.SetWidgetPosition("FindScout", 322, 2)
	XGUIEng.SetWidgetPosition("FindThief", 353, 2)

	--XGUIEng.ShowWidget("Research_UpgradeBow2", 0)
	--XGUIEng.ShowWidget("Research_UpgradeBow3", 0)

	MPW.OSI.CombatPlus.PostLoad()
end
--------------------------------------------------------------------------------
function MPW.CombatPlus.Unload()
	--MPW.Log( "CombatPlus.Unload()" )
end