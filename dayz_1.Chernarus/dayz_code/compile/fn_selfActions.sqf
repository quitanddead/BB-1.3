scriptName "Functions\misc\fn_selfActions.sqf";
/***********************************************************
	ADD ACTIONS FOR SELF
	- Function
	- [] call fnc_usec_selfActions;
************************************************************/
_vehicle = vehicle player;
_inVehicle = (_vehicle != player);
_cursorTarget = cursorTarget;
_primaryWeapon = primaryWeapon player;
_currentWeapon = currentWeapon player;
_onLadder = (getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;

_nearLight = nearestObject [player,"LitObject"];
_canPickLight = false;
if (!isNull _nearLight) then {
	if (_nearLight distance player < 4) then {
		_canPickLight = isNull (_nearLight getVariable ["owner",objNull]);
	};
};
_canDo = (!r_drag_sqf and !r_player_unconscious and !_onLadder);

//####----####----####---- Base Building 1.3 Start ----####----####----####
	_currentSkin = typeOf(player);
	_hasToolbox = "ItemToolbox" in items player;
	_baseBuildAdmin = ((getPlayerUID player) in BBSuperAdminAccess);
	//Get objects that can't be targetted
	_flagBasePole = nearestObject [player, BBTypeOfFlag];
		//All untargetable objects (except Base Flag), searches a 10 meter radius, you can add any new objects you put in the build list that can't be targetted
		_untargetableArray = nearestObjects [player, ["Land_CamoNetB_EAST","Land_CamoNetVar_EAST","Land_CamoNet_EAST","Land_CamoNetB_NATO","Land_CamoNetVar_NATO","Land_CamoNet_NATO","Land_Ind_IlluminantTower","Land_sara_hasic_zbroj","Land_A_Castle_Bergfrit"],10];
		_nearUntargetable = count _untargetableArray > 0; //Check if anything is in range
		_closestUntargetable = if (_nearUntargetable) then {_untargetableArray select 0};//Selects the closest returned item
		_nettingNames = ["Land_CamoNetB_EAST","Land_CamoNetVar_EAST","Land_CamoNet_EAST","Land_CamoNetB_NATO","Land_CamoNetVar_NATO","Land_CamoNet_NATO"]; //Used for menu options
		_castleNames = ["Land_A_Castle_Bergfrit"];
		_buildingNames = [];//Can add generic building names here
		_displayName = "Base Build Object";//Default menu option name if none of the following match
		if (typeOf(_closestUntargetable) in _nettingNames) then {_displayName = "Netting";};
		if (typeOf(_closestUntargetable) in _castleNames) then {_displayName = "Castle";};
		if (typeOf(_closestUntargetable) in _buildingNames) then {_displayName = "Building";};
		if (typeOf(_closestUntargetable) == "Land_Ind_IlluminantTower") then {_displayName = "Tower";};


	// Check mags in player inventory to show build recipe menu	
	_mags = magazines player;
	if ("ItemTankTrap" in _mags || "ItemSandbag" in _mags || "ItemWire" in _mags || "PartWoodPile" in _mags || "PartGeneric" in _mags || "equip_scrapelectronics" in _mags || "ItemCamoNet" in _mags || "equip_crate" in _mags || "equip_brick" in _mags || "equip_string" in _mags || "equip_duct_tape" in _mags) then {
		hasBuildItem = true;
	} else { hasBuildItem = false;};
	//Build Recipe Menu Action
	if((speed player <= 1) && hasBuildItem && _canDo) then {
		if (s_player_recipeMenu < 0) then {
			s_player_recipeMenu = player addaction [("<t color=""#0074E8"">" + ("Build Recipes") +"</t>"),"buildRecipeBook\build_recipe_dialog.sqf","",5,false,true,"",""];
		};
		if (s_player_buildHelp < 0) then {
			s_player_buildHelp = player addaction [("<t color=""#FF9500"">" + ("Base Building Help") +"</t>"),"dayz_code\actions\build_help.sqf","",5,false,true,"",""];
		};
		if (s_player_showFlags < 0) then {
			s_player_showFlags = player addAction [("<t color=""#FF9500"">" + ("Show My Flags") +"</t>"),"dayz_code\actions\show_flag_markers.sqf","",5,false,true,"",""];
		};
	} else {
		player removeAction s_player_buildHelp;
		s_player_buildHelp = -1;
		player removeAction s_player_recipeMenu;
		s_player_recipeMenu = -1;
		player removeAction s_player_showFlags;
		s_player_showFlags = -1;
	};
	
	//Add in custom eventhandlers or whatever on skin change
	if (_currentSkin != globalSkin) then {
		globalSkin = _currentSkin;
		player removeMPEventHandler ["MPHit", 0]; 
		player removeEventHandler ["AnimChanged", 0];
		ehWall = player addEventHandler ["AnimChanged", { player call antiWall; }];
		empHit = player addMPEventHandler ["MPHit", {_this spawn fnc_plyrHit;}];
	};

	//General Untargetable Objects
	if((isNull cursorTarget) && _canDo && !remProc && !procBuild && _nearUntargetable) then {
	_ownerUnT = _closestUntargetable getVariable ["characterID", "0"]; //Checks owner IDs of untargetable objects, simply to avoid RPT spam with map objects
	_unTauthUID = _closestUntargetable getVariable ["AuthorizedUID", []]; //Gets master AuthUID from untargetable objects
	_unTauthGateCodes = if (_ownerUnT != "0") then {((getPlayerUID player) in (_unTauthUID select 1));}; //Checks for player access to untargetable objects
	_adminText = if (!_unTauthGateCodes && _baseBuildAdmin) then {"ADMIN:";}else{"";};//Let admins know they aren't registered
		if (_unTauthGateCodes || _baseBuildAdmin) then {
			if (s_player_camoBaseOwnerAccess < 0) then {
				s_player_camoBaseOwnerAccess = player addAction [format["%2%1: Give all base owners (from flagpole) access",_displayName,_adminText], "dayz_code\external\keypad\fnc_keyPad\functions\give_gateAccess.sqf",_closestUntargetable, 1, false, true, "", ""];
			};
			if (s_player_addCamoAuth < 0) then {
				s_player_addCamoAuth = player addAction [format["%2%1: Add Player UIDs",_displayName,_adminText], "dayz_code\external\keypad\fnc_keyPad\enterCodeAdd.sqf",_closestUntargetable, 1, false, true, "", ""];
			};
			if (s_player_removeCamoAuth < 0) then {
				s_player_removeCamoAuth = player addAction [format[("<t color=""#F01313"">" + ("%2%1: Remove Player UIDs") +"</t>"),_displayName,_adminText], "dayz_code\external\keypad\fnc_keyPad\enterCodeRemove.sqf",_closestUntargetable, 1, false, true, "", ""];
			};
		};
		if (_hasToolbox || _baseBuildAdmin) then {
			if (s_player_deleteCamoNet < 0) then {
				s_player_deleteCamoNet = player addaction [format[("<t color=""#F01313"">" + ("Remove %1") +"</t>"),_displayName,_adminText],"dayz_code\actions\player_remove.sqf",_closestUntargetable,1,false,true,"",""];
			};
		};
	} else {
		player removeAction s_player_camoBaseOwnerAccess;
		s_player_camoBaseOwnerAccess = -1;
		player removeAction s_player_addCamoAuth;
		s_player_addCamoAuth = -1;
		player removeAction s_player_removeCamoAuth;
		s_player_removeCamoAuth = -1;
		player removeAction s_player_deleteCamoNet;
		s_player_deleteCamoNet = -1;
	};	

	// FlagPole Access (more reliable than cursortarget)
	if ((isNull cursorTarget) && _canDo && !remProc && !procBuild && (_flagBasePole distance player < 10)) then {
	_ownerFlag = _flagBasePole getVariable ["characterID", "0"]; //Checks owner IDs of flags, simply to avoid RPT spam with map objects
	_flagAuthUID = _flagBasePole getVariable ["AuthorizedUID", []]; //Gets master AuthUID from 
	_flagAuthGateCodes = if (_ownerFlag != "0") then {((getPlayerUID player) in (_flagAuthUID select 1));}; //Checks if player has access to flag
	_adminText = if (!_flagAuthGateCodes && _baseBuildAdmin) then {"ADMIN:";}else{"";};//Let admins know they aren't registered
		if (_flagAuthGateCodes || _baseBuildAdmin) then {
			if (s_player_addFlagAuth < 0) then {
				s_player_addFlagAuth = player addAction [format["%1FlagPole: Add Player UIDs for Base Building Access",_adminText], "dayz_code\external\keypad\fnc_keyPad\enterCodeAdd.sqf", _flagBasePole, 1, false, true, "", ""];
			};
			if (s_player_removeFlagAuth < 0) then {
				s_player_removeFlagAuth = player addaction [format[("<t color=""#F01313"">" + ("%1FlagPole: Remove Player UIDs") +"</t>"),_adminText],"dayz_code\external\keypad\fnc_keyPad\enterCodeRemove.sqf", _flagBasePole, 1, false, true, "", ""];
			};
			if (s_player_removeFlag < 0) then {
				s_player_removeFlag = player addaction [format[("<t color=""#F01313"">" + ("%1Permanently Remove Flag (restrictions apply)") +"</t>"),_adminText],"dayz_code\actions\player_remove.sqf", _flagBasePole,1,false,true,"",""];
			};
			if (bbAIGuards == 1) then {
				if (s_player_guardToggle < 0) then {
					s_player_guardToggle = player addaction [format[("<t color=""#FFFFFF"">" + ("%1Toggle Guards to Kill all non-base owners (default on)") +"</t>"),_adminText],"dayz_code\actions\toggle_base_guards.sqf",_flagBasePole,1,false,true,"",""];
				};
			};
		};
	} else {
		player removeAction s_player_removeFlag;
		s_player_removeFlag = -1;
		player removeAction s_player_addFlagAuth;
		s_player_addFlagAuth = -1;
		player removeAction s_player_removeFlagAuth;
		s_player_removeFlagAuth = -1;
		player removeAction s_player_guardToggle;
		s_player_guardToggle = -1;
	};
//####----####----####---- Base Building 1.3 END ----####----####----####

//Grab Flare
if (_canPickLight and !dayz_hasLight) then {
	if (s_player_grabflare < 0) then {
		_text = getText (configFile >> "CfgAmmo" >> (typeOf _nearLight) >> "displayName");
		s_player_grabflare = player addAction [format[localize "str_actions_medical_15",_text], "\z\addons\dayz_code\actions\flare_pickup.sqf",_nearLight, 1, false, true, "", ""];
		s_player_removeflare = player addAction [format[localize "str_actions_medical_17",_text], "\z\addons\dayz_code\actions\flare_remove.sqf",_nearLight, 1, false, true, "", ""];
	};
} else {
	player removeAction s_player_grabflare;
	player removeAction s_player_removeflare;
	s_player_grabflare = -1;
	s_player_removeflare = -1;
};

if (dayz_onBack != "" && !dayz_onBackActive && !_inVehicle && !_onLadder && !r_player_unconscious) then {
	if (s_player_equip_carry < 0) then {
		_text = getText (configFile >> "CfgWeapons" >> dayz_onBack >> "displayName");
		s_player_equip_carry = player addAction [format[localize "STR_ACTIONS_WEAPON", _text], "\z\addons\dayz_code\actions\player_switchWeapon.sqf", "action", 0.5, false, true];
	};
} else {
	player removeAction s_player_equip_carry;
	s_player_equip_carry = -1;
};

//fishing
if ((_currentWeapon in Dayz_fishingItems) && !dayz_fishingInprogress && !_inVehicle && !dayz_isSwimming) then {
	if (s_player_fishing < 0) then {
		s_player_fishing = player addAction [localize "STR_ACTION_CAST", "\z\addons\dayz_code\actions\player_goFishing.sqf",player, 0.5, false, true];
	};
} else {
	player removeAction s_player_fishing;
	s_player_fishing = -1;
};
if ((_primaryWeapon in Dayz_fishingItems) && !dayz_fishingInprogress && (_inVehicle and (driver _vehicle != player))) then {
		if (s_player_fishing_veh < 0) then {
			s_player_fishing_veh = _vehicle addAction [localize "STR_ACTION_CAST", "\z\addons\dayz_code\actions\player_goFishing.sqf",_vehicle, 0.5, false, true];
		};
} else {
	_vehicle removeAction s_player_fishing_veh;
	s_player_fishing_veh = -1;
};	

if (!isNull _cursorTarget and !_inVehicle and (player distance _cursorTarget < 4)) then { //Has some kind of target
	
	_isVehicle = _cursorTarget isKindOf "AllVehicles";
	_isMan = _cursorTarget isKindOf "Man";
	_isAnimal = _cursorTarget isKindOf "Animal";
	_isZombie = _cursorTarget isKindOf "zZombie_base";
	_isDestructable = _cursorTarget isKindOf "BuiltItems";
	_isTent = _cursorTarget isKindOf "TentStorage";
	_isStash = _cursorTarget isKindOf "StashSmall";
	_isMediumStash = _cursorTarget isKindOf "StashMedium";
	_isHarvested = _cursorTarget getVariable["meatHarvested",false];
	_ownerID = _cursorTarget getVariable ["characterID","0"];
	_isVehicletype = typeOf _cursorTarget in ["ATV_US_EP1","ATV_CZ_EP1"];
	_isFuel = false;
	_hasFuel20 = "ItemJerrycan" in magazines player;
	_hasFuel5 = "ItemFuelcan" in magazines player;
	_hasFuelE20 = "ItemJerrycanEmpty" in magazines player;
	_hasFuelE5 = "ItemFuelcanEmpty" in magazines player;
	_hasKnife = "ItemKnife" in items player;
	_hasToolbox = "ItemToolbox" in items player;
	_hasbottleitem = "ItemWaterbottle" in magazines player;
	_isAlive = alive _cursorTarget;
	_canmove = canmove _cursorTarget;
	_text = getText (configFile >> "CfgVehicles" >> typeOf _cursorTarget >> "displayName");
	_isPlant = typeOf _cursorTarget in Dayz_plants;
	if (_hasFuelE20 or _hasFuelE5) then {
		_isFuel = (_cursorTarget isKindOf "Land_Ind_TankSmall") or (_cursorTarget isKindOf "Land_fuel_tank_big") or (_cursorTarget isKindOf "Land_fuel_tank_stairs") or (_cursorTarget isKindOf "Land_wagon_tanker");
	};
	
//####----####----####---- Base Building 1.3 Start ----####----####----####
	_lever = cursorTarget;
	_codePanels = ["Infostand_2_EP1", "Fence_corrugated_plate"];
	_baseBuildAdmin = ((getPlayerUID player) in BBSuperAdminAccess);
	_authorizedUID = cursorTarget getVariable ["AuthorizedUID", []];
	_authorizedGateCodes = if (_ownerID != "0") then {((getPlayerUID player) in (_authorizedUID select 1));}; //Check it's not a map object/unbuilt object to avoid RPT spam
	_adminText = if (!_authorizedGateCodes && _baseBuildAdmin) then {"ADMIN:";}else{"";};//Let admins know they aren't registered
	
	//Let players check the UID of other players when near their flags
	if (_isMan && (_flagBasePole distance player < 10)) then {
	_ownerFlag = _flagBasePole getVariable ["characterID", "0"]; //Checks owner IDs of flags, simply to avoid RPT spam with map objects
	_flagAuthUID = _flagBasePole getVariable ["AuthorizedUID", []]; //Gets master AuthUID from 
	_flagAuthGateCodes = if (_ownerFlag != "0") then {((getPlayerUID player) in (_flagAuthUID select 1));}; //Checks if player has access to flag
	_adminText = if (!_flagAuthGateCodes && _baseBuildAdmin) then {"ADMIN:";}else{"";};//Let admins know they aren't registered
		if (_flagAuthGateCodes || _baseBuildAdmin) then {
			if (s_player_getTargetUID < 0) then {
				s_player_getTargetUID = player addAction [format["%1Get UID of Targeted Player",_adminText], "dayz_code\actions\get_player_UID.sqf", cursorTarget, 1, false, true, "", ""];
			};
		};
	} else {
		player removeAction s_player_getTargetUID;
		s_player_getTargetUID = -1;
	};
	
	// Operate Gates AND Add Authorization to Gate
	if (((typeOf(cursortarget) in _codePanels) && (_authorizedGateCodes || _baseBuildAdmin) && !remProc && !procBuild) || ((typeOf(cursortarget) in allbuildables_class) && (_authorizedGateCodes || _baseBuildAdmin) && !remProc && !procBuild)) then {
		_gates = nearestObjects [_lever, ["Concrete_Wall_EP1"], 15];
		if (s_player_gateActions < 0) then {
			if (typeOf(cursortarget) == "Fence_corrugated_plate") then {
					s_player_gateActions = player addAction [format["%1Operate Single Metal Gate",_adminText], "dayz_code\external\keypad\fnc_keyPad\operate_gates.sqf", _lever, 1, false, true, "", ""];
			} else {
				if (typeOf(cursortarget) == "Infostand_2_EP1") then {
					if (count _gates > 0) then {
						s_player_gateActions = player addAction [format["%1Operate Nearest Concrete Gates Within 15 meters",_adminText], "dayz_code\external\keypad\fnc_keyPad\operate_gates.sqf", _lever, 1, false, true, "", ""];
					} else {s_player_gateActions = player addAction [format["%1No gates around to operate",_adminText], "", _lever, 1, false, true, "", ""];};
				};
			};
		};
		if (s_player_giveBaseOwnerAccess < 0) then {
			s_player_giveBaseOwnerAccess = player addAction [format["%1Give all base owners (from flagpole) access to object/gate",_adminText], "dayz_code\external\keypad\fnc_keyPad\functions\give_gateAccess.sqf", _lever, 1, false, true, "", ""];
		};
		if (s_player_addGateAuthorization < 0) then {
			s_player_addGateAuthorization = player addAction [format["%1Add Player UIDs to Grant Gate/Object Access",_adminText], "dayz_code\external\keypad\fnc_keyPad\enterCodeAdd.sqf", _lever, 1, false, true, "", ""];
		};
		if (s_player_removeGateAuthorization < 0) then {
				s_player_removeGateAuthorization = player addaction [format[("<t color=""#F01313"">" + ("%1Remove Player UIDs from Gate/Object Access") +"</t>"),_adminText],"dayz_code\external\keypad\fnc_keyPad\enterCodeRemove.sqf", _lever, 1, false, true, "", ""];
		};
	} else {
		player removeAction s_player_giveBaseOwnerAccess;
		s_player_giveBaseOwnerAccess = -1;
		player removeAction s_player_gateActions;
		s_player_gateActions = -1;
		player removeAction s_player_addGateAuthorization;
		s_player_addGateAuthorization = -1;
		player removeAction s_player_removeGateAuthorization;
		s_player_removeGateAuthorization = -1;
	};
	// Operate ROOFS
	if ((typeOf(cursortarget) in _codePanels) && (_authorizedGateCodes || _baseBuildAdmin) && !remProc && !procBuild) then {
		_gates = nearestObjects [_lever, ["Land_Ind_Shed_01_main"], BBFlagRadius];
		if (s_player_roofToggle < 0) then {
			if (typeOf(cursortarget) == "Infostand_2_EP1") then {
				if (count _gates > 0) then {
					s_player_roofToggle = player addAction [format["%1Operate Roof Covers",_adminText], "dayz_code\external\keypad\fnc_keyPad\operate_roofs.sqf", _lever, 1, false, true, "", ""];
				} else {s_player_roofToggle = player addAction [format["%1No roof covers around to operate",_adminText], "", _lever, 1, false, true, "", ""];};
			};
		};
	} else {
		player removeAction s_player_roofToggle;
		s_player_roofToggle = -1;
	};

	// Remove Object
	if((typeOf(cursortarget) in allremovables) && (_hasToolbox || _baseBuildAdmin) && _canDo && !remProc && !procBuild && !removeObject) then {
		if (s_player_deleteBuild < 0) then {
			s_player_deleteBuild = player addAction [format[localize "str_actions_delete",_text], "dayz_code\actions\player_remove.sqf",cursorTarget, 1, false, true, "", ""];
		};
	} else {
		player removeAction s_player_deleteBuild;
		s_player_deleteBuild = -1;
	};

	//Barrel + Tower Lighting
    if((typeOf(cursortarget) == "Infostand_2_EP1") && (_authorizedGateCodes || _baseBuildAdmin) && !remProc && !procBuild) then {
		_nearestFlags = nearestObjects [_lever, [BBTypeOfFlag], BBFlagRadius];
		_baseFlag = _nearestFlags select 0;
		_barrels = nearestObjects [_baseFlag, ["Land_Fire_Barrel"], BBFlagRadius];//Makes sure there are barrels in range of the flag
		_towers = nearestObjects [_baseFlag, ["Land_Ind_IlluminantTower"], BBFlagRadius];//Makes sure there are towers in range of the flag
		if (count _barrels > 0) then {
			if (s_player_inflameBarrels < 0) then {
				s_player_inflameBarrels = player addAction [format["%1Barrel Lights ON",_adminText], "dayz_code\actions\lights\barrelToggle.sqf", [_lever,true], 1, false, true, "", ""];
			};
			if (s_player_deflameBarrels < 0) then {
				s_player_deflameBarrels = player addAction [format["%1Barrel Lights OFF",_adminText], "dayz_code\actions\lights\barrelToggle.sqf", [_lever,false], 1, false, true, "", ""];
			};
		} else {
			if (s_player_inflameBarrels < 0) then {
				s_player_inflameBarrels = player addAction [format["%1No Barrel Lights In Range",_adminText], "", _lever, 1, false, true, "", ""];
			};
			player removeAction s_player_deflameBarrels;
			s_player_deflameBarrels = -1;
		};
		if (BBUseTowerLights == 1) then {
			if (count _towers > 0) then {
				if (s_player_towerLightsOn < 0) then {
					s_player_towerLightsOn = player addAction [format["%1Tower Lights ON",_adminText], "dayz_code\actions\lights\towerLightsToggle.sqf", [_lever,true], 1, false, true, "", ""];
				};
				if (s_player_towerLightsOff < 0) then {
					s_player_towerLightsOff = player addAction [format["%1Tower Lights OFF",_adminText], "dayz_code\actions\lights\towerLightsToggle.sqf", [_lever,false], 1, false, true, "", ""];
				};
			} else {
				if (s_player_towerLightsOn < 0) then {
					s_player_towerLightsOn = player addAction [format["%1No Tower Lights In Range",_adminText], "", _lever, 1, false, true, "", ""];
				};
				player removeAction s_player_towerLightsOff;
				s_player_towerLightsOff = -1;
			};
		};
	} else {
		player removeAction s_player_inflameBarrels;
		s_player_inflameBarrels = -1;
		player removeAction s_player_deflameBarrels;
		s_player_deflameBarrels = -1;
		player removeAction s_player_towerLightsOn;
		s_player_towerLightsOn = -1;
		player removeAction s_player_towerLightsOff;
		s_player_towerLightsOff = -1;
	};
//####----####----####---- Base Building 1.3 End ----####----####----####

	//gather
	if(_isPlant and _canDo) then {
		if (s_player_gather < 0) then {
			_text = getText (configFile >> "CfgVehicles" >> typeOf _cursorTarget >> "displayName");
			s_player_gather = player addAction [format[localize "str_actions_gather",_text], "\z\addons\dayz_code\actions\player_gather.sqf",_cursorTarget, 1, true, true, "", ""];
		};
	} else {
		player removeAction s_player_gather;
		s_player_gather = -1;
	};

	//Allow player to force save
	if((_isVehicle or _isTent or _isStash or _isMediumStash) and _canDo and !_isMan and (damage _cursorTarget < 1)) then {
		if (s_player_forceSave < 0) then {
			s_player_forceSave = player addAction [format[localize "str_actions_save",_text], "\z\addons\dayz_code\actions\forcesave.sqf",_cursorTarget, 1, true, true, "", ""];
		};
	} else {
		player removeAction s_player_forceSave;
		s_player_forceSave = -1;
	};

	//flip vehicle
	if ((_isVehicletype) and !_canmove and _isAlive and (player distance _cursorTarget >= 2) and (count (crew _cursorTarget))== 0 and ((vectorUp _cursorTarget) select 2) < 0.5) then {
		if (s_player_flipveh < 0) then {
			s_player_flipveh = player addAction [format[localize "str_actions_flipveh",_text], "\z\addons\dayz_code\actions\player_flipvehicle.sqf",_cursorTarget, 1, true, true, "", ""];
		};
	} else {
		player removeAction s_player_flipveh;
		s_player_flipveh = -1;
	};

	//Allow player to fill Fuel can
	if((_hasFuelE20 or _hasFuelE5) and _isFuel and !_isZombie and !_isAnimal and !_isMan and _canDo and !a_player_jerryfilling) then {
		if (s_player_fillfuel < 0) then {
			s_player_fillfuel = player addAction [localize "str_actions_self_10", "\z\addons\dayz_code\actions\jerry_fill.sqf",[], 1, false, true, "", ""];
		};
	} else {
		player removeAction s_player_fillfuel;
		s_player_fillfuel = -1;
	};

	//Allow player to fill vehicle 20L
	if(_hasFuel20 and _canDo and !_isZombie and !_isAnimal and !_isMan and _isVehicle and (fuel _cursorTarget < 1) and (damage _cursorTarget < 1)) then {
		if (s_player_fillfuel20 < 0) then {
			s_player_fillfuel20 = player addAction [format[localize "str_actions_medical_10",_text,"20"], "\z\addons\dayz_code\actions\refuel.sqf",["ItemJerrycan"], 0, true, true, "", "'ItemJerrycan' in magazines player"];
		};
	} else {
		player removeAction s_player_fillfuel20;
		s_player_fillfuel20 = -1;
	};

	//Allow player to fill vehicle 5L
	if(_hasFuel5 and _canDo and !_isZombie and !_isAnimal and !_isMan and _isVehicle and (fuel _cursorTarget < 1)) then {
		if (s_player_fillfuel5 < 0) then {
			s_player_fillfuel5 = player addAction [format[localize "str_actions_medical_10",_text,"5"], "\z\addons\dayz_code\actions\refuel.sqf",["ItemFuelcan"], 0, true, true, "", "'ItemFuelcan' in magazines player"];
		};
	} else {
		player removeAction s_player_fillfuel5;
		s_player_fillfuel5 = -1;
	};

	//Allow player to spihon vehicles
	if ((_hasFuelE20 or _hasFuelE5) and !_isZombie and !_isAnimal and !_isMan and _isVehicle and _canDo and !a_player_jerryfilling and (fuel _cursorTarget > 0) and (damage _cursorTarget < 1)) then {
		if (s_player_siphonfuel < 0) then {
			s_player_siphonfuel = player addAction [format[localize "str_siphon_start"], "\z\addons\dayz_code\actions\siphonFuel.sqf",_cursorTarget, 0, true, true, "", ""];
		};
	} else {
		player removeAction s_player_siphonfuel;
		s_player_siphonfuel = -1;
	};

	//Harvested
	if (!alive _cursorTarget and _isAnimal and _hasKnife and !_isHarvested and _canDo) then {
		if (s_player_butcher < 0) then {
			s_player_butcher = player addAction [localize "str_actions_self_04", "\z\addons\dayz_code\actions\gather_meat.sqf",_cursorTarget, 3, true, true, "", ""];
		};
	} else {
		player removeAction s_player_butcher;
		s_player_butcher = -1;
	};
//Fireplace Actions check
	if (inflamed _cursorTarget and _canDo) then {
	/*
		{
			if (_x in magazines player) then {
				_hastinitem = true;
			};
		} forEach boil_tin_cans;
		
		_rawmeat = meatraw;
		_hasRawMeat = false;
		{
			if (_x in magazines player) then {
				_hasRawMeat = true;
			};
		} forEach _rawmeat;
	*/
		_hasRawMeat = {_x in meatraw} count magazines player > 0;
		_hastinitem = {_x in boil_tin_cans} count magazines player > 0;
		
	//Cook Meat	
		if (_hasRawMeat and !a_player_cooking) then {
			if (s_player_cook < 0) then {
				s_player_cook = player addAction [localize "str_actions_self_05", "\z\addons\dayz_code\actions\cook.sqf",_cursorTarget, 3, true, true, "", ""];
			};
		}; 
	//Boil Water
		if (_hastinitem and _hasbottleitem and !a_player_boil) then {
			if (s_player_boil < 0) then {
				s_player_boil = player addAction [localize "str_actions_boilwater", "\z\addons\dayz_code\actions\boil.sqf",_cursorTarget, 3, true, true, "", ""];
			};
		};
	} else {
		if (a_player_cooking) then {
			player removeAction s_player_cook;
			s_player_cook = -1;
		};
		if (a_player_boil) then {
			player removeAction s_player_boil;
			s_player_boil = -1;
		};
	};

	if(_cursorTarget == dayz_hasFire and _canDo) then {
		if ((s_player_fireout < 0) and !(inflamed _cursorTarget) and (player distance _cursorTarget < 3)) then {
			s_player_fireout = player addAction [localize "str_actions_self_06", "\z\addons\dayz_code\actions\fire_pack.sqf",_cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_fireout;
		s_player_fireout = -1;
	};

	//Packing my tent
	if(_cursorTarget isKindOf "TentStorage" and _canDo and _ownerID == dayz_characterID) then {
		if ((s_player_packtent < 0) and (player distance _cursorTarget < 3)) then {
			s_player_packtent = player addAction [localize "str_actions_self_07", "\z\addons\dayz_code\actions\tent_pack.sqf",_cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_packtent;
		s_player_packtent = -1;
		};

	//Sleep
	if(_cursorTarget isKindOf "TentStorage" and _canDo and _ownerID == dayz_characterID) then {
		if ((s_player_sleep < 0) and (player distance _cursorTarget < 3)) then {
			s_player_sleep = player addAction [localize "str_actions_self_sleep", "\z\addons\dayz_code\actions\player_sleep.sqf",_cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_sleep;
		s_player_sleep = -1;
	};

	//Repairing Vehicles
	if ((dayz_myCursorTarget != _cursorTarget) and _isVehicle and !_isMan and _hasToolbox and (damage _cursorTarget < 1)) then {
		if (s_player_repair_crtl < 0) then {
			dayz_myCursorTarget = _cursorTarget;
			_menu = dayz_myCursorTarget addAction [localize "str_actions_rapairveh", "\z\addons\dayz_code\actions\repair_vehicle.sqf",_cursorTarget, 0, true, false, "",""];
			//_menu1 = dayz_myCursorTarget addAction [localize "str_actions_salvageveh", "\z\addons\dayz_code\actions\salvage_vehicle.sqf",_cursorTarget, 0, true, false, "",""];
			s_player_repairActions set [count s_player_repairActions,_menu];
			//s_player_repairActions set [count s_player_repairActions,_menu1];
			s_player_repair_crtl = 1;
		} else {
			{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
			s_player_repair_crtl = -1;
		};
	};

	if (_isMan and !_isAlive and !_isZombie and !_isAnimal) then {
		if (s_player_studybody < 0) then {
			s_player_studybody = player addAction [localize "str_action_studybody", "\z\addons\dayz_code\actions\study_body.sqf",_cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_studybody;
		s_player_studybody = -1;
	};
} else {
	//Engineering
	{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
	player removeAction s_player_repair_crtl;
	s_player_repair_crtl = -1;
	dayz_myCursorTarget = objNull;
//####----####----####---- Base Building 1.3 Start ----####----####----####
	player removeAction s_player_getTargetUID;
	s_player_getTargetUID = -1;
	player removeAction s_player_giveBaseOwnerAccess;
	s_player_giveBaseOwnerAccess = -1;
	player removeAction s_player_gateActions;
	s_player_gateActions = -1;
	player removeAction s_player_roofToggle;
	s_player_roofToggle = -1;
	player removeAction s_player_addGateAuthorization;
	s_player_addGateAuthorization = -1;
	player removeAction s_player_removeGateAuthorization;
	s_player_removeGateAuthorization = -1;
	player removeAction s_player_disarm;
	s_player_disarm = -1;
	player removeAction s_player_inflameBarrels;
	s_player_inflameBarrels = -1;
	player removeAction s_player_deflameBarrels;
	s_player_deflameBarrels = -1;
	player removeAction s_player_towerLightsOn;
	s_player_towerLightsOn = -1;
	player removeAction s_player_towerLightsOff;
	s_player_towerLightsOff = -1;
	player removeAction s_check_playerUIDs;
	s_check_playerUIDs = -1;
	player removeAction s_player_disarmBomb;
	s_player_disarmBomb = -1;
	player removeAction s_player_codeObject;
	s_player_codeObject = -1;
	player removeAction s_player_enterCode;
	s_player_enterCode = -1;
//####----####----####---- Base Building 1.3 End ----####----####----####
	//Others
	player removeAction s_player_forceSave;
	s_player_forceSave = -1;
	player removeAction s_player_flipveh;
	s_player_flipveh = -1;
	player removeAction s_player_sleep;
	s_player_sleep = -1;
	player removeAction s_player_deleteBuild;
	s_player_deleteBuild = -1;
	player removeAction s_player_butcher;
	s_player_butcher = -1;
	player removeAction s_player_cook;
	s_player_cook = -1;
	player removeAction s_player_boil;
	s_player_boil = -1;
	player removeAction s_player_fireout;
	s_player_fireout = -1;
	player removeAction s_player_packtent;
	s_player_packtent = -1;
	player removeAction s_player_fillfuel;
	s_player_fillfuel = -1;
	player removeAction s_player_studybody;
	s_player_studybody = -1;
	//fuel
	player removeAction s_player_fillfuel20;
	s_player_fillfuel20 = -1;
	player removeAction s_player_fillfuel5;
	s_player_fillfuel5 = -1;
	//Allow player to siphon vehicle fuel
	player removeAction s_player_siphonfuel;
	s_player_siphonfuel = -1;
	//Allow player to gather
	player removeAction s_player_gather;
	s_player_gather = -1;
};