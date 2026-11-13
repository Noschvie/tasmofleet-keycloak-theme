# Design decisions

## Open questions

| ID | Question | Status | Notes |
|---|---|---|---|
| OQ-01 | Parent theme | Open | Verify `keycloak.v2` and style names on 26.8.2 (Phase 2) |
| OQ-02 | Logo | Open | Confirm with maintainer; placeholder in use |
| OQ-03 | Font assets | Open | Geist is OFL 1.1; add notice when bundling |
| OQ-04 | Dark mode switch | Decided (initial) | System preference only |
| OQ-05 | Footer | Open | Minimal or none |
| OQ-06 | Repository licence | **Decided 2026-11-13** | AGPL-3.0-or-later |
| OQ-07 | Theme packaging | Decided (initial) | Read-only Docker volume |
| OQ-08 | Upstream contribution | Open | After first working version |

## Decision log

### OQ-06 Licence (2026-11-13)
AGPL-3.0-or-later. Chosen deliberately instead of CC BY-NC-SA, which is
unusual for software artefacts. Keycloak-derived files keep their
Apache-2.0 notices (see NOTICE). Fonts stay under OFL. Brand assets
are not covered by the AGPL.

## Design tokens

To be filled from upstream `docs/spec/design-system.md`, `design/v2/`
and `/styleguide`. Record source and upstream commit for each value.

| Token | Light | Dark | Source |
|---|---|---|---|
| | | | |

## Template overrides

Every FreeMarker override is listed here with reason and the Keycloak
version of the upstream base template.

| Template | Reason | Base version |
|---|---|---|
| none yet | | |
