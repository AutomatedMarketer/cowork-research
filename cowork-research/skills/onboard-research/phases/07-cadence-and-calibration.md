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

This is the final phase. After verification:

1. Mark `install_complete: true` in `state-research.md`
2. Append to `<workspace>/about-me/memory.md`: `<ISO date>: cowork-research v0.1.0 onboarded for <business-type>`
3. Tell the user (in voice):

> *"Wizard done. You're set up.*
>
> *What you can do now:*
> *- `/research-brief <topic>` — generate a brief on anything*
> *- `/web-audit <url>` — CRO + competitive audit of any page*
> *- `/meeting-recap <fathom-url>` — pull decisions, actions, and quotes from a Fathom call*
>
> *Calibration check is locked in for `[date]`. Come back then and we'll see how the 4 Cs moved."*
