# Compatibility restoration plan

## Objective

Restore TitanCritLine 0.7.1 on the current Classic Era/Season of Discovery
client and the unified Titan Panel 9 distribution with the same user-visible
behavior it had originally.

This is a compatibility port, not a product redesign. TitanCritLine is also a
small reference project for learning the current Titan Panel plugin contract so
that the same integration patterns can later be applied to another addon.

## Success criteria

The restored addon must:

- load without Lua errors when current Titan Panel is enabled;
- register as a Titan plugin and appear on a Titan bar;
- record the same normal, critical, healing, periodic, and pet records as 0.7.1;
- show the same button text, summary tooltip, menus, and record notifications;
- retain the existing settings, filters, chat export, sound, screenshot, reset,
  backup, and restore behavior;
- preserve existing saved data where technically possible;
- introduce no new user-facing feature.

The `main` branch and `0.7.1` tag remain the immutable legacy reference. All
compatibility work targets `dev` through small pull requests.

## Constraints

- Preserve behavior and defaults unless a current API makes the old behavior
  impossible.
- Keep UI text and interaction patterns stable unless Titan or WoW requires a
  change.
- Do not convert spell names to spell IDs as part of this restoration. That is a
  separate post-parity refactor.
- Do not redesign the saved-variable schema before compatibility is restored.
- Do not add Retail or other Classic-flavor support implicitly.
- Do not perform a broad file split merely to make the code look modern.
- Document every unavoidable behavior difference before merging it.

## Verified target baseline

| Component | Baseline |
| --- | --- |
| WoW flavor | Classic Era/Season of Discovery |
| Exact client build | Record from the installed test client before coding |
| Titan distribution | Unified Titan Panel, not the retired standalone Titan Panel Classic project |
| Current researched Titan version | 9.3.2 |
| Titan core dependency | `Titan` |
| Classic compatibility module | `TitanClassic`, shipped inside the unified package |
| Titan 9.3.2 Classic interface | `11509` for game version 1.15.9 |

The addon TOC must use the interface value reported by the installed Season of
Discovery client. Titan's multi-flavor TOC is evidence of package support, not a
value to copy without verification.

See [Titan Panel 9 compatibility](TITAN-PANEL-9-COMPATIBILITY.md) for the
package inspection and API details.

## Compatibility strategy

Change the smallest boundary that is broken, verify parity, and only then move
to the next boundary. Prefer thin adapters over changes to record logic.

### Titan integration

Keep the existing Titan plugin identity, button template, registry values,
button text function, and update calls where they remain supported.

Replace only the obsolete integration paths:

- retain `## Dependencies: Titan`;
- retain `TitanPanelComboTemplate`, `TitanPanelButton_OnLoad`,
  `TitanPanelButton_OnClick`, and `TitanPanelButton_UpdateButton` while they are
  present in Titan 9;
- replace the global `TitanPanelRightClickMenu_PrepareCritLineMenu` route with
  `registry.menuContextFunction` and `Titan_Menu` while reproducing the same
  menu entries and actions;
- remove the addon-owned `UIDropDownMenuTemplate` frame once the new menu is
  equivalent;
- initially retain `tooltipTextFunction`, because Titan 9.3.2 still supports it
  and TitanCritLine already returns formatted text;
- move to `tooltipTemplateFunction` only if the existing tooltip cannot reproduce
  the old display safely on the target client.

The resulting Titan adapter should be useful as a concise implementation
example, but learning value must not justify unrelated abstractions.

### Combat log integration

The legacy parser's use of positional `arg1` through `arg20` is the main WoW API
compatibility risk. Preserve the existing record rules and replace only event
capture and decoding:

1. Read the current event payload through `CombatLogGetCurrentEventInfo()`.
2. Map each supported combat subevent to named local fields.
3. Pass values to the existing record paths in their expected meaning.
4. Add recorded fixtures for every legacy event family before changing its
   behavior.

Supported legacy event families include direct heals, ranged damage, swings,
spell damage, casts, aura lifecycle events, summons, deaths, periodic healing,
periodic damage, and misses. Correct the misspelled
`SPELL_PERODIC_MISSED` event to `SPELL_PERIODIC_MISSED`; this restores intended
legacy behavior rather than adding a feature.

### Other WoW API changes

Audit and replace deprecated calls only when confirmed on the target client,
including:

- string-based sound identifiers;
- screenshot invocation;
- chat-message invocation;
- combat-log flag and bit operations;
- realm, unit, GUID, level, and relationship APIs;
- XML widget templates used by the settings and filter windows.

Each replacement must preserve the old result and default. A working old call
does not need to be replaced merely because a newer style exists.

### Saved variables

Keep `TitanCritLineSettings`, `TCL_SETTINGS`, and `TCL_DOT` for the compatibility
release. Test clean initialization and loading a real 0.7.1 saved-variable file.

The historical migration code may be isolated or guarded if it crashes, but it
must not be replaced with a new schema during this project. Version comparison,
spell-ID storage, and schema redesign belong to a later refactor after parity.

## Delivery sequence

### PR 1: executable compatibility baseline

- Record the installed WoW build and Titan version.
- Update the addon interface metadata for that verified client.
- Add a short manual smoke-test checklist.
- Make the existing Titan button register and render without errors.
- Change no record behavior.

Exit criteria: TitanCritLine can be enabled, placed on a Titan bar, reloaded,
and disabled without Lua errors.

### PR 2: Titan 9 menu and tooltip parity

- Recreate the existing right-click menu with
  `registry.menuContextFunction` and `Titan_Menu`.
- Remove the obsolete addon-owned dropdown frame.
- Verify every old menu action and displayed state.
- Retain the text tooltip if it renders correctly; otherwise port it to
  `tooltipTemplateFunction` without changing its content.

Exit criteria: screenshots or a written comparison confirm the same button,
tooltip, menu items, toggles, and commands as the legacy addon.

### PR 3: current combat-log input

- Capture representative current-client events.
- Introduce a named decoder around `CombatLogGetCurrentEventInfo()`.
- Route decoded values into the existing record logic.
- Add fixture tests for all supported subevents.
- Correct confirmed event-name and field-position defects.

Exit criteria: direct, periodic, healing, miss, pet, and death scenarios update
the same record categories as the 0.7.1 design.

### PR 4: remaining API compatibility

- Verify settings and filter windows.
- Update only broken widget, sound, screenshot, chat, unit, and bit APIs.
- Verify notifications and optional side effects with their existing defaults.
- Test clean and legacy saved variables.

Exit criteria: every inventoried 0.7.1 feature has a pass result or a documented,
approved compatibility exception.

### PR 5: release hardening

- Remove temporary diagnostics.
- Enable stricter linting for files changed by the port.
- Package an installable ZIP with one `TitanCritLine` directory.
- Run the complete manual regression checklist on a clean client profile and an
  upgraded 0.7.1 profile.
- Release the compatibility build as the next 0.x version; do not call it 1.0
  solely because it runs on a current client.

Exit criteria: CI passes, both profiles pass the checklist, and known deviations
are documented in the release notes.

## Regression checklist

At minimum, verify:

- login, logout, `/reload`, and Titan disabled or missing;
- Titan button placement, label, icon, text refresh, tooltip, and menu;
- normal and critical melee, ranged, and spell damage;
- normal and critical direct healing;
- periodic damage and healing completion;
- player, pet, and guardian ownership;
- misses and displayed percentages;
- target-level, PvP, and mob filters;
- splash, sound, and screenshot record notifications;
- overview, settings, reset, rebuild, backup, and restore;
- raid, party, and guild export initiated by the user;
- clean saved variables and an imported 0.7.1 profile;
- English, German, French, and Russian loading without missing-key errors.

## Explicitly deferred work

After the compatibility release is proven, separate proposals may consider:

- replacing spell-name keys with spell IDs;
- introducing a new saved-variable schema and importer;
- splitting the monolith into modules, following CritLog's proven boundaries:
  bootstrap, combat-log decoding, records, filters, persistence, Titan Panel
  integration, UI, chat output, and event wiring;
- separating periodic healing from periodic damage in the data model and UI so
  Renew and similar spells are represented as HoTs rather than DoTs;
- deciding whether periodic healing records should remain the aggregate value
  over one completed effect, as in the legacy addon, or track the largest
  individual tick; retain aggregate recording until that behavior change has
  been explicitly tested and approved;
- replacing the custom settings UI;
- reducing globals and removing the `table` extension;
- broadening support to other WoW flavors;
- removing features that are no longer useful.

None of these changes is required to complete the 1:1 restoration.

## Definition of done

- The addon behaves like 0.7.1 on the verified current Classic Era/Season of
  Discovery client.
- The current unified Titan Panel package is the documented dependency.
- Titan menus use the current `Titan_Menu` contract.
- Combat events are read from the current combat-log API.
- Existing settings and records survive the update where technically possible.
- Every legacy feature is covered by the regression checklist.
- No new user-facing feature or unapproved behavior change is included.

## References

- [Titan Panel 9 compatibility](TITAN-PANEL-9-COMPATIBILITY.md)
- [Legacy inventory](LEGACY-INVENTORY.md)
- [Titan Panel developer template](https://www.titanpanel.org/template.html)
- [Current Titan Panel project and developer notes](https://www.curseforge.com/wow/addons/titan-panel)
