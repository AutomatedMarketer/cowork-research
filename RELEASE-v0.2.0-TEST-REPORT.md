# v0.2.0 Test Report — 2026-05-15

## Summary

- **Tests passing:** 20/20
- **Tests carried over from v0.1 (still applicable):** 15
- **New tests for v0.2:** 5 (T16–T20)
- **Static checks run:** 12 (grep / file-existence)
- **Inspection checks:** 8 (full-file reads to confirm canonical phrasing)
- **Final verdict:** GREEN — clear to push, tag, and release after explicit confirmation

---

## Test results

### Carried over from v0.1.0 (still passing post-v0.2 changes)

| Test | Type | Result | Notes |
|---|---|---|---|
| 1. Foundation B — `/research-brief` self-improve close | Inspection | PASS | Canonical question + append format unchanged. Skill version bumped to 0.2.0; foundation pattern intact. |
| 2. Foundation B — `/web-audit` self-improve close | Inspection | PASS | Unchanged from v0.1; version bumped only. |
| 3. Foundation B — `/meeting-recap` self-improve close | Inspection | PASS | Unchanged from v0.1; version bumped only. |
| 4. Foundation B — `/onboard-research` Phase 7 wrap-up self-improve close | Inspection | PASS | Wrap-up Step 4 unchanged; Step 3 message updated to list 4 skills (was 3). Self-improve close itself unchanged. |
| 5. Foundation C — `/research-brief` NEXT MOVE | Inspection | PASS | Unchanged from v0.1. |
| 6. Foundation C — `/web-audit` NEXT MOVE | Inspection | PASS | Unchanged from v0.1. |
| 7. Foundation C — `/meeting-recap` NEXT MOVE | Inspection | PASS | Unchanged from v0.1. |
| 8. Foundation C — `/onboard-research` Phase 7 NEXT MOVE | Inspection | PASS | Topic-extraction table unchanged; all 6 business types still represented; de-dup via `first_brief_topic` intact. |
| 9. Critical safety property — `install_complete: true` is LAST | Inspection | PASS | Wrap-up sequence in `phases/07-cadence-and-calibration.md` unchanged. Step 5 still the last write. |
| 10. Foundation A — lazy-load discipline | Static (grep) | PASS | New `/save-clip` SKILL.md has explicit "Read on every run (lazy — only when invoked)" section — no auto-load patterns added. |
| 11. Manifest + version consistency | Static (grep) | PASS | All 6 version mirrors = 0.2.0: plugin.json (line 3), marketplace.json (line 6), 5 SKILL.md frontmatter `version:` fields, CHANGELOG.md first entry. Templates and welcome phase plugin_version field also bumped to 0.2.0. ZERO matches for `^version: 0\.1\.0` in skills/. |
| 12. Build script excludes the right things | Static (inspection) | PASS | `build-release-zip.sh` unchanged — still excludes `.git/`, `node_modules/`, `docs/sops/*`. Now zips `skills/save-clip/` automatically (recursive include). |
| 13. 6 personalization profiles exist | Static (file existence) | PASS | All 6 files present and now each ends with the "Quick-capture habit (post-onboarding)" line for `/save-clip`. |
| 14. Connectors catalog | Static (file existence + grep) | PASS | Cross-cutting baseline has all 4 entries (Perplexity, Firecrawl, Fathom, Context7); skip-list intact; new top-of-file authentication call-out added. |
| 15. No SOP/course-IP files in plugin repo | Static (grep) | PASS | No new SOP-shaped content added in v0.2. Course-IP firewall intact. |

### New for v0.2.0

| Test | Type | Result | Notes |
|---|---|---|---|
| **16. `/save-clip` Foundation B (self-improve close)** | Inspection | PASS | `skills/save-clip/SKILL.md` line 145 contains the canonical question `"What would've made this 10% better?"`. Append format `<YYYY-MM-DD> \| /save-clip \| <answer verbatim>` to `projects/research/memory.md`. 60% substring overlap rule + same-keyword recurrence (keywords: tags, Firecrawl, Playwright, fallback, destination, frontmatter, dedup). Drafts to `projects/research/skill-improvements.md` with the same 6-column pipe table format used by the other 4 skills. |
| **17. `/save-clip` Foundation C (canonical NEXT MOVE)** | Inspection | PASS | `skills/save-clip/SKILL.md` line 172 contains the canonical block `⚡ NEXT MOVE: <Subject> <Verb> <Timing>` + `Why:` line (line 173). 4-row pattern table by clip type (lines 178–183). ✅/❌ examples (lines 187–188). Picking rule: external action (cite/brief/share) over internal re-read. Validation regex documented at line 192: `⚡ NEXT MOVE: .+ .+ .+\n   Why: .+`. |
| **18. Catalog Context7 verification command uses correct namespace** | Static (grep) | PASS | `connectors-research.md` line 56 uses `mcp__plugin_context7_context7__query-docs` (doubled prefix). ZERO matches for `mcp__plugin_context7__` (single prefix) anywhere in the catalog. |
| **19. Catalog Playwright verification command uses correct namespace** | Static (grep) | PASS | `connectors-research.md` line 84 uses `mcp__plugin_playwright_playwright__browser_navigate` (doubled prefix). ZERO matches for `mcp__plugin_playwright__` (single prefix) anywhere in the catalog. |
| **20. Wizard Phase 7 wrap-up lists all 4 utility skills** | Inspection | PASS | `phases/07-cadence-and-calibration.md` Step 3 (line 175–186) — wrap-up message lists `/research-brief`, `/save-clip`, `/web-audit`, `/meeting-recap` (4 skills, was 3 in v0.1). `/save-clip` is line 183. SKILL.md "After all phases complete" Step 3 description also mentions "4 utility skills". |

---

## Fixes applied during testing

None. All 20 tests passed on first run. Foundation work + version-bump + namespace-fix + skill-add changes in commits `d091813`, `d23a702`, `efb67ea`, `97a0eb9` are correct and verified.

---

## Live-Cowork tests pending (non-blocking for GitHub push)

These require Nuno to run them in a clean Cowork session post-install to confirm runtime behavior matches the static design:

| Test | How Nuno runs it live |
|---|---|
| TEST 16 live | Invoke `/save-clip <url>` end-to-end → answer the 10%-better question → verify `projects/research/memory.md` appends with the canonical format → run 3+ times with similar feedback to verify recurrence flag fires + `skill-improvements.md` row appears. |
| TEST 17 live | Confirm the final `/save-clip` output renders the `⚡ NEXT MOVE:` block with caps + lightning emoji + `Why:` line + clip-specific picking rule (external action over re-read). |
| TEST 18 live | In a fresh Cowork session: paste `mcp__plugin_context7_context7__query-docs` and confirm the tool resolves. Confirm the single-prefix `mcp__plugin_context7__query-docs` does NOT resolve. |
| TEST 19 live | Same pattern for Playwright: confirm `mcp__plugin_playwright_playwright__browser_navigate` resolves; single-prefix does not. |
| TEST 20 live | Run `/onboard-research` end-to-end and reach Phase 7 wrap-up — confirm the closing message lists all 4 utility skills (`/research-brief`, `/save-clip`, `/web-audit`, `/meeting-recap`). |
| TEST 1–15 re-runs | Re-validate v0.1 live tests post-upgrade: install v0.2 over v0.1, run `/onboard-research`, confirm all 4 v0.1 skills still produce canonical NEXT MOVE blocks and self-improve closes. |
| Auth-flow test | First-time use of Firecrawl in a fresh env should prompt for `FIRECRAWL_API_KEY` — confirm the catalog wording matches the real prompt. Same for Perplexity/Fathom/VidIQ/Notion/Drive. |
| `/save-clip` Firecrawl→Playwright fallback | Try `/save-clip` against a known-blocked page (e.g., a Cloudflare-protected site) — confirm the skill detects Firecrawl failure and falls back to Playwright with the user-facing heads-up message. |

---

## Conclusion

- **Static + inspection: 20/20 PASS**
- Dynamic in-Cowork verification: procedure documented above
- **Recommendation: GO for GitHub push, tag, and release** (after explicit Nuno confirmation)
