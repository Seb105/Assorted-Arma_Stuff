this setVariable ["BIS_enableRandomization", false];
this setVehicleLock "LOCKEDPLAYER";
_action = this addAction  
[  
 "Hack the Planet",  
 {  
  params ["_target", "_caller", "_actionId", "_arguments"]; 
  IsHackDone = true;
  publicVariable "IsHackDone";
 },  
 _action,  
 1.5,  
 true,  
 true,  
 "",  
 "!IsHackDone", 
 15,  
 false,  
 "",  
 ""  
];

this setObjectMaterial [1,"A3\Data_F\mirror.rvmat"];
this setObjectMaterial [2,"A3\Data_F\mirror.rvmat"]; 
(backpackContainer this) setObjectMaterial [0,"A3\Data_F\mirror.rvmat"]; 

_x addEventHandler ["Killed", {
	params ["_unit", "_killer", "_instigator", "_useEffects"];
		["_unit",{
		_corpse = _this select 0;
		private _dummy = "#particlesource" createVehicleLocal ASLToAGL getPosWorld _corpse;
		_dummy say3D "whatever";
		_dummy spawn {
			sleep 5;
			deleteVehicle _this;
		};	
	}] remoteExec ["BIS_fnc_spawn",0,true];
};

_x addEventHandler ["Reloaded", {
	params ["_unitReloaded", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];
		["_unitReloaded",{
			_reloadeddude = _this select 0;
			_reloadeddude say3D [ChromeDomeReload, 300]
		};
	}] remoteExec ["BIS_fnc_spawn",0,true];
};