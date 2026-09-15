local addon = TitanCritLine;
local TCL_REALM = addon:GetRealmKey();
local TCL_SOURCETYPE = addon.SOURCE_TYPES;
local DAMAGE_TYPE_HEAL = addon.DAMAGE_TYPE_HEAL;

-- Records are keyed by spell id (a number) since the spell-id rework, by the
-- literal NORMAL_HIT_TEXT constant for melee normal hits (no spell exists),
-- or - for pet records - "<pet name>'s <id or NORMAL_HIT_TEXT>". Only the
-- numeric case needs resolving back to a display name; the other two are
-- already human-readable. Spells the client hasn't seen this session (e.g.
-- an old boss ability) fall back to "Spell <id>" rather than erroring.
local GetSpellInfoCompat = C_Spell and C_Spell.GetSpellInfo;
function tcl_ResolveAttackTypeName(key)
	if (type(key) == "number") then
		local name;
		if (GetSpellInfoCompat) then
			local info = GetSpellInfoCompat(key);
			name = info and info.name;
		else
			name = GetSpellInfo(key);
		end
		return name or ("Spell "..key);
	end
	if (type(key) == "string") then
		local petName, id = string.match(key, "^(.-)'s (%d+)$");
		if (petName and id) then
			return petName.."'s "..tcl_ResolveAttackTypeName(tonumber(id));
		end
	end
	return key;
end
addon.ResolveAttackTypeName = tcl_ResolveAttackTypeName;

-- Inverse lookup, used only by the one-time spell-id migration (see
-- TitanCritLine.lua's tcl_MigrateAttackTypeKeysToSpellId): resolves a spell
-- name to its id via the client's own spell cache. Returns nil if the name
-- isn't (yet) known to the client - e.g. an old boss ability not cast since
-- login - the migration leaves such records under their old name key rather
-- than guessing.
function tcl_ResolveSpellIdByName(name)
	if (GetSpellInfoCompat) then
		local info = GetSpellInfoCompat(name);
		return info and info.spellID;
	end
	local _, _, _, _, _, _, spellId = GetSpellInfo(name);
	return spellId;
end
addon.ResolveSpellIdByName = tcl_ResolveSpellIdByName;

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

function tcl_RecordMiss(AttackType, sourceType)
	local source = sourceType or TCL_SOURCETYPE[1];
	if (AttackType == nil) then
		return;
	end
	local attacks = TCL_SETTINGS[TCL_REALM]["DATA"][source];
	attacks[AttackType] = attacks[AttackType] or {};
	attacks[AttackType]["Misses"] = (attacks[AttackType]["Misses"] or 0) + 1;
end

function tcl_DisplayNewRecord(AttackType, DamageAmount, HitType, IsHealing)
	local splashMessage = TITAN_CRITLINE_NEW_RECORD_MSG;
	if (HitType == "CRIT") then
		splashMessage = TITAN_CRITLINE_NEW_CRIT_RECORD_MSG;
	elseif (HitType == "DOT") then
		splashMessage = IsHealing == DAMAGE_TYPE_HEAL and addon.NEW_HOT_RECORD_MSG or TITAN_CRITLINE_NEW_DOT_RECORD_MSG;
	end
	local attackName = tcl_ResolveAttackTypeName(AttackType);
	tcl_DEBUG(format(splashMessage, attackName));
	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] == "1") then
		TitanCritLineSplashFrame:AddMessage(DamageAmount, 1, 1, 1, 1, 3);
		TitanCritLineSplashFrame:AddMessage(format(splashMessage, attackName), 1, 1, 0, 1, 3);
	end
	TitanPanelButton_UpdateButton(addon.ID);
	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] == "1") then
		PlaySound(addon.RECORD_SOUND);
	end
	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] == "1") then
		TakeScreenshot();
	end
end
