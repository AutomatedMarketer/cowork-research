# v0.1.0 — Initial Release: Research Engine for the Cowork AI OS

## The big idea

In April 2026, Andrej Karpathy published a gist titled [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) that crystallized something the field had been circling: **a markdown library is the cheapest, most durable long-term memory your AI agent will ever own.** Plain text. No vendor lock-in. Every Claude model can read it natively.

> "Obsidian is the IDE, the LLM is the programmer, the wiki is the codebase. You rarely ever write or edit the wiki manually." — Karpathy, April 4, 2026

Corey Ganim's framing applies the same idea to research specifically:

> "Stop treating Cowork like a chatbot. Treat it like an employee. The first day on the job, you tell it about your business. After that, every research task is just delegation."

`cowork-research v0.1.0` is the install + scaffold + wiring that makes this practical for Claude Cowork users. This release is the third plugin in the Cowork AI OS family: `cowork-ai-os` gives the assistant identity, `cowork-obsidian` gives it long-term memory, and now `cowork-research` gives it the right tools and calibrated voice for brand briefs, web audits, and meeting recaps.

## What's new

- **4 skills shipped:** `/onboard-research` (the wizard), `/research-brief` (600-word brief + 5-bullet TLDR), `/web-audit` (CRO + competitive audit), `/meeting-recap` (Fathom → decisions + actions + questions).
- **6 personalization profiles** — one per business type (Solo coach, Agency owner, Creator, Course creator, Solopreneur/SMB, Sales-led B2B). The wizard reads your `business-brain.md`, classifies you into one type, and drives Phase 2 connector recommendations + Phase 6 first-research demo from the matching profile.
- **4-tier memory model** — identity (300 tokens) + research hot cache (500) + research index (1,000) + individual outputs (loaded only when matched). Typical research query touches ~3,500 tokens, not 50,000. Past briefs become input context for new ones.
- **Per-business-type connector recommendations** — agency owners get Firecrawl + Perplexity + Playwright; coaches get Perplexity + Fathom + Notion; creators get VidIQ + Perplexity + Firecrawl. Surfaced paste-ready, never auto-installed.
- **Live connector recommendations via `cowork-ai-os v0.10.2`** — the wizard's Phase 2 delegates to `/browse-connectors`, which fetches `claude.com/connectors` at runtime in v0.10.2+. No stale bundled catalogs. Falls back gracefully to the bundled `connectors-research.md` on older `cowork-ai-os` versions.
- **State.md resumable wizard** — stop any time, pick up at the next pending phase. Schedules a 14-day calibration check to re-run `/audit` and track 4 Cs score movement.
- **`reference/_research-hot.md`** — new tier-2 memory file at the workspace level (not vault-only). Auto-populated during onboarding; refreshed on cadence.

## What's not in this release

- **Course SOP content** (Karpathy + Ganim-framed lessons on the research-assistant methodology) lives privately in the course workspace, not in this public plugin repo. The plugin ships as a plugin — install it, run `/onboard-research`, and the wizard handles the rest.
- **Browser clipper, Chrome extension, Fireflies, Notion rich blocks, `/competitive-monitor`, `/research-query`** — all deferred to v0.2+. See the [CHANGELOG](./CHANGELOG.md) for the full deferred list.

## Install / upgrade

New install:

```
/plugin marketplace add AutomatedMarketer/cowork-research
/plugin install cowork-research@cowork-research
/onboard-research
```

The wizard is resumable via `state-research.md` and skips phases you've already completed.

**Prereq:** `cowork-ai-os >= 0.10` must be installed and onboarded first (so `about-me/business-brain.md` exists). The wizard halts cleanly with a paste-ready prompt if it's missing. `cowork-ai-os >= 0.10.2` is recommended for live connector catalogs.

## Breaking changes

**None.** This is the initial release.

## What's next

- **v0.2 — the compounding loop.** `/competitive-monitor` (scheduled audit re-runs with diff detection), `/save-clip` (browser clipper / Chrome extension), `/research-query` (natural-language search across the library), Fireflies MCP swap-in, Notion rich-block writing, Stop-hook auto-extract-to-research-library.
- **v0.3+ — custom Cowork MCP server.** Once we've watched 20+ users hit specific friction, we ship `research_get`, `research_search`, `index_resolve` as first-class MCP tools.
- **The modular-plugin roadmap.** `cowork-research` is the third in a planned family: `cowork-ai-os` (identity) → `cowork-obsidian` (vault) → `cowork-research` (THIS) → `cowork-financial` (P&L + cashflow briefs) → `cowork-social` (posting + scheduling) → `cowork-highlevel` (GoHighLevel CRM ops). Each ships independently. None require the others, but they compose well when you stack them.

## Credits

Built by Nuno Tavares of Automated Marketer for the [VCInc](https://vcinc.com) cohort. Karpathy framing borrowed gratefully from the [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). "Cowork as employee" framing borrowed from Corey Ganim's pattern. Source course material drawn from Jack Roberts' Cowork course (Chapter 5 use cases on brand briefs, web audits, and meeting recaps). Memory architecture pattern carried over from `cowork-obsidian v0.5`.
