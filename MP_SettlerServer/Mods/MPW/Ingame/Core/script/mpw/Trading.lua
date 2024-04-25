--Balancer for trading in MPW

MPW.Trading = {}

function MPW.Trading.PostInit()
	Trigger.RequestTrigger(Events.LOGIC_EVENT_ENTITY_DESTROYED, nil, MPW.MarketDestroiedHandler, 1, nil, nil)
	--SyncCalls
	if CNetwork then
		CNetwork.SetNetworkHandler("TradingSaveCancelTrade", MPW.Trading.SaveCancelTrade) 
		CNetwork.SetNetworkHandler("AcceptTrade", MPW.Trading.AcceptDeal)
	end
	MPW.Trading.MarketOverride()
end


function MPW.Trading.MarketOverride()
	--Setup Pricingfactors
	MPW.Trading.LowerPriceCap = 0.75
	MPW.Trading.UpperPriceCap = 1.75 --1.25 old value
	MPW.Trading.StartInflation = 0
	MPW.Trading.StartDeflation = 0


	for player = 1,16 do
		MPW.Trading[player] = {}
		MPW.Trading[player].Factors = {
			[ResourceType.Gold] = 0.05, --Gold
			[ResourceType.Clay] = 0.05,	--Clay
			[ResourceType.Wood] = 0.05, --Wood
			[ResourceType.Stone] = 0.05, --Stone
			[ResourceType.Iron] = 0.05,	--Iron
			[ResourceType.Sulfur] = 0.05	--Sulfur
		}
		MPW.Trading[player].Prices = {
			[ResourceType.Gold] = 1, --Gold
			[ResourceType.Clay] = 1,	--Clay
			[ResourceType.Wood] = 1, --Wood
			[ResourceType.Stone] = 1, --Stone
			[ResourceType.Iron] = 1,	--Iron
			[ResourceType.Sulfur] = 1	--Sulfur
		}
		MPW.Trading[player].CurrentTrades = { }

		--Setup of start-inflation and start-deflation
		MPW.Trading[player].PriceLevel = { 
			CurrentInflation = { },
			CurrentDeflation = { }
		}

		for k,v in pairs(MPW.Trading[player].Factors) do
			Logic.SetCurrentInflation(player,k,MPW.Trading.StartInflation)
			Logic.SetCurrentDeflation(player,k,MPW.Trading.StartDeflation)
			MPW.Trading[player].PriceLevel.CurrentInflation[k] = Logic.GetCurrentInflation(player,k)
			MPW.Trading[player].PriceLevel.CurrentDeflation[k] = Logic.GetCurrentDeflation(player,k)
		end
	end
end

--OverrideTradingFunc
if not CNetwork then
	--SP
	GUIAction_MarketAcceptDealWithDirectCap = GUAction_MarketAcceptDeal
	function GUAction_MarketAcceptDeal(_SellResourceType)

	MPW.Trading.PreSaveAcceptDeal(nil, _SellResourceType)

	--start trade
	GUIAction_MarketAcceptDealWithDirectCap(_SellResourceType)

	MPW.Trading.PostSaveAcceptDeal(nil, _SellResourceType)

	end

end


if CNetwork then
	--MP
	function MPW.Trading.AcceptDeal(_name, _buildingID, _sellType, _buyType, _buyAmount)
		local player = Logic.EntityGetPlayer(_buildingID)
		local _SellResourceType = _sellType
		local _BuyResourceType = _buyType
		local SellAmount =  Logic.GetSellAmount(player, _SellResourceType, _BuyResourceType, _buyAmount)
		local Costs = { }
		
		Costs[_SellResourceType] = SellAmount


		if InterfaceTool_HasPlayerEnoughResources_Feedback( Costs ) == 1 and Logic.GetTransactionProgress(_buildingID) == 100 and CNetwork.IsAllowedToManipulatePlayer(_name, Logic.EntityGetPlayer(_buildingID)) and not MPW.Trading[player].CurrentTrades[_buildingID] then
			-- save price-state
			
			MPW.Trading[player].Prices[_SellResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,_SellResourceType)))
			if _BuyResourceType then
				MPW.Trading[player].Prices[_BuyResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,_BuyResourceType)))
			end

			--start trade
			SendEvent.AcceptTrade(_buildingID, _sellType, _buyType, _buyAmount);

			--Override for Ubi-Priceadjustments when trade is accepted

			--Selling
			if Logic.GetCurrentPrice(player, _SellResourceType) > MPW.Trading.LowerPriceCap then
				Logic.SetCurrentPrice(player, _SellResourceType, MPW.Trading[player].Prices[_SellResourceType] - MPW.Trading[player].Factors[_SellResourceType])
				MPW.Trading[player].Prices[_SellResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player, _SellResourceType)))
			else
				Logic.SetCurrentPrice(player, _SellResourceType,MPW.Trading[player].Prices[_SellResourceType])
				MPW.Trading[player].Prices[_SellResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player, _SellResourceType)))
			end

			--Buying
			if _BuyResourceType then
				if Logic.GetCurrentPrice(player,_BuyResourceType) < MPW.Trading.UpperPriceCap then
					Logic.SetCurrentPrice(player,_BuyResourceType, MPW.Trading[player].Prices[_BuyResourceType] + MPW.Trading[player].Factors[_BuyResourceType])
					MPW.Trading[player].Prices[_BuyResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player, _BuyResourceType)))
				else
					Logic.SetCurrentPrice(player,_BuyResourceType,MPW.Trading[player].Prices[_BuyResourceType])
					MPW.Trading[player].Prices[_BuyResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,_BuyResourceType)))
				end
			end

			--Adding current trade to table
			MPW.Trading[player].CurrentTrades[_buildingID] = {
				["SellType"] = _SellResourceType,
				["BuyType"] = _BuyResourceType,
				["InProgress"] = true
			}
		end
	end
else
	--SP
	function MPW.Trading.PreSaveAcceptDeal(_name, _SellResourceType)
		
		local player = GUI.GetPlayerID()
		local _BuyResourceType = InterfaceTool_MarketGetBuyResourceTypeAndAmount()
		-- save price-state
		
		MPW.Trading[player].Prices[_SellResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,_SellResourceType)))
		if _BuyResourceType then
			MPW.Trading[player].Prices[_BuyResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,_BuyResourceType)))
		end

	end

	function MPW.Trading.PostSaveAcceptDeal(_name, _SellResourceType)

		--Override for Ubi-Priceadjustments when trade is accepted

		local player = GUI.GetPlayerID()
		local buildingID = GUI.GetSelectedEntity()
		local _BuyResourceType = InterfaceTool_MarketGetBuyResourceTypeAndAmount()

		--Selling
		if Logic.GetCurrentPrice(player, _SellResourceType) > MPW.Trading.LowerPriceCap then
			Logic.SetCurrentPrice(player, _SellResourceType, MPW.Trading[player].Prices[_SellResourceType] - MPW.Trading[player].Factors[_SellResourceType])
			MPW.Trading[player].Prices[_SellResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player, _SellResourceType)))
		else
			Logic.SetCurrentPrice(player, _SellResourceType,MPW.Trading[player].Prices[_SellResourceType])
			MPW.Trading[player].Prices[_SellResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player, _SellResourceType)))
		end

		--Buying
		if _BuyResourceType then
			if Logic.GetCurrentPrice(player,_BuyResourceType) < MPW.Trading.UpperPriceCap then
				Logic.SetCurrentPrice(player,_BuyResourceType, MPW.Trading[player].Prices[_BuyResourceType] + MPW.Trading[player].Factors[_BuyResourceType])
				MPW.Trading[player].Prices[_BuyResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player, _BuyResourceType)))
			else
				Logic.SetCurrentPrice(player,_BuyResourceType,MPW.Trading[player].Prices[_BuyResourceType])
				MPW.Trading[player].Prices[_BuyResourceType] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,_BuyResourceType)))
			end
		end

		--Adding current trade to table
		MPW.Trading[player].CurrentTrades[buildingID] = {
			["SellType"] = _SellResourceType,
			["BuyType"] = _BuyResourceType,
			["InProgress"] = true
		}

	end
end


--Override CancelTrade to reset prices
GUIAction_CancelTradeResetCap = GUIAction_CancelTrade
function GUIAction_CancelTrade()
	GUIAction_CancelTradeResetCap()

	local player = GUI.GetPlayerID()
	local buildingID = GUI.GetSelectedEntity()
	
	if CNetwork then
		CNetwork.SendCommand("TradingSaveCancelTrade", player, buildingID); --syncer canceling trade
	else
		MPW.Trading.SaveCancelTrade(nil, player, buildingID)
	end
end

function MPW.Trading.SaveCancelTrade(_name, player, buildingID)
	if MPW.Trading[player].CurrentTrades[buildingID]["InProgress"] then
		
		Logic.SetCurrentPrice(player,MPW.Trading[player].CurrentTrades[buildingID]["SellType"], MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[buildingID]["SellType"]] + MPW.Trading[player].Factors[MPW.Trading[player].CurrentTrades[buildingID]["SellType"]])
		MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[buildingID]["SellType"]] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,MPW.Trading[player].CurrentTrades[buildingID]["SellType"])))
		

		Logic.SetCurrentPrice(player,MPW.Trading[player].CurrentTrades[buildingID]["BuyType"], MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[buildingID]["BuyType"]] - MPW.Trading[player].Factors[MPW.Trading[player].CurrentTrades[buildingID]["BuyType"]])
		MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[buildingID]["BuyType"]] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,MPW.Trading[player].CurrentTrades[buildingID]["BuyType"])))
		
		MPW.Trading[player].CurrentTrades[buildingID] = nil
	end
end


--Override for Ubi-Priceadjustments after trade is done
GameCallback_OnTransactionCompleteNew = GameCallback_OnTransactionComplete
function GameCallback_OnTransactionComplete(_BuildingID, _empty )

	GameCallback_OnTransactionCompleteNew(_BuildingID, _empty )

	local player = Logic.EntityGetPlayer(_BuildingID)
		for k,_ in pairs(MPW.Trading[player].Prices) do
			--Priceadjustment after trade is done
			Logic.SetCurrentPrice(player,k,MPW.Trading[player].Prices[k])
			MPW.Trading[player].Prices[k] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,k)))
		end

		--PriceLevel-Adjustment after trade is done
		--SoldResource value decreases
		Logic.SetCurrentInflation(player,MPW.Trading[player].CurrentTrades[_BuildingID]["SellType"],MPW.Trading[player].PriceLevel.CurrentInflation[ MPW.Trading[player].CurrentTrades[_BuildingID]["SellType"] ] + 0.005)
		--BoughtResource value increases
		Logic.SetCurrentDeflation(player,MPW.Trading[player].CurrentTrades[_BuildingID]["BuyType"],MPW.Trading[player].PriceLevel.CurrentDeflation[ MPW.Trading[player].CurrentTrades[_BuildingID]["BuyType"] ] + 0.005)
		--Getting new pricelevel parameters
		MPW.Trading[player].PriceLevel.CurrentInflation[ MPW.Trading[player].CurrentTrades[_BuildingID]["SellType"] ] = Logic.GetCurrentInflation(player, MPW.Trading[player].CurrentTrades[_BuildingID]["SellType"])
		MPW.Trading[player].PriceLevel.CurrentDeflation[ MPW.Trading[player].CurrentTrades[_BuildingID]["BuyType"] ] = Logic.GetCurrentDeflation(player, MPW.Trading[player].CurrentTrades[_BuildingID]["BuyType"])
	
		MPW.Trading[player].CurrentTrades[_BuildingID] = nil
end

--Addition for Ubi-Priceadjustments when market gets destroied

function MPW.MarketDestroiedHandler()
	local marketID = Event.GetEntityID()
	local player = Logic.EntityGetPlayer(marketID)
	if Logic.GetEntityType(marketID) == Entities.PB_Market2 then
		if Logic.GetTransactionProgress(marketID) ~= 100 then
			Logic.SetCurrentPrice(player,MPW.Trading[player].CurrentTrades[marketID]["SellType"], MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[marketID]["SellType"]] + MPW.Trading[player].Factors[MPW.Trading[player].CurrentTrades[marketID]["SellType"]])
			MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[marketID]["SellType"]] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,MPW.Trading[player].CurrentTrades[marketID]["SellType"])))
		

			Logic.SetCurrentPrice(player,MPW.Trading[player].CurrentTrades[marketID]["BuyType"], MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[marketID]["BuyType"]] - MPW.Trading[player].Factors[MPW.Trading[player].CurrentTrades[marketID]["BuyType"]])
			MPW.Trading[player].Prices[MPW.Trading[player].CurrentTrades[marketID]["BuyType"]] = tonumber(string.format("%.2f", Logic.GetCurrentPrice(player,MPW.Trading[player].CurrentTrades[marketID]["BuyType"])))
			
			MPW.Trading[player].CurrentTrades[marketID] = nil
		end
	end
end