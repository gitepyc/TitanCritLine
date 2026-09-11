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

## Releasing

- Versions are `X.Y.Z.W`, four segments. `X.Y.Z` only bumps for a genuinely
  new feature/milestone; a small fix or tweak bumps just `W`
  (`0.8.7` -> `0.8.7.1` -> `0.8.7.2` -> ...) - keeps `X.Y.Z` from climbing on
  every minor change.
- Bump `TitanCritLine.toc`'s `## Version` (and the matching constant in
  `TitanCritLine.lua`) to a `-dev.N` prerelease (`0.8.7.1-dev.1`), run
  `scripts/update-changelog.sh`, commit, and tag.
- Only bump the target version (`X.Y.Z.W`) when starting toward a genuinely
  new one. For another iteration on the *same* target, just increment `N`
  (`0.8.7.1-dev.1` -> `0.8.7.1-dev.2` -> ...) - bumping the target on every
  small change abandons the previous one as a tag nobody ever "finishes",
  recreating the orphaned-tag mess the whole versioning rework was meant to
  fix.
- Once a `-dev.N` build is confirmed working in-game, tag that same commit
  again **without** the suffix (the real release) and delete the
  now-superseded `-dev.N` tag(s) for that target - a `-dev.N` tag never
  becomes a release just by virtue of a later version bump; it stays a
  prerelease until an explicit clean tag is cut.
- `cliff.toml`'s `ignore_tags` folds every `-dev.N` tag's commits into the
  next real release's section automatically - `CHANGELOG.md` never shows
  `X.Y.Z-dev.1`/`.2`/... as separate permanent entries, only the final
  `X.Y.Z` heading with everything since the previous real release. The
  in-progress, not-yet-tagged-clean work shows as `## Unreleased` until
  then. `release.yml`'s release-notes step accounts for this: a real
  release keeps using git-cliff's `--current` (which now naturally
  includes every folded-in `-dev.N` commit too), a prerelease tag gets an
  explicit commit range instead, since `--current` can't resolve a tag
  that `ignore_tags` excludes.
