local addon = TitanCritLine;

local function getDefaultChannel()
	if (IsInRaid()) then
		return "RAID";
	end
	if (IsInGroup()) then
		return "PARTY";
	end
	return "GUILD";
end

function tcl_PostMessage(messages, channel)
	if (type(messages) ~= "table") then
		messages = tcl_GetRecordChatText();
	end
	channel = channel or getDefaultChannel();
	for _, message in ipairs(messages) do
		SendChatMessage(message, channel);
	end
end

-- Deliberately does not fall back to getDefaultChannel() when the specific
-- condition (in a raid / in a non-raid group) doesn't hold: that fallback is
-- itself context-sensitive and happens to resolve to "RAID" whenever you are
-- in a raid, which made "Post to Party" silently post to the raid channel
-- instead of party while in a raid (in-game reported), and symmetrically
-- made "Post to Raid" post to party/guild while not in a raid. Falls back to
-- a local-only echo instead, matching tcl_PostToGuild's existing behavior
-- when its own condition (being in a guild) doesn't hold.
function tcl_PostToRaid()
	if (IsInRaid()) then
		tcl_PostMessage(tcl_GetRecordChatText(), "RAID");
		return;
	end
	for _, message in ipairs(tcl_GetRecordChatText()) do
		tcl_Msg(message);
	end
end

function tcl_PostToParty()
	if (IsInGroup() and not IsInRaid()) then
		tcl_PostMessage(tcl_GetRecordChatText(), "PARTY");
		return;
	end
	for _, message in ipairs(tcl_GetRecordChatText()) do
		tcl_Msg(message);
	end
end

function tcl_PostToGuild()
	if (GetGuildInfo("player")) then
		tcl_PostMessage(tcl_GetRecordChatText(), "GUILD");
		return;
	end
	for _, message in ipairs(tcl_GetRecordChatText()) do
		tcl_Msg(message);
	end
end

function tcl_GetRecordChatText()
	local hicrit, acrit, ecrit = tcl_GetHighDMG("MY", "CRIT");
	local hidmg, anormal, enormal = tcl_GetHighDMG();
	local hihealcrit, hcrit, ehcrit = tcl_GetHighDMG("MY", "CRIT", "1");
	local hihealdmg, hnormal, ehnormal = tcl_GetHighDMG("MY", "NORMAL", "1");
	local hihealhot, hot, ehot = tcl_GetHighDMG("MY", "DOT", "1");
	local hidot, adot, edot = tcl_GetHighDMG("MY", "DOT");

	local text = {};
	table.insert(text, addon.ID.." "..RECORDS_TEXT..":");
	table.insert(text, CRIT_TEXT..": "..acrit.." ("..hicrit..")".." ["..ecrit.."]");
	table.insert(text, DOT_TEXT..": "..adot.." ("..hidot..")".." ["..edot.."]");
	table.insert(text, NORMAL_TEXT..": "..anormal.." ("..hidmg..")".." ["..enormal.."]");
	if (TCL_SETTINGS[addon:GetRealmKey()]["SETTINGS"]["FILTER_HEALING"] == "0") then
		if (hihealcrit > 0) then
			table.insert(text, CRIT_TEXT..": "..hcrit.." ("..hihealcrit..")".." ["..ehcrit.."]");
		end
		if (hihealhot > 0) then
			table.insert(text, "HOT: "..hot.." ("..hihealhot..")".." ["..ehot.."]");
		end
		if (hihealdmg > 0) then
			table.insert(text, NORMAL_TEXT..": "..hnormal.." ("..hihealdmg..")".." ["..ehnormal.."]");
		end
	end
	return text;
end
