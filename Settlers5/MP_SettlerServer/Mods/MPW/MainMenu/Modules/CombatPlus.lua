--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
-- CombatPlus
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
MPW.CombatPlus = {}
MPW.Modules.CombatPlus = {
	Dependencies = { "Core" },
	Incompatible = {},
	Name = "Combat Plus",
	Description = {
		DE = "Fügt dem Spiel Axtkrieger hinzu und separiert Armbrustschützen von Begenschützen. Außerdem können Kanonen deutlich schneller rekrutiert werden und nehmen eine anderer Rolle im Balancing ein.",
		GB = "Adds axe warriors as a new unit type to the game and separates Crossbowmen from Archers. Additionaly cannons can be recruited much faster and play a different roll in the unit balancing. ",
	},
}
--------------------------------------------------------------------------------
function MPW.CombatPlus.OnInitialize()
	--LuaDebugger.Log( "CombatPlus.OnInitialize()" )
	
	-- create buttons here ( optional )
	-- return false to create a button manually
	
	-- return true to let MPW create a default rule button
	return true
end
--------------------------------------------------------------------------------
function MPW.CombatPlus.OnGUILoaded()
	--LuaDebugger.Log( "CombatPlus.OnGUILoaded()" )
	
	-- set button texts and positions here ( optional )
end
--------------------------------------------------------------------------------
function MPW.CombatPlus.OnMapStart()
	--LuaDebugger.Log( "CombatPlus.OnMapStart()" )

	------------------Entry in animsets.xml-------------------------------------
	
	local animsets = {
		[[<AnimSet>SET_SOLDIERAXE3</AnimSet>]],
		[[<AnimSet>SET_LEADERAXE3</AnimSet>]],
	}
	
	for _, animset in pairs ( animsets ) do
		CMod.AppendToXML("data\\config\\animsets.xml", animset );
	end
		
	------------------Entry in entities.xml-------------------------------------
	
	local entities = {
		[[<Entity>PU_LeaderAxe1</Entity>]],
        [[<Entity>PU_LeaderAxe2</Entity>]],
        [[<Entity>PU_LeaderAxe3</Entity>]],
        [[<Entity>PU_LeaderAxe4</Entity>]],

		[[<Entity>PU_SoldierAxe1</Entity>]],
		[[<Entity>PU_SoldierAxe2</Entity>]],
        [[<Entity>PU_SoldierAxe3</Entity>]],
        [[<Entity>PU_SoldierAxe4</Entity>]],

		[[<Entity>PU_LeaderCrossBow1</Entity>]],
        [[<Entity>PU_LeaderCrossBow2</Entity>]],

		[[<Entity>PU_SoldierCrossBow1</Entity>]],
		[[<Entity>PU_SoldierCrossBow2</Entity>]],
	}
	
	for _, entity in pairs ( entities ) do
		CMod.AppendToXML("data\\config\\entities.xml", entity );
	end
	
	------------------Entry in logic.xml-----------------------------------------
	
	local settlerupgrades = {
		[[<SettlerUpgrade>
			<Category>LeaderAxe</Category>
			<FirstSettler>PU_LeaderAxe1</FirstSettler>
		</SettlerUpgrade>]],
	
		[[<SettlerUpgrade>
			<Category>SoldierAxe</Category>
			<FirstSettler>PU_SoldierAxe1</FirstSettler>
		</SettlerUpgrade>]],

		[[<SettlerUpgrade>
			<Category>LeaderCrossbow</Category>
			<FirstSettler>PU_LeaderCrossbow1</FirstSettler>
		</SettlerUpgrade>]],
	
		[[<SettlerUpgrade>
			<Category>SoldierCrossbow</Category>
			<FirstSettler>PU_SoldierCrossbow1</FirstSettler>
		</SettlerUpgrade>]],
	}
	
	for _, settlerupgrade in pairs ( settlerupgrades ) do
		CMod.AppendToXML("data\\config\\logic.xml", settlerupgrade);
	end

	------------------Entry in models.xml----------------------------------------
	
	local models = {

		[[<Model id="PU_LeaderAxe1">
			<SelectionRadius>80</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],
	
		[[<Model id="PU_SoldierAxe1">
			<SelectionRadius>75</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<SelectionTexture>Selection_Soldier</SelectionTexture>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],

		[[<Model id="PU_LeaderAxe2">
			<SelectionRadius>80</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],
	
		[[<Model id="PU_SoldierAxe2">
			<SelectionRadius>75</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<SelectionTexture>Selection_Soldier</SelectionTexture>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],

		[[<Model id="PU_LeaderAxe3">
			<SelectionRadius>80</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],
	
		[[<Model id="PU_SoldierAxe3">
			<SelectionRadius>75</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<SelectionTexture>Selection_Soldier</SelectionTexture>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],
	
		[[<Model id="PU_LeaderAxe4">
			<SelectionRadius>80</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],
	
		[[<Model id="PU_SoldierAxe4">
			<SelectionRadius>75</SelectionRadius>
			<Effect>SettlerPlayerColorSpecular</Effect>
			<SelectionTexture>Selection_Soldier</SelectionTexture>
			<OcclusionReceiver>True</OcclusionReceiver>
		</Model>]],
	}
	
	for _, model in pairs ( models ) do
		CMod.AppendToXML("data\\config\\models.xml", model);
	end

	------------------Entry in technologies.xml----------------------------------------
	
	local technologies = {
		[[<Technology>MU_LeaderAxe</Technology>]],
		[[<Technology>MU_LeaderAxe2</Technology>]],
		[[<Technology>MU_LeaderAxe3</Technology>]],
		[[<Technology>MU_LeaderAxe4</Technology>]],
		[[<Technology>T_UpgradeAxe1</Technology>]],
		[[<Technology>T_UpgradeAxe2</Technology>]],
		[[<Technology>T_UpgradeAxe3</Technology>]],

		[[<Technology>MU_LeaderCrossBow</Technology>]],
		[[<Technology>MU_LeaderCrossBow2</Technology>]],
		[[<Technology>T_UpgradeCrossBow1</Technology>]],

		[[<Technology>T_ReinforcedChassis</Technology>]],
		[[<Technology>T_HardenedFrames</Technology>]],
	}

	for _, technology in pairs ( technologies ) do
		CMod.AppendToXML("data\\config\\technologies.xml", technology);
	end

	------------------Entry in technologies.xml----------------------------------------
	
	local tasklists = {
		[[<TaskList>TL_TRAIN1_FOUNDRY1</TaskList>]],
		[[<TaskList>TL_TRAIN1_FOUNDRY2</TaskList>]],
		[[<TaskList>TL_TRAIN2_FOUNDRY1</TaskList>]],
		[[<TaskList>TL_TRAIN2_FOUNDRY2</TaskList>]],
		[[<TaskList>TL_TRAIN3_FOUNDRY1</TaskList>]],
		[[<TaskList>TL_TRAIN3_FOUNDRY2</TaskList>]],
	}

	for _, tasklist in pairs ( tasklists ) do
		CMod.AppendToXML("data\\config\\tllist.xml", tasklist);
	end
end