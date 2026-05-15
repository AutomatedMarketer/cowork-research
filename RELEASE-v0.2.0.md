# v0.2.0 — Browser Clipper + Catalog Accuracy

## The big idea

A research library only compounds if you keep feeding it. v0.1.0 gave you `/research-brief`, `/web-audit`, and `/meeting-recap` — three ways to *generate* research. But the missing piece was the act of *capturing* — the moment you read something good and want it in your library before you close the tab.

That's what `/save-clip` is for. Paste a URL, get clean markdown in `reference/research/clips/<slug>.md` with frontmatter (source URL, tags, accessed date, your note). The next time you run `/research-brief`, the brief skill knows about that clip and can cite it. The library becomes a flywheel instead of a graveyard of unread tabs.

## What's new

- **`/save-clip` skill** — paste a URL, drop a clean-markdown clip into your research library. Firecrawl is the primary scraper (`--only-main-content` strips nav/ads/footer). Playwright is the fallback for blocked or login-walled pages — heads up, it opens a real browser when used. Plan-then-approve before any write. Frontmatter has source URL, accessed date, ICP-matched tag suggestions read from `business-brain.md`, and an optional one-line user note. Append-only updates to `reference/research/_index.md` and `projects/research/memory.md`. Optional vault fold-back per `research-preferences.md` (ask / always / never).
- **Phase 2 mention of `/save-clip`** — the wizard now surfaces the clipper alongside Firecrawl during connector recommendations. Recommended for all 6 business types.
- **Phase 7 wrap-up lists 4 skills** — `/research-brief`, `/save-clip`, `/web-audit`, `/meeting-recap`. The closing message now points the user at the clipper as part of their everyday rhythm.
- **Per-profile post-onboarding pointer** — all 6 personalization profiles get a one-line "Quick-capture habit (post-onboarding): Use `/save-clip` whenever you find an article worth keeping. The library compounds over weeks." Identical wording across the 6 profiles for v0.2 (we'll customize per business type in a later version if usage data tells us to).
- **Catalog accuracy fixes** — Context7 + Playwright verification commands now use the actual MCP namespace (doubled prefix — `mcp__plugin_context7_context7__` and `mcp__plugin_playwright_playwright__`). The single-prefix versions never worked; this was a v0.1 bug. Plus an authentication call-out at the top of the catalog: most MCPs prompt for API key or OAuth on first use, so the wizard sets expectations before the user hits a verification command that "fails" (it's just asking for credentials).
- **4 cross-cutting MCPs live-verified** — Perplexity, Firecrawl, Context7, Playwright all dogfooded in a default Cowork environment on 2026-05-15. Catalog stamps these with the live-smoke-test date.

## What's still deferred

These move to v0.3+ to keep v0.2 tight:

- **`/competitive-monitor`** — scheduled re-runs of `/web-audit` against tracked URLs with diff detection. Pairs with a Stop-hook.
- **`/research-query`** — natural-language search across `reference/research/`. Uses index Tier 3 + selective Tier 4 expansion.
- **Stop-hook auto-extract-to-research-library** — fold session learnings into `reference/research/` automatically.
- **Fireflies MCP support** — swap-in for Fathom.
- **Notion rich-block writing** — plain markdown only in v0.2.
- **Custom Cowork MCP server** — `research_get`, `research_search`, `index_resolve` as first-class MCP tools. Ships once we've watched 20+ users hit specific friction.

## Install / upgrade

New install:

```
/plugin marketplace add AutomatedMarketer/cowork-research
/plugin install cowork-research@cowork-research
/onboard-research
```

Upgrading from v0.1.0:

```
/plugin update cowork-research
```

The `/onboard-research` wizard is idempotent — re-running it after the upgrade will detect `install_complete: true` from your previous install and offer to redo a specific phase. You don't need to re-onboard to use `/save-clip`; just paste a URL and run it.

**Prereqs (unchanged):** `cowork-ai-os >= 0.10` for identity files, `>= 0.10.2` recommended for live connector catalogs. Optional `cowork-obsidian >= 0.5` for vault destination + fold-back.

## Breaking changes

**None.** v0.2 is purely additive. The 4 v0.1 skills work identically. The catalog fix (MCP namespace prefixes) corrects bugs that would have caused verification commands to fail silently — no user code depends on the broken strings.

## What's next

- **v0.3 — the search + monitor loop.** `/competitive-monitor` (scheduled audit re-runs with diff), `/research-query` (NL search across the library), Stop-hook auto-extract-to-research-library, Fireflies MCP swap-in, Notion rich-block writing.
- **v0.4+ — custom Cowork MCP server.** Once we've watched 20+ users hit specific friction, we ship `research_get`, `research_search`, `index_resolve` as first-class MCP tools.
- **The modular-plugin roadmap is unchanged.** `cowork-ai-os` (identity) → `cowork-obsidian` (vault) → `cowork-research` (THIS) → `cowork-financial` (P&L + cashflow briefs) → `cowork-social` (posting + scheduling) → `cowork-highlevel` (GoHighLevel CRM ops). Each ships independently. None require the others, but they compose well when stacked.

## Credits

Built by Nuno Tavares of Automated Marketer for the [VCInc](https://vcinc.com) cohort. Karpathy framing borrowed gratefully from the [LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). "Cowork as employee" framing borrowed from Corey Ganim's pattern. Memory architecture pattern carried over from `cowork-obsidian v0.5`. v0.2 specifically: the clipper-as-flywheel framing came from watching cohort users repeatedly say "I read something great but never wrote it down" — the missing capture step is what gates compounding.
