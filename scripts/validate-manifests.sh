#!/usr/bin/env bash
# Verify every manifest declared in .version-bump.json matches the VERSION file.
# Exits non-zero if anything drifts.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$REPO_ROOT/.version-bump.json"
EXPECTED="$(cat "$REPO_ROOT/VERSION")"

dotted_to_jq_path() {
  local field="$1"
  echo ".$field" | sed -E 's/\.([0-9]+)/[\1]/g'
}

fail=0
while IFS=$'\t' read -r relpath field; do
  abs="$REPO_ROOT/$relpath"
  if [[ ! -f "$abs" ]]; then
    echo "validate-manifests: missing $relpath" >&2
    fail=1
    continue
  fi

  if [[ "$field" == "__raw__" ]]; then
    actual="$(tr -d '[:space:]' <"$abs")"
  else
    jq_path="$(dotted_to_jq_path "$field")"
    actual="$(jq -r "$jq_path" "$abs")"
  fi

  if [[ "$actual" != "$EXPECTED" ]]; then
    echo "validate-manifests: $relpath ($field) = '$actual', expected '$EXPECTED'" >&2
    fail=1
  fi
done < <(jq -r '.files[] | [.path, .field] | @tsv' "$CONFIG")

if [[ "$fail" -eq 0 ]]; then
  echo "validate-manifests: all versions match $EXPECTED"
fi
exit "$fail"
