--------------------------------------------------------------------------------
-- Local script
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Game call backs
--------------------------------------------------------------------------------
-- Function called when local script was loaded the first time

function GameCallback_LocalScriptLoadedFirstTime()

    -- Load sub scripts	
	Script.Load( "Data\\Script\\Local\\LocalCamera.lua" )		
	Script.Load( "Data\\Script\\Local\\LocalDisplay.lua" )	
	Script.Load( "Data\\Script\\Local\\LocalDebug.lua" )
	
	--Load Debug Keybindings
	Script.Load( "Data\\Script\\Local\\LocalKeyBindings.lua" )
	
	--Load official Keybindings
	Script.Load( "Data\\Script\\Local\\LocalOfficialKeyBindings.lua" )
		
	Script.Load( "Data\\Script\\Speech\\LocalSpeech.lua" )	
	Script.Load( "Data\\Script\\Interface\\InitInterface.lua" )
	
	--Load score Script 
	Script.Load( "Data\\Script\\MapTools\\Score.lua" )
	
	--load music script
	Script.Load( "Data\\Script\\Local\\LocalMusic.lua" )
	
	--load script for puppet master (Only GC!)
	Script.Load( "Data\\Script\\Local\\LocalPuppetMaster.lua" )

	--load the display, sound and control options for ingame modifications
	Script.Load( "Data\\Script\\MainMenu\\OptionsDisplay.lua" )
	Script.Load( "Data\\Script\\MainMenu\\OptionsSound.lua" )
	Script.Load( "Data\\Script\\MainMenu\\OptionsControls.lua" )
	
	--load AddOn keybindings! There will be no assert, if file does not exsist in BASE
	Script.Load( "Data\\Script\\Local\\AOLocalOfficialKeyBindings.lua" )
	
	OptionsSound_Menu.Init()
	OptionsControls_Menu.Init()
end


--------------------------------------------------------------------------------
-- Set default values and init stuff
--------------------------------------------------------------------------------

function GameCallback_LocalSetDefaultValues()

	--Load Counter Script 
	Script.Load( "Data\\Script\\MapTools\\Counter.lua" )
	

	-- Init stuff
	LocalScript_Init()
	Interface_Init()
	Camera_InitParams()

	-- Create Cost Table
	InterfaceGlobals = {}
	InterfaceGlobals.CostTable = {}
	
	-- Reset selection
	GUI.ClearSelection()
	
	
	-- Multi player game?
	if XNetwork.Manager_IsGameRunning() == 1 then
	
		-- Set controlling player
		do
			local PlayerID = XNetwork.Manager_GetLocalMachineLogicPlayerID()
			if PlayerID ~= 0 then
				GUI.SetControlledPlayer( PlayerID )
			end
		end
		
		-- Transfer colors
		do
			Display.InitializePlayerColors()
			local PlayerMaximum = XNetwork.GameInformation_GetMapMaximumNumberOfHumanPlayer()
			for PlayerID=1, PlayerMaximum, 1 do
				local ColorID = XNetwork.GameInformation_GetLogicPlayerColor( PlayerID )
				Display.SetPlayerColorMapping( PlayerID, ColorID )
			end
		end
		
	end
	
	
	-- AnSu: This is not the right place!!! Where can we put this?	
	-- Speech system
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "SpeechTrigger_UpdateEverySecond", 1)
	
	
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "LocalMusic_UpdateMusic", 1)	
	
	
	--Because of garbage problems, when they are updated every turn
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "GUIUpdate_HeroFindButtons", 1)	
	Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "GUIUpdate_SettlersInBuilding", 1)
	
	if GDB.GetValue( "Game\\HighlightNewWorkerHaveNoFarmOrResidenceButtonsFlag" ) == 0 then	
		gvGUI.HighlightNewWorkerHaveNoFarmOrResidenceButtonsTrigger = Trigger.RequestTrigger(Events.LOGIC_EVENT_EVERY_SECOND, nil, "GUIUpdate_HighlightNewWorkerHaveNoFarmOrResidenceButtons", 1)
	end
	
	-- init mpw
	Script.Load( "MP_SettlerServer\\Mods\\MPW\\Ingame\\Core\\script\\mpw\\debug.lua" )
	local path = MPW_Debug and "MP_SettlerServer\\Mods\\MPW\\Ingame\\Core\\script\\mpw\\" or "data\\script\\mpw\\"

	Script.Load( path .. "init.lua" )
	MPW.Init()
end

--------------------------------------------------------------------------------
-- set params after save game load
--------------------------------------------------------------------------------

function GameCallback_LocalRecreateGameLogic()

	-- Init stuff
	LocalScript_Init()	

	if Mission_OnSaveGameLoaded ~= nil then
		Mission_OnSaveGameLoaded()
	end
	
	
	if MultiplayerTools ~= nil then
		MultiplayerTools.OnSaveGameLoaded()
	end
	
	--Update all buttons in the visible container
	XGUIEng.DoManualButtonUpdate(gvGUI_WidgetID.InGame)
	
	GUI.SetSelectedEntity(gvGUI.LastSelectedEntityID)
	
	-- load mpw
	MPW.Load()
	MPW.PostLoad()
end

--------------------------------------------------------------------------------
-- Init Keybindings, Camera, Display and Speech
--------------------------------------------------------------------------------

function LocalScript_Init()	
	
	Interface_InitWidgets()
	if XNetwork.Manager_DoesExist() ~= 1 then
		DebugKeyBindings_Init()
	end
	OfficialKeyBindings_Init()
	Display_SetDefaultValues()
	Speech_Init()
	

	--AnSu: HACK: disable Skybox
	Display.SetRenderSky( 0 )
	
	--AnSu: Restart Music
	LocalMusic.SongLength = 0
	
end

--------------------------------------------------------------------------------
-- Player has won / lost or left the game?
--------------------------------------------------------------------------------

function
GameCallback_PlayerStateChanged( _PlayerID, _State )

	if Score ~= nil then
		Score.CallBackGameWon(_PlayerID, _State)
	end
	
	-- For ladder games
	if XNetwork ~= nil and XNetwork.Manager_DoesExist() == 1 
	 and XNetworkUbiCom ~= nil and XNetworkUbiCom.Manager_DoesExist() == 1 
	 and XNetworkUbiCom.Lobby_IsMatch() then
		local Name = XNetwork.GameInformation_GetLogicPlayerUbiComUserName( _PlayerID )
		local Team = XNetwork.GameInformation_GetPlayerTeam( _PlayerID )
		if _State == 2 then
			-- Player has won
			XNetworkUbiCom.Match_SetSingleResult(Name, 1, Team - 1)
		elseif _State == 3 then
			-- Player has lost
			XNetworkUbiCom.Match_SetSingleResult(Name, -1, Team - 1)
		end
	end
	
	
	local PlayerID = GUI.GetPlayerID()
	if PlayerID  == _PlayerID then
		--player has won
		if _State == 2 then			
			XGUIEng.ShowAllSubWidgets("Windows",0)	
			XGUIEng.ShowWidget( gvGUI_WidgetID.GameEndScreen,1 )			
			XGUIEng.SetTextKeyName(gvGUI_WidgetID.GameEndScreenMessage	, "WindowMisc/EndScreen_Won")	
			
			local SongToPlay = Folders.Music .. "Win.mp3"
			Sound.StartMusic( SongToPlay, 127)
			
		--player has lost
		elseif _State == 3 then
			XGUIEng.ShowAllSubWidgets("Windows",0)	
			XGUIEng.ShowWidget( gvGUI_WidgetID.GameEndScreen,1 )				
			XGUIEng.SetTextKeyName(gvGUI_WidgetID.GameEndScreenMessage	, "WindowMisc/EndScreen_Lost")	
			
			local SongToPlay = Folders.Music .. "Failed.mp3"
			Sound.StartMusic( SongToPlay, 127)
			
		end
	end
end
