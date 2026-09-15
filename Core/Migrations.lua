local addon = TitanCritLine;

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
local MIGRATIONS = {
	-- Add migration functions here as TCL_SETTINGS's shape changes; each
	-- one takes the TCL_SETTINGS table and mutates it in place.
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
