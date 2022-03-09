params ["_speakers", "_lights"];
#define BASE_INTENSITY 5000
#define LIGHTS_HZ 30
#define NUM_SAMPLES (SEGMENT_LENGTH*LIGHTS_HZ)-1
#define SEGMENT_LENGTH 5
// seconds
private _slice = 0;
seb_fnc_playSlice = {
    params ["_slice", "_lightintensities", "_speakers", "_lights"];
    private _soundClass = "seb_song_" + str _slice;
    if (player inArea _speakers) then {
        playSound _soundClass;
    } else {
        _speakers say3D [_soundClass, 2000];
    };
    private _lightintensity = _lightintensities#_slice;
    for "_i" from 0 to (count _lightintensity) do {
        [{
            params ["_lightintensities", "_lights", "_index"];
            _lightintensities params ["_bassArr", "_midArr", "_trebleArr"];
            private _bass = _bassArr#_index;
            private _mid = _midArr#_index;
            private _treble = _trebleArr#_index;
            _lights params ["_redLights", "_greenLights", "_blueLights"];
            {
                _x setLightFlareSize _bass;
                _x setLightIntensity _bass*BASE_INTENSITY
            } forEach _redLights;
            {
                _x setLightFlareSize _mid;
                _x setLightIntensity _mid*BASE_INTENSITY
            } forEach _greenLights;
            {
                _x setLightFlareSize _treble;
                _x setLightIntensity _treble*BASE_INTENSITY
            } forEach _blueLights;
        }, [_lightintensity, _lights, _i], _i/LIGHTS_HZ] call CBA_fnc_waitAndExecute;
    };
    [
        {
            _this call seb_fnc_playSlice;
        },
        [_slice+1, _lightintensities, _speakers, _lights],
        SEGMENT_LENGTH
    ] call CBA_fnc_waitAndExecute;
};

private _lightintensities = ["REPLACE ME"];
[_slice, _lightintensities, _speakers, _lights] call seb_fnc_playSlice;
