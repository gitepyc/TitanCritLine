DEBUG = false; -- for internal testing only, leave it set to false!
-- Tony

--[[ global addon variables ]]
local TITAN_CRITLINE_ID =  "CritLine";
local TITAN_CRITLINE_VERSION = "0.9.1.2-dev";
local TITAN_CRITLINE_BUTTON_LABEL = "CL: ";
local TITAN_CRITLINE_BUTTON_ICON = "Interface\\AddOns\\TitanCritLine\\TitanCritLine";
local TITAN_CRITLINE_BUTTON_TEXT = "%s/%s/%s";
local TITAN_CRITLINE_RECORD_SOUND = 888; -- SOUNDKIT.LEVEL_UP
local TITAN_CRITLINE_NEW_HOT_RECORD_MSG = "New HOT %s Record!";
local HOT_TEXT = "HOT";

local HEADER_TEXT_COLOR  = "|cffffffff";
local SUBHEADER_TEXT_COLOR  = "|cffCEA208";
local BODY_TEXT_COLOR  = "|cffffffff";
local HEAL_TEXT_COLOR  = "|cFF0070CC";
local DOT_TEXT_COLOR   = "|cFFFF8000";
local HINT_TEXT_COLOR  = "|cff00ff00";

local TCL_REALM = GetRealmName() or GetNormalizedRealmName();
local TitanCritLine_PlayerRealmName = ""; -- only stored for compability reasons

local TCL_SPECIAL_MOB_IDS = {
	[12460] = true, -- Death Talon Wyrmguard
	[12461] = true, -- Death Talon Overseer
	[13020] = true, -- Vaelastrasz the Corrupt
	[14020] = true, -- Chromaggus
	[15339] = true, -- Ossirian the Unscarred
};
local TCL_HITTYPE = { "NORMAL", "CRIT", "DOT" };
local TCL_SOURCETYPE = { "MY", "PET" };  --TCL_SOURCETYPE = { "MY", "PET", "GUARDIAN" };

local DAMAGE_TYPE_NONHEAL = "0";
local DAMAGE_TYPE_HEAL =  "1";

local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("Titan_CritLine", true)
TitanCritLine = LibStub("AceAddon-3.0"):NewAddon("TitanCritLine", "AceHook-3.0", "AceTimer-3.0")
TitanCritLine.ID = TITAN_CRITLINE_ID;
TitanCritLine.VERSION = TITAN_CRITLINE_VERSION;
TitanCritLine.COLORS = {
	HEADER = HEADER_TEXT_COLOR,
	SUBHEADER = SUBHEADER_TEXT_COLOR,
	BODY = BODY_TEXT_COLOR,
	HEAL = HEAL_TEXT_COLOR,
	DOT = DOT_TEXT_COLOR,
	HINT = HINT_TEXT_COLOR,
};
TitanCritLine.HIT_TYPES = TCL_HITTYPE;
TitanCritLine.SOURCE_TYPES = TCL_SOURCETYPE;
TitanCritLine.SPECIAL_MOB_IDS = TCL_SPECIAL_MOB_IDS;
TitanCritLine.DAMAGE_TYPE_NONHEAL = DAMAGE_TYPE_NONHEAL;
TitanCritLine.DAMAGE_TYPE_HEAL = DAMAGE_TYPE_HEAL;
TitanCritLine.RECORD_SOUND = TITAN_CRITLINE_RECORD_SOUND;
TitanCritLine.NEW_HOT_RECORD_MSG = TITAN_CRITLINE_NEW_HOT_RECORD_MSG;
TitanCritLine.HOT_TEXT = HOT_TEXT;

function TitanCritLine:GetRealmKey()
	return TCL_REALM;
end

local TITAN_CRITLINE_DIALOG_BACKDROP = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 },
};

local function tcl_ApplyDialogBackdrop(frame)
	frame:SetBackdrop(TITAN_CRITLINE_DIALOG_BACKDROP);
end
TitanCritLine.ApplyDialogBackdrop = tcl_ApplyDialogBackdrop;

-- UISpecialFrames's native Escape behavior hides every registered frame that
-- is currently shown, all at once - fine for a single frame, wrong once
-- Settings, Filter, and About can all be open at the same time (About and
-- Filter both open from Settings). Only the most-recently-shown frame's name
-- is ever actually present in UISpecialFrames; on hide, the next-most-recent
-- one (if any) is re-registered, so Escape closes them one at a time, in the
-- order they were opened, like a normal window stack. Same bug and fix as
-- CritLog's UI/Shared.lua (pushEscapeFrame/popEscapeFrame).
local tcl_EscapeFrameStack = {};
-- The one name currently sitting in UISpecialFrames, or nil. Tracked
-- explicitly rather than inferred from stack position: assuming "whatever
-- was just popped is the one in UISpecialFrames" only holds if frames are
-- always closed in the reverse of the order they were opened. Closing a
-- non-topmost frame directly (e.g. closing Settings while About, opened
-- from it, is still shown) breaks that assumption and leaves a stale entry
-- behind instead of removing it.
local tcl_RegisteredEscapeFrame = nil;

local function tcl_RemoveFromTable(t, value)
	for i, existing in ipairs(t) do
		if (existing == value) then
			table.remove(t, i);
			return;
		end
	end
end

local function tcl_SetRegisteredEscapeFrame(name)
	if (tcl_RegisteredEscapeFrame) then
		tcl_RemoveFromTable(UISpecialFrames, tcl_RegisteredEscapeFrame);
	end
	tcl_RegisteredEscapeFrame = name;
	if (tcl_RegisteredEscapeFrame) then
		tinsert(UISpecialFrames, tcl_RegisteredEscapeFrame);
	end
end

function tcl_PushEscapeFrame(name)
	tcl_RemoveFromTable(tcl_EscapeFrameStack, name);
	table.insert(tcl_EscapeFrameStack, name);
	tcl_SetRegisteredEscapeFrame(name);
end

function tcl_PopEscapeFrame(name)
	tcl_RemoveFromTable(tcl_EscapeFrameStack, name);
	tcl_SetRegisteredEscapeFrame(tcl_EscapeFrameStack[#tcl_EscapeFrameStack]);
end

local function tcl_EnsureInitialized()
	if (TCL_SETTINGS == nil) then
		TCL_SETTINGS = {};
	end
	if (TCL_DOT == nil) then
		TCL_DOT = {};
	end

	tcl_Initialize();
	tcl_InitDOT();
end
TitanCritLine.EnsureInitialized = tcl_EnsureInitialized;


--[[ functions for the setup dialog ]]
function tcl_DisplaySettings()
	tcl_EnsureInitialized();
	tcl_ApplyDialogBackdrop(TitanCritLine_SettingsFrame);
	TitanCritLine_SettingsFrame_HeaderText:SetText(TITAN_CRITLINE_ID.." "..TITAN_CRITLINE_MENU_SETTINGS);
	TitanCritLine_SettingsFrame_Option1Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_SPLASH_TEXT));
	TitanCritLine_SettingsFrame_Option1.HelpText = TITAN_CRITLINE_OPTION_SPLASH_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] == "1" ) then
		TitanCritLine_SettingsFrame_Option1:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option2Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_PLAYSOUNDS_TEXT));
	TitanCritLine_SettingsFrame_Option2.HelpText = TITAN_CRITLINE_OPTION_PLAYSOUNDS_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] == "1" ) then
		TitanCritLine_SettingsFrame_Option2:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option3Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_PVPONLY_TEXT));
	TitanCritLine_SettingsFrame_Option3.HelpText = TITAN_CRITLINE_OPTION_PVPONLY_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"] == "1" ) then
		TitanCritLine_SettingsFrame_Option3:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option4Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_SCREENCAP_TEXT));
	TitanCritLine_SettingsFrame_Option4.HelpText = TITAN_CRITLINE_OPTION_SCREENCAP_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] == "1" ) then
		TitanCritLine_SettingsFrame_Option4:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option7Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_SHOW_CRIT_TEXT));
	TitanCritLine_SettingsFrame_Option7.HelpText = TITAN_CRITLINE_OPTION_SHOW_CRIT_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWCRIT"] == "1" ) then
		TitanCritLine_SettingsFrame_Option7:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option8Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_SHOWHITS_TEXT));
	TitanCritLine_SettingsFrame_Option8.HelpText = TITAN_CRITLINE_OPTION_SHOWHITS_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWHITS"] == "1" ) then
		TitanCritLine_SettingsFrame_Option8:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option5Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_ONCLICK_TEXT));
	TitanCritLine_SettingsFrame_Option5.HelpText = TITAN_CRITLINE_OPTION_ONCLICK_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"] == "1" ) then
		TitanCritLine_SettingsFrame_Option5:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option9Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_SHIFT_ONCLICK_TEXT));
	TitanCritLine_SettingsFrame_Option9.HelpText = TITAN_CRITLINE_OPTION_SHIFT_ONCLICK_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] == "1" ) then
		TitanCritLine_SettingsFrame_Option9:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option6Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_FILTER_HEALING_TEXT));
	TitanCritLine_SettingsFrame_Option6.HelpText = TITAN_CRITLINE_OPTION_FILTER_HEALING_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "1" ) then
		TitanCritLine_SettingsFrame_Option6:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Slider1:SetValue(tonumber(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"]));
	TitanCritLine_SettingsFrame_Slider1Text1:SetText(TITAN_CRITLINE_OPTION_LVLADJ_TEXT);
	TitanCritLine_SettingsFrame_Slider1.HelpText = TITAN_CRITLINE_OPTION_LVLADJ_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"] == "0" ) then
		TitanCritLine_SettingsFrame_Slider1Text2:SetText("Off");
	else
		TitanCritLine_SettingsFrame_Slider1Text2:SetText(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"]);
	end
	TitanCritLine_SettingsFrame_Option10Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_MOBFILTER_TEXT));
	TitanCritLine_SettingsFrame_Option10.HelpText = TITAN_CRITLINE_OPTION_MOBFILTER_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] == "1" ) then
		TitanCritLine_SettingsFrame_Option10:SetChecked(true);
	end 
	TitanCritLine_SettingsFrame_Option11Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_SHOW_PET_TEXT));
	TitanCritLine_SettingsFrame_Option11.HelpText = TITAN_CRITLINE_OPTION_SHOW_PET_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "1" ) then
		TitanCritLine_SettingsFrame_Option11:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Option12Text:SetText(COLOR(SUBHEADER_TEXT_COLOR, TITAN_CRITLINE_OPTION_ALL_SPELLS_TEXT));
	TitanCritLine_SettingsFrame_Option12.HelpText = TITAN_CRITLINE_OPTION_ALL_SPELLS_HELPTEXT;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] == "1" ) then
		TitanCritLine_SettingsFrame_Option11:SetChecked(true);
	end
	TitanCritLine_SettingsFrame_Slider1:Show();
	TitanCritLine_SettingsFrame:Show();
end 

function tcl_SettingsOptionButton_OnClick( self, button )
	if ( button == 1 ) then
		tcl_ToggleSplash();
	elseif ( button == 2 ) then
		tcl_ToggleSound();
	elseif ( button == 3 ) then
		tcl_TogglePvP();
	elseif ( button == 4 ) then
		tcl_ToggleScreenShots();
	elseif ( button == 5 ) then
		tcl_ToggleOnClick();
	elseif ( button == 6 ) then
		tcl_ToggleHealing();
	elseif ( button == 7 ) then
		tcl_ToggleShowCrit();
	elseif ( button == 8 ) then
		tcl_ToggleShowHits();
	elseif ( button == 9 ) then
		tcl_ToggleShiftOnClick();
	elseif ( button == 10 ) then
		tcl_ToggleMobFilter();
	elseif ( button == 11 ) then
		tcl_TogglePet();
	elseif ( button == 12 ) then
		tcl_ToggleAllSpells();
	end
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end
function table.removekey(table, key)
    local element = table[key]
    table[key] = nil
    return element
end

function tcl_SettingsOptionButton_OnEnter( self )
	-- GameTooltip is a single shared frame (every addon and Blizzard UI
	-- element uses the same instance), and it doesn't always shrink back
	-- down to a new SetText's actual size if it's still showing when
	-- SetText is called again - in-game reported: the tooltip sometimes
	-- rendered much too large, fixed by moving the mouse away and
	-- re-hovering (which hides and re-shows it). Hiding first forces a
	-- clean reset every time instead of relying on that happening on its
	-- own. Same bug and fix as CritLog's UI/Shared.lua (attachTooltip).
	GameTooltip:Hide();
    GameTooltip:SetOwner(UIParent, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self:GetName(), "BOTTOMLEFT", -10, -4);
	GameTooltip:SetText(self.HelpText);
	GameTooltip:Show();
end

function tcl_SettingsOptionButton_OnLeave( self )
	GameTooltip:Hide();
end

function tcl_SettingsSlider_OnValueChanged()
	local lvladj = TitanCritLine_SettingsFrame_Slider1:GetValue();
	if ( lvladj == 0 ) then
		TitanCritLine_SettingsFrame_Slider1Text2:SetText("Off");
	else
		TitanCritLine_SettingsFrame_Slider1Text2:SetText(tostring(lvladj));
	end
	TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"] = tostring(lvladj);
	tcl_DEBUG(TITAN_CRITLINE_ID.." level adjustment set to "..tostring(lvladj));
end

function tcl_ToggleShowHits()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWHITS"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWHITS"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show all hits is on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWHITS"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show all hits is off");
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_ToggleOnClick()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"] = "1";
		TitanCritLine_SettingsFrame_Option9:Enable();
		tcl_DEBUG(TITAN_CRITLINE_ID.." post to chat on click is on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"] = "0";
		TitanCritLine_SettingsFrame_Option9:Disable();
		tcl_DEBUG(TITAN_CRITLINE_ID.." post to chat on click is off");
	end
end

function tcl_ToggleShiftOnClick()
	if ( TitanCritLine_SettingsFrame_Option9:IsEnabled() ) then
		if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] == "0" ) then
			TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] = "1";
			tcl_DEBUG(TITAN_CRITLINE_ID.." post to chat on SHIFT click is on");
		else
			TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] = "0";
			tcl_DEBUG(TITAN_CRITLINE_ID.." post to chat on SHIFT click is off");
		end
	end
end

function tcl_ToggleScreenShots()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." screen shots on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." screen shots off");
	end
end

function tcl_ToggleSound()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." sound on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." sound off");
	end
end

function tcl_TogglePet()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show pet on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show pet off");
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_TogglePvP()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." pvponly on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." pvponly off");
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_ToggleSplash()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." splash on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] = "0";
		info.checked = 0;
		tcl_DEBUG(TITAN_CRITLINE_ID.." splash off");
	end
end

function tcl_ToggleHealing()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." filter healing on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." filter healing off");
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_ToggleShowCrit()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWCRIT"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWCRIT"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show crit percentage on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWCRIT"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show crit percentage off");
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_ToggleMobFilter()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." filter mobs on");
		tcl_DeleteAllRecordsWithMobsInFilter();
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." filter mobs off");
		tcl_RestoreAllRecordsWithMobsInFilter();
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_ToggleAllSpells()
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] == "0" ) then
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] = "1";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show all spells on");
	else
		TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] = "0";
		tcl_DEBUG(TITAN_CRITLINE_ID.." show all spells off");
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_Reset()
	for index = 1, #(TCL_SOURCETYPE) do
		TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[index]] = {};
	end
	for index = 1, #(TCL_SOURCETYPE) do
		TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[index]] = {};
	end
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

StaticPopupDialogs["TITAN_CRITLINE_CONFIRM_RESET"] = {
	text = "Are you sure you want to reset all CritLine records?",
	button1 = YES,
	button2 = NO,
	OnAccept = tcl_Reset,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

function tcl_RequestReset()
	StaticPopup_Show("TITAN_CRITLINE_CONFIRM_RESET");
end

function tcl_SettingsClose()
	if ( TitanCritLine_FilterFrame:IsVisible() ) then
		tcl_FilterClose();
	end
	TitanCritLine_SettingsFrame:Hide();
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_Filter()
	if ( TitanCritLine_FilterFrame:IsVisible() ) then
		tcl_FilterClose();
	else
		local i = 1;
		for index = 1, #(TCL_SOURCETYPE) do
			for k,v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[index]]) do
				if ( i > 40 ) then
					do break end
				end
				tcl_DEBUG("create button no."..tostring(i).." for "..k);
				local button = _G["TitanCritLine_FilterFrame_Option"..tostring(i)];
				local text = _G["TitanCritLine_FilterFrame_Option"..tostring(i).."Text"];
				text:Show();
				text:SetText(k);
				button:Show();
				if (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[index]][k]["Filter"] == "0") then
					button:SetChecked(true);
				end
				i = i + 1;
			end
		end
		local height = i * 24 + 20;
		TitanCritLine_FilterFrame:SetHeight(height);
		TitanCritLine_FilterFrame:SetPoint("LEFT", "TitanCritLine_SettingsFrame", "RIGHT", 5, 0);
		tcl_ApplyDialogBackdrop(TitanCritLine_FilterFrame);
		TitanCritLine_FilterFrame:Show();
	end
end

function tcl_FilterOptionButton_OnClick(self, id)
	local button = _G["TitanCritLine_FilterFrame_Option"..tostring(id)];
	local attackType = _G["TitanCritLine_FilterFrame_Option"..tostring(id).."Text"]:GetText();
	if ( button:GetChecked() ) then
		tcl_DEBUG(attackType.." filter is on");
		for i = 1, #(TCL_SOURCETYPE) do
			if (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType] ~= nil) then
				TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["Filter"] = "0";
				break;
			end
		end
	else
		tcl_DEBUG(attackType.." filter is off");
		for i = 1, #(TCL_SOURCETYPE) do
			if (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType] ~= nil) then
				TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["Filter"] = "1";
				break;
			end
		end
	end
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_FilterClose()
	TitanCritLine_FilterFrame:Hide();
	for i = 1, 40, 1 do
		local button = _G["TitanCritLine_FilterFrame_Option"..tostring(i)];
		local text = _G["TitanCritLine_FilterFrame_Option"..tostring(i).."Text"];
		button:SetChecked(false);
		button:Hide();
		text:SetText(nil);
		text:Hide();
	end
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

--[[ titan panel functions ]]
-- registry.menuContextFunction (Titan_Menu, Jan 2026 scheme). Titan_Menu.AddContextMenu
-- already adds the plugin title, a divider, and (via GenControlVars) the ShowIcon /
-- ShowLabelText / DisplayOnRightSide / Hide controls declared in registry.controlVariables,
-- so only the CritLine-specific entries are added here.
function TitanCritLine_MenuGenerator(owner, rootDescription)
	local id = TITAN_CRITLINE_ID;
	local root = rootDescription;

	Titan_Menu.AddCommand(root, id, TITAN_CRITLINE_MENU_SETTINGS, tcl_DisplaySettings);
	Titan_Menu.AddDivider(root);
	Titan_Menu.AddCommand(root, id, TITAN_CRITLINE_MENU_POSTGUILD, tcl_PostToGuild);
	Titan_Menu.AddCommand(root, id, TITAN_CRITLINE_MENU_POSTPARTY, tcl_PostToParty);
	Titan_Menu.AddCommand(root, id, TITAN_CRITLINE_MENU_POSTRAID, tcl_PostToRaid);
	Titan_Menu.AddCommand(root, id, TITAN_CRITLINE_MENU_POSTLOCAL, tcl_PostToLocal);
end

function tcl_GetButtonText( id )
	local id = TitanUtils_GetButton( id );
	local buttonRichText = format(TITAN_CRITLINE_BUTTON_TEXT, COLOR(BODY_TEXT_COLOR, 0), COLOR(BODY_TEXT_COLOR, 0), COLOR(BODY_TEXT_COLOR, 0) );

	if (TCL_SETTINGS ~= nil ) then
		if ( id ~= 0 ) then
			if ( TCL_SETTINGS[TCL_REALM] ~= nil ) then
				if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0") then 				
					buttonRichText = format(TITAN_CRITLINE_BUTTON_TEXT, COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG()), COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG("MY", "CRIT")), COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG("MY", "DOT")));
					buttonRichText = buttonRichText.." - "..format(TITAN_CRITLINE_BUTTON_TEXT, COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG("MY", "NORMAL", "1")), COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG("MY", "CRIT", "1")), COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG("MY", "DOT", "1"))); 
				else 
					buttonRichText = format(TITAN_CRITLINE_BUTTON_TEXT, COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG()), COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG("MY", "CRIT")), COLOR(BODY_TEXT_COLOR, tcl_GetHighDMG("MY", "DOT")));
				end
			end
		end
	end

	tcl_DEBUG("tcl_GetButtonText: "..TITAN_CRITLINE_BUTTON_LABEL..buttonRichText);
	return TITAN_CRITLINE_BUTTON_LABEL..buttonRichText;
end

--[[ addon functions ]]
function tcl_OnLoad(self)
	self.registry = { 
		id = TITAN_CRITLINE_ID,
		category = "Combat",
		version = TITAN_CRITLINE_VERSION,
		menuText = TITAN_CRITLINE_ID,
		menuContextFunction = TitanCritLine_MenuGenerator,
		buttonTextFunction = "tcl_GetButtonText",
		tooltipTitle = TITAN_CRITLINE_ID.." "..TITAN_CRITLINE_TOOLTIP_HEADER.." "..TITAN_CRITLINE_VERSION,
		tooltipTextFunction = "tcl_GetSummaryRichText",
		icon = TITAN_CRITLINE_BUTTON_ICON,
		iconWidth = 16,
		controlVariables = {
			ShowIcon = true,
			ShowLabelText = true,
		},
		savedVariables = {
			ShowIcon = true,
			ShowLabelText = true,
		}
	};
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_LEAVING_WORLD");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	tcl_Msg(TITAN_CRITLINE_ID.." "..TITAN_CRITLINE_VERSION.." loaded.");
end

function tcl_OnUpdate( self, elapsed ) 
end









function tcl_OnClick(self, button)
	if (button == "LeftButton") then
		if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] == "1" ) then
			if ( IsShiftKeyDown() ) then
				if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"] == "0" ) then
					tcl_DisplaySettings();
				else
					tcl_PostMessage();
				end
			else
				return;
			end
		else
			if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"] == "0" ) then
				tcl_DisplaySettings();
			else
				tcl_PostMessage();
			end
		end
--	elseif (button == "RightButton") then
--		local summary = tcl_GetSummaryRichText();
--		TitanCritLineSummaryFrame:AddMessage(tcl_GetSummaryRichText(), 1, 1, 0, 1, 1);
	end
end

function tcl_Update(version)
	tcl_Msg("Updating "..TITAN_CRITLINE_ID.." from version "..version.." to version "..TITAN_CRITLINE_VERSION.." ...");
	-- set local variables;
	local dbName = {};

	if ( version == "NEW" or version == "UNKNOWN" ) then
		if ( version == "NEW" ) then
			if ( TCL_SETTINGS == nil ) then
				TCL_SETTINGS = {};
			end
			if ( TCL_DOT == nil ) then
				TCL_DOT = {};
			end
		end
		dbName = TCL_SETTINGS;
	end

	-- set global variables
	tcl_Initialize(dbName);
	tcl_InitDOT(TCL_DOT);
                
	-- check for old titan critline data
	if ( version == "NEW" or version == "UNKNOWN") then
		tcl_Msg("No old Titan Critline database found, creating new database for "..UnitName("player")..".");
	elseif ( version < "0.5.0" ) then
		if (dbName == nil) then
			tcl_Msg("No old Titan Critline database found, creating new database for "..UnitName("player")..".");
		else
			realm = GetRealmName().."."..UnitName("player");
			if (dbName[realm] == nil) then
				realm = TCL_REALM;
				if (dbName[realm] == nil ) then 
					tcl_Msg("Old Titan CritLine database found, but not for "..UnitName("player")..", creating new one.");
				end
			end

			if (dbName[realm] ~= nil ) then
				if ( #(TCL_SETTINGS[realm]["DATA"]) == nil or #(TCL_SETTINGS[realm]["DATA"]) == 0 ) then
					tcl_Msg("Updating old Titan CritLine data ...");
					for k,v in pairs(TCL_SETTINGS[realm]["SETTINGS"]) do
						dbName[TCL_REALM]["SETTINGS"][k] = v;
					end
					for attackType,v in pairs(TCL_SETTINGS[realm]["DATA"]) do
						if (attackType ~= "MY") then
							dbName[TCL_REALM]["DATA"]["MY"][attackType] = {}; 
							dbName[TCL_REALM]["DATA"]["MY"][attackType]["Filter"] = "0"; 
							for hitType,v in pairs(TCL_SETTINGS[realm]["DATA"][attackType]) do 
								if ( v ~= {} ) then
									dbName[TCL_REALM]["DATA"]["MY"][attackType][hitType] = v; 
								elseif ( v == {} ) then 
									for k,v in pairs(TCL_SETTINGS[realm]["DATA"][attackType][hitType]) do 
										dbName[TCL_REALM]["DATA"]["MY"][attackType][hitType][k] = v; 
									end 

									if (TCL_SETTINGS[realm]["DATA"][attackType][hitType]["Value"] == nil) then 
										dbName[TCL_REALM]["DATA"]["MY"][attackType][hitType]["Value"] = 0; 
									end 
								end
							end
					        end
					end
				else
					tcl_Msg("New data was found, no update needed ...");
				end
			end
		end
		--add changes to database
		tcl_Msg("Updating main database ...");
		for k, v in pairs(dbName[realm]["DATA"]["MY"]) do
			if ( dbName[TCL_REALM]["DATA"]["MY"][k]["Misses"] == nil ) then
				dbName[TCL_REALM]["DATA"]["MY"][k]["Misses"] = 0;
			end
		end
	elseif (version >= "0.5.0" ) then
		if (dbName == nil) then
			tcl_Msg("No old Titan Critline database found, creating new database for "..UnitName("player")..".");
		else
			if (dbName[TCL_REALM] == nil) then
				tcl_Msg("Old Titan CritLine database found, but not for "..UnitName("player")..", creating new one.");
			else
				if ( #(TCL_SETTINGS[TCL_REALM]["DATA"]) == nil or #(TCL_SETTINGS[TCL_REALM]["DATA"]) == 0 ) then
					tcl_Msg("Updating old Titan CritLine data ...");
					for k,v in pairs(TCL_SETTINGS[TCL_REALM]["SETTINGS"]) do
						dbName[TCL_REALM]["SETTINGS"][k] = v;
					end
					for i = 1, #(TCL_SOURCETYPE) do
						for attackType,v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]]) do
							dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType] = {};
							dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["Filter"] = "0";
							for hitType,v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]) do
								if ( v ~= {} ) then
									dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType] = v; 
								elseif ( v == {} ) then
									dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType] = {};
									for k,v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType]) do
										dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType][k] = v;
									end
									if (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType]["Value"] == nil) then
										dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType]["Value"] = 0;
									end
								end
							end
						end
					end
				else
					tcl_Msg("New data was found, no update needed ...");
				end
			end
		end
		--add changes to database
		tcl_Msg("Updating main database ...");
		for i = 1, #(TCL_SOURCETYPE) do
			for k, v in pairs(dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]]) do
				if ( dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][k]["Misses"] == nil ) then
					dbName[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][k]["Misses"] = 0;
				end
			end
		end
	end
	TCL_SETTINGS = {};
	TCL_SETTINGS = dbName;
	-- update complete
	tcl_Msg("Conversion complete, read the UPDATE.TXT file in the addon directory!");
end

function tcl_InitDOT(tcl_Table)
    local tab = tcl_Table or TCL_DOT;
    tcl_DEBUG("Initialize DOT Table...");
    if (tab == nil) then
       	tab = {};
    end   
   	if (tab["VERSION"] == nil) then
  	 	tcl_DEBUG("VERSION was not found...Creating");
		tab["VERSION"] = TITAN_CRITLINE_VERSION;
	end
    if (tab["DOT_DATA"] == nil) then
    	tcl_DEBUG("DOT_DATA was not found...Creating");
       	tab["DOT_DATA"] = {};
    end
    for i = 1, #(TCL_SOURCETYPE) do
   	 if (tab["DOT_DATA"][TCL_SOURCETYPE[i]] == nil) then
			tab["DOT_DATA"][TCL_SOURCETYPE[i]] = {};
		end	
	end
    tcl_DEBUG("Initialize DOT Table Complete.");    
end

function tcl_Initialize(tcl_Table)
    local tab = tcl_Table or TCL_SETTINGS;

	tcl_DEBUG("Initializing...");
	TCL_REALM = TCL_REALM or GetRealmName() or GetNormalizedRealmName();
	if (tab == nil) then
		tab = {};
	end
	if (tab["VERSION"] == nil) then
		tab["VERSION"] = TITAN_CRITLINE_VERSION;
	end
	if (tab[TCL_REALM] == nil) then
		tab[TCL_REALM] = {};
	end
	if (tab[TCL_REALM]["SETTINGS"] == nil) then
		tab[TCL_REALM]["SETTINGS"] = {};
	end
	local existingSettings = TCL_SETTINGS
		and TCL_SETTINGS[TCL_REALM]
		and TCL_SETTINGS[TCL_REALM]["SETTINGS"]
		or {};
	if (tab[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == nil) then
		if (existingSettings["FILTER_HEALING"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] = existingSettings["FILTER_HEALING"];
		else 
			tab[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["LVLADJ"] == nil) then
		if (existingSettings["LVLADJ"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["LVLADJ"] = existingSettings["LVLADJ"];
		else 
			tab[TCL_REALM]["SETTINGS"]["LVLADJ"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SPLASH"] == nil) then
		if (existingSettings["SPLASH"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SPLASH"] = existingSettings["SPLASH"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SPLASH"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["PVPONLY"] == nil) then
		if (existingSettings["PVPONLY"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["PVPONLY"] = existingSettings["PVPONLY"];
		else 
			tab[TCL_REALM]["SETTINGS"]["PVPONLY"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["PLAYSOUND"] == nil) then
		if (existingSettings["PLAYSOUND"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["PLAYSOUND"] = existingSettings["PLAYSOUND"];
		else 
			tab[TCL_REALM]["SETTINGS"]["PLAYSOUND"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SNAPSHOT"] == nil) then
		if (existingSettings["SNAPSHOT"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SNAPSHOT"] = existingSettings["SNAPSHOT"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SNAPSHOT"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SHOWCRIT"] == nil) then
		if (existingSettings["SHOWCRIT"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHOWCRIT"] = existingSettings["SHOWCRIT"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHOWCRIT"] = "1";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["SHOWHITS"] == nil ) then
		if (existingSettings["SHOWHITS"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHOWHITS"] = existingSettings["SHOWHITS"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHOWHITS"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["ONCLICK"] == nil) then
		if (existingSettings["ONCLICK"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["ONCLICK"] = existingSettings["ONCLICK"];
		else 
			tab[TCL_REALM]["SETTINGS"]["ONCLICK"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] == nil) then
		if (existingSettings["SHIFTONCLICK"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] = existingSettings["SHIFTONCLICK"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] = "0";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] == nil ) then
		if (existingSettings["FILTER_MOBS"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] = existingSettings["FILTER_MOBS"];
		elseif (existingSettings["FILTER_MOB"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] = existingSettings["FILTER_MOB"];
		else 
			tab[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] = "0";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["SHOW_PET"] == nil ) then
		if (existingSettings["SHOW_PET"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHOW_PET"] = existingSettings["SHOW_PET"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHOW_PET"] = "0";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] == nil ) then
		if (existingSettings["ALL_SPELLS"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] = existingSettings["ALL_SPELLS"];
		else 
			tab[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] = "0";
		end
	end
	if (tab[TCL_REALM]["DATA"] == nil) then
		tab[TCL_REALM]["DATA"] = {};
	end
	for i = 1, #(TCL_SOURCETYPE) do
		if (tab[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]] == nil) then
			tab[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]] = {};
		end
	end
	tcl_DEBUG("Initialization Complete.");
end







--[[ misc help functions ]]
function COLOR(color, msg)
	if ( msg == nil ) then
		return;
	end
	return color..msg..FONT_COLOR_CODE_CLOSE;
end

function tcl_Msg(msg)
	if ( msg == nil ) then
		msg = "------------------------------";
	end
	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(msg);
	end
end

function tcl_Rebuild()
	tcl_Msg(TITAN_CRITLINE_ID.." "..TITAN_CRITLINE_VERSION.." rebuilding data.");
	TCL_SETTINGS[TCL_REALM] = nil;
	tcl_Initialize();
	TCL_DOT["DOT_DATA"] = nil;
	tcl_InitDOT(TCL_DOT);
	tcl_Msg(TITAN_CRITLINE_ID.." "..TITAN_CRITLINE_VERSION.." rebuilding data complete.");
end

function tcl_DEBUG(message)
	if (DEBUG and DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage("DEBUG: "..message);
	end
end
