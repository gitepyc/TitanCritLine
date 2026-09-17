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

- Versions are `X.Y.Z.W`, four segments, but `W` only appears once it's
  actually been incremented. A genuinely new feature/milestone is plain
  `X.Y.Z` (`0.8.8`, tagged `0.8.8-dev.1`) - not `X.Y.Z.0`. The first small
  fix or tweak on top of it introduces `W` (`0.8.8` -> `0.8.8.1` ->
  `0.8.8.2` -> ...) - keeps `X.Y.Z` from climbing on every minor change.
- Bump `TitanCritLine.toc`'s `## Version` (and the matching constant in
  `TitanCritLine.lua`) to a `-dev.N` prerelease (`0.8.7.1-dev.1`), run
  `scripts/update-changelog.sh`, commit, and tag.

### When to bump the target vs. just `N`

- **Another dev build for the same target** (you found a bug, made a small
  change, want to re-test): keep the target exactly as-is, just increment
  `N` (`0.8.7.1-dev.1` -> `0.8.7.1-dev.2` -> ...).
- **Starting toward a genuinely new target** (new milestone, or a small
  fix/tweak layered on a target that's already been promoted to a real
  release): bump `X.Y.Z` or `W` and reset to `-dev.1` - this bump is itself
  the confirmation that the previous target is done, see below.

### Bumping to a new target finishes the previous one

A bump to a new target means: the previous target counts as tested and
done.

1. Tag the previous target's last commit again, without `-dev.N` (e.g. the
   commit tagged `0.8.7.1-dev.3` also gets tagged plain `0.8.7.1`).
2. Delete every `-dev.N` tag for that target, locally and on the Gitea
   remote.
3. Tag the new target as `-dev.1`, regenerate the changelog, commit.
4. Check the GitHub mirror's Releases page by hand afterward - deleted
   tags don't reliably sync there.

### CHANGELOG interaction

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
