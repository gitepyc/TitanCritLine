local addon = TitanCritLine;

local function getLegacyMobId(mobname)
	local legacyMobs = {
		[TITAN_CRITLINE_MOBFILTER_01] = 14020,
		[TITAN_CRITLINE_MOBFILTER_02] = 12461,
		[TITAN_CRITLINE_MOBFILTER_03] = 12460,
		[TITAN_CRITLINE_MOBFILTER_04] = 15339,
		[TITAN_CRITLINE_MOBFILTER_05] = 13020,
	};
	return legacyMobs[mobname];
end

function tcl_GetNpcId(unitGUID)
	if (type(unitGUID) ~= "string") then
		return nil;
	end
	local unitType, _, _, _, _, npcId = strsplit("-", unitGUID);
	if (unitType ~= "Creature" and unitType ~= "Vehicle") then
		return nil;
	end
	return tonumber(npcId);
end

function tcl_IsMobInFilter(npcId)
	return npcId ~= nil and addon.SPECIAL_MOB_IDS[tonumber(npcId)] == true;
end

function tcl_DeleteAllRecordsWithMobsInFilter()
	tcl_DEBUG("Search for filtered mobs and delete them ...");
	local realm = addon:GetRealmKey();
	for i = 1, #(addon.SOURCE_TYPES) do
		local sourceData = TCL_SETTINGS[realm]["DATA"][addon.SOURCE_TYPES[i]];
		for attackType, attackData in pairs(sourceData) do
			for j = 1, #(addon.HIT_TYPES) do
				local hitType = addon.HIT_TYPES[j];
				local record = attackData[hitType];
				local targetNpcId = record and (record["TargetNpcID"] or getLegacyMobId(record["Target"]));
				if (record ~= nil and tcl_IsMobInFilter(targetNpcId)) then
					record["TargetNpcID"] = targetNpcId;
					tcl_DEBUG("Filtered mob found for "..attackType..", backing up stats ...");
					local filtered = "FILTER_"..hitType;
					local backup = "OLD_"..hitType;
					attackData[filtered] = record;
					attackData[hitType] = attackData[backup];
					attackData[backup] = nil;
				end
			end
		end
	end
	tcl_DEBUG("All filtered mobs deleted if found.");
	TitanPanelButton_UpdateButton(addon.ID);
end

function tcl_RestoreAllRecordsWithMobsInFilter()
	tcl_DEBUG("Restore all records with filtered mobs ...");
	local realm = addon:GetRealmKey();
	for i = 1, #(addon.SOURCE_TYPES) do
		local sourceData = TCL_SETTINGS[realm]["DATA"][addon.SOURCE_TYPES[i]];
		for attackType, attackData in pairs(sourceData) do
			for j = 1, #(addon.HIT_TYPES) do
				local hitType = addon.HIT_TYPES[j];
				local filtered = "FILTER_"..hitType;
				local backup = "OLD_"..hitType;
				if (attackData[filtered] ~= nil) then
					tcl_DEBUG("Restoring filtered mob stats for "..attackType.." ...");
					attackData[backup] = attackData[hitType];
					attackData[hitType] = attackData[filtered];
					attackData[filtered] = nil;
				end
			end
		end
	end
	tcl_DEBUG("All records with filtered mobs are restored.");
	TitanPanelButton_UpdateButton(addon.ID);
end
