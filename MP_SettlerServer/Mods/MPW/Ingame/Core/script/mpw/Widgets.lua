--------------------------------------------------------------------------------
-- MPW.Widgets = {}
--------------------------------------------------------------------------------
function MPW.Widgets_Init()
	WidgetHelper.AddPreCommitCallback(
		function()
			
			-- add technology dependency and change tooltips for hero abilities
			CWidget.Transaction_RemoveWidget("Selection_Hero")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Selection_Hero.xml", "Selection_BattleSerf")
			
			-- add shortcuts and change tooltips for build beatification buttons
			CWidget.Transaction_RemoveWidget("SerfBeautificationMenu")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\SerfBeautificationMenu.xml", "SerfConstructionMenu")
			
			-- add shortcut for switch serf menu buttons
			CWidget.Transaction_RemoveWidget("SerfToConstructionMenu")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\SerfToConstructionMenu.xml")
			
			CWidget.Transaction_RemoveWidget("SerfToBeautificationMenu")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\SerfToBeautificationMenu.xml")
			
			-- add shortcut for switch building menu buttons
			CWidget.Transaction_RemoveWidget("ToBuildingSettlersMenu")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\ToBuildingSettlersMenu.xml")
			
			CWidget.Transaction_RemoveWidget("ToBuildingCommandMenu")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\ToBuildingCommandMenu.xml")
			
			-- add shortcuts for buildings settler menu
			CWidget.Transaction_RemoveWidget("WorkerInBuilding")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\WorkerInBuilding.xml", "EaterInBuilding")
			
			-- add shortcuts for formations
			CWidget.Transaction_RemoveWidget("Commands_Leader")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Commands_Leader.xml")
			
			-- change shortcuts for technologies
			CWidget.Transaction_RemoveWidget("Commands_Tavern")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Commands_Tavern.xml")
			
			-- change shortcuts for last technology row
			CWidget.Transaction_RemoveWidget("Commands_University")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Commands_University.xml")
			
			-- change shortcuts for technologies
			CWidget.Transaction_RemoveWidget("Commands_GunsmithWorkshop")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Commands_GunsmithWorkshop.xml")
			
			-- enable T1 techs in T1 Sawmill
			CWidget.Transaction_RemoveWidget("Commands_Sawmill")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Commands_Sawmill.xml")
			
			-- add drop and pickup button to thief menu
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Thief_DropLoot.xml")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Thief_PickUpLoot.xml")
			
			-- add max zoom button to minimap
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\ZoomButton.xml")
			
			-- add expel hero troll button
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Commands_HeroContainer.xml", "Command_Attack")
			
			-- add HeroInfoText statictextwidget for overview of technology dependencies when hero gets selected
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\BuyHeroInfo.xml", "BuyHeroWindowCloseButton")
			
			--remove old buyherowidgets and add new one
			for i = 1,12,1 do
				CWidget.Transaction_RemoveWidget("BuyHeroWindowBuyHero"..i)
			end
			
			CWidget.Transaction_RemoveWidget("BuyHeroLine1")
			
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\BuyHeroSelectionHero.xml", "BuyHeroInfo")

			-- replace townguard with cityguard and switch order with loom
			-- new: loom > cityguatd > shoes
			CWidget.Transaction_RemoveWidget("Research_TownGuard")
			CWidget.Transaction_RemoveWidget("Research_Loom")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Research_Loom.xml", "Research_Shoes")
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\Research_CityGuard.xml", "Research_Shoes")
			
			-- add population additional serfs
			-- this is a workaround, since @ra formating kills following @color formatings
			CWidget.Transaction_AddRawWidgetsFromFile("data\\menu\\projects\\PopulationAdditionalSerfs.xml")
		end
	)
end
--------------------------------------------------------------------------------
function MPW.Widgets_Load()
	
	-- if its an ems map, the GUI will be loaded by ems script
	-- the above defined callback will then modify the ems.xml
	if not MPW.IsEMS then
		CWidget.LoadGUI( "data\\menu\\projects\\ingame.xml" )
	end
end
--------------------------------------------------------------------------------
function MPW.Widgets_PostLoad()
	
	-- allign buttons to the grid ( starts at 4, button size 32, gap of 4 ... )
	-- 4 40 76 112 148 184 220 256 292 328 364 400
	
	-- buildings
	-- generic
	XGUIEng.SetWidgetPosition( "ResearchProgress", 118, 59 )
	XGUIEng.SetWidgetPosition( "CancelResearch", 76, 47 )
	XGUIEng.SetWidgetPosition( "CancelUpgrade", 76, 47 )
	XGUIEng.SetWidgetPosition( "DestroyBuilding", 400, 164 )
	
	XGUIEng.SetWidgetPositionAndSize( "ToggleRecruitGroups", 360, 88, 40, 40 )
	XGUIEng.SetWidgetPositionAndSize( "Activate_RecruitSingleLeader", 4, 4, 32, 32 )
	XGUIEng.SetWidgetPositionAndSize( "Activate_RecruitGroups", 4, 4, 32, 32 )
	
	XGUIEng.SetWidgetPosition( "WorkerContainer1", 5, 0 )
	XGUIEng.SetWidgetPosition( "WorkerContainer2", 67, 0 )
	XGUIEng.SetWidgetPosition( "WorkerContainer3", 129, 0 )
	XGUIEng.SetWidgetPosition( "WorkerContainer4", 191, 0 )
	XGUIEng.SetWidgetPosition( "WorkerContainer5", 253, 0 )
	XGUIEng.SetWidgetPosition( "WorkerContainer6", 315, 0 )
	XGUIEng.SetWidgetPosition( "WorkerContainer7", 5, 55 )
	XGUIEng.SetWidgetPosition( "WorkerContainer8", 67, 55 )
	XGUIEng.SetWidgetPosition( "WorkerContainer9", 129, 55 )
	XGUIEng.SetWidgetPosition( "WorkerContainer10", 191, 55 )
	XGUIEng.SetWidgetPosition( "WorkerContainer11", 253, 55 )
	XGUIEng.SetWidgetPosition( "WorkerContainer12", 315, 55 )
	XGUIEng.SetWidgetPosition( "OvertimesButton_Recharge", 400, 76 )
	XGUIEng.SetWidgetPosition( "OvertimesButtonDisable", 400, 76 )
	XGUIEng.SetWidgetPosition( "OvertimesButtonEnable", 400, 76 )
	XGUIEng.SetWidgetPosition( "WorkerBackToBuilding", 400, 4 )

	-- foundry
	XGUIEng.SetWidgetPosition( "CannonProgress", 118, 59 )
	XGUIEng.SetWidgetPosition( "Upgrade_Foundry1", 400, 4 )
	XGUIEng.SetWidgetPosition( "BuyCannon4", 112, 4 )
	XGUIEng.SetWidgetPosition( "Research_BetterChassis", 40, 40 )
	
	-- headquarter
	XGUIEng.SetWidgetPosition( "Upgrade_Headquarter1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Headquarter2", 400, 4 )
	XGUIEng.SetWidgetPosition( "ActivateAlarm_Recharge", 364, 76 )
	XGUIEng.SetWidgetPosition( "ActivateAlarm", 364, 76 )
	XGUIEng.SetWidgetPosition( "QuitAlarm", 364, 76 )
	XGUIEng.SetWidgetPosition( "Levy_Duties", 76, 4 )
	XGUIEng.SetWidgetPosition( "HQTaxes", 136, 4 )
	
	-- barracks
	XGUIEng.SetWidgetPosition( "Upgrade_Barracks1", 400, 4 )
	
	-- university
	XGUIEng.SetWidgetPosition( "Upgrade_University1", 400, 4 )
	
	-- iron mine
	XGUIEng.SetWidgetPosition( "Upgrade_Ironmine1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Ironmine2", 400, 4 )
	
	-- stone mine
	XGUIEng.SetWidgetPosition( "Upgrade_Stonemine1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Stonemine2", 400, 4 )
	
	-- sulfur mine
	XGUIEng.SetWidgetPosition( "Upgrade_Sulfurmine1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Sulfurmine2", 400, 4 )
	
	-- farm
	XGUIEng.SetWidgetPosition( "Upgrade_Farm1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Farm2", 400, 4 )
	
	-- residence
	XGUIEng.SetWidgetPosition( "Upgrade_Residence1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Residence2", 400, 4 )
	
	-- village
	XGUIEng.SetWidgetPosition( "Upgrade_Village1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Village2", 400, 4 )
	XGUIEng.SetWidgetPosition( "Research_Loom", 4, 4 )
	XGUIEng.SetWidgetPosition( "Research_Shoes", 76, 4 )
	
	-- alchemist
	XGUIEng.SetWidgetPosition( "Upgrade_Alchemist1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Research_BlisteringCannonballs", 76, 4 )
	XGUIEng.SetWidgetPosition( "Research_WeatherForecast", 40, 40 )
	XGUIEng.SetWidgetPosition( "Research_ChangeWeather", 76, 40 )
	
	-- blacksmith
	XGUIEng.SetWidgetPosition( "Upgrade_Blacksmith1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Blacksmith2", 400, 4 )
	XGUIEng.SetWidgetPosition( "Research_PlateMailArmor", 76, 4 )
	XGUIEng.SetWidgetPosition( "Research_PaddedArcherArmor", 40, 40 )
	XGUIEng.SetWidgetPosition( "Research_LeatherArcherArmor", 76, 40 )
	XGUIEng.SetWidgetPosition( "Research_LeatherMailArmor", 4, 4 )
	XGUIEng.SetWidgetPosition( "Research_SoftArcherArmor", 4, 40 )
	XGUIEng.SetWidgetPosition( "Research_MasterOfSmithery", 40, 76 )
	
	-- stonemason
	XGUIEng.SetWidgetPosition( "Upgrade_Stonemason1", 400, 4 )
	
	-- bank
	XGUIEng.SetWidgetPosition( "Upgrade_Bank1", 400, 4 )
	
	-- monastery
	XGUIEng.SetWidgetPosition( "Upgrade_Monastery1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Monastery2", 400, 4 )
	XGUIEng.SetWidgetPosition( "FaithProgress", 118, 59 )
	XGUIEng.SetWidgetPosition( "BlessSettlers1", 134, 8 )
	XGUIEng.SetWidgetPosition( "BlessSettlers2", 170, 8 )
	XGUIEng.SetWidgetPosition( "BlessSettlers3", 206, 8 )
	XGUIEng.SetWidgetPosition( "BlessSettlers4", 242, 8 )
	XGUIEng.SetWidgetPosition( "BlessSettlers5", 278, 8 )
	
	-- market
	XGUIEng.SetWidgetPosition( "Upgrade_Market1", 400, 4 )
	XGUIEng.SetWidgetPosition( "TradeProgress", 118, 59 )
	XGUIEng.SetWidgetPosition( "CancelTrade", 76, 47 )
	
	-- archery
	XGUIEng.SetWidgetPosition( "Upgrade_Archery1", 400, 4 )
	
	-- stables
	XGUIEng.SetWidgetPosition( "Upgrade_Stables1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Research_Shoeing", 76, 4 )
	XGUIEng.SetWidgetPosition( "Buy_LeaderCavalryHeavy", 40, 4 )
	XGUIEng.SetWidgetPosition( "Research_UpgradeCavalryHeavy1", 40, 40 )
	
	-- clay mine
	XGUIEng.SetWidgetPosition( "Upgrade_Claymine1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Claymine2", 400, 4 )
	XGUIEng.SetWidgetPosition( "Research_PickAxe", 40, 4 )
	
	-- brickworks
	XGUIEng.SetWidgetPosition( "Upgrade_Brickworks1", 400, 4 )
	
	-- tower
	XGUIEng.SetWidgetPosition( "Upgrade_Tower1", 400, 4 )
	XGUIEng.SetWidgetPosition( "Upgrade_Tower2", 400, 4 )
	
	-- sawmill
	XGUIEng.SetWidgetPosition( "Upgrade_Sawmill1", 400, 4 )
	
	-- tavern
	XGUIEng.SetWidgetPosition( "Upgrade_Tavern1", 400, 4 )
	
	-- gunsmith workshop
	XGUIEng.SetWidgetPosition( "Upgrade_GunsmithWorkshop1", 400, 4 )
	
	-- powerplant
	XGUIEng.SetWidgetPosition( "PowerPlant_WeatherEnergyProgress", 118, 59 )
	XGUIEng.SetWidgetPositionAndSize( "PowerPlant_EnergyIcon", 76, 47, 32, 32 )
	
	-- weather tower
	XGUIEng.SetWidgetPosition( "WeatherEnergyProgress", 118, 59 )
	XGUIEng.SetWidgetPositionAndSize( "Weather_EnergyIcon", 76, 47, 32, 32 )
	
	-- mercenary tent
	XGUIEng.SetWidgetPosition( "TroopMerchant_ExitFrame", 400, 76 )
	XGUIEng.SetWidgetPosition( "TroopMerchant_Exit", 403, 79 )
	
	-- units
	-- serf
	XGUIEng.SetWidgetPosition( "Build_Barracks", 364, 4 )
	XGUIEng.SetWidgetPosition( "Build_Archery", 400, 4 )
	XGUIEng.SetWidgetPosition( "Build_Stables", 364, 40 )
	XGUIEng.SetWidgetPosition( "Build_Foundry", 400, 40 )
	XGUIEng.SetWidgetPosition( "Build_Tower", 328, 4 )
	XGUIEng.SetWidgetPosition( "Build_Outpost", 328, 40 )
	XGUIEng.SetWidgetPosition( "Build_Weathermachine", 220, 40 )
	XGUIEng.SetWidgetPosition( "Build_PowerPlant", 256, 40 )
	XGUIEng.SetWidgetPosition( "ChangeIntoBattleSerf", 364, 76 )
	XGUIEng.SetWidgetPosition( "ExpelSerf", 400, 76 )
	
	XGUIEng.SetWidgetPosition( "Build_Beautification01", 40, 76 )
	XGUIEng.SetWidgetPosition( "Build_Beautification02", 40, 40 )
	XGUIEng.SetWidgetPosition( "Build_Beautification03", 112, 76 )
	XGUIEng.SetWidgetPosition( "Build_Beautification04", 4, 76 )
	XGUIEng.SetWidgetPosition( "Build_Beautification05", 76, 76 )
	XGUIEng.SetWidgetPosition( "Build_Beautification06", 4, 40 )
	XGUIEng.SetWidgetPosition( "Build_Beautification07", 76, 40 )
	XGUIEng.SetWidgetPosition( "Build_Beautification10", 112, 40 )
	XGUIEng.SetWidgetPosition( "BeautificationMenu_ChangeIntoBattleSerf", 364, 76 )
	XGUIEng.SetWidgetPosition( "BeautificationMenu_ExpelSerf", 400, 76 )
	
	XGUIEng.SetWidgetPosition( "ChangeIntoSerf", 364, 164 )
	
	-- military
	XGUIEng.SetWidgetPosition( "Command_Attack", 76, 4 )
	XGUIEng.SetWidgetPosition( "Command_Expel", 400, 76 )
	
	-- worker
	XGUIEng.SetWidgetPosition( "SettlerBackToSettler", 400, 4 )
	XGUIEng.SetWidgetPosition( "ExpelWorker", 400, 76 )

	-- population
	XGUIEng.SetWidgetPositionAndSize( "PopulationLimit", 36, 130, 56, 26 )
	XGUIEng.SetWidgetPositionAndSize( "PolulationTooltipController", 0, 0, 56, 26 )
end