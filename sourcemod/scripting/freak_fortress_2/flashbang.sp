#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>
#include <tf2_stocks>
#include <freak_fortress_2>

#include <stocksoup/sdkports/util>
#include <stocksoup/sdkports/vector>

#tryinclude <ff2_potry>
#if !defined _ff2_potry_included
	#include <freak_fortress_2_subplugin>
#endif

#define THIS_PLUGIN_NAME    "flashbang"

#define FLASHBANG_NAME	     "flashbang"


float g_flFlashTime[MAXPLAYERS + 1] = {0.0, ...};

#if defined _ff2_potry_included
	public void OnPluginStart()
	{
	    FF2_RegisterSubplugin(THIS_PLUGIN_NAME);
	}
#else
	public void OnPluginStart2()
	{
		return;
	}
#endif

#if defined _ff2_potry_included
public void FF2_OnAbility(int boss, const char[] pluginName, const char[] abilityName, int slot, int status)
#else
public Action FF2_OnAbility2(int boss, const char[] pluginName, const char[] abilityName, int status)
#endif
{
	if(StrEqual(abilityName, FLASHBANG_NAME)) {
        Flashbang(GetClientOfUserId(FF2_GetBossUserId(boss)));
	}
}

void Flashbang(int owner)
{
    int colors[4] = {255, 255, 255, 255};
    float targetPos[3], targetAngles[3], ownerPos[3], angles[3];
    float fov = Cosine(0.5 * 75.0);

    GetEntPropVector(owner, Prop_Send, "m_vecOrigin", ownerPos);

    for(int client = 1; client <= MaxClients; client++)
    {
        if(!IsClientInGame(client) || !IsPlayerAlive(client)
        || GetEntProp(owner, Prop_Send, "m_iTeamNum") == GetClientTeam(client)) continue;

        GetClientEyePosition(client, targetPos);
        GetClientEyeAngles(client, targetAngles);
        GetAngleVectors(targetAngles, angles, NULL_VECTOR, NULL_VECTOR);

        if(PointWithinViewAngle(targetPos, ownerPos, angles, fov))
        {
            UTIL_ScreenFade(client, colors, 5.0, 3.0, FFADE_IN);

            // 본인은 제외
            TR_TraceRay(targetPos, ownerPos, MASK_ALL, RayType_EndPoint); // TODO: 창문 같은 경우는 OK
            if(!TR_DidHit())
            {
                // TODO; 플래시뱅 강약 조절: 보이는 각도에 따른 플래시 지속시간
                UTIL_ScreenFade(client, colors, 5.0, 3.0, FFADE_IN);
            }
        }
    }
}
