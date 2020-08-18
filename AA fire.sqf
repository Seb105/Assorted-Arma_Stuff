if (isServer) then {
	[] spawn {
		AntiAircraftFire = true;
			while {AntiAircraftFire} do {		
				{ 
				_AntiAirCraftx = round(random 400) -200 + (getPosAsl _x select 0);
				_AntiAirCrafty = round(random 400) -200 + (getPosAsl _x select 1);
				_firetarget = [_AntiAirCraftx,_AntiAirCrafty,200];
				_x setVehicleAmmo 1;
				_x doSuppressiveFire _firetarget;
				uisleep 2;
				} forEach [Flaks_0, Flaks_1, Flaks_2, Flaks_3, Flaks_4, Flaks_5, Flaks_6, Flaks_7, Flaks_8, Flaks_9, Flaks_10, Flaks_11, Flaks_12, Flaks_13, Lights_0, Lights_1, Lights_2, Lights_3, Lights_4, Lights_5, Lights_6, Lights_7, Lights_8, Lights_9, Lights_10, Lights_11];
			};
	};
};

// From mission layer should work

if (isServer) then {
	[] spawn {
		AntiAircraftFire = true;
			while {AntiAircraftFire} do {		
				{ 
				_AntiAirCraftx = round(random 400) -200 + (getPosAsl _x select 0);
				_AntiAirCrafty = round(random 400) -200 + (getPosAsl _x select 1);
				_firetarget = [_AntiAirCraftx,_AntiAirCrafty,200];
				_x setVehicleAmmo 1;
				_x doSuppressiveFire _firetarget;
				} forEach ((getMissionLayerEntities "AmbientAA") select 0);
				uisleep 15;
			};
	};
};


// WORKS
if (isServer) then {
	[] spawn {
			AntiAircraftFire = true;
			while {AntiAircraftFire} do {		
				{ 
				hint "first";
				AntiAirCraftx = round(random 2500) + 500;
				AntiAirCrafty = round(random 2500) +2000;
				firetarget = [AntiAirCraftx,AntiAirCrafty,180];
				_x setVehicleAmmo 1;
				_x doSuppressiveFire firetarget;
				hint "slept";
				} forEach [Flaks_0, Flaks_1, Flaks_2, Flaks_3, Flaks_4, Flaks_5, Flaks_6, Flaks_7, Flaks_8, Flaks_9, Flaks_10, Flaks_11, Flaks_12, Flaks_13];
			uisleep 15;
			hint "slept";
			};
	};
};

