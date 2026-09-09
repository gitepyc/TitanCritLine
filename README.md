# TitanCritLine

TitanCritLine is a Titan Panel plugin for WoW Classic Era and Season of
Discovery. It records personal highscores for normal, critical, and periodic
damage and healing, including pet and guardian records.

**Current version:** `0.8.7` ([changelog](CHANGELOG.md))

This project is a compatibility restoration of TitanCritLine 0.7.1. The goal
is to preserve its original behavior on a current client, not to add unrelated
features. The original imported source is preserved by the `0.7.1` tag; see
[Versioning](#versioning) below for how `dev`/`main` and version tags work
today.

## Supported baseline

| Component | Baseline |
| --- | --- |
| WoW flavor | Classic Era / Season of Discovery |
| WoW interface | `11509` |
| Titan Panel | Unified Titan Panel 9.x |
| Verified Titan release | `9.3.2` (21 August 2026) |
| Required addon | `Titan` |

The addon's own version isn't repeated here since it changes far more often
than this table - see [Versioning](#versioning).

TitanCritLine has been tested in game with Titan Panel 9.x. Registration,
context menus, settings, damage and healing tracking, record notifications,
and sound playback are confirmed working. See the [manual test guide](docs/TESTING.md)
for the remaining regression checklist.

## Installation

1. Install the current unified [Titan Panel](https://www.curseforge.com/wow/addons/titan-panel)
   package.
2. Copy or extract this addon as
   `_classic_era_/Interface/AddOns/TitanCritLine`.
3. Enable Titan Panel and Titan Panel CritLine for the character.
4. Add CritLine to a Titan bar from Titan Panel's plugin menu.

## Usage

- Hover over CritLine for the record summary.
- Right-click it for Titan Panel options and CritLine settings.
- Use `Filter` to include or exclude individual recorded abilities from the
  displayed highscores.
- Use `Reset All` to erase all stored records after confirming the prompt.

The complete behavior of every setting and displayed value is documented in
the [feature reference](docs/FEATURES.md).

## Documentation

- [Contributing](CONTRIBUTING.md) — bug report checklist and pull request guidelines
- [Feature reference](docs/FEATURES.md) — settings, filters, records, and notifications
- [Manual testing](docs/TESTING.md) — supported baseline and regression checklist
- [Compatibility roadmap](docs/MODERNIZATION-PLAN.md) — completed and deferred modernization work
- [CurseForge release plan](docs/CURSEFORGE-RELEASE.md) — project adoption and publishing steps
- [Titan Panel 9 integration](docs/TITAN-PANEL-9-COMPATIBILITY.md) — verified dependency and API contracts
- [Legacy inventory](docs/LEGACY-INVENTORY.md) — original 0.7.1 design and risks
- [Legacy documents](docs/legacy/) — original changelog, upgrade notes, and retired support instructions
- [Credits](CREDITS.TXT) — current maintenance and original contributors
- [Changelog](CHANGELOG.md) — development history after the 0.7.1 import

## Project layout

- `TitanCritLine.toc` — addon metadata and entry point
- `TitanCritLine.xml` — frames and UI declarations
- `TitanCritLine.lua` — bootstrap, settings, and persistence
- `Core/` — combat-log decoding, record handling, and special-mob filters
- `UI/` — summary tooltip and About dialog
- `Localization/` — bundled enUS, deDE, frFR, and ruRU strings
- `Chat.lua` — explicit party, raid, and guild record output

## Development

Open compatibility and maintenance pull requests against `dev`. Keep user
documentation, code comments, commit messages, and new UI text in English.
Run the repository lint workflow and the relevant sections of the manual test
guide before merging runtime changes.

## Versioning

Active development and version tags happen on `dev`. `main` only moves once a
`dev` tag has actually been verified in-game - the two branches are not
necessarily in sync at any given moment, and that's expected, not a bug.

The addon's single current version lives in `TitanCritLine.toc`'s
`## Version` line (kept in sync with a matching constant in
`TitanCritLine.lua`). [`CHANGELOG.md`](CHANGELOG.md) is generated
automatically from commit messages via [git-cliff](https://git-cliff.org)
(see `cliff.toml`) - write the actual description in the commit message, not
in the changelog file directly. The original, untouched `0.7.1` import is
preserved permanently by the `0.7.1` tag.

## License

TitanCritLine is distributed under the [MIT License](LICENSE).
