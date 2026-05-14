---
name: meeting-recap
slug: /meeting-recap
version: 0.1.0
plugin: cowork-research
description: Pull a Fathom transcript and extract decisions, action items, open questions, and notable quotes. Reads about-me/business-brain.md (for ICP context — what the user cares about). Uses Fathom MCP. Lands in reference/research/meetings/<date>-<title>.md. Optionally drafts to chosen destination.
triggers:
  - /meeting-recap
  - recap this meeting
  - pull fathom recap
  - meeting actions
  - meeting notes from fathom
---

# /meeting-recap — v0.1.0

Pull a Fathom meeting transcript and extract decisions + action items + open questions.

## Inputs

- **Required:** Fathom URL OR call_id OR recording_id
- **Read on every run:**
  - `about-me/about-me.md`
  - `about-me/business-brain.md` (for ICP context — what action items matter to THIS user)
  - `templates/meeting-recap-template.md`
  - `projects/research/research-preferences.md` (recap depth: executive / detailed / verbatim)

## Logic

1. Read input files
2. Resolve Fathom input: URL → `mcp__claude_ai_Fathom__get_recording_by_url`; call_id → `get_recording_by_call_id`; recording_id → `get_meeting_summary` directly
3. Call `get_meeting_transcript` with the resolved recording_id (for timestamped quotes) AND `get_meeting_summary` (for AI-generated summary as a starting point)
4. Extract structured data:
   - 1-paragraph TLDR
   - Decisions made (3-5 bullets)
   - Action items (with owner + deadline if mentioned)
   - Open questions (things raised but not resolved)
   - 2-3 notable quotes with timestamps + speaker
5. Generate recap using `templates/meeting-recap-template.md` shape
6. Plan-then-approve: show user the recap structure + key extracted items
7. On user approval, write the recap
8. Append one-line entry to `reference/research/_index.md`
9. Append one-line entry to `projects/research/memory.md`
10. If destination = Notion or vault, ask: "Draft to <destination> too?"

## Output

- `reference/research/meetings/<date>-<title>.md` (the recap)

## Hard rules

- Never make claims about meeting content without calling `get_meeting_transcript` first (per Fathom MCP grounding rule)
- Plan-then-approve before any write
- Action items MUST include owner + deadline if mentioned in the transcript; mark "owner: unspecified" if not

## Voice for the recap itself

Tactical, scannable. Decisions and actions are the load-bearing parts — the rest is supporting. Quotes only when they capture something the summary can't.

## Self-improvement close (Foundation B)

After the recap is written, ask the user ONE question:

> "Did this recap land? What would have made it 10% better?"

- Append the user's answer as a one-line entry to `projects/research/memory.md` (append-only, never overwrite). Format: `<YYYY-MM-DD> /meeting-recap on <meeting-title> — <user's one-line feedback>`
- Scan `projects/research/memory.md` for recurring complaints. If the same complaint shows up 3+ times (e.g., "quotes section is noise, drop it" three runs in a row), append a flag line: `flag: meeting-recap skill — <pattern>, consider revising SKILL.md`
- Do NOT edit SKILL.md yourself. Surface the flag to the user; they decide if/when to revise.

## Actionable close (Foundation C)

End every run with this exact block (the `⚡ NEXT MOVE:` string is canonical — caps, leading lightning emoji, colon, space):

```
⚡ NEXT MOVE: <owner> <specific verb on specific action item> <by when>
   Why: <one-sentence reason — usually the decision or commitment that depends on it>
```

The Next Move MUST be the SINGLE most important action item from the meeting — not the full list. Picking rule:

1. If the user is the owner of any action item → pick the user's most time-sensitive one
2. If the user owes a follow-up to another attendee → that wins (relationship debt compounds fastest)
3. If all action items belong to others → pick the one the user needs to UNBLOCK or chase, with timing
4. If the meeting had no action items but had a decision → pick the action that operationalizes the decision

| Action item type | Next Move pattern |
|---|---|
| User owes a deliverable | "Send <deliverable> to <attendee> by <deadline> — <decision/commitment from meeting>." |
| User needs to chase someone else's action | "Follow up with <attendee> on <their action item> by <date> — they committed in the meeting and it blocks <next step>." |
| Decision was made, needs to be operationalized | "Tell <stakeholder> about the decision to <X> today — they need to know before <next downstream event>." |
| Meeting flagged an open question | "Get an answer on <open question> from <best source> by <date> — it blocks the decision on <Y>." |

✅ "⚡ NEXT MOVE: Send Sarah the revised pricing deck by Wednesday EOD — you committed to it at 14:32 and it gates the contract decision."
❌ "⚡ NEXT MOVE: Review the action items and follow up." (no owner, no specific action, no timing — fails the rule)
