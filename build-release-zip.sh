#!/usr/bin/env bash
set -euo pipefail

# Build release zip for cowork-research plugin
# Reads VERSION from cowork-research/.claude-plugin/plugin.json

PLUGIN_DIR="cowork-research"
RELEASE_DIR="release"

VERSION=$(grep -E '"version"' "${PLUGIN_DIR}/.claude-plugin/plugin.json" \
  | head -1 | sed -E 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/')

if [ -z "${VERSION}" ]; then
  echo "ERROR: could not parse version from plugin.json" >&2
  exit 1
fi

ZIP_PATH="${RELEASE_DIR}/cowork-research-v${VERSION}.zip"

echo "Building cowork-research v${VERSION}..."
mkdir -p "${RELEASE_DIR}"
rm -f "${ZIP_PATH}"

# Defensive excludes:
# - .DS_Store / OS artifacts
# - docs/sops/* (course IP rule — never ship SOPs in public plugin repo)
# - .git/ / build artifacts
(
  cd "${PLUGIN_DIR}"
  zip -r "../${ZIP_PATH}" . \
    -x ".DS_Store" \
    -x "._*" \
    -x "*.swp" \
    -x ".git/*" \
    -x "node_modules/*" \
    -x "docs/sops/*" \
    -x "docs/sops"
)

echo "Built: ${ZIP_PATH}"
echo "Size: $(stat -c %s "${ZIP_PATH}" 2>/dev/null || stat -f %z "${ZIP_PATH}") bytes"
