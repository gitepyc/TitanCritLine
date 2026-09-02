DEBUG = false; -- for internal testing only, leave it set to false!
-- Tony

--[[ global addon variables ]]
local TITAN_CRITLINE_ID =  "CritLine";
local TITAN_CRITLINE_VERSION = "0.7.1";
local TITAN_CRITLINE_BUTTON_LABEL = "CL: ";
local TITAN_CRITLINE_BUTTON_ICON = "Interface\\AddOns\\TitanCritLine\\TitanCritLine";
local TITAN_CRITLINE_BUTTON_TEXT = "%s/%s/%s";

local HEADER_TEXT_COLOR  = "|cffffffff";
local SUBHEADER_TEXT_COLOR  = "|cffCEA208";
local BODY_TEXT_COLOR  = "|cffffffff";
local HEAL_TEXT_COLOR  = "|cFF0070CC";
local DOT_TEXT_COLOR   = "|cFFFF8000";
local HINT_TEXT_COLOR  = "|cff00ff00";

local TCL_REALM = GetCVar("realmName");
local TitanCritLine_PlayerRealmName = ""; -- only stored for compability reasons
local TCL_PUID = nil;						-- tracks the player UID to determine whom casted spells/effects
local TCL_FINALIZE_DOT = false;  			-- flag used to force dot effects to finalize healing dots.  Without this healing dot effects will register forever.

local TCL_MOBFILTER = {};
local TCL_HITTYPE = { "NORMAL", "CRIT", "DOT" };
local TCL_SOURCETYPE = { "MY", "PET" };  --TCL_SOURCETYPE = { "MY", "PET", "GUARDIAN" };

local DAMAGE_TYPE_NONHEAL = "0";
local DAMAGE_TYPE_HEAL =  "1";
local SHOW_WELCOME = 0;
local TRACK_DMG = true;

local L = LibStub("AceLocale-3.0"):GetLocale("Titan", true)
local LB = LibStub("AceLocale-3.0"):GetLocale("Titan_CritLine", true)
local TitanCritLine = LibStub("AceAddon-3.0"):NewAddon("TitanCritLine", "AceHook-3.0", "AceTimer-3.0")


--[[ functions for the setup dialog ]]
function tcl_DisplaySettings()
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
	for index = 1, table.getn(TCL_SOURCETYPE) do
		TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[index]] = {};
	end
	for index = 1, table.getn(TCL_SOURCETYPE) do
		TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[index]] = {};
	end
	TitanPanelButton_UpdateTooltip( self );
end

function tcl_SettingsClose()
	if ( TitanCritLine_FilterFrame:IsVisible() ) then
		tcl_FilterClose();
	end
	TitanCritLine_SettingsFrame:Hide();
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_About()
	if ( TitanCritLine_AboutFrame:IsVisible() ) then
		tcl_AboutClose();
	else 
		local text = getglobal("TitanCritLine_AboutFrame_Text");
		text:Show();
		text:SetText( tcl_GetAboutRichText() );
		TitanCritLine_AboutFrame:Show();
	end
end

function tcl_AboutClose()
	TitanCritLine_AboutFrame:Hide();
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_Filter()
	if ( TitanCritLine_FilterFrame:IsVisible() ) then
		tcl_FilterClose();
	else
		local i = 1;
		for index = 1, table.getn(TCL_SOURCETYPE) do
			for k,v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[index]]) do
				if ( i > 40 ) then
					do break end
				end
				tcl_DEBUG("create button no."..tostring(i).." for "..k);
				local button = getglobal("TitanCritLine_FilterFrame_Option"..tostring(i));
				local text = getglobal("TitanCritLine_FilterFrame_Option"..tostring(i).."Text");
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
		TitanCritLine_FilterFrame:Show();
	end
end

function tcl_FilterOptionButton_OnClick(self, id)
	local button = getglobal("TitanCritLine_FilterFrame_Option"..tostring(id));
	local attackType = getglobal("TitanCritLine_FilterFrame_Option"..tostring(id).."Text"):GetText();
	if ( button:GetChecked() ) then
		tcl_DEBUG(attackType.." filter is on");
		for i = 1, table.getn(TCL_SOURCETYPE) do
			if (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType] ~= nil) then
				TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["Filter"] = "0";
				break;
			end
		end
	else
		tcl_DEBUG(attackType.." filter is off");
		for i = 1, table.getn(TCL_SOURCETYPE) do
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
	for i = 1, 20, 1 do
		local button = getglobal("TitanCritLine_FilterFrame_Option"..tostring(i));
		local text = getglobal("TitanCritLine_FilterFrame_Option"..tostring(i).."Text");
		button:SetChecked(false);
		button:Hide();
		text:SetText(nil);
		text:Hide();
	end
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_ManualUpdate()
	tcl_Update(TCL_SETTINGS["VERSION"]);
end

--[[ titan panel functions ]]
function TitanPanelRightClickMenu_PrepareCritLineMenu()
	local id = TITAN_CRITLINE_ID;
	TitanPanelRightClickMenu_AddTitle(TitanPlugins[id].menuText.." "..TITAN_CRITLINE_VERSION);

	local info = {};
	info.text = TITAN_CRITLINE_MENU_SETTINGS;
	info.func = tcl_DisplaySettings;
	UIDropDownMenu_AddButton(info);
	TitanPanelRightClickMenu_AddSpacer();
	local info2 = {};
	info2.text = TITAN_CRITLINE_MENU_POSTGUILD;
	info2.func = tcl_PostToGuild;
	local info3 = {};
	info3.text = TITAN_CRITLINE_MENU_POSTPARTY;
	info3.func = tcl_PostToParty;
	local info4 = {};
	info4.text = TITAN_CRITLINE_MENU_POSTRAID;
	info4.func = tcl_PostToRaid;
	UIDropDownMenu_AddButton(info2);
	UIDropDownMenu_AddButton(info3);
	UIDropDownMenu_AddButton(info4);
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddToggleIcon(id);
	TitanPanelRightClickMenu_AddToggleLabelText(id);
	TitanPanelRightClickMenu_AddSpacer();
	TitanPanelRightClickMenu_AddCommand(TITAN_PANEL_MENU_HIDE, id, TITAN_PANEL_MENU_FUNC_HIDE);
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
		buttonTextFunction = "tcl_GetButtonText", 
		tooltipTitle = TITAN_CRITLINE_ID.." "..TITAN_CRITLINE_TOOLTIP_HEADER.." "..TITAN_CRITLINE_VERSION,
		tooltipTextFunction = "tcl_GetSummaryRichText", 
		icon = TITAN_CRITLINE_BUTTON_ICON,
		iconWidth = 16,
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

function tcl_OnEvent(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 = select(1, ...);
	local srcType;
	local myUnit = false;
	
	if ( event ~= nil and event ~= "COMBAT_LOG_EVENT_UNFILTERED" ) then 
		tcl_DEBUG("***"..tostring(event).."***");
	end
	
	if (event == "UNIT_ENTERED_VEHICLE" ) then
		tcl_DEBUG("Disabling TCL Tracking!");
		if ( TRACK_DMG == true ) then
			TRACK_DMG = false;
		end
	end
	
	if (event == "UNIT_EXITED_VEHICLE" ) then
		tcl_DEBUG("Enabling TCL Tracking!");
		if ( TRACK_DMG == false ) then
			TRACK_DMG = true;
		end
	end
	
	if (event == "PLAYER_ENTERING_WORLD") then		
		if (TitanCritLineSettings == nil) then
			TitanCritLineSettings = {};
		end
		if (TitanCritLineSettings.LASTUSER == nil) then
			TitanCritLineSettings.LASTUSER = "";
		end
		if ((TCL_SETTINGS == nil) or (TCL_DOT == nil) ) then
			tcl_Update("NEW");
		elseif ((TCL_SETTINGS.VERSION == nil) or (TCL_DOT.VERSION == nil)) then
			tcl_Update("UNKNOWN");
		elseif (TCL_SETTINGS.VERSION ~= TITAN_CRITLINE_VERSION) then
			tcl_Update(TCL_SETTINGS.VERSION);
		else
			tcl_Initialize();
			tcl_InitDOT();
		end		
				
		if(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] ~= nil ) then
			if(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] == "1") then
				local greeting;
				if (TitanCritLineSettings.LASTUSER ~= nil and TitanCritLineSettings.LASTREALM ~= nil) then
					if (TitanCritLineSettings.LASTUSER == UnitName("player") 
						and TitanCritLineSettings.LASTREALM == GetCVar("realmName") ) then
						greeting = TitanCritLineSettings.LASTUSER..": Welcome back to "..TitanCritLineSettings.LASTREALM;
						--if (SHOW_WELCOME == 0) then
						--	TitanCritLineSplashFrame:AddMessage(greeting, 1, 1, 0, 1, 20);
						--	TitanCritLineSplashFrame:AddMessage("Titan CritLine", 1, 1, 1, 1, 15);
						--	SHOW_WELCOME = 1;
						--end
					end
				end
			end
		end
		tcl_CreateMobFilter();
		TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
		TitanPanelButton_UpdateTooltip( self );
	elseif (event == "PLAYER_LEAVING_WORLD") then
		TitanCritLineSettings.LASTUSER = UnitName("player");
		TitanCritLineSettings.LASTREALM = TCL_REALM;
		TitanCritLineSettings.LASTUSED = date(); 
		TitanCritLineSettings.VERSION  = TITAN_CRITLINE_VERSION; 
		
		
		for i = 1, table.getn(TCL_SOURCETYPE) do
			if ( TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[i]] ~= nil ) then
				TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[i]] = {};
				tcl_DEBUG("Removing TCL_DOT table ["..TCL_SOURCETYPE[i].."]");		
			end
		end
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then	
		local dot_damage = 0;
			    	-- for debugging events
			--if ( event == "UNIT_ENTERED_VEHICLE" ) then
			--if ( event == "SPELL_SUMMON" ) then
			--	tcl_Msg("UNIT INFO: ");
			--	tcl_Msg("   arg1: "..(arg1 or "none")); 
			--	tcl_Msg("   arg2: "..(arg2 or "none")); 
			--	tcl_Msg("   arg3: "..(arg3 or "none")); 
			--	tcl_Msg("   arg4: "..(arg4 or "none"));
			--	tcl_Msg("   arg5: "..(arg5 or "none"));
			--	tcl_Msg("   arg6: "..(arg6 or "none"));
			--	tcl_Msg("   arg7: "..(arg7 or "none"));
			--	tcl_Msg("   arg8: "..(arg8 or "none"));
			--	tcl_Msg("   arg9: "..(arg9 or "none"));
			--	tcl_Msg("   arg10: "..(arg10 or "none"));
			--	tcl_Msg("   arg11: "..(arg11 or "none"));
			--	tcl_Msg("   arg12: "..(arg12 or "none"));
			--	tcl_Msg("   arg13: "..(arg13 or "none"));
			--	tcl_Msg("   arg14: "..(arg14 or "none"));
			--	tcl_Msg("   arg15: "..(arg15 or "none"));
			--	tcl_Msg("   arg16: "..(arg16 or "none"));
			--	tcl_Msg("   arg17: "..(arg17 or "none"));
			--	tcl_Msg("   arg18: "..(arg18 or "none"));
			--	tcl_Msg("   arg19: "..(arg19 or "none"));
			--	tcl_Msg("   arg20: "..(arg20 or "none"));
			--end
			
    
	    -- String - The UnitId to query (e.g. "player", "party2", "pet", "target" etc.)
		if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ~= 0 ) then
			srcType = TCL_SOURCETYPE[1];
			if (TCL_PUID == nil ) then
				TCL_PUID = arg4;
				tcl_DEBUG("TCL_PUID = "..TCL_PUID);
			end
		elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 
				and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 
				and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
				srcType = TCL_SOURCETYPE[2];
		elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_GUARDIAN) == 0 and
				 bit.band(arg6, COMBATLOG_OBJECT_CONTROL_PLAYER) == 0 and
				 bit.band(arg6, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 and
				 bit.band(arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) == 0 ) then
					 
				srcType = TCL_SOURCETYPE[2];  -- for now use pet, may create GUARDIAN grouping later
				myUnit = true;
		end
			    
	    if ( event ~= nil ) then 
	        tcl_DEBUG("Received Event: ["..(arg2 or "none").."]");	    
	    end  
		if ( arg2 == "SPELL_HEAL" ) then 
			if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0") then
				if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ) then 
					if (arg8 == UnitName("player")) then
						if (arg15 ~= nil) then
 							tcl_DEBUG("Crit Heal: Yourself for "..arg13);
 							tcl_RecordHit(arg11, "CRIT", tonumber(arg13), "You", DAMAGE_TYPE_HEAL);
						else
							tcl_DEBUG("Regular Heal: Yourself for "..arg13);
							tcl_RecordHit(arg11, "NORMAL", tonumber(arg13), "You", DAMAGE_TYPE_HEAL);
						end
					else
						creaturename = arg8;
						if (arg15 ~= nil) then
							tcl_DEBUG("Crit Heal: "..creaturename.." for "..arg13);
							tcl_RecordHit(arg11, "CRIT", tonumber(arg13), creaturename, DAMAGE_TYPE_HEAL);
						else
							tcl_DEBUG("Regular Heal: "..creaturename.." for "..damage);
							tcl_RecordHit(arg11, "NORMAL", tonumber(arg13), creaturename, DAMAGE_TYPE_HEAL);
						end
					end
				end
			end
		elseif (arg2 == "RANGE_DAMAGE" ) then
			if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ~= 0 ) then 
				if (arg19 ~= nil ) then
					tcl_DEBUG("Range Crit Hit: "..arg8.." with "..arg11.." for "..arg13);
					tcl_RecordHit(arg11, "CRIT", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL);
				else
					tcl_DEBUG("Range Regular Hit: "..arg8.." with "..arg11.." for "..arg13);
					tcl_RecordHit(arg11, "NORMAL", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL); 
				end
			elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 
				and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 
				and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
                
                if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "1" ) then
					if (arg19 ~= nil ) then
						tcl_DEBUG("Range Crit Hit: "..arg5.." crit "..arg8.." with "..arg11.." for "..arg13);
						tcl_RecordHit(arg5.."'s "..arg11, "CRIT", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL, "PET");
					else
						tcl_DEBUG("Range Regular Hit: "..arg5.." hit "..arg8.." with "..arg11.." for "..arg13);
						tcl_RecordHit(arg5.."'s "..arg11, "NORMAL", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL, "PET");
					end
				end

			end
		elseif (arg2 == "SWING_DAMAGE" or arg2 == "SWING_EXTRA_ATTACKS" ) then
			if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ~= 0 ) then 
				if (arg16 ~= nil ) then
					tcl_DEBUG("Crit Hit: "..arg8.." for "..arg10);
					tcl_RecordHit(NORMAL_HIT_TEXT, "CRIT", tonumber(arg10), arg8, DAMAGE_TYPE_NONHEAL);
				else
					tcl_DEBUG("Regular Hit: "..arg8.." for "..arg10);
					tcl_RecordHit(NORMAL_HIT_TEXT, "NORMAL", tonumber(arg10), arg8, DAMAGE_TYPE_NONHEAL); 
				end
			elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 
				and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 
				and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
				
				if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "1" ) then
					if (arg16 ~= nil ) then
						tcl_DEBUG("Pet Crit Hit: "..arg5.." crit "..arg8.." for "..arg10);
						tcl_RecordHit(arg5.."'s "..NORMAL_HIT_TEXT, "CRIT", tonumber(arg10), arg8, DAMAGE_TYPE_NONHEAL, "PET");
					else
						tcl_DEBUG("Pet Normal Hit: "..arg5.." hit "..arg8.." for "..arg10);
						tcl_RecordHit(arg5.."'s "..NORMAL_HIT_TEXT, "NORMAL", tonumber(arg10), arg8, DAMAGE_TYPE_NONHEAL, "PET");
					end
				end
			end
		elseif (arg2 == "SPELL_DAMAGE" ) then
			if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ~= 0 ) then 
				if ( arg19 ~= nil ) then
					tcl_DEBUG(arg11.." Crit: "..arg8.." for "..arg13);
					tcl_RecordHit(arg11, "CRIT", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL);
				else
					tcl_DEBUG(arg11.." Hit: "..arg8.." for "..arg13);
					tcl_RecordHit(arg11, "NORMAL", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL);
				end
			elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 
				and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 
				and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
				if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "1" ) then
					if ( arg19 ~= nil ) then
						tcl_DEBUG(arg5.."'s "..arg11.." Crit: "..arg8.." for "..arg13);
						tcl_RecordHit(arg5.."'s "..arg11, "CRIT", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL, "PET");
					else
						tcl_DEBUG(arg5.."'s "..arg11.." Hit: "..arg8.." for "..arg13);
						tcl_RecordHit(arg5.."'s "..arg11, "NORMAL", tonumber(arg13), arg8, DAMAGE_TYPE_NONHEAL, "PET");
					end
				end
			end
		elseif ( arg2 == "SPELL_CAST_SUCCESS" ) then
			local src = arg8 or arg5;
            if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] == nil ) then
				tcl_Initialize();
			else
				if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ~= 0 ) then 
					tcl_DEBUG(arg11.." Cast: "..src);
					if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] == "1" ) then
						tcl_RecordHit(arg11, "NORMAL", 0, src, DAMAGE_TYPE_NONHEAL);
					end
				elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 
					and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 
					and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
					
					if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "1" ) then
						tcl_DEBUG(arg5.."'s "..arg11.." Cast: "..src);
						--if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] == "1" ) then
						tcl_RecordHit(arg5.."'s "..arg11, "NORMAL", 0, src, DAMAGE_TYPE_NONHEAL, "PET");
						--end
					end
				end
			end
		elseif ( arg2 == "SPELL_AURA_APPLIED" or 
		         arg2 == "SPELL_AURA_REMOVED" or 
		         arg2 == "SPELL_AURA_REFRESH" or 
		         arg2 == "SPELL_AURA_BROKEN" or
		         arg2 == "SPELL_AURA_BROKEN_SPELL" ) then --track when a DEBUFF is created
			local showMsg = 0;
			local dmg = arg13 or "none";
			local trg = arg8 or "none";
			local src = arg5 or "none";
			local removeVal = nil;
			
			if ( arg11 ) then
				if ( showMsg == 1 ) then
					tcl_Msg("AURA: "..arg11.." S: ["..src.."]T: ["..trg.."] TYPE: ["..dmg.."]");
				end
				tcl_DEBUG("AURA: "..arg11.." S: ["..src.."]T: ["..trg.."] TYPE: ["..dmg.."]");				
			end

			if ( srcType ~= nil ) then
				local isHeal = nil;				
				if ( arg2 == "SPELL_AURA_APPLIED" ) then								    	    
					if ( TCL_DOT["DOT_DATA"][srcType][arg11] == nil ) then
						TCL_DOT["DOT_DATA"][srcType][arg11] = {};
					end
					tcl_DEBUG("SPELL: "..arg11.." is casted on "..arg8.." ["..arg7.."]");
						if ( TCL_DOT["DOT_DATA"][srcType][arg11][arg7] == nil ) then
							if (( arg5 == arg8 ) and ( arg13 == "BUFF" ) ) then
								isHeal = true;
							else
								isHeal = false;
							end
						TCL_DOT["DOT_DATA"][srcType][arg11][arg7] = {0, isHeal};
					end
		   		end
		   end
		   if ( srcType ~= nil ) then
		   		if ( arg2 == "SPELL_AURA_REMOVED" ) then		   				 		
		 			if ( arg8 == UnitName("player") and TCL_PUID ~= nil ) then		 				
		 				if ( TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[1]][arg11] ~= nil ) then
		 					tcl_DEBUG("AURA_REMOVED: Removing "..arg11.." from the DOT database from "..arg8);
			 				for gUID,v in pairs(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[1]][arg11]) do	
			 					tcl_DEBUG("gUID["..gUID.."] TCL_PUID ["..TCL_PUID.."]");			 					 						
			 					if ( gUID == TCL_PUID ) then			 								 								 							
			 						if ( v[2] == true ) then		 								
									   	tcl_RecordHit(arg11, "DOT", tonumber(v[1]), "You", DAMAGE_TYPE_HEAL);
									else
										tcl_RecordHit(arg11, "DOT", tonumber(v[1]), arg8, DAMAGE_TYPE_NONHEAL);								    
									end
									removeVal = table.removekey(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[1]][arg11], arg4);
			 						tcl_DEBUG("SPELL_AURA_REMOVED [SELF]: Removed ["..removeVal[1].."] from "..arg11.." K "..arg4);
			 					end
			 				end
			 			end
		 			end			 				
		   		end
		   end
		   if ( srcType ~= nil ) then
		   		if ( arg2 == "SPELL_AURA_REFRESH" ) then			   			
		   			-- since we refreshed the spell, we need to lock down the damage store now so we do not overlap the results	 			
		 			if ( arg8 == UnitName("player") and TCL_PUID ~= nil ) then
		 				if ( TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[1]][arg11] ~= nil ) then
			 				tcl_DEBUG("AURA_REFRESH: Removing "..arg11.." from the DOT database from"..arg8);		 				
			 				for gUID,v in pairs(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[1]][arg11]) do		 						
			 					if ( gUID == TCL_PUID ) then		 								 							
			 						if ( v[2] == true ) then		 								
									   	tcl_RecordHit(arg11, "DOT", tonumber(v[1]), "You", DAMAGE_TYPE_HEAL);	
									else 
										tcl_RecordHit(arg11, "DOT", tonumber(v[1]), arg8, DAMAGE_TYPE_NONHEAL);							    
									end
									removeVal = table.removekey(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[1]][arg11], arg4);
			 						tcl_DEBUG("SPELL_AURA_REFESH [SELF]: Removed ["..removeVal[1].."] from "..arg11.." K "..arg4);
			 					end
			 				end
			 			end
		 			end									
			   end
		   end		
		elseif ( arg2 == "SPELL_SUMMON" ) then
			local isHeal = false;
			
			if ( event ~= nil ) then 
		        tcl_DEBUG("Received Event: ["..(arg2 or "none").."]");	    
		    end	 				
		    if ( arg4 == UnitName("player") ) then	    	    
				if ( TCL_DOT["DOT_DATA"][srcType][arg11] == nil ) then
					TCL_DOT["DOT_DATA"][srcType][arg11] = {};
				end			
				if ( TCL_DOT["DOT_DATA"][srcType][arg11][arg7] == nil ) then
					TCL_DOT["DOT_DATA"][srcType][arg11][arg7] = {0, isHeal};
				end
			end
			
		elseif ( arg2 == "UNIT_DIED" or arg2 == "PARTY_KILL" or arg2 == "UNIT_DESTROYED" ) then
			local removeVal, dest;
			local destID = arg7;
			
			if ( myUnit == true ) then
				destID = arg4;
			end
					
			-- check DOT table for spells that may have damaged this unit
			tcl_DEBUG("High DOT "..tcl_GetHighDMG("MY", "DOT"));
			
			if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ~= 0 ) then
				srcType = TCL_SOURCETYPE[1];
			elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 
					and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 
					and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
					srcType = TCL_SOURCETYPE[2];
			elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_GUARDIAN) == 0 and
					 bit.band(arg6, COMBATLOG_OBJECT_CONTROL_PLAYER) == 0 and
					 bit.band(arg6, COMBATLOG_OBJECT_REACTION_FRIENDLY) == 0 and
					 bit.band(arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) == 0 ) then
					 					 					 
					 -- cleaning DOT table for damage associated to this mob
					 	
					 for spellName,v in pairs(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[2]]) do							
					 	for gUID,v in pairs(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[2]][spellName]) do	
					 		removeVal = table.removekey(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[2]][spellName], gUID);
				     		if ( removeVal == nil) then
								removeVal = "nil";
					 		end
					 		tcl_DEBUG("MOB: Removed ["..removeVal[1].."] from "..spellName.." K "..gUID.." V "..v[1]);
					 	end
					 end			 
			else
				-- for now unit items like totem healing dots are not stored.
				tcl_DEBUG("arg6 : "..arg6.." is not stored.");
			end
			for i = 1, table.getn(TCL_SOURCETYPE) do
				for spellName,v in pairs(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[i]]) do							
					for gUID,v in pairs(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[i]][spellName]) do					  								 				 	
						if ( gUID == destID ) then
							tcl_DEBUG("MOB: "..spellName.." ["..v[1].."] ".." arg8 "..arg8);
							if ( arg8 == UnitName("player") ) then
								dest = "You";
							else
					    		dest = arg8;
					    	end
							if ( i == 1 ) then
							    if ( v[2] == false ) then
							    	tcl_RecordHit(spellName, "DOT", tonumber(v[1]), dest, DAMAGE_TYPE_NONHEAL);
							    else
							    	if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0") then
							       		tcl_RecordHit(spellName, "DOT", tonumber(v[1]), dest, DAMAGE_TYPE_HEAL);
							       	end
							    end
							else
								if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "1" ) then
									if ( v[2] == false ) then
										tcl_RecordHit(spellName, "DOT", tonumber(v[1]), dest, DAMAGE_TYPE_NONHEAL, "PET");
									else
										if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0") then
											tcl_RecordHit(spellName, "DOT", tonumber(v[1]), dest, DAMAGE_TYPE_HEAL, "PET");
										end
									end
								end
							end						
							removeVal = table.removekey(TCL_DOT["DOT_DATA"][TCL_SOURCETYPE[i]][spellName], gUID);
							if ( removeVal == nil) then
								removeVal = "nil";
							end
							tcl_DEBUG("MOB: Removed ["..removeVal[1].."] from "..spellName.." K "..gUID.." V "..v[1]);
						end					
					end
				end
			end				
		elseif ( arg2 == "SPELL_PERIODIC_HEAL" ) then  --for DOT Heal spells			
			local oDOT, nTotal;
			local destID = arg7;
			local temp = "FALSE";
			
			if ( myUnit == true ) then
				destID = arg4;
			end
			if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0") then
				if ( arg5 == UnitName("player") ) then
					if ( TCL_DOT["DOT_DATA"][srcType][arg11] ~= nil ) then
						if ( TCL_DOT["DOT_DATA"][srcType][arg11][destID] ~= nil ) then
							if ( TCL_DOT["DOT_DATA"][srcType][arg11][destID][2] == true ) then
								temp = "TRUE";
							end		
							tcl_DEBUG(" SPHeal "..arg11.." : {"..TCL_DOT["DOT_DATA"][srcType][arg11][destID][1]..", "..temp.."}");
						end	
					end
				end
											 					
				if ( srcType ~= nil ) then
					if ( TCL_DOT["DOT_DATA"][srcType][arg11] == nil ) then
						tcl_DEBUG("TCL_DOT Table: ["..srcType.."]["..arg11.."] does not exist...Creating");
						TCL_DOT["DOT_DATA"][srcType][arg11] = {}
					end
					if ( TCL_DOT["DOT_DATA"][srcType][arg11][destID] == nil ) then
						tcl_DEBUG("TCL_DOT Table: ["..srcType.."]["..arg11.."]["..destID.."] does not exist...Creating");
						TCL_DOT["DOT_DATA"][srcType][arg11][destID] = {0, true};
					elseif ( TCL_DOT["DOT_DATA"][srcType][arg11][destID][2] == false ) then -- check to see of named periodic heal was set to false
						tcl_DEBUG("TCL_DOT Table: ["..srcType.."]["..arg11.."]["..destID.."][2] was set to false, set to true");
						TCL_DOT["DOT_DATA"][srcType][arg11][destID][2] = true;					
					end
					oDOT = TCL_DOT["DOT_DATA"][srcType][arg11][destID];
					nTotal = oDOT[1] + arg13;
					
					tcl_DEBUG("DOT Heal for ["..arg11.."] is "..oDOT[1].." new stored heal is "..nTotal);
					if ( TCL_DOT["DOT_DATA"][srcType][arg11][destID] ~= nil ) then
						TCL_DOT["DOT_DATA"][srcType][arg11][destID][1] = nTotal;
					end
				end	
		    end		
		-- All Misses
		elseif ( arg2 == "SPELL_PERIODIC_DAMAGE" ) then  --for DOT Damage spells
			local oDOT, nTotal;
			local temp = "FALSE";
			if ( arg5 == UnitName("player") ) then
				if ( TCL_DOT["DOT_DATA"][srcType][arg11] ~= nil ) then
					if ( TCL_DOT["DOT_DATA"][srcType][arg11][arg7] ~= nil ) then
						if ( TCL_DOT["DOT_DATA"][srcType][arg11][arg7][2] == true ) then
							temp = "TRUE";				
						end		
						tcl_DEBUG(" SPDamage "..arg11.." : {"..TCL_DOT["DOT_DATA"][srcType][arg11][arg7][1]..", "..temp.."}");	
					end
				end
			end
											
			if ( srcType ~= nil ) then
				if ( TCL_DOT["DOT_DATA"][srcType][arg11] == nil ) then
					TCL_DOT["DOT_DATA"][srcType][arg11] = {};
			    end
				if ( TCL_DOT["DOT_DATA"][srcType][arg11][arg7] == nil ) then
					TCL_DOT["DOT_DATA"][srcType][arg11][arg7] = {0, false};
				elseif ( TCL_DOT["DOT_DATA"][srcType][arg11][arg7][2] == true ) then
					TCL_DOT["DOT_DATA"][srcType][arg11][arg7][2] = false;
				end
				oDOT = TCL_DOT["DOT_DATA"][srcType][arg11][arg7];
				nTotal = oDOT[1] + arg13;
				
				tcl_DEBUG("DOT Damage for ["..arg11.."] is "..oDOT[1].." new stored damage is "..nTotal);
				if ( TCL_DOT["DOT_DATA"][srcType][arg11][arg7] ~= nil ) then
					TCL_DOT["DOT_DATA"][srcType][arg11][arg7][1] = nTotal;
				end
			end			
		elseif ( arg2 == "SPELL_CAST_FAILED" or 
			 arg2 == "SPELL_MISSED" or 
			 arg2 == "SWING_MISSED" or 
			 arg2 == "SPELL_PERODIC_MISSED" or 
			 arg2 == "RANGE_MISSED" ) then
			missType = arg11 or "Normal Hit";
			if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ~= 0 ) then 
				tcl_RecordMiss(missType);
			elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0 
				and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0 
				and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
				tcl_RecordMiss(arg5.."'s "..missType, "PET");
			end
--		elseif ( arg2 == "PARTY_KILL" ) then
--				tcl_Msg("I killed "..(destName or "UNKNOWN"));
		else
--			local timestamp, eventtype, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags = ...;
			local toPlayer, fromPlayer, toPet, fromPet, toTarget;
 --       
--			if (sourceName and not CombatLog_Object_IsA(sourceFlags, COMBATLOG_OBJECT_NONE) ) then
--			  fromPlayer = CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MINE);
--			  fromPet = CombatLog_Object_IsA(sourceFlags, COMBATLOG_FILTER_MY_PET);
--			end
--
--			if (destName and not CombatLog_Object_IsA(destFlags, COMBATLOG_OBJECT_NONE) ) then
--			  toPlayer = CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MINE);
--			  toPet = CombatLog_Object_IsA(destFlags, COMBATLOG_FILTER_MY_PET);
--			  toTarget = CombatLog_Object_IsA(destFlags, COMBATLOG_OBJECT_TARGET);
--			end

 --                       if eventtype == "PARTY_KILL" and fromPlayer then
--				tcl_Msg("I killed "..destName);
--			end

			local showMsg = 0;
						
			--tcl_DEBUG("Received Event: ["..(arg2 or "none").."]");
			local dmg = arg13 or "none";
			local trg = arg8 or "none";
			local src = arg5 or "none";
			if ( arg11 ) then
				if ( showMsg == 1 ) then
					tcl_Msg("SPELL: "..arg11.." S: ["..src.."]T: ["..trg.."] DMG: ["..dmg.."]");
				end
				tcl_DEBUG("SPELL: "..arg11.." S: ["..src.."]T: ["..trg.."] DMG: ["..dmg.."]");
			end
			if ( arg2 == "UNIT_DIED" ) then
				if ( showMsg == 1 ) then
	 				tcl_Msg("UNIT INFO: ");
					tcl_Msg("   arg1: "..(arg1 or "none")); 
					tcl_Msg("   arg2: "..(arg2 or "none")); 
					tcl_Msg("   arg3: "..(arg3 or "none")); 
					tcl_Msg("   arg4: "..(arg4 or "none")); 
				end
			end
		end
	end
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
			realm = GetCVar("realmName").."."..UnitName("player");
			if (dbName[realm] == nil) then
				realm = TCL_REALM;
				if (dbName[realm] == nil ) then 
					tcl_Msg("Old Titan CritLine database found, but not for "..UnitName("player")..", creating new one.");
				end
			end

			if (dbName[realm] ~= nil ) then
				if ( table.getn(TCL_SETTINGS[realm]["DATA"]) == nil or table.getn(TCL_SETTINGS[realm]["DATA"]) == 0 ) then
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
				if ( table.getn(TCL_SETTINGS[TCL_REALM]["DATA"]) == nil or table.getn(TCL_SETTINGS[TCL_REALM]["DATA"]) == 0 ) then
					tcl_Msg("Updating old Titan CritLine data ...");
					for k,v in pairs(TCL_SETTINGS[TCL_REALM]["SETTINGS"]) do
						dbName[TCL_REALM]["SETTINGS"][k] = v;
					end
					for i = 1, table.getn(TCL_SOURCETYPE) do
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
		for i = 1, table.getn(TCL_SOURCETYPE) do
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
    for i = 1, table.getn(TCL_SOURCETYPE) do
   	 if (tab["DOT_DATA"][TCL_SOURCETYPE[i]] == nil) then
			tab["DOT_DATA"][TCL_SOURCETYPE[i]] = {};
		end	
	end
    tcl_DEBUG("Initialize DOT Table Complete.");    
end

function tcl_Initialize(tcl_Table)
    local tab = tcl_Table or TCL_SETTINGS;

	tcl_DEBUG("Initializing...");
	--TCL_REALM = GetCVar("realmName");
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
	if (tab[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == nil) then
 		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"];
		else 
			tab[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["LVLADJ"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["LVLADJ"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"];
		else 
			tab[TCL_REALM]["SETTINGS"]["LVLADJ"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SPLASH"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SPLASH"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SPLASH"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["PVPONLY"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["PVPONLY"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"];
		else 
			tab[TCL_REALM]["SETTINGS"]["PVPONLY"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["PLAYSOUND"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["PLAYSOUND"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"];
		else 
			tab[TCL_REALM]["SETTINGS"]["PLAYSOUND"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SNAPSHOT"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SNAPSHOT"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SNAPSHOT"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SHOWCRIT"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWCRIT"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHOWCRIT"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWCRIT"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHOWCRIT"] = "1";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["SHOWHITS"] == nil ) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWHITS"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHOWHITS"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWHITS"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHOWHITS"] = "1";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["ONCLICK"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["ONCLICK"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ONCLICK"];
		else 
			tab[TCL_REALM]["SETTINGS"]["ONCLICK"] = "0";
		end
	end
	if (tab[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] == nil) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHIFTONCLICK"] = "0";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] == nil ) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOB"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["FILTER_MOB"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOB"];
		else 
			tab[TCL_REALM]["SETTINGS"]["FILTER_MOB"] = "0";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["SHOW_PET"] == nil ) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["SHOW_PET"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"];
		else 
			tab[TCL_REALM]["SETTINGS"]["SHOW_PET"] = "0";
		end
	end
	if ( tab[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] == nil ) then
		if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] ~= nil) then
			tab[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] = TCL_SETTINGS[TCL_REALM]["SETTINGS"]["ALL_SPELLS"];
		else 
			tab[TCL_REALM]["SETTINGS"]["ALL_SPELLS"] = "0";
		end
	end
	if (tab[TCL_REALM]["DATA"] == nil) then
		tab[TCL_REALM]["DATA"] = {};
	end
	for i = 1, table.getn(TCL_SOURCETYPE) do
		if (tab[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]] == nil) then
			tab[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]] = {};
		end
	end
	tcl_DEBUG("Initialization Complete.");
end

function tcl_CreateMobFilter()
	tcl_DEBUG("Creating Mob Filter...");
	table.insert(TCL_MOBFILTER, TITAN_CRITLINE_MOBFILTER_01);
	table.insert(TCL_MOBFILTER, TITAN_CRITLINE_MOBFILTER_02);
	table.insert(TCL_MOBFILTER, TITAN_CRITLINE_MOBFILTER_03);
	table.insert(TCL_MOBFILTER, TITAN_CRITLINE_MOBFILTER_04);
	table.insert(TCL_MOBFILTER, TITAN_CRITLINE_MOBFILTER_05);
	tcl_DEBUG("Creation complete.");
end

function tcl_IsMobInFilter(mobname)
	local returnvalue = false;
	for k, v in pairs(TCL_MOBFILTER) do
		if ( v == mobname ) then
			tcl_DEBUG("Name of Mob ("..mobname..") is in Filter ...");
			returnvalue = true;
			do break end;
		end
	end
	tcl_DEBUG("Name of Mob ("..mobname..") is NOT in Filter ...");
	return returnvalue;
end

function tcl_DeleteAllRecordsWithMobsInFilter()
	tcl_DEBUG("Search for filtered mobs and delete them ...");
	for attackType, v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"]) do
		for hitType, v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][attackType]) do
			if ( hitType == "CRIT" or hitType == "NORMAL" ) then
				if ( tcl_IsMobInFilter(TCL_SETTINGS[TCL_REALM]["DATA"][attackType][hitType]["Target"]) ) then
					tcl_DEBUG("Mob found, backup stats ...");
					local filtered = "FILTER_"..hitType;
					local backup = "OLD_"..hitType;
					TCL_SETTINGS[TCL_REALM]["DATA"][attackType][filtered] = {};
					TCL_SETTINGS[TCL_REALM]["DATA"][attackType][filtered] = TCL_SETTINGS[TCL_REALM]["DATA"][attackType][hitType];
					if ( TCL_SETTINGS[TCL_REALM]["DATA"][attackType][backup] == nil ) then
						table.remove(TCL_SETTINGS[TCL_REALM]["DATA"][attackType], hitType);
					else
						TCL_SETTINGS[TCL_REALM]["DATA"][attackType][hitType] = TCL_SETTINGS[TCL_REALM]["DATA"][attackType][backup];
					end
				end
			end
		end
	end
	tcl_DEBUG("All filtered mobs deleted if found.");
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_RestoreAllRecordsWithMobsInFilter()
	tcl_DEBUG("Restore all records with filtered mobs ...");
	for attackType, v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"]) do
		for hitType, v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][attackType]) do
			if ( hitType == "CRIT" or hitType == "NORMAL" ) then
				if ( tcl_IsMobInFilter(TCL_SETTINGS[TCL_REALM]["DATA"][attackType][hitType]["Target"]) ) then
					tcl_DEBUG("Mob found, restoring stats ...");
					local filtered = "FILTER_"..hitType;
					local backup = "OLD_"..hitType;
					if ( TCL_SETTINGS[TCL_REALM]["DATA"][attackType][filtered] ~= nil ) then
						if ( TCL_SETTINGS[TCL_REALM]["DATA"][attackType][backup] == nil ) then
							TCL_SETTINGS[TCL_REALM]["DATA"][attackType][backup] = {};
							TCL_SETTINGS[TCL_REALM]["DATA"][attackType][backup] = TCL_SETTINGS[TCL_REALM]["DATA"][attackType][hitType];
						end
						TCL_SETTINGS[TCL_REALM]["DATA"][attackType][hitType] = TCL_SETTINGS[TCL_REALM]["DATA"][attackType][filtered];
					end
				end
			end
		end
	end
	tcl_DEBUG("All records with filtered mobs are restored.");
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_RecordHit(AttackType, HitType, Damage, uname, IsHealing, sourceType)
	local targetlvl = UnitLevel("target");
	local source = sourceType or TCL_SOURCETYPE[1];
	local ulevel = false;
	if (targetlvl == nil) then 
		targetlvl = 0;
	end
	if (TRACK_DMG == false ) then
		tcl_DEBUG("TCL Record Hit disabled!  exiting...");
		return;
	end
	
	if ((Damage == nil) or (Damage < 1) ) then
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
	if ( (UnitIsPlayer("target") ~= 1) and (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PVPONLY"] == "1") ) then
		tcl_DEBUG("Target !=player and PvPOnly enabled, exiting...");
		return;
	end
	local leveldiff = 0;
	if (UnitLevel("player") < UnitLevel("target")) then
		leveldiff = (UnitLevel("target") - UnitLevel("player"));
	else
		leveldiff = (UnitLevel("player") - UnitLevel("target"));
	end
	tcl_DEBUG("Level difference: "..leveldiff);
	if ( (tonumber(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"]) ~= 0) and (tonumber(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["LVLADJ"]) < leveldiff) ) then
		tcl_DEBUG("Target level too low and LvlAdj enabled, exiting...");
		return;
	end
	if (TCL_SETTINGS == nil) then
		return;
	end
	if (TCL_SETTINGS[TCL_REALM] == nil) then
		tcl_DEBUG("TCL_SETTINGS[TCL_REALM] should not be nil at this point!");
		tcl_Initialize();
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"] == nil) then
		tcl_DEBUG("TCL_SETTINGS[TCL_REALM][DATA] should not be nil at this point!");
		tcl_Initialize();
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"][source] == nil) then
		tcl_DEBUG("TCL_SETTINGS[TCL_REALM][DATA][SOURCETYPE] should not be nil at this point!");
		tcl_Initialize();
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType] == nil) then
		tcl_DEBUG("Creating TCL_SETTINGS["..TCL_REALM.."][DATA][source]["..AttackType.."]...");
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType] = {};
	end
	if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType]["Filter"] == nil ) then
		tcl_DEBUG("Creating TCL_SETTINGS["..TCL_REALM.."][DATA][source]["..AttackType.."][Filter]...");
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType]["Filter"] = "0";
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType] == nil) then
		tcl_DEBUG("Creating TCL_SETTINGS["..TCL_REALM.."][DATA][source]["..AttackType.."]["..HitType.."]...");
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType] = {};
	end
	if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Value"] == nil ) then
		tcl_DEBUG("Creating TCL_SETTINGS["..TCL_REALM.."][DATA][source]["..AttackType.."]["..HitType.."][Value]...");
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Value"] = 0;
	end
	local oldhitvalue = TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Value"];
	TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Value"] = oldhitvalue + 1;
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_MOBS"] == "1" ) then
		if ( tcl_IsMobInFilter(uname) ) then
			return;
		end
	end
	if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Damage"] == nil or TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Damage"] < Damage ) then
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Damage"] = Damage;
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Target"] = uname;
		if ( ulevel ) then
			TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Level"] = ulevel;
		else
			TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Level"] = UnitLevel("target");
		end
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["Date"] = date();
		TCL_SETTINGS[TCL_REALM]["DATA"][source][AttackType][HitType]["IsHeal"] = IsHealing;
		if ( Damage > 0 ) then
			tcl_DisplayNewRecord(AttackType, Damage, HitType);
		end
	end
end

function tcl_RecordMiss(text, sourceType )
	local source = sourceType or TCL_SOURCETYPE[1];
	if ( text == nil ) then
		tcl_DEBUG("RecordMiss text value is nil, return.");
		return;
	end
	if ( string.find(text, "(%d+)") ) then
		tcl_DEBUG("RecordMiss found a number in text, return.");
		return;
	else
		for attackType, v in pairs(TCL_SETTINGS[TCL_REALM]["DATA"][source]) do
			if ( string.find(text, attackType) ) then
				tcl_DEBUG("RecordMiss found "..attackType.." in text, add a miss and return.");
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][attackType]["Misses"] == nil ) then
					TCL_SETTINGS[TCL_REALM]["DATA"][source][attackType]["Misses"] = 1;
					do return end;
				else
					local oldvalue = TCL_SETTINGS[TCL_REALM]["DATA"][source][attackType]["Misses"];
					TCL_SETTINGS[TCL_REALM]["DATA"][source][attackType]["Misses"] = oldvalue + 1;
					do return end;
				end
			end
		end
		tcl_DEBUG("RecordMiss found no attackType in text.");
		if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][NORMAL_HIT_TEXT] == nil ) then
			tcl_DEBUG("RecordMiss creating TCL_SETTINGS["..TCL_REALM.."][DATA]["..NORMAL_HIT_TEXT.."].");
			TCL_SETTINGS[TCL_REALM]["DATA"][source][NORMAL_HIT_TEXT] = {};
		end
		if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][NORMAL_HIT_TEXT]["Misses"] == nil ) then
			tcl_DEBUG("RecordMiss creating TCL_SETTINGS["..TCL_REALM.."][DATA]["..NORMAL_HIT_TEXT.."][Misses] = 1.");
			TCL_SETTINGS[TCL_REALM]["DATA"][source][NORMAL_HIT_TEXT]["Misses"] = 1;
			return;
		else
			tcl_DEBUG("RecordMiss add a miss to "..NORMAL_HIT_TEXT..".");
			local oldvalue = TCL_SETTINGS[TCL_REALM]["DATA"][source][NORMAL_HIT_TEXT]["Misses"];
			TCL_SETTINGS[TCL_REALM]["DATA"][source][NORMAL_HIT_TEXT]["Misses"] = oldvalue + 1;
			return;
		end
	end
	tcl_DEBUG("RecordMiss found nothing and return.");
end

function tcl_DisplayNewRecord(AttackType, DamageAmount, HitType)
	local splash_msg = TITAN_CRITLINE_NEW_RECORD_MSG;
	if ( HitType == "CRIT" ) then
		splash_msg = TITAN_CRITLINE_NEW_CRIT_RECORD_MSG;
	elseif ( HitType == "DOT" ) then
		splash_msg = TITAN_CRITLINE_NEW_DOT_RECORD_MSG;
	end
	tcl_DEBUG(format(splash_msg, AttackType));
	if(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SPLASH"] == "1") then
		TitanCritLineSplashFrame:AddMessage(DamageAmount, 1, 1, 1, 1, 3);
		TitanCritLineSplashFrame:AddMessage(format(splash_msg, AttackType), 1, 1, 0, 1, 3);
	end
	if(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["PLAYSOUND"] == "1") then 
		PlaySound("LEVELUP", 1, 1, 0, 1, 3); 
	end
	if(TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SNAPSHOT"] == "1") then 
		TakeScreenshot(); 
	end
	TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
end

function tcl_GetHighDMG( sourceType, dmgType, healType )
	local source = sourceType or TCL_SOURCETYPE[1];
	local dmg = dmgType or "NORMAL";
	local isHeal = healType or "0";
	local highDMG = 0;
	local attackType = "";
	local enemyInfo = "";

	if (TCL_SETTINGS == nil) then
		return highDMG;
	end
	if (TCL_SETTINGS[TCL_REALM] == nil) then
		return highDMG;
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"] == nil) then
		return highDMG;
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"][source] == nil) then
		return highDMG;
	end
	for tempAttack,v in pairs (TCL_SETTINGS[TCL_REALM]["DATA"][source]) do 
		if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][tempAttack]["Filter"] == "0" ) then 
			if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][tempAttack][dmg] ~= nil ) then 
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][tempAttack][dmg]["IsHeal"] == isHeal ) then 
					if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][tempAttack][dmg]["Damage"] > highDMG ) then
						highDMG = TCL_SETTINGS[TCL_REALM]["DATA"][source][tempAttack][dmg]["Damage"];
						attackType = tempAttack;
						enemyInfo = TCL_SETTINGS[TCL_REALM]["DATA"][source][tempAttack][dmg]["Target"]..
							" ("..TCL_SETTINGS[TCL_REALM]["DATA"][source][tempAttack][dmg]["Level"]..")";
					end
				end
			end
		else
			if ( isHeal == "0" ) then 
				tcl_DEBUG(attackType.." Filter enabled, did not process for highest "..dmg.." Hit.");
			else
				tcl_DEBUG(attackType.." Filter enabled, did not process for highest "..dmg.." Heal.");
			end
		end
	end
	return highDMG, attackType, enemyInfo;
end

function tcl_GetHighestCritPercentage( mysource )
	local critperc; 
	local crithits = 0;
	local normhits = 0;
	local hiperc = 0;
	local attack = "";
	local source = mysource or TCL_SOURCETYPE[1];
	tcl_DEBUG("Using source "..source);
	
	if (TCL_SETTINGS == nil) then 
		return hiperc;
	end
	if (TCL_SETTINGS[TCL_REALM] == nil) then
		return hiperc;
	end
	if (TCL_SETTINGS[TCL_REALM]["DATA"] == nil) then
		return hiperc;
	end
	for k,v in pairs (TCL_SETTINGS[TCL_REALM]["DATA"][source]) do
		if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][k]["Filter"] == "0" ) then
			if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][k]["NORMAL"] ~= nil ) then
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][k]["NORMAL"]["IsHeal"] == "0") then
					normhits = TCL_SETTINGS[TCL_REALM]["DATA"][source][k]["NORMAL"]["Value"];
				end
			else
				normhits = 0;
			end
			if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][k]["CRIT"] ~= nil ) then
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][source][k]["CRIT"]["IsHeal"] == "0") then
					crithits = TCL_SETTINGS[TCL_REALM]["DATA"][source][k]["CRIT"]["Value"];
				end
			else
				crithits = 0;
			end
			if ( crithits == 0 or normhits == 0 ) then
				critperc = 0;
			else
				critperc = crithits / ( ( crithits + normhits ) / 100 );
				if ( hiperc == 0 ) then
					hiperc = critperc;
				end
			end
			tcl_DEBUG(k.." critical percentage: "..critperc);
			if ( critperc > hiperc ) then
				tcl_DEBUG("Crit%: "..critperc.." > ".." Hi% :"..hiperc);
				hiperc = critperc;
				attack = k;
				tcl_DEBUG(attack.." crit of "..hiperc.." is now the best!");
			end
		else
			tcl_DEBUG(k.." Filter is on, did not recognized for highest CRIT percentage");
		end
	end
	return format("%.2f", hiperc), attack;
end

--[[ tooltip functions ]]
function tcl_DisplayDialog(message)
	GameTooltip:SetText(message);
	GameTooltip:Show();
end

function tcl_GenToolDMG(dbSource, hitType, hidmg, dmgperc, hidmgperc)
	local dmg = "";
	local hiperc = hidmgperc or 0;
	local textType = "";
		
    if ( hitType == "NORMAL" ) then
		textType = NORMAL_TEXT;
	elseif ( hitType == "CRIT" ) then
		textType = CRIT_TEXT;
	elseif ( hitType == "DOT" ) then
		textType = DOT_TEXT;
	end
	
	dmg = dmg.."  "..COLOR(SUBHEADER_TEXT_COLOR, textType).." [";
	if (dbSource[hitType]["IsHeal"] == "0") then		
		if (dbSource[hitType]["Damage"] == hidmg) then
			dmg = dmg..COLOR(HINT_TEXT_COLOR, dbSource[hitType]["Damage"]).."]";
		else
			dmg = dmg..COLOR(BODY_TEXT_COLOR, dbSource[hitType]["Damage"]).."]";
		end
	else
		if (dbSource[hitType]["Damage"] == hidmg) then
			dmg = dmg..COLOR(HEAL_TEXT_COLOR, dbSource[hitType]["Damage"]).."]";
		else
			dmg = dmg..COLOR(BODY_TEXT_COLOR, dbSource[hitType]["Damage"]).."]";
		end
	end
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWCRIT"] == "1" ) then
		if ( dmgperc == hiperc ) then
			if ( dbSource[hitType]["IsHeal"] == "0" ) then 
				dmg = dmg.." ["..COLOR(HINT_TEXT_COLOR, dmgperc.."%").."]\t";
			else
				dmg = dmg.." ["..COLOR(HEAL_TEXT_COLOR, dmgperc.."%").."]\t";
			end
		else
			dmg = dmg.." ["..COLOR(BODY_TEXT_COLOR, dmgperc.."%").."]\t";
		end
	else
		dmg = dmg.."\t";
	end
	if (dbSource[hitType]["Level"] == -1) then
		dmg = dmg..COLOR(BODY_TEXT_COLOR, dbSource[hitType]["Target"]).." ["..COLOR(BODY_TEXT_COLOR, "??").."]\n";
	else
		dmg = dmg..COLOR(BODY_TEXT_COLOR, dbSource[hitType]["Target"]).." ["..COLOR(BODY_TEXT_COLOR, dbSource[hitType]["Level"]).."]\n";
	end
	return dmg
end

function tcl_GetSummaryRichText()
	local rtfAttack="";
	local line = "    -------------------------------------------------------------------  \n";
	for i = 1, table.getn(TCL_SOURCETYPE) do
		local hicrit = tcl_GetHighDMG(TCL_SOURCETYPE[i], "CRIT");
		local hicritperc = tcl_GetHighestCritPercentage(TCL_SOURCETYPE[i]);	
		local hidmg = tcl_GetHighDMG(TCL_SOURCETYPE[i]);
		local hihealcrit = tcl_GetHighDMG(TCL_SOURCETYPE[i], "CRIT", "1");
		local hihealdmg = tcl_GetHighDMG(TCL_SOURCETYPE[i], "NORMAL", "1");
		local hidot = tcl_GetHighDMG(TCL_SOURCETYPE[i], "DOT");
		local hihealdot = tcl_GetHighDMG(TCL_SOURCETYPE[i], "DOT", "1");
		
		
		if ( TCL_SOURCETYPE[i] == "MY") then
			rtfAttack = rtfAttack..COLOR(HEADER_TEXT_COLOR, TCL_SOURCETYPE[i].." DAMAGE").."\n";
			rtfAttack = rtfAttack..line;
		end
		if ( TCL_SOURCETYPE[i] == "PET" ) then
			if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOW_PET"] == "1" ) then 
				rtfAttack = rtfAttack..COLOR(HEADER_TEXT_COLOR, TCL_SOURCETYPE[i].." DAMAGE").."\n";
				rtfAttack = rtfAttack..line;
			else
				break;
			end
		end
		for attackType,v in pairs (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]]) do
			if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["Filter"] == "0" ) then
				local crithits, dothits, normhits, critperc, dotperc, normperc;
				local normAtk = "";
				local critAtk = "";
				local dotAtk = "";
				
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["CRIT"] == nil) then
					crithits = 0;
				else
					if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["CRIT"]["Value"] == nil) then
						crithits = 0;
					else
						crithits = TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["CRIT"]["Value"];
					end
				end
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["DOT"] == nil) then
					dothits = 0;
				else
					if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["DOT"]["Value"] == nil) then
						dothits = 0;
					else
						dothits = TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["DOT"]["Value"];
					end
				end
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["NORMAL"] == nil) then
					normhits = 0;
				else
					if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["NORMAL"]["Value"] == nil) then
						normhits = 0;
					else
						normhits = TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["NORMAL"]["Value"];
					end
				end
				local allhits = normhits + crithits + dothits;
				
				if ( crithits == 0 ) then
					critperc = 0;
				else
					critperc = format("%.2f", crithits / ( allhits / 100 ) );					
				end
				if ( dothits == 0 ) then
					dotperc = 0;
				else
					dotperc = format("%.2f", dothits / ( allhits / 100 ) );
				end
				if ( normhits == 0 ) then
					normperc = 0;
				else
					normperc = format("%.2f", normhits / ( allhits / 100 ) );
				end
				local allmisses;
				if ( TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["Misses"] == nil) then
					allmisses = 0;
				else
					allmisses = TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]["Misses"];
				end
				local allswings = allmisses + allhits;
				local hitperc = format("%.2f", allhits / ( allswings / 100 ) );
				if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["SHOWHITS"] == "1" ) then
					rtfAttack = rtfAttack..COLOR(HEADER_TEXT_COLOR, attackType).."\t "..COLOR(HEADER_TEXT_COLOR, allhits).." "..HIT_TEXT.." ("..COLOR(HEADER_TEXT_COLOR, hitperc.." %")..")\n";
				else
					rtfAttack = rtfAttack..COLOR(HEADER_TEXT_COLOR, attackType).."\n";
				end
				for hitType,v in pairs (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType]) do
					if (hitType == "NORMAL") then 
						local normOrHeal = hidmg;
						if  (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType]["IsHeal"] == "1") then
							normOrHeal = hihealdmg;
						end
						normAtk = tcl_GenToolDMG(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType], hitType, normOrHeal, normperc, 0);
					elseif ( hitType == "CRIT" ) then
						local normOrHeal = hicrit;
						if  (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType]["IsHeal"] == "1") then
							normOrHeal = hihealcrit;
						end		
						critAtk = tcl_GenToolDMG(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType], hitType, normOrHeal, critperc, hicritperc);						
					elseif ( hitType == "DOT" ) then
						local normOrHeal = hidot;
						if  (TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType][hitType]["IsHeal"] == "1") then
							normOrHeal = hihealdot;
						end
						dotAtk = tcl_GenToolDMG(TCL_SETTINGS[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]][attackType], hitType, normOrHeal, dotperc, 0);
					end
				end
				rtfAttack = rtfAttack..normAtk..critAtk..dotAtk;
			end
		end
		rtfAttack = rtfAttack..line;
	end
	return rtfAttack
end

function tcl_GetAboutRichText()
	return 
		COLOR(HEADER_TEXT_COLOR, TITAN_CRITLINE_ID.." v"..TITAN_CRITLINE_VERSION).."\n\n"..
		COLOR(SUBHEADER_TEXT_COLOR, "Developers: ").."\n\n"..
		COLOR(BODY_TEXT_COLOR, "Sordit: Concept and Stand-Alone version").."\n"..
		COLOR(BODY_TEXT_COLOR, "Uggh: Titan Panel version < 0.3.7").."\n"..
		COLOR(BODY_TEXT_COLOR, "Falli: Titan Panel version > 0.3.7").."\n"..
		COLOR(BODY_TEXT_COLOR, "AidenK: Titan Panel version > 0.4.0e").."\n"..
		COLOR(BODY_TEXT_COLOR, "Lowpinger: Titan Panel version > 0.4.1").."\n".. 
		COLOR(BODY_TEXT_COLOR, "Penddor: Titan Panel version > 0.4.5");
end

--[[ chat functions ]]
function tcl_PostMessage(message_array,channel)
	if ( message_array == nil or type(message_array) ~= "table") then
		message_array = tcl_GetRecordChatText();
	end
	if ( channel == nil ) then
		channel = "GUILD";
		if ( GetNumPartyMembers() > 0 ) then
			channel = "PARTY";
		end
		if ( GetNumRaidMembers() > 0 ) then
			channel = "RAID";
		end
	end
	table.foreach(message_array, function(k,v) SendChatMessage(v, channel); end);
end

function tcl_PostToRaid()
	if ( GetNumRaidMembers ~= 0 ) then
		tcl_PostMessage(tcl_GetRecordChatText(),"RAID")
	else
		tcl_PostMessage(tcl_GetRecordChatText())
	end
end

function tcl_PostToParty()
	if ( GetNumPartyMembers ~= 0 ) then
		tcl_PostMessage(tcl_GetRecordChatText(),"PARTY")
	else
		tcl_PostMessage(tcl_GetRecordChatText())
	end
end

function tcl_PostToGuild()
	local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
	if ( guildName ) then
		tcl_PostMessage(tcl_GetRecordChatText(),"GUILD")
	else
		local message_array = tcl_GetRecordChatText();
		table.foreach(message_array, function(k,v) tcl_Msg(v); end);
	end
end

function tcl_GetRecordChatText()
	local hicrit, acrit, ecrit = tcl_GetHighDMG("MY", "CRIT");
	local hidmg, anormal, enormal = tcl_GetHighDMG();
	local hihealcrit, hcrit, ehcrit = tcl_GetHighDMG("MY", "CRIT", "0");
	local hihealdmg, hnormal, ehnormal = tcl_GetHighDMG("MY", "NORMAL", "1");
	local hihealdot, hdot, ehdot = tcl_GetHighDMG("MY", "DOT", "1");	
	local hidot, adot, edot = tcl_GetHighDMG("MY", "DOT");
	
	local text = {};
	table.insert(text, TITAN_CRITLINE_ID.." "..RECORDS_TEXT..":");
	table.insert(text, CRIT_TEXT..": "..acrit.." ("..hicrit..")".." ["..ecrit.."]");
	table.insert(text, DOT_TEXT..": "..adot.." ("..hidot..")".." ["..edot.."]");
	table.insert(text, NORMAL_TEXT..": "..anormal.." ("..hidmg..")".." ["..enormal.."]");
	if ( TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0" ) then
		if ( hihealcrit > 0 ) then
			table.insert(text, CRIT_TEXT..": "..hcrit.." ("..hihealcrit..")".." ["..ehcrit.."]");
		end
		if ( hihealdot > 0 ) then
			table.insert(text, NORMAL_TEXT..": "..hdot.." ("..hihealdot..")".." ["..ehdot.."]");
		end
		if ( hihealdmg > 0 ) then
			table.insert(text, NORMAL_TEXT..": "..hnormal.." ("..hihealdmg..")".." ["..ehnormal.."]");
		end
	end
	return text;
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
