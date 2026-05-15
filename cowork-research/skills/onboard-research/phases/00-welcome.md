# Phase 0 — Welcome

## What this phase does

Greets the user. Sets expectations (7 phases, ~12 minutes, resumable). Runs the prereq check for cowork-ai-os. Scaffolds `_aibos/state-research.md` so every later phase can read + write it.

## Ask

Only one question at this phase: *"Ready to start? Type `let's go` to begin, or `pause onboarding` any time."*

If the prereq check fails, the only "ask" is the paste-ready install prompt from [`../checks/prereq-cowork-ai-os.md`](../checks/prereq-cowork-ai-os.md) — no other questions until the user comes back with cowork-ai-os onboarded.

## Why we ask

> *"Welcome to cowork-research — your research engine, wired to Cowork.*
>
> *By the end of this wizard you'll have brand briefs, web audits, and meeting recaps on tap. Each one is shaped to your business type, your customers, and the way you write. No generic templates.*
>
> *7 phases, about 12 minutes. Pause-friendly — type `pause onboarding` any time and I'll save your spot.*
>
> *Before we start, I need to check one thing: you have to have cowork-ai-os installed and onboarded first. That's where your `about-me/` files live. I'll check now."*

## Logic

### Step 1 — Run the prereq check

Execute [`../checks/prereq-cowork-ai-os.md`](../checks/prereq-cowork-ai-os.md):
- If `about-me/business-brain.md` is missing → halt with the paste-ready prompt. Do not advance.
- If `about-me/connections.md` is missing → halt with the partial-onboarding message.
- If `claude.md` is missing or not wired into Cowork's Global Instructions → soft warning, continue (default Y).
- If all checks pass → return OK and continue.

### Step 2 — Scaffold the state file

Read `_aibos/state-research.md`:

- **Doesn't exist** → create from [`../templates/state-research.md.template`](../templates/state-research.md.template). Set:
  - `started_at: <ISO timestamp>`
  - `plugin_version: 0.2.0`
  - `current_phase: 0`
  - `next_pending_phase: 1`
  - `install_complete: false`
  - `phase_0_welcome: completed_at <ISO timestamp>`
- **Exists, `install_complete: false`** → load it, jump to `next_pending_phase`. Skip the welcome script — say *"Resuming at Phase X — [one-line preview]."*
- **Exists, `install_complete: true`** → ask *"You finished onboarding on `<completed_at>`. Want to redo a specific phase (1-7), or run the 14-day calibration check?"* Branch on user response.

### Step 3 — Confirm and preview Phase 1

Tell the user:

> *"Prereq check passed. State file saved. You're 14% through.*
>
> *Phase 1 next — I'll read `about-me/business-brain.md` and figure out which of 6 business types you fit. Then I'll confirm with you before locking it in. ~2 minutes.*
>
> *Type `continue onboarding` when ready."*

## Write

Files created/touched in this phase:

- `_aibos/state-research.md` (created from template, with Phase 0 marked complete and `current_phase: 0` → `next_pending_phase: 1`)

No appends to `about-me/` files yet. No safe-zones changes yet.

## Resume

After this phase completes, mark `phase_0_welcome` as `completed_at <ISO timestamp>` in state-research.md and set `next_pending_phase: 1`.

## Verification before advancing

Phase 0 is complete when ALL of these are true:

- The prereq check returned OK (`about-me/business-brain.md` and `about-me/connections.md` both exist)
- `_aibos/state-research.md` exists with `current_phase: 0`, `next_pending_phase: 1`, and `phase_0_welcome` populated with a completion timestamp
- The user has typed `continue onboarding` (or equivalent)

If the prereq check failed, do NOT advance. Loop back when the user returns with cowork-ai-os onboarded.
