---
name: save-clip
slug: /save-clip
version: 0.2.0
plugin: cowork-research
description: Clip any URL into your research library as clean markdown. Reads about-me/business-brain.md for tag suggestions. Uses Firecrawl primary + Playwright fallback for login-walled pages. Lands in reference/research/clips/<slug>.md with frontmatter (source URL, accessed date, tags, user note). Plan-then-approve writes. Optional vault fold-back per preferences.
triggers:
  - /save-clip
  - clip this
  - save this article
  - save this page
  - clip url
---

# /save-clip — v0.2.0

Clip any URL into your research library as clean markdown. The library compounds — every clip you save becomes input context for future briefs.

## Inputs

- **Required:** URL (free-form — paste any link)
- **Optional:** `--note "<reason>"` — your one-line reason for clipping (gets stored in frontmatter)
- **Read on every run (lazy — only when invoked):**
  - `about-me/about-me.md` (user identity)
  - `about-me/business-brain.md` (ICP, terminology, focus areas → drives tag suggestions)
  - `reference/research/_index.md` (dedup check — has user already clipped this URL?)
  - `projects/research/research-preferences.md` (destination, clip-format preference, fold-back default)

## Logic

### Step 1 — Read the inputs (lazy)

Read all 4 input files. If `business-brain.md` is missing, halt with the paste-ready prompt: *"I need `about-me/business-brain.md` to suggest tags. Run `/onboard` from cowork-ai-os first, then come back."*

### Step 2 — Dedup check

Search `reference/research/_index.md` for the URL. If it appears within the last 30 days:
> *"You clipped this on [date]. Want to re-clip (overwrite), keep both with a date suffix, or read the existing clip?"*

Default suggestion: read the existing clip. Re-clipping is rare and usually means the page changed materially.

### Step 3 — Scrape the URL (Firecrawl primary)

Run `firecrawl scrape <url> --only-main-content -o .firecrawl/clip-tmp.md` — strips nav, ads, footer, sidebar; keeps only the main article body.

Capture:
- Page title (from `<title>` or first H1)
- Word count of scraped content
- Domain (for tag suggestion + provenance)

### Step 4 — Fallback to Playwright if Firecrawl fails

If Firecrawl reports the page is blocked, login-walled, or returns < 100 words of content:

1. Tell the user: *"Firecrawl couldn't reach this page (blocked or login-walled). Using Playwright as a fallback — heads up, this opens a real browser."*
2. Use `mcp__plugin_playwright_playwright__browser_navigate` to open the URL
3. Use `mcp__plugin_playwright_playwright__browser_snapshot` to capture the page accessibility tree
4. Convert the snapshot to clean markdown (strip layout cruft, keep semantic content)
5. If the page requires login, ask the user to log in manually in the open browser, then continue

### Step 5 — Suggest tags

Cross-reference the scraped content against `business-brain.md`:
- Match against ICP keywords → tag with the matched ICP segment
- Match against named methodologies / frameworks → tag with those
- Match against named competitors / thought-leaders → tag with the name
- Match against current focus areas (Q&A, project, launch) → tag with that focus

Suggest 3–5 tags max. Always show the user the source text that drove each tag suggestion.

### Step 6 — Plan-then-approve

Show the user the clip plan (one block):

```
Plan for /save-clip:

  Source URL:   <url>
  Title:        <scraped title>
  Word count:   ~<N> words
  Destination:  reference/research/clips/<slug>.md
  Tags I'll suggest: <tag1>, <tag2>, <tag3>
  User note:    <--note value or "(none)">

Approve? Or edit tags / change destination first.
```

### Step 7 — Write the clip

On approval, write to `reference/research/clips/<slug>.md` using `templates/clip-template.md` shape. Frontmatter MUST include:

- `title:` — the scraped title
- `source_url:` — the original URL
- `accessed_date:` — ISO date of the clip run
- `business_tags:` — array of approved tags
- `clipped_by:` — `/save-clip` (cowork-research v0.2.0)
- `user_note:` — the `--note` value or empty string

Body: a `## Source content` H2 followed by the scraped markdown.

### Step 8 — Append to research index

Append one line to `reference/research/_index.md`:
```
<ISO date> | clip | <slug> | <path> | <source URL>
```

### Step 9 — Append to memory

Append one line to `projects/research/memory.md`:
```
<ISO timestamp> — clipped <title> from <domain>
```

### Step 10 — Optional vault fold-back

Read `research-preferences.md`. If the user set `vault_foldback: ask`, prompt:
> *"Fold this clip into your vault too? It'd land in `wiki/research/clips/`."*

If `vault_foldback: always`, do it silently. If `vault_foldback: never`, skip.

## Output

- `reference/research/clips/<slug>.md` — the clip (with frontmatter)
- One-line append to `reference/research/_index.md`
- One-line append to `projects/research/memory.md`
- Optional vault fold-back per preferences

## Hard rules

- 3rd–4th-grade reading level in user-facing prompts (NOT in the clipped content — that's the original author's voice)
- Plan-then-approve before any write
- Never write outside `safe-zones.md`-declared paths
- Append-only on `_index.md` and `memory.md`
- Never strip or rewrite the source content — clean extraction only, preserve the author's voice

## Voice for the clip itself

The clipped content is the original author's voice — don't paraphrase, don't summarize, don't editorialize. The frontmatter is your tagging layer; the body is the author's text. This is research-archive, not synthesis.

## Self-improvement close (Foundation B)

After delivering the main output + Next Move block, ask:

> "What would've made this 10% better?"

Accept a one-line answer. Then:

1. Append to `projects/research/memory.md`:
   ```
   <YYYY-MM-DD> | /save-clip | <answer verbatim>
   ```

2. Read `memory.md` and check if any pattern recurs 3+ times for `/save-clip`. Patterns matching by:
   - Substring overlap >= 60% with prior entries
   - Same keyword (e.g., "tags", "Firecrawl", "Playwright", "fallback", "destination", "frontmatter", "dedup")

3. If recurrence detected:
   - Surface: "I've seen this 3+ times. Want me to update `/save-clip` itself?"
   - If yes → draft change to `projects/research/skill-improvements.md` in this format:
     ```
     | /save-clip | <pattern> | <first_seen_date> | <recurrence_count> | <suggested_change> | <reviewed: no> |
     ```

4. If no recurrence → silent. No noise.

## Actionable close (Foundation C)

End every run with this exact block (the `⚡ NEXT MOVE:` string is canonical — caps, leading lightning emoji, colon, space):

```
⚡ NEXT MOVE: <Subject> <Verb> <Timing>
   Why: <one-sentence reason tied to the clip's content or tags>
```

The Next Move MUST be the single highest-value action this clip unlocks. Pick from:

| Clip type | Likely Next Move pattern |
|---|---|
| Clip on a topic the user is actively researching | "Run `/research-brief` on <topic> today — this clip is the seed for a deeper synthesis." |
| Clip the user explicitly tied to an upcoming deliverable | "Cite this clip in <upcoming deliverable> by <date> — it's the proof point you needed." |
| Clip on reference material with no urgent use | "Schedule re-read in 7 days — flag with `?` if it doesn't click on second pass." |
| Pure archive (informational only) | "Tag and forget — it's in your library now, search `/research-query` will surface it later." |

**Picking rule:** prefer external action (cite, brief, share) over internal re-read. Re-read only when no clear external use is visible from the clip's content + tags.

✅ "⚡ NEXT MOVE: Run /research-brief on direct-response email cadence today. Why: This Belcher clip is the seed for the brief that informs your June launch."
❌ "⚡ NEXT MOVE: Read this later." (no subject specificity, no timing tied to the clip — fails the rule)

### Validation pattern
The block MUST match:
`⚡ NEXT MOVE: .+ .+ .+\n   Why: .+`

If it doesn't match, the skill output is incomplete — regenerate.

## What this skill never does

- Summarize or paraphrase the source content (it's an archive, not a synthesis)
- Auto-suggest tags without showing the source text that drove them
- Write outside `safe-zones.md`-declared paths
- Re-clip the same URL within 30 days without asking
- Use Playwright as the primary path (Firecrawl is faster + cheaper; Playwright is fallback only)
