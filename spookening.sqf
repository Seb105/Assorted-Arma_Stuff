// prepare to be spooked!
if (!isServer) exitwith {};
Seb_Spookening = true;

if (Seb_spookLoopIsOn isEqualTo true) exitWith {systemchat "instance already running!"};

private _viewLength = 30;
private _viewFOV = 50;
private _viewPoly = [[0,0,0],[((tan (_viewFOV/2))*_viewLength),_viewLength,0],[-((tan (_viewFOV/2))*_viewLength),_viewLength,0]];
systemchat str _viewPoly;


while {Seb_Spookening} do {
   Seb_spookLoopIsOn = true;
   private _allPlayers = call BIS_fnc_listPlayers;
   private _randomPlayer = selectRandom _allplayers;
   private _randomPlayerPos = getPos _randomPlayer;
   private _spookGroup = createGroup [civilian, true];
   private _spooker = _spookGroup createUnit ["LOP_CHR_Civ_Woodlander_04",_randomPlayerPos,[],50,"NONE"];
   _spooker setUnitLoadout [[[],[],[],["UK3CB_CW_SOV_O_Early_U_Sniper_Uniform_01_Ghillie_Top_KHK",[]],[],[],"","G_Bandanna_oli",[],["ItemMap","","ItemRadio","ItemCompass","ItemWatch",""]],false];
   private _spookWp = _spookGroup addWaypoint [position _randomPlayer, 0];
   _spookWp setWaypointSpeed "FULL";
   sleep 2;
   private _spookCheckHandler = [{
      (_this select 0) params ["_allPlayers","_spooker","_viewPoly"];
      if (damage _spooker < 0.1) then {
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
            if (getpos _spooker inPolygon _viewPolyPlayer) then {
               deleteVehicle _spooker;
               [_handle] call CBA_fnc_removePerFrameHandler;
            };
         } forEach _allplayers;
      } else {
         deleteVehicle _spooker;
         [_handle] call CBA_fnc_removePerFrameHandler;
      };

   }, 0,[_allPlayers,_spooker,_viewPoly]] call CBA_fnc_addPerFrameHandler;
   sleep 14;
   [_spookCheckHandler] call CBA_fnc_removePerFrameHandler;
   deleteVehicle _spooker;
};
systemchat "exiting";
Seb_spookLoopIsOn = false;
