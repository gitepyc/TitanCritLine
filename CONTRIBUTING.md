# Contributing

TitanCritLine is a small, actively maintained addon. This project has no
formal review board or coding-standard document - the guidelines below are
just what makes a bug report or pull request actionable.

## Reporting a bug

Only the game client can validate WoW and Titan Panel APIs, so a good report
needs the same information [`docs/TESTING.md`](docs/TESTING.md#reporting-a-failure)
asks for:

1. Exact reproduction steps.
2. The first Lua or XML error in full, including its stack trace.
3. Whether it happened during login, hover, left-click, right-click, or combat.
4. `/dump GetBuildInfo()`, `/dump C_AddOns.GetAddOnMetadata("Titan", "Version")`,
   and `/dump C_AddOns.GetAddOnMetadata("TitanCritLine", "Version")`.
5. Whether you tested with clean saved variables or an existing profile.

## Pull requests

- Branch off `main` (there's no separate `dev` branch - trunk-based, short-lived
  feature branches only) and open the PR against `main`.
- Run `luacheck` before opening the PR (see `tests/lint/`) if you changed any
  `.lua` file.
- Write commit messages as `type: short description` (`feature`/`fix`/`tweak`/
  `docs`/`debug`/`refactor`/`chore`) - `CHANGELOG.md` is generated from these
  automatically via [git-cliff](https://git-cliff.org), not hand-edited.
- Keep the PR focused on one change - a bug fix doesn't need unrelated
  cleanup bundled in.
