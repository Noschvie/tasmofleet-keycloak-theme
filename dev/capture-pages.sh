#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2026 Noschvie
#
# Saves the HTML of several login pages of the DEV realm, so that selectors
# can be derived from real markup. Uses the users from realm-tasmofleet-test.json.
# Output: dev/snapshots/*.html (ignored by git).
#
# Usage: ./capture-pages.sh [output-dir]
#   KC_DEV_URL (default http://localhost:8040), KC_REALM (default tasmofleet)
set -euo pipefail

BASE="${KC_DEV_URL:-http://localhost:8040}"
REALM="${KC_REALM:-tasmofleet}"
OUT="${1:-$(cd "$(dirname "$0")" && pwd)/snapshots}"
JAR="$(mktemp)"
trap 'rm -f "$JAR"' EXIT
mkdir -p "$OUT"

AUTH="$BASE/realms/$REALM/protocol/openid-connect/auth?client_id=tasmofleet&redirect_uri=http://localhost:8081/&response_type=code&scope=openid"

unescape()    { sed 's/&amp;/\&/g'; }
form_action() { grep -o 'action="[^"]*"' "$1" | head -1 | sed 's/^action="//; s/"$//' | unescape; }
link_to()     { grep -o "href=\"[^\"]*$2[^\"]*\"" "$1" | head -1 | sed 's/^href="//; s/"$//' | unescape; }

fresh() {  # fresh session, saves the login page to $1
  : > "$JAR"
  curl -s --max-time 15 -c "$JAR" -b "$JAR" "$AUTH" -o "$1"
}

login_as() {  # $1 user, $2 password, $3 output file
  local page="$OUT/.login-tmp.html" action
  fresh "$page"
  action="$(form_action "$page")"
  # the last redirect may point to the (not running) test application: ignore that failure
  curl -s --max-time 15 -L --max-redirs 5 -c "$JAR" -b "$JAR" \
    --data-urlencode "username=$1" --data-urlencode "password=$2" --data-urlencode "credentialId=" \
    "$action" -o "$3" || true
}

echo "Base: $BASE  Realm: $REALM"

fresh "$OUT/login.html";                                   echo "login.html"
login_as alice wrong-password "$OUT/login-error.html";     echo "login-error.html (wrong password)"
login_as bob bob "$OUT/required-update-password.html";     echo "required-update-password.html"
login_as carol carol "$OUT/required-configure-totp.html";  echo "required-configure-totp.html"

curl -s --max-time 15 "$BASE/realms/$REALM/protocol/openid-connect/auth?client_id=tasmofleet&redirect_uri=http://invalid.example/&response_type=code&scope=openid" \
  -o "$OUT/error-page.html";                                echo "error-page.html (invalid redirect URI)"
login_as alice alice "$OUT/.login-tmp.html"
curl -s --max-time 15 -b "$JAR" -c "$JAR" "$BASE/realms/$REALM/protocol/openid-connect/logout" \
  -o "$OUT/logout-confirm.html";                            echo "logout-confirm.html"

fresh "$OUT/.login-tmp.html"
href="$(link_to "$OUT/.login-tmp.html" reset-credentials)"
if [ -n "$href" ]; then
  curl -s --max-time 15 -c "$JAR" -b "$JAR" "$BASE$href" -o "$OUT/reset-credentials.html"; echo "reset-credentials.html"
else
  echo "reset-credentials: no link found (Forgot password disabled?)"
fi
rm -f "$OUT/.login-tmp.html"

echo; grep -H -o '<title>[^<]*</title>' "$OUT"/*.html
