#pragma semicolon 1

#include <sourcemod>
#include <cstrike>
#include <ttt>
#include <ttt_sql>
#include <ttt_shop>
#include <ttt_grabbermod>

#pragma newdecls required

#define PLUGIN_NAME TTT_PLUGIN_NAME ... " - API Test"

#define PLUGIN_ITEM_SHORT "testitem"
#define PLUGIN_ITEM_LONG  "Test Item"
#define PLUGIN_ITEM_PRICE 350

public Plugin myinfo = {
	name = PLUGIN_NAME,
	author = TTT_PLUGIN_AUTHOR,
	description = TTT_PLUGIN_DESCRIPTION,
	version = TTT_PLUGIN_VERSION,
	url = TTT_PLUGIN_URL
};

public void OnPluginStart()
{
	TTT_IsGameCSGO();
	
	CreateConVar("ttt2_api_test_version", TTT_PLUGIN_VERSION, TTT_PLUGIN_DESCRIPTION, FCVAR_NOTIFY | FCVAR_DONTRECORD | FCVAR_REPLICATED);

	HookEvent("weapon_fire", Event_WeaponFire);
	
	RegAdminCmd("sm_uitem", Command_UItem, ADMFLAG_ROOT);
	RegAdminCmd("sm_trole", Command_TRole, ADMFLAG_ROOT);
	RegAdminCmd("sm_endround", Command_EndRound, ADMFLAG_ROOT);
}

public Action Command_TRole(int client, int args)
{
	int iRole = TTT_GetClientRole(client);
	char sRole[ROLE_LENGTH], sShort[ROLE_LENGTH];

	TTT_GetRoleNameByID(iRole, sRole, sizeof(sRole));
	TTT_GetShortRoleNameByID(iRole, sShort, sizeof(sShort));
	PrintToChat(client, "(1) Player: %N - RoleID: %d - RoleName: %s - RoleShort: %s", client, iRole, sRole, sShort);
	TTT_GetRoleNameByShortName(sShort, sRole, sizeof(sRole));
	PrintToChat(client, "(2) Player: %N - RoleID: %d - RoleName: %s - RoleShort: %s", client, iRole, sRole, sShort);
	iRole = TTT_GetRoleIDByName(sRole);
	PrintToChat(client, "(3) Player: %N - RoleID: %d - RoleName: %s - RoleShort: %s", client, iRole, sRole, sShort);
	iRole = TTT_GetRoleIDByShortName(sShort);
	PrintToChat(client, "(4) Player: %N - RoleID: %d - RoleName: %s - RoleShort: %s", client, iRole, sRole, sShort);
	TTT_GetShortRoleNameByName(sRole, sShort, sizeof(sShort));
	PrintToChat(client, "(5) Player: %N - RoleID: %d - RoleName: %s - RoleShort: %s", client, iRole, sRole, sShort);
}

public Action Command_EndRound(int client, int args)
{
	if (args != 1)
	{
		ReplyToCommand(client, "sm_endround <delay in seconds>");
		return Plugin_Handled;
	}

	char sArg[12];
	GetCmdArg(1, sArg, sizeof(sArg));

	CS_TerminateRound(StringToFloat(sArg), CSRoundEnd_Draw, true);

	return Plugin_Handled;
}

public Action Command_UItem(int client, int args)
{
	if (args != 2)
	{
		ReplyToCommand(client, "sm_uitem <item name (short)> <price>");
		return Plugin_Handled;
	}
	
	char arg1[MAX_NAME_LENGTH], arg2[5];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	TTT_UpdateCustomItem(arg1, StringToInt(arg2));
	
	return Plugin_Continue;
}

public void OnConfigsExecuted()
{
	RegisterItem();
}

void RegisterItem()
{
	TTT_RegisterCustomItem(PLUGIN_ITEM_SHORT, PLUGIN_ITEM_LONG, PLUGIN_ITEM_PRICE);
}

public Action TTT_OnItemPurchase(int client, int &price, bool &count, const char[] item)
{
	if (TTT_IsClientValid(client) && IsPlayerAlive(client) && strlen(item) > 2)
	{
		PrintToChat(client, "[TTT_OnItemPurchase] It works! Hooray! Item: %s Price: %d Count: %d", item, price, count);
	}

	return Plugin_Continue;
}

public Action TTT_OnItemPurchased(int client, const char[] itemshort, bool count, int price)
{
	if (TTT_IsClientValid(client) && IsPlayerAlive(client) && strlen(itemshort) > 2)
	{
		PrintToChat(client, "[TTT_OnItemPurchased] It works! Hooray! Item: %s Count: %d Price: %d", itemshort, count, price);
	}

	return Plugin_Continue;
}

public Action Event_WeaponFire(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (TTT_IsClientValid(client))
	{
		PrintToChat(client, "Player: %N, Karma %d, Credits: %d", client, TTT_GetClientKarma(client), TTT_GetClientCredits(client));
	}
}

public void TTT_OnRoundStart(int innocents, int traitors, int detective)
{
	PrintToServer("TTT_OnRoundStart was called!");
	PrintToServer("(TTT_OnRoundStart) innocents: %d - traitors: %d - detective: %d", innocents, traitors, detective);
}

public void TTT_OnRoundStartFailed(int players, int requiredPlayers, int detective)
{
	PrintToServer("TTT_OnRoundStartFailed was called!");
	PrintToServer("(TTT_OnRoundStartFailed) players: %d - requiredPlayers: %d - detective: %d", players, requiredPlayers, detective);
}

public void TTT_OnClientGetRole(int client, int role)
{
	PrintToServer("TTT_OnClientGetRole was called!");
	PrintToServer("(TTT_OnClientGetRole) client: %d - role: %d", client, role);
}

public void TTT_OnClientDeath(int victim, int attacker)
{
	PrintToServer("TTT_OnClientDeath was called!");
	PrintToServer("(TTT_OnClientDeath) victim: %d - attacker: %d", victim, attacker);
}

public Action TTT_OnClientDeathPre(int victim, int attacker)
{
	PrintToServer("TTT_OnClientDeathPre was called!");
	PrintToServer("(TTT_OnClientDeathPre) victim: %d - attacker: %d", victim, attacker);
}

public void TTT_OnBodyFound(int client, int victim, const char[] deadPlayer, bool silent)
{
	PrintToServer("TTT_OnBodyFound was called!");
	PrintToServer("(TTT_OnBodyFound) client: %d - victim: %d - deadPlayer: %s - silent: %b", client, victim, deadPlayer, silent);
}

public void TTT_OnBodyScanned(int client, int victim, const char[] deadPlayer)
{
	PrintToServer("TTT_OnBodyScanned was called!");
	PrintToServer("(TTT_OnBodyScanned) client: %d - victim: %d - deadPlayer: %s", client, victim, deadPlayer);
}

public Action TTT_OnPlayerDeath(int victim, int attacker)
{
	PrintToServer("TTT_OnPlayerDeath was called!");
	PrintToServer("(TTT_OnPlayerDeath) victim: %d - attacker: %d", victim, attacker);
}

public void TTT_OnSQLConnect(Database db)
{
	PrintToServer("TTT_OnSQLConnect was called!");
	PrintToServer("(TTT_OnSQLConnect) db: %d", db);

	Database dDB = TTT_GetSQLConnection();
	PrintToServer("(TTT_OnSQLConnect) dDB: %d", dDB);

	if (dDB == db)
	{
		PrintToServer("(TTT_OnSQLConnect) db and dDB are equal!", db);
	}
}

public bool TTT_OnGrabbing(int client, int entity)
{
	PrintToServer("TTT_OnGrabbing was called!");
	PrintToServer("(TTT_OnGrabbing) Client: %N - Entity: %d", client, entity);
}
