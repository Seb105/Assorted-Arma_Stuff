if ("Seb" == (name player)) then 
{
	player addAction [
	"Gcam2",	
		{
		params ["_target", "_caller", "_actionId", "_arguments"];
		execVM "gcam\gcam.sqf";
		},
	nil,		
	1.5,		
	true,		
	true,		
	"",			
	"_originalTarget == _this", 
	5,			
	false,		
	"",		
	""	
	];
};