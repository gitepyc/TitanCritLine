# CurseForge release plan

## Background

TitanCritLine already existed as a CurseForge project before this repository:
project ID `7019`, slug `titan-panel-crit-line-agr8`, original owner
`_ForgeUser234700` (CurseForge account `agr8`), abandoned since the `0.7.1`
release in 2011. See the `0.7.1` GitHub release notes for the full archived
project metadata (downloads, category, original license field, etc.).

Decision: adopt the existing abandoned project rather than create a new one.
This keeps the project's name and history intact and lets the current
maintainer set the license (MIT, matching this repo) as the legitimate new
owner, instead of starting a duplicate listing under a similar name.

## Prerequisites

- A CurseForge/Overwolf account for the current maintainer.
- Access to this repository (already the case) as evidence of active
  maintenance when requesting the ownership transfer.

## Step 1: Adopt project 7019

1. Optional but recommended: contact the original owner (`_ForgeUser234700`
   / `agr8`) through their CurseForge profile first. Even an unanswered
   attempt strengthens the takeover request.
2. Open a CurseForge support request for an abandoned-project ownership
   transfer, referencing project `7019`
   (`curseforge.com/wow/addons/titan-panel-crit-line-agr8`).
3. Include as evidence: this Gitea repository and the GitHub releases
   already published (`github.com/gitepyc/TitanCritLine`).
4. In the same request, ask to rename the project slug from
   `titan-panel-crit-line-agr8` (carries the previous owner's username) to
   `titan-panel-crit-line`. Slug changes historically required a support
   ticket rather than self-service on the older Curse platform; unclear
   whether that's still the case on the current CurseForge/Overwolf
   platform, so ask directly rather than assuming a self-service option
   exists. Also ask whether the old slug will keep redirecting, since
   external links/bookmarks to the current URL exist from the addon's
   264k-download history.
5. Wait for support to process the transfer. This step has no fixed
   timeline and cannot be done from this repository or automated.

## Step 2: Project page setup (after ownership transfer)

- License: set to MIT in the project settings.
- Description: can reuse `README.md` largely as-is.
- Category and supported game version tags: set on the CurseForge project
  edit page directly (Classic Era / Season of Discovery as applicable —
  verify against CurseForge's current category list at edit time).
- Project logo: upload a dedicated image. `TitanCritLine.tga` is the small
  in-game plugin icon, not a project-page logo — a separate, larger image
  is needed.
- Screenshots (optional, recommended for a first release): the archived
  `0.7.1` gallery captions (`CritLine Tooltip w Heal`, `Critline on Titan
  Bar w Heal`, `Critline on Titan Bar`, `Critline Filter Menu`) are a
  reasonable shot list to recreate on the current client.

## Step 3: Wire up automated publishing

The existing `.github/workflows/release.yml` (BigWigsMods/packager) already
builds and publishes a GitHub release with a zip on every tag push, via the
push-mirror from Gitea to `github.com/gitepyc/TitanCritLine`. The same job
can publish to CurseForge with two additions:

1. Create a CurseForge API token (project or account API tokens page).
2. Add it as a GitHub Actions secret named `CF_API_KEY` on
   `gitepyc/TitanCritLine`.
3. Add one line to `TitanCritLine.toc`:
   ```
   ## X-Curse-Project-ID: 7019
   ```
   The packager action reads this automatically; no workflow file change
   needed.

## Step 4: Publish

- Pick the tag to publish as the first CurseForge release. `0.9` (current)
  is a reasonable first public version — no requirement to reach `1.0`
  first (see `docs/MODERNIZATION-PLAN.md`: "do not call it 1.0 solely
  because it runs on a current client").
- Mark the CurseForge release channel as `Release`, not `Alpha`/`Beta`.
- If `CF_API_KEY`/`X-Curse-Project-ID` are already in place before the tag
  is pushed, this happens automatically alongside the GitHub release.
  Otherwise, upload the already-built zip from the matching GitHub release
  manually for the first file.

## Decided, not blocking

- **Addon-list title shows Titan Panel's version (`9.3.2`), not
  TitanCritLine's own (`0.9`).** Raised during review: Titan's own
  bundled plugins (Gold, Clock, Bag, ...) show `9.3.2` in their title only
  because that IS their own version — they ship in lockstep with Titan
  Panel itself. TitanCritLine is independently versioned, so the same
  display doesn't carry the same meaning; it also doesn't match
  `## Version: 0.9` in the same file. Kept as-is per explicit maintainer
  decision (informational: "tested against this Titan Panel version").
  Revisit only if it causes real user confusion.
- **Relicensing the ported `0.7.1` code as MIT** without contacting the
  original authors beyond the abandoned-project adoption itself. Accepted
  as consistent with WoW addon community norms for long-abandoned
  hobby-project code, especially once the CurseForge ownership transfer
  (Step 1) formally makes the current maintainer the project owner.
  `CREDITS.TXT` documents the full original authorship chain regardless of
  license.
