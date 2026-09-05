local addon = TitanCritLine;
local TITAN_CRITLINE_ID = addon.ID;
local TITAN_CRITLINE_VERSION = addon.VERSION;
local TCL_REALM = addon:GetRealmKey();
local TCL_SOURCETYPE = addon.SOURCE_TYPES;
local DAMAGE_TYPE_NONHEAL = addon.DAMAGE_TYPE_NONHEAL;
local DAMAGE_TYPE_HEAL = addon.DAMAGE_TYPE_HEAL;
local SHOW_WELCOME = 0;
local TRACK_DMG = true;
local TCL_EVENT_TARGET_GUID = nil;

function addon:GetCurrentTargetGUID()
	return TCL_EVENT_TARGET_GUID;
end

function addon:IsTrackingDamage()
	return TRACK_DMG;
end

local function tcl_GetLegacyCombatLogEventInfo()
	local timestamp, subevent, hideCaster,
		sourceGUID, sourceName, sourceFlags, _sourceRaidFlags,
		destGUID, destName, destFlags, _destRaidFlags,
		payload1, payload2, payload3, payload4, payload5, payload6,
		payload7, payload8, payload9, payload10, payload11 = CombatLogGetCurrentEventInfo();

	return timestamp, subevent, hideCaster,
		sourceGUID, sourceName, sourceFlags,
		destGUID, destName, destFlags,
		payload1, payload2, payload3, payload4, payload5, payload6,
		payload7, payload8, payload9, payload10, payload11;
end

function tcl_OnEvent(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 = select(1, ...);
	local srcType;

	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10,
			arg11, arg12, arg13, arg14, arg15, arg16, arg17, arg18, arg19, arg20 = tcl_GetLegacyCombatLogEventInfo();
		TCL_EVENT_TARGET_GUID = arg7;
	end
	
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
						and TitanCritLineSettings.LASTREALM == GetRealmName() ) then
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
		TitanPanelButton_UpdateButton(TITAN_CRITLINE_ID);
		TitanPanelButton_UpdateTooltip( self );
	elseif (event == "PLAYER_LEAVING_WORLD") then
		TitanCritLineSettings.LASTUSER = UnitName("player");
		TitanCritLineSettings.LASTREALM = TCL_REALM;
		TitanCritLineSettings.LASTUSED = date(); 
		TitanCritLineSettings.VERSION  = TITAN_CRITLINE_VERSION; 
		
		
		for i = 1, #(TCL_SOURCETYPE) do
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
		elseif ( bit.band(arg6, COMBATLOG_OBJECT_TYPE_PLAYER) == 0
				and bit.band( arg6, COMBATLOG_OBJECT_AFFILIATION_MINE) ~= 0
				and bit.band( arg6, COMBATLOG_FILTER_MY_PET ) ~= 0 ) then
				srcType = TCL_SOURCETYPE[2];
		end
		-- Any other source (a hostile mob, another player, another player's pet,
		-- ...) leaves srcType nil on purpose - this is not you or your own pet
		-- dealing/receiving damage, so it has no place in a personal crit
		-- tracker and every DOT/HOT block below is already gated on
		-- srcType ~= nil. Used to fall through to the "PET" bucket ("for now
		-- use pet, may create GUARDIAN grouping later"), which meant a mob's
		-- DoT on you or on another party member got recorded and displayed as
		-- if it were your own pet's damage.

	    if ( event ~= nil ) then
	        tcl_DEBUG("Received Event: ["..(arg2 or "none").."]");	    
	    end  
		if ( arg2 == "SPELL_HEAL" ) then 
			if (TCL_SETTINGS[TCL_REALM]["SETTINGS"]["FILTER_HEALING"] == "0") then
				if ( arg5 == UnitName("player") and bit.band(arg6, COMBATLOG_FILTER_ME) ) then 
					if (arg8 == UnitName("player")) then
						if (arg16 == true) then
 							tcl_DEBUG("Crit Heal: Yourself for "..arg13);
 							tcl_RecordHit(arg11, "CRIT", tonumber(arg13), "You", DAMAGE_TYPE_HEAL);
						else
							tcl_DEBUG("Regular Heal: Yourself for "..arg13);
							tcl_RecordHit(arg11, "NORMAL", tonumber(arg13), "You", DAMAGE_TYPE_HEAL);
						end
					else
						creaturename = arg8;
						if (arg16 == true) then
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
				if (arg19 == true) then
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
					if (arg19 == true) then
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
				if (arg16 == true) then
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
					if (arg16 == true) then
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
				if (arg19 == true) then
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
					if (arg19 == true) then
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
		   -- SPELL_AURA_REMOVED/REFRESH used to gate on "arg8 == UnitName("player")"
		   -- (the buff's target being yourself) and then match table entries against
		   -- TCL_PUID (your own source GUID, not the target's). That only ever
		   -- resolved for HoTs/DoTs you put on yourself; casting Renew (or any
		   -- periodic effect) on someone else never finalized or cleaned up its
		   -- entry, since neither the gate nor the GUID comparison could ever be
		   -- true for another target. SPELL_AURA_APPLIED and SPELL_PERIODIC_HEAL/
		   -- DAMAGE already key entries by arg7 (the actual target GUID of this
		   -- event) under the correctly-detected srcType (not hardcoded to "MY") -
		   -- REMOVED/REFRESH now do the same, so any target's effect resolves.
		   if ( srcType ~= nil ) then
		   		if ( arg2 == "SPELL_AURA_REMOVED" ) then
		 			if ( TCL_DOT["DOT_DATA"][srcType][arg11] ~= nil ) then
		 				local entry = TCL_DOT["DOT_DATA"][srcType][arg11][arg7];
		 				if ( entry ~= nil ) then
		 					tcl_DEBUG("AURA_REMOVED: Removing "..arg11.." from the DOT database from "..arg8);
		 					if ( entry[2] == true ) then
		 						tcl_RecordHit(arg11, "DOT", tonumber(entry[1]), "You", DAMAGE_TYPE_HEAL);
		 					else
		 						tcl_RecordHit(arg11, "DOT", tonumber(entry[1]), arg8, DAMAGE_TYPE_NONHEAL);
		 					end
		 					TCL_DOT["DOT_DATA"][srcType][arg11][arg7] = nil;
		 					tcl_DEBUG("SPELL_AURA_REMOVED: Removed ["..entry[1].."] from "..arg11.." K "..arg7);
		 				end
		 			end
		   		end
		   end
		   if ( srcType ~= nil ) then
		   		if ( arg2 == "SPELL_AURA_REFRESH" ) then
		   			-- since we refreshed the spell, we need to lock down the damage store now so we do not overlap the results
		 			if ( TCL_DOT["DOT_DATA"][srcType][arg11] ~= nil ) then
		 				local entry = TCL_DOT["DOT_DATA"][srcType][arg11][arg7];
		 				if ( entry ~= nil ) then
		 					tcl_DEBUG("AURA_REFRESH: Removing "..arg11.." from the DOT database from "..arg8);
		 					if ( entry[2] == true ) then
		 						tcl_RecordHit(arg11, "DOT", tonumber(entry[1]), "You", DAMAGE_TYPE_HEAL);
		 					else
		 						tcl_RecordHit(arg11, "DOT", tonumber(entry[1]), arg8, DAMAGE_TYPE_NONHEAL);
		 					end
		 					TCL_DOT["DOT_DATA"][srcType][arg11][arg7] = nil;
		 					tcl_DEBUG("SPELL_AURA_REFRESH: Removed ["..entry[1].."] from "..arg11.." K "..arg7);
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

			-- check DOT table for spells that may have damaged this unit
			tcl_DEBUG("High DOT "..tcl_GetHighDMG("MY", "DOT"));

			for i = 1, #(TCL_SOURCETYPE) do
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

