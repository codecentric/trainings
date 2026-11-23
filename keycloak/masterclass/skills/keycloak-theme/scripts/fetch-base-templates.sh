#!/usr/bin/env bash
# Download the official base theme templates for a Keycloak version -- the authoritative
# contract to diff custom templates against.
# Usage: fetch-base-templates.sh <version> [login|email|account|admin] [outdir] [--list-only]
set -uo pipefail
VERSION="${1:?usage: fetch-base-templates.sh <version> [type] [outdir] [--list-only]}"
TYPE="${2:-login}"
OUT="${3:-./kc-base-$VERSION-$TYPE}"
LIST_ONLY=""
for a in "$@"; do [ "$a" = "--list-only" ] && LIST_ONLY=1; done

BASE_API="https://api.github.com/repos/keycloak/keycloak/contents/themes/src/main/resources/theme/base"
BASE_RAW="https://raw.githubusercontent.com/keycloak/keycloak/$VERSION/themes/src/main/resources/theme/base"

# email templates live in html/ and text/ subdirectories
case "$TYPE" in
  email) SUBDIRS="html text" ;;
  *)     SUBDIRS="." ;;
esac

found=0
for sub in $SUBDIRS; do
  path="$TYPE"; [ "$sub" != "." ] && path="$TYPE/$sub"
  json=$(curl -sfL --max-time 20 "$BASE_API/$path?ref=$VERSION") || { echo "Could not list base/$path for $VERSION (does the tag exist?)"; continue; }
  files=$(printf '%s' "$json" | grep -oE '"name": *"[^"]+\.ftl"' | cut -d'"' -f4 | sort)
  [ -z "$files" ] && { echo "No .ftl files in base/$path at $VERSION"; continue; }
  found=1

  echo "base/$path @ $VERSION -- $(printf '%s\n' "$files" | wc -l | tr -d ' ') templates:"
  printf '%s\n' "$files" | tr '\n' ' '; echo

  [ -n "$LIST_ONLY" ] && continue

  mkdir -p "$OUT/$sub"
  for f in $files; do
    curl -sfL --max-time 20 "$BASE_RAW/$path/$f" -o "$OUT/$sub/$f" || echo "  ! failed: $f"
  done
done

[ "$found" -eq 0 ] && exit 1
[ -n "$LIST_ONLY" ] && exit 0

curl -sfL --max-time 20 "$BASE_RAW/$TYPE/theme.properties" -o "$OUT/theme.properties" 2>/dev/null
echo "downloaded to $OUT"
