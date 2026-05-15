# v0.1.0 Test Report — 2026-05-14

## Summary

- **Tests passing:** 15/15
- **Static checks run:** 7 (Tests 1–4 grep-verified, Tests 10/11/12/15 grep-verified)
- **Inspection checks:** 8 (Tests 5–9, 13, 14, plus full-file reads on T1–T4 to confirm canonical phrasing)
- **Final verdict:** GREEN — clear to push to GitHub after explicit confirmation

---

## Test results

| Test | Type | Result | Notes |
|---|---|---|---|
| 1. Foundation B — `/research-brief` self-improve close | Inspection | PASS | Canonical question `"What would've made this 10% better?"` present (line 63). Append format `<YYYY-MM-DD> \| /research-brief \| <answer verbatim>` to `projects/research/memory.md`. 60% substring overlap rule + same-keyword recurrence. Drafts to `projects/research/skill-improvements.md` with 6-column pipe table. |
| 2. Foundation B — `/web-audit` self-improve close | Inspection | PASS | Canonical question present (line 57). Append format `<YYYY-MM-DD> \| /web-audit \| <answer verbatim>`. 60% rule + skill-improvements.md staging identical to T1. Skill-specific keywords listed (severity, checklist, Firecrawl, hero, CTA). |
| 3. Foundation B — `/meeting-recap` self-improve close | Inspection | PASS | Canonical question present (line 64). Append format `<YYYY-MM-DD> \| /meeting-recap \| <answer verbatim>`. 60% rule + skill-improvements.md staging present. Skill-specific keywords listed (quotes, owners, Fathom, deadlines, decisions). |
| 4. Foundation B — `/onboard-research` Phase 7 wrap-up self-improve close | Inspection | PASS | Wizard variant question `"What would've made this onboarding 10% better?"` (line 194). Append format identical: `<YYYY-MM-DD> \| /onboard-research \| <answer verbatim>` to `<workspace>/projects/research/memory.md`. 60% overlap + skill-improvements.md staging. Step 4 fires AFTER user sees wrap-up + NEXT MOVE — matches gold-standard sequence. |
| 5. Foundation C — `/research-brief` NEXT MOVE | Inspection | PASS | Canonical `⚡ NEXT MOVE: <Subject> <Verb> <Timing>` block (line 90) + `Why:` line. 4-row pattern table by brief type. ✅/❌ examples. Validation regex: `⚡ NEXT MOVE: .+ .+ .+\n   Why: .+` |
| 6. Foundation C — `/web-audit` NEXT MOVE | Inspection | PASS | Canonical block (line 84) + `Why:` line. Critical-first picking rule (3 priorities). 4-row pattern table by audit finding. ✅/❌ examples. Same validation regex. Single highest-leverage fix only — never minor items. |
| 7. Foundation C — `/meeting-recap` NEXT MOVE | Inspection | PASS | Canonical block (line 91) + `Why:` line. 4-priority picking rule (user as owner > user chases other > decision-needs-step > open-question). 4-row pattern table by action-item type. ✅/❌ examples. Same validation regex. |
| 8. Foundation C — `/onboard-research` Phase 7 NEXT MOVE | Inspection | PASS | Canonical block format (line 144) + `Why:` line. Validation regex documented (line 159). ALL 6 business types present in topic-extraction table (lines 129–134): coach, agency-owner, creator, course-creator, solopreneur-smb, sales-led-b2b. ✅ examples for all 6 (lines 150–155). De-dup rule prevents Phase 6 demo collision. |
| 9. Critical safety property — `install_complete: true` is LAST | Inspection | PASS | `phases/07-cadence-and-calibration.md` documents the wrap-up order on line 119: "The order is load-bearing: `install_complete: true` is the LAST action so a crash anywhere mid-wrap-up correctly leaves state as 'not complete'." Steps execute in order: Step 1 (build NEXT MOVE) → Step 2 (memory.md log line) → Step 3 (show wrap-up + NEXT MOVE) → Step 4 (self-improve) → Step 5 (mark install_complete LAST, line 216–222). Crash-safe by design. |
| 10. Foundation A — lazy-load discipline | Static (grep) | PASS | `grep -i "always.{0,5}load\|auto.{0,5}load\|preload"` against `cowork-research/` returns 3 matches, ALL of which are documentation/runtime references (not plugin context auto-load): (a) `docs/architecture.md` line 24/26 explains why we DON'T always-load research library; (b) `phases/04-calibrate.md` line 5/81 references the user-side `_research-hot.md` tier-2 cache (a workspace memory file, not plugin context). The 4 SKILL.md files use scoped "Read on every run" sections only — read on invocation, not always-on. No `auto-load` / `preload` patterns anywhere. |
| 11. Manifest + version consistency | Static (grep) | PASS | Verified all 6 version strings = `0.1.0`: `cowork-research/.claude-plugin/plugin.json` (line 3) ✓, `.claude-plugin/marketplace.json` root (line 6) ✓, `skills/research-brief/SKILL.md` frontmatter (line 4) ✓, `skills/web-audit/SKILL.md` frontmatter (line 4) ✓, `skills/meeting-recap/SKILL.md` frontmatter (line 4) ✓, `skills/onboard-research/SKILL.md` frontmatter ✓, `CHANGELOG.md` first entry (line 10) ✓, `RELEASE-v0.1.0.md` filename + title ✓. |
| 12. Build script excludes the right things | Static (inspection) | PASS | `build-release-zip.sh` zips from inside `cowork-research/` (PLUGIN_DIR, line 7). Explicit excludes (lines 31–37): `.DS_Store`, `._*`, `*.swp`, `.git/*`, `node_modules/*`, `docs/sops/*`, `docs/sops`. The `release/` folder is OUTSIDE `PLUGIN_DIR` — naturally excluded by the `cd "${PLUGIN_DIR}"` scope. The `docs/` folder contains only `architecture.md` (legit ship-able doc) — no SOPs to worry about; defensive `docs/sops/*` exclude catches accidents. No rebuild required — script structure is correct. |
| 13. 6 personalization profiles exist | Static (file existence) | PASS | All 6 files present at `cowork-research/skills/onboard-research/personalization/`: `coach.md`, `agency-owner.md`, `creator.md`, `course-creator.md`, `solopreneur-smb.md`, `sales-led-b2b.md`. Matches the 6 business types in T8 topic-extraction table — no drift. |
| 14. Connectors catalog | Static (file existence + grep) | PASS | `cowork-research/skills/onboard-research/catalogs/connectors-research.md` exists. Cross-cutting baseline section (line 7) contains all 4 required entries: Perplexity Ask (line 9), Firecrawl (line 22), Fathom (line 35), Context7 (line 48). Skip-list section present at line 117 ("Skip-list (research-relevant MCPs we deliberately don't recommend in v0.1)"). Mirrors cowork-ai-os v0.10 schema verbatim. |
| 15. No SOP/course-IP files in plugin repo | Static (grep) | PASS | `grep "lesson:|## Section 1 — What this lesson is about|reading_level: 3rd-4th grade"` against `cowork-research/` — ZERO matches. `grep "SOP"` returns 2 matches, both in `docs/architecture.md` (lines 195, 206) which are META-REFERENCES stating the rule itself ("Course SOPs live in the **private** course workspace, NOT in this repo"). No SOP CONTENT shipped. Course-IP firewall intact. |

---

## Fixes applied during testing

None. All 15 tests passed on first run. Foundation work in commits `0689e5b`, `0e8e491`, `4462937`, `0fcc8c5` is correct and verified.

---

## Live-Cowork tests pending (non-blocking for GitHub push)

These require Nuno to run them in a clean Cowork session post-install to confirm runtime behavior matches the static design:

| Test | How Nuno runs it live |
|---|---|
| TEST 1–4 live | Invoke each skill end-to-end → answer the 10%-better question → verify `projects/research/memory.md` appends with the canonical format → run 3+ times with similar feedback to verify recurrence flag fires + `skill-improvements.md` row appears |
| TEST 5–8 live | Confirm every skill's final output renders the `⚡ NEXT MOVE:` block with caps + lightning emoji + `Why:` line. For `/onboard-research`, run all 6 business-type variants to confirm the topic-extraction table picks correctly. |
| TEST 9 live | Mid-wrap-up crash simulation — kill the session after Step 3 (wrap-up shown) but before Step 5 (install_complete). Re-invoke `/onboard-research` and verify it resumes the wrap-up rather than thinking install is done. |
| TEST 10 live | Open a non-research chat session → verify research catalog/profiles do NOT auto-load (token count check). |
| TEST 11 live | Run `/plugin install cowork-research` → verify `0.1.0` is what gets installed end-to-end. |
| TEST 12 live | Run `bash build-release-zip.sh` → unzip the artifact → verify `docs/sops/`, `.git/`, `release/`, `node_modules/` are NOT inside. |
| TEST 13 live | Walk Phase 1 of `/onboard-research` for each of the 6 business types → confirm Phase 2 personalization file matches classification result. |
| TEST 14 live | Walk Phase 2 of `/onboard-research` → confirm baseline (Perplexity, Firecrawl, Fathom, Context7) are recommended for ALL 6 business types. Live `/browse-connectors` (cowork-ai-os v0.10.2+) wins; bundled catalog is fallback. |
| TEST 15 live | Repo audit — `git ls-files` should return ZERO files matching `*sop*`, `*lesson*`, or `*.md` with `lesson:` frontmatter. |

---

## Conclusion

- **Static + inspection: 15/15 PASS**
- Dynamic in-Cowork verification: procedure documented above
- **Recommendation: GO for GitHub push** (after explicit Nuno confirmation)
