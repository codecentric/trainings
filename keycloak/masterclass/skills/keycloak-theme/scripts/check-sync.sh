#!/usr/bin/env bash
# Verify the static demo and the deployed theme carry the same CSS/JS.
# Usage: check-sync.sh [repo-root]
set -uo pipefail
ROOT="${1:-$PWD}"
rc=0

[ -d "$ROOT/demo" ] || { echo "no demo/ directory -- nothing to compare"; exit 0; }

for demodir in "$ROOT"/demo/*/*/; do
  [ -d "$demodir" ] || continue
  rel="${demodir#$ROOT/demo/}"; rel="${rel%/}"          # <theme>/<type>
  theme="${rel%%/*}"; type="${rel##*/}"
  res="$ROOT/themes/$theme/$type/resources"
  if [ ! -d "$res" ]; then
    echo "WARN  demo/$rel has no counterpart at themes/$theme/$type/resources"
    rc=1; continue
  fi
  for src in "$demodir"*.css "$demodir"*.js; do
    [ -f "$src" ] || continue
    base=$(basename "$src"); ext="${base##*.}"
    case "$ext" in css) sub=css;; js) sub=js;; *) continue;; esac
    match=""
    for cand in "$res/$sub/$base" "$res/$sub/styles.css" "$res/$sub/style.css" "$res/$sub/script.js"; do
      [ -f "$cand" ] && { match="$cand"; break; }
    done
    if [ -z "$match" ]; then
      echo "MISS  $src has no counterpart under $res/$sub/"
      rc=1
    elif ! diff -q "$src" "$match" >/dev/null; then
      echo "DIFF  $src <-> $match"
      diff -u "$src" "$match" | head -20 | sed 's/^/      /'
      rc=1
    else
      echo "OK    $src == $match"
    fi
  done
done
if [ $rc -eq 0 ]; then
  echo "demo/ and themes/ are in sync."
else
  echo
  echo "Review every DIFF: theme-only additions (e.g. .alert styles that only exist in FreeMarker)"
  echo "are legitimate -- unintended drift in shared rules is not. Mirror back what belongs in both."
fi
exit $rc
