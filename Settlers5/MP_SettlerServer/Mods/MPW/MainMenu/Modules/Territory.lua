--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- Territory
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
MPW.Territory = {}
MPW.Modules.Territory = {
	Priority = 90,
	Dependencies = { "Core" },
	Incompatible = {},
	Name = "Territory",
	Description = {
		DE = "Fügt Territorien wie in Die Siedler 4 hinzu. @cr Neben eurer Burg, könnt ihr euer Territorium mit Dorfzentren, Aussichtstürmen und Außenposten erwetern. @cr @cr @color:255,204,51,255 Dieser Spielmodus funktioniert aktuell nur, wenn die Burgen und Aussichtstürme von verschiedenen Spielern zu Spielstart nicht zu dicht stehen. Im laufe des Spiels platzierte Gebäude machen keine Probleme. An einer Lösung wird gearbeitet. @cr @cr @color:220,64,16,255 Warnung @cr Dieses Modul ist in erster Linie für den Multiplayer entworfen. Einige Spielmechaniken in Einzelspielerkarten können durch dieses Modul ausgehebelt werden, wodurch die Karte im schlimmsten Fall nicht mehr gewonnen werden kann.",
		GB = "Adds territories as in The Settlers 4. @cr Beside your Keep, you can expand your territory with Village Centers, Watch Towers and Outposts. @cr @cr @color:255,204,51,255 This gamemode currently only works, if the Keep and Watch Towers of different players have enough space between them. Buildings placed in game are no problem. We work on a solution. @cr @cr @color:220,64,16,255 Warning @cr This module is designed for multiplayer in the first place. Some game mechanics in singelplayer maps could break with this module enabled. Worst case, the map can not be won anymore.",
	},
}
--------------------------------------------------------------------------------
function MPW.Territory.OnInitialize()
	LuaDebugger.Log( "Territory.OnInitialize()" )
	return true
end
--------------------------------------------------------------------------------
function MPW.Territory.OnMapStart()
	LuaDebugger.Log( "Territory.OnMapStart()" )
	
	-- this will only be called if the module is active and all dependencies are met
	-- add xmls here, like Enitites, UpgradeCategories ...
	
	CMod.AppendToXML("data\\config\\entities.xml", [[<Entity>XD_Border</Entity>]])
	CMod.AppendToXML(
		"data\\config\\models.xml",
		[[<Model id="XD_Border">
		<Effect>SimpleObjectPlayerColor</Effect>
		<OcclusionCaster>True</OcclusionCaster>
		<CastShadow>False</CastShadow>
		</Model>]]
	)
	CMod.AppendToXML("data\\config\\technologies.xml", [[<Technology>UP1_Outpost</Technology>]])
	CMod.AppendToXML("data\\config\\technologies.xml", [[<Technology>UP2_Outpost</Technology>]])
end