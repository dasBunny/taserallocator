#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <string>
#include <sdkhooks>

Handle g_taserEnabled;
Handle g_taserKills;

public Plugin myinfo = 
{
	name = "Taser Allocator",
	author = "dasBunny",
	description = "Gives a taser to every player who requests one at round start",
	version = "1.3.4",
	url = "quixz.eu"
};

public void OnPluginStart(){
	HookEvent("player_spawn", event_Spawn, EventHookMode_Pre);
	HookEvent("player_death", event_Death, EventHookMode_Pre);
	g_taserEnabled = RegClientCookie("dasbunny_taserEnabled", "Taser Allocator - Taser enabled", CookieAccess_Public);
	g_taserKills = RegClientCookie("dasbunny_taserKills", "Taser Allocator - Taser kills", CookieAccess_Protected);
	RegConsoleCmd("taser",TaserCommand);
	
}

public Action event_Spawn(Event event, const char[] name, bool dontBroadcast){
	int user = event.GetInt("userid");
	int client= GetClientOfUserId(user);
	if(IsFakeClient(client)){
		return Plugin_Continue;
	}
	if(AreClientCookiesCached(client)){
		char sCookieVal[2];
		GetClientCookie(client, g_taserEnabled, sCookieVal, sizeof(sCookieVal));
		int cookieVal=StringToInt(sCookieVal);
		if(cookieVal==1){
			CreateTimer(0.1, GiveTaser, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}

public Action event_Death(Event event, const char[] name, bool dontBroadcast){
	char weapon[64];
	event.GetString("weapon", weapon, sizeof(weapon));
	if(!strcmp(weapon, "taser", false)){
		int killer_user = event.GetInt("attacker");
		int killer = GetClientOfUserId(killer_user);
		if(IsFakeClient(killer)){
			return Plugin_Continue;
			}
		if(AreClientCookiesCached(killer)){
			char s_kills[16];
			GetClientCookie(killer,g_taserKills, s_kills,sizeof(s_kills));
			int kills = StringToInt(s_kills);
			kills++;
			IntToString(kills, s_kills, sizeof(s_kills));
			SetClientCookie(killer, g_taserKills, s_kills);
		}
	}
	return Plugin_Continue;
}	

public Action GiveTaser(Handle timer, int client){
	GivePlayerItem(client,"weapon_taser");
}

public Action TaserCommand(int client, int args){
	if(args==0){
		if(AreClientCookiesCached(client)){
			char sCookieVal[2];
			GetClientCookie(client,g_taserEnabled, sCookieVal, sizeof(sCookieVal));
			int cookieVal=StringToInt(sCookieVal);
			if(cookieVal==1) {
				SetClientCookie(client,g_taserEnabled,"0");
				PrintToChat(client,"You'll no longer receive a taser when you spawn");
			}
			else {
				SetClientCookie(client,g_taserEnabled, "1");
				PrintToChat(client,"You'll receive a taser when you spawn");
			}
		}
		else {
			PrintToChat(client,"Error setting taser preference, try again in a few seconds");
		}
	}
	else{
		char arg[256];
		GetCmdArg(1, arg, sizeof(arg));
		if(!strcmp(arg,"on",false)){
			SetClientCookie(client,g_taserEnabled, "1");
			PrintToChat(client,"You'll receive a taser when you spawn");
		}
		if(!strcmp(arg,"off",false)){
			SetClientCookie(client,g_taserEnabled,"0");
			PrintToChat(client,"You'll no longer receive a taser when you spawn");
		}
		if(!strcmp(arg,"score", false)){
			
		}
	}
	return Plugin_Continue;
}
