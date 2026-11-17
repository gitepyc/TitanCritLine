# AGENTS.md

TitanCritLine: Titan Panel plugin (WoW Classic Era / SoD and other flavors)
recording highest normal, critical and periodic damage/healing. Compatibility
port of the legacy 0.7.1 addon (tag `0.7.1`). Docs: `README.md` (layout,
versioning), `CONTRIBUTING.md` (PR and release process - source of truth),
`docs/FEATURES.md`, `docs/TESTING.md`.

## Repos

- Mainline, issues and PRs: GitHub `gitepyc/TitanCritLine`; tag pushes build the
  release via `.github/workflows/release.yml`. Branches are pushed to GitHub.
- Forgejo pull-mirrors GitHub (read-only). The old Gitea repo
  `claude-bot-mh/TitanCritLine` is not used anymore.

## Commands

- `scripts/lint.sh` - luacheck (Lua 5.1) in a Docker image from
  `tests/lint/`. Undefined-global checks are disabled in `.luacheckrc`, so
  lint does not catch API typos. No unit tests; runtime behavior is verified
  in-game with `docs/TESTING.md`.
- `scripts/update-changelog.sh` - full git-cliff regen of `CHANGELOG.md`
  (Docker). Only at release time, after tagging (see `CONTRIBUTING.md`).

## Workflow rules

- Explain a proposed change and wait for agreement before committing - also
  for docs-only changes.
- Short-lived branch off `main` + PR; never commit directly to `main`.
- Large/architectural reworks (saved-variable schema, record keying, new
  subsystems, UI reworks): PR stays open until the user confirms an in-game
  test. A test build can be tagged `-dev.N` on the branch commit.
- Merge with a merge commit (`--no-ff` locally, or the GitHub UI) so the
  merge keeps the `gitepyc` identity.
- Commit author and committer: `gitepyc <git@brauteam.de>` (repo-local
  `git config`, set right after cloning).
- Commit subject `type: description` (`feature`/`fix`/`tweak`/`docs`/
  `debug`/`refactor`/`chore`; `ci:` is NOT mapped here and lands in
  "other"). The subject becomes the changelog bullet: one short line.
- No version bump, tag or release unless the user asks for it. Version lives
  in `TitanCritLine.toc` `## Version` AND `TITAN_CRITLINE_VERSION` in
  `TitanCritLine.lua` - keep both in sync. Format `X.Y.Z[.W]`, `W` only once
  incremented (`0.8.8`, not `0.8.8.0`).

## Code conventions

- `TCL_SETTINGS` schema changes: append a migration to `MIGRATIONS` in
  `Core/Migrations.lua` (index = `SCHEMA_VERSION`), never drop records.
  `TCL_DOT` is per-session state and needs no migrations.
- User-facing strings go through `Localization/` (enUS, deDE, frFR, ruRU);
  code, comments and new UI text in English.
- Titan registry (`TitanCritLine.lua`): right-click menu uses
  `menuContextFunction` with `Titan_Menu`; Titan adds title and
  ShowIcon/ShowLabelText/Hide controls itself from
  `registry.controlVariables` (not the same as `savedVariables`) - don't
  build those entries by hand. `tooltipTextFunction` is still the current
  contract.
- Combat log: `tcl_GetLegacyCombatLogEventInfo` (`Core/CombatLog.lua`) maps
  `CombatLogGetCurrentEventInfo()` onto the legacy `argN` positions and
  drops `sourceRaidFlags`/`destRaidFlags`; changing that mapping shifts
  every later field and needs in-game event capture to verify.
- Frames using `SetBackdrop()` need `inherits="BackdropTemplate"`. Use
  numeric sound-kit IDs (record sound `888`), symbolic `SOUNDKIT.*` names
  can be missing and fail silently.
- `docs/legacy/` is historical; don't update it to describe current behavior.
