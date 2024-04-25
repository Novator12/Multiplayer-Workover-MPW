-- ************************************************************************************************
-- requires:
-- S5Hook or S5HookReplacement, XD_ThiefLoot
-- ************************************************************************************************
MPW.ThiefLoot = {}
-- ************************************************************************************************
function MPW.ThiefLoot.PostInit()
	
	-- setup handlers for CNetwork.SendCommand
	if CNetwork then
		CNetwork.SetNetworkHandler("ThiefPickUpLoot", MPW.ThiefLoot.PickUpLoot)
		CNetwork.SetNetworkHandler("ThiefDropLoot", MPW.ThiefLoot.DropLoot)
	end
	
	-- setup event when a thief dies -> drop his loot
	Trigger.RequestTrigger( Events.LOGIC_EVENT_ENTITY_DESTROYED, "", MPW.ThiefLoot.OnThiefDied, 1, {}, {})
end
-- ************************************************************************************************
-- GUI Action
-- ************************************************************************************************
function GUIAction_ThiefPickUpLoot()
	if CNetwork then
		CNetwork.SendCommand("ThiefPickUpLoot"); --syncer
	else
		MPW.ThiefLoot.PickUpLoot()
	end
end
-- ************************************************************************************************
function MPW.ThiefLoot.PickUpLoot()

	local id = GUI.GetSelectedEntity()
	local loot = MPW.ThiefLoot.GetLootAtPosition( GetPosition( id ), 200 )
	
	if loot ~= 0 then
		local restype, amount, player = MPW.ThiefLoot.DestroyLoot( loot )
		MPW.ThiefLoot.SetStolenResourceInfo( id, restype, amount, player )
	end
end
-- ************************************************************************************************
function GUIAction_ThiefDropLoot()
	if CNetwork then
		CNetwork.SendCommand("ThiefDropLoot", GUI.GetSelectedEntity() ); --syncer
	else
		MPW.ThiefLoot.DropLoot( GUI.GetSelectedEntity() )
	end
end
-- ************************************************************************************************
function MPW.ThiefLoot.DropLoot( _id )
	if Logic.GetCurrentTaskList(_id) ~= "TL_THIEF_SECURE_GOODS" and Logic.GetCurrentTaskList(_id) ~= "TL_THIEF_STEAL_GOODS" then
		local restype, amount, player = MPW.ThiefLoot.GetStolenResourceInfo( _id )
		
		if amount > 0 and MPW.ThiefLoot.IsValidResourceType( restype ) then
			MPW.ThiefLoot.CreateLoot( GetPosition( _id ), restype, amount, player )
			MPW.ThiefLoot.ClearStolenResourceInfo( _id )
		end
	end
end
-- ************************************************************************************************
-- GUI Update
-- ************************************************************************************************

-- ************************************************************************************************
-- GUI Tooltip
-- ************************************************************************************************

-- ************************************************************************************************
-- thief data setter and getter
-- ************************************************************************************************
function MPW.ThiefLoot.GetStolenResourceInfo( _thief )

	-- do important checks
	if Logic.GetEntityType( _thief ) ~= Entities.PU_Thief then
		LuaDebugger.Log("MPW.GetStolenResourceInfo: _thief must be of type Entities.PU_Thief")
		return
	end
	
	return S5Hook.GetEntityMem(_thief)[31][8][5]:GetInt(), S5Hook.GetEntityMem(_thief)[31][8][4]:GetInt(), S5Hook.GetEntityMem(_thief)[31][8][6]:GetInt()
end
-- ************************************************************************************************
function MPW.ThiefLoot.SetStolenResourceInfo( _thief, _restype, _amount, _player )
	
	-- do important checks
	if Logic.GetEntityType( _thief ) ~= Entities.PU_Thief then
		LuaDebugger.Log("MPW.SetStolenResourceInfo: _thief must be of type Entities.PU_Thief")
		return
	end
	if type( _amount ) ~= "number" or _amount <= 0 then
		LuaDebugger.Log("MPW.SetStolenResourceInfo: _amount must be a number greater zero")
		return
	end
	if type( _restype ) ~= "number" or not MPW.ThiefLoot.IsValidResourceType( _restype ) then
		LuaDebugger.Log("MPW.SetStolenResourceInfo: _restype must be a valid resource type")
		return
	end
	if type( _player ) ~= "number" or _player < 1 or _player > 16 then
		LuaDebugger.Log("MPW.SetStolenResourceInfo: _player must be a number between 1 and 16")
		return
	end
	
	S5Hook.GetEntityMem(_thief)[31][8][5]:SetInt(_restype)
	S5Hook.GetEntityMem(_thief)[31][8][4]:SetInt(_amount)
	S5Hook.GetEntityMem(_thief)[31][8][6]:SetInt(_player)
end
-- ************************************************************************************************
function MPW.ThiefLoot.ClearStolenResourceInfo( _thief )

	-- do important checks
	if Logic.GetEntityType( _thief ) ~= Entities.PU_Thief then
		LuaDebugger.Log("MPW.ClearStolenResourceInfo: _thief must be of type Entities.PU_Thief")
		return
	end
	
	S5Hook.GetEntityMem(_thief)[31][8][5]:SetInt(0)
	S5Hook.GetEntityMem(_thief)[31][8][4]:SetInt(0)
	S5Hook.GetEntityMem(_thief)[31][8][6]:SetInt(0)
end
-- ************************************************************************************************
-- loot setter and getter
-- ************************************************************************************************
function MPW.ThiefLoot.GetLootAtPosition( _pos, _range )
	for id in CEntityIterator.Iterator( CEntityIterator.InRangeFilter( _pos.X, _pos.Y, _range ), CEntityIterator.OfTypeFilter( Entities.XD_ThiefLoot ) ) do
		return id
	end
	return 0
end
-- ************************************************************************************************
function MPW.ThiefLoot.CreateLoot( _pos, _restype, _amount, _player )
	
	local player = CNetwork and 17 or 1
	local loot = Logic.CreateEntity( Entities.XD_ThiefLoot, _pos.X, _pos.Y, 0, player )
	--local effect = Logic.CreateEntity( Entities.XD_Sparkles, _pos.X, _pos.Y, 0, 0 )
	
	CUtil.SetEntityDisplayName( loot, _amount .. " " .. MPW.ThiefLoot.GetResourceDisplayName( _restype ) )
	
	--Logic.SetEntityScriptingValue( loot, 0, effect )
	Logic.SetEntityScriptingValue( loot, 1, _restype )
	Logic.SetEntityScriptingValue( loot, 2, _amount )
	Logic.SetEntityScriptingValue( loot, 3, _player )
end
-- ************************************************************************************************
function MPW.ThiefLoot.DestroyLoot( _loot )
	
	local restype, amount, player = Logic.GetEntityScriptingValue( _loot, 1 ), Logic.GetEntityScriptingValue( _loot, 2 ), Logic.GetEntityScriptingValue( _loot, 3 )
	
	--DestroyEntity( Logic.GetEntityScriptingValue( _loot, 0 ) )
	DestroyEntity( _loot )
	
	return restype, amount, player
end
-- ************************************************************************************************
-- resource type
-- ************************************************************************************************
function MPW.ThiefLoot.IsValidResourceType( _type )
	for k,v in pairs(ResourceType) do
		if _type == v then
			return true
		end
	end
	return false
end
-- ************************************************************************************************
function MPW.ThiefLoot.GetResourceDisplayName( _restype )
	
	local name = ""
	
	if     _restype == ResourceType.Gold or _restype == ResourceType.GoldRaw then
		name = XGUIEng.GetStringTableText( "InGameMessages/GUI_NameMoney" )
	elseif _restype == ResourceType.Clay or _restype == ResourceType.ClayRaw then
		name = XGUIEng.GetStringTableText( "InGameMessages/GUI_NameClay" )
	elseif _restype == ResourceType.Wood or _restype == ResourceType.WoodRaw then
		name = XGUIEng.GetStringTableText( "InGameMessages/GUI_NameWood" )
	elseif _restype == ResourceType.Stone or _restype == ResourceType.StoneRaw then
		name = XGUIEng.GetStringTableText( "InGameMessages/GUI_NameStone" )
	elseif _restype == ResourceType.Iron or _restype == ResourceType.IrondRaw then
		name = XGUIEng.GetStringTableText( "InGameMessages/GUI_NameIron" )
	elseif _restype == ResourceType.Sulfur or _restype == ResourceType.SulfurRaw then
		name = XGUIEng.GetStringTableText( "InGameMessages/GUI_NameSulfur" )
	elseif _restype == ResourceType.Silver or _restype == ResourceType.SilverRaw then
		name = XGUIEng.GetStringTableText( "Silber" )
	elseif _restype == ResourceType.Faith then
		name = XGUIEng.GetStringTableText( "Glauben" )
	elseif _restype == ResourceType.WeatherEnergy then
		name = XGUIEng.GetStringTableText( "Wetterenergie" )
	elseif _restype == ResourceType.Knowledge then
		name = XGUIEng.GetStringTableText( "Wissen" )
	end
	
	return name
end
-- ************************************************************************************************
function MPW.ThiefLoot.OnThiefDied()
	
	local id = Event.GetEntityID()
	
	if Logic.GetEntityType( id ) == Entities.PU_Thief then
		
		MPW.ThiefLoot.DropLoot( id )
	end	
end