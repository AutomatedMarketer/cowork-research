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
