# connectors-research.md — Research-specific MCP connector catalog

> Used by `/onboard-research` Phase 2 to recommend connectors per business type. Schema mirrors `cowork-ai-os` v0.10 `browse-connectors` exactly. Last verified: 2026-05-14 (most entries) / 2026-05-15 (4 cross-cutting MCPs live smoke-tested).

> **v0.1 + cowork-ai-os v0.10.2 update:** As of cowork-ai-os v0.10.2, `/browse-connectors` lives-fetches the official Cowork directory from `claude.com/connectors`. This bundled catalog is now the **offline cache fallback** only — Phase 2 of `/onboard-research` will pull live data when possible. The 7-bucket framework here remains useful as the organizing structure for the wizard's recommendations.

> **Authentication note (read first):** Most MCPs need authentication on first use (API key or OAuth). Cowork prompts for credentials when you invoke a tool that needs them. The wizard's Phase 2 explains the auth flow per connector — don't expect a verification command to "just work" until the connector is authenticated. Look for the "Authenticate first if Cowork prompts (one-time)" prefix on the first-week test for any auth-required connector below.

## Cross-cutting baseline (recommend for all business types)

### Perplexity Ask

- **slug:** `perplexity-ask`
- **bucket:** Knowledge (cross-cutting research)
- **what it does:** Real-time web search + LLM reasoning. Returns answers with citations.
- **best for:** All 6 business types — fastest path from question to cited answer
- **add it:** Already installed in default Cowork environments. Verify with `which mcp__perplexity-ask__perplexity_ask`. If missing, see Anthropic MCP docs.
- **what you unlock:** Synthesis-style research without leaving chat
- **first-week test:** Authenticate first if Cowork prompts (one-time). Ask Cowork *"using perplexity, what's the latest on [user's competitor]?"*
- **gotchas:** Citations sometimes link to outdated cached pages — spot-check the dates
- **permission level:** Reads = act, no writes
- **last verified:** 2026-05-15 (live smoke test)

### Firecrawl

- **slug:** `firecrawl`
- **bucket:** Knowledge (web fetching)
- **what it does:** Single-page scrape, batch crawl, site map, structured LLM extraction. 83% accuracy benchmark.
- **best for:** Agency owner (daily), Sales-led B2B (account research), Course creator (sales-page teardowns)
- **add it:** Already installed as a Cowork skill. First use prompts for `FIRECRAWL_API_KEY` (env var) or browser login — authenticate once per environment, then verify with `/firecrawl-scrape https://example.com`.
- **what you unlock:** Pulling clean markdown from any URL into your research workflow
- **first-week test:** Authenticate first if Cowork prompts (one-time). `/firecrawl-scrape <competitor-pricing-page>`
- **gotchas:** Some sites block scraping; Firecrawl has a cloud-browser fallback for those (check the docs)
- **permission level:** Reads = act, no writes
- **last verified:** 2026-05-15 (live smoke test)

### Fathom

- **slug:** `fathom`
- **bucket:** Meetings
- **what it does:** AI-transcribed meetings with summaries, action items, speaker insights
- **best for:** Solo coach (every coaching call), Sales-led B2B (every discovery call), Solopreneur (customer-call recall)
- **add it:** Already installed in default Cowork environments. Verify with the Fathom MCP tools. If missing, see Fathom MCP setup docs.
- **what you unlock:** `/meeting-recap` skill works end-to-end
- **first-week test:** Authenticate first if Cowork prompts (one-time). Run `/meeting-recap <fathom-url>` on yesterday's most important call
- **gotchas:** Pasted Fathom URLs work; pasted call IDs work; some custom-share links need URL resolution first
- **permission level:** Reads = act, no writes
- **last verified:** 2026-05-14

### Context7

- **slug:** `context7`
- **bucket:** Knowledge (technical docs)
- **what it does:** Current docs for 1000+ libraries (React, Next, Django, FastAPI, Prisma, etc.)
- **best for:** Sales-led B2B selling to dev teams; any creator/educator covering tech topics
- **add it:** Already installed as MCP. Verify with `mcp__plugin_context7_context7__query-docs` (note the doubled `_context7_context7__` prefix — this is the actual tool namespace).
- **what you unlock:** Library-specific brief generation that's actually current
- **first-week test:** `/research-brief` on a library the user's customers ask about
- **gotchas:** Doesn't replace Perplexity for non-library questions
- **permission level:** Reads = act, no writes
- **last verified:** 2026-05-15 (live smoke test)

## Business-type specific recommendations

### For Creator: VidIQ

- **slug:** `vidiq`
- **bucket:** Knowledge (YouTube competitive intel)
- **what it does:** Channel stats, video performance, engagement trends, outlier detection, transcript analysis, keyword research
- **best for:** Creator, Course creator (anyone whose customers watch YouTube)
- **add it:** Already installed in default Cowork environments. Verify with VidIQ MCP tools.
- **what you unlock:** Unique YouTube signal Perplexity can't surface — outlier detection, sub-velocity, keyword opportunity scoring
- **first-week test:** Authenticate first if Cowork prompts (one-time). `vidiq_outliers` against a competitor channel
- **gotchas:** Outlier detection requires a few minutes of API time on large channels — be patient
- **permission level:** Reads = act, no writes
- **last verified:** 2026-05-14

### For Agency owner: Playwright

- **slug:** `playwright`
- **bucket:** Knowledge (web fetching — login-walled)
- **what it does:** Browser automation. Reaches pages Firecrawl can't (logged-in dashboards, JS-heavy SPAs, multi-step funnels).
- **best for:** Agency owner (SaaS competitor analysis), Sales-led B2B (when target accounts hide pricing)
- **add it:** Already installed as MCP plugin. Verify with `mcp__plugin_playwright_playwright__browser_navigate` (note the doubled `_playwright_playwright__` prefix — this is the actual tool namespace).
- **what you unlock:** Audit pages behind logins (with user's own credentials, never stored)
- **first-week test:** Use Playwright + `/web-audit` on a SaaS competitor's logged-in dashboard
- **gotchas:** Playwright sessions don't persist credentials — re-login per session
- **permission level:** Reads = act (browse), no writes (no form submissions without explicit user approval)
- **last verified:** 2026-05-15 (live smoke test)

## Optional / advanced recommendations (only surface if user asks)

### Notion (Knowledge destination)

- **slug:** `notion`
- **bucket:** Knowledge (research destination)
- **what it does:** Query/search Notion workspace, create docs, manage databases
- **best for:** Anyone whose existing knowledge base is in Notion
- **add it:** Notion MCP setup (OAuth flow). See Notion MCP docs.
- **what you unlock:** `/research-brief` and `/meeting-recap` can write directly into Notion as the destination instead of workspace files
- **first-week test:** Authenticate first if Cowork prompts (one-time OAuth). Run a brief and confirm it lands in the chosen Notion database
- **gotchas:** Plain markdown only in v0.1 — rich blocks coming in v0.2
- **permission level:** Reads = act, writes = ask, destructive = blocked
- **last verified:** 2026-05-14

### Google Drive

- **slug:** `google-drive`
- **bucket:** Knowledge (research destination + file ingestion)
- **what it does:** Search, read, categorize files across shared drives
- **best for:** Anyone with team Google Workspace; teams with institutional memory in Drive
- **add it:** Already installed in default Cowork environments. Verify with Drive MCP tools.
- **what you unlock:** Pull existing Drive docs into research briefs as additional sources
- **first-week test:** Authenticate first if Cowork prompts (one-time OAuth). `/research-brief` on a topic that has 3+ existing Drive docs; verify they appear in sources
- **gotchas:** Drive search is keyword-based, not semantic — frame search terms accordingly
- **permission level:** Reads = act, writes = ask
- **last verified:** 2026-05-14

## Skip-list (research-relevant MCPs we deliberately don't recommend in v0.1)

- **Brave Search** — Perplexity is dramatically better for synthesis-style research; Brave returns links, Perplexity returns cited answers
- **Tavily** — no meaningful win over Perplexity for our use cases; recommend only if user already has Tavily API budget
- **Fireflies** — Fathom is already installed; don't add a second transcription tool. Fireflies is on v0.2 roadmap as a swap-in.
- **GitHub MCP** — useful but too niche for non-dev audiences in v0.1; surface only if user is a dev-tools founder
- **Slack search** — internal-comms search, not external research; out of scope
- **Beehiiv** — newsletter ops, future plugin
- **SimilarWeb / BuiltWith** — good but narrow (competitor-traffic analysis); recommend after user masters Firecrawl + Perplexity
