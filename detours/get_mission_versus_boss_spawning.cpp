/**
 * vim: set ts=4 :
 * =============================================================================
 * Left 4 Downtown SourceMod Extension
 * Copyright (C) 2009 Igor "Downtown1" Smirnov.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 * Version: $Id$
 */

#include "get_mission_versus_boss_spawning.h"
#include "extension.h"
#include "l4d2calls.h"
#include <KeyValues.h>

namespace Detours
{
	void GetMissionVersusBossSpawning::OnGetMissionVersusBossSpawning(float &spawn_pos_min, float &spawn_pos_max, float &tank_chance, float &witch_chance)
	{
		L4D_DEBUG_LOG("CDirectorVersusMode::GetMissionVersusBossSpawning has been called, %f %f %f %f", spawn_pos_min, spawn_pos_max, tank_chance, witch_chance);
		
		//KeyValues *kCurMission = NULL;
		KeyValues *kCurMission = CTerrorGameRules__GetMissionCurrentMap(NULL);
		if(kCurMission && (kCurMission = kCurMission->FindKey("versus_boss_spawning", false)) != NULL)
		{
			spawn_pos_min = kCurMission->GetFloat("spawn_pos_min", spawn_pos_min);
			spawn_pos_max = kCurMission->GetFloat("spawn_pos_max", spawn_pos_max);
			tank_chance = kCurMission->GetFloat("tank_chance", tank_chance);
			witch_chance = kCurMission->GetFloat("witch_chance", witch_chance);
		}
		
		cell_t result = Pl_Continue;
		if(g_pFwdOnGetMissionVersusBossSpawning)
		{
			L4D_DEBUG_LOG("L4D_OnGetMissionVersusBossSpawning forward has been sent out");
			g_pFwdOnSetCampaignScores->PushFloatByRef(&spawn_pos_min);
			g_pFwdOnSetCampaignScores->PushFloatByRef(&spawn_pos_max);
			g_pFwdOnSetCampaignScores->PushFloatByRef(&tank_chance);
			g_pFwdOnSetCampaignScores->PushFloatByRef(&witch_chance);
			g_pFwdOnSetCampaignScores->Execute(&result);
		}

		return;
	}
};