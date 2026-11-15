#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
# Copyright (C) 2026 Noschvie
#
# Smoke test against the DEV realm (users from realm-tasmofleet-test.json, user `alice`).
# Checks that the theme is active and that it does not break what Keycloak does itself:
# sign-in with redirect, invalid credentials, assets, security headers, no external requests.
# Prints PASS/FAIL per check, exit code 1 if one fails.
#
# Usage: ./smoke-test.sh      (KC_DEV_URL default http://localhost:8040, KC_REALM default tasmofleet)
set -uo pipefail

BASE="${KC_DEV_URL:-http://localhost:8040}"
REALM="${KC_REALM:-tasmofleet}"
REDIR="http://localhost:8081/"
AUTH="$BASE/realms/$REALM/protocol/openid-connect/auth?client_id=tasmofleet&redirect_uri=$REDIR&response_type=code&scope=openid"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
JAR="$TMP/jar"
FAILED=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1"; FAILED=1; }
check() { local d="$1"; shift; if "$@" >/dev/null 2>&1; then pass "$d"; else fail "$d"; fi; }

unescape()    { sed 's/&amp;/\&/g'; }
form_action() { grep -o 'action="[^"]*"' "$1" | head -1 | sed 's/^action="//; s/"$//' | unescape; }
attr_of()     { grep -o "$2=\"[^\"]*\"" "$1" | head -1 | sed "s/^$2=\"//; s/\"$//" | unescape; }
fresh()       { : > "$JAR"; curl -s --max-time 15 -c "$JAR" -b "$JAR" -D "$TMP/headers" "$AUTH" -o "$1"; }
http_code()   { curl -s --max-time 15 -o "$2" -w '%{http_code}' "$1"; }

echo "Base: $BASE  Realm: $REALM"

# --- theme is active and its assets are served
fresh "$TMP/login.html"
check "login page is served" grep -q 'kc-form-login' "$TMP/login.html"

CSS="$(grep -o 'href="[^"]*tasmofleet-login.css"' "$TMP/login.html" | head -1 | sed 's/^href="//; s/"$//')"
if [ -z "$CSS" ]; then
  fail "theme stylesheet is linked (is loginTheme = tasmofleet set for the realm?)"
else
  pass "theme stylesheet is linked"
  [ "$(http_code "$BASE$CSS" "$TMP/theme.css")" = "200" ] && grep -q -- '--color-accent' "$TMP/theme.css" \
    && pass "stylesheet loads and contains the tokens" || fail "stylesheet loads and contains the tokens"
  check "stylesheet has no external urls or @import" bash -c "! grep -qiE 'url\\([\"'\\'' ]*https?:|@import' '$TMP/theme.css'"
  FONT="${CSS%css/tasmofleet-login.css}fonts/geist-latin.woff2"
  [ "$(http_code "$BASE$FONT" /dev/null)" = "200" ] && pass "Geist font is served by Keycloak" || fail "Geist font is served by Keycloak"
fi

ICON="$(grep -o '<link rel="icon" href="[^"]*"' "$TMP/login.html" | sed 's/.*href="//; s/"$//' | head -1)"
case "$ICON" in
  */login/tasmofleet/*) [ "$(http_code "$BASE$ICON" /dev/null)" = "200" ] && pass "favicon comes from the theme" || fail "favicon comes from the theme (not found)" ;;
  *) fail "favicon comes from the theme (found: ${ICON:-none})" ;;
esac

# --- nothing is loaded from other hosts, headers are preserved
EXTERNAL="$(grep -oE '(src|href)="https?://[^"]+"' "$TMP/login.html" | grep -vF "\"$BASE" || true)"
[ -z "$EXTERNAL" ] && pass "no external scripts, styles or images" || fail "external references: $EXTERNAL"
check "Content-Security-Policy header is present" grep -qi '^content-security-policy:' "$TMP/headers"
check "X-Content-Type-Options header is present" grep -qi '^x-content-type-options:' "$TMP/headers"

# --- invalid credentials stay on the themed page with Keycloak's message
fresh "$TMP/login.html"
ACTION="$(form_action "$TMP/login.html")"
curl -s --max-time 15 -c "$JAR" -b "$JAR" --data-urlencode "username=alice" --data-urlencode "password=wrong-password" \
  --data-urlencode "credentialId=" "$ACTION" -o "$TMP/wrong.html"
check "invalid credentials: error message is shown" grep -q 'Invalid username or password' "$TMP/wrong.html"
check "invalid credentials: page is still themed" grep -q 'tasmofleet-login.css' "$TMP/wrong.html"

# --- successful sign-in ends with a redirect to the application, carrying a code
fresh "$TMP/login.html"
ACTION="$(form_action "$TMP/login.html")"
RESULT="$(curl -s --max-time 15 -c "$JAR" -b "$JAR" --data-urlencode "username=alice" --data-urlencode "password=alice" \
  --data-urlencode "credentialId=" -o /dev/null -w '%{http_code} %{redirect_url}' "$ACTION")"
CODE="${RESULT%% *}"; TARGET="${RESULT#* }"
case "$TARGET" in
  "$REDIR"*code=*) [ "$CODE" = "302" ] && pass "sign-in: redirect to the application with a code" || fail "sign-in: unexpected status $CODE" ;;
  *) fail "sign-in: no redirect to $REDIR (status $CODE, target: ${TARGET:-none})" ;;
esac

# --- logout confirmation page is served (session from the sign-in above)
LOGOUT_CODE="$(curl -s --max-time 15 -b "$JAR" -c "$JAR" -o "$TMP/logout.html" -w '%{http_code}' "$BASE/realms/$REALM/protocol/openid-connect/logout")"
[ "$LOGOUT_CODE" = "200" ] && grep -q 'tasmofleet-login.css' "$TMP/logout.html" \
  && pass "logout: confirmation page is served and themed" || fail "logout: confirmation page (status $LOGOUT_CODE)"

echo
[ "$FAILED" = "0" ] && echo "All checks passed." || echo "Some checks failed."
exit "$FAILED"
