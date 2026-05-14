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
