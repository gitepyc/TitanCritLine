local addon = TitanCritLine;
local TCL_REALM = addon:GetRealmKey();
local TCL_SOURCETYPE = addon.SOURCE_TYPES;
local DAMAGE_TYPE_HEAL = addon.DAMAGE_TYPE_HEAL;

function tcl_RecordHit(AttackType, HitType, Damage, uname, IsHealing, sourceType, targetGUID)
	local targetlvl = UnitLevel("target");
	local source = sourceType or TCL_SOURCETYPE[1];
	local ulevel = false;
	if (targetlvl == nil) then
		targetlvl = 0;
	end
	if (not addon:IsTrackingDamage()) then
		tcl_DEBUG("TCL Record Hit disabled!  exiting...");
		return;
	end
	if ((Damage == nil) or (Damage < 1)) then
		tcl_DEBUG("No Damage! exiting...");
		return;
	else
		tcl_DEBUG("Storing ["..AttackType.."/"..Damage.."]");
	end
	if (uname == nil) then
		uname = "??";
	end
	if (not UnitExists("target")) then
		if (IsHealing == DAMAGE_TYPE_HEAL) then
			uname = UnitName("player");
			ulevel = UnitLevel("player");
		else
			tcl_DEBUG("No Target! exiting...");
			return;
		end
	end
	if (IsHealing == nil) then
		tcl_DEBUG("IsHealing==nil! exiting...");
		return;
	end
	if ((UnitIsPlayer("target") ~= 1) and (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"] == "1")) then
		tcl_DEBUG("Target !=player and PvPOnly enabled, exiting...");
		return;
	end
	local leveldiff = 0;
	if (UnitLevel("player") < UnitLevel("target")) then
		leveldiff = UnitLevel("target") - UnitLevel("player");
	else
		leveldiff = UnitLevel("player") - UnitLevel("target");
	end
	tcl_DEBUG("Level difference: "..leveldiff);
	if ((tonumber(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"]) ~= 0) and (tonumber(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"]) < leveldiff)) then
		tcl_DEBUG("Target level too low and LvlAdj enabled, exiting...");
		return;
	end
	if (TCL_SETTINGS == nil) then
		return;
	end
	if (TCL_SETTINGS[TCL_REALM] == nil or TCL_SETTINGS[TCL_REALM]["DATA"] == nil or TCL_SETTINGS[TCL_REALM]["DATA"][source] == nil) then
		tcl_Initialize();
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType] == nil) then
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType] = {};
	end
	local attack = TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType];
	attack["Filter"] = attack["Filter"] or "0";
	attack[HitType] = attack[HitType] or {};
	attack[HitType]["Value"] = attack[HitType]["Value"] or 0;
	attack[HitType]["Value"] = attack[HitType]["Value"] + 1;
	local targetNpcId = tcl_GetNpcId(targetGUID or addon:GetCurrentTargetGUID());
	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] == "1" and tcl_IsMobInFilter(targetNpcId)) then
		return;
	end
	if (attack[HitType]["Damage"] == nil or attack[HitType]["Damage"] < Damage) then
		attack[HitType]["Damage"] = Damage;
		attack[HitType]["Target"] = uname;
		attack[HitType]["TargetNpcID"] = targetNpcId;
		attack[HitType]["Level"] = ulevel or UnitLevel("target");
		attack[HitType]["Date"] = date();
		attack[HitType]["IsHeal"] = IsHealing;
		tcl_DisplayNewRecord(AttackType, Damage, HitType, IsHealing);
	end
end

function tcl_RecordMiss(text, sourceType)
	local source = sourceType or TCL_SOURCETYPE[1];
	if (text == nil or string.find(text, "(%d+)")) then
		return;
	end
	for attackType in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][source]) do
		if (string.find(text, attackType)) then
			local attack = TCL_SETTINGS[TCL_REALM]["DATA"][source][attackType];
			attack["Misses"] = (attack["Misses"] or 0) + 1;
			return;
		end
	end
	local attacks = TCL_SETTINGS[TCL_REALM]["DATA"][source];
	attacks[NORMAL_HIT_TEXT] = attacks[NORMAL_HIT_TEXT] or {};
	attacks[NORMAL_HIT_TEXT]["Misses"] = (attacks[NORMAL_HIT_TEXT]["Misses"] or 0) + 1;
end

function tcl_DisplayNewRecord(AttackType, DamageAmount, HitType, IsHealing)
	local splashMessage = TITAN_CRITLINE_NEW_RECORD_MSG;
	if (HitType == "CRIT") then
		splashMessage = TITAN_CRITLINE_NEW_CRIT_RECORD_MSG;
	elseif (HitType == "DOT") then
		splashMessage = IsHealing == DAMAGE_TYPE_HEAL and addon.NEW_HOT_RECORD_MSG or TITAN_CRITLINE_NEW_DOT_RECORD_MSG;
	end
	tcl_DEBUG(format(splashMessage, AttackType));
	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] == "1") then
		TitanCritLineSplashFrame:AddMessage(DamageAmount, 1, 1, 1, 1, 3);
		TitanCritLineSplashFrame:AddMessage(format(splashMessage, AttackType), 1, 1, 0, 1, 3);
	end
	TitanPanelButton_UpdateButton(addon.ID);
	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] == "1") then
		PlaySound(addon.RECORD_SOUND);
	end
	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] == "1") then
		TakeScreenshot();
	end
end
