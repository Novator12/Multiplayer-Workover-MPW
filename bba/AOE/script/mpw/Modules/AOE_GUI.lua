MPW.AOE.GUIUpdate_BuildingButtons = GUIUpdate_BuildingButtons
GUIUpdate_BuildingButtons = function( _Button, _Technology )
	
	MPW.AOE.GUIUpdate_BuildingButtons( _Button, _Technology )
	
	if _Button == "Build_Headquarters" then
		
		if MPW.AOE.HQ[GUI.GetPlayerID()].Amount >= MPW.AOE.HQ[GUI.GetPlayerID()].Limit then
			
			XGUIEng.DisableButton( _Button, 1 )
		end
		
	elseif _Button == "Build_NeutralVillageCenter" then
		
		if MPW.AOE.VC[GUI.GetPlayerID()].Amount >= MPW.AOE.VC[GUI.GetPlayerID()].Limit then

			XGUIEng.DisableButton( _Button, 1 )
		end
	end
end


MPW.AOE.GUITooltip_ConstructBuilding = GUITooltip_ConstructBuilding
GUITooltip_ConstructBuilding = function( _CategoryType, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut )
	
	local CostString, TooltipText, ShortCutToolTip = MPW.AOE.GUITooltip_ConstructBuilding( _CategoryType, _NormalTooltip, _DisabledTooltip, _TechnologyType, _ShortCut )
	
	if _CategoryType == UpgradeCategories.Headquarters or _CategoryType == UpgradeCategories.NeutralVillageCenter then
		
		local limit = 0
		local amount = 0

		if _CategoryType == UpgradeCategories.Headquarters then
			amount = MPW.AOE.HQ[GUI.GetPlayerID()].Amount
			limit = MPW.AOE.HQ[GUI.GetPlayerID()].Limit
		else
			amount = MPW.AOE.VC[GUI.GetPlayerID()].Amount
			limit = MPW.AOE.VC[GUI.GetPlayerID()].Limit
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