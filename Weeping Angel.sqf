if (!isServer) exitwith {};
params ["_statueStone"];

// triangular cone of vision based on  predifined input. Length refers to actual length, not hypotenuse.
private _viewLength = 75;
private _viewFOV = 110;
private _viewPoly = [[0,0,0],[((tan (_viewFOV/2))*_viewLength),_viewLength,0],[-((tan (_viewFOV/2))*_viewLength),_viewLength,0]];

private _statueGroup = createGroup [civilian, true];
_statueGroup setBehaviour "CARELESS";
private _statue = _statueGroup createUnit ["LOP_CHR_Civ_Woodlander_04",_statueStone,[],0,"NONE"];
_statue hideObjectGlobal true;
_statue allowDamage false;
_statue setSpeaker "NoVoice";
_statueStone attachTo [_statue, [0,0,0]];
_statue setVariable ["lastMove",time];

[{
   (_this select 0) params ["_statue","_statueStone","_viewPoly"];
   if (isNull _statue or isNull _statueStone) exitWith {
      [_handle] call CBA_fnc_removePerFrameHandler;
   };
   // builds list of all nearby players the monster can "see" within x m. Ignores vehicles
   private _nearPlayersAll = [_statue,allPlayers,250] call CBA_fnc_getNearest;
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
         private _player = _x;
         private _viewPolyPlayer = _viewPoly apply {
            private _newPoly = _x;
            private _viewDir = ((eyeDirection _player) call CBA_fnc_vect2Polar) select 1;
            _newPoly = [[0,0,0],_newPoly,-_viewDir] call CBA_fnc_vectRotate2D;
            _newPoly = [_newPoly select 0,_newPoly select 1,0];
            private _playerPos = getPos _player;
            _newPoly = _newPoly vectorAdd _playerPos;
            _newPoly
         };
         if (getpos _statueStone inPolygon _viewPolyPlayer) then {
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
               player setPos ([getPos player,500] call CBA_fnc_randPos)
            } remoteExec ["Call",_x];

            [_x,{
               private _scream = selectRandom ["ryanzombiesscream1","ryanzombiesscream2","ryanzombiesscream3","ryanzombiesscream4","ryanzombiesscream5","ryanzombiesscream6","ryanzombiesscream7","ryanzombiesscream8","ryanzombiesscream9"];
               _this say3D [_scream,120,0.5];
            }] remoteExec ["call"];
            _statue setPos ([getPos _statue,50] call CBA_fnc_randPos);
         } forEach (_nearPlayers select {_statue distance _x < 5});
      } else {
         if (simulationEnabled _statue) then {
            _statue enableSimulationGlobal false;
         };
      };
   };
}, 0,[_statue,_statueStone,_viewPoly]] call CBA_fnc_addPerFrameHandler;
