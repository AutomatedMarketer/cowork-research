#!/usr/bin/env python3
"""Build release zip for cowork-research plugin (Windows fallback for bash script).

Reads VERSION from cowork-research/.claude-plugin/plugin.json.
Defensive excludes:
- .DS_Store / OS artifacts
- docs/sops/* (course IP rule — never ship SOPs in public plugin repo)
- .git/ / build artifacts
- node_modules/
"""

from __future__ import annotations

import json
import os
import sys
import zipfile
from pathlib import Path

PLUGIN_DIR = Path("cowork-research")
RELEASE_DIR = Path("release")

EXCLUDE_PATTERNS = (
    ".DS_Store",
    "._",
    ".swp",
)

EXCLUDE_DIR_PREFIXES = (
    ".git",
    "node_modules",
    "docs/sops",
    "docs\\sops",
)


def should_exclude(rel_path: str) -> bool:
    for pat in EXCLUDE_PATTERNS:
        if pat in rel_path:
            return True
    for prefix in EXCLUDE_DIR_PREFIXES:
        if rel_path.startswith(prefix) or f"/{prefix}" in rel_path:
            return True
    return False


def main() -> int:
    plugin_manifest = PLUGIN_DIR / ".claude-plugin" / "plugin.json"
    if not plugin_manifest.exists():
        print(f"ERROR: {plugin_manifest} not found", file=sys.stderr)
        return 1

    with plugin_manifest.open(encoding="utf-8") as fh:
        manifest = json.load(fh)
    version = manifest.get("version")
    if not version:
        print("ERROR: could not parse version from plugin.json", file=sys.stderr)
        return 1

    zip_path = RELEASE_DIR / f"cowork-research-v{version}.zip"
    print(f"Building cowork-research v{version}...")

    RELEASE_DIR.mkdir(exist_ok=True)
    if zip_path.exists():
        zip_path.unlink()

    file_count = 0
    with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(PLUGIN_DIR):
            dirs[:] = [d for d in dirs if not should_exclude(str(Path(root) / d).replace(str(PLUGIN_DIR) + os.sep, "").replace("\\", "/"))]
            for fname in files:
                src = Path(root) / fname
                rel = src.relative_to(PLUGIN_DIR).as_posix()
                if should_exclude(rel):
                    continue
                zf.write(src, arcname=rel)
                file_count += 1

    size = zip_path.stat().st_size
    print(f"Built: {zip_path}")
    print(f"Size: {size} bytes")
    print(f"Files: {file_count}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
