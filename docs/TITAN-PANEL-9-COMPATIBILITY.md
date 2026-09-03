# Titan Panel 9 integration

## Supported dependency

TitanCritLine targets the unified **Titan Panel** distribution. It does not
target the retired standalone Titan Panel Classic project. The addon correctly
declares the shared core as:

```text
## Dependencies: Titan
```

The unified package also ships Classic compatibility code. Users should install
the complete Titan Panel package rather than assembling individual directories.

## Verified baseline

The official Titan Panel `9.3.2` package, released on 21 August 2026, was the
latest CurseForge release when this document was reviewed on 3 September 2026.
It includes support for Classic `1.15.9`, matching interface `11509` used by the
tested Season of Discovery client.

| Component | Value |
| --- | --- |
| Distribution | Unified Titan Panel |
| Verified release | `9.3.2` |
| Core addon | `Titan` |
| WoW target | Classic Era / Season of Discovery |
| Classic interface | `11509` |

The installed game client and Titan package remain authoritative. Re-check both
versions whenever either dependency is upgraded.

## Integration used by TitanCritLine

TitanCritLine currently uses:

- `TitanPanelComboTemplate` for its bar button;
- `TitanPanelButton_OnLoad` and the plugin registry for registration;
- `registry.menuContextFunction` with `Titan_Menu` for the context menu;
- `registry.tooltipTextFunction` for its formatted summary;
- `TitanPanelButton_UpdateButton` for immediate display refreshes;
- `## Dependencies: Titan` in the TOC.

These paths were checked against Titan Panel 9.3.2 and exercised in game.
`tooltipTextFunction` remains a supported Titan path and does not need replacing
while it behaves correctly on the target client.

## 2026 API transition

Titan Panel changed its menu and tooltip integration in response to Blizzard UI
changes. Current plugins should prefer `registry.menuContextFunction` and the
`Titan_Menu` wrapper over addon-owned `UIDropDownMenu` frames. TitanCritLine has
completed that menu migration and no longer owns a legacy dropdown frame.

Titan also offers newer tooltip frame and template callbacks. TitanCritLine
retains `tooltipTextFunction` because Titan still supports it and the summary is
working in game. A tooltip rewrite would add risk without changing behavior.

## External references

- [Titan Panel on CurseForge](https://www.curseforge.com/wow/addons/titan-panel)
- [Titan Panel 9.3.2 release](https://www.curseforge.com/wow/addons/titan-panel/files/8703023)
- [Titan Panel developer template](https://www.titanpanel.org/template.html)

The version-specific findings were verified against the official 9.3.2 package,
including its TOC, menu implementation, and bundled plugin examples.
