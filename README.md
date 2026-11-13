# tasmofleet-keycloak-theme

Custom Keycloak **login theme** that follows the visual identity of
[TasmoFleet](https://github.com/Noschvie/TasmoFleet).

> Status: early scaffold (v0.0.0). Not an official TasmoFleet project.
> The design values are placeholders until verified against the upstream
> design specification.

## Scope

- Presentation only: no authentication logic, no changes to OIDC settings.
- Login theme only (no Admin Console, no Account Console).
- CSS-first; FreeMarker overrides only where unavoidable and documented.
- Light and dark appearance via system preference.

## Quick start (development)

```bash
cd dev
docker compose up -d
# Admin Console: http://localhost:8080  (admin / admin, dev only)
# Login page:    http://localhost:8080/realms/tasmofleet/account
```

Theme caching is disabled in the dev setup, so CSS changes show up on reload.

## Repository layout

| Path | Content |
|---|---|
| `theme/tasmofleet/login/` | The theme (deployable artifact) |
| `dev/` | Development Keycloak and test realm |
| `docs/requirements.md` | Requirements and architecture (v0.3) |
| `docs/design-decisions.md` | Open questions, decisions, template overrides |
| `docs/deployment.md` | Deployment, caching, rollback |
| `docs/testing.md` | Test matrix and checklists |

## Related projects

| Project | Responsibility |
|---|---|
| TasmoFleet | Application and design system |
| Keycloak configuration (config-as-code) | Realm, clients, users, `loginTheme` selection |
| This repository | Login presentation |

## License

AGPL-3.0-or-later, see `LICENSE`. Third-party components and their
licences are listed in `NOTICE`.
