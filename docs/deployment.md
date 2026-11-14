# Deployment

Target: Keycloak 26.8.2 in Docker on Eibesthal, behind Nginx Proxy Manager, LAN only.
The theme is a directory that Keycloak reads from `/opt/keycloak/themes/tasmofleet`.
No custom Keycloak image is needed (requirements, section 13).

> The paths below are assumptions, because the production compose file is not part of
> this repository. Adjust them to your setup; the order of the steps stays the same.

## 1. Release archive

```bash
scripts/package.sh 0.1.0
# dist/tasmofleet-keycloak-theme-0.1.0.tar.gz and .sha256
```

The archive holds one folder `tasmofleet/` with `login/`, `LICENSE`, `NOTICE`, `VERSION`.
Deploy only archives built from a tag on `main` (see `releasing.md`).

## 2. Directory layout on the host

Every release lives in its own folder, a symlink points to the active one:

```text
/srv/keycloak/themes/
  releases/
    0.1.0/tasmofleet/     <- unpacked archive
    0.1.1/tasmofleet/
  tasmofleet -> releases/0.1.0/tasmofleet
```

```bash
sudo mkdir -p /srv/keycloak/themes/releases/0.1.0
sudo tar -xzf tasmofleet-keycloak-theme-0.1.0.tar.gz -C /srv/keycloak/themes/releases/0.1.0
sudo ln -sfn releases/0.1.0/tasmofleet /srv/keycloak/themes/tasmofleet
```

Ownership and permissions: owner `root`, directories `755`, files `644`. The Keycloak
container runs as an unprivileged user and only needs read access. Nobody except
root can change the theme files (requirements, section 10).

## 3. Compose

Add one read-only volume to the existing Keycloak service:

```yaml
services:
  keycloak:
    volumes:
      - /srv/keycloak/themes/tasmofleet:/opt/keycloak/themes/tasmofleet:ro
```

Nothing else changes: no ports, no proxy settings, no environment variables.

## 4. Caching and restart

- Production (`start`): Keycloak caches themes and templates. A changed theme is
  only picked up after the container has been recreated.
- Development (`dev/compose.yaml`): caching is switched off, see `README.md`.
- Docker resolves the symlink when the container is **created**. A plain
  `docker restart` keeps the old release mounted. Use:

  ```bash
  docker compose up -d --force-recreate keycloak
  ```

- After a recreate the resource URLs contain a new hash, browsers load the new CSS
  automatically. A hard reload is only needed if a page was open during the update.

## 5. Order of activation

1. Deploy the theme (steps 1 to 4).
2. Verify availability: Admin Console, realm `tasmofleet` (or any test realm),
   Realm settings, Themes: `tasmofleet` is listed under Login theme.
3. Provision or update the realm in the Keycloak configuration project. It must set
   - `loginTheme: "tasmofleet"`
   - `displayName: "TasmoFleet"` (the brand above the card is the realm's display name; without it the lower-case realm name is shown)
4. Open the login page and compare it with the screenshots in `README.md`.
5. Test the OIDC login from TasmoFleet end to end (login, redirect, logout).

The theme repository does not contain realm provisioning, and the realm provisioning does
not contain theme files (requirements, section 6.2).

## 6. Update

```bash
sudo mkdir -p /srv/keycloak/themes/releases/0.1.1
sudo tar -xzf tasmofleet-keycloak-theme-0.1.1.tar.gz -C /srv/keycloak/themes/releases/0.1.1
sudo ln -sfn releases/0.1.1/tasmofleet /srv/keycloak/themes/tasmofleet
docker compose up -d --force-recreate keycloak
```

Then run the checklist in `testing.md` for the changed pages.

## 7. Rollback

```bash
sudo ln -sfn releases/0.1.0/tasmofleet /srv/keycloak/themes/tasmofleet
docker compose up -d --force-recreate keycloak
```

The previous release folder stays on disk, so a rollback takes one symlink and one recreate.
Keep at least the last two releases and delete older ones by hand.

If the theme itself is broken and the login page cannot be used, select another login theme
(`keycloak.v2`) for the realm in the Admin Console. The Admin Console of the `master` realm
is not affected by this theme.

## 8. Troubleshooting

| Symptom | Check |
|---|---|
| Theme is not in the list | Mount path, `docker exec keycloak ls /opt/keycloak/themes/tasmofleet/login`, file permissions |
| Login page looks like the default | Realm setting `loginTheme`; in the page source, resource paths must contain `/login/tasmofleet/` |
| Old CSS after an update | Container was restarted, not recreated (symlink); recreate it |
| Brand shows `tasmofleet` in lower case | Realm `displayName` is not set |
| Fonts missing | Network tab: `geist-latin.woff2` must load from the same origin |
