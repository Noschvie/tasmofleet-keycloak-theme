#!/usr/bin/env python3
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2026 Noschvie
"""Check that every PatternFly variable the theme sets exists in a PatternFly release.

The theme maps its tokens onto PatternFly 5 variables. After a Keycloak upgrade the
bundled PatternFly may change; a variable that no longer exists would silently stop working.

Usage: scripts/check-pf-vars.py [PATTERNFLY_VERSION]
Default: 5.4.2 (bundled with Keycloak 26.8.2). Needs access to registry.npmjs.org.
Exit code 1 if a variable is missing.
"""
import io
import pathlib
import re
import sys
import tarfile
import urllib.request

version = sys.argv[1] if len(sys.argv) > 1 else "5.4.2"
root = pathlib.Path(__file__).resolve().parent.parent
css_file = root / "theme/tasmofleet/login/resources/css/tasmofleet-login.css"

url = f"https://registry.npmjs.org/@patternfly/patternfly/-/patternfly-{version}.tgz"
data = urllib.request.urlopen(url, timeout=60).read()
with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as tar:
    pf = tar.extractfile("package/patternfly.css").read().decode("utf-8")

mine = re.sub(r"/\*.*?\*/", "", css_file.read_text(encoding="utf-8"), flags=re.S)
names = sorted(set(re.findall(r"(--pf-v5-[A-Za-z0-9_-]+)\s*:", mine)))
missing = [n for n in names if n not in pf]

print(f"PatternFly {version}: {len(names)} variables set by the theme, {len(missing)} missing")
for name in missing:
    print("  missing:", name)
sys.exit(1 if missing else 0)
