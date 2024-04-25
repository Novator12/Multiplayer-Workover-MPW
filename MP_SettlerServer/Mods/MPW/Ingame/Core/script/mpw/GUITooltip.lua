--------------------------------------------------------------------------------
-- added return values to following functions, to be easyer overwritten
--------------------------------------------------------------------------------
function GUITooltip_ConstructBuilding(_CategoryType, _NormalTooltip, _DiabledTooltip,_TechnologyType, _ShortCut)

	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()

	local PlayerID = GUI.GetPlayerID()	
	Logic.FillBuildingCostsTable( Logic.GetBuildingTypeByUpgradeCategory(_CategoryType, PlayerID ), InterfaceGlobals.CostTable )
	local CostString = InterfaceTool_CreateCostString( InterfaceGlobals.CostTable )
	local TooltipText = " "
	local ShortCutToolTip = " "
	local ShowCosts = 1
	
	if _TechnologyType ~= nil then
	
		local TechState = Logic.GetTechnologyState(PlayerID, _TechnologyType)
		
		if TechState == 0 then
		
			TooltipText =  "MenuGeneric/BuildingNotAvailable"
			ShowCosts = 0
		elseif TechState == 1 or  TechState == 5 then
		
			TooltipText =  _DiabledTooltip
		elseif TechState == 2 or TechState == 3 or TechState == 4 then
		
			TooltipText = _NormalTooltip
			
			if _ShortCut ~= nil then
				ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
			end
		end
	else
		if XGUIEng.IsButtonDisabled(CurrentWidgetID) == 1 then
		
			TooltipText =  _DiabledTooltip
		else
		
			TooltipText = _NormalTooltip
			
			if _ShortCut ~= nil then
				ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
			end
		end
	end
	
	if ShowCosts == 0 then
		CostString = " "
	end
	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
	
	return CostString, XGUIEng.GetStringTableText( TooltipText ), ShortCutToolTip
end
--------------------------------------------------------------------------------
function GUITooltip_UpgradeBuilding(_BuildingType, _DisabledTooltip, _NormalTooltip, _TechnologyType)
	
	local CurrentWidgetID = XGUIEng.GetCurrentWidgetID()
	
	local PlayerID = GUI.GetPlayerID()
	Logic.FillBuildingUpgradeCostsTable( _BuildingType, InterfaceGlobals.CostTable )
	local CostString = InterfaceTool_CreateCostString( InterfaceGlobals.CostTable )
	local TooltipText = " "
	local ShowCosts = 1
	
	local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText("KeyBindings/UpgradeBuilding") .. "]"
	
	if XGUIEng.IsButtonDisabled(CurrentWidgetID) == 1 then
		TooltipText = _DisabledTooltip
	else
		TooltipText = _NormalTooltip
	end
	
	if _TechnologyType ~= nil then
		local TechState = Logic.GetTechnologyState(PlayerID, _TechnologyType)		
		if TechState == 0 then
			TooltipText =  "MenuGeneric/UpgradeNotAvailable"
			ShowCosts = 0
		end
	end
	
	if ShowCosts == 0 then
		CostString = " "
	end
	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
	
	return CostString, XGUIEng.GetStringTableText( TooltipText ), ShortCutToolTip
end
--------------------------------------------------------------------------------
function GUITooltip_NormalButton(_TooltipString, _ShortCut)
	local CostString = " "
	local ShortCutToolTip = " "
	
	if _ShortCut ~= nil then
		ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
	end

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, _TooltipString)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

	return CostString, XGUIEng.GetStringTableText( _TooltipString ), ShortCutToolTip
end
--------------------------------------------------------------------------------
function GUITooltip_Generic(_TooltipString)
	local CostString, TooltipText, ShortCutToolTip = GUITooltip_NormalButton(_TooltipString)

	local widget = XGUIEng.GetCurrentWidgetID()
	local resourcekey
	if widget == XGUIEng.GetWidgetID("GoldTooltipController") then
		resourcekey = "Gold"
	elseif widget == XGUIEng.GetWidgetID("ClayTooltipController") then
		resourcekey = "Clay"
	elseif widget == XGUIEng.GetWidgetID("WoodTooltipController") then
		resourcekey = "Wood"
	elseif widget == XGUIEng.GetWidgetID("StoneTooltipController") then
		resourcekey = "Stone"
	elseif widget == XGUIEng.GetWidgetID("IronTooltipController") then
		resourcekey = "Iron"
	elseif widget == XGUIEng.GetWidgetID("SulfurTooltipController") then
		resourcekey = "Sulfur"
	end

	if resourcekey then
		TooltipText = TooltipText .. " @cr @cr Rohstoff: " .. Logic.GetPlayersGlobalResource(GUI.GetPlayerID(), ResourceType[resourcekey .. "Raw"]) .. " @cr Veredelt: " .. Logic.GetPlayersGlobalResource(GUI.GetPlayerID(), ResourceType[resourcekey])
		XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	end

	return CostString, TooltipText, ShortCutToolTip
end
--------------------------------------------------------------------------------
function GUITooltip_BuyMilitaryUnit(_UpgradeCategory,_NormalTooltip,_DisabledTooltip, _TechnologyType,_ShortCut)
	local PlayerID = GUI.GetPlayerID()
	local SettlerTypeID = Logic.GetSettlerTypeByUpgradeCategory(_UpgradeCategory, PlayerID)
	
	Logic.FillLeaderCostsTable(PlayerID, _UpgradeCategory, InterfaceGlobals.CostTable)
	local CostString = InterfaceTool_CreateCostString( InterfaceGlobals.CostTable ) .. XGUIEng.GetStringTableText("InGameMessages/GUI_NamePlaces") .. ": "
	local TooltipText = _NormalTooltip
	local costcolor = "@color:220,64,16,255 "
	local NeededPlaces = Logic.GetAttractionLimitValueByEntityType(SettlerTypeID)
	local slotsused, slotamount = Logic.GetPlayerAttractionUsage(PlayerID), Logic.GetPlayerAttractionLimit(PlayerID)
	local ShortCutToolTip = " "
	
	if slotsused + NeededPlaces <= slotamount then
		costcolor = "@color:155,230,112,255 "
	end

	CostString = CostString .. costcolor .. NeededPlaces
	
	if _TechnologyType ~= nil then
		local TechState = Logic.GetTechnologyState(PlayerID, _TechnologyType)
		if TechState == 0 then
			TooltipText =  "MenuGeneric/UnitNotAvailable"
			CostString = " "
		elseif TechState == 1 then
			TooltipText = _DisabledTooltip
		end
	end
	
	if _ShortCut ~= nil then
		ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
	end
	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)

	return CostString, XGUIEng.GetStringTableText(TooltipText), ShortCutToolTip
end
--------------------------------------------------------------------------------
function GUITooltip_BuySerf()
	Logic.FillSerfCostsTable(InterfaceGlobals.CostTable)
	local CostString = InterfaceTool_CreateCostString( InterfaceGlobals.CostTable ) .. XGUIEng.GetStringTableText("InGameMessages/GUI_NamePlaces") .. ": "
	local ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText("KeyBindings/BuyUnits1") .. "]"
	local player = GUI.GetPlayerID()
	local costcolor = "@color:220,64,16,255 "
	local nserfs, maxserfs = MPW.AttractionLimit.GetNumberOfAdditionalSerfsOfPlayer(player), MPW.AttractionLimit.MaxAdditionalSerfs
	local nslots = Logic.GetAttractionLimitValueByEntityType(Entities.PU_Serf)

	if Logic.GetPlayerAttractionLimit(player) + maxserfs > Logic.GetPlayerAttractionUsage(player) + nserfs then
		if nserfs + nslots <= maxserfs then
			costcolor = "@color:155,230,112,255 "
		else
			costcolor = "@color:255,204,51,255 "
		end
	end

	CostString = CostString .. costcolor .. nslots

	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText,"MenuHeadquarter/BuySerf")
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
	
	return CostString, XGUIEng.GetStringTableText(TooltipText), ShortCutToolTip
end
--------------------------------------------------------------------------------
-- added technology param and return values to this function, to be easyer overwritten
--------------------------------------------------------------------------------
function GUITooltip_HeroButton( _TechnologyType, _Tooltip, _ShortCut )
	
	local PlayerID = GUI.GetPlayerID()
	local TechState = 2

	if _TechnologyType then
		TechState = Logic.GetTechnologyState(PlayerID, _TechnologyType)
	end

	local CostString = " "
	local TooltipText = " "
	local ShortCutToolTip = " "
	
	if TechState == 0 then
	
		TooltipText =  "MenuGeneric/TechnologyNotAvailable"
	elseif TechState == 1 or  TechState == 5 then
	
		TooltipText =  _Tooltip .. "_disabled"
	elseif TechState == 2 or TechState == 3 or TechState == 4 then
	
		TooltipText = _Tooltip
		if _ShortCut ~= nil then
			ShortCutToolTip = XGUIEng.GetStringTableText("MenuGeneric/Key_name") .. ": [" .. XGUIEng.GetStringTableText(_ShortCut) .. "]"
		end
	end
	
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomCosts, CostString)
	XGUIEng.SetTextKeyName(gvGUI_WidgetID.TooltipBottomText, TooltipText)
	XGUIEng.SetText(gvGUI_WidgetID.TooltipBottomShortCut, ShortCutToolTip)
	
	return CostString, XGUIEng.GetStringTableText( TooltipText ), ShortCutToolTip
end

HeroInfoTable = {

	[Entities.PU_Hero1c] = {
		Name = "Dario",
		Abilities = {
			[1] = "Falkenauge",
			[2] = "Vertreiben",
			[3] = "Aura d. Freude"
		},
		Technologies = {
			[1] = "Fernglas",
			[2] = "Wehrpflicht",  --Fehler in StringTableKey t fehlt
			[3] = "Bildung"
		},

	},

	[Entities.PU_Hero2] = {
		Name = "Pilgrim",
		Abilities = {
			[1] = "Bombe",
			[2] = "Kanone",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Legierung",
			[2] = "Architektur",
			[3] = "-None-"
		},

	},

	[Entities.PU_Hero3] = {
		Name = "Salim",
		Abilities = {
			[1] = "Falle",
			[2] = "Heilen",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Flaschenzug",
			[2] = "Alchemie",
			[3] = "-None-"
		},

	},

	[Entities.PU_Hero4] = {
		Name = "Erec",
		Abilities = {
			[1] = "Wirbelschlag",
			[2] = "Aura d. Stärke",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Pferdezucht",
			[2] = "Taktiken",
			[3] = "-None-"
		},

	},

	[Entities.PU_Hero5] = {
		Name = "Ari",
		Abilities = {
			[1] = "Tarnen",
			[2] = "Banditen",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Konstruktion",
			[2] = "Stehendes Heer",
			[3] = "-None-"
		},

	},

	[Entities.PU_Hero6] = {
		Name = "Helias",
		Abilities = {
			[1] = "Überzeugen",
			[2] = "Segnen",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Bücherein",
			[2] = "Buchdruck",
			[3] = "-None-"
		},

	},

	[Entities.CU_BlackKnight] = {
		Name = "Kerberos",
		Abilities = {
			[1] = "Höllenschrei",
			[2] = "Aura d. Furcht",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Wehrpflicht",
			[2] = "Buchdruck",
			[3] = "-None-"
		},

	},

	[Entities.CU_Mary_de_Mortfichet] = {
		Name = "Mary de Mortfichet",
		Abilities = {
			[1] = "Gift",
			[2] = "Demoralisieren",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Chemie",
			[2] = "Metallurgie",
			[3] = "-None-"
		},

	},

	[Entities.CU_Barbarian_Hero] = {
		Name = "Varg",
		Abilities = {
			[1] = "Wolfsbrut",
			[2] = "Berserkerwut",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Stehendes Heer",
			[2] = "Taktiken",
			[3] = "-None-"
		},

	},

	[Entities.PU_Hero10] = {
		Name = "Drake",
		Abilities = {
			[1] = "Meisterschuss",
			[2] = "Feuerkraft",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Gezogener Lauf",
			[2] = "Luntenschloss",
			[3] = "-None-"
		},

	},

	[Entities.PU_Hero11] = {
		Name = "Yuki",
		Abilities = {
			[1] = "Shuriken",
			[2] = "Feuerw. d. Furcht",
			[3] = "Feuerw. d. Freude"
		},
		Technologies = {
			[1] = "Zahnrad",
			[2] = "Mathematik",
			[3] = "Bildung"
		},

	},

	[Entities.CU_Evil_Queen] = {
		Name = "Kala",
		Abilities = {
			[1] = "Giftpfeile",
			[2] = "Giftnebel",
			[3] = "-None-"
		},
		Technologies = {
			[1] = "Chemie",
			[2] = "Legierung",
			[3] = "-None-"
		},

	},
}

--setting text in hero buy window
function GUITooltip_BuyHeroText(_EntityType)
	for k,v in pairs(HeroInfoTable) do
		--filter for herotype
		if k == _EntityType then

			XGUIEng.SetTextColor("BuyHeroInfoAbillityHead",75,139,59)
			XGUIEng.SetTextColor("BuyHeroInfoTechHead",75,139,59)

			local TooltipText = HeroInfoTable[_EntityType].Name
			XGUIEng.SetText("BuyHeroInfoName","@center "..TooltipText)
			if k == Entities.PU_Hero1c or k == Entities.PU_Hero2 or k == Entities.PU_Hero3 or k == Entities.PU_Hero4 or k == Entities.PU_Hero5 or k == Entities.PU_Hero6 or k == Entities.PU_Hero10 or k == Entities.PU_Hero11 then    
				XGUIEng.SetTextColor("BuyHeroInfoName",102,197,238)
			else
				XGUIEng.SetTextColor("BuyHeroInfoName",102,0,25)
			end

			for i = 1,3 do
				local TooltipText = HeroInfoTable[_EntityType].Abilities[i]
				XGUIEng.SetText("BuyHeroInfoAbillity"..i,"@center "..TooltipText)
			end

			for i = 1,3 do
				local TooltipText = HeroInfoTable[_EntityType].Technologies[i]
				XGUIEng.SetText("BuyHeroInfoTech"..i,"@center "..TooltipText)
			end

			break
		end
	end
end
--------------------------------------------------------------------------------
-- colored cost strings by play4fun
--------------------------------------------------------------------------------
function InterfaceTool_CreateCostString( _Costs )
	
	local PlayerID = GUI.GetPlayerID()
	
	local PlayerGold = GetGold(PlayerID)
	local PlayerWood = GetWood(PlayerID)
	local PlayerClay = GetClay(PlayerID)
	local PlayerIron = GetIron(PlayerID)
	local PlayerStone = GetStone(PlayerID)
	local PlayerSulfur = GetSulfur(PlayerID)
	local CostString = ""
	
	-- color scheme
	local cWhite = " @color:255,255,255,255 "
	
	local cNormal = " @color:255,204,51,255 "
	local cEnoughRefined = " @color:155,230,112,255 "
	local cNotEnough = " @color:220,64,16,255 "
	
	-- workaround: costs can either be in the form of "gold = 100" or "[ResourceType.Gold] = 100" or "Gold = 100"
	_Costs.gold = _Costs.gold or _Costs[ResourceType.Gold] or _Costs.Gold
	_Costs.wood = _Costs.wood or _Costs[ResourceType.Wood] or _Costs.Wood
	_Costs.clay = _Costs.clay or _Costs[ResourceType.Clay] or _Costs.Clay
	_Costs.stone = _Costs.stone or _Costs[ResourceType.Stone] or _Costs.Stone
	_Costs.iron = _Costs.iron or _Costs[ResourceType.Iron] or _Costs.Iron
	_Costs.sulfur = _Costs.sulfur or _Costs[ResourceType.Sulfur] or _Costs.Sulfur
	
	if _Costs.gold and _Costs.gold > 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameMoney") .. ": "
		local color = cNormal
		if PlayerGold >= _Costs.gold then
			if Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Gold ) >= _Costs.gold then
				color = cEnoughRefined
			end
		else
			color = cNotEnough
		end
		CostString = CostString .. color .. _Costs.gold .. cWhite .. " @cr "
	end
	
	if _Costs.wood and _Costs.wood > 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameWood") .. ": "
		local color = cNormal
		if PlayerWood >= _Costs.wood then
			if Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Wood ) >= _Costs.wood then
				color = cEnoughRefined
			end
		else
			color = cNotEnough
		end
		CostString = CostString .. color .. _Costs.wood .. cWhite .. " @cr "
	end
	
	if _Costs.clay and _Costs.clay > 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameClay") .. ": "
		local color = cNormal
		if PlayerClay >= _Costs.clay then
			if Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Clay ) >= _Costs.clay then
				color = cEnoughRefined
			end
		else
			color = cNotEnough
		end
		CostString = CostString .. color .. _Costs.clay .. cWhite .. " @cr "
	end
			
	if _Costs.stone and _Costs.stone > 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameStone") .. ": "
		local color = cNormal
		if PlayerStone >= _Costs.stone then
			if Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Stone ) >= _Costs.stone then
				color = cEnoughRefined
			end
		else
			color = cNotEnough
		end
		CostString = CostString .. color .. _Costs.stone .. cWhite .. " @cr "
	end
	
	if _Costs.iron and _Costs.iron > 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameIron") .. ": "
		local color = cNormal
		if PlayerIron >= _Costs.iron then
			if Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Iron ) >= _Costs.iron then
				color = cEnoughRefined
			end
		else
			color = cNotEnough
		end
		CostString = CostString .. color .. _Costs.iron .. cWhite .. " @cr "
	end
		
	if _Costs.sulfur and _Costs.sulfur > 0 then
		CostString = CostString .. XGUIEng.GetStringTableText("InGameMessages/GUI_NameSulfur") .. ": "
		local color = cNormal
		if PlayerSulfur >= _Costs.sulfur then
			if Logic.GetPlayersGlobalResource( PlayerID, ResourceType.Sulfur ) >= _Costs.sulfur then
				color = cEnoughRefined
			end
		else
			color = cNotEnough
		end
		CostString = CostString .. color .. _Costs.sulfur .. cWhite .. " @cr "
	end
	
	-- operating on the _Costs table also changes this global table - must be reset!
	InterfaceGlobals.CostTable = {}
	
	return CostString
end