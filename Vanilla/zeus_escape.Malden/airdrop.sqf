params ["_target", "_caller", "_actionId", "_arguments"];
missionNamespace setVariable ["AIRDROP_AVAILABLE", false, true]; 

private _centerPos = getPos _target;
private _startPos = [(_centerPos select 0)-3000,(_centerPos select 1),200];
private _endPos = [(_centerPos select 0)+3000,(_centerPos select 1),200];

private _grp = createGroup west;
private _aimRadius = 50;
private _wp0 = _grp addWaypoint [_centerPos, _aimRadius];
private _wp1 = _grp addWaypoint [_endPos, 300];

[_grp, 0] setWaypointType 'Move';

private _plane = createVehicle ["B_Plane_Fighter_01_F",_startPos,[],100,'FLY'];
private _dir = 90;
_plane setDir _dir;

private _speed = 150;
_plane setVelocity [(sin _dir * _speed),(cos _dir * _speed), 0];

private _pilot = _grp createUnit ["B_Pilot_F", _centerPos, [], 0, 'NONE'];
_pilot moveInDriver _plane;
_pilot setSkill 1;

waitUntil {(_plane distance2D _centerPos) < _aimRadius};
_grp setCurrentWaypoint [_grp, 1];

//crate 1 - weapons
private _crateWeapons = createVehicle ["B_supplyCrate_F",[(getPos _plane select 0)-10, (getPos _plane select 1), (getPos _plane select 2)-10],[], 0, "CAN_COLLIDE"];
_crateWeapons allowDamage false;
_crateWeapons setVelocity [((velocity _plane select 0)/20),((velocity _plane select 1)/20), -5];
_crateWeapons addAction ["Add Ammo for this Weapon","fn_refillWeapon.sqf", 4];
_crateWeapons addAction [
	"Destroy this crate", {
		(_this select 0) setDamage 1;
		sleep 5;
		deleteVehicle (_this select 0);
	}];

sleep 0.25;
//crate 2 - attachments
private _crateAtt = createVehicle ["C_IDAP_supplyCrate_F",[(getPos _plane select 0)-10, (getPos _plane select 1), (getPos _plane select 2)-10],[], 0, "CAN_COLLIDE"];
_crateAtt allowDamage false;
_crateAtt setVelocity [((velocity _plane select 0)/20),((velocity _plane select 1)/20), -5];
_crateAtt addAction [
	"Destroy this crate", {
		(_this select 0) setDamage 1;
		sleep 5;
		deleteVehicle (_this select 0);
	}];


//fill both crates
clearWeaponCargoGlobal _crateWeapons;
clearItemCargoGlobal _crateWeapons;
clearBackpackCargoGlobal _crateWeapons;
clearMagazineCargoGlobal _crateWeapons;

clearWeaponCargoGlobal _crateAtt;
clearItemCargoGlobal _crateAtt;
clearBackpackCargoGlobal _crateAtt;
clearMagazineCargoGlobal _crateAtt;
{
	_crateAtt addItemCargoGlobal [_x, 8];
} foreach attachmentClassnames;
{
	_crateWeapons addWeaponCargoGlobal [_x, 2];
} foreach weaponClassnames;
{
	_crateWeapons addItemCargoGlobal [_x, 8];
} forEach ammoClassnames;

sleep 20;
deleteVehicle _plane;
deleteVehicle _pilot;

sleep AIRDROP_TIME;
missionNamespace setVariable ["AIRDROP_AVAILABLE", true, true]; 