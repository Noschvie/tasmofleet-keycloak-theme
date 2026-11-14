# Testing

Test realm: `dev/realm-tasmofleet-test.json`
(users `alice`, `bob` update-password, `carol` configure-OTP, passwords equal to the username).

## Functional

- [ ] Successful login (alice)
- [ ] Invalid credentials
- [ ] Forgot password page
- [ ] Update password required action (bob)
- [ ] Configure OTP required action (carol)
- [ ] Logout and redirect
- [ ] Error page

## Pages captured by `dev/capture-pages.sh`

- [ ] Login with wrong password: red field border, status icon, error text under the field
- [ ] Update password (`bob`): warning banner with dot, two password fields, checkbox
- [ ] Configure OTP (`carol`): list, QR code (white ground in dark mode), fields
- [ ] Forgot password: secondary button "Back to Login", info band
- [x] Danger banner "account disabled" (captured with disabled users, light mode, 375 px)
- [x] Timeout banner "login attempt timed out" (light and dark, 375 px)
- [ ] Favicon in the browser tab is the TasmoFleet one (depends on OQ-02, currently Keycloak's)
- [ ] Not yet seen: OTP login (user with OTP), error page ("We are sorry", invalid redirect URI), logout confirmation, success banner, password policy errors, verify e-mail (needs SMTP)
- [ ] 375 px: OTP heading without a broken word (after the narrow-screen change)

## Visual (light / dark x desktop / tablet / mobile)

- [ ] Login
- [ ] Validation and error states
- [ ] Required action pages
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
| Realm provisioning selects the theme | Open: `loginTheme` and `displayName` in the configuration project |
| TasmoFleet design specification followed | Done (tokens, card, controls, banners); one open point: control border contrast, issue hellwand/tasmofleet#829 |
| Logo and font licensing clarified | Open: asked in hellwand/tasmofleet#830; fonts and tokens come from the AGPL repository, the logo is a placeholder |
| Light and dark appearance | Done, checked on the captured pages |
| Responsive layout | Done for 375 px (sign-in, banner, OTP); tablet widths not checked separately |
| Keycloak authentication fully functional | Sign-in, error, forgot password, update password and OTP setup seen; successful login with redirect still to be checked |
| Existing OIDC integration works | Open: check after deployment |
| Logout and redirects work | Open: check after deployment, logout page not yet seen |
| Accessibility requirements fulfilled | Contrast audited (one open point, see above); keyboard navigation and screen reader not yet tested |
| Docker deployment documented | Done, `deployment.md` (paths are assumptions) |
| Rollback documented | Done, `deployment.md` |
| Keycloak upgrade requirements documented | Done, `upgrading.md` |
