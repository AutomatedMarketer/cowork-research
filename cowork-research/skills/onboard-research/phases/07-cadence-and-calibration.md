# Phase 7 — Cadence + Calibration

## What this phase does

Sets up the long-term rhythm so cowork-research stays useful past day 1:

1. **Weekly competitive scan** — default Saturday 8am — re-runs `/web-audit` on the user's top 1-3 competitor URLs and surfaces any diff
2. **Monthly research review** — first Sunday of each month — walks the `reference/research/_index.md` from the past 30 days, highlights what got used vs. what got ignored
3. **14-day calibration check** — re-runs cowork-ai-os's `/audit` skill 14 days from today to measure whether the 4 Cs score moved; surfaces what the wizard should tune in v0.2

Each of these is captured in `state-research.md` with a date, so the user can re-trigger later.

## Ask

Three questions, one per cadence:

1. *"Schedule a weekly competitive scan? Default is Saturday 8am — I'll re-run `/web-audit` on your top 3 competitor URLs and email you (or post to your destination) what changed. Yes / change time / no."*
2. *"Schedule a monthly research review? First Sunday of each month — I'll walk the past 30 days of research and flag what you used vs. what you ignored. Yes / change time / no."*
3. *"Schedule the 14-day calibration check? This is non-optional in v0.1 — it's how we measure if this wizard actually helped. The check runs `/audit` (cowork-ai-os) on `[date 14 days from today]` and shows your 4 Cs score change."*

Q3 has no opt-out in v0.1 — explain why if the user pushes back: *"It's the only way to know if cowork-research is doing its job. If after 14 days nothing improved, we know the wizard needs tuning. Trust the loop."*

## Why we ask

> *"Day 1 setup is the easy part. The real value of cowork-research shows up over weeks and months — your competitive scan catches changes you'd miss, your monthly review tells you what's actually useful, and the 14-day check makes sure I'm earning my keep.*
>
> *Three short questions. Defaults are sensible — most people just hit yes."*

## Logic

### Step 1 — Resolve top competitor URLs (for weekly scan)

Read `<workspace>/about-me/business-brain.md`. Look for explicit competitor URLs. If found, list the top 3. If not found, ask: *"For the weekly scan I need 1-3 competitor URLs. What are they?"*

If the user can't name any, defer the weekly scan: *"Skipping weekly scan for now. You can re-trigger this later by running `/onboard-research redo phase 7` once you've identified competitors."*

### Step 2 — Schedule the weekly scan

If yes: write to `_aibos/state-research.md`:
```yaml
weekly_competitive_scan:
  enabled: true
  cron: "0 8 * * 6"   # Saturday 8am local
  competitor_urls: [<url-1>, <url-2>, <url-3>]
  next_run: <ISO date for next Saturday>
  output_destination: <primary_destination from Phase 3>
```

If user wanted a different time: parse the time + day they specified, convert to cron, write that.

If no: write `weekly_competitive_scan: { enabled: false }`.

### Step 3 — Schedule the monthly review

If yes: write:
```yaml
monthly_research_review:
  enabled: true
  cron: "0 9 1-7 * 0"   # 9am on the first Sunday of the month
  next_run: <ISO date for next first-Sunday>
  output_destination: <primary_destination from Phase 3>
```

If no: write `monthly_research_review: { enabled: false }`.

### Step 4 — Schedule the 14-day calibration check (mandatory)

Compute the date: `today + 14 days`. Write:
```yaml
calibration_check_14_day:
  enabled: true
  scheduled_date: <ISO date>
  audit_skill: cowork-ai-os /audit
  baseline_4cs_score: <pull from state if available, else "unknown — first audit will set baseline">
  output_destination: <primary_destination from Phase 3>
```

Tell the user the exact date in plain English: *"I've scheduled the 14-day calibration check for `[Tuesday, May 28, 2026]`. On that day, run `/audit` from cowork-ai-os (or just type `continue calibration` and I'll trigger it). It'll compare your 4 Cs score now vs. then, and we'll see what cowork-research actually moved."*

### Step 5 — Append cadence summary to memory + connections

Append to `<workspace>/projects/research/memory.md`:

```markdown
## <ISO timestamp> — Phase 7 complete: cadence scheduled
- Weekly competitive scan: <enabled / disabled>, runs <day + time>
- Monthly research review: <enabled / disabled>, runs first Sunday
- 14-day calibration check: scheduled for <date>
```

Also append to `<workspace>/about-me/connections.md`:

```markdown
## <ISO timestamp> — added by cowork-research /onboard-research Phase 7
- Cadence scheduled: weekly_scan=<bool>, monthly_review=<bool>, 14_day_calibration=<date>
```

## Write

- `_aibos/state-research.md` — append the 3 cadence blocks (weekly_competitive_scan, monthly_research_review, calibration_check_14_day) AND mark `phase_7_cadence: completed_at <ISO timestamp>`
- `<workspace>/projects/research/memory.md` — append cadence summary
- `<workspace>/about-me/connections.md` — append (append-only, never overwrite)

## Resume

After this phase completes, mark `phase_7_cadence` as `completed_at <ISO timestamp>` in state-research.md, set `install_complete: true`, and write `completed_at: <ISO timestamp>` at the top of state-research.md.

## Verification before advancing

Phase 7 is complete when ALL of these are true:

- The 14-day calibration check is scheduled with a concrete `scheduled_date` (mandatory — non-optional)
- The weekly + monthly cadence are EITHER scheduled with valid cron + URLs OR explicitly marked `enabled: false`
- `memory.md` and `connections.md` both have the Phase 7 append
- `state-research.md` reflects all 3 cadence blocks

## After Phase 7 — wizard wrap-up

This is the final phase. Run the wrap-up in this exact order. **Do not re-shuffle.** The order is load-bearing: `install_complete: true` is the LAST action so a crash anywhere mid-wrap-up correctly leaves state as "not complete" and the next `/onboard-research` invocation resumes the wrap-up.

### Step 1 — Build the ⚡ NEXT MOVE block (Foundation C — business-type-aware)

Build the block now (don't display yet — Step 3 displays it). Pick the single highest-leverage research action the user should run NEXT, based on their `business_type` (set in Phase 1) and the specifics in `<workspace>/about-me/business-brain.md`.

**Topic-extraction logic by business type** (mirrors Phase 6 demo logic, but picks a NEW topic — not the one we just used in the demo):

| business_type | Scan business-brain.md for | Pick | Timing | Why-line anchor |
|---|---|---|---|---|
| `coach` | thought-leaders, methodologies admired, upcoming workshop/cohort/launch | thought-leader name | "tomorrow morning" | upcoming workshop / cohort / launch |
| `agency-owner` | prospect URLs, top competitors, named pitch targets | prospect URL or top competitor | "tomorrow before your sales call" | CRO weaknesses to lead with in pitch |
| `creator` | trends, content topics, niche themes | trend topic | "today" | next video script foundation |
| `course-creator` | competing courses, methodologies in same category | competing course | "this week" | next course chapter outline |
| `solopreneur-smb` | suppliers, partners, market trends | key supplier or partner | "this week" | leverage point in next negotiation |
| `sales-led-b2b` | target ICP companies, named accounts | target ICP company | "tomorrow before your first outreach" | letting you open with their priorities, not your script |

**Picking rule (avoid duplicating the Phase 6 demo):**
- If the topic you'd pick matches `first_brief_topic` in `state-research.md`, pick the SECOND-best candidate from business-brain.md instead
- If `first_brief_topic` is absent from `state-research.md` (e.g., Phase 6 was skipped), treat the de-duplicate check as passing and pick the top candidate
- If business-brain.md only surfaces one candidate, point the user to the next utility skill that fits their business type (e.g., `/web-audit` for agency-owner if no second prospect URL)

**Format the block exactly like this** (canonical — caps, leading lightning emoji, colon, space):

```
⚡ NEXT MOVE: <Subject> <Verb> <Timing>
   Why: <one-sentence reason tied to user's stated goal/ICP>
```

**Examples by business type:**

- ✅ coach: `⚡ NEXT MOVE: Run /research-brief on Brené Brown tomorrow morning. Why: That's the brief that'll most directly inform your June vulnerability cohort.`
- ✅ agency-owner: `⚡ NEXT MOVE: Run /web-audit on acme-corp.com tomorrow before your sales call. Why: It surfaces 3 CRO weaknesses you can lead with in your pitch.`
- ✅ creator: `⚡ NEXT MOVE: Run /research-brief on the AI-agents trend today. Why: The brief becomes your next video script foundation.`
- ✅ course-creator: `⚡ NEXT MOVE: Run /research-brief on Hormozi's $100M Offers course this week. Why: It gates your next course chapter outline.`
- ✅ solopreneur-smb: `⚡ NEXT MOVE: Run /research-brief on Alibaba supplier QingFeng this week. Why: Names the leverage point in your next negotiation.`
- ✅ sales-led-b2b: `⚡ NEXT MOVE: Run /research-brief on Stripe tomorrow before your first outreach. Why: Lets you open with their actual priorities, not your script.`
- ❌ `⚡ NEXT MOVE: Try the other skills.` (no subject, no timing, no specificity — REJECT)

**Validation pattern (do not skip):** The block MUST match:
`⚡ NEXT MOVE: .+ .+ .+\n   Why: .+`

If it doesn't match, regenerate the block before advancing to Step 2.

### Step 2 — Append onboarding-complete log line

Append to `<workspace>/about-me/memory.md`:
```
<ISO date>: cowork-research v0.1.0 onboarded for <business-type>
```

This is a passive log entry, not a state flag — safe to write before the user sees the wrap-up.

### Step 3 — Show the final wrap-up message

Lead with the ⚡ NEXT MOVE block from Step 1, then the rest:

> *"Wizard done. You're set up.*
>
> *⚡ NEXT MOVE: [Subject Verb Timing from Step 1]*
> *   Why: [why-line from Step 1]*
>
> *Other skills you can use now:*
> *- `/research-brief <topic>` — generate a brief on anything*
> *- `/save-clip <url>` — clip any article into your research library*
> *- `/web-audit <url>` — CRO + competitive audit of any page*
> *- `/meeting-recap <fathom-url>` — pull decisions, actions, and quotes from a Fathom call*
>
> *Calibration check is locked in for `[date]`. Come back then and we'll see if your research is actually working."*

### Step 4 — Self-improvement close (Foundation B — wizard variant)

The wizard runs once per onboarding, but the self-improve loop still fires once at wrap-up so we learn what the wizard routinely fails at across runs. This fires AFTER the user has seen the wrap-up + NEXT MOVE, matching the gold-standard sequence ("after delivering main output + Next Move block, ask").

Ask the user this exact question (one line, plain English):

> *"What would've made this onboarding 10% better?"*

Accept a one-line answer. Then:

1. Append to `<workspace>/projects/research/memory.md`:
   ```
   <YYYY-MM-DD> | /onboard-research | <answer verbatim>
   ```

2. Read `memory.md` and check if any pattern recurs 3+ times for `/onboard-research`. Pattern matching:
   - Substring overlap >= 60% with prior entries
   - Same keyword (e.g., "Phase 2", "connector", "destination", "calibration", "demo", "too long")

3. If recurrence detected:
   - Surface: *"I've seen this 3+ times. Want me to update `/onboard-research` itself?"*
   - If yes → draft change to `<workspace>/projects/research/skill-improvements.md` in this format:
     ```
     | /onboard-research | <pattern> | <first_seen_date> | <recurrence_count> | <suggested_change> | <reviewed: no> |
     ```

4. If no recurrence → silent. No noise.

### Step 5 — Mark install_complete (LAST action)

This MUST be the final write. If anything above crashes, state correctly reflects "not complete" and the next `/onboard-research` invocation will resume the wrap-up.

- Mark `install_complete: true` in `state-research.md`
- Confirm `completed_at: <ISO timestamp>` is written at the top of `state-research.md` (canonical write point — see Resume section above)
