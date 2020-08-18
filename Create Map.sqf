/* 
USAGE: Move any object you want adding to the map to an eden layer called "EdenMapObjects"
The, paste the following code in the init of any permanent object:
*/

if (isServer) then {
	[] spawn {
		_EdenObjectNum = 0;
			{
			_name = (["3DenObjectMarker",_EdenObjectNum] joinstring "_");
			_bbr = boundingBoxReal _x;
			_p1 = _bbr select 0;
			_p2 = _bbr select 1;
			_maxWidth = abs ((_p2 select 0) - (_p1 select 0));
			_maxLength = abs ((_p2 select 1) - (_p1 select 1));
			_Direction = getDir _x;
			createMarker [_name, _x];
			_name setMarkerShape "RECTANGLE";
			_name setMarkerBrush "SolidFull";
			_name setMarkerSize [(_maxWidth / 2),(_maxLength / 2)];
			_name setMarkerDir _Direction;
			_name setMarkerAlpha 1;
			_name setmarkerColor "ColorGrey";
			_EdenObjectNum = _EdenObjectNum+1;
			} forEach ((getMissionLayerEntities "EdenMapObjects") select 0);
	};
};