# Phase 1 — Classify Business

## What this phase does

Reads `about-me/business-brain.md` (from cowork-ai-os) and classifies the user into 1 of 6 business types. Confirms the classification with the user. Loads the matching `personalization/<type>.md` profile so every later phase (especially Phase 2 connector recommendations and Phase 6 demo) can read it.

The 6 business types:

1. **Solo coach** — 1:1 or small-group coaching, transformation-focused, methodology-driven
2. **Agency owner** — services-for-hire, multi-client, team or freelancers
3. **Creator** — audience-first, content-driven, sponsorships / digital products
4. **Course creator** — productized education, cohort or self-paced, curriculum-driven
5. **Solopreneur / SMB** — small business with revenue, often product + service mix, lean team
6. **Sales-led B2B** — outbound or inbound pipeline, ICP-defined, contract-driven

## Ask

After Claude proposes the classification, ask one question:

> *"Based on your `business-brain.md`, you look like a **[business-type]**. That matches because [cite the line from business-brain.md that drove this — e.g., 'you described yourself as a coach who helps transformation-focused leaders'].*
>
> *Confirm? Type `yes` to lock it in, or tell me which of the 6 types fits better:*
>
> *1. Solo coach — 2. Agency owner — 3. Creator — 4. Course creator — 5. Solopreneur/SMB — 6. Sales-led B2B"*

## Why we ask

> *"Your business type drives everything that follows: which connectors I recommend, what your first research deliverable looks like, even how I word the brief templates. A coach researching their craft is different from an agency owner researching competitors. I want to get this right before we move on."*

## Logic

### Step 1 — Read business-brain.md

```
read <workspace>/about-me/business-brain.md
```

If the file is empty or has fewer than 100 characters, halt: *"Your `business-brain.md` looks empty or unfinished. Run `/onboard` from cowork-ai-os to fill it in, then come back."*

### Step 2 — Apply the classification heuristic

Look for these signals in the file, ranked by weight:

**Job title / self-description (highest weight):**
- "coach," "coaching," "1:1," "transformation," "client breakthrough" → **Solo coach**
- "agency," "we serve," "client roster," "team of," "freelancers," "fractional" → **Agency owner**
- "creator," "audience," "subscribers," "followers," "newsletter," "content" → **Creator**
- "course," "cohort," "curriculum," "students," "lesson," "module" → **Course creator**
- "founder," "small business," "shop," "product line," "team of 2-10" → **Solopreneur / SMB**
- "ICP," "outbound," "inbound," "pipeline," "deal cycle," "AE," "SDR," "MQL" → **Sales-led B2B**

**Revenue stage / ICP description (medium weight):**
- 1:1 high-ticket service → coach or agency
- Subscription / digital product / sponsor revenue → creator or course creator
- Multi-product or wholesale → solopreneur/SMB
- Enterprise contracts → sales-led B2B

**Tiebreaker:** If two types tie, ask the user. Don't guess.

### Step 3 — Propose to user with citation

Show the user:
- The classification result
- The 1-2 lines from `business-brain.md` that drove it
- The numbered menu so they can correct it

### Step 4 — Lock it in

On user confirmation:
- Write `business_type: <slug>` to `_aibos/state-research.md` (e.g., `business_type: coach`)
- Load the matching profile: `personalization/<slug>.md` (e.g., `personalization/coach.md`)
- Cache the profile contents in working memory for Phases 2, 4, 6 to reference

The 6 slugs are: `coach`, `agency-owner`, `creator`, `course-creator`, `solopreneur-smb`, `sales-led-b2b`.

## Write

Files touched:

- `_aibos/state-research.md` — append `business_type: <slug>` and `phase_1_classify: completed_at <ISO timestamp>`

No writes to `about-me/` files. No safe-zones changes.

## Resume

After this phase completes, mark `phase_1_classify` as `completed_at <ISO timestamp>` in state-research.md and set `next_pending_phase: 2`. The `business_type` field MUST be populated before advancing — Phase 2 reads it.

## Verification before advancing

Phase 1 is complete when ALL of these are true:

- `business_type` is set in `state-research.md` to one of the 6 valid slugs
- The matching `personalization/<slug>.md` file exists and was successfully loaded
- The user explicitly confirmed the classification (`yes` or picked a number)

If the user keeps changing their mind, that's a signal cowork-ai-os onboarding was rushed. Recommend: *"It might be worth re-running `/onboard` to sharpen `business-brain.md` first — but if you want, we can pick a best-fit and move on."*
