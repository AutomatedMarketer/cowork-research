# cowork-research — architecture (v0.2.0)

Internal contributor doc. For the user-facing pitch see the [root README](../../README.md).

## v0.2.0 — Research Engine + Browser Clipper

The v0.2.0 surface is **5 skills** (1 wizard + 4 operational) and **6 personalization profiles** (one per business type). v0.2.0 added `/save-clip` — the browser clipper that turns any URL into a clean-markdown entry in `reference/research/clips/`, with Firecrawl as the primary scraper and Playwright as the fallback for login-walled pages. Plan-then-approve, frontmatter with source URL + tags + accessed date, append-only updates to the index and memory. The library only compounds if you keep feeding it.

Also in v0.2.0: catalog accuracy fixes (Context7 + Playwright MCP namespace doubled-prefix correction; Firecrawl/Perplexity/Fathom/VidIQ/Notion/Google Drive auth-required notes — Cowork prompts for API key or OAuth on first use of each).

## v0.1.0 — Research Engine for the Cowork AI OS

`cowork-research` is the third plugin in the Cowork AI OS family. It assumes identity already exists (from `cowork-ai-os`) and optionally writes into a vault (from `cowork-obsidian`). Its job is narrow: turn the assistant into a research analyst that knows the user's business, has the right MCPs wired, and produces outputs in a calibrated voice.

The v0.1.0 surface is **4 skills** (1 wizard + 3 operational) and **6 personalization profiles** (one per business type). No background agents, no Stop-hooks, no custom MCP server in this release — those are deferred. See [Deferred to later versions](#deferred-to-later-versions).

---

## The four-tier memory model

Borrowed verbatim from `cowork-obsidian v0.5`'s memory architecture, adapted for research outputs instead of vault notes.

| Tier | What | Where | Loaded when | ~Token cost | Who writes |
|---|---|---|---|---|---|
| 1 | Identity | `about-me/about-me.md`, `business-brain.md`, `connections.md` | Skills that need ICP/voice context | 300 | User (via `cowork-ai-os`) |
| 2 | Research hot cache | `reference/_research-hot.md` | Start of any research session | 500 | `/onboard-research` Phase 4; refreshed on cadence |
| 3 | Research index | `reference/research/_index.md` | When picking which past output is relevant | 1,000 | Every skill on save (append-only) |
| 4 | Individual outputs | `reference/research/briefs/<topic>.md`, `audits/<url-slug>.md`, `meetings/<call-id>.md` | Only when explicitly named or matched | 600–1,200 each | Skills, plan-then-approve |

**Rationale (why this beats always-loading):**

The naive approach is to always load the full research library into context. With 50+ briefs that's 30k–60k tokens before the user even types a query. With Tier 2 + Tier 3, we load ~1,500 tokens always — the hot cache (current state of the library, last 5 outputs, calibration prefs) plus the index (titles + 1-line summaries of every past output). Skills only reach for Tier 4 when the index match is strong.

Empirically (mirrors cowork-obsidian's measurements): a typical query touches ~3,500 tokens of research context, not 50,000. The library can grow to 200+ outputs without bloating session tokens.

---

## Soft-dependency on `cowork-ai-os`

`cowork-research` does not bundle identity. The wizard halts cleanly if `about-me/business-brain.md` is missing, with a paste-ready prompt directing the user to `cowork-ai-os`'s `/onboard`.

**What the wizard reads (read-only, never overwrites):**

- `about-me/about-me.md` — who the user is
- `about-me/business-brain.md` — ICP, offer, voice samples, current focus
- `about-me/connections.md` — what's already wired (so we don't re-recommend)
- `safe-zones.md` — current scoped paths

**What the wizard appends (append-only, never rewrites):**

- `about-me/connections.md` — new connector entries the user opted into during Phase 2
- `about-me/memory.md` — `YYYY-MM-DD: cowork-research v0.2.0 onboarded for <business-type>`
- `safe-zones.md` — adds `reference/research/` and `projects/research/` to the skill scope

**Prereq check (`checks/prereq-cowork-ai-os.md`):**

A markdown checklist Claude follows in Phase 0. Verifies:

1. `about-me/` directory exists
2. `business-brain.md` is non-empty
3. `safe-zones.md` is writable
4. `cowork-ai-os` plugin version is `>= 0.10`

Failure → wizard halts with paste-ready instructions to install/onboard `cowork-ai-os` first.

---

## v0.10.2 dependency for live connector catalogs

`cowork-ai-os v0.10.2` shipped a live-fetch upgrade to `/browse-connectors` — instead of returning a bundled snapshot of the connector catalog, the skill now fetches `claude.com/connectors` at runtime and returns the current list.

**Phase 2 of `/onboard-research` delegates to `/browse-connectors`** to surface the connector recommendations. This means:

- On `cowork-ai-os v0.10.2+` → user gets the live, current catalog
- On `cowork-ai-os v0.10.0 / v0.10.1` → wizard falls back to the bundled `connectors-research.md` (last verified 2026-05-14, schema-compatible with v0.10)
- On no `cowork-ai-os` at all → wizard halts at the prereq check

The bundled `connectors-research.md` uses the v0.10 schema verbatim so future live-fetch will be drop-in compatible with no schema migration.

---

## Loose coupling with `cowork-obsidian`

`cowork-research` works fine without an Obsidian vault. The default research destination is `reference/research/` at the workspace level.

If `cowork-obsidian` is detected (via the existence of `cowork-obsidian` in the plugin manifest list and a populated `vaults.md`), Phase 3 of the wizard offers the vault as the destination. Outputs land in `wiki/research/` instead of `reference/research/`. Indexing logic adapts; everything else is identical.

**Fold-back is offered, never required.** A future `/research → wiki` skill (deferred to v0.2) will surface "this brief has been cited 3 times — fold it into your wiki?" prompts. v0.1 just lets the user keep research outputs separate from vault wiki pages, which is the saner default for most users (research goes stale fast; wiki pages are evergreen).

---

## Connector recommendation rationale

The 6 business types and their top 3 connectors are the result of pattern-matching across the cohort's existing usage data + Jack Roberts' Cowork course examples. Brief reasoning per type:

- **Solo coach** — Perplexity (methodology research), Fathom (every coaching call is research input), Notion/Obsidian (long-term framework storage). Skip Firecrawl for now — coaches rarely scrape.
- **Agency owner** — Firecrawl (daily competitor scraping), Perplexity (pre-call context), Playwright (login-walled SaaS pages). Skip VidIQ unless agency is YouTube-focused.
- **Creator** — VidIQ (the unique YouTube signal Perplexity can't surface), Perplexity (trend context), Firecrawl (sponsorship pages, monetization stacks). Skip Playwright unless creator runs a SaaS too.
- **Course creator** — Perplexity (audience-pain validation), VidIQ (course teardowns happen on YouTube), Firecrawl (sales pages). Skip Fathom unless they coach 1:1 alongside the course.
- **Solopreneur / SMB** — Perplexity (the most common one-off research need), Firecrawl (occasional CRO checks), Fathom (customer-call recall — most under-used research input). Skip VidIQ + Playwright by default.
- **Sales-led B2B** — Firecrawl (THE pre-call research job), Perplexity (industry context), Fathom (post-call action extraction). Skip VidIQ.

**Skip-list (research-relevant MCPs we deliberately don't recommend in v0.1):**

- Brave Search — Perplexity dominates synthesis; Brave returns links not answers
- Tavily — no meaningful win over Perplexity for our use cases
- Fireflies — Fathom is already there; don't add a second transcription tool (v0.2 swap-in)
- GitHub MCP — too niche for non-dev audiences in v0.1
- Slack search — internal-comms, not external research
- SimilarWeb / BuiltWith — narrow; surface only after user masters Firecrawl + Perplexity

Full per-connector rationale: [`skills/onboard-research/catalogs/connectors-research.md`](../skills/onboard-research/catalogs/connectors-research.md).

---

## State.md resumability

The wizard writes `<workspace>/_aibos/state-research.md` on every phase transition. The state file tracks:

- `install_complete: <bool>`
- `current_phase: <int>`
- `next_pending_phase: <int>`
- `business_type: <one of 6>`
- `connectors_chosen: <list>`
- `destination: <workspace | vault | notion>`
- `calibration: <object — brief length, citation style, TLDR style>`
- `cadence_set: <bool>`
- `calibration_check_date: <ISO date — 14 days from install>`

Every phase reads state on entry and writes on exit. If interrupted, `/onboard-research` re-invocation reads `next_pending_phase` and resumes there.

If `install_complete: true`, re-invocation asks the user if they want to redo a specific phase. Each phase is idempotent — redoing Phase 4 (calibration) doesn't re-recommend connectors; redoing Phase 2 doesn't reset preferences.

State template lives at `skills/onboard-research/templates/state-research.md.template`. Bumped to `v1` for the v0.1.0 release; future schema additions bump the template version and add migration logic in `/onboard-research` Phase 0.

---

## Deferred to later versions

Tracked here so contributors know what's intentionally NOT in v0.1:

- **`/competitive-monitor`** (v0.3+) — scheduled re-runs of `/web-audit` against tracked URLs with diff detection. Pairs with a Stop-hook.
- **`/research-query`** (v0.3+) — natural-language search across `reference/research/`. Uses index Tier 3 + selective Tier 4 expansion.
- **Stop-hook auto-extract** (v0.3+) — fold session learnings into `reference/research/` automatically. Pattern from `cowork-obsidian v0.6` roadmap.
- **Custom Cowork MCP server** (v0.4+) — `research_get`, `research_search`, `index_resolve` as first-class MCP tools. Ships once we've watched 20+ users hit specific friction.
- **Fireflies MCP support** (v0.3+) — swap-in for Fathom.
- **Notion rich-block writing** (v0.3+) — plain markdown only in v0.2.
- **VidIQ-deep skill (`/youtube-competitive`)** (v0.4+) — for now use VidIQ MCP tools directly via `/research-brief`.

**Shipped in v0.2.0** (no longer deferred): `/save-clip` browser clipper.

---

## Manifest version policy

- **Single source of truth:** `cowork-research/.claude-plugin/plugin.json` `version` field.
- **Mirrors:** `marketplace.json`, `CHANGELOG.md`, `RELEASE-vX.Y.Z.md`, all 4 SKILL.md frontmatter `version:` fields.
- **CI check (Phase G.1 in the implementation plan):** `grep -rn "0\.0\.\|0\.2\.\|0\.5\."` across `*.json *.md *.sh` excluding `.git/` — must return zero matches in initial release. Future releases extend the grep pattern to include the previous version.
- **Semver:** patch for bug fixes, minor for new skills/phases, major for breaking schema changes (state.md, plugin.json structure, or removed skills).

Lesson from `cowork-obsidian` 0.3↔0.4 mismatch: bump every mirror in the same commit as `plugin.json`. Don't trust manual chases.

---

## Folder structure

```
cowork-research/                          # repo root
├── README.md                             # user-facing
├── CHANGELOG.md                          # Keep-a-Changelog format
├── RELEASE-v0.1.0.md                     # marketing-voice release notes
├── LICENSE                               # MIT
├── .claude-plugin/
│   └── marketplace.json                  # plugin marketplace entry
├── build-release-zip.sh                  # excludes docs/sops/* defensively
├── release/
│   └── cowork-research-v0.1.0.zip        # produced by build-release-zip.sh
└── cowork-research/                      # the actual plugin
    ├── .claude-plugin/
    │   └── plugin.json                   # version: 0.2.0
    ├── docs/
    │   └── architecture.md               # this file
    └── skills/
        ├── onboard-research/             # the wizard
        │   ├── SKILL.md                  # 100–150 line dispatcher
        │   ├── phases/                   # 00..07 phase files
        │   ├── checks/                   # prereq + cloud-sync checks
        │   ├── personalization/          # 6 business-type profiles
        │   ├── catalogs/                 # connectors-research.md (offline fallback)
        │   └── templates/                # state, hot-cache, preferences templates
        ├── research-brief/
        │   ├── SKILL.md
        │   └── templates/brief-template.md
        ├── save-clip/                        # v0.2.0
        │   ├── SKILL.md
        │   └── templates/clip-template.md
        ├── web-audit/
        │   ├── SKILL.md
        │   └── templates/web-audit-checklist.md
        └── meeting-recap/
            ├── SKILL.md
            └── templates/meeting-recap-template.md
```

Course SOPs live in the **private** course workspace, NOT in this repo. This is a hard rule (cowork-obsidian v0.5 cleanup, commit `f651a3a`). `build-release-zip.sh` defensively excludes `docs/sops/*` even if a contributor accidentally adds them.

---

## Hard rules (contributor checklist)

- Never re-collect identity (read `about-me/`, never overwrite)
- Append-only on `about-me/connections.md` and `safe-zones.md`
- Plan-then-approve for every write outside `safe-zones.md`-declared paths
- 3rd–4th-grade reading level for every prompt the wizard shows the user
- Resumable: every phase reads + writes `state-research.md`
- No course SOPs in this repo (private workspace only)
- Bump every version mirror in the same commit as `plugin.json`
- Match `cowork-ai-os v0.10` connector schema verbatim in `connectors-research.md`
