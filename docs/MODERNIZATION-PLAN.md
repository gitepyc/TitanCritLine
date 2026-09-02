# Modernization plan

## Decision

Rebuild TitanCritLine behind a small Titan Panel adapter while preserving the
observable 0.7.1 behavior that is still valuable. Do not port the monolith line
by line, and do not discard the legacy data before an import decision is made.

The first supported release should target Classic Era/Season of Discovery using
the unified Titan Panel 9 distribution. That choice must still be confirmed by
an in-game spike before implementation commits to combat-log semantics.
Additional WoW flavors are separate targets, not an implicit promise.

## Goals

- Load without errors with the selected current WoW client and Titan Panel.
- Record deterministic damage and healing highscores for the player and owned
  units.
- Use spell IDs and GUID-derived identifiers internally; localize names only at
  presentation boundaries.
- Keep game API access, Titan integration, state transitions, persistence, and
  presentation independently testable.
- Offer a documented, recoverable import path for useful 0.7.1 records.
- Produce repeatable packages and pre-release artifacts from CI.

## Non-goals for the first modern release

- Simultaneous support for every Retail and Classic flavor.
- Pixel-perfect reproduction of the legacy XML windows.
- Permanent support for every historical saved-variable version.
- Automated chat messages, screenshots, or other side effects without a direct
  user preference or action.
- New record types before the core recording behavior is verified.

## Proposed architecture

```text
TitanCritLine.toc
TitanCritLine.lua             addon namespace and lifecycle only
Core/
  CombatLog.lua               game event capture and named event decoding
  Records.lua                 pure record and percentage rules
  Filters.lua                 pure eligibility rules
  Constants.lua               schema and record enums
Persistence/
  Database.lua                defaults, validation, and writes
  Legacy071.lua               one-way legacy import
Integration/
  Titan.lua                   Titan registry, button, tooltip, and menu adapter
  Notifications.lua           splash, sound, and screenshot adapters
UI/
  Options.lua                 generated/current settings UI
Localization/
  enUS.lua
  deDE.lua
  frFR.lua
  ruRU.lua
```

The exact filenames may change during implementation. The important boundaries
are contracts: decoded events enter pure rules; persistence stores normalized
records; presentation never becomes the source of truth.

### Normalized record identity

Use a structured key rather than a displayed label:

```lua
{
  source = "player",        -- or pet/guardian
  kind = "spell_damage",    -- stable internal enum
  spellId = 12345,           -- nil for melee swings
  outcome = "critical"
}
```

Store target GUID/NPC ID, level, amount, timestamp, and build metadata as named
fields where they are relevant. Resolve spell and creature names only for the
current locale when rendering. Never concatenate pet and attack names into a
database key.

### Dependency policy

- Depend on the unified Titan Panel package through its core addon name `Titan`;
  do not depend on the obsolete standalone Titan Panel Classic project.
- Target Titan 9's `registry.menuContextFunction` and `Titan_Menu` menu path.
- Select either `registry.tooltipTemplateFunction` or
  `registry.tooltipDisplayFrame` during the compatibility spike.
- Do not reach into Titan's embedded Ace libraries as an undeclared dependency.
- Prefer native WoW facilities when they are sufficient; vendor or declare any
  library the addon truly owns.

## Prioritized debt register

Priority is calculated as `(Impact + Risk) × (6 - Effort)`, with each dimension
scored from 1 (low) to 5 (high). A high score should be addressed earlier.

| Rank | Item | Impact | Risk | Effort | Priority | Action |
| ---: | --- | ---: | ---: | ---: | ---: | --- |
| 1 | Establish target client and executable smoke test | 5 | 5 | 1 | 50 | First compatibility spike |
| 2 | Replace positional combat-log parsing | 5 | 5 | 2 | 40 | Named decoder plus fixtures |
| 3 | Isolate globals and game/Titan APIs | 5 | 4 | 2 | 36 | Namespace and adapters |
| 4 | Define normalized schema and safe legacy import | 5 | 5 | 3 | 30 | New DB plus one-way importer |
| 5 | Add record-rule and migration tests | 5 | 4 | 3 | 27 | Pure Lua test suite |
| 6 | Replace legacy menu/tooltip integration | 4 | 4 | 3 | 24 | Current Titan adapter |
| 7 | Replace static XML settings and filter UI | 4 | 3 | 4 | 14 | Generated current settings UI |
| 8 | Strengthen linting and packaging | 3 | 3 | 2 | 24 | CI gates per supported flavor |
| 9 | Review optional side effects and exports | 2 | 3 | 2 | 20 | Explicit settings and actions |
| 10 | Refresh all translations | 3 | 2 | 3 | 15 | English source-of-truth review |

The score is a sequencing aid, not a substitute for dependency order. Schema
work follows event decoding even though both are high priority.

## Delivery phases

### Phase 0: compatibility spike

Deliver a throwaway or minimal vertical slice before restructuring the addon.

- Confirm Classic Era/Season of Discovery and record the exact client build.
- Install the unified Titan Panel distribution and record the exact release;
  use `Titan` as the dependency and verify the role of `TitanClassic`.
- Load a minimal TitanCritLine button using the current Titan template.
- Exercise `registry.menuContextFunction` with `Titan_Menu` and a current
  Titan-owned tooltip path.
- Capture representative combat events for melee, spell, periodic, healing,
  pet/guardian, miss, and target-death cases.
- Decide whether legacy 0.7.1 data exists in the test environment and must be
  imported.

Exit criteria: a checked-in compatibility note and repeatable manual smoke
procedure prove the supported client/Titan pair and the current event shapes.

### Phase 1: executable shell and decoder

- Introduce the addon namespace and lifecycle module.
- Update interface metadata only for the verified target.
- Implement a named combat-event decoder with fixture tests.
- Register events through the new lifecycle and log decoded events in a debug
  build without modifying records.
- Remove reliance on implicit `argN` payloads.

Exit criteria: fixtures cover every retained event family, and an in-game debug
session produces equivalent decoded data without Lua errors.

### Phase 2: recording core

- Implement pure record reducers for melee, ranged, direct spell damage, and
  direct healing.
- Add source ownership classification for player, pet, and guardian.
- Define precise rules for normal/critical counts, misses, percentages, ties,
  target eligibility, and unknown data.
- Add periodic damage/healing only after direct events are stable.

Exit criteria: tests define all record decisions, and captured events reproduce
expected records without Titan or UI dependencies.

### Phase 3: persistence and migration

- Introduce an integer schema version independent of addon release versions.
- Separate account preferences, character preferences, persistent records, and
  session-only aggregation state.
- Validate loaded data and fall back safely when malformed.
- Implement an idempotent, one-way 0.7.1 importer with a backup and a migration
  report. Never delete the legacy tables in the first release that imports them.
- Resolve legacy spell names to IDs only when the client can do so reliably;
  preserve unresolved records as labelled legacy entries.

Exit criteria: clean install, upgrade, repeated import, malformed input, and
rollback scenarios are covered by tests and a manual procedure.

### Phase 4: Titan presentation and settings

- Connect the record core to Titan text and tooltip rendering.
- Implement the current Titan menu API behind one adapter.
- Replace 40 static filter checkboxes with a data-driven list.
- Move configuration to the current settings system or another explicitly owned
  UI dependency.
- Make sound, splash, screenshot, and chat export opt-in and testable through
  adapters.

Exit criteria: the supported Titan release can enable, place, configure, and
interact with the plugin without taint or Lua errors.

### Phase 5: hardening and release

- Enable undefined-global linting for modern modules and permit only documented
  WoW/Titan globals.
- Add deterministic unit tests and package validation to CI.
- Build installable ZIP artifacts with a single top-level `TitanCritLine` folder.
- Run a manual matrix covering login, reload, combat types, settings, migration,
  reset, localization fallback, and Titan disabled/missing.
- Publish `0.8.0-alpha.1` style prereleases; reserve `1.0.0` for the agreed
  compatibility and migration promise.

Exit criteria: CI is green, the manual matrix is signed off, rollback is
documented, and the package installs cleanly in a fresh client profile.

## Recommended pull-request sequence

Keep each pull request independently reviewable and target `dev`.

1. Compatibility spike and support matrix.
2. Namespaced bootstrap plus combat-log decoder fixtures.
3. Direct damage/healing record core.
4. New database schema and 0.7.1 importer.
5. Periodic effects and owned-unit classification.
6. Current Titan button, tooltip, and menu adapter.
7. Settings/filter UI and optional notifications.
8. Localization refresh, packaging, and release checklist.

Avoid a preliminary file-only split of the legacy code. Moving globally coupled
functions into multiple files would change geography without creating stable
boundaries. Extract by behavior while tests establish each new boundary.

## Decisions required after Phase 0

- Which client flavor is the first supported target?
- Is Titan Panel mandatory, or should a LibDataBroker display become a future
  optional frontend?
- Are misses part of a useful crit percentage, or should accuracy be separate?
- Should a DoT/HoT record represent the largest tick, one application total, or
  the full effect until removal?
- How long must 0.7.1 import support remain in shipped builds?
- Which filters remain useful when stable NPC and spell IDs replace names?
- Which four localizations have maintainers for semantic review?

## Definition of done for the modernization

- Supported client and Titan versions are explicit and verified.
- No production logic consumes raw positional combat-log fields.
- No addon-owned mutable symbol is added to the global namespace except the
  saved variables and frame names that the platform requires.
- Spell records use IDs internally with localized display names.
- Current and migrated databases are validated and recoverable.
- Core rules and migration paths have deterministic automated tests.
- User-triggered side effects are documented and disabled or conservative by
  default.
- README, architecture notes, support matrix, migration guide, and release
  checklist match the shipped implementation.

## References

- [Titan Panel developer template](https://www.titanpanel.org/template.html)
- [Current Titan Panel project and developer notes](https://www.curseforge.com/wow/addons/titan-panel)
- [Verified Titan Panel 9 compatibility notes](TITAN-PANEL-9-COMPATIBILITY.md)
