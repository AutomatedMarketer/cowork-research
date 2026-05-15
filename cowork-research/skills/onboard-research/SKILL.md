---
name: onboard-research
slug: /onboard-research
version: 0.2.0
plugin: cowork-research
description: 7-phase install wizard for the cowork-research engine. Reads about-me/business-brain.md from cowork-ai-os, classifies into one of 6 business types, recommends top 3 research connectors per type (delegates to cowork-ai-os v0.10.2's /browse-connectors which live-fetches the directory), picks default destination (workspace / vault / Notion), calibrates research preferences, schedules cadence + 14-day calibration check. State.md resumable. Inspired by Karpathy's LLM Wiki framing and Corey Ganim's "Cowork as employee" pattern.
triggers:
  - /onboard-research
  - onboard research
  - set up research
  - install cowork-research
  - start research onboarding
  - begin research setup
---

# /onboard-research — v0.2.0

The setup wizard for cowork-research. 7 phases. ~12 minutes. Resumable.

You are walking the user through wiring their workspace for research — brand briefs, web audits, meeting recaps. By the end, the user has:

- A research engine tuned to their business type (1 of 6 profiles)
- Top 3 connectors recommended (live-fetched from Anthropic's MCP directory via cowork-ai-os v0.10.2)
- A primary destination chosen (workspace / vault / Notion)
- Calibrated preferences (brief length, TLDR style, citation style, audit checklist style, recap depth)
- `safe-zones.md` updated with research carve-outs
- A first research deliverable (live-fire demo) shipped to the destination
- Weekly + monthly cadence scheduled, plus a 14-day `/audit` calibration check

## Prereq check

Before Phase 0, run [`checks/prereq-cowork-ai-os.md`](checks/prereq-cowork-ai-os.md). If `about-me/business-brain.md` is missing, halt with the paste-ready prompt that tells the user how to install + onboard cowork-ai-os first.

## State management

Read [`templates/state-research.md.template`](templates/state-research.md.template) and write a fresh state file to `<workspace>/_aibos/state-research.md` if it doesn't exist. If it exists with `install_complete: false`, resume at `next_pending_phase`. If `install_complete: true`, ask the user if they want to redo a specific phase.

## Phase dispatch

Phases run in order, but each can be redone independently. After each phase, pause for user confirmation before advancing.

| # | Phase | File |
|---|---|---|
| 0 | Welcome + prereq check | [`phases/00-welcome.md`](phases/00-welcome.md) |
| 1 | Read business + classify | [`phases/01-classify-business.md`](phases/01-classify-business.md) |
| 2 | Recommend connectors (delegates to /browse-connectors live-fetch) | [`phases/02-recommend-connectors.md`](phases/02-recommend-connectors.md) |
| 3 | Pick destination | [`phases/03-pick-destination.md`](phases/03-pick-destination.md) |
| 4 | Calibrate preferences | [`phases/04-calibrate.md`](phases/04-calibrate.md) |
| 5 | Update safe-zones | [`phases/05-safe-zones.md`](phases/05-safe-zones.md) |
| 6 | First research live-fire | [`phases/06-first-research.md`](phases/06-first-research.md) |
| 7 | Cadence + calibration | [`phases/07-cadence-and-calibration.md`](phases/07-cadence-and-calibration.md) |

## Pause and resume

If the user types `pause onboarding`: save state. Tell them: *"Phase X complete. You're [N]% through. Resume any time with `/onboard-research`."*

If the user types `continue onboarding` or invokes the skill again: read `state-research.md`, jump to `next_pending_phase`.

## Phase completion protocol

After each phase's verification passes:
1. Update state file: mark phase as `completed`, set `next_pending_phase: <next>`, append timestamped log entry
2. Tell user: *"Phase N complete. You're [%] through. [One-sentence preview of next phase]. Type `continue onboarding` when ready."*

## After all phases complete

The full wrap-up sequence lives in [`phases/07-cadence-and-calibration.md`](phases/07-cadence-and-calibration.md) under "After Phase 7 — wizard wrap-up". The order is load-bearing — `install_complete: true` is the LAST write so a mid-wrap-up crash leaves state as "not complete" and the next invocation resumes the wrap-up. It runs (in order):

1. **Build the ⚡ NEXT MOVE block** — business-type-aware, picks one specific research action from `business-brain.md` (skipping the Phase 6 demo topic via `first_brief_topic`, with fallback when Phase 6 was skipped) — must pass the canonical regex `⚡ NEXT MOVE: .+ .+ .+\n   Why: .+`
2. **Append onboarding-complete log line** to `about-me/memory.md` (passive log, not a state flag)
3. **Show the final wrap-up message** — leads with the ⚡ NEXT MOVE, lists the **4 utility skills** (`/research-brief`, `/save-clip`, `/web-audit`, `/meeting-recap`), names the 14-day calibration date in plain English
4. **Self-improvement close** — ask "What would've made this onboarding 10% better?" → append to `projects/research/memory.md` → flag `/onboard-research` for revision if 3+ recurrence
5. **Mark `install_complete: true`** in `state-research.md` AS THE LAST ACTION

The 14-day calibration check itself is scheduled earlier in Phase 7 (cadence Step 4).

## Hard rules

- **Never re-collect identity** — read `about-me/` files; never overwrite
- **Append-only** on `about-me/connections.md` and `safe-zones.md`
- **Plan-then-approve** for every write outside `safe-zones.md`-declared paths
- **3rd–4th-grade reading level** for every prompt shown to the user (the wizard's voice — NOT the deliverables themselves)
- **Resumable** — every phase reads + writes `state-research.md`
- **Live-fetch over hardcoding** — Phase 2 delegates to `/browse-connectors` (cowork-ai-os v0.10.2+) so the connector list reflects Anthropic's directory today, not a snapshot from when this plugin shipped

## Voice

Plain English. Short sentences. One question at a time. Approval gates, not menus. Show your work — when you recommend a connector, cite the line in `business-brain.md` that drove the recommendation.

## What this skill never does

- Re-collect identity that already lives in `about-me/` (read-only on those files)
- Write outside paths declared in `safe-zones.md` without explicit approval
- Hardcode the connector recommendation list (delegates to live-fetch)
- Force a destination choice (workspace is always available; vault and Notion are offered only if detected)
- Skip the calibration check (the 14-day `/audit` re-run is non-optional — it's how we measure if the wizard actually helped)
