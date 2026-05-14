# Phase 4 — Calibrate Preferences

## What this phase does

Asks the user 5 short questions about how they want their research outputs to look and feel. Interpolates the answers into `projects/research/research-preferences.md` (so every research skill can read them) AND seeds `<workspace>/reference/_research-hot.md` (the tier-2 always-loaded cache) from the templates.

The 5 questions:

1. **Brief length** — short (300 words) / standard (600 words) / long (1200 words)
2. **TLDR style** — 3 bullets / 5 bullets / 1 paragraph
3. **Citation style** — inline links / footnote numbers / appendix-only
4. **Audit checklist style** — CRO-only / brand-only / both
5. **Recap depth** — executive (decisions + actions only) / detailed (with quotes) / verbatim (full timeline)

## Ask

Five questions, one at a time. Use the matching `personalization/<type>.md` to set sensible defaults so the user can just hit return:

> *"Question 1 of 5 — How long should briefs be by default?*
> *(a) short — 300 words*
> *(b) standard — 600 words ← recommended for [business_type]*
> *(c) long — 1200 words*
>
> *Default is (b). Type a, b, or c, or hit return to accept."*

Repeat for Q2–Q5. One question at a time. Approval after each.

## Why we ask

> *"These 5 answers shape every research output you'll get. A coach reading on their phone wants short + scannable. A sales-led B2B founder briefing a board wants long + footnoted. There's no right answer — only the right answer for you. You can change any of these later by editing `research-preferences.md`."*

## Logic

### Step 1 — Read the personalization profile defaults

From `personalization/<business_type>.md`, pull recommended defaults for each question if specified. Examples:

- `coach.md` defaults: brief=600, tldr=5-bullets, citation=inline, audit=brand-only, recap=executive
- `sales-led-b2b.md` defaults: brief=1200, tldr=3-bullets, citation=footnote, audit=both, recap=detailed
- `creator.md` defaults: brief=300, tldr=3-bullets, citation=inline, audit=brand-only, recap=executive

If the profile doesn't specify a default, use the universal default (b for length, 5 bullets for TLDR, inline for citations, both for audit, detailed for recap).

### Step 2 — Walk the 5 questions

For each question:
- Show the 3 options with the recommended default marked
- Wait for user input (a/b/c or return)
- If user picks something other than the default, log a note: *"Got it — [chosen option]. That's different from the default for [business_type], but that's fine."*
- Capture the answer

### Step 3 — Interpolate into research-preferences.md

Read `<workspace>/projects/research/research-preferences.md` (created in Phase 3 with destination fields). Append or update these fields:

```yaml
brief_length: <300|600|1200>
brief_length_words: <number>
tldr_style: <3-bullets|5-bullets|1-paragraph>
citation_style: <inline|footnote|appendix>
audit_checklist_style: <cro-only|brand-only|both>
recap_depth: <executive|detailed|verbatim>
calibrated_at: <ISO timestamp>
business_type: <slug>  # echo from state for self-containment
```

Don't clobber the destination fields written in Phase 3 — these are additive.

### Step 4 — Seed the hot cache

Write or update `<workspace>/reference/_research-hot.md` from [`../templates/research-hot.md.template`](../templates/research-hot.md.template). Interpolate:

- `<business_type>` → from state
- `<brief_length_words>` → from Phase 4 answer
- `<tldr_style>` → from Phase 4 answer
- `<citation_style>` → from Phase 4 answer
- `<primary_destination>` → from Phase 3
- Top 1-2 lines from the personalization profile's "Conversation tone" section
- A starter "Currently researching" section that's empty (user will fill in over time, or `/research-brief` will populate)

The hot cache is the tier-2 always-loaded memory file. Keep it under 1500 tokens — concise, high-signal.

## Write

- `<workspace>/projects/research/research-preferences.md` — update with the 5 calibration fields + `calibrated_at`
- `<workspace>/reference/_research-hot.md` — write fresh from template, interpolated
- `_aibos/state-research.md` — append:
  - `phase_4_calibrate: completed_at <ISO timestamp>`
  - `calibration_answers: {brief_length, tldr_style, citation_style, audit_checklist_style, recap_depth}`

## Resume

After this phase completes, mark `phase_4_calibrate` as `completed_at <ISO timestamp>` in state-research.md and set `next_pending_phase: 5`. The 5 calibration fields MUST all be populated in `research-preferences.md` before advancing — Phase 6 reads them when generating the live-fire demo.

## Verification before advancing

Phase 4 is complete when ALL of these are true:

- All 5 calibration fields are present in `research-preferences.md` with non-empty values
- `_research-hot.md` exists at `<workspace>/reference/_research-hot.md` and is under 1500 tokens
- `_research-hot.md` interpolation completed cleanly (no `<placeholder>` strings left in the file)
- `state-research.md` reflects the 5 answers in `calibration_answers`

If interpolation left placeholders (e.g., template variable not substituted), surface the gap and re-prompt the user for the missing field.
