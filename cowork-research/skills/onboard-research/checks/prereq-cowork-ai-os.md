# Prereq check: cowork-ai-os

> Phase 0 runs this BEFORE proceeding.

## Step 1: Look for `about-me/business-brain.md`

```bash
ls "<workspace>/about-me/business-brain.md" 2>&1
```

If found → return OK, proceed to Phase 0 welcome.
If not found → halt with this message:

> "I need a file called `about-me/business-brain.md` to know about your business. That comes from cowork-ai-os. Run this first:
>
> `/plugin install cowork-ai-os@cowork-ai-os`
> `/onboard`
>
> When you're done, come back and run `/onboard-research` again."

## Step 2: Look for `about-me/connections.md`

If missing, the user partially onboarded cowork-ai-os. Halt with:

> "Your cowork-ai-os onboarding is incomplete (missing `connections.md`). Run `/onboard` to finish it, then come back."

## Step 3: Confirm Cowork's Global Instructions reference `claude.md`

Spot-check that `<workspace>/claude.md` exists and is referenced in Cowork's Global Instructions. If not, surface a soft warning:

> "Heads up: your handbook (`claude.md`) doesn't seem wired into Cowork's Global Instructions. cowork-ai-os usually does this in Phase 1. Continue anyway?" (Y/N — default Y, just a heads-up)

## All-clear

If Step 1 + 2 pass, return OK and proceed to Phase 0 welcome.
