# Changelog

This file records the compatibility port developed after the archived 0.7.1
release. The original changelog is preserved in
[`docs/legacy/CHANGELOG-0.7.1.txt`](docs/legacy/CHANGELOG-0.7.1.txt).

**Entry format:** one line per change, `**type:** short bullet`
(`feature`/`fix`/etc., bolded) - as terse as possible, no prose, no
rationale. Save the "why" for the commit message/PR, not here. `-dev`
sections get folded into one consolidated summary under the next real
release heading rather than kept individually forever (same convention as
the sibling CritLog project).

## 0.9.1.2-dev

- **fix:** hostile mobs' periodic damage/debuffs on you or on party members were tracked and displayed as your own pet's DOT damage - any source that isn't you or your own pet is no longer tracked at all
- **feature:** declared TOC compatibility with TBC Classic, Cataclysm Classic, and Mainline/Retail (`## Interface: 120100, 50504, 20506, 11509`), matching the multi-flavor interface list the `Titan` dependency itself already declares - only Classic Era/SoD has been verified in a real client so far
- **docs:** added `CONTRIBUTING.md` (bug report checklist, PR-against-`dev` guideline)

## 0.9.1.1-dev

- **fix:** settings/filter help tooltip sometimes rendered oversized (`GameTooltip` now hidden before every re-show)
- **fix:** HoT/DoT records never finalized for any target but yourself (e.g. Renew cast on someone else never produced a record)
- **fix:** Post to Party posted to raid chat while in a raid - Post to Party now always posts to `/p`, Post to Raid always to `/ra`, both falling back to a local-only echo instead of substituting a different channel
- **feature:** explicit "Post record locally" menu action

## 0.9.1-dev

- **feature:** hid the player and pet healing summary sections while healing tracking is disabled

## 0.9

- Made the Settings window movable and clamped it to the visible screen.
- Promoted the tested compatibility work to the 0.9 release.

## 0.8.9-dev

- Split the Titan hover summary into separate damage and healing sections for
  the player and enabled pet records.
- Added `No entries yet` placeholders to empty summary sections.
- Updated the active addon author metadata while preserving original credits.
- Displayed the verified Titan Panel version in the addon-list title.

## 0.8.8-dev

- Removed the redundant Manual Update action.
- Added confirmation before resetting all records.
- Updated and refined the About dialog.
- Made Escape close only the topmost CritLine dialog.

## 0.8.7-dev

- Split combat-log parsing, record handling, filtering, summaries, chat output,
  and About UI into focused modules.
- Distinguished periodic healing as HoT in user-facing text while retaining
  the legacy aggregate record calculation.

## 0.8.4-dev – 0.8.6-dev

- Corrected normal-hit and critical-hit accounting and displayed percentages.
- Replaced localized special-mob names with numeric NPC IDs while preserving
  reversible filtering of existing records.
- Improved nested dialog behavior and About content.

## 0.8.1 – 0.8.3-dev

- Adapted combat-log event input to the current client API.
- Fixed settings initialization, current UI sounds, immediate Titan bar
  refreshes, and record notification sound playback.

## 0.8.0-dev

- Established the Season of Discovery and Titan Panel 9 compatibility baseline.
- Migrated the right-click menu to `registry.menuContextFunction` and
  `Titan_Menu`.
- Replaced removed Lua 5.0 globals and added automated lint and release
  workflows.

## 0.7.1

Original legacy release. The exact imported source is preserved by tag `0.7.1`
and the `main` branch.
