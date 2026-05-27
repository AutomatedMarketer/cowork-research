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

echo "Linting SKILL.md and plugin.json descriptions..."
PLUGIN_DIR_PATH="${PLUGIN_DIR}" python3 - <<'PYLINT' || exit 1
import json, os, pathlib, re, sys
DESC_LIMIT = 300
pd = pathlib.Path(os.environ["PLUGIN_DIR_PATH"])
errors = []
pj = json.loads((pd / ".claude-plugin" / "plugin.json").read_text(encoding="utf-8"))
desc = pj.get("description", "")
if len(desc) > DESC_LIMIT:
    errors.append(f"plugin.json description is {len(desc)} chars (max {DESC_LIMIT})")
na = sorted({c for c in desc if ord(c) > 127})
if na:
    errors.append(f"plugin.json description has non-ASCII chars: {na}")
for sk in sorted(pd.glob("skills/**/SKILL.md")):
    text = sk.read_text(encoding="utf-8")
    fm = re.match(r"^---\s*\n(.*?)\n---", text, re.S)
    if not fm: continue
    m = re.search(r'^description:\s*"(.+?)"', fm.group(1), re.S | re.M)
    if not m: continue
    d = m.group(1)
    rel = sk.relative_to(pd).as_posix()
    if len(d) > DESC_LIMIT:
        errors.append(f"{rel} description is {len(d)} chars (max {DESC_LIMIT})")
    na = sorted({c for c in d if ord(c) > 127})
    if na:
        errors.append(f"{rel} description has non-ASCII chars: {na}")
if errors:
    print("ERROR: Cowork validator rule violations:", file=sys.stderr)
    for e in errors: print(f"  - {e}", file=sys.stderr)
    sys.exit(1)
print("  OK")
PYLINT

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
