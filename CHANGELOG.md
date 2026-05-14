# Changelog

All notable changes to `cowork-research` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.1.0] — 2026-05-14 — "Initial Release: Research Engine for the Cowork AI OS"

### Added

- **`/onboard-research` wizard** — 7-phase install flow (~12 min). Resumable via `state-research.md`. Includes prereq check for cowork-ai-os.
- **`/research-brief` skill** — 600-word executive brief + 5-bullet TLDR. Plan-then-approve writes. Reads `about-me/business-brain.md` for ICP context.
- **`/web-audit` skill** — CRO + competitive audit of any URL. Read-only on web. Bulleted recommendations grouped by severity.
- **`/meeting-recap` skill** — Fathom transcript → decisions + action items + open questions + notable quotes.
- **6 personalization profiles** — one per business type (Solo coach, Agency owner, Creator, Course creator, Solopreneur/SMB, Sales-led B2B). Drives Phase 2 connector recommendations and Phase 6 demos.
- **`reference/_research-hot.md` tier-2 cache** — new always-loaded memory file at the workspace level (not vault-only).
- **Connector catalog** (`connectors-research.md`) using cowork-ai-os v0.10 schema verbatim.
- **3 templates** — `brief-template.md`, `web-audit-checklist.md` (Baymard-style CRO heuristics), `meeting-recap-template.md`.
- **3 onboard templates** — `research-preferences.md.template`, `research-hot.md.template`, `state-research.md.template`.
- **14-day calibration check** — wizard schedules a `/audit` re-run to track 4 Cs score movement.

### Notes

- Soft-depends on `cowork-ai-os >= 0.10` for identity files (`about-me/about-me.md`, `business-brain.md`, `connections.md`).
- `cowork-ai-os >= 0.10.2` recommended for live connector catalogs.
- `/onboard-research` Phase 2 delegates to `/browse-connectors` (cowork-ai-os v0.10.2+ live-fetches the directory; older versions fall back to bundled catalog).
- Optionally integrates with `cowork-obsidian >= 0.5` for fold-back to vault.
- **No course SOPs in this repo** — course material lives in the private course workspace, per the modular-plugin rule.

### Deferred to v0.2+

- `/competitive-monitor` (scheduled re-runs of audits with diff detection)
- `/save-clip` browser clipper
- `/research-query` (natural-language search across `reference/research/`)
- Chrome extension integration
- Fireflies MCP support (Fathom only in v0.1)
- Notion MCP rich-block writing (plain markdown only in v0.1)
- VidIQ-deep skill (`/youtube-competitive`)
- Stop-hook auto-extract-to-research-library

[0.1.0]: https://github.com/AutomatedMarketer/cowork-research/releases/tag/v0.1.0
