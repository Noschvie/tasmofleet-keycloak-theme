# Changelog

All notable changes are documented here.
Format based on Keep a Changelog, versioning follows SemVer.

## [Unreleased]

## [0.1.0] - 2026-11-14

First release.

### Added
- Repository scaffold, development environment and test realm.
- AGPL-3.0-or-later licence (OQ-06).
- Iteration 1 of the login CSS: TasmoFleet tokens (light/dark), 420 px card,
  Geist fonts, form controls, primary button, brand above the card.

- Iteration 2 of the login CSS, derived from captured pages: banners (PatternFly
  alerts in the upstream banner style with dot and tone colours), field errors,
  secondary button, running text and lists, info band, QR code on the OTP page.

- Logout confirmation: spacing above the "back to application" link.

- Narrow screens (up to 30 rem): the language select moves above the title, so long words such as "Mehrfachauthentifizierung" are no longer broken in the middle.

- Real TasmoFleet logo and favicon (`img/logo.svg`, `img/favicon.ico`, release v0.36.1), allowed by the maintainer in hellwand/tasmofleet#830; NOTICE names source, path and tag. `favicon.svg` is not bundled: Keycloak's template links only `favicon.ico`.
- Unofficial-community wording in README, NOTICE, `theme.properties` and CSS header; tokens pinned to tag v0.36.1.
- README with screenshots; documentation for deployment, releasing and upgrading.

### Added (tooling)
- `dev/capture-pages.sh` snapshots login pages of the dev realm to `dev/snapshots/`.
- `dev/smoke-test.sh` checks theme, assets, headers, sign-in and logout against the dev realm; `dev/capture-pages.sh` also saves the error and logout pages.
- `scripts/package.sh` builds the release archive, `scripts/check-pf-vars.py` checks PatternFly variables.

### Fixed
- Password field: remove the divider and tinted background around the visibility button (dark mode).
- "Remember me": align the checkbox with its label (PatternFly variables instead of direct font rules).
- Brand: the gap to the card is 20 px, set through PatternFly's brand margin variable (the earlier attempt with 0 removed the gap completely).
- Buttons in forms are as wide as the fields again (parent and child margins of `.pf-v5-c-form__actions` are reset together).
- OTP page: bullets for the list of supported apps.
- Language select is compact, so the German heading fits on one line at card width.

### Changed
- Dev compose port is configurable (`KC_DEV_PORT`, default 8040).
- Dev realm sets the display name `TasmoFleet`.
