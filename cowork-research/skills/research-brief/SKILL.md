---
name: research-brief
slug: /research-brief
version: 0.1.0
plugin: cowork-research
description: Generate a 600-word executive brief + 5-bullet TLDR on any topic, person, company, or URL. Reads about-me/business-brain.md (for ICP/positioning context) + reference/_research-hot.md (for what user is currently researching). Uses Perplexity Ask + Firecrawl. Plan-then-approve writes. Lands in reference/research/briefs/<slug>.md. Optionally folds to vault or Notion based on research-preferences.md.
triggers:
  - /research-brief
  - research brief on
  - write a brief on
  - executive brief
  - brand brief
---

# /research-brief — v0.1.0

Generate a 600-word executive brief on any topic, person, company, or URL.

## Inputs

- **Required:** topic (free-form text) OR URL
- **Read on every run:**
  - `about-me/about-me.md` (user identity)
  - `about-me/business-brain.md` (ICP, positioning, terminology)
  - `reference/_research-hot.md` (what user is actively researching)
  - `reference/research/_index.md` (to dedup — has user already briefed this topic?)
  - `projects/research/research-preferences.md` (brief length, TLDR style, citation style)

## Logic

1. Read all input files
2. If topic already in `_index.md` (within last 30 days), surface that to user: "You briefed this on [date]. Want to refresh, or read the existing brief?"
3. Call Perplexity Ask for synthesis-style answer with citations
4. If URL provided, also call Firecrawl for the source page content
5. Generate brief using `templates/brief-template.md` shape
6. Plan-then-approve: show user the plan ("I'll write a 600-word brief covering X, Y, Z. Sources: A, B, C. Land in reference/research/briefs/<slug>.md. OK?")
7. On user approval, write the brief
8. Append one-line entry to `reference/research/_index.md`
9. Append one-line entry to `projects/research/memory.md`
10. If `research-preferences.md` has a fold-back destination, ask: "Fold this to <destination> too?" (default: no, ask each time in v0.1)

## Output

- `reference/research/briefs/<slug>.md` (the brief)
- `reference/research/sources/<source-slug>.md` (one per cited source — accessed-on dated)
- Index + memory appends

## Hard rules

- 3rd–4th-grade reading level in user-facing prompts (NOT in the brief itself — briefs are professional voice)
- Plan-then-approve before any write
- Never write outside `safe-zones.md`-declared paths
- Cite every source — no source = no claim

## Voice for the brief itself

Professional, executive-ready. NOT 3rd-grade — the brief is the user's deliverable, not the wizard's voice. Short paragraphs, clear structure, scannable. The TLDR comes first; the brief supports it.

## Self-improvement close (Foundation B)

After the brief is written, ask the user ONE question:

> "Did this brief land? What would have made it 10% better?"

- Append the user's answer as a one-line entry to `projects/research/memory.md` (append-only, never overwrite). Format: `<YYYY-MM-DD> /research-brief on <topic> — <user's one-line feedback>`
- Scan `projects/research/memory.md` for recurring complaints. If the same complaint shows up 3+ times (e.g., "TLDR too long" three runs in a row), append a flag line: `flag: research-brief skill — <pattern>, consider revising SKILL.md`
- Do NOT edit SKILL.md yourself. Surface the flag to the user; they decide if/when to revise.

## Actionable close (Foundation C)

End every run with this exact block (the `⚡ NEXT MOVE:` string is canonical — caps, leading lightning emoji, colon, space):

```
⚡ NEXT MOVE: <specific person/asset> <specific verb> <specific timing>
   Why: <one-sentence reason tied to the brief's TLDR>
```

The Next Move MUST be the single highest-value action this brief unlocks. Pick from:

| Brief type | Likely Next Move pattern |
|---|---|
| Brief on a person/prospect | "Send the <name> brief to <recipient> before <time> — it answers <specific question/objection>." |
| Brief on a company/competitor | "Drop the 5-bullet TLDR into <doc/deck/email> by <time> — it sharpens our positioning on <angle>." |
| Brief on a topic/trend | "Run `/research-brief` on <follow-up subtopic> next — this brief surfaced <specific gap> that needs depth." |
| Brief on a URL | "Re-read section <X> of the brief before <upcoming meeting/email> — that's the part the recipient cares about." |

✅ "⚡ NEXT MOVE: Send the Acme brief to John today before 5pm — it answers his pricing-objection question from Monday's call."
❌ "⚡ NEXT MOVE: Review the brief and decide what to do." (no subject, no timing — fails the rule)
