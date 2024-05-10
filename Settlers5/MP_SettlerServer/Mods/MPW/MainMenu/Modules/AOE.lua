--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- PU_Axe
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
MPW.AOE = {}
MPW.Modules.AOE = {
	Dependencies = { "Core" },
	Incompatible = {},
	Name = "Age Of Empires",
	Description = {
		DE = "Basierend auf dem Spiel Age of Empires, startet ihr mit Gründungskarren mit denen ihr die Startposition eurer Burg und Siedlungsplätze selbst bestimmen könnt. @cr @cr @color:220,64,16,255 Warnung @cr Dieses Modul ist in erster Linie für den Multiplayer entworfen. Einige Spielmechaniken in Einzelspielerkarten können durch dieses Modul ausgehebelt werden, wodurch die Karte im schlimmsten Fall nicht mehr gewonnen werden kann.",
		GB = "Based on the game Age of Empires, you start with founder carts with which you can choose the start position of your Keep and Village Centers on you own. @cr @cr @color:220,64,16,255 Warning @cr This module is designed for multiplayer in the first place. Some game mechanics in singelplayer maps could break with this module enabled. Worst case, the map can not be won anymore.",
	},
}
--------------------------------------------------------------------------------
function MPW.AOE.OnInitialize()
	--LuaDebugger.Log( "AOE.OnInitialize()" )
	
	-- create buttons here ( optional )
	-- return false to create a button manually
	
	-- return true to let MPW create a default rule button
	return true
end
--------------------------------------------------------------------------------
function MPW.AOE.OnGUILoaded()
	--LuaDebugger.Log( "AOE.OnGUILoaded()" )
	
	-- set button texts and positions here ( optional )
end
--------------------------------------------------------------------------------
function MPW.AOE.OnMapStart()
	--LuaDebugger.Log( "AOE.OnMapStart()" )

	------------------Entry in entities.xml----------------------------------------
	
	CMod.AppendToXML("data\\config\\entities.xml", [[<Entity>PU_Founder_Cart</Entity>]] )

	------------------Entry in models.xml----------------------------------------
	
	local models = {
		[[<Model id="PU_TraderHammer">
		<SelectionRadius>65</SelectionRadius>
		<Effect>SettlerPlayerColor</Effect>
		<SelectionTexture>Selection_civilian</SelectionTexture>
		<OcclusionReceiver>True</OcclusionReceiver>
	  </Model>]],
	}
	
	for _, model in pairs ( models ) do
		CMod.AppendToXML("data\\config\\models.xml", model)
	end

------------------Entry in tllist.xml----------------------------------------
		
	local tasklists = {
		[[<TaskList>TL_SALESMAN_BECOME_IDLE</TaskList>]],
		[[<TaskList>TL_SALESMAN_BUILD</TaskList>]],
		[[<TaskList>TL_SALESMAN_GO_TO_CONSTRUCTION_SITE</TaskList>]],
		[[<TaskList>TL_SALESMAN_WALK</TaskList>]],
	}

	for _, tl in pairs ( tasklists ) do
		CMod.AppendToXML("data\\config\\tllist.xml", tl);
	end
end


