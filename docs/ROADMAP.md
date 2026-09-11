# Roadmap

Open, forward-looking items only, in priority order. Everything already
done is in `CHANGELOG.md` and git history, not repeated here.

### 1. Redesign the saved-variable schema and versioned migrations

`TCL_SETTINGS`/`TCL_DOT` have no real schema-version tracking - the
removed `tcl_Update()` tried to branch on the addon's own version string
instead and crashed on every normal update (see `CHANGELOG.md`). A proper
replacement needs an explicit schema-version field per saved table plus a
small chain of migration functions gated on it, run once per version step
- modeled on the sibling CritLog project's `CritLogDB.SchemaVersion`
approach.

Not started: no schema-version field exists yet, so there's nothing to
gate on.

### 2. Replace the static 40-row filter UI

`Filter` is a fixed block of 40 `TitanCritLine_FilterOptionButtonTemplate`
checkboxes in `TitanCritLine.xml`, one row per possible entry - it can't
show more than 40 filterable abilities/spells at once, and every row
exists whether it's needed or not.

Needs a dynamic/scrollable list (e.g. a `FauxScrollFrame`) sized to the
actual number of recorded entries instead of a hardcoded cap. Not started.

### 3. Reduce the remaining global API surface

Around 55 public `tcl_*` functions and several writable globals currently
form the de facto module interface, and `TitanCritLine.lua` still adds
`removekey` to Lua's own global `table` library rather than keeping it as
a local helper.

Needs converting internal-only functions to locals or fields on the
`TitanCritLine` addon table, and moving `table.removekey` off the global
`table` library. Not started - low risk but touches most files, so best
done as one deliberate pass rather than incrementally.

## Parked

Not active priorities, revisit only if the situation changes.

### Spell-name record keys → spell IDs

Replace spell-name record keys with spell IDs and provide a migration for
existing records. Would remove the localization/renaming fragility of
name-keyed records, but touches the saved-variable schema - better done
together with item 1 above, not before it.

### HoT full-effect vs. largest tick

Decide whether HoT records should represent the full effect (sum of every
tick until the aura ends) or just the largest individual tick. The
current code preserves the legacy aggregate-over-the-effect behavior;
changing it would need a decision on which is actually more useful to
show, not just a technical change.
