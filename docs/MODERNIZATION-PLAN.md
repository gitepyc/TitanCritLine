# Compatibility roadmap

## Goal

Restore the behavior of TitanCritLine 0.7.1 on WoW Classic Era / Season of
Discovery and the unified Titan Panel 9.x package. This remains a conservative
compatibility port: changes should fix compatibility, correctness, or
maintainability without introducing unrelated features.

The exact imported source is preserved by the `0.7.1` tag. Development
happens directly on `main` through short-lived pull-request branches
(trunk-based - see the [README](../README.md#versioning) for the current
branch/tag convention).

## Current baseline

| Component | Baseline |
| --- | --- |
| WoW flavor | Classic Era / Season of Discovery |
| WoW interface | `11509` |
| Titan distribution | Unified Titan Panel |
| Verified Titan version | `9.3.2` |
| Titan dependency | `Titan` |

The addon's own current version isn't repeated here - see the latest entry in
[CHANGELOG.md](../CHANGELOG.md) or the `## Version` line in
[`TitanCritLine.toc`](../TitanCritLine.toc).

## Completed work

- Updated the TOC for the tested Season of Discovery client.
- Restored registration with current Titan Panel.
- Migrated the right-click menu to `registry.menuContextFunction` and
  `Titan_Menu`.
- Adapted combat-log input to `CombatLogGetCurrentEventInfo()`.
- Replaced removed Lua globals and invalid sound references.
- Fixed startup, tooltip, settings, record refresh, sound, and critical-rate
  errors found during in-game testing.
- Replaced localized special-mob matching with numeric NPC IDs while retaining
  reversible filtering.
- Split the legacy monolith into combat-log, records, filters, summary, About,
  and chat modules.
- Labeled periodic healing as HoT in user-facing output.
- Added current addon metadata, packaging, lint, release automation, and manual
  regression documentation.
- Declared TOC compatibility with TBC Classic, MoP Classic, and Mainline/Retail
  (only Classic Era/SoD has actually been verified in a client - see
  [TESTING.md](TESTING.md)).
- Added a setting to disable DoT/HoT tracking entirely (button text and
  summary both drop the periodic column when off).
- Stopped mis-tracking hostile mobs' periodic damage/debuffs as the player's
  own pet DOT damage.
- Fixed two long-standing defects from the original `0.7.1` source
  (`SPELL_PERODIC_MISSED` typo, an `ALL_SPELLS` settings checkbox that never
  rendered checked) and a crash on regular (non-crit) heals cast on anyone but
  the player.
- Replaced the hand-maintained `CHANGELOG.md` with one generated from commit
  messages via `git-cliff` (see `cliff.toml`).

In-game testing has confirmed Titan registration, the context menu, settings,
damage and healing tracking, record notifications, sound playback, and normal
versus critical hit counting after the module split.

## Next compatibility checks

The full outstanding checklist lives in [TESTING.md](TESTING.md) so it isn't
duplicated (and doesn't go stale) here - notably still open as of this
writing: the full damage/healing/pet/guardian/periodic/miss record pass, chat
output to party/raid/guild, screenshot notifications, a real imported `0.7.1`
profile, all four bundled locales, and the TBC/MoP/Retail declaration itself
(interface-only so far, not client-tested).

## Deferred work

These changes require separate decisions after compatibility parity:

- Replace spell-name record keys with spell IDs and provide a migration.
- Decide whether HoT records should represent the full effect or the largest
  individual tick. The current code preserves the legacy aggregate behavior.
- Redesign the saved-variable schema and versioned migrations.
- Replace the static 40-row filter UI.
- Reduce the remaining global API surface and remove the `table` extension.

## Definition of done

- No Lua or XML errors occur during login, interaction, or combat.
- Every legacy feature has a pass result or an explicitly accepted exception.
- Existing settings and records survive the upgrade where technically possible.
- Titan menus use the current API and the addon works with the documented Titan
  9.x baseline.
- CI passes and the release ZIP installs as one `TitanCritLine` directory.

## References

- [Titan Panel 9 integration](TITAN-PANEL-9-COMPATIBILITY.md)
- [Manual testing](TESTING.md)
- [Feature reference](FEATURES.md)
- [Legacy inventory](LEGACY-INVENTORY.md)
