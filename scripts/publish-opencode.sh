#!/usr/bin/env bash
# Publish the @xberg-io/opencode-* plugins to npm — initial LOCAL release.
#
# Why local: npm Trusted Publishers (OIDC) can only be configured for a package
# that already exists, so the very first release must be published by hand. This
# release therefore has NO provenance (provenance needs CI/OIDC). After this
# debut, set up Trusted Publishers on npmjs.com and let CI (.github/workflows/
# publish.yaml) handle subsequent releases with provenance.
#
# 2FA: by default this logs in with your browser (npm login --auth-type=web). If
# your account requires 2FA on every write, npm will prompt for a one-time code
# at publish time — type it in, or pass it up front with --otp.
#
# Usage:
#   scripts/publish-opencode.sh                 # browser login + interactive OTP
#   scripts/publish-opencode.sh --otp 123456    # supply a TOTP code up front
#   scripts/publish-opencode.sh --dry-run       # validate + pack only, no publish
#
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

PACKAGES=(
  plugins/xberg
  plugins/crawlberg
  plugins/html-to-markdown
  plugins/tree-sitter-language-pack
)

OTP=""
DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
  --otp)
    OTP="${2:?--otp needs a code}"
    shift 2
    ;;
  --otp=*)
    OTP="${1#*=}"
    shift
    ;;
  --dry-run)
    DRY_RUN=1
    shift
    ;;
  -h | --help)
    sed -n '2,30p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "unknown argument: $1" >&2
    exit 2
    ;;
  esac
done

have() { command -v "$1" >/dev/null 2>&1; }
have npm || {
  echo "error: npm not found on PATH" >&2
  exit 1
}
have jq || {
  echo "error: jq not found on PATH" >&2
  exit 1
}

# Provenance is a CI/OIDC feature; force it off for this local release so the
# publishConfig.provenance=true in each package.json does not abort the publish.
export npm_config_provenance=false

bold() { printf '\033[1m%s\033[0m\n' "$*"; }

bold "==> opencode packages to publish (access=public, NO provenance — local debut):"
for d in "${PACKAGES[@]}"; do
  printf '      %-46s %s\n' "$(jq -r .name "$d/package.json")" "$(jq -r .version "$d/package.json")"
done

bold "==> validating opencode entrypoints import cleanly ..."
node scripts/validate-opencode.mjs

# --- auth ---------------------------------------------------------------------
if npm whoami >/dev/null 2>&1; then
  bold "==> npm user: $(npm whoami)"
else
  bold "==> not logged in — opening browser login (npm login --auth-type=web) ..."
  npm login --auth-type=web
  bold "==> logged in as: $(npm whoami)"
fi

# --- dry-run pack (always) ----------------------------------------------------
bold "==> dry-run pack (validate tarball contents) ..."
for d in "${PACKAGES[@]}"; do
  (cd "$d" && npm publish --dry-run --access public --no-provenance >/dev/null)
  echo "      ok  $(jq -r .name "$d/package.json")"
done

if [ "$DRY_RUN" -eq 1 ]; then
  bold "==> --dry-run set; nothing published."
  exit 0
fi

# --- confirm ------------------------------------------------------------------
printf '\n'
bold "==> publish the packages above to npm now? [y/N] "
read -r ans
case "$ans" in
y | Y | yes | YES) ;;
*)
  echo "aborted."
  exit 1
  ;;
esac

# --- publish ------------------------------------------------------------------
# Avoid empty-array expansion under `set -u` (breaks on macOS' bash 3.2).
published=""
for d in "${PACKAGES[@]}"; do
  name="$(jq -r .name "$d/package.json")"
  ver="$(jq -r .version "$d/package.json")"
  if npm view "${name}@${ver}" version >/dev/null 2>&1; then
    echo "==> skip ${name}@${ver} (already on npm)"
    continue
  fi
  bold "==> publishing ${name}@${ver} ..."
  if [ -n "$OTP" ]; then
    (cd "$d" && npm publish --access public --no-provenance --otp "$OTP")
  else
    (cd "$d" && npm publish --access public --no-provenance)
  fi
  published="$published ${name}@${ver}"
done

printf '\n'
bold "==> done. published:${published:- none (all already on npm)}"
cat <<'NEXT'

Next steps (one-time, per package, on npmjs.com):
  1. Open each package > Settings > Trusted Publishers.
  2. Add a GitHub Actions publisher:
       repository: xberg-io/plugins
       workflow:   publish.yaml
  3. After that, releases can publish from CI with provenance and no token/OTP.
NEXT
