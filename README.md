# TitanCritLine

TitanCritLine is a legacy Titan Panel addon that records normal and critical
damage highscores.

## Current state

- Addon version: `0.7.1`
- Current development target: WoW Classic Era / Season of Discovery (`11509`)
- Titan Panel baseline: unified Titan Panel `9.3.2`
- Required dependency: Titan Panel (`Titan`)
- Original authors and contributors are listed in `CREDITS.TXT`.

This repository initially preserves the addon as received, apart from line
ending normalization and exclusion of local Eclipse/LDT workspace metadata.
The metadata now matches the working Season of Discovery baseline used by
CritLog. Runtime compatibility is not yet verified; follow the
[manual test guide](docs/TESTING.md) when testing in game.

The legacy source is preserved on `main` and by the `0.7.1` tag. Active work
targets `dev`; feature and modernization branches should open pull requests
against `dev`.

## Modernization

The addon predates the current WoW and Titan Panel APIs. No compatibility claim
should be made until the first in-game test has passed. The immediate goal is a
conservative compatibility port that restores the 0.7.1 behavior without adding
features or redesigning the addon. Structural refactoring is deferred until
functional parity has been demonstrated.

- [Legacy inventory](docs/LEGACY-INVENTORY.md) describes the current behavior,
  structure, data, and known risks.
- [Modernization plan](docs/MODERNIZATION-PLAN.md) defines the target
  architecture, priorities, migration path, and acceptance criteria.
- [Titan Panel 9 compatibility](docs/TITAN-PANEL-9-COMPATIBILITY.md) records
  the verified package layout and the 2026 plugin API transition.
- [Manual testing](docs/TESTING.md) defines the supported baseline and the
  compatibility checks required before a change can be declared working.

## Installation

Copy the repository contents into a directory named `TitanCritLine` below the
client's `Interface/AddOns` directory. Install and enable Titan Panel as well.

## Repository contents

- `TitanCritLine.toc`: addon metadata and load entry point
- `TitanCritLine.xml`: UI and script declarations
- `TitanCritLine.lua`: addon logic
- `localization*.lua`: bundled translations
- `TitanCritLine.tga`: addon icon
- `CHANGELOG.TXT`, `NOTES.TXT`, `BUGS.TXT`, `CREDITS.TXT`: legacy project documentation

## License

TitanCritLine is distributed under the MIT License. See [LICENSE](LICENSE).
