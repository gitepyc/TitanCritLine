local addon = TitanCritLine;
local TCL_REALM = addon:GetRealmKey();
local TCL_SOURCETYPE = addon.SOURCE_TYPES;

-- Schema-version migrations for TCL_SETTINGS, modeled on the sibling
-- CritLog project's CritLogDB.SchemaVersion (Persistence/Database.lua
-- there). A migration function's position in MIGRATIONS is the schema
-- version it upgrades TO; tcl_RunSchemaMigrations runs every migration
-- between the table's stored version and #MIGRATIONS, in order, then
-- stamps the new version. A fresh install has SCHEMA_VERSION nil -> 0,
-- so it runs every migration too - there's no separate "brand new" case
-- to special-case, a new install just starts one version behind current.
--
-- TCL_DOT (the DOT/HOT bookkeeping table) has no migrations of its own:
-- it only holds in-flight tracking state and is cleared every session
-- (see tcl_OnEvent's PLAYER_LEAVING_WORLD handler in Core/CombatLog.lua),
-- so nothing in it ever needs upgrading across logins.

-- Schema 1: the old spell-name-keyed records become spell-id keys.
-- Only string keys are touched; a fresh install has nothing but
-- numeric/NORMAL_HIT_TEXT keys already, so this is a no-op for it. Names
-- the client can't currently resolve (e.g. a boss ability not cast since
-- this login) are left under their old name key untouched - no record is
-- ever dropped.
local function migrateAttackTypeKeysToSpellId(tab)
	for i = 1, #(TCL_SOURCETYPE) do
		local bucket = tab[TCL_REALM]["DATA"][TCL_SOURCETYPE[i]];
		local toMigrate = {};
		for attackType in pairs(bucket) do
			if (type(attackType) == "string" and attackType ~= NORMAL_HIT_TEXT) then
				local petName, name = string.match(attackType, "^(.-)'s (.+)$");
				tinsert(toMigrate, { key = attackType, petName = petName, name = name or attackType });
			end
		end
		for _, entry in ipairs(toMigrate) do
			if (entry.name ~= NORMAL_HIT_TEXT) then
				local spellId = addon.ResolveSpellIdByName(entry.name);
				if (spellId ~= nil) then
					local newKey = entry.petName and (entry.petName.."'s "..spellId) or spellId;
					if (bucket[newKey] == nil) then
						bucket[newKey] = bucket[entry.key];
						bucket[entry.key] = nil;
					end
					-- newKey already taken: leave the old name-keyed record alone
					-- rather than overwrite or merge an existing highscore.
				end
			end
		end
	end
end

local MIGRATIONS = {
	migrateAttackTypeKeysToSpellId,
};

function tcl_RunSchemaMigrations(tab)
	tab["SCHEMA_VERSION"] = tab["SCHEMA_VERSION"] or 0;
	for schemaVersion, migrate in ipairs(MIGRATIONS) do
		if (tab["SCHEMA_VERSION"] < schemaVersion) then
			migrate(tab);
			tab["SCHEMA_VERSION"] = schemaVersion;
		end
	end
end
addon.RunSchemaMigrations = tcl_RunSchemaMigrations;
