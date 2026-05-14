# Phase 5 — Update Safe Zones

## What this phase does

Appends research-specific paths to the user's `safe-zones.md` (from cowork-ai-os) so the research skills can read + write where they need to without a permission prompt every time. Sets explicit permission defaults: reads = act, writes = ask, destructive = blocked.

The 3 paths added (last one only if vault destination chosen):

1. `reference/research/` — where briefs, audits, recaps land in workspace mode
2. `projects/research/` — where research-preferences.md, memory.md, indexes live
3. `<vault>/<area>/wiki/sources/research/` — only if Phase 3 picked vault as primary or fold-back

## Ask

One question, framed as a confirmation rather than open-ended:

> *"I'm going to add 3 paths to your `safe-zones.md` so research skills can work without asking permission every time:*
>
> *  - `reference/research/` (where outputs land)*
> *  - `projects/research/` (where preferences + memory live)*
> *  - `<vault>/<area>/wiki/sources/research/` (only if you chose vault as a destination — skipping otherwise)*
>
> *Permissions:*
> *  - Reads: act (no prompt — the research skills always read your preferences and prior outputs)*
> *  - Writes: ask (you approve every brief/audit/recap before it lands)*
> *  - Destructive (delete/overwrite): blocked (never — research is append-only by nature)*
>
> *Type `yes` to apply, or `show me the diff` to see exactly what I'll add."*

## Why we ask

> *"Safe-zones is your master rulebook for what Cowork can touch on its own. I want to add the research paths so the workflow is smooth — but I never want to surprise you. Reads happen silently because they're harmless. Writes always ask because outputs are your work product. Destructive is off because research builds, it doesn't tear down."*

## Logic

### Step 1 — Locate safe-zones.md

```
read <workspace>/projects/file-organization/safe-zones.md
```

If the file doesn't exist (cowork-ai-os onboarding skipped the file-organization step), surface a soft warning: *"`safe-zones.md` not found. cowork-ai-os usually creates it. I'll create a minimal one with just the research paths so we can proceed — but consider running `/onboard-file-organization` from cowork-ai-os later for the full setup."*

In that case: create a minimal `safe-zones.md` with a header noting it was started by cowork-research, then proceed with the appends.

### Step 2 — Build the append block

```markdown
## <ISO timestamp> — added by cowork-research /onboard-research Phase 5

### Research paths (cowork-research v0.1.0)

- path: reference/research/
  reads: act
  writes: ask
  destructive: blocked
  scoped_to: cowork-research skills (research-brief, web-audit, meeting-recap)

- path: projects/research/
  reads: act
  writes: ask
  destructive: blocked
  scoped_to: cowork-research skills

# only included if vault destination chosen in Phase 3
- path: <absolute-vault-path>/<area>/wiki/sources/research/
  reads: act
  writes: ask
  destructive: blocked
  scoped_to: cowork-research skills (folded outputs only)
```

If Phase 3's `primary_destination` is `vault` OR `fold_back_destination` is `vault`, include the vault block. Otherwise omit it.

### Step 3 — Show the diff

Show the user exactly what will be appended to `safe-zones.md` (the block above, with `<placeholders>` filled in).

If the user says `show me the diff`, show it before asking for `yes`. If the user types `yes` directly, append straight away.

### Step 4 — Append (never overwrite)

Append the block to the END of `safe-zones.md`. Do NOT modify any existing entries. If a research-specific path already exists in the file from a prior run, don't duplicate — instead, log: *"`reference/research/` is already in safe-zones — leaving it as-is."*

### Step 5 — Verify the append landed

Re-read the last ~30 lines of `safe-zones.md`. Confirm the new block is present with the correct paths and permission settings.

## Write

- `<workspace>/projects/file-organization/safe-zones.md` — append the research-paths block (created if missing)
- `_aibos/state-research.md` — append:
  - `phase_5_safe_zones: completed_at <ISO timestamp>`
  - `safe_zones_paths_added: [reference/research/, projects/research/, optionally <vault-path>]`
  - `safe_zones_was_pre_existing: <true|false>` (true if file existed before this phase)

## Resume

After this phase completes, mark `phase_5_safe_zones` as `completed_at <ISO timestamp>` in state-research.md and set `next_pending_phase: 6`.

## Verification before advancing

Phase 5 is complete when ALL of these are true:

- `safe-zones.md` exists at `<workspace>/projects/file-organization/safe-zones.md`
- The append block from this phase is present in the file (verified by re-read)
- Permissions for all 3 (or 2) paths are set to `reads: act, writes: ask, destructive: blocked` — no other combinations allowed
- `state-research.md` lists the paths added

If safe-zones.md was created from scratch (no cowork-ai-os file-organization onboarding), surface a one-line note: *"Heads up — I created a minimal safe-zones.md. For the full file-organization setup, run `/onboard-file-organization` from cowork-ai-os later."*
