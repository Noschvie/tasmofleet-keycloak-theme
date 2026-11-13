
# TasmoFleet Keycloak Login Theme

**Requirements & Architecture Document**

Version: 0.3  
Status: Draft – For Maintainer Review  
Date: 2026-11-13

## 1. Project Overview

The goal of this project is to provide a custom Keycloak login theme
that follows the visual identity and design principles of TasmoFleet.

TasmoFleet uses Keycloak for authentication via OpenID Connect (OIDC).
The integration is functional. However, the standard Keycloak login
page differs visually from the TasmoFleet application.

This project aims to create a consistent user experience by adapting
the Keycloak login interface to the TasmoFleet design system.

The theme will be maintained as an independent project.

The project is initially intended for personal use, with the possibility
of making it available to the TasmoFleet community.

## 2. Project Goals

- Consistent TasmoFleet look & feel.
- Strict adherence to the existing TasmoFleet design system.
- Support for light and dark appearance.
- Responsive desktop and mobile layouts.
- Native Keycloak authentication functionality.
- Minimal maintenance effort during Keycloak upgrades.
- Independent versioning and deployment.
- Reproducible integration with the TasmoFleet Keycloak realm.

## 3. Non-Goals

The project does not aim to:

- Modify the TasmoFleet application itself.
- Implement authentication logic.
- Modify the existing OIDC integration.
- Replace Keycloak functionality.
- Customize the Keycloak Admin Console.
- Customize the Account Console.
- Introduce additional authentication methods.
- Maintain a separate copy of the TasmoFleet design system.

## 4. Design Authority

The TasmoFleet repository is the authoritative source for the
visual design.

The following references shall be used:

1. `docs/spec/design-system.md`
2. `design/v2/`
3. Running TasmoFleet `/styleguide`
4. Existing official branding and assets.

The implementation must follow the current upstream design specification.

### 4.1 Login Component

The primary design reference is:

`ui.AuthCard(base, version, host)`

The component defines the visual structure of the authentication card.

Relevant design properties include:

- Brand mark above the card.
- Maximum card width of approximately 420 px.
- Card radius of 12 px.
- Card padding of 24 px.
- Sign-in heading: 20 px, semibold.
- Geist and Geist Mono typography.
- Consistent form controls and feedback messages.

Exact values must be verified against the current upstream
design-system specification before implementation.

### 4.2 Design Requirements

The theme must implement:

- TasmoFleet typography.
- TasmoFleet colour tokens.
- Consistent input fields and buttons.
- Consistent border and radius definitions.
- Light and dark appearance.
- Responsive spacing.
- Accessible contrast and focus indicators.

The theme must not introduce an independent visual language.

### 4.3 Branding and Licensing

Before using upstream assets:

- Confirm the preferred TasmoFleet logo with the maintainer.
- Verify asset redistribution permissions.
- Verify Geist font licensing and include required notices.
- Preserve all applicable attribution and licence information.

The project must not imply official upstream ownership
or endorsement without explicit approval.

## 5. Authentication Architecture

### 5.1 Dedicated Keycloak Realm

A dedicated Keycloak realm named `tasmofleet` will be used.

This realm is separate from the existing `knx` realm.

The purpose is to isolate TasmoFleet authentication and
allow independent configuration and future development.

Initial structure:

    Keycloak
    |
    +-- Realm: knx
    |     |
    |     +-- Existing KNX applications
    |
    +-- Realm: tasmofleet
          |
          +-- Client: tasmofleet
          |
          +-- TasmoFleet users
          |
          +-- Login Theme: tasmofleet

### 5.2 OIDC Client

The initial client configuration follows the existing
TasmoFleet integration.

| Setting | Value |
|---|---|
| Client ID | tasmofleet |
| Client authentication | ON |
| Standard flow | ON |
| Direct access grants | OFF |
| Service accounts | OFF |

Existing redirect URIs, logout configuration, client secrets
and other OIDC parameters remain managed by the realm
configuration project.

The theme must not change any of these settings.

### 5.3 Authentication Responsibility

Keycloak remains responsible for:

- User authentication.
- Password verification.
- Session management.
- Authentication flows.
- Required actions.
- OIDC authorization and token handling.
- Logout processing.

The custom theme is presentation-only.

## 6. Keycloak Configuration as Code

The TasmoFleet realm will be provisioned and maintained
through the existing Keycloak configuration-as-code project.

The configuration project uses:

- JSON files as the source of truth.
- Provisioning scripts.
- Controlled updates to existing realms.
- CI/CD integration.

The scripts must support both initial provisioning and
controlled updates.

### 6.1 Source of Truth

The JSON configuration files are authoritative.

Manual changes in the Keycloak Admin Console must not
become an alternative configuration source.

The provisioning process should:

- Create missing managed objects.
- Update existing managed objects.
- Preserve unmanaged settings.
- Avoid destructive operations.
- Never delete objects automatically without an explicit
  and separately approved operation.

### 6.2 Theme Selection

The realm configuration must select:

    loginTheme = tasmofleet

The selection is part of the managed realm configuration.

Keycloak's RealmRepresentation supports the `loginTheme`
property.

The theme itself remains an independent deployment artifact.

The realm provisioning scripts must not contain or
duplicate the theme's CSS, templates or image assets.

### 6.3 Deployment Dependency

The theme must be available to Keycloak before the
realm configuration activates it.

Expected deployment order:

1. Deploy the custom theme.
2. Verify theme availability.
3. Provision or update the `tasmofleet` realm.
4. Verify the login page.
5. Test the OIDC integration.

This avoids configuring a theme that Keycloak cannot load.

## 7. Technical Architecture

### 7.1 Target Environment

| Component | Configuration |
|---|---|
| Identity Provider | Keycloak |
| Keycloak version | 26.8.2 |
| Deployment | Docker |
| Host | Eibesthal |
| Reverse Proxy | Nginx Proxy Manager |
| Proxy host | Baumgarten |
| Access | Internal LAN |
| TLS | Let's Encrypt certificate |
| Public Internet access | Not directly accessible |

The existing network and reverse-proxy configuration
must remain unchanged.

### 7.2 Theme Structure

Proposed directory structure:

    tasmofleet-keycloak-theme/
    |
    +-- README.md
    +-- LICENSE
    +-- CHANGELOG.md
    |
    +-- theme/
    |   |
    |   +-- tasmofleet/
    |       |
    |       +-- login/
    |           |
    |           +-- theme.properties
    |           +-- resources/
    |               |
    |               +-- css/
    |               |   +-- tasmofleet-login.css
    |               |
    |               +-- img/
    |               |   +-- logo.svg
    |               |
    |               +-- fonts/
    |
    +-- docs/
        +-- design-decisions.md
        +-- deployment.md
        +-- testing.md

The final structure may be adjusted during implementation.

### 7.3 Theme Implementation Strategy

The preferred approach is CSS-first.

Priority:

1. Existing Keycloak theme functionality.
2. Theme properties.
3. Custom CSS.
4. Custom images and fonts.
5. FreeMarker template overrides only when necessary.

Every template override must be documented.

Keycloak's built-in functionality must not be unnecessarily
reimplemented.

The initial parent theme must be selected after compatibility
testing against Keycloak 26.8.2.

## 8. Light and Dark Appearance

Both appearance modes are required.

The implementation should use the Keycloak theme mechanism
and TasmoFleet design tokens.

Requirements:

- Respect the user's system appearance preference.
- Maintain readable contrast.
- Avoid unnecessary JavaScript.
- Avoid visual flickering during page loading.
- Ensure both modes are tested independently.

A manually selectable theme switch is optional and
subject to design review.

## 9. Functional Requirements

The theme must preserve all relevant Keycloak login states.

### Login

- Username and password.
- Password visibility control, if enabled.
- Remember-me, if enabled.
- Forgot-password flow, if enabled.
- Error messages.
- Validation messages.

### Additional Authentication States

- Required actions.
- Password update.
- Account verification.
- OTP, if enabled.
- Localisation.
- Authentication failure.

All functionality must continue to use Keycloak's native
authentication mechanisms.

## 10. Security Requirements

- No custom credential handling.
- No storage of passwords or tokens.
- No weakening of OIDC security.
- No modification of redirect URI validation.
- No unnecessary JavaScript.
- No external runtime dependencies.
- Preserve Keycloak security headers and CSP.
- Restrict write access to deployed theme files.
- Review all custom FreeMarker templates.

## 11. Accessibility and Responsive Design

The theme must support:

- Desktop browsers.
- Tablet layouts.
- Mobile browsers.
- Keyboard navigation.
- Visible focus indicators.
- Semantic form labels.
- Accessible error messages.
- Appropriate colour contrast.
- Reduced-motion preferences.

WCAG AA is the accessibility target.

## 12. Testing Requirements

### Functional Tests

- Successful login.
- Invalid credentials.
- Logout.
- Redirect to TasmoFleet.
- Session handling.
- Password reset, if enabled.
- Required actions.

### Visual Tests

- Light appearance.
- Dark appearance.
- Desktop.
- Tablet.
- Mobile.
- Form validation.
- Error states.

### Integration Tests

- Theme availability in Keycloak.
- Realm provisioning.
- Realm updates.
- Existing OIDC configuration.
- Docker restart.
- Theme update and rollback.

### Upgrade Tests

For each Keycloak upgrade:

- Review overridden templates.
- Compare them with upstream templates.
- Check theme properties.
- Check CSS compatibility.
- Test authentication flows.

## 13. Deployment and Maintenance

The theme will initially be deployed through a read-only
Docker volume.

A custom Keycloak image is not required for the first iteration.

Production deployment must document:

- Volume configuration.
- File ownership and permissions.
- Theme caching.
- Restart requirements.
- Rollback procedure.

Development and production caching settings must be
distinguished.

The theme must be independently versioned and released.

## 14. Repository and Project Independence

The theme will have its own repository.

It will not be part of the TasmoFleet application repository.

It will not contain a second copy of the realm provisioning scripts.

Responsibilities:

| Project | Responsibility |
|---|---|
| TasmoFleet | Application and design system |
| Keycloak Configuration | Realm, clients, users and provisioning |
| Keycloak Theme | Login presentation |

The theme repository should reference the upstream
TasmoFleet design specification.

## 15. Maintainer Review

A review by the TasmoFleet maintainer is recommended
before implementation.

The review should address:

1. Correct interpretation of the TasmoFleet design system.
2. Use of `ui.AuthCard` as the login design reference.
3. Preferred logo and branding assets.
4. Font usage and licensing.
5. Light and dark appearance.
6. Design details not covered by the specification.
7. Potential documentation contribution.

The maintainer has indicated that an independently
developed Keycloak theme could be linked from the
TasmoFleet Keycloak documentation.

The project remains independently maintained.

## 16. Acceptance Criteria

- [ ] Dedicated `tasmofleet` realm.
- [ ] Existing `knx` realm remains unaffected.
- [ ] Realm provisioning selects the `tasmofleet` login theme.
- [ ] TasmoFleet design specification followed.
- [ ] Logo and font licensing clarified.
- [ ] Light and dark appearance supported.
- [ ] Responsive layout implemented.
- [ ] Keycloak authentication remains fully functional.
- [ ] Existing OIDC integration works.
- [ ] Logout and redirects work.
- [ ] Accessibility requirements fulfilled.
- [ ] Docker deployment documented.
- [ ] Rollback documented.
- [ ] Keycloak upgrade requirements documented.

## 17. Open Decisions

| ID | Question | Initial Direction |
|---|---|---|
| OQ-01 | Theme parent | Evaluate against Keycloak 26.8.2 |
| OQ-02 | Logo | Confirm with maintainer |
| OQ-03 | Font assets | Verify licensing |
| OQ-04 | Dark mode switch | System preference initially |
| OQ-05 | Footer | Minimal or none |
| OQ-06 | Repository licence | **Decided 2026-11-13: AGPL-3.0-or-later** |
| OQ-07 | Theme packaging | Docker volume initially |
| OQ-08 | Upstream contribution | Discuss after first working version |

## 18. References

### TasmoFleet

- Repository:
  https://github.com/Noschvie/TasmoFleet

- Design system:
  https://github.com/Noschvie/TasmoFleet/blob/main/docs/spec/design-system.md

- Design overview:
  https://github.com/Noschvie/TasmoFleet/blob/main/design/README.md

- Live styleguide:
  `/styleguide`

### Keycloak

- Theme customisation:
  https://www.keycloak.org/ui-customization/themes

- Keycloak 26.8.2 upgrade guide:
  https://www.keycloak.org/docs/26.8.2/upgrading/

- RealmRepresentation API:
  https://www.keycloak.org/docs-api/26.8.0/javadocs/org/keycloak/representations/idm/RealmRepresentation.html

---

**Document status:** Draft 0.3 – For Maintainer Review.

Implementation should begin after the design references,
branding requirements and technical architecture have been reviewed.
