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

-- Shared fallback for every Post-to-X action below when their specific
-- channel doesn't apply (not grouped/raided/guilded) - echoes to your own
-- chat frame only, nobody else sees it. Also exposed as its own explicit
-- menu action (tcl_PostToLocal) for testing without posting anywhere.
local function tcl_PostLocal()
	for _, message in ipairs(tcl_GetRecordChatText()) do
		tcl_Msg(message);
	end
end

function tcl_PostToLocal()
	tcl_PostLocal();
end

-- Each of these targets its own specific channel unconditionally whenever
-- that channel could plausibly apply, and never substitutes a different
-- real chat channel - only ever RAID for Raid, PARTY for Party (even while
-- in a raid; the WoW client itself may reject SendChatMessage(..., "PARTY")
-- while raided, needs in-game verification), GUILD for Guild. Falls back to
-- a local-only echo, never to a different real channel (in-game reported:
-- both used to fall back to a context-sensitive getDefaultChannel(), which
-- made Post to Party post to the raid channel while in a raid, and Post to
-- Raid post to party/guild chat while not in a raid).
function tcl_PostToRaid()
	if (IsInRaid()) then
		tcl_PostMessage(tcl_GetRecordChatText(), "RAID");
		return;
	end
	tcl_PostLocal();
end

function tcl_PostToParty()
	if (IsInGroup()) then
		tcl_PostMessage(tcl_GetRecordChatText(), "PARTY");
		return;
	end
	tcl_PostLocal();
end

function tcl_PostToGuild()
	if (GetGuildInfo("player")) then
		tcl_PostMessage(tcl_GetRecordChatText(), "GUILD");
		return;
	end
	tcl_PostLocal();
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
