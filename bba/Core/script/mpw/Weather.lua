MPW.Weather = {}
MPW.Weather.PlayerWeatherStates = {}
MPW.Weather.GlobalWeatherStates = {0, 0, 0}
MPW.Weather.Params = {
    EnergyUsage = 50, -- usage per second of stored weather energy
    EnergyLoss = 12, -- natural degeneration per interval of global weather state
    EnergyMin = 1000, -- global weather energy required for weather change
    EnergyMax = 2000, -- max amount of weather energy, that can be stored in the global weather state
    UpdateInterval = 5, -- time in seconds in which weather gets updated
    EnergyStored = 1000, -- weather energy stored per weather tower
}
--------------------------------------------------------------------------------
function MPW.Weather.Init()

    if CNetwork then
        for player = 1, 16 do
            if XNetwork.GameInformation_IsHumanPlayerAttachedToPlayerID(player) == 1 then
                MPW.Weather.PlayerWeatherStates[player] = 0
            end
        end
    else
        MPW.Weather.PlayerWeatherStates[GUI.GetPlayerID()] = 0
    end

    Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, MPW.Weather.ControllerJob, 1, nil, nil)
end
--------------------------------------------------------------------------------
function MPW.Weather.PostInit()

    MPW.Weather.GameCallback_ResourceChanged = GameCallback_ResourceChanged
    function GameCallback_ResourceChanged(_Player, _ResourceType, _Amount)
        (MPW.Weather.GameCallback_ResourceChanged or function() end)(_Player, _ResourceType, _Amount)

        -- only if weather energy increases
        if _ResourceType == ResourceType.WeatherEnergy and _Amount > 0 then
            local weatherstate = MPW.Weather.PlayerWeatherStates[_Player]
            if weatherstate and weatherstate ~= 0 then
                Logic.SubFromPlayersGlobalResource(_Player, ResourceType.WeatherEnergy, _Amount)
                MPW.Weather.AddToGlobalWeatherEnergy(weatherstate, _Amount)
            end

            -- limit weather energy per player
            local amount = Logic.GetPlayersGlobalResource(_Player, ResourceType.WeatherEnergy)
            local limit = MPW.Weather.GetPlayerMaxWeatherEnergy(_Player) + 10 -- why ???
            if amount + _Amount > limit then
                Logic.SubFromPlayersGlobalResource(_Player, ResourceType.WeatherEnergy, amount + _Amount - limit)
            end
        end
    end

    -- load after EMS
    function GUIAction_ChangeWeather(_WeatherState)
        if CNetwork then
            CNetwork.SendCommand( "SetPlayerWeatherState", GUI.GetPlayerID(), _WeatherState )
        else
            MPW.Weather.SetPlayerWeatherState( nil, GUI.GetPlayerID(), _WeatherState )
        end
    end

    function GUIUpdate_ChangeWeatherButtons(_Button, _Technology, _WeatherState)
        local PlayerID = GUI.GetPlayerID()
        if _WeatherState == MPW.Weather.PlayerWeatherStates[PlayerID] then
            XGUIEng.HighLightButton(_Button,1)
        else
            XGUIEng.HighLightButton(_Button,0)
        end
        if _Technology then
            local TechState = Logic.GetTechnologyState(PlayerID, _Technology)
            if TechState == 0 then
                XGUIEng.DisableButton(_Button,1)
            elseif TechState == 1 or TechState == 5 then
                XGUIEng.DisableButton(_Button,1)
                XGUIEng.ShowWidget(_Button,1)
            elseif TechState == 2 or TechState == 3 or TechState == 4 then
                XGUIEng.ShowWidget(_Button,1)
                XGUIEng.DisableButton(_Button,0)
            end
        end
    end

    function GUIUpdate_WeatherEnergyProgress()
        local PlayerID = GUI.GetPlayerID()
        local amount = Logic.GetPlayersGlobalResource( PlayerID, ResourceType.WeatherEnergy )
        local limit = MPW.Weather.GetPlayerMaxWeatherEnergy( PlayerID )
        XGUIEng.SetProgressBarValues( XGUIEng.GetCurrentWidgetID(), amount, limit )
    end

    if CNetwork then
		CNetwork.SetNetworkHandler("SetPlayerWeatherState", MPW.Weather.SetPlayerWeatherState)
	end
end
--------------------------------------------------------------------------------
function MPW.Weather.ControllerJob()
    for player, weatherstate in pairs(MPW.Weather.PlayerWeatherStates) do
        if weatherstate ~= 0 then
            local amount = math.min(Logic.GetPlayersGlobalResource(player, ResourceType.WeatherEnergy), MPW.Weather.Params.EnergyUsage)
            
            Logic.SubFromPlayersGlobalResource(player, ResourceType.WeatherEnergy, amount)
            MPW.Weather.AddToGlobalWeatherEnergy(weatherstate, amount)
        end
    end
    
    if Counter.Tick2("MPW_Weather_Controller", MPW.Weather.Params.UpdateInterval) and (MPW.Weather.GlobalWeatherStates[1] > MPW.Weather.Params.EnergyMin or MPW.Weather.GlobalWeatherStates[2] > MPW.Weather.Params.EnergyMin or MPW.Weather.GlobalWeatherStates[3] > MPW.Weather.Params.EnergyMin) then
        if MPW.Weather.GlobalWeatherStates[1] >= MPW.Weather.GlobalWeatherStates[2] and MPW.Weather.GlobalWeatherStates[1] >= MPW.Weather.GlobalWeatherStates[3] then
            StartSummer(MPW.Weather.Params.UpdateInterval)
        elseif MPW.Weather.GlobalWeatherStates[2] >= MPW.Weather.GlobalWeatherStates[3] then
            StartRain(MPW.Weather.Params.UpdateInterval)
        else
            StartWinter(MPW.Weather.Params.UpdateInterval)
        end

        for weatherstate = 1, 3 do
            MPW.Weather.GlobalWeatherStates[weatherstate] = math.max(0, MPW.Weather.GlobalWeatherStates[weatherstate] - MPW.Weather.Params.EnergyLoss)
        end
    end
end
--------------------------------------------------------------------------------
function MPW.Weather.SetPlayerWeatherState(_Name, _Player, _WeatherState)
    MPW.Weather.PlayerWeatherStates[_Player] = _WeatherState
end
--------------------------------------------------------------------------------
function MPW.Weather.AddToGlobalWeatherEnergy(_WeatherState, _Amount)

    local strong, weak
    if _WeatherState == 1 then
        if MPW.Weather.GlobalWeatherStates[2] >= MPW.Weather.GlobalWeatherStates[3] then
            strong, weak = 2, 3
        else
            strong, weak = 3, 2
        end
    elseif _WeatherState == 2 then
        if MPW.Weather.GlobalWeatherStates[1] >= MPW.Weather.GlobalWeatherStates[3] then
            strong, weak = 1, 3
        else
            strong, weak = 3, 1
        end
    else
        if MPW.Weather.GlobalWeatherStates[1] >= MPW.Weather.GlobalWeatherStates[2] then
            strong, weak = 1, 2
        else
            strong, weak = 2, 1
        end
    end

    -- weather state exeeds the limit on its own ?
    if MPW.Weather.GlobalWeatherStates[_WeatherState] + _Amount >= MPW.Weather.Params.EnergyMax then
        MPW.Weather.GlobalWeatherStates[_WeatherState] = MPW.Weather.Params.EnergyMax
        MPW.Weather.GlobalWeatherStates[strong] = 0
        MPW.Weather.GlobalWeatherStates[weak] = 0
        return
    end
    
    local globalenergy = 0
    for weatherstate = 1,3 do
        globalenergy = globalenergy + MPW.Weather.GlobalWeatherStates[weatherstate]
    end
    
    -- sub energy from other weeather states
    local blockedcapacity = _Amount - (MPW.Weather.Params.EnergyMax - globalenergy)
    if blockedcapacity > 0 then

        local highamount, lowamount = math.ceil(blockedcapacity / 2), math.floor(blockedcapacity / 2)
        local weakamount = math.min(MPW.Weather.GlobalWeatherStates[weak], lowamount)
        MPW.Weather.GlobalWeatherStates[weak] = MPW.Weather.GlobalWeatherStates[weak] - weakamount

        if weakamount < lowamount then
            highamount = highamount + lowamount - weakamount
        end

        local highamount = math.min(MPW.Weather.GlobalWeatherStates[strong], highamount)
        MPW.Weather.GlobalWeatherStates[strong] = MPW.Weather.GlobalWeatherStates[strong] - highamount
   end
    
    -- add energy
    MPW.Weather.GlobalWeatherStates[_WeatherState] = MPW.Weather.GlobalWeatherStates[_WeatherState] + _Amount
end
--------------------------------------------------------------------------------
function MPW.Weather.GetPlayerMaxWeatherEnergy(_Player)
    local amount = 0
    for id in CEntityIterator.Iterator(CEntityIterator.OfTypeFilter(Entities.PB_WeatherTower1), CEntityIterator.OfPlayerFilter(_Player)) do
        if Logic.IsConstructionComplete(id) == 1 then
            amount = amount + 1
        end
    end
    return amount * MPW.Weather.Params.EnergyStored
end
--------------------------------------------------------------------------------
function MPW.Weather.DegenerateGlobalWeatherEnergy()
    local amount = 0
    for weatherstate = 1,3 do
        amount = amount + MPW.Weather.GlobalWeatherStates[weatherstate]
    end
    for weatherstate = 1,3 do
        MPW.Weather.GlobalWeatherStates[weatherstate] = math.max(0, MPW.Weather.GlobalWeatherStates[weatherstate] - math.max(amount / MPW.Weather.Params.EnergyMax, 1) * MPW.Weather.Params.EnergyLoss)
    end
end