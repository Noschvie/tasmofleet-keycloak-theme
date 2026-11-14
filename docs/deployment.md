# Deployment

Target: Keycloak 26.8.2 in Docker on Eibesthal, behind Nginx Proxy Manager, LAN only.
The theme is a directory that Keycloak reads from `/opt/keycloak/themes/tasmofleet`.
No custom Keycloak image is needed (requirements, section 13).

> The paths below are assumptions, because the production compose file is not part of
> this repository. Adjust them to your setup; the order of the steps stays the same.

## 1. Get the release

Every release is a tag on `main` (see `releasing.md`). Download the source archive that
GitHub attaches to the tag ("Source code (tar.gz)") and unpack it; the theme is the folder
`theme/tasmofleet`. `LICENSE` and `NOTICE` stay next to it.

GitHub does not guarantee stable checksums for these generated archives, so none is
published. If you want to verify the content, compare it with the tag in a clone
(`git clone --branch v0.1.1 <repository>`).

Deploy only tags on `main`. `scripts/package.sh` is optional (an archive with the theme alone).

## 2. Directory layout on the host

Every release lives in its own folder, a symlink points to the theme inside the active one:

```text
/srv/keycloak/themes/
  releases/
    0.1.1/                <- unpacked source archive
      theme/tasmofleet/   <- the Keycloak theme
      LICENSE  NOTICE  docs/ ...
    0.1.2/
  tasmofleet -> releases/0.1.1/theme/tasmofleet
```

```bash
sudo mkdir -p /srv/keycloak/themes/releases/0.1.1
sudo tar -xzf tasmofleet-keycloak-theme-0.1.1.tar.gz --strip-components=1 \
  -C /srv/keycloak/themes/releases/0.1.1
sudo ln -sfn releases/0.1.1/theme/tasmofleet /srv/keycloak/themes/tasmofleet
```

(The file name of the download is `tasmofleet-keycloak-theme-<version>.tar.gz` for a tag `v<version>`;
`--strip-components=1` removes the top folder whatever its name is.)

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
   the following realm attributes:

   | Realm attribute | Value | Admin Console (Realm settings) | Used for |
   |---|---|---|---|
   | `loginTheme` | `tasmofleet` | Themes → Login theme | Activates the theme |
   | `displayName` | `TasmoFleet` | General → Display name | Browser tab title, e-mails |
   | `displayNameHtml` | `TasmoFleet` | General → HTML Display name | Brand above the login card |

   The brand name is **not** part of the theme. Keycloak takes it from the realm and
   falls back to the technical realm name (`tasmofleet`, lower case) when the display
   names are empty. Changes take effect immediately, without a recreate.
   If you set the values by hand in the Admin Console, also add them to the realm
   provisioning, otherwise the next import overwrites them.
4. Open the login page and compare it with the screenshots in `README.md`.
5. Test the OIDC login from TasmoFleet end to end (login, redirect, logout).

The theme repository does not contain realm provisioning, and the realm provisioning does
not contain theme files (requirements, section 6.2).

## 6. Update

```bash
sudo mkdir -p /srv/keycloak/themes/releases/0.1.2
sudo tar -xzf tasmofleet-keycloak-theme-0.1.2.tar.gz --strip-components=1 \
  -C /srv/keycloak/themes/releases/0.1.2
sudo ln -sfn releases/0.1.2/theme/tasmofleet /srv/keycloak/themes/tasmofleet
docker compose up -d --force-recreate keycloak
```

Then run the checklist in `testing.md` for the changed pages.

## 7. Rollback

```bash
sudo ln -sfn releases/0.1.1/theme/tasmofleet /srv/keycloak/themes/tasmofleet
docker compose up -d --force-recreate keycloak
```

(Use the folder of the release you want back.) The previous release folder stays on disk, so a rollback takes one symlink and one recreate.
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
| Brand shows `tasmofleet` in lower case | Realm settings → General: `Display name` / `HTML Display name` are empty (see step 5.3); no theme change or recreate needed |
| Fonts missing | Network tab: `geist-latin.woff2` must load from the same origin |
