# Releasing

## Branches

| Branch | Purpose |
|---|---|
| `main` | Tagged, tested states only. What runs on Eibesthal and what is linked from outside |
| `development` | Integration branch, all daily work |
| `feature/...`, `fix/...` | Optional short-lived branches from `development` |

`development` is the default branch on GitHub. `main` is protected against force pushes
and deletion. Commit messages are imperative ("Add ...", "Fix ...").

## Versioning

Semantic Versioning, tags `vMAJOR.MINOR.PATCH`.

- Patch: fixes without visible design change.
- Minor: new pages or components, design changes following upstream.
- Major: a change that needs action in the realm configuration or a new Keycloak major version.

## Pre-release

The earlier condition (confirmed logo and fonts, OQ-02/OQ-03) is met since 2026-11-14, so
0.1.0 can be a normal release. Mark a tag as pre-release only when something is unfinished.

## Steps

```bash
git switch development
# 1. everything done, docs/testing.md checklist ticked for the changed pages
# 2. CHANGELOG.md: rename [Unreleased] to [x.y.z] - YYYY-MM-DD, add a fresh [Unreleased]
git commit -am "Prepare release x.y.z"

git switch main
git merge --no-ff development
git tag -a vx.y.z -m "Release x.y.z"
git push origin main vx.y.z

scripts/package.sh x.y.z          # builds dist/ archive and checksum
# 3. GitHub: create the release from the tag, attach the .tar.gz and the .sha256
# 4. deploy as described in deployment.md
git switch development && git merge main
```

## Before every release

- `scripts/check-pf-vars.py` exits with 0.
- `docs/testing.md`: functional, visual and accessibility checks for the changed pages.
- `NOTICE` is current (new third-party files, changed fonts).
- No realm provisioning files and no secrets in the repository.
