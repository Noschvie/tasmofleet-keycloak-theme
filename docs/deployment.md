# Deployment

## Development

See `dev/compose.yaml`. Theme caching is disabled via
`--spi-theme--static-max-age=-1`, `--spi-theme--cache-themes=false`,
`--spi-theme--cache-templates=false` (verify option names for 26.8.x).

## Production (Eibesthal)

Target: Keycloak 26.8.2 in Docker behind Nginx Proxy Manager.

Order (requirements 6.3):

1. Deploy the theme.
2. Verify availability (theme selectable in the Admin Console).
3. Set `loginTheme = tasmofleet` in the realm JSON of the Keycloak
   configuration project and provision.
4. Verify login page.
5. Test the OIDC integration.

### Volume

TODO: host path, read-only mount to `/opt/keycloak/themes/tasmofleet`.

### Ownership and permissions

TODO: owner, mode, write access restricted.

### Caching and restart

TODO: production caching stays enabled; restart required after theme update.

### Rollback

TODO: keep the previous release directory, switch back, restart.
