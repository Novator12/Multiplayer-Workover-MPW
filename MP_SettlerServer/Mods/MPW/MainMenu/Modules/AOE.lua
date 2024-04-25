--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- PU_Axe
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
MPW.AOE = {}
MPW.Modules.AOE = {
	Dependencies = { "Core" },
	Incompatible = {},
	Name = "Age Of Empires",
	Description = "Basierend auf dem Spiel Age of Empires, startet ihr mit Handelskarren mit denen ihr die Startposition eurer Burg und Siedlungsplätze selbst bestimmen könnt."
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


