params ["_target", "_caller", "_actionId", "_arguments"];

private _vehicleClassname = _arguments select 0;
private _vehicleType = (_arguments select 0) call BIS_fnc_objectType;
private _centerMarker = _arguments select 1;
private _runwaySpawn = ["Plane"];
private _waterSpawn = ["Ship", "Submarine"];
private _dir = markerDir _centerMarker;
private _blacklisted = [];
{
	_blacklisted pushBack [(getMarkerPos _x), 10]; 
} forEach BLACKLISTED_MARKERS;

//create a default spawn position somewhere in the area
private _findSafePosArray = [
	getMarkerPos _centerMarker, //0, center
	getMarkerSize _centerMarker select 0, //1, min search radius
	100, //2, max search radius
	8, //3, min dist to other objects
	0, //4, cannot be in water
	MAX_GRADIENT, //5, max allowable ground slope
	0, //6, does not need to be on shore
	_blacklisted, //7, cannot be near select markers
	[getMarkerPos "plane_spawn", getMarkerPos "boat_spawn"] //8, default locations
];

//init the position to some value
private _pos = getMarkerPos "plane_spawn";

//if it is a plane, use the runway marker
if ((_vehicleType select 1) in _runwaySpawn) then
{
	//modify the safe position function's parameters to allow for plane spawning
	_findSafePosArray set [0, getMarkerPos "plane_spawn"];
	_findSafePosArray set [1, 0];
	_findSafePosArray set [2, 10];
	_findSafePosArray set [7, []];
	_dir = markerDir "plane_spawn";
};
//if it is a boat, use the water marker
if ((_vehicleType select 1) in _waterSpawn) then
{
	//modify the safe position function's parameters to allow for boat spawning
	_findSafePosArray set [0, getMarkerPos "boat_spawn"];
	_findSafePosArray set [1, 0];
	_findSafePosArray set [2, 10];
	_findSafePosArray set [4, 2];
	_findSafePosArray set [7, []];
	_dir = markerDir "boat_spawn";
};

_pos = _findSafePosArray call BIS_fnc_findSafePos;
private _veh = createVehicle [_vehicleClassname, _pos, [], 0, "NONE"];
_veh setDir _dir;
_veh setVectorUp surfaceNormal _pos;

//teleport the player to the driver seat
_caller moveInDriver _veh;