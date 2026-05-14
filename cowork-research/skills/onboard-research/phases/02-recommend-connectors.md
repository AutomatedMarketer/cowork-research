# Phase 2 — Recommend Connectors

## What this phase does

**Delegates to `/browse-connectors`** (cowork-ai-os v0.10.2+) which live-fetches Anthropic's MCP directory. We do NOT duplicate the fetch logic here — that's the whole point of v0.10.2's live-fetch helper. We pipe the live-fetched output, then cross-reference it with the user's `personalization/<type>.md` profile (which has the recommended-3 connectors per business type), then ask the user to confirm + install.

The cross-reference is what makes this research-specific: `/browse-connectors` shows the whole directory; we narrow it to the 3 that matter for the user's business type.

## Ask

Two questions, in order:

1. *"I'm checking what connectors Anthropic has in their directory right now (live-fetch — not a hardcoded list). One sec."*
2. After the cross-reference: *"Based on your business type ([type]), the top 3 connectors for research are: **[connector 1]**, **[connector 2]**, **[connector 3]**. Want me to walk you through installing the ones you don't have yet?"*

If the user says yes, then for each missing connector: *"Install **[connector name]** now? [paste-ready command]. Yes / no / skip."*

## Why we ask

> *"Two reasons I'm doing it this way:*
>
> *First, I'm checking Anthropic's directory live so the list is current — not a snapshot from when this plugin shipped. Anthropic adds connectors all the time.*
>
> *Second, I'm matching against your business type so you don't drown in 50 options. A coach needs different research tools than an agency owner."*

## Logic

### Step 1 — Delegate to /browse-connectors (live-fetch)

Invoke `/browse-connectors` from cowork-ai-os v0.10.2. The fetch helper at `cowork-ai-os/cowork-ai-os/skills/browse-connectors/lib/fetch-live-catalog.md` handles the network call, parsing, and offline fallback. We do NOT re-implement any of that.

If `/browse-connectors` is not detected (cowork-ai-os older than v0.10.2), fall back to the bundled offline catalog at [`../catalogs/connectors-research.md`](../catalogs/connectors-research.md) and warn the user: *"Heads up — your cowork-ai-os is older than v0.10.2 so I'm using a cached catalog. Update cowork-ai-os later for live-fetch."*

### Step 2 — Read the personalization profile

Read `personalization/<business_type>.md` (cached from Phase 1). Pull the "Top 3 connector recommendations (ranked)" section.

### Step 3 — Cross-reference

For each of the user's top 3:
- Match it against `/browse-connectors` output by name
- Mark `installed: true | false` (probe by checking if the matching MCP tool prefix is available — e.g., `mcp__perplexity-ask__*` for Perplexity, `mcp__claude_ai_Fathom__*` for Fathom)
- If installed → skip the install prompt, just confirm to the user
- If missing → grab the install command from `/browse-connectors` output (paste-ready)

### Step 4 — Present + walk through installs

Show the user the 3 with status:

```
For your business type ([type]), top 3 connectors:

  1. [name]  — [why it matters in 1 sentence]  — [installed | needs install]
  2. [name]  — [why it matters in 1 sentence]  — [installed | needs install]
  3. [name]  — [why it matters in 1 sentence]  — [installed | needs install]

Want to install the missing ones now?
```

For each missing: show paste-ready install command, ask yes/no/skip, wait for user to confirm install completed (or skip).

### Step 5 — Append accepted recommendations to about-me/connections.md

For every connector the user accepted (whether already-installed or freshly installed):

Append to `<workspace>/about-me/connections.md`:

```markdown
## <ISO timestamp> — added by cowork-research /onboard-research Phase 2
- <connector-name>: status=<installed|skipped>, recommended_for=<business_type>, source=<live-fetch|offline-catalog>
```

**Append-only** — never overwrite existing entries in `connections.md`.

## Write

- `<workspace>/about-me/connections.md` — append block (one entry per accepted recommendation)
- `_aibos/state-research.md` — append:
  - `phase_2_connectors: completed_at <ISO timestamp>`
  - `connectors_recommended: [list of 3 connector names]`
  - `connectors_installed_in_phase_2: [list of names installed during this phase]`
  - `live_fetch_used: <true|false>` (false means offline fallback was used)

## Resume

After this phase completes, mark `phase_2_connectors` as `completed_at <ISO timestamp>` in state-research.md and set `next_pending_phase: 3`. If the user skipped one or more connector installs, that's fine — the missing connectors will surface as gaps in Phase 6 (live-fire) and the user can install later.

## Verification before advancing

Phase 2 is complete when ALL of these are true:

- `/browse-connectors` was invoked (or offline fallback was used with a logged warning)
- The personalization profile's top 3 was cross-referenced against the live (or cached) catalog
- The user explicitly responded to each install prompt (yes / no / skip — no silent skips)
- `about-me/connections.md` has at least the one append block from this phase
- `state-research.md` reflects which connectors are now installed

If the user has 0 of the 3 recommended connectors installed and refused all of them, surface a soft warning: *"You skipped all 3. The Phase 6 live-fire demo may not work without at least one. Want to install one now, or push on and we'll improvise in Phase 6?"*
