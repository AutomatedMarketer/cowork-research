# Changelog

All notable changes to `cowork-research` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.0] — 2026-05-15 — "Browser Clipper + Catalog Accuracy"

### Added

- **`/save-clip` skill** — browser clipper for URL → clean markdown into the research library. Firecrawl primary + Playwright fallback for login-walled pages. Foundation-compliant: lazy-loads `business-brain.md` for tag suggestions; canonical 10%-better self-improve close; canonical `⚡ NEXT MOVE:` block with 4-row picking table by clip type; plan-then-approve before any write; append-only on index + memory.
- **Phase 2 mention of `/save-clip`** — `phases/02-recommend-connectors.md` now has a "Quick capture: /save-clip works alongside Firecrawl" paragraph; recommended for all 6 business types.
- **Phase 7 wrap-up lists 4 skills** — was 3 (`/research-brief`, `/web-audit`, `/meeting-recap`); now 4 with `/save-clip` added.
- **Per-profile post-onboarding pointer** — all 6 personalization profiles (coach, agency-owner, creator, course-creator, solopreneur-smb, sales-led-b2b) now include a one-line "Quick-capture habit (post-onboarding): Use `/save-clip` whenever you find an article worth keeping. The library compounds over weeks."
- **Clip template** — `skills/save-clip/templates/clip-template.md` with frontmatter shape (title, source_url, accessed_date, business_tags, clipped_by, user_note) and Source content body.

### Fixed

- **MCP namespace prefixes in catalog** — Context7 verification command corrected from `mcp__plugin_context7__query-docs` to `mcp__plugin_context7_context7__query-docs` (doubled prefix is the actual namespace). Playwright corrected from `mcp__plugin_playwright__browser_navigate` to `mcp__plugin_playwright_playwright__browser_navigate` (same doubled-prefix pattern).
- **Catalog auth-required warnings** — added top-of-file authentication call-out; Firecrawl, Perplexity, Fathom, VidIQ, Notion, Google Drive entries now prefix their first-week test with "Authenticate first if Cowork prompts (one-time)" so a fresh install doesn't fail silently on the verification step. Firecrawl install line now mentions `FIRECRAWL_API_KEY` env var or browser login.

### Verified

- 4 cross-cutting MCPs live-tested in default Cowork environment on 2026-05-15: Perplexity Ask, Firecrawl, Context7, Playwright. All return-paths confirmed (with auth prompt as documented). Catalog stamps these "last verified: 2026-05-15 (live smoke test)"; the rest keep 2026-05-14 (untested live this round).

### Notes

- 5 skills now (was 4): `/onboard-research`, `/research-brief`, `/save-clip`, `/web-audit`, `/meeting-recap`.
- No new MCP dependencies — `/save-clip` uses Firecrawl + Playwright (already in the v0.1 connector stack).
- Foundation patterns for existing skills are unchanged — only `/save-clip` is new.

### Deferred to v0.3+

- `/competitive-monitor` (scheduled re-runs of audits with diff detection)
- `/research-query` (natural-language search across `reference/research/`)
- Chrome extension integration
- Fireflies MCP support (Fathom only in v0.2)
- Notion MCP rich-block writing (plain markdown only in v0.2)
- VidIQ-deep skill (`/youtube-competitive`)
- Stop-hook auto-extract-to-research-library
- Custom Cowork MCP server (`research_get`, `research_search`, `index_resolve`)

[0.2.0]: https://github.com/AutomatedMarketer/cowork-research/releases/tag/v0.2.0

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
