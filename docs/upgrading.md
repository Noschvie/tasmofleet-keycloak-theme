# Upgrading Keycloak

The theme overrides **no** FreeMarker templates (see `design-decisions.md`, table
"Template overrides"). There is nothing to merge with upstream templates. What can
break is the dependency on the parent theme `keycloak.v2` and on PatternFly.

## Checklist for every Keycloak upgrade

1. Read the upgrade guide of the new version for theme changes
   (https://www.keycloak.org/docs/<version>/upgrading/).
2. Start the dev compose with the new image tag and check in the Admin Console that
   `keycloak.v2` and `tasmofleet` are still listed as login themes.
3. Find out which PatternFly version the new Keycloak bundles and check the variables:

   ```bash
   curl -sL https://raw.githubusercontent.com/keycloak/keycloak/<version>/js/pnpm-lock.yaml \
     | grep -oE "@patternfly/patternfly@[0-9.]+" | sort -u      # use the 5.x line
   scripts/check-pf-vars.py <patternfly-version>
   ```

   Exit code 1 lists variables that no longer exist.
4. Capture the pages again and compare the markup with the previous snapshots:

   ```bash
   dev/capture-pages.sh dev/snapshots-new
   diff -r dev/snapshots dev/snapshots-new   # resource hashes and session tokens differ, ignore them
   ```

   New or renamed classes on a page mean a selector in `tasmofleet-login.css` may stop matching.
5. Run the checklist in `testing.md`: light and dark, 375 px, error and banner states.
6. Update the Keycloak version in `README.md`, `deployment.md` and `dev/compose.yaml`,
   and record the result in `CHANGELOG.md`.

## When a template override becomes necessary

Override a template only if CSS cannot do it. Then, for every upgrade:

1. Add the template to the table in `design-decisions.md` with reason and base version.
2. Compare the override with the template of the new Keycloak version
   (`themes/src/main/resources/theme/keycloak.v2/login/` in the Keycloak repository, tag of the version).
3. Merge the upstream changes and test all login states again.
