if (!isServer) exitwith {};
params ["_statueStone"];

// triangular cone of vision based on  predifined input. Length refers to actual length, not hypotenuse.
private _viewLength = 75;
private _viewFOV = 110;

private _statueGroup = createGroup [civilian, true];
_statueGroup setBehaviour "CARELESS";
private _statue = _statueGroup createUnit ["C_man_1", _statueStone, [], 0, "NONE"];
_statue hideObjectGlobal true;
_statue allowDamage false;
_statue setSpeaker "NoVoice";
_statueStone attachTo [_statue, [0,0,0]];
_statue setVariable ["lastMove", time];

[{
    (_this select 0) params ["_statue","_statueStone","_viewLength", "_viewFOV"];

    if (isNull _statue or isNull _statueStone) exitWith {
        [_handle] call CBA_fnc_removePerFrameHandler;
        {
            if !(isNull _x) then {deleteVehicle _x};
        } forEach [_statue, _statueStone]
    };
    // builds list of all nearby players the monster can "see" within x m. Ignores vehicles
    private _nearPlayersAll = [_statue, allPlayers, 250] call CBA_fnc_getNearest;
    private _nearPlayers = _nearPlayersAll select {
        vehicle _x == _x
    };

    // state cannot be seen at start of loop, this is set to true if statue can be seen
    private _statueSeen = false;
    // by default the statue can do damage, but if it does emergency teleport it cannot.
    private _canDamage = true;

    // check if any player can see statue
    if (count _nearPlayers > 0) then {
        // create a polygonal viewcone for each player, and check if monster is within it.
        {
            private _dir = ((_x getRelDir _statueStone) + _viewFOV/2);
            _dir = [_dir, _dir - 360] select {_dir > 360};
            if (_dir < _viewFov && (_x distance2D _x) < _viewLength) exitWith {
                _statueSeen = true;
            };
        } forEach _nearPlayers;

        // statue can move twice per second per second, if it cannot be seen.
        if (!_statueSeen) then {
            if (!simulationEnabled _statue) then {
                _statue enableSimulationGlobal true;
            };
            if (time > ((_statue getVariable "lastMove") + 0.5)) then {
                _statue setVariable ["lastMove", time];
                private _nearPlayer = _nearPlayers select 0;
                _statueStone setDir ((_statueStone getDir _statue)+180);
                _statue doMove (getPos _nearPlayer);
            };

            // damage player
            {
                {
                    [player, 1, "body", "stab"] call ace_medical_fnc_addDamageToUnit;
                    player setPos ([_statue, 50, 150, 3, 0] call BIS_fnc_findSafePo)
                } remoteExec ["Call", _x];

                _statue setPos ([getPos _statue, 50] call BIS_fnc_findSafePos);
            } forEach (_nearPlayers select {_statue distance _x < 5});
        } else {
            if (simulationEnabled _statue) then {
                _statue enableSimulationGlobal false;
            };
        };
    };
}, 0,[_statue, _statueStone, _viewLength, _viewFOV]] call CBA_fnc_addPerFrameHandler;
