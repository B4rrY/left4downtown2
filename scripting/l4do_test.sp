/* Plugin Template generated by Pawn Studio */

#include <sourcemod>
#include <sdktools>

//set to 1 to require left4downtown
//set to 0 to just work without it (eg check gameconf)
#define USE_NATIVES 1

#if USE_NATIVES
#include "left4downtown.inc"
#endif

#define TEST_DEBUG 1
#define TEST_DEBUG_LOG 0

new Handle:gConf;

public Plugin:myinfo = 
{
	name = "L4D Downtown's Extension Test",
	author = "Downtown1",
	description = "Ensures functions/offsets are valid and provides some commands to call into natives directly",
	version = "1.0.0.6",
	url = "<- URL ->"
}

new Handle:cvarBlockTanks = INVALID_HANDLE;
new Handle:cvarBlockWitches = INVALID_HANDLE;
new Handle:cvarSetCampaignScores = INVALID_HANDLE;
new Handle:cvarFirstSurvivorLeftSafeArea = INVALID_HANDLE;
new Handle:cvarProhibitBosses = INVALID_HANDLE;
new Handle:cvarFinaleEscape;


#define GAMECONFIG_FILE "left4downtown.l4d2"

stock L4D_SetRoundEndTime(Float:endTime)
{
	static bool:init = false;
	static Handle:func = INVALID_HANDLE;
	
	if(!init)
	{
		new Handle:conf = LoadGameConfigFile(GAMECONFIG_FILE);
		if(conf == INVALID_HANDLE)
		{
			LogError("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
			DebugPrintToAll("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
		}
		
		StartPrepSDKCall(SDKCall_GameRules);
		new bool:readConf = PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTerrorGameRules_SetRoundEndTime");
		if(!readConf)
		{
			ThrowError("Failed to read function from game configuration file");
		}
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		func = EndPrepSDKCall();
		
		if(func == INVALID_HANDLE)
		{
			ThrowError("Failed to end prep sdk call");
		}
		
		init = true;
	}

	SDKCall(func, endTime);
	DebugPrintToAll("CTerrorGameRules::SetRoundTime(%f)", endTime);
}


stock L4D_ResetRoundNumber()
{
	static bool:init = false;
	static Handle:func = INVALID_HANDLE;
	
	if(!init)
	{
		new Handle:conf = LoadGameConfigFile(GAMECONFIG_FILE);
		if(conf == INVALID_HANDLE)
		{
			LogError("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
			DebugPrintToAll("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
		}
		
		StartPrepSDKCall(SDKCall_GameRules);
		new bool:readConf = PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTerrorGameRules_ResetRoundNumber");
		if(!readConf)
		{
			ThrowError("Failed to read function from game configuration file");
		}
		func = EndPrepSDKCall();
		
		if(func == INVALID_HANDLE)
		{
			ThrowError("Failed to end prep sdk call");
		}
		
		init = true;
	}

	SDKCall(func);
	DebugPrintToAll("CTerrorGameRules::ResetRoundNumber()");
}

native L4D_ToggleGhostsInFinale(bool:enableGhostsInFinale);


public OnPluginStart()
{
	gConf = LoadGameConfigFile(GAMECONFIG_FILE);
	if(gConf == INVALID_HANDLE) 
	{
		DebugPrintToAll("Could not load gamedata/%s.txt", GAMECONFIG_FILE);
	}
	
	SearchForOffset("TheDirector"); //fails on Linux
	SearchForOffset("TheZombieManager"); //fails on Linux
	SearchForOffset("ValveRejectServerFullFirst");
	
	SearchForFunction("GetTeamScore");
	SearchForFunction("SetCampaignScores");
	SearchForFunction("ClearTeamScores");
	SearchForFunction("SetReservationCookie");
	SearchForFunction("TakeOverBot");
	SearchForFunction("SetHumanSpec");
	
	SearchForFunction("CDirectorScavengeMode_OnBeginRoundSetupTime");
	SearchForFunction("CTerrorGameRules_ResetRoundNumber");
	SearchForFunction("CTerrorGameRules_SetRoundEndTime");
	SearchForFunction("CDirector_AreWanderersAllowed");
	SearchForFunction("DirectorMusicBanks_OnRoundStart");
	
	
	SearchForFunction("TheDirector"); //fails on Windows
	SearchForFunction("RestartScenarioFromVote");
	
	SearchForFunction("Rematch");
	
	SearchForFunction("SpawnTank");
	SearchForFunction("SpawnWitch");
	SearchForFunction("OnFirstSurvivorLeftSafeArea");
	SearchForFunction("CDirector_GetScriptValueInt");
	SearchForFunction("CDirector_IsFinaleEscapeInProgress");
	SearchForFunction("CTerrorPlayer_CanBecomeGhost");
	
	SearchForFunction("CTerrorPlayer_OnEnterGhostState");
	SearchForFunction("CDirector_IsFinale");
	
	SearchForFunction("TryOfferingTankBot");
	SearchForFunction("OnMobRushStart");
	SearchForFunction("Zombiemanager_SpawnITMob");
	SearchForFunction("Zombiemanager_SpawnMob");
	
	SearchForFunction("CTerrorPlayer_OnStaggered");
	SearchForFunction("CTerrorPlayer_OnShovedBySurvivor");
	SearchForFunction("CTerrorPlayer_GetCrouchTopSpeed");
	SearchForFunction("CTerrorPlayer_GetRunTopSpeed");
	SearchForFunction("CTerrorPlayer_GetWalkTopSpeed");
	
	/*
	* These searches will fail when slots are patched
	*/
	SearchForFunction("ConnectClientLobbyCheck");
	SearchForFunction("HumanPlayerLimitReached");
	SearchForFunction("GetMaxHumanPlayers");
	
	SearchForFunction("GetMasterServerPlayerCounts");

	//////

	RegConsoleCmd("sm_brst", Command_BeginRoundSetupTime);
	RegConsoleCmd("sm_rrn", Command_ResetRoundNumber);
	RegConsoleCmd("sm_sret", Command_SetRoundEndTime);
	RegConsoleCmd("sm_sig", Command_FindSig);
	
	RegConsoleCmd("sm_ir", Command_IsReserved);
	RegConsoleCmd("sm_rsfv", Command_RestartScenarioFromVote);
	RegConsoleCmd("sm_ur", Command_Unreserve);
	RegConsoleCmd("sm_hordetime", Command_HordeTimer);
	

	cvarBlockTanks = CreateConVar("l4do_block_tanks", "0", "Disable ZombieManager::SpawnTank", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarBlockWitches = CreateConVar("l4do_block_witches", "0", "Disable ZombieManager::SpawnWitch", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarSetCampaignScores = CreateConVar("l4do_set_campaign_scores", "0", "Override campaign score if non-0", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);

	cvarFirstSurvivorLeftSafeArea = CreateConVar("l4do_versus_round_started", "0", "Block versus round from starting if non-0", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarProhibitBosses = CreateConVar("l4do_unprohibit_bosses", "0", "Override ProhibitBosses script key if non-0", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);
	cvarFinaleEscape = CreateConVar("l4do_finale_ghosts", "0", "Override finale auto spawning if non-0", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_NOTIFY);

	L4D_ToggleGhostsInFinale(GetConVarBool(cvarFinaleEscape));
	HookConVarChange(cvarFinaleEscape, OnConVarsChanged);
}

public OnConVarsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	L4D_ToggleGhostsInFinale(GetConVarBool(cvarFinaleEscape));
}

public Action:Command_BeginRoundSetupTime(client, args)
{
	
	L4D_ScavengeBeginRoundSetupTime()
	
	return Plugin_Handled;
}


public Action:Command_ResetRoundNumber(client, args)
{
	
	L4D_ResetRoundNumber();
	
	return Plugin_Handled;
}



public Action:Command_SetRoundEndTime(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Error: Specify a round end time");
		return Plugin_Handled;
	}
	
	decl String:functionName[256];
	GetCmdArg(1, functionName, sizeof(functionName));
	new Float:time = StringToFloat(functionName);
	
	L4D_SetRoundEndTime(time);
	
	return Plugin_Handled;
}


public Action:Command_FindSig(client, args)
{
	/* 
	* DOES NOT ACTUALLY WORK :(
	* 
	*/
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Error: Specify a signature");
		return Plugin_Handled;
	}
	
	decl String:functionName[256];
	GetCmdArg(1, functionName, sizeof(functionName));
	new len = strlen(functionName);
	
	StartPrepSDKCall(SDKCall_Static);
	if(PrepSDKCall_SetSignature(SDKLibrary_Server, functionName, len)) {
		DebugPrintToAll("Signature '%s' initialized.", functionName);
	} else {
		DebugPrintToAll("Signature '%s' NOT FOUND.", functionName);
	}
	
	return Plugin_Handled;
}

public Action:L4D_OnSpawnTank(const Float:vector[3], const Float:qangle[3])
{
	DebugPrintToAll("OnSpawnTank(vector[%f,%f,%f], qangle[%f,%f,%f]", 
		vector[0], vector[1], vector[2], qangle[0], qangle[1], qangle[2]);
		
	if(GetConVarBool(cvarBlockTanks))
	{
		DebugPrintToAll("Blocking tank spawn...");
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
}

public Action:L4D_OnSpawnWitch(const Float:vector[3], const Float:qangle[3])
{
	DebugPrintToAll("OnSpawnWitch(vector[%f,%f,%f], qangle[%f,%f,%f])", 
		vector[0], vector[1], vector[2], qangle[0], qangle[1], qangle[2]);
		
	if(GetConVarBool(cvarBlockWitches))
	{
		DebugPrintToAll("Blocking witch spawn...");
		return Plugin_Handled;
	}
	else
	{
		return Plugin_Continue;
	}
}

public Action:L4D_OnClearTeamScores(bool:newCampaign)
{
	DebugPrintToAll("OnClearTeamScores(newCampaign=%d)", newCampaign); 
		
	return Plugin_Continue;
}

public Action:L4D_OnSetCampaignScores(&scoreA, &scoreB)
{
	DebugPrintToAll("SetCampaignScores(A=%d, B=%d", scoreA, scoreB); 
	
	if(GetConVarInt(cvarSetCampaignScores)) 
	{
		scoreA = GetConVarInt(cvarSetCampaignScores);
		DebugPrintToAll("Overrode with SetCampaignScores(A=%d, B=%d", scoreA, scoreB); 
	}
}

public Action:L4D_OnFirstSurvivorLeftSafeArea(client)
{
	DebugPrintToAll("OnFirstSurvivorLeftSafeArea(client=%d)", client); 
	
	if(GetConVarInt(cvarFirstSurvivorLeftSafeArea)) 
	{
		DebugPrintToAll("Blocking OnFirstSurvivorLeftSafeArea...");
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:L4D_OnGetScriptValueInt(const String:key[], &retVal)
{
	//DebugPrintToAll("OnGetScriptValueInt(key=\"%s\",retVal=%d)", key, retVal); 
	
	if(GetConVarInt(cvarProhibitBosses) && StrEqual(key, "ProhibitBosses")) 
	{
		//DebugPrintToAll("Overriding OnGetScriptValueInt(ProhibitBosses)...");
		retVal = 0; //no, do not prohibit bosses thank you very much
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public L4D_OnEnterGhostState(client)
{
	DebugPrintToAll("L4D_OnEnterGhostState(client=%N)", client); 
}

public Action:L4D_OnTryOfferingTankBot(tank_index, &bool:enterStasis)
{
	DebugPrintToAll("L4D_OnTryOfferingTankBot() fired with tank %d and enterstasis %d", tank_index, enterStasis);
	return Plugin_Continue;
}

public Action:L4D_OnMobRushStart()
{
	DebugPrintToAll("L4D_OnMobRushStart() fired");
	return Plugin_Continue;
}

public Action:L4D_OnSpawnITMob(&amount)
{
	DebugPrintToAll("L4D_OnSpawnITMob(%d) fired", amount);
	return Plugin_Continue;
}

public Action:L4D_OnSpawnMob(&amount)
{
	DebugPrintToAll("L4D_OnSpawnMob(%d) fired", amount);
	return Plugin_Continue;
}

public Action:L4D_OnShovedBySurvivor(client, victim, const Float:vector[3])
{
	DebugPrintToAll("L4D_OnShovedBySurvivor() fired, victim %N", victim);
	
	if (client)
	{
		DebugPrintToAll("Shoving client: %N", client);
	}
	// return Plugin_Handled to completely stop melee effects on SI
	return Plugin_Continue;
}

// caution, those 3 are super spammy
public Action:L4D_OnGetCrouchTopSpeed(target, &Float:retVal)
{
	// DebugPrintToAll("OnOnGetCrouchTopSpeed(target=%N, retVal=%f)", target, retVal);
	return Plugin_Continue;
}

public Action:L4D_OnGetRunTopSpeed(target, &Float:retVal)
{
	// DebugPrintToAll("OnOnGetRunTopSpeed(target=%N, retVal=%f)", target, retVal);
	return Plugin_Continue;
}

public Action:L4D_OnGetWalkTopSpeed(target, &Float:retVal)
{
	// DebugPrintToAll("OnOnGetWalkTopSpeed(target=%N, retVal=%f)", target, retVal);
	return Plugin_Continue;
}

public OnMapStart()
{
	//CreateTimer(0.1, Timer_GetCampaignScores, _);
}


public Action:Command_IsReserved(client, args)
{
#if USE_NATIVES
	//new bool:res = L4D_LobbyIsReserved();
	
	//DebugPrintToAll("Lobby is %s reserved...", res ? "" : "NOT");
#endif
	
	return Plugin_Handled;
}

public Action:Command_RestartScenarioFromVote(client, args)
{
#if USE_NATIVES
	decl String:currentmap[128];
	GetCurrentMap(currentmap, sizeof(currentmap));
	
	DebugPrintToAll("Restarting scenario from vote ...");
	L4D_RestartScenarioFromVote(currentmap);
#endif
	
	return Plugin_Handled;
}

public Action:Command_Unreserve(client, args)
{
#if USE_NATIVES
	DebugPrintToAll("Invoking L4D_LobbyUnreserve() ...");
	L4D_LobbyUnreserve();
#endif
	
	return Plugin_Handled;
}

public Action:Command_HordeTimer(client, args)
{
#if USE_NATIVES
	new Float:hordetime = L4D_GetMobSpawnTimerRemaining();
	DebugPrintToAll("Time remaining for next horde is: %f", hordetime);
	ReplyToCommand(client, "Remaining: %f", hordetime);
#endif
}

SearchForFunction(const String:functionName[])
{
	StartPrepSDKCall(SDKCall_Static);
	if(PrepSDKCall_SetFromConf(gConf, SDKConf_Signature, functionName)) {
		DebugPrintToAll("Function '%s' initialized.", functionName);
	} else {
		DebugPrintToAll("Function '%s' not found.", functionName);
	}
}


	
SearchForOffset(const String:offsetName[])
{
	new offset = GameConfGetOffset(gConf, offsetName);
	DebugPrintToAll("Offset for '%s' is %d", offsetName, offset);
}


DebugPrintToAll(const String:format[], any:...)
{
	#if TEST_DEBUG	|| TEST_DEBUG_LOG
	decl String:buffer[192];
	
	VFormat(buffer, sizeof(buffer), format, 2);
	
	#if TEST_DEBUG
	PrintToChatAll("[TEST-L4DO] %s", buffer);
	PrintToConsole(0, "[TEST-L4DO] %s", buffer);
	#endif
	
	LogMessage("%s", buffer);
	#else
	//suppress "format" never used warning
	if(format[0])
		return;
	else
		return;
	#endif
}