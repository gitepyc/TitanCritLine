# Feature reference

This document describes the behavior of the current compatibility port. Some
labels are inherited from the original addon and are less precise than their
modern meaning.

## Manual Update

`Manual Update` runs the addon's legacy saved-data migration and normalization
routine for the currently installed version. It does not download an addon
update, contact a server, or refresh the Titan Panel display directly.

The same routine runs automatically at login when saved data is missing, has no
version, or was written by a different addon version. The button merely forces
that routine to run again for the current version, so it is normally not
needed.

The routine recreates missing settings and data containers and attempts to
carry existing records into the current saved-variable layout. It exists for
compatibility with old installations. A future refactor should replace it with
automatic, versioned migrations and rename or remove this button.

## Filter

`Filter` opens a list of recorded player and pet attacks or spells. A checked
entry is included in the Titan Panel display and tooltip; clearing it excludes
that entry from highscore calculations. The underlying record remains stored.

This is an ability filter. It is independent of the special-mob setting.

The legacy dialog has room for at most 40 entries. Its close routine currently
resets only the first 20 UI rows, which is a known legacy defect to address in
a later cleanup.

## Special mobs

`Don't count damage on special mobs` compares the numeric NPC ID extracted from
the combat-log target GUID with a central list. It is independent of the client
language. The list is:

- `12460`: Death Talon Wyrmguard
- `12461`: Death Talon Overseer
- `13020`: Vaelastrasz the Corrupt
- `14020`: Chromaggus
- `15339`: Ossirian the Unscarred

When enabled, a matching hit increments the hit counter but cannot replace the
stored highscore. The list was intended to exclude encounters with unusual
damage modifiers from meaningful records.

When the setting is enabled, an existing highscore against a listed mob is
archived and the best record collected while filtering was previously enabled
is restored, if one exists. Disabling the setting archives the current
non-special record and restores the special-mob highscore. This makes the
setting reversible without discarding either record.

Records written by older versions do not contain an NPC ID. When such a record
uses one of the old localized names, CritLine converts it to the corresponding
ID the first time the special-mob filter processes it.

## Critical percentage

`Show Critical Percentage` displays the share of recorded hits for an ability
that were critical. CritLine records normal hits as well as critical hits; the
setting does not describe the share of highscore entries. Current combat-log
booleans are interpreted explicitly so a normal hit is no longer mistaken for
a critical hit merely because the event field exists with the value `false`.

## Titan Panel button values

The three values before the optional healing separator are the highest normal
direct hit, highest critical direct hit, and highest periodic damage record:
`normal / critical / DoT`. When healing is included, the values after the
separator use the same order for direct heal, critical heal, and HoT. Periodic
healing is labeled `HOT` in tooltips, chat output, and new-record messages while
retaining the legacy aggregate-over-the-effect calculation.

## Record sound

When `Play sound` is enabled, every new normal-hit, critical-hit, or periodic
damage/healing record plays WoW sound kit `888`, the Level Up sound. The old
implementation looked up `SOUNDKIT.LEVEL_UP`; that symbolic entry is absent on
the current Season of Discovery client, so it silently played nothing.
