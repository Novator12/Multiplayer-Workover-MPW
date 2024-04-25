MPW.Defeat = {}
--------------------------------------------------------------------------------
function MPW.Defeat.PostInit()

    -- override ubi defeat condition
	function VC_Deathmatch()
		if MultiplayerTools.GameFinished == 1 then
			return
		end

		-- Get number of humen player
		local HumenPlayer = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()
		local LocalPlayer = GUI.GetPlayerID()

		-- Check loose condition: Player did loose his Headquarter			
		local CurrentPlayerID
		for CurrentPlayerID = 1, HumenPlayer do

			-- Check if HQ exists
			local ConditionFlag = 0
			for i = 1, MultiplayerTools.EntityTableHeadquarters[1], 1 do
				-- check all upgrades
				if ConditionFlag == 0 then
					if 	Logic.GetNumberOfEntitiesOfTypeOfPlayer(CurrentPlayerID, MultiplayerTools.EntityTableHeadquarters[i+1]) ~= 0 then
						ConditionFlag = 1
					end
				end
			end

			-- No headquarter exists
			if ConditionFlag == 0 and MPW.Defeat.AdditionalCheck(CurrentPlayerID) then

				-- Mark player as looser
				if Logic.PlayerGetGameState(CurrentPlayerID) == 1 then		

					MPW.Defeat.PlayerLost(CurrentPlayerID)

					if LocalPlayer == CurrentPlayerID then			
						GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerLostGame" ) )
						XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerLostGame" ) .. "\n"  )
					else
						local PlayerName = UserTool_GetPlayerName( CurrentPlayerID )						
						GUI.AddNote( PlayerName .. XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerXLostGame" ),10 )						
						XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", PlayerName .. XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerXLostGame" ) .. "\n"  )
					end
				end
			end
		end

		-- Check win condition
		for j = 1, 16 do
			if MultiplayerTools.Teams[ j ] ~= nil then

				local AmountOfPlayersInTeam = table.getn(MultiplayerTools.Teams [ j ])

				-- Count player lost in team
				local AmountOfPlayersLostInTeam = 0 
				for k = 1, AmountOfPlayersInTeam do
					if Logic.PlayerGetGameState(MultiplayerTools.Teams [ j ] [ k ]) == 3 or	Logic.PlayerGetGameState(MultiplayerTools.Teams [ j ] [ k ]) == 4 then
						AmountOfPlayersLostInTeam = AmountOfPlayersLostInTeam + 1
					end
				end

				--Set lost teams
				if AmountOfPlayersLostInTeam == AmountOfPlayersInTeam then

					-- Team has lost!!!
					if MultiplayerTools.TeamLostTable[ j ] == nil or MultiplayerTools.TeamLostTable[ j ] == 0 then

						-- Has the team more that 1 player -- ThHa: must print even for 1 player opponent teams...
						if true then -- AmountOfPlayersInTeam > 1 then
							for k= 1,AmountOfPlayersInTeam ,1 do
								if LocalPlayer == MultiplayerTools.Teams [ j ] [ k ] then											
									GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerTeamLost" ) )						
									XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerTeamLost" .. "\n" ) )
								else
									GUI.AddNote( XGUIEng.GetStringTableText( "InGameMessages/Note_TeamX" )  .. j .. XGUIEng.GetStringTableText( "InGameMessages/Note_TeamXHasLostGame" ))
									XGUIEng.AddRawTextAtEnd( "GameEndScreen_MessageDetails", XGUIEng.GetStringTableText( "InGameMessages/Note_TeamX" )  .. j .. XGUIEng.GetStringTableText( "InGameMessages/Note_TeamXHasLostGame" ) .. "\n"  )
								end
							end
						end

						MultiplayerTools.TeamLostTable[ j ] = 1
						MultiplayerTools.AmountOfLooserTeams = MultiplayerTools.AmountOfLooserTeams + 1
					end
				end
				if MultiplayerTools.AmountOfLooserTeams  > 0 then
					local NumberOfTeams = MultiplayerTools.TeamCounter

					--only one team is left:mark players as winner
					if MultiplayerTools.AmountOfLooserTeams == ( NumberOfTeams - 1) then

						for TempPlayerID = 1, HumenPlayer, 1
						do
							if Logic.PlayerGetGameState(TempPlayerID) == 1 then
								Logic.PlayerSetGameStateToWon(TempPlayerID)
							end
						end

						MultiplayerTools.GameFinished = 1
					end
				end
			end
		end
	end

    -- override ems defeat condition
	if MPW.IsEMS then
		function EMS_T_StandardVictoryConditionJob()
			-- started from file ruledata
			-- if config doesn't disable it
			if not EMS.GV.GameStarted then
				return;
			end
			local HasLost;
			for playerId, data in pairs(EMS.PlayerList) do
				if EMS.T.VictoryCondition.Playing[playerId] then
					HasLost = true;
					for HQIndex = table.getn(EMS.T.VictoryCondition[playerId]), 1, -1 do
						if IsAlive(EMS.T.VictoryCondition[playerId][HQIndex]) then
							HasLost = false;
							break;
						else
							table.remove(EMS.T.VictoryCondition[playerId], HQIndex);
						end
					end
					if HasLost then
						if (not EMS.T.ScanForPlayerHQ(playerId)) and MPW.Defeat.AdditionalCheck(playerId) then
							EMS.T.PlayerLost(playerId);
							EMS.T.VictoryCondition.Playing[playerId] = false;
							EMS.T.VictoryCondition.NumberOfPlayersPlaying = EMS.T.VictoryCondition.NumberOfPlayersPlaying - 1;
							if EMS.T.VictoryCondition.NumberOfPlayersPlaying <= 0 then
								return true;
							end
						end
					end
				end
			end
		end

		function EMS.T.PlayerLost(_playerId)
			if GUI.GetPlayerID() == _playerId then
				GUI.AddNote( "@color:255,0,0 " .. XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerLostGame" ) );
			else
				if EMS.PlayerList[_playerId] then
					GUI.AddNote(  EMS.PlayerList[_playerId].ColorName .. " @color:255,255,255 " .. XGUIEng.GetStringTableText( "InGameMessages/Note_PlayerXLostGame" ) );
				end
			end
			MPW.Defeat.PlayerLost(_playerId)
			XGUIEng.ShowWidget("GameEndScreen",0);
		end
	end
end
--------------------------------------------------------------------------------
-- overrider method for logic actions taken on player defeated
function MPW.Defeat.PlayerLost(_playerId)
	Logic.PlayerSetGameStateToLost(_playerId);
	MultiplayerTools.RemoveAllPlayerEntities(_playerId);
end
--------------------------------------------------------------------------------
-- override method for additioal defeat condition (both must be met)
function MPW.Defeat.AdditionalCheck(_PlayerId)
	return true
end