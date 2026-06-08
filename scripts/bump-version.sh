#!/usr/bin/env bash
# Bump plugin versions across every manifest declared in .version-bump.json.
# Usage: scripts/bump-version.sh <new-semver>
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "bump-version: jq is required" >&2
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <new-semver>" >&2
  exit 2
fi

NEW="$1"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONFIG="$REPO_ROOT/.version-bump.json"

if [[ ! -f "$CONFIG" ]]; then
  echo "bump-version: $CONFIG not found" >&2
  exit 1
fi

# Validate semver-ish (semver allowed plus pre-release / build)
if ! [[ "$NEW" =~ ^[0-9]+\.[0-9]+\.[0-9]+([-+][0-9A-Za-z.-]+)?$ ]]; then
  echo "bump-version: '$NEW' is not a valid semver" >&2
  exit 2
fi

# Convert a dotted .version-bump.json field like "plugins.0.version" into a jq path "plugins[0].version".
dotted_to_jq_path() {
  local field="$1"
  echo ".$field" | sed -E 's/\.([0-9]+)/[\1]/g'
}

count=0
missing=0
while IFS=$'\t' read -r relpath field; do
  abs="$REPO_ROOT/$relpath"
  if [[ ! -f "$abs" ]]; then
    echo "bump-version: skipping missing $relpath" >&2
    missing=$((missing + 1))
    continue
  fi

  if [[ "$field" == "__raw__" ]]; then
    printf '%s\n' "$NEW" > "$abs"
    count=$((count + 1))
    continue
  fi

  jq_path="$(dotted_to_jq_path "$field")"
  tmp="$(mktemp)"
  jq --arg v "$NEW" "$jq_path = \$v" "$abs" > "$tmp"
  mv "$tmp" "$abs"
  count=$((count + 1))
done < <(jq -r '.files[] | [.path, .field] | @tsv' "$CONFIG")

echo "bump-version: wrote $NEW to $count locations ($missing skipped)"
