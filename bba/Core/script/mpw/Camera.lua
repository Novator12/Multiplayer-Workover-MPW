--------------------------------------------------------------------------------
MPW.Camera = {}
--------------------------------------------------------------------------------
function MPW.Camera.Init()
	
	-- ZoomSetFactorMax should be enough
	MPW.Camera.ZoomSetFactorMax = Camera.ZoomSetFactorMax

	-- if we need more, we can consider to copy the whole table
	--for k,v in pairs( Camera ) do
		--MPW.Camera[k] = v
	--end
end
--------------------------------------------------------------------------------
function MPW.Camera.PostInit()
	
	local factor = 2
	
	MPW.Camera.ZoomSetFactorMax( factor )
	Camera.ZoomSetFactor( factor )
	MPW.Camera.ZoomFactorMax = factor
end
--------------------------------------------------------------------------------
-- set local max zoom factor
--------------------------------------------------------------------------------
function GUIAction_SetCameraZoom()
	
	MPW.Camera.ZoomFactorMax = MPW.Camera.ZoomFactorMax + 0.5
	
	if MPW.Camera.ZoomFactorMax > 2.0 then
		MPW.Camera.ZoomFactorMax = 1.0
		MPW.GFXSetHandler.UpdateFog()
	end
	
	MPW.Camera.ZoomSetFactorMax( MPW.Camera.ZoomFactorMax )
end
--------------------------------------------------------------------------------
-- zoomfactor button tooltip
--------------------------------------------------------------------------------
function GUITooltip_ZoomButton()
	XGUIEng.SetText("TooltipBottomText", "@color:180,180,180 Kameraentfernung @cr @color:255,255,255 Die Zoomstufe der Kamera beträgt "..MPW.Camera.ZoomFactorMax.." von 2.")
	XGUIEng.SetText("TooltipBottomCosts", "")
end