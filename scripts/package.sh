#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2026 Noschvie
#
# Builds the release archive: dist/tasmofleet-keycloak-theme-<version>.tar.gz (+ .sha256).
# The archive contains one directory `tasmofleet/` (the Keycloak theme) with LICENSE,
# NOTICE and VERSION next to the `login/` folder. Unpack it into the themes directory.
#
# Usage: scripts/package.sh <version>      e.g. scripts/package.sh 0.1.0
set -euo pipefail

VERSION="${1:?usage: scripts/package.sh <version> (e.g. 0.1.0)}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$ROOT/dist"
cp -a "$ROOT/theme/tasmofleet" "$STAGE/tasmofleet"
cp "$ROOT/LICENSE" "$ROOT/NOTICE" "$STAGE/tasmofleet/"
echo "$VERSION" > "$STAGE/tasmofleet/VERSION"
find "$STAGE" -type d -exec chmod 755 {} +
find "$STAGE" -type f -exec chmod 644 {} +

OUT="$ROOT/dist/tasmofleet-keycloak-theme-$VERSION.tar.gz"
tar --owner=0 --group=0 --numeric-owner --sort=name -czf "$OUT" -C "$STAGE" tasmofleet
(cd "$ROOT/dist" && sha256sum "$(basename "$OUT")" > "$(basename "$OUT").sha256")

echo "$OUT"
cat "$OUT.sha256"
