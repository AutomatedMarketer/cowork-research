# Phase 6 — First Research (Live-Fire)

## What this phase does

Picks a demo brief topic based on the user's business type (per the "Phase 6 demo" section in `personalization/<type>.md`). Shows the user a plan. Gets approval. Runs `/research-brief` with the demo topic. Confirms the output landed in the destination chosen in Phase 3.

This is the moment the user sees the wizard pay off — they go from "set up" to "shipped a real deliverable" in one phase.

## Ask

Two questions:

1. *"For your first research run, I'm going to do `[demo topic from personalization profile]`. That'll give you a real brief that's actually useful — not a throwaway test. Sound good? Or want to pick your own topic?"*
2. After showing the plan: *"Here's the plan: [brief outline]. Land in `[destination path]`. Approve?"*

If the user wants their own topic, ask: *"What's the topic?"* and use that instead.

## Why we ask

> *"The fastest way to know if this wizard worked is to ship a real brief. I picked a default topic that fits your business type — but if you've got something specific you've been meaning to research, this is a great excuse to do it. Either way, in 2-3 minutes you'll have a 600-word brief on your screen and saved to your destination."*

## Logic

### Step 1 — Read the personalization profile's demo

From `personalization/<business_type>.md`, pull the "Phase 6 demo (first research live-fire)" section. Examples:

- `coach.md`: *"Run `/research-brief` on a thought-leader the user cited in their `business-brain.md`, OR on the user's top competitor."*
- `agency-owner.md`: *"Run `/research-brief` on the user's top 3 competitors as a single comparative brief."*
- `creator.md`: *"Run `/research-brief` on a content trend the user mentioned in `business-brain.md`."*
- `course-creator.md`: *"Run `/research-brief` on a course in the same category as the user's, or on a competing methodology."*
- `solopreneur-smb.md`: *"Run `/research-brief` on a key supplier, partner, or market trend the user mentioned."*
- `sales-led-b2b.md`: *"Run `/research-brief` on a target ICP company the user named in `business-brain.md`."*

If the personalization profile doesn't have a Phase 6 demo, fall back to: *"a 600-word brief on the user's #1 competitor (extract from business-brain.md)."*

### Step 2 — Resolve the demo topic

Read `<workspace>/about-me/business-brain.md`. Extract a candidate topic per the demo guidance:
- For coach: scan for "thought leaders," "I admire," "my methodology compared to" — pull the first specific name
- For agency owner: scan for "competitors," "alternatives," "vs" — pull 3 competitor names
- For creator: scan for "trend," "topic," "niche," "vertical" — pull a topic phrase
- For course creator: scan for "course," "competitor," "category" — pull a course or category name
- For solopreneur/SMB: scan for "supplier," "partner," "market" — pull a name or topic
- For sales-led B2B: scan for "ICP," "target customer," "ideal client" — pull a company-shape description

Show the candidate to the user. Let them edit it or pick their own.

### Step 3 — Show the plan (plan-then-approve)

Build the plan dynamically from `research-preferences.md` (Phase 4 calibration) and `research-preferences.md` (Phase 3 destination):

```
Plan for first research:

  Topic:        [resolved topic]
  Length:       [brief_length_words] words (per Phase 4 calibration)
  TLDR style:   [tldr_style]
  Citations:    [citation_style]
  Destination:  [primary_destination_path]
  Sources:      Perplexity Ask + (Firecrawl if URL involved)

Estimated time: ~2-3 minutes.

Approve?
```

### Step 4 — Run /research-brief

On user approval, invoke `/research-brief` with:
- topic = resolved topic
- length = from research-preferences.md
- tldr_style = from research-preferences.md
- citation_style = from research-preferences.md
- destination = from research-preferences.md
- skill_invocation_mode = "phase 6 demo" (so /research-brief logs that this is the onboarding live-fire)

The `/research-brief` skill handles its own plan-then-approve internally; for Phase 6, the wizard's own approval at Step 3 acts as the umbrella approval — `/research-brief` may show a brief sub-plan before writing.

### Step 5 — Confirm landing

After `/research-brief` returns:
- Verify the output file exists at `[primary_destination_path]/briefs/<slug>.md`
- Show the user the path and the first 200 words of the brief
- Say: *"Brief shipped. You can read the full thing at `[path]`. If you didn't like it, tell me what to fix and we'll re-run."*

If the user wants a re-run with adjustments, loop back to Step 3 with edits.

### Step 6 — Append to research index + memory

The `/research-brief` skill should already append to `reference/research/_index.md` and `projects/research/memory.md`. Verify both appends happened. If either is missing, append manually:

- `_index.md`: `<ISO date> | brief | <topic-slug> | <path> | (Phase 6 demo)`
- `memory.md`: `<ISO timestamp> — Phase 6 demo: shipped first brief on <topic>`

## Write

- `<destination>/briefs/<slug>.md` — the actual brief (written by `/research-brief`)
- `<workspace>/reference/research/_index.md` — append (one line)
- `<workspace>/projects/research/memory.md` — append (one line)
- `_aibos/state-research.md` — append:
  - `phase_6_first_research: completed_at <ISO timestamp>`
  - `first_brief_topic: <topic>`
  - `first_brief_path: <path>`
  - `first_brief_word_count: <count>`

## Resume

After this phase completes, mark `phase_6_first_research` as `completed_at <ISO timestamp>` in state-research.md and set `next_pending_phase: 7`.

If the user re-ran Step 3 multiple times, that's fine — only mark the phase complete after the user confirms they're satisfied with the output.

## Verification before advancing

Phase 6 is complete when ALL of these are true:

- A brief file exists at `[primary_destination_path]/briefs/<slug>.md`
- The brief is non-empty (at least 200 words)
- `_index.md` and `memory.md` both have a fresh entry for this brief
- The user explicitly said the brief is good (no implicit "I guess that's fine")

If `/research-brief` failed (missing connector, network issue), surface the failure clearly and offer two paths: (a) install the missing connector and retry, (b) skip Phase 6 and revisit later (mark `phase_6_first_research: skipped`).
