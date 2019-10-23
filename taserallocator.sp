#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <string>
#include <sdkhooks>

Handle taserCookie;

public Plugin myinfo = 
{
	name = "Taser Allocator",
	author = "dasBunny",
	description = "Gives a taser to every player who requests one at round start",
	version = "1.2",
	url = "quixz.eu"
};

public void OnPluginStart(){
	HookEvent("player_spawn", event_Spawn, EventHookMode_Pre);
	taserCookie = RegClientCookie("dasbunny_taserallocator", "Taser Allocator", CookieAccess_Public);
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
		GetClientCookie(client,taserCookie, sCookieVal, sizeof(sCookieVal));
		int cookieVal=StringToInt(sCookieVal);
		if(cookieVal==1){
			CreateTimer(0.1, GiveTaser, client, TIMER_FLAG_NO_MAPCHANGE);
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
			GetClientCookie(client,taserCookie, sCookieVal, sizeof(sCookieVal));
			int cookieVal=StringToInt(sCookieVal);
			if(cookieVal==1) {
				SetClientCookie(client,taserCookie,"0");
				PrintToChat(client,"You'll no longer receive a taser when you spawn");
			}
			else {
				SetClientCookie(client,taserCookie, "1");
				PrintToChat(client,"You'll receive a taser when you spawn");
			}
		}
		else {
			PrintToChat(client,"Error setting taser preference, try again in a few seconds");
		}
	}
	else{
	char arg[256];
	if(strcmp(arg,"on",false)){
		SetClientCookie(client,taserCookie, "1");
		PrintToChat(client,"You'll receive a taser when you spawn");
	}
	if(strcmp(arg,"off",false)){
		SetClientCookie(client,taserCookie,"0");
		PrintToChat(client,"You'll no longer receive a taser when you spawn");
	}
	}
	return Plugin_Continue;
}
