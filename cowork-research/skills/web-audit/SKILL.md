---
name: web-audit
slug: /web-audit
version: 0.1.0
plugin: cowork-research
description: CRO + competitive audit of any URL. Bulleted recommendations against the web-audit-checklist.md heuristics. Reads about-me/business-brain.md (for ICP context). Uses Firecrawl + Playwright (for login-walled pages). Read-only on the web — never submits forms or clicks destructive actions. Lands in reference/research/audits/<domain>-<date>.md.
triggers:
  - /web-audit
  - audit this page
  - cro audit
  - competitive audit
  - audit url
---

# /web-audit — v0.1.0

CRO + competitive audit of any URL. Bulleted recommendations.

## Inputs

- **Required:** URL
- **Read on every run:**
  - `about-me/business-brain.md` (for ICP context — audits should reflect THE USER's customer, not generic best practices)
  - `templates/web-audit-checklist.md` (the heuristics — user can edit)
  - `projects/research/research-preferences.md` (audit style: cro-only / brand-only / both)

## Logic

1. Read input files
2. Fetch the URL via Firecrawl. If Firecrawl reports "blocked / login-walled," fall back to Playwright (with user approval — Playwright requires a browser session)
3. Walk the checklist section by section. For each item, return PASS / FAIL / N/A with a 1-sentence reason.
4. Group failures by severity (critical / important / minor)
5. Plan-then-approve: show user the plan ("I'll audit <url> against [checklist sections X, Y, Z]. Output: bulleted recommendations grouped by severity. Land in reference/research/audits/<domain>-<date>.md. OK?")
6. On user approval, write the audit
7. Append one-line entry to `reference/research/_index.md`
8. Append one-line entry to `projects/research/memory.md`

## Output

- `reference/research/audits/<domain>-<date>.md` (the audit, structured as bulleted list)

## Hard rules

- READ-ONLY on the web — never submit forms, never click destructive actions
- Playwright session NEVER persists credentials
- Plan-then-approve before any write
- Cite the URL accessed-on date in the output footer

## Voice for the audit itself

Direct, actionable, scannable. Each recommendation is one bullet. No essays. The user wants to know what to fix and why, fast.

## Self-improvement close (Foundation B)

After the audit is written, ask the user ONE question:

> "Did this audit land? What would have made it 10% better?"

- Append the user's answer as a one-line entry to `projects/research/memory.md` (append-only, never overwrite). Format: `<YYYY-MM-DD> /web-audit on <domain> — <user's one-line feedback>`
- Scan `projects/research/memory.md` for recurring complaints. If the same complaint shows up 3+ times (e.g., "too many minor-severity items, hide them" three runs in a row), append a flag line: `flag: web-audit skill — <pattern>, consider revising SKILL.md`
- Do NOT edit SKILL.md yourself. Surface the flag to the user; they decide if/when to revise.

## Actionable close (Foundation C)

End every run with this exact block (the `⚡ NEXT MOVE:` string is canonical — caps, leading lightning emoji, colon, space):

```
⚡ NEXT MOVE: <single highest-leverage CRO fix> <ship by when>
   Why: <one-sentence reason — usually severity + expected lift>
```

The Next Move MUST be the SINGLE highest-leverage fix from the audit — not a list. Picking rule:

1. If any **critical** failures exist → pick the one with the highest CRO impact (usually a hero/CTA/proof issue)
2. If no critical, pick the **important** fix that touches the most pageviews (usually above-the-fold or primary CTA)
3. Never recommend "minor" items as the Next Move — they go in the audit body, not here

| Common audit findings | Next Move pattern |
|---|---|
| Hero copy is generic / no clear value prop | "Rewrite the hero headline before <date> — current copy doesn't name the ICP or the outcome." |
| Single CTA is buried / weak | "Move the primary CTA above the fold today — it's the highest-leverage 30-min fix on the page." |
| No social proof above the fold | "Add a 1-line proof bar (logos or stat) under the hero by end of week — biggest credibility gap." |
| Form has too many fields | "Cut form fields from <N> to <M> this week — drop everything not strictly required for the next step." |

✅ "⚡ NEXT MOVE: Rewrite the hero headline on acme.com before Friday — current copy doesn't name the ICP or the outcome, costing the most pageviews of any single fix."
❌ "⚡ NEXT MOVE: Address the critical findings from the audit." (no specific fix, no timing — fails the rule)
