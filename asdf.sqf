[{
	private _veh = _args select 0;
	private _tex = surfaceTexture getpos _veh;
	_veh setObjectTextureGlobal [0,_tex];
 }, 0, [this]] call CBA_fnc_addPerFrameHandler;