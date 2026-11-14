# Design decisions

## Open questions

| ID | Question | Status | Notes |
|---|---|---|---|
| OQ-01 | Parent theme | **Decided 2026-11-13** | `keycloak.v2`; `styles=css/styles.css css/tasmofleet-login.css` verified on 26.8.2 (both stylesheets are loaded) |
| OQ-02 | Logo and favicon | Open | Asked in https://github.com/hellwand/tasmofleet/issues/830; neutral placeholder logo and a generated placeholder favicon are in use. Replace `logo.svg` and `favicon.ico` after the answer |
| OQ-03 | Font assets | Decided (initial) | Geist latin and latin-ext woff2 bundled with OFL.txt; copied from the TasmoFleet repo, confirmation asked in https://github.com/hellwand/tasmofleet/issues/830 |
| OQ-04 | Dark mode switch | Decided (initial) | System preference only |
| OQ-05 | Footer | **Decided 2026-11-14** | None. The upstream sign-in footer shows the application version and host, which Keycloak does not know |
| OQ-06 | Repository licence | **Decided 2026-11-13** | AGPL-3.0-or-later |
| OQ-07 | Theme packaging | **Decided 2026-11-14** | Release archive (`scripts/package.sh`) unpacked on the host, read-only Docker volume, see `deployment.md` |
| OQ-08 | Upstream contribution | Open | Link from the Keycloak documentation asked in https://github.com/hellwand/tasmofleet/issues/830, page or PR after the first release |

## Decision log

### OQ-06 Licence (2026-11-13)
AGPL-3.0-or-later. Chosen deliberately instead of CC BY-NC-SA, which is
unusual for software artefacts. Keycloak-derived files keep their
Apache-2.0 notices (see NOTICE). Fonts stay under OFL. Brand assets
are not covered by the AGPL.

## Design tokens

Source: TasmoFleet `docs/spec/design-system.md` (token table) and
`internal/web/static/app.css`. Upstream is `hellwand/tasmofleet`. The values were first
read from the copy `Noschvie/TasmoFleet` (branch `main`, 2026-11-13) and compared with
`hellwand/tasmofleet` `main` on 2026-11-14: `design-system.md`, `assets/branding/logo.svg`
and the Geist woff2 files are byte-identical; `app.css` differs only in unrelated parts
(tables, tooltips, a list of known devices), not in tokens, auth card or banners.
Commit hash not recorded (GitHub API was rate limited); record it on the next sync.

Names and values are copied verbatim from the token table into
`tasmofleet-login.css`. Only the subset used by the login pages is included.

| Topic | Decision |
|---|---|
| Dark mode | Keycloak sets `pf-v5-theme-dark` on `<html>` before first paint; dark tokens use `:root.pf-v5-theme-dark` (upstream uses `data-theme`) |
| PatternFly mapping | Tokens are mapped to `--pf-v5-global--*` and `--pf-v5-c-*` variables first, direct rules only where PatternFly draws borders itself |
| Card | 420 px, radius 12, padding 24, border 1 px `--color-border`, no shadow (upstream `.auth-card`) |
| Heading | `600 20px/1.2`, letter-spacing -0.015em |
| Controls | height 34 px, radius 7, strong border, 13.5 px text; primary button 38 px (`btn-tall`), 600 13px |
| Brand | Mark 28 px and name `600 18px`, centred above the card (upstream `.page-auth .brand`) |
| Product name | Realm display name `TasmoFleet` (D15); CSS does not change the text |
| `!important` | One use, on `#kc-header-wrapper`, because Keycloak sets its colour with `!important` |
| Banners | `.pf-v5-c-alert` styled like upstream `.banner`: 1 px tone border, tone background, 8 px dot instead of the Font Awesome glyph, 13 px text, weight 500. Tones: warning, danger, success, default (info) = accent |
| Field errors | `.pf-m-error` / `aria-invalid="true"`: danger border, helper text `600 12px` in `--color-danger-fg` (upstream `.field-error`) |
| Secondary button | Surface, strong border, `500 13px`, 34 px (upstream `.btn`) |
| Running text | `13.5px/1.45`, `--color-text-2` (upstream `.auth-text`) |
| Info band | Hairline top border, left aligned, no extra padding |
| QR code | Always a white ground, 1 px border, radius 10, no shadow |
| Footer | Not implemented (OQ-05) |

## Accessibility audit (2026-11-13)

Contrast ratios computed from the upstream tokens (WCAG relative luminance).
All text pairs pass AA (4.5:1) in light and dark: text, `text-2`, `text-3`, links,
primary button, error text, banners (warning, danger, success, info), focus ring (about 6:1).

| Finding | Ratio | Decision |
|---|---|---|
| Control border `--color-border-strong` on card, light | 1.67:1 (needs 3:1, WCAG 1.4.11) | Keep the upstream value; reported as https://github.com/hellwand/tasmofleet/issues/829 |
| Control border on card, dark | 1.75:1 | same |

Candidate values for a dedicated control-border token, included in the issue:
light `#808a94` (3.5:1 on card), dark `#68737f` (3.7:1 on card).

## Template overrides

Every FreeMarker override is listed here with reason and the Keycloak
version of the upstream base template.

| Template | Reason | Base version |
|---|---|---|
| none yet | | |
