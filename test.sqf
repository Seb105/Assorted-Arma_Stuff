private _light = "#lightpoint" createVehicleLocal [0,0,0];
private _lightR = 1;
private _lightG = 0;
private _lightB = 0;
private _lightcolour = [_lightR,_lightG,_lightB];
_light setLightBrightness 0.75;
_light setLightAmbient _lightcolour;
_light setLightColor _lightcolour;
_light setLightUseFlare true;
_light setLightFlareSize 1;
_light setLightFlareMaxDistance 200;
_light lightAttachObject [this, [0,1.5,6.2]];
_light setLightAttenuation [1,0,8,0,9,0];




if (isServer) then {
   private _wheel = "acd_WoodenCart_F" createVehicle [0,0,0];
   private _bench = "Land_Pod_Heli_Transport_04_bench_F" createVehicle [0,0,0];
   _wheel attachTo [this, [0, -3, -0.65] ];
   _bench attachTo [this, [0, -3, 0.55] ];
   private _y = 180; private _p = -15; private _r = 0;
   _wheel setVectorDirAndUp [
    [ sin _y * cos _p,cos _y * cos _p,sin _p],
    [ [ sin _r,-sin _p,cos _r * cos _p],-_y] call BIS_fnc_rotateVector2D
   ];

   private _horseLeft = "UserTexture10m_F" createVehicle [0,0,0];
   _horseLeft setObjectTextureGlobal [0,"images\horseyleft.paa"];
   _horseLeft attachTo [this, [-0.3, 0.75, -0.5] ];
   _y = 90; _p = 0; _r = 0;
   _horseLeft setVectorDirAndUp [
   [ sin _y * cos _p,cos _y * cos _p,sin _p],
   [ [ sin _r,-sin _p,cos _r * cos _p],-_y] call BIS_fnc_rotateVector2D
   ];

   private _horseRight  = "UserTexture10m_F" createVehicle [0,0,0];
   _horseRight setObjectTextureGlobal [0,"images\horseyright.paa"];
   _horseRight attachTo [this, [0.1, 0.75, -0.5] ];
   _y = -90; _p = 0; _r = 0;
   _horseRight setVectorDirAndUp [
   [ sin _y * cos _p,cos _y * cos _p,sin _p],
   [ [ sin _r,-sin _p,cos _r * cos _p],-_y] call BIS_fnc_rotateVector2D
];
};

this addAction
[
	"Take stagecoach to Carpe Aurum",
	{
		params ["_target", "_caller", "_actionId", "_arguments"];
      _caller setPos (getPos tpToHQ);
	},
	nil,
	1.5,
	true,
	true,
	"",
	"true",
	10
];
