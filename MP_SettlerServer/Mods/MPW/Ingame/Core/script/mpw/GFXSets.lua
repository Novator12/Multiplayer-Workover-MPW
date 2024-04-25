MPW.GFXSetHandler = {}

---------------------------------------------------------Sommer------------------------------------------------------------
function MPW.GFXSetHandler.InitSummerSet()
	Display.GfxSetSetSkyBox(1, 0.0, 1.0, "YSkyBox07")
	Display.GfxSetSetRainEffectStatus(1, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(1, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(1, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 130 , 150 , 170 , 6000, 23000)
	Display.GfxSetSetLightParams(1, 0.0, 1.0, 40, -15, -50, 145, 155, 165, 240, 220, 100) 
	AddSummer = function(dauer)
		Logic.AddWeatherElement(1, dauer, 0, 1, 5, 15)
	end
end
-- Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 120 , 140 , 160 , 3000, 23000) --bei Zoomstufe 1

---------------------------------------------------------Regen-------------------------------------------------------------
function MPW.GFXSetHandler.InitRainSet()
	Display.GfxSetSetSkyBox(2, 0.0, 1.0, "YSkyBox04")
	Display.GfxSetSetRainEffectStatus(2, 0.0, 1.0, 1)
	Display.GfxSetSetSnowStatus(2, 0, 1.0, 0)
	Display.GfxSetSetSnowEffectStatus(2, 0.0, 0.8, 0)
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 120, 140, 160, 5000, 20000) --ChatGpt-Vorschlag
	Display.GfxSetSetLightParams(2, 0.0, 1.0, 40, -15, -50, 70, 80, 90, 150, 160, 170) --ChatGpt-Vorschlag
	AddRain = function(dauer)
		Logic.AddWeatherElement(2, dauer, 0, 2, 5, 15)
	end
end
-- Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 120, 140, 160, 0, 20000) --bei Zoomstufe 1

---------------------------------------------------------Winter------------------------------------------------------------
function MPW.GFXSetHandler.InitWinterSet()
	Display.GfxSetSetSkyBox(3, 0.0, 1.0, "YSkyBox01")
	Display.GfxSetSetRainEffectStatus(3, 0.0, 1.0, 0)
	Display.GfxSetSetSnowStatus(3, 0, 1.0, 1)
	Display.GfxSetSetSnowEffectStatus(3, 0.0, 0.8, 1)
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 200, 220, 230,  7000 , 22000) --ChatGpt-Vorschlag
	Display.GfxSetSetLightParams(3, 0.0, 1.0, 40, -15, -50, 100, 110 , 120, 200 , 190, 180) --ChatGpt-Vorschlag
	AddSnow = function(dauer)
		Logic.AddWeatherElement(3, dauer, 0, 3, 5, 15)
	end
end
-- Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 200, 220, 230,  0 , 22000) --bei Zoomstufe 1

----------------------------------------------------------------------------------------------------------------------------
function MPW.GFXSetHandler.PostInit()
	
	MPW.GFXSetHandler.InitSummerSet()
	MPW.GFXSetHandler.InitRainSet()
	MPW.GFXSetHandler.InitWinterSet()

	MPW.GFXSetHandler.InputCallback_MouseWheel = InputCallback_MouseWheel
	function InputCallback_MouseWheel( _Forward )
		
		if MPW.GFXSetHandler.InputCallback_MouseWheel then
			MPW.GFXSetHandler.InputCallback_MouseWheel( _Forward )
		end

		MPW.GFXSetHandler.UpdateFog()
	end
end
----------------------------------------------------------------------------------------------------------------------------
function MPW.GFXSetHandler.UpdateFog()
	
	local currentZoom = Camera.GetZoomFactor()
	
	--SummerFog
	local GFXFogSummer = 3000 * currentZoom
	Display.GfxSetSetFogParams(1, 0.0, 1.0, 1, 120 , 140 , 160 , GFXFogSummer , 23000)
	
	--RainFog
	local GFXFogRain = 5000 * currentZoom - 5000
	Display.GfxSetSetFogParams(2, 0.0, 1.0, 1, 120, 140, 160, GFXFogRain, 20000)
	
	--WinterFog
	local GFXFogWinter = 7000 * currentZoom - 7000
	Display.GfxSetSetFogParams(3, 0.0, 1.0, 1, 200, 220, 230,  GFXFogWinter , 22000)
end