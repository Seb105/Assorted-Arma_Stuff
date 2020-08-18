// Actions
{
	private _team = "0";
	_x addAction
	[
		"Go to cannon: Bow Top",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_teamNum = _this select 3;
			_vehicle = ["CANNON_BOWMID",_teamNum] joinstring "_";
			moveOut player;
			player moveInTurret [(missionNamespace getVariable _vehicle),[0]];
			player switchCamera "Gunner";
		},
		_team,6,true,true,"","_originalTarget == _this", 50,false,"",""
	];
	_x addAction
	[
		"Go to cannon: Aft Top",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_teamNum = _this select 3;
			_vehicle = ["CANNON_AFTMID",_teamNum] joinstring "_";
			moveOut player;
			player moveInTurret [(missionNamespace getVariable _vehicle),[0]];
			player switchCamera "Gunner";
		},
		_team,6,true,true,"","_originalTarget == _this", 50,false,"",""
	];
	_x addAction
	[
		"Go to cannon: Aft Portside",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_teamNum = _this select 3;
			_vehicle = ["CANNON_PORTAFT",_teamNum] joinstring "_";
			moveOut player;
			player moveInTurret [(missionNamespace getVariable _vehicle),[0]];
			player switchCamera "Gunner";
		},
		_team,6,true,true,"","_originalTarget == _this", 50,false,"",""
	];
	_x addAction
	[
		"Go to cannon: Bow Portside",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_teamNum = _this select 3;
			_vehicle = ["CANNON_PORTBOW",_teamNum] joinstring "_";
			moveOut player;
			player moveInTurret [(missionNamespace getVariable _vehicle),[0]];
			player switchCamera "Gunner";
		},
		_team,6,true,true,"","_originalTarget == _this", 50,false,"",""
	];
	_x addAction
	[
		"Go to cannon: Aft Starboard",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_teamNum = _this select 3;
			_vehicle = ["CANNON_STARAFT",_teamNum] joinstring "_";
			moveOut player;
			player moveInTurret [(missionNamespace getVariable _vehicle),[0]];
			player switchCamera "Gunner";
		},
		_team,6,true,true,"","true", 50,false,"",""
	];
	_x addAction
	[
		"Go to cannon: Bow Starboard",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_teamNum = _this select 3;
			_vehicle = ["CANNON_STARBOW",_teamNum] joinstring "_";
			moveOut player;
			player moveInTurret [(missionNamespace getVariable _vehicle),[0]];
			player switchCamera "Gunner";
		},
		_team,6,true,true,"","_originalTarget == _this", 50,false,"",""
	];
	_x addAction
	[
		"Go to cockpit",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
			_teamNum = _this select 3;
			_vehicle = ["COCKPIT",_teamNum] joinstring "_";
			moveOut player;
			player moveInDriver (missionNamespace getVariable _vehicle); 
		},
		_team,6,true,true,"","_originalTarget == _this", 50,false,"",""
	];
} forEach units group Captain_0;

// Death condition
	// team 0
!alive HEALTH_MIDDECK_0 && !alive HEALTH_PORTFRONT_0 && !alive HEALTH_PORTMID_0 && !alive HEALTH_PORTREAR_0 && !alive HEALTH_STARFRONT_0 && !alive HEALTH_STARMID_0 && !alive HEALTH_STARREAR_0
	// team 1
!alive HEALTH_MIDDECK_1 && !alive HEALTH_PORTFRONT_1 && !alive HEALTH_PORTMID_1 && !alive HEALTH_PORTREAR_1 && !alive HEALTH_STARFRONT_1 && !alive HEALTH_STARMID_1 && !alive HEALTH_STARREAR_1
	// team 2
!alive HEALTH_MIDDECK_2 && !alive HEALTH_PORTFRONT_2 && !alive HEALTH_PORTMID_2 && !alive HEALTH_PORTREAR_2 && !alive HEALTH_STARFRONT_2 && !alive HEALTH_STARMID_2 && !alive HEALTH_STARREAR_2

// Helicopters
this allowDamage false;
this addAction
		[
		"Undock (you cannot redock)",
		{
			params ["_target", "_caller", "_actionId", "_arguments"];
				{
				detach _x;
				} forEach attachedObjects Flagpole_0;
			},
		nil,0,true,true,"","_this in _target", 50,false,"",""
	];
	
	
// Trigger Code
COCKPIT_2 allowDamage true;
COCKPIT_2 setHitPointDamage ["HitEngine", 1];
COCKPIT_2 setHitPointDamage ["HitVRotor", 1];
hint "BURGER IS GOING DOWN!";

//

