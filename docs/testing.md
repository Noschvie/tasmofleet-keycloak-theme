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

## Visual (light / dark x desktop / tablet / mobile)

- [ ] Login
- [ ] Validation and error states
- [ ] Required action pages
- [ ] Language switch (en, de)

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
