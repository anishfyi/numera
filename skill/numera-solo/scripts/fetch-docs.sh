#!/usr/bin/env bash
# Numera Solo: pull a platform's own API reference into a local cache.
#
#   ./fetch-docs.sh xero
#   ./fetch-docs.sh xero --refresh
#   ./fetch-docs.sh --list
#
# Cached under ~/.numera/docs/<platform>/ with a _meta.json recording each URL,
# its mode, and when it was fetched. That directory is YOURS. This repo
# redistributes nothing a vendor owns, and you remain responsible for their
# terms and for copyright, which is what curl_reap's LEGAL notice says too.
#
# ---------------------------------------------------------------------------
# WHAT ACTUALLY WORKS, measured rather than assumed:
#
#   spec  A static OpenAPI/JSON file. Fetched verbatim. This is the best source
#         by a distance: machine-readable, complete, and versioned by the vendor.
#         Xero publishes one; it is 900KB of exact request/response contracts.
#
#   md    A server-rendered doc page, converted to markdown by curl_reap.
#         Microsoft Learn works this way.
#
#   browser  A client-rendered SPA. Intuit's and Xero's developer PORTALS are
#         Gatsby apps: the HTML is 1.2MB of JavaScript shell and the prose is
#         not in it. Scraping returns an empty document. We do not pretend
#         otherwise; we print the URL and tell you to open it.
# ---------------------------------------------------------------------------
set -uo pipefail

NUMERA_HOME="${NUMERA_HOME:-$HOME/.numera}"
BOLD=$'\033[1m'; DIM=$'\033[2m'; OK=$'\033[32m'; WARN=$'\033[33m'; OFF=$'\033[0m'
MIN_BYTES=400   # a "fetched" page smaller than this is an empty shell, not a doc

good() { printf '    %s✓%s %s\n' "$OK" "$OFF" "$*"; }
warn() { printf '    %s!%s %s\n' "$WARN" "$OFF" "$*"; }
note() { printf '    %s%s%s\n' "$DIM" "$*" "$OFF"; }

# platform|mode|label|url
SOURCES='
xero|spec|Accounting API (OpenAPI)|https://raw.githubusercontent.com/XeroAPI/Xero-OpenAPI/master/xero_accounting.yaml
xero|spec|Payroll UK (OpenAPI)|https://raw.githubusercontent.com/XeroAPI/Xero-OpenAPI/master/xero-payroll-uk.yaml
xero|browser|Manual journals guide|https://developer.xero.com/documentation/api/accounting/manualjournals
dynamics-365-bc|md|API v2.0 reference|https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/
dynamics-365-bc|md|Journal entry API|https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/api-reference/v2.0/resources/dynamics_journalline
quickbooks-online|browser|JournalEntry reference|https://developer.intuit.com/app/developer/qbo/docs/api/accounting/all-entities/journalentry
quickbooks-online|browser|OAuth 2.0|https://developer.intuit.com/app/developer/qbo/docs/develop/authentication-and-authorization/oauth-2.0
sage-intacct|browser|Journal entries|https://developer.intacct.com/api/general-ledger/journal-entries/
netsuite|browser|SuiteTalk REST|https://docs.oracle.com/en/cloud/saas/netsuite/ns-online-help/section_158151970537.html
'

if [ "${1:-}" = "--list" ] || [ -z "${1:-}" ]; then
  echo "Platforms with known doc sources:"
  printf '%s\n' "$SOURCES" | awk -F'|' 'NF==4{print $1}' | sort -u | sed 's/^/  /'
  echo
  echo "Platforms without one: follow ../PLATFORM-PLAYBOOK.md, then add the URLs here."
  [ -z "${1:-}" ] && exit 2 || exit 0
fi

PLATFORM="$1"; REFRESH="${2:-}"
ROWS="$(printf '%s\n' "$SOURCES" | awk -F'|' -v p="$PLATFORM" 'NF==4 && $1==p')"
[ -z "$ROWS" ] && { warn "No doc sources known for \"$PLATFORM\"."
  echo "    Follow ../PLATFORM-PLAYBOOK.md to find the vendor reference, then add it to"
  echo "    SOURCES in this script so nobody repeats the search."; exit 1; }

REAP="$NUMERA_HOME/venv/bin/reap"
[ -x "$REAP" ] || REAP="$(command -v reap 2>/dev/null || true)"

OUT="$NUMERA_HOME/docs/$PLATFORM"; mkdir -p "$OUT"
printf '%s==>%s %s docs into %s\n' "$BOLD" "$OFF" "$PLATFORM" "$OUT"
note "Vendor documentation, cached for your use. Not redistributed."

TMP_META="$(mktemp)"; n_ok=0; n_browser=0; n_fail=0

while IFS='|' read -r _p mode label url; do
  [ -z "${url:-}" ] && continue
  slug="$(printf '%s' "$label" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-')"

  if [ "$mode" = "browser" ]; then
    warn "$label needs a browser"
    note "client-rendered page, scraping returns an empty document: $url"
    n_browser=$((n_browser+1))
    printf '{"label":"%s","mode":"browser","url":"%s"}\n' "$label" "$url" >> "$TMP_META"
    continue
  fi

  ext="md"; [ "$mode" = "spec" ] && ext="yaml"
  dest="$OUT/$slug.$ext"

  if [ -s "$dest" ] && [ "$REFRESH" != "--refresh" ]; then
    good "cached  $label ($(wc -c < "$dest" | tr -d ' ') bytes)"
    n_ok=$((n_ok+1))
    printf '{"label":"%s","mode":"%s","url":"%s","file":"%s"}\n' "$label" "$mode" "$url" "$(basename "$dest")" >> "$TMP_META"
    continue
  fi

  if [ "$mode" = "spec" ]; then
    curl -fsSL --max-time 60 "$url" -o "$dest" 2>/dev/null
  else
    [ -n "$REAP" ] || { warn "curl_reap missing, run scripts/setup.sh"; n_fail=$((n_fail+1)); continue; }
    "$REAP" get "$url" > "$dest" 2>/dev/null
  fi

  size=$( [ -f "$dest" ] && wc -c < "$dest" | tr -d ' ' || echo 0 )
  # A non-empty file is not a fetched doc: a JS shell yields a byte or two.
  if [ "${size:-0}" -ge "$MIN_BYTES" ]; then
    good "fetched $label ($size bytes)"
    n_ok=$((n_ok+1))
    printf '{"label":"%s","mode":"%s","url":"%s","file":"%s"}\n' "$label" "$mode" "$url" "$(basename "$dest")" >> "$TMP_META"
  else
    warn "empty    $label (got ${size:-0} bytes, treating as failure)"
    rm -f "$dest"; n_fail=$((n_fail+1))
  fi
done <<< "$ROWS"

{
  printf '{\n  "platform": "%s",\n  "fetched": "%s",\n  "sources": [\n' \
    "$PLATFORM" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  paste -sd, - < "$TMP_META" 2>/dev/null | sed 's/},{/},\n    {/g; s/^/    /'
  printf '\n  ]\n}\n'
} > "$OUT/_meta.json"
rm -f "$TMP_META"

printf '%s==>%s %s cached, %s need a browser, %s failed\n' "$BOLD" "$OFF" "$n_ok" "$n_browser" "$n_fail"
[ "$n_browser" -gt 0 ] && note "Open the browser-only pages yourself and paste what matters; they cannot be scraped."
note "Read the cached source BEFORE writing. It is the current contract; platforms/ is notes."
