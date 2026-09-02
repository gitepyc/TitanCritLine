# Legacy inventory

This document inventories TitanCritLine 0.7.1 as imported. It describes what
the source appears to do; it does not claim that those paths work on a current
World of Warcraft client.

## Baseline

| Item | Legacy value |
| --- | --- |
| Addon version | `0.7.1` |
| WoW interface | `40100` (Patch 4.1 era) |
| Required addon | `Titan` |
| Runtime code | One approximately 1,900-line Lua file |
| UI | One approximately 950-line XML file |
| Locales | English, German, French, Russian |
| Account saved variable | `TitanCritLineSettings` |
| Character saved variables | `TCL_SETTINGS`, `TCL_DOT` |
| Automated tests | None |

## User-visible behavior

The implementation contains the following feature areas.

| Area | Observed behavior | Modernization disposition |
| --- | --- | --- |
| Damage records | Stores highest normal and critical weapon, ranged, and spell hits | Keep |
| Healing records | Stores highest normal, critical, and periodic healing | Keep, verify semantics |
| Periodic effects | Aggregates DoT/HoT ticks until aura removal, refresh, or unit death | Redesign and test |
| Pets and guardians | Keeps a separate record namespace for controlled sources | Keep, rebuild classification |
| Miss statistics | Counts misses and includes them in percentages | Review product meaning |
| Titan display | Shows selected record data in the Titan bar and tooltip | Keep through an adapter |
| Record notification | Shows splash text; can play a sound or take a screenshot | Keep as opt-in choices |
| Target filtering | Can restrict records by PvP status, target level, and a mob-name filter | Redesign around stable identifiers |
| Data maintenance | Reset, rebuild, delete filtered records, and restore a backup | Replace with explicit safe operations |
| Chat export | Posts record summaries to raid, party, or guild chat | Keep only as an explicit user action |
| Settings and overview | Custom movable XML frames and a 40-row static filter form | Replace |

## Runtime flow

1. XML creates the Titan button and all configuration frames.
2. `tcl_OnLoad` constructs the Titan registry, registers game events, and
   announces the addon version.
3. `tcl_OnEvent` initializes saved data on world entry and parses every combat
   log event.
4. Event-specific branches mutate nested global saved-variable tables directly.
5. New records trigger UI feedback and refresh the Titan text and tooltip.
6. XML script blocks and globally named Lua functions mutate settings directly.

There are no boundaries between event decoding, business rules, persistence,
Titan integration, presentation, and user-interface code.

## Data model

The saved data is composed of nested tables indexed by source category, damage
or healing category, attack name, and record type. Periodic effects use an
additional transient-looking table keyed by localized spell and unit names or
GUIDs. Settings, records, migration state, and backups share the same mutable
global namespace.

Important migration concerns:

- Version migrations compare dotted version strings lexicographically.
- Records use localized spell names as durable keys.
- Pet labels concatenate the pet name with the attack name.
- The mob filter stores localized creature names.
- Both account-wide and per-character saved variables exist, but ownership and
  lifecycle are not documented.
- Some migrations rewrite the input table in place and assume historical table
  shapes.

The 0.7.1 tables should be treated as an import format, not as the new internal
schema.

## Compatibility findings

### Titan Panel

The underlying Titan plugin mechanism still exists. Titan's current developer
template documents inherited button templates, `TitanPanelButton_OnLoad`,
`TitanPanelButton_OnClick`, registry-based registration, and button refreshes.
The legacy addon therefore needs a focused Titan compatibility update, not the
removal of Titan integration.

However, current Titan releases recommend a new menu wrapper and a Titan-owned
tooltip path because Blizzard changed menu and tooltip behavior. The legacy
right-click menu and tooltip implementation must be validated and most likely
adapted.

### World of Warcraft

The combat parser is the primary blocker. It assigns event payload fields to
generic positional variables (`arg1` through `arg20`) and then gives those
positions different meanings in large conditional branches. A current parser
must obtain the combat-log payload at event time, decode each subevent shape,
and expose named fields.

Other compatibility candidates include string-based sound identifiers, old
widget templates, inline XML scripts, old dropdown behavior, global combat-log
constants, and assumptions about unit names and realms. Each must be verified
against the selected game flavor rather than changed by guesswork.

## Structural debt and defects

- Approximately 45 public `tcl_*` functions and many writable globals form the
  de facto module interface.
- The addon adds `removekey` to Lua's global `table` library.
- UI logic is encoded in nearly 1,000 lines of XML and includes 40 individual
  filter checkboxes.
- Version metadata is duplicated in the TOC and Lua.
- The addon consumes Ace libraries through Titan instead of declaring a stable
  library contract of its own.
- Static linting intentionally suppresses undefined-global diagnostics, which
  hides the most important class of addon errors.
- `SPELL_PERODIC_MISSED` is misspelled and can never match the intended combat
  event.
- Settings rendering checks option 12 but marks option 11 as selected.
- Several branches depend on implicit globals and ambiguous positional values.
- There is no reproducible combat-log fixture, migration test, or UI smoke test.

## External references

- [Titan Panel developer template](https://www.titanpanel.org/template.html)
- [Current Titan Panel project and compatibility notes](https://www.curseforge.com/wow/addons/titan-panel)

These references are snapshots of moving dependencies. Implementation pull
requests must pin and record the versions used for verification.
