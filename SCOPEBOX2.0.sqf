private _addScopes = {
   private _allWeaponOptics = [primaryWeapon player,"optic"] call CBA_fnc_compatibleItems;
   private _allWeaponEligibleOptics = _allWeaponOptics select {
      private _optic = _x;
      private _opticCfg = (configfile >> "CfgWeapons" >> _optic >> "ItemInfo" >> "OpticsModes");
      private _opticVisionModes = [_opticCfg,2] call BIS_fnc_returnChildren;
      private _opticVisionModeUseModelOptics = _opticVisionModes apply {getNumber (_x >> "useModelOptics")};
      private _opticUseModelOpticsFindNonZero = _opticVisionModeUseModelOptics findIf {_x != 0};
      private _cfgScope = getNumber (configfile >> "CfgWeapons" >> _optic >> "scope");
      private _opticExtremes = [_opticVisionModes,["opticsZoomMin"]] call BIS_fnc_configExtremes;
      private _opticMaxZoom = (_opticExtremes select 0) select 0;

      _opticMaxZoom >=0.25 && _cfgScope == 2 && _opticUseModelOpticsFindNonZero == -1;
   };
   _allWeaponEligibleOptics sort true;
   {
       _x params ["_classname"];
       _text = format ["<t color='#33cc33'>%1</t>",getText (configfile >> "CfgWeapons" >> _className >> "displayName")];
       _this addAction [
           _text,
           compile format ['player addPrimaryWeaponItem "%1"', _classname],
           nil, 0.1, true, true, "", "(_target distance _this) < 3"
       ];
   } forEach _allWeaponEligibleOptics;
};
this call _addScopes;
this addAction
   [
      "<t color='#0000cc'>REFRESH SCOPEBOX</t>",
      {
         params ["_target", "_caller", "_actionId", "_arguments"];
         _arguments params ["_addScopes"];
         {
            _target removeAction _x
         } forEach ((actionIDs _target) - [_actionId]);
         _target call _addScopes;
      },
      _addScopes, -1, false, true, "", "(_target distance _this) < 3"
   ];
