# Manual compatibility testing

## Purpose

Use this guide to verify the compatibility port without silently changing the
behavior of TitanCritLine 0.7.1. Automated linting can validate Lua syntax, but
only the game client can validate WoW and Titan Panel APIs.

## Baseline

| Component | Version |
| --- | --- |
| WoW flavor | Classic Era / Season of Discovery |
| WoW interface | `11509` |
| Interface source | The current working CritLog addon in the same workspace |
| Titan distribution | Unified Titan Panel |
| Titan version | `9.3.2` |
| Titan dependency name | `Titan` |
| Titan Classic compatibility addon | `TitanClassic`, supplied by Titan Panel |

Interface `11509` is shared with CritLog, which is actively used in the target
Season of Discovery client. Titan Panel 9.3.2 was the newest CurseForge release
when the compatibility work began. Re-check both values when the client or
Titan Panel is updated.

## Installation

1. Install the unified Titan Panel package from CurseForge.
2. Copy this repository to
   `_classic_era_/Interface/AddOns/TitanCritLine`.
3. Enable `Titan Panel [Core]`, the applicable Titan Classic compatibility
   addon, and `Titan Panel [CritLine]` on the character selection screen.
4. Enable Lua error dialogs once:

   ```text
   /console scriptErrors 1
   ```

5. Reload the UI:

   ```text
   /reload
   ```

Do not enable "Load out of date AddOns" for this baseline. Requiring that option
would indicate incorrect interface metadata.

## Record the environment

Run these commands and attach their output to the compatibility PR or test
report:

```text
/dump GetBuildInfo()
/dump C_AddOns.GetAddOnMetadata("Titan", "Version")
/dump C_AddOns.GetAddOnMetadata("TitanCritLine", "Version")
```

The installed client build is authoritative if it differs from the repository
baseline.

## Baseline smoke test

This first compatibility branch changes metadata only. It must pass the
following checks before further API fixes are mixed into it:

- TitanCritLine appears in the addon list without an out-of-date warning.
- Titan Panel loads normally.
- TitanCritLine produces no XML or Lua error during login.
- `CritLine` appears in Titan's available plugin list under Combat.
- The plugin can be placed on a Titan bar.
- Its icon, label, and initial `0/0/0` text are visible.
- Hovering the plugin shows the existing summary tooltip.
- Left-click follows the existing configured behavior.
- Right-click either opens the legacy menu or produces a captured error for the
  next Titan-menu compatibility change.
- `/reload` preserves the Titan placement and produces no additional error.
- Disabling TitanCritLine and reloading does not affect Titan Panel.

## Reporting a failure

Record:

1. The exact reproduction steps.
2. The first Lua or XML error in full, including its stack trace.
3. Whether the error occurs during login, hover, left-click, right-click, or
   combat.
4. The three environment outputs listed above.
5. Whether the test used clean saved variables or an existing 0.7.1 profile.

Fix the first error before diagnosing follow-on errors. One missing template or
failed initialization can cause many secondary failures.

## Saved-variable safety

For the first run, back up the existing file before testing an old profile:

```text
WTF/Account/<account>/<realm>/<character>/SavedVariables/TitanCritLine.lua
```

Begin with a clean profile if possible, then repeat the smoke test with a copy
of real 0.7.1 data. Do not use the only copy of historical records for a
development test.
