local addon = TitanCritLine;

function tcl_About()
	if (TitanCritLine_AboutFrame:IsVisible()) then
		tcl_AboutClose();
		return;
	end

	TitanCritLine_AboutFrame_Text:SetText(tcl_GetAboutRichText());
	TitanCritLine_AboutFrame_History:SetText(tcl_GetAboutHistoryRichText());
	addon.ApplyDialogBackdrop(TitanCritLine_AboutFrame);
	TitanCritLine_AboutFrame:Show();
end

function tcl_AboutClose()
	TitanCritLine_AboutFrame:Hide();
	TitanPanelButton_UpdateButton(addon.ID);
end

function tcl_GetAboutRichText()
	return
		COLOR(addon.COLORS.HEADER, addon.ID.." v"..addon.VERSION).."\n\n"..
		COLOR(addon.COLORS.SUBHEADER, "Current maintainer:").."\n"..
		COLOR(addon.COLORS.BODY, "Epyc").."\n"..
		COLOR(addon.COLORS.SUBHEADER, "Titan Panel baseline:").."\n"..
		COLOR(addon.COLORS.BODY, "9.3.2");
end

function tcl_GetAboutHistoryRichText()
	return
		COLOR(addon.COLORS.SUBHEADER, "History:").."\n"..
		COLOR(addon.COLORS.BODY, "Sordit: Concept and Stand-Alone version").."\n"..
		COLOR(addon.COLORS.BODY, "Uggh: Titan Panel version < 0.3.7").."\n"..
		COLOR(addon.COLORS.BODY, "Falli: Titan Panel version > 0.3.7").."\n"..
		COLOR(addon.COLORS.BODY, "AidenK: Titan Panel version > 0.4.0e").."\n"..
		COLOR(addon.COLORS.BODY, "Lowpinger: Titan Panel version > 0.4.1").."\n"..
		COLOR(addon.COLORS.BODY, "Penddor: Titan Panel version > 0.4.5");
end
