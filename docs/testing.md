# Testing

Test realm: `dev/realm-tasmofleet-test.json`
(users `alice`, `bob` update-password, `carol` configure-OTP, passwords equal to the username).

## Functional

- [x] Successful login (alice), 2026-11-14 (the account console needs HTTPS or localhost, see below)
- [x] Invalid credentials
- [x] Forgot password page
- [x] Update password required action (bob)
- [x] Configure OTP required action (carol)
- [x] Logout confirmation page (button and back link)
- [x] Error page (invalid redirect URI)
- [ ] Logout redirect to the application and OTP login with an existing device: check after deployment

## Automatic: `dev/smoke-test.sh`

Run it after every change and before every release. It covers part of the functional and
integration tests below for the dev realm: theme active, stylesheet, font and favicon served,
no external requests, Keycloak security headers, invalid credentials, successful sign-in with
redirect to the application, logout page. Keyboard navigation, screen readers and the
visual checks stay manual.

## Pages captured by `dev/capture-pages.sh`

- [x] Login with wrong password: red field border, status icon, error text under the field
- [x] Update password (`bob`): warning banner with dot, two password fields, checkbox
- [x] Configure OTP (`carol`): list, QR code (white ground in dark mode), fields
- [x] Forgot password: secondary button "Back to Login", info band
- [x] Danger banner "account disabled" (captured with disabled users, light mode, 375 px)
- [x] Timeout banner "login attempt timed out" (light and dark, 375 px)
- [x] Favicon in the browser tab is the TasmoFleet one (blue tile, white ring)
- [ ] Not seen: OTP login (user with OTP), success banner, password policy errors, verify e-mail (needs SMTP)
- [x] Error page and logout confirmation (light and dark)
- [x] 375 px: OTP heading without a broken word (after the narrow-screen change)

Note: the Keycloak account console (`/realms/<realm>/account`) is a JavaScript app that needs a secure context (HTTPS or `localhost`). Over plain HTTP from another host it shows "An error occurred". That is not a theme problem and not part of this theme.

## Visual (light / dark x desktop / tablet / mobile)

- [x] Login
- [x] Validation and error states
- [x] Required action pages
- [ ] Language switch (en, de)
- [ ] Card width 420 px, radius 12, padding 24 (DevTools)
- [ ] Geist loads (Network tab, no external requests)
- [ ] Gap between brand and card is 20 px in light and dark

## Accessibility (WCAG AA)

- [ ] Contrast
- [ ] Keyboard navigation and visible focus
- [ ] Labels and error messages
- [ ] Reduced motion

## Integration

- [ ] Theme available in Keycloak
- [ ] Realm provisioning and update
- [ ] OIDC login from TasmoFleet
- [ ] Docker restart
- [ ] Theme update and rollback

## Upgrade (per Keycloak release)

- [ ] Review overridden templates against upstream
- [ ] Check theme properties and CSS
- [ ] Run all functional tests

## Status of the acceptance criteria (requirements, section 16), 2026-11-14

| Criterion | Status |
|---|---|
| Dedicated `tasmofleet` realm | Dev realm exists; production realm belongs to the configuration project |
| Existing `knx` realm unaffected | Not touched by the theme; verify after deployment |
| Realm provisioning selects the theme | Theme works in the production realm (2026-11-14). The brand name is a realm setting (`displayName`, `displayNameHtml`) and had to be corrected by hand; both must be set in the configuration project together with `loginTheme: "tasmofleet"` |
| TasmoFleet design specification followed | Done (tokens, card, controls, banners); one open point: control border contrast, issue hellwand/tasmofleet#829 |
| Logo and font licensing clarified | Done: answered in hellwand/tasmofleet#830; logo, favicon, fonts and tokens come from tag v0.36.1 (AGPL repository, OFL fonts) |
| Light and dark appearance | Done, checked on the captured pages |
| Responsive layout | Done for 375 px (sign-in, banner, OTP); tablet widths not checked separately |
| Keycloak authentication fully functional | Sign-in, error, forgot password, update password, OTP setup, error page and logout seen; the redirect to the application is checked after deployment |
| Existing OIDC integration works | Done: complete OIDC login from TasmoFleet on Eibesthal, 2026-11-14 |
| Logout and redirects work | Logout confirmation seen; redirects are checked after deployment |
| Accessibility requirements fulfilled | Contrast audited (one open point, see above); keyboard navigation and screen reader not yet tested |
| Docker deployment documented | Done, `deployment.md` (paths are assumptions) |
| Rollback documented | Done, `deployment.md` |
| Keycloak upgrade requirements documented | Done, `upgrading.md` |
