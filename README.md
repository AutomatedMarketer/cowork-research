# cowork-research

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](./LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-brightgreen.svg?style=flat-square)](./CHANGELOG.md)
[![Platform: Mac · Windows · Linux](https://img.shields.io/badge/platform-Mac%20%C2%B7%20Windows%20%C2%B7%20Linux-blue.svg?style=flat-square)](#install)
[![Built for Claude Cowork](https://img.shields.io/badge/built%20for-Claude%20Cowork-7C3AED.svg?style=flat-square)](https://claude.com/product/claude-code)

A [Claude Cowork](https://claude.com/product/claude-code) plugin that turns your assistant into a **full-time research analyst** — brand briefs, web audits, and meeting recaps that compound across every business decision you make.

> **Stop pasting links into ChatGPT. Your assistant already knows your business, your ICP, and your offer. Give it the right tools and it researches in your voice.**

Built by [Nuno Tavares](https://nunomtavares.com) for [VCInc](https://vcinc.com) cohort students and anyone who wants research that accumulates instead of evaporating after every conversation.

---

## Why this exists

In April 2026, Andrej Karpathy published [LLM Wiki](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f), a gist that crystallized the markdown-vault-as-second-brain pattern:

> "Obsidian is the IDE, the LLM is the programmer, the wiki is the codebase. You rarely ever write or edit the wiki manually."

Corey Ganim's framing applies the same idea to research specifically:

> "Stop treating Cowork like a chatbot. Treat it like an employee. The first day on the job, you tell it about your business. After that, every research task is just delegation."

Same pattern, two voices. Both point at the same thing: **a research workflow where your assistant already knows the context, has the right tools wired up, and writes outputs that match how YOU think.** This plugin is the install + scaffold + wiring that makes that practical for Claude Cowork users.

`cowork-research` soft-depends on `cowork-ai-os` for identity (`about-me/about-me.md`, `business-brain.md`, `connections.md`). When `cowork-ai-os v0.10.2+` is detected, the wizard's Phase 2 delegates connector recommendations to the live `/browse-connectors` skill — which fetches `claude.com/connectors` at runtime, so you always get the current catalog instead of a stale bundled snapshot. Older versions still work via the bundled fallback.

---

## What it ships (4 skills)

| Skill | Slash | What it does |
|---|---|---|
| **Onboard wizard** | `/onboard-research` | 7-phase install (~12 min). Reads your business context, classifies into 1 of 6 business types, recommends top 3 connectors for your type, picks a default research destination, calibrates your preferences. State.md resumable. |
| **Research brief** | `/research-brief` | 600-word executive brief + 5-bullet TLDR on any topic, competitor, account, methodology, or library. Cited. Plan-then-approve writes. |
| **Web audit** | `/web-audit` | CRO + competitive audit of any URL. Bulleted recommendations grouped by severity (block / fix / consider). Read-only on web. |
| **Meeting recap** | `/meeting-recap` | Fathom transcript → decisions + action items + open questions + notable quotes. Paste a Fathom URL or call ID and it does the rest. |

That's the whole surface. Four commands. Run `/onboard-research` once and the wizard wires the rest.

---

## How memory works (the 4 tiers)

Borrowed from `cowork-obsidian`'s memory architecture. Same pattern, applied to research outputs instead of vault notes.

| Tier | What | Where | Loaded when | ~Token cost |
|---|---|---|---|---|
| 1 | Identity | `about-me/` (cowork-ai-os) | Skills that need it | 300 |
| 2 | Research hot cache | `reference/_research-hot.md` | Start of any research session | 500 |
| 3 | Research index | `reference/research/_index.md` | When picking which past brief is relevant | 1,000 |
| 4 | Individual outputs | `reference/research/briefs/<topic>.md` (and `audits/`, `meetings/`) | Only when explicitly named or matched | 600–1,200 each |

A typical research query touches ~3,500 tokens, not 50,000. Past briefs become input context for new ones. Audits inform briefs. Meeting recaps surface in account research. The library compounds.

---

## Per-business-type connector matrix

Phase 2 of the wizard reads your `business-brain.md`, classifies you into one of 6 business types, and recommends the top 3 connectors for that type. Here's the matrix:

| Business type | Connector 1 | Connector 2 | Connector 3 |
|---|---|---|---|
| **Solo coach** | Perplexity Ask | Fathom | Notion or Obsidian vault |
| **Agency owner** | Firecrawl | Perplexity Ask | Playwright |
| **Creator** (content business) | VidIQ | Perplexity Ask | Firecrawl |
| **Course creator / educator** | Perplexity Ask | VidIQ | Firecrawl |
| **Solopreneur / SMB** | Perplexity Ask | Firecrawl | Fathom |
| **Sales-led B2B** | Firecrawl | Perplexity Ask | Fathom |

Why these picks (full reasoning per type): see [`docs/architecture.md`](./cowork-research/docs/architecture.md) and the per-type personalization profiles at [`skills/onboard-research/personalization/`](./cowork-research/skills/onboard-research/personalization/).

The wizard never installs MCP servers for you — it surfaces paste-ready install instructions and verifies what's already wired. Your environment, your call.

---

## ⚡ 1-minute install

```
/plugin marketplace add AutomatedMarketer/cowork-research
/plugin install cowork-research@cowork-research
/onboard-research
```

That's it. The wizard is resumable — stop any time, pick up where you left off.

---

## Dependencies

`cowork-research` is **standalone** but plays nice with the rest of the Cowork AI OS family:

- **Soft-depends on `cowork-ai-os >= 0.10`** — for identity files (`about-me/about-me.md`, `business-brain.md`, `connections.md`). The wizard halts cleanly with a paste-ready prompt if these are missing. Without them the assistant has no idea who you are or what your ICP looks like.
- **`cowork-ai-os >= 0.10.2` recommended** — Phase 2 of the wizard delegates to `/browse-connectors`, which v0.10.2 made live (fetches `claude.com/connectors` at runtime). On v0.10.0 / v0.10.1 the wizard still works — it falls back to the bundled connector catalog (verified 2026-05-14, may drift).
- **Optionally integrates with `cowork-obsidian >= 0.5`** — if you have a vault, Phase 3 of the wizard offers it as the research destination. Brief + audit + recap outputs land in `wiki/research/` instead of `reference/research/`. Fold-back into the wiki is offered, never required.

---

## How it works (no jargon)

When you run `/research-brief`, here's what happens under the hood:

1. The skill reads your `about-me/business-brain.md` to know your ICP, voice, and what "competitor" means in your world.
2. It reads `reference/_research-hot.md` for the current state of your research library.
3. It picks the right MCPs based on the topic — Perplexity for synthesis, Firecrawl for scraping, VidIQ for YouTube, Fathom for meeting recall.
4. It drafts the brief in YOUR voice (calibrated during onboarding).
5. It shows you the plan before writing anything to disk.
6. On approval, it saves to `reference/research/briefs/<topic>.md` AND updates the index AND appends to memory.

No MCP server required for the plugin itself — Cowork has filesystem access. The MCPs are for *external* data (Perplexity, Firecrawl, VidIQ, Fathom) and you wire them once during Phase 2.

---

## What's NOT in v0.1

Deferred to v0.2+ to keep the initial release tight:

- ❌ **`/competitive-monitor`** — scheduled re-runs of audits with diff detection. Phase D in the roadmap.
- ❌ **`/save-clip`** browser clipper / Chrome extension — capture from any tab into your research library.
- ❌ **`/research-query`** — natural-language search across `reference/research/`.
- ❌ **Fireflies MCP support** — Fathom-only in v0.1; Fireflies is a swap-in for v0.2.
- ❌ **Notion rich-block writing** — plain markdown only in v0.1; rich blocks in v0.2.
- ❌ **VidIQ-deep skill** (`/youtube-competitive`) — for now use the existing VidIQ MCP tools directly.
- ❌ **Stop-hook auto-extract-to-research-library** — v0.2 will fold session learnings back into `reference/research/` automatically.
- ❌ **Custom Cowork MCP server** — once we've watched 20+ users hit specific friction, we'll ship `research_get`, `research_search`, `index_resolve` as first-class MCP tools.

---

## Who this is for

- **Solo coaches** — competitive context on the methodologies your clients ask about
- **Agency owners** — pre-call account research and free-value audits as sales lead-ins
- **Creators** — outlier detection and trend research that's actually current
- **Course creators** — competing-course teardowns with structured comparison
- **Solopreneurs / SMB owners** — one-off briefs on whatever is most-pressing this week
- **Sales-led B2B** — target-account briefs with tech stack + recent news + likely buying triggers

If you've watched ChatGPT forget your business context for the 50th time, or your "competitor research doc" is a Slack channel of pasted links no one reads, this is the alternative.

---

## Install

### Mac

<details>
<summary><b>Mac install (click to expand)</b></summary>

1. Download `cowork-research.zip` from the [latest release](https://github.com/AutomatedMarketer/cowork-research/releases/latest)
2. Open Claude Desktop → click your name (top right) → **Settings**
3. **Customize** → **Browse plugins** → upload the zip
4. Open a fresh Cowork task → run `/onboard-research`

</details>

### Windows

<details>
<summary><b>Windows install (click to expand)</b></summary>

```
/plugin marketplace add AutomatedMarketer/cowork-research
/plugin install cowork-research@cowork-research
```

Then in a fresh Cowork task:

```
/onboard-research
```

</details>

### Linux

<details>
<summary><b>Linux install (click to expand)</b></summary>

Same as Windows:

```
/plugin marketplace add AutomatedMarketer/cowork-research
/plugin install cowork-research@cowork-research
/onboard-research
```

</details>

---

## Coordination with the Cowork AI OS family

| Plugin | Role | Required? |
|---|---|---|
| **`cowork-ai-os`** | Identity + connector discovery + safe-zones | Soft-required (`>= 0.10`); v0.10.2+ recommended for live connector catalogs |
| **`cowork-research`** *(this one)* | Research engine — briefs, audits, recaps | — |
| **`cowork-obsidian`** | Vault as long-term memory | Optional (`>= 0.5`); enables vault destination + fold-back |
| **`cowork-financial`** *(future)* | P&L, cashflow, financial briefs | Out of scope for v0.1 |
| **`cowork-social`** *(future)* | Social posting + scheduling | Out of scope for v0.1 |

Cohort install order: `cowork-ai-os` first → `cowork-obsidian` (if you want a vault) → `cowork-research`.

---

## License

[MIT](./LICENSE) — yours forever.

## Built by

[Nuno Tavares](https://nunomtavares.com) — Newsletter: [automatedmarketer.net](https://automatedmarketer.net) · YouTube: [@AutomatedMarketer](https://youtube.com/@AutomatedMarketer)

## Links

- [Anthropic Claude Code docs](https://docs.claude.com/en/docs/claude-code)
- [`cowork-ai-os` plugin](https://github.com/AutomatedMarketer/cowork-ai-os) — identity + connector layer
- [`cowork-obsidian` plugin](https://github.com/AutomatedMarketer/cowork-obsidian) — second-brain layer
- [Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) — the framing
