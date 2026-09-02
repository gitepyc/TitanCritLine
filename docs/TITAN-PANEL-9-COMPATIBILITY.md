# Titan Panel 9 compatibility

## Conclusion

TitanCritLine must target the unified **Titan Panel** distribution, not the old
standalone **Titan Panel Classic** project. As of 2 September 2026, the latest
release is Titan Panel 9.3.2. Its official package supports Retail 12.1.0, MoP
Classic 5.5.4, Burning Crusade Classic 2.5.6, and Classic 1.15.9.

The package and its built-in examples show a mixed transition state: the core
button and registry model remains, while menu and tooltip integration have new
preferred contracts. TitanCritLine should implement the new contracts and must
not treat the presence of legacy fallbacks as a long-term compatibility promise.

## Verified package layout

The official `TitanPanel-9.3.2.zip` package was inspected directly. Relevant
top-level addons include:

| Directory | Role |
| --- | --- |
| `Titan` | Shared core; TOC title `Titan Panel [_Core_]` |
| `TitanClassic` | Classic compatibility module; TOC title `Titan Panel [_Classic_]` |
| `TitanBag`, `TitanClock`, `TitanGold`, and others | Built-in plugin examples |

The core TOC declares all supported interfaces in one addon:

```text
## Interface: 120100, 50504, 20506, 11509
## Title: Titan Panel [Core] 9.3.2
## Version: 9.3.2
```

Formatting codes were omitted from the title above for readability. Built-in
plugins, including Classic-capable ones, declare:

```text
## Dependencies: Titan
```

For TitanCritLine, `## Dependencies: Titan` is therefore still the correct
dependency name. `TitanClassic` is part of Titan's compatibility implementation,
not the primary dependency name for a plugin.

## What changed in 2026

### Menu contract

Titan 9.3.2 resolves a plugin menu in this order:

1. `registry.menuContextFunction` — introduced in January 2026.
2. `registry.menuTextFunction` — the intermediate API from February 2024.
3. A global `TitanPanelRightClickMenu_Prepare<id>Menu` function — legacy
   fallback.

The new function builds an object-style menu with `Titan_Menu`, which wraps
Blizzard's current menu system. Titan's source marks the old
`UIDropDownMenu`-based paths as deprecated and retained for compatibility.

TitanCritLine currently uses only the third route and declares its own
`UIDropDownMenuTemplate` frame in XML. The modernization must:

- add `menuContextFunction` to the plugin registry;
- build entries with `Titan_Menu.AddButton`, `AddSelector`, `AddCommand`,
  `AddDivider`, and related helpers as appropriate;
- remove the custom legacy dropdown frame;
- keep no global menu-builder function in the final architecture.

### Tooltip contract

Titan changed tooltips for WoW Midnight 12.0.0 after Blizzard's restricted or
"secret" values made direct `GameTooltip` assumptions unsafe. Titan 9.3.2 uses
the following priority:

1. `registry.tooltipDisplayFrame` — plugin-owned frame, introduced March 2026.
2. `registry.tooltipTemplateFunction` — Titan passes its tooltip frame to the
   plugin, introduced March 2026.
3. `registry.tooltipCustomFunction` — deprecated implicit `GameTooltip` path.
4. `registry.tooltipTextFunction` — returns formatted text for Titan to display.

TitanCritLine uses `tooltipTextFunction`. That is still recognized in 9.3.2, so
it is not evidence by itself that the addon cannot load. For a structured modern
tooltip, `tooltipTemplateFunction` is the best initial candidate; it keeps frame
ownership in Titan while allowing explicit `AddLine` calls. This must be tested
in Classic Era/Season of Discovery before the choice becomes permanent.

### What did not change

The following are present in Titan Panel 9.3.2 and its built-in plugins:

- `TitanPanelComboTemplate` and related button templates;
- `TitanPanelButton_OnLoad`;
- `TitanPanelButton_OnClick`;
- a plugin `registry` containing ID, category, version, text functions, tooltip
  functions, icon, saved-variable defaults, and control variables;
- `TitanPanelButton_UpdateButton`.

These can remain behind a small `Integration/Titan.lua` adapter. They should not
leak into combat parsing, record rules, persistence, or settings modules.

## Why addons broke

Two separate transitions are easy to conflate:

1. The former standalone Classic-specific Titan distribution was superseded by
   the unified Titan Panel package. Classic compatibility now ships alongside
   the `Titan` core as `TitanClassic`.
2. Blizzard replaced/deprecated menu and tooltip foundations. Titan introduced
   `Titan_Menu`, `menuContextFunction`, and new tooltip registry fields during
   2026. Plugins tied directly to the old dropdown or `GameTooltip` assumptions
   require changes even though Titan still exposes compatibility fallbacks.

TitanCritLine is affected by both its age and these transitions. Its old Titan
menu is a real migration item, but its positional combat-log parser remains the
larger functional blocker.

## Implementation baseline

The first compatibility pull request should use:

| Component | Baseline |
| --- | --- |
| Titan distribution | Unified Titan Panel |
| Titan version | 9.3.2 initially; re-check latest at implementation time |
| Titan dependency | `Titan` |
| WoW target | Classic Era/Season of Discovery |
| Published Classic interface in 9.3.2 | `11509` / game version 1.15.9 |
| Menu route | `registry.menuContextFunction` and `Titan_Menu` |
| Tooltip candidate | `registry.tooltipTemplateFunction` |

The interface value must be checked against the installed Season of Discovery
client rather than copied blindly from Titan's package. Titan supports several
flavors with a multi-interface TOC; TitanCritLine may choose a narrower support
contract.

## Sources

- [Titan Panel 9.3.2 file metadata and supported game versions](https://www.curseforge.com/wow/addons/titan-panel/files/8703023)
- [Titan Panel project notes for Classic compatibility, menus, and tooltips](https://www.curseforge.com/wow/addons/titan-panel)
- [Titan Panel developer template](https://www.titanpanel.org/template.html)

The package-level API findings above were verified against the official 9.3.2
ZIP, specifically `Titan/Titan.toc`, `Titan/TitanMenu.lua`, and the documented
`TitanBag/TitanBag.lua` example. The upstream project does not currently expose
those exact release files through a public source link on its CurseForge page,
so the file metadata link is provided as the reproducible download source.
