#!/usr/bin/env bash
# Detect the Keycloak version this repo targets and the latest released one.
# Usage: kc-version.sh [repo-root]
set -uo pipefail
ROOT="${1:-$PWD}"

detect() {
  local v=""
  if [ -f "$ROOT/Dockerfile" ]; then
    v=$(grep -ioE 'keycloak/keycloak:[0-9][^ "]*' "$ROOT/Dockerfile" | head -1 | cut -d: -f2)
  fi
  if [ -z "$v" ] && [ -f "$ROOT/VERSION" ]; then
    v=$(tr -d '[:space:]' < "$ROOT/VERSION")
  fi
  printf '%s' "$v"
}

# 26.7.2-1 (upstream rebuild tag) -> 26.7.2
normalize() { printf '%s' "$1" | sed -E 's/^([0-9]+\.[0-9]+\.[0-9]+).*$/\1/'; }

PINNED_RAW="$(detect)"
PINNED="$(normalize "${PINNED_RAW:-}")"

COMPOSE=""
for f in "$ROOT/compose.yaml" "$ROOT/compose.yml" "$ROOT/docker-compose.yaml" "$ROOT/docker-compose.yml"; do
  [ -f "$f" ] || continue
  COMPOSE=$(grep -ioE 'keycloak/keycloak:[0-9][^ "]*' "$f" | head -1 | cut -d: -f2)
  [ -n "$COMPOSE" ] && break
done

LATEST=$(curl -sfL --max-time 15 https://api.github.com/repos/keycloak/keycloak/releases \
  | grep -oE '"tag_name": *"[0-9]+\.[0-9]+\.[0-9]+"' | head -1 | cut -d'"' -f4)

echo "pinned (Dockerfile/VERSION): ${PINNED_RAW:-<none>}${PINNED:+  -> normalized ${PINNED}}"
echo "compose dev image:           ${COMPOSE:-<none>}"
echo "latest released:             ${LATEST:-<offline, could not query GitHub>}"

if [ -n "$COMPOSE" ] && [ -n "$PINNED" ] && [ "$(normalize "$COMPOSE")" != "$PINNED" ]; then
  echo "WARN: dev compose and Dockerfile target different Keycloak versions -- tests would not match production."
fi
if [ -n "$LATEST" ] && [ -n "$PINNED" ] && [ "$LATEST" != "$PINNED" ]; then
  echo "NOTE: a newer Keycloak ($LATEST) is available than the pinned $PINNED."
fi
echo
echo "Recommend: build against ${PINNED:-${LATEST:-unknown}} (the version actually deployed); mention $LATEST as the current release."
