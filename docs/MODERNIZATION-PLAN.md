# Compatibility roadmap

## Goal

Restore the behavior of TitanCritLine 0.7.1 on WoW Classic Era / Season of
Discovery and the unified Titan Panel 9.x package. This remains a conservative
compatibility port: changes should fix compatibility, correctness, or
maintainability without introducing unrelated features.

The exact imported source is preserved on `main` and tag `0.7.1`. Development
changes target `dev` through pull requests.

## Current baseline

| Component | Baseline |
| --- | --- |
| WoW flavor | Classic Era / Season of Discovery |
| WoW interface | `11509` |
| Titan distribution | Unified Titan Panel |
| Verified Titan version | `9.3.2` |
| Titan dependency | `Titan` |
| Addon version | `0.8.9-dev` |

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

In-game testing has confirmed Titan registration, the context menu, settings,
damage and healing tracking, record notifications, sound playback, and normal
versus critical hit counting after the module split.

## Next compatibility checks

- Verify damage, healing, pet, guardian, periodic, and miss records across the
  full checklist in [TESTING.md](TESTING.md).
- Verify chat output to party, raid, and guild.
- Verify screenshot notifications.
- Test both clean saved variables and a real imported 0.7.1 profile.
- Verify all four bundled locales load without missing-key errors.
- Confirm filtering and Reset All behavior after the latest UI changes.

## Deferred work

These changes require separate decisions after compatibility parity:

- Replace spell-name record keys with spell IDs and provide a migration.
- Decide whether HoT records should represent the full effect or the largest
  individual tick. The current code preserves the legacy aggregate behavior.
- Redesign the saved-variable schema and versioned migrations.
- Replace the static 40-row filter UI.
- Reduce the remaining global API surface and remove the `table` extension.
- Consider support for WoW flavors beyond Classic Era / Season of Discovery.

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
