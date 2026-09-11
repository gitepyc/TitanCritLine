#!/usr/bin/env bash
# Regenerates the entire CHANGELOG.md from scratch via git-cliff (see
# cliff.toml), reading every real git tag - not an incremental prepend of
# just the newest section. Run this locally after creating a new tag
# (bump TitanCritLine.toc's version, commit, `git tag`, then this script,
# then amend the CHANGELOG.md update into that same commit and move the
# tag: `git commit --amend --no-edit && git tag -f <version>`), not in CI -
# CI (release.yml) independently regenerates its own release notes from
# the same commits, it doesn't read this file.
#
# Full regeneration instead of the old incremental `--unreleased --tag
# <version> --prepend`: that form has to label the not-yet-existing tag
# itself, so it stamps "today" for the version's date instead of the real
# tag date, and - if any tag predates git-cliff's own adoption in this
# repo's history - can duplicate the entire prior changelog content on
# every subsequent call. Both were found and fixed during the TitanCritLine
# and CritLog repo rebuilds; full regeneration only reads real, already-
# existing tags, so neither failure mode can happen.
#
# Usage: scripts/update-changelog.sh
set -euo pipefail

cd "$(dirname "$0")/.."

docker run --rm \
    -v "$PWD":/repo \
    -w /repo \
    orhunp/git-cliff:latest \
    --config cliff.toml -o CHANGELOG.md
