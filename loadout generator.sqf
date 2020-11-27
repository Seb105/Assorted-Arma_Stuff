private _loadoutArrayExample = {
[
   [
      "description",
      "uniform",
      "vest",
      "backpack",
      "headgear",
      "primary weapon",
      "secondary weapon",
      "launcher",
      ["primary weapon accessories array"],
      ["secondary weapon accessories array"],
      ["launcher accessories array"],
      ["items array (map, gps etc)"],
      [
         [0,"uniformItems"]
      ],
      [
         [0,"vestItems"]
      ],
      [
         [0,"backPackItems"]
      ],
      [
         [0,"anywhereItems"]
      ]
   ]
];
};

private _fnc_addItem = {
params ["_unit","_item",["_amount",1],["_where","any"]];

   switch (_where) do {
      case "uniform": {
         for "_i" from 1 to _amount do {
            _unit addItemToUniform _item;
         };
      };
      case "vest": {
         for "_i" from 1 to _amount do {
            _unit addItemToVest _item;
         };
      };
      case "backpack": {
         for "_i" from 1 to _amount do {
            _unit addItemtoBackpack _item;
         };
      };
      default {
         for "_i" from 1 to _amount do {
            _unit addItem _item;
         };
      };
   };
};

{
   private _unit = _x;
   // get unit description and empty their inventory
   private _unitDescription = _unit get3DENAttribute "description" select 0;
   _unit setUnitLoadout [[],[],[],[],[],[],"","",[],["","","","","",""]];
   {
      private _newLoadout = _x;
      _newLoadout params ["_targetDescription","_uniform","_vest","_backpack","_headgear","_primaryWeapon","_handgunWeapon","_launcher","_primaryAccessories","_handgunAccessories","_launcherAccessories","_equipment","_uniformArray","_vestArray","_backpackArray","_anywhereArray"];

      if (_targetDescription in _unitDescription) then {

         // add uniform items

         _unit addVest _vest;
         _unit forceAddUniform _uniform;
         _unit addBackpack _backpack;
         _unit addHeadGear _headgear;

         // add equipment

         {
            _unit linkItem _x;
         } forEach _equipment;

         // add weapons and weapon items (including magazines)

         _unit addWeapon _primaryWeapon;
         _unit addWeapon _handgunWeapon;
         _unit addWeapon _launcher;
         {
            _unit addPrimaryWeaponItem _x;
         } forEach _primaryAccessories;
         {
            _unit addHandGunItem _x;
         } forEach _handgunAccessories;
         {
            _unit addSecondaryWeaponItem _x;
         } forEach _launcherAccessories;

         // all the rest of the items

         {
            _x params ["_amount","_item"];
            [_unit,_item,_amount,"vest"] call _fnc_addItem;
         } forEach _vestArray;
         {
            _x params ["_amount","_item"];
            [_unit,_item,_amount,"uniform"] call _fnc_addItem;
         } forEach _uniformArray;
         {
            _x params ["_amount","_item"];
            [_unit,_item,_amount,"backpack"] call _fnc_addItem;
         } forEach _backpackArray;
         {
            _x params ["_amount","_item"];
            [_unit,_item,_amount,"any"] call _fnc_addItem;
         } forEach _anywhereArray;

      };
   } forEach _unitLoadoutArray;
} forEach playableUnits;
save3DENInventory playableUnits;
