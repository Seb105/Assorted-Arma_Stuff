/* 		Crew Vision Map System

This will create and update a map marker where the gunner & commander are looking for every crew member of a given vehicle.
It will also create a cone of vision, based on their current FOV.

This is designed for multiplayer with player crew members only.
It will only work if the gunner or commander is a player.

HOW TO USE:
Add this script to your mission's folder, and in the init of your vehicle add the following:
this execVM "CrewVisionMap.sqf";

To initialise for more than one vehicle, simply copy that same init code to the new vehicle.

This will only work if the vehicle has a "gunner" OR "commander" slot, or both. If it only has 1 of those that's fine, it's just pointless to use if these slots do not exist.

Must be executed locally, do not wrap in ifServer.

Does not work for the Blackfish.
*/

if !(hasInterface) exitWith {};
params ["_vehicle"];
// Event handler for player getting into vehicle

disableSerialization;

_vehicle addEventHandler ["GetIn", {
   params ["_vehicle", "_role", "_unit", "_turret"];
   if (player == _unit) then {

      // function to calculate cone field of vision and where gunner/crew is looking.
      Seb_fnc_getCone = {
         params ["_vehicle","_role","_roleFOV"];
         // Resets cone for new calc loop

         // blank cone vertices. This draws a cone with 45deg angle at 100m distance.
         // This is then manipulated based on view direciton and elevation.
      	private _coneArrayTemp = [
            [0				,0			,0],
            [-100			,100		,0],
            [-96.593		,125.883	,0],
            [-86.603		,150		,0],
            [-70.711		,170.711	,0],
            [-50			,186.603	,0],
            [-25.882		,196.593	,0],
            [0				,200		,0],
            [25.882		,196.593	,0],
            [50			,186.603	,0],
            [70.711		,170.711	,0],
            [86.603		,150		,0],
            [96.593		,125.882	,0],
            [100			,100		,0]
         ];


         /* animationsourcephase returns angle relative to model (or turret if commander), in order to convert this from this
         to a usable format (world space), it is converted to a vector, that vector is transformed using vectormodeltoworld, then it is
         turned back into angles. If it is the commander turret, then a turret offset is applied*/
         private _gunnerDirectionModel = -deg (_vehicle animationSourcePhase "mainturret");
         private _gunnerElevationModel = deg (_vehicle animationSourcePhase "maingun");
         private _gunnerVectorModel = [1,_gunnerDirectionModel,_gunnerElevationModel] call CBA_fnc_polar2Vect;
         private _gunnerVectorWorld = _vehicle vectorModelToWorld _gunnerVectorModel;
         private _gunnerWorldAngles = _gunnerVectorWorld call CBA_fnc_vect2Polar;


         // todo: Check if commander is not on turret, then don't apply offset if they are not.
         private _commanderDirectionModel = -(deg (_vehicle animationSourcePhase "obsturret")) + _gunnerDirectionModel;
         private _commanderElevationModel = deg (_vehicle animationSourcePhase "obsgun");
         private _commanderVectorModel = [1,_commanderDirectionModel,_commanderElevationModel] call CBA_fnc_polar2Vect;
         private _commanderVectorWorld = _vehicle vectorModelToWorld _commanderVectorModel;
         private _commanderWorldAngles = _commanderVectorWorld call CBA_fnc_vect2Polar;


         // depending on if gunner or commander is passed as a param get view dir.
         private _viewAzi = 0;
         private _viewElev = 0;
         if (commander _vehicle != _role) then {
            _viewAzi = _gunnerWorldAngles select 1;
            _viewElev = _gunnerWorldAngles select 2;
         } else {
            _viewAzi = _commanderWorldAngles select 1;
            _viewElev = _commanderWorldAngles select 2;
         };

         // a point 8000m from the origin, 0,0,0. This is rotated in the vertical and horizontal axes.
         // Think of this point as line 8km long drawn from the eye of the vehicle crew to where they are looking.
         private _pointRotStart = [0,8000,0];
         // Rotates elevation
         private _pointRotVertDone = [[0,0,0],[_pointRotStart select 1,_pointRotStart select 2], _viewElev] call CBA_fnc_vectRotate2D;
         private _pointRotHorizDone = [[0,0,0],[_pointRotStart select 0,_pointRotVertDone select 0], -_viewAzi] call CBA_fnc_vectRotate2D;
         private _pointIntersectionNoOffset = [_PointRotHorizDone select 0, _PointRotHorizDone select 1, _pointRotVertDone select 1];

         private _vehPos = getPosASL _vehicle;
         private _eyePos = eyePos _role;

         // this is the point now offset based on position of eyes.
         private _pointIntersectionOffset = _pointIntersectionNoOffset vectorAdd _eyePos;



         //Checks if intersecting objects are in the way and returns that intersection pos if true.
         private _intersects = lineIntersectsSurfaces [_eyePos,_pointIntersectionOffset,_vehicle,_role,true,1,"GEOM","VIEW"];
         private _target = [0,0,0];

         // lineIntersectsSurfaces returns nothing if it does not intersect. This fixes that.
         if (count _intersects != 0) then {_target = (_intersects select 0) select 0;} else{_target = _pointIntersectionOffset;};

      	private _distanceToTarget = _vehicle distance2D _target;

      	// Fov ratio calculated by (tan(fov)*distance) divided by 100 as blank cone is set at 100m to target.
      	private _fovRatio = tan(_roleFOV/2)*(_distanceToTarget/100);

      	// Modifies the blank cone with properties from distance2d and FOV. Scales before rotation for less trig!, x dimension is FOV y is distance to target, then rotates.
      	for "_i" from 0 to 13 do {
      		(_coneArrayTemp select _i) params ["_blankX","_blankY"];
      		// Declares Y
      		private _newY = _blankY;

      		// Scales Y dimension to match distance to target
      		private _newY = _newY * (_distanceToTarget/100);
      		// Scales the curved cone so it isn't skewed and has a consistent radius. This took formula took way too long.
      		if (_i >= 2 && _i <= 12) then {_newY = ((_newY-_distanceToTarget)*(tan(_roleFOV/2))+_distanceToTarget)};

      		// Multiplies X dimensions by FOV ratio of blank cone TAN to actual TAN.
      		private _newX = _blankX * _fovRatio;

      		// Rotates X and Y coordinates. Needs to be a new var as X/Y being modified before completion creates skewing innacuracy.
      		private _newRotX = cos(-_viewAzi) * (_newX) - sin(-_viewAzi) * (_newY);
      		private _newRotY = sin(-_viewAzi) * (_newX) + cos(-_viewAzi) * (_newY);

      		// Applies offset so this new cone matches vehicle position.
      		private _newRotX = (_newRotX + (_vehPos select 0));
      		private _newRotY = (_newRotY + (_vehPos select 1));

      		_coneArrayTemp set [_i,[_newRotX,_newRotY,0]];s
         };
         _coneArrayFinal = +_coneArrayTemp;
         // return
         [_coneArrayFinal,_target]
      };

      // updates crew about gunner & commander FOV.
      private _sendInfoHandler = [{
         (_this select 0) params ["_vehicle"];
         if (vehicle player == player) then {
            [_handle] call CBA_fnc_removePerFrameHandler;
         } else {
            if (player == gunner _vehicle) then {
               private _targets = crew _vehicle;
               private _vfov = deg((call CBA_fnc_getFov) select 0);
               private _aspRatio = "NUMBER" call CBA_fnc_getAspectRatio;
               private _hfov = 2*atan(tan(_vfov/2)*_aspRatio);
               [_vehicle,["Seb_CrewVisionMap_gunnerFOV",_hfov]] remoteExec ["setVariable",_targets];
            };
            if (player == commander _vehicle) then {
               private _targets = crew _vehicle;
               private _vfov = deg((call CBA_fnc_getFov) select 0);
               private _aspRatio = "NUMBER" call CBA_fnc_getAspectRatio;
               private _hfov = 2*atan(tan(_vfov/2)*_aspRatio);
               [_vehicle,["Seb_CrewVisionMap_commanderFOV",_hfov]] remoteExec ["setVariable",_targets];
            };
         };
      }, 0.25, [_vehicle]] call CBA_fnc_addPerFrameHandler;

      private _coneCalcs = [{
         (_this select 0) params ["_vehicle"];
         if (vehicle player == player) then {
            [_this select 1] call CBA_fnc_removePerFrameHandler;
         } else {
            // if !(isNull (gunner _vehicle)) then {
         };
      }, 0, [_vehicle]] call CBA_fnc_addPerFrameHandler;

      _fnc_DrawCone = {
         disableSerialization;
         if (vehicle player ==  player) exitWith {
            _thisArgs ctrlRemoveEventHandler ["Draw",_thisID];
         };

         if (!isNull gunner (vehicle player)) then {
            private _gunnerFOV =  (vehicle player) getVariable ["Seb_CrewVisionMap_gunnerFOV",45];
            if (!isPlayer gunner (vehicle player)) then {_gunnerFOV = 45;};
            private _coneAndTarget = [(vehicle player),(gunner (vehicle player)),_gunnerFOV] call Seb_fnc_getCone;
            private _gunnerCone = _coneAndTarget select 0;
            private _gunnerTarget = _coneAndTarget select 1;
            _thisArgs drawPolygon [_gunnerCone, [0,0,1,1]];
            _thisArgs DrawIcon ["pictureExplosive",[0,0,1,1],_gunnerTarget,25,25,0,"Gunner",1];
         };

         if (!isNull commander (vehicle player)) then {
            private _commanderFOV =  (vehicle player) getVariable ["Seb_CrewVisionMap_commanderFOV",45];
            if (!isPlayer commander (vehicle player)) then {_commanderFOV = 45;};
            private _coneAndTarget = [(vehicle player),(commander (vehicle player)),_commanderFOV] call Seb_fnc_getCone;
            private _commanderCone = _coneAndTarget select 0;
            private _commanderTarget = _coneAndTarget select 1;
            _thisArgs drawPolygon [_commanderCone, [0,1,0,1]];
            _thisArgs DrawIcon ["pictureExplosive",[0,1,0,1],_commanderTarget,25,25,0,"Commander",1];
         };
      };

      disableSerialization;
      //Map draw event handler
      private _mapControl = findDisplay 12 displayCtrl 51;
      [_mapControl,"Draw",_fnc_DrawCone,_mapControl] call CBA_fnc_addBISEventHandler;

      //GPS draw event handler
      private _GPSdisplay = uiNamespace getVariable "RscCustomInfoMiniMap";
      private _GPScontrol = _GPSdisplay displayCtrl 101;
      [_GPScontrol,"Draw",_fnc_DrawCone,_GPScontrol] call CBA_fnc_addBISEventHandler;
   };
}];
