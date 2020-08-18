/*
Insurgency Style Respawn Script - by Highway & Seb

Params:
0 - Respawn countdown in seconds - default 90 if undefined
1 - Number of waves available - can be an array of [east,west,independent] OR a whole number which is the same for each - default 5 if undefined
2 - Respawn threshold. Ratio of living to dead players that is required to respawn (0.3 = 30% of players dead etc) - default 0.3 if undefined

*/
params [["_respawnCountdown",90],["_startingWaves",5],["_respawnThreshold",0.3]];

waitUntil { time > 5 }; // hoping everyone will connect in 5 secs

// if startingWaves is an array then use it to set unique set waves for each side, else everyone has the same waves
if (isArray _startingWaves) then {
	MW_wavesLeftEast = _startingWaves select 0;
	MW_wavesLeftWest = _startingWaves select 1;
	MW_wavesLeftInde = _startingWaves select 2;
} else {
	MW_wavesLeftEast = _startingWaves;
	MW_wavesLeftWest = _startingWaves;
	MW_wavesLeftInde = _startingWaves;
};

MW_eastRespawnInProgress = false;
MW_westRespawnInProgress = false;
MW_indeRespawnInProgress = false;

// gets all players of each side living or dead after mission start
MW_totalUnitsEast = allPlayers select { side _x == east };
MW_totalUnitsWest = allPlayers select { side _x == west };
MW_totalUnitsInde = allPlayers select { side _x == independent };

// respawn loop
while { true } do {
	sleep 5;

	// returns a number between 0 and 1, where 0 is no dead players and 1 is all dead players for eachs side
	_deadRatioEast = (allPlayers select { side _x == east })/count MW_totalUnitsEast;
	_deadRatioWest = (allPlayers select { side _x == west })/count MW_totalUnitsWest;
	_deadRatioInde = (allPlayers select { side _x == independent })/count MW_totalUnitsInde;


	// East respawn
	if (!MW_eastRespawnInProgress && (_deadRatioEast > _respawnThreshold) && MW_wavesLeftEast > 0) then {
		[_respawnCountdown] spawn {
			params ["_respawnCountdown"];

			scriptName "East Respawn wave";
			"East Respawn in progress" call BIS_fnc_log;

			MW_eastRespawnInProgress = true;
			sleep _respawnCountdown;
			[0] remoteExec ["setPlayerRespawnTime",MW_totalUnitsEast];
			sleep 2;
			[1e39] remoteExec ["setPlayerRespawnTime",MW_totalUnitsEast];
			MW_totalUnitsEast = allPlayers select { side _x == east };
			MW_eastRespawnInProgress = false;
			MW_wavesLeftEast = MW_wavesLeftEast - 1;
		};
	};

	// West respawn
	if (!MW_westRespawnInProgress && (_deadRatioWest > _respawnThreshold) && MW_wavesLeftWest > 0) then {
		[_respawnCountdown] spawn {
			params ["_respawnCountdown"];

			scriptName "East Respawn wave";
			"West Respawn in progress" call BIS_fnc_log;

			MW_westRespawnInProgress = true;
			sleep _respawnCountdown;
			[0] remoteExec ["setPlayerRespawnTime",MW_totalUnitsWest];
			sleep 2;
			[1e39] remoteExec ["setPlayerRespawnTime",MW_totalUnitsWest];
			MW_totalUnitsWest = allPlayers select { side _x == west };
			MW_westRespawnInProgress = false;
			MW_wavesLeftWest = MW_wavesLeftWest - 1;
		};
	};

	// Inde respawn
	if (!MW_indeRespawnInProgress && (_deadRatioInde > _respawnThreshold) && MW_wavesLeftInde > 0) then {
		[_respawnCountdown] spawn {
			params ["_respawnCountdown"];

			scriptName "East Respawn wave";
			"Inde Respawn in progress" call BIS_fnc_log;

			MW_indeRespawnInProgress = true;
			sleep _respawnCountdown;
			[0] remoteExec ["setPlayerRespawnTime",MW_totalUnitsInde];
			sleep 2;
			[1e39] remoteExec ["setPlayerRespawnTime",MW_totalUnitsInde];
			MW_totalUnitsInde = allPlayers select { side _x == independent };
			MW_indeRespawnInProgress = false;
			MW_wavesLeftInde = MW_wavesLeftInde - 1;
		};
	};
};
