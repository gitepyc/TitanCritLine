# TitanCritLine

TitanCritLine is a legacy Titan Panel addon that records normal and critical
damage highscores.

## Current state

- Addon version: `0.7.1`
- Declared WoW interface: `40100`
- Required dependency: Titan Panel (`Titan`)
- Original authors and contributors are listed in `CREDITS.TXT`.

This repository initially preserves the addon as received, apart from line
ending normalization and exclusion of local Eclipse/LDT workspace metadata.
Compatibility with current WoW clients has not yet been verified.

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
