local addon = TitanCritLine;
local TCL_REALM = addon:GetRealmKey();
local TCL_SOURCETYPE = addon.SOURCE_TYPES;
local HEADER_TEXT_COLOR = addon.COLORS.HEADER;
local SUBHEADER_TEXT_COLOR = addon.COLORS.SUBHEADER;
local BODY_TEXT_COLOR = addon.COLORS.BODY;
local HEAL_TEXT_COLOR = addon.COLORS.HEAL;
local HINT_TEXT_COLOR = addon.COLORS.HINT;
local DAMAGE_TYPE_HEAL = addon.DAMAGE_TYPE_HEAL;
local HOT_TEXT = addon.HOT_TEXT;

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
		if (dbSource[hitType]["IsHeal"] == DAMAGE_TYPE_HEAL) then
			textType = HOT_TEXT;
		else
			textType = DOT_TEXT;
		end
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
	TitanCritLine.EnsureInitialized();
	local rtfAttack="";
	local line = "    -------------------------------------------------------------------  \n";
	for i = 1, #(TCL_SOURCETYPE) do
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


