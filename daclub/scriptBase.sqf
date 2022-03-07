params ["_speakers", "_lights"];
#define BASE_INTENSITY 1000;
private _lightsHz = 15;
private _lightsStep = 1/_lightsHz;
private _segmentLength = 10;
// seconds
private _slice = 0;
seb_fnc_playSlice = {
    params ["_lightsHz", "_lightsStep", "_segmentLength", "_slice", "_lightintensities", "_speakers", "_lights", "_soundObj"];
    private _soundClass = "seb_song_" + str _slice;
    private _soundObj = _speakers say3D [_soundClass, 2000];
    private _lightintensity = _lightintensities#_slice;
    
    private _index = 0;
    for "_i" from 0 to _segmentLength step _lightsStep do {
        [{
            params ["_lightintensities", "_lights", "_index"];
            _lightintensities params ["_bassArr", "_midArr", "_trebleArr"];
            private _bass = _bassArr#_index;
            private _mid = _midArr#_index;
            private _treble = _trebleArr#_index;
            _lights params ["_redLights", "_greenLights", "_blueLights"];
            {
                _x setLightIntensity _bass*BASE_INTENSITY
            } forEach _redLights;
            {
                _x setLightIntensity _mid*BASE_INTENSITY
            } forEach _greenLights;
            {
                _x setLightIntensity _treble*BASE_INTENSITY
            } forEach _blueLights;
        }, [_lightintensity, _lights, _index], _i] call CBA_fnc_waitandexecute;
        _index = _index + 1;
    };
    [
        {
            params ["_lightsHz", "_lightsStep", "_segmentLength", "_slice", "_lightintensities", "_speakers", "_lights", "_soundObj"];
            isNull _soundObj
        },
        {
            _this call seb_fnc_playSlice;
        },
        [_lightsHz, _lightsStep, _segmentLength, _slice+1, _lightintensities, _speakers, _lights, _soundObj]
    ] call CBA_fnc_waitUntilandexecute;
};

private _lightintensities = ["REPLACE ME"];
[_lightsHz, _lightsStep, _segmentLength, _slice+1, _lightintensities, _speakers, _lights, objNull] call seb_fnc_playSlice;
