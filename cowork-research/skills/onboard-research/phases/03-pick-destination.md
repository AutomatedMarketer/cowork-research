# Phase 3 — Pick Destination

## What this phase does

Lists destination options for research outputs (briefs, audits, recaps), based on what's actually installed on the user's machine. Lets the user pick a primary destination (where outputs land by default) and an optional fold-back destination (where they get copied for sharing / mobile reading). Writes the choice to `projects/research/research-preferences.md`.

The 3 possible destinations:

1. **Workspace** (always available) — outputs land in `<workspace>/reference/research/`
2. **Vault** (only if cowork-obsidian detected) — outputs land in `<vault>/<area>/wiki/sources/research/`
3. **Notion** (only if Notion MCP detected) — outputs land as Notion pages in a chosen database

## Ask

Two questions:

1. *"Where should your research outputs land by default? Pick one:*
   *[options shown based on detection]"*
2. *"Want a fold-back destination too? That's where I'll copy outputs after writing to the primary. Useful for sharing or reading on your phone. Pick one or skip."*

## Why we ask

> *"Briefs, audits, and recaps need a home. The workspace is always there — local files Cowork can re-read. A vault is great for long-term knowledge that grows. Notion is great if you collaborate or read on your phone.*
>
> *Most people pick one primary and skip the fold-back at first. You can always change this later by editing `research-preferences.md`."*

## Logic

### Step 1 — Detect what's available

Three probes:

**Workspace** — always available. No probe needed.

**Vault (cowork-obsidian)** — probe by reading the Claude Code installed-plugins manifest:

```
read ~/.claude/plugins/installed_plugins.json
```

If `cowork-obsidian` appears in the installed list with version >= 0.5.0:
- Read `<workspace>/projects/second-brain/vaults.md` (cowork-obsidian's vault registry)
- Pull the list of registered vaults with their `path` and the user's chosen life-areas
- Mark vault as available

If cowork-obsidian is not installed, mark vault as `not_available` and tell the user *(when they ask about vault): "Vault destination needs cowork-obsidian installed first. Skip for now or install + onboard cowork-obsidian and re-run this phase."*

**Notion** — probe by checking if any MCP tool with prefix `mcp__notion__*` is registered. If yes, mark Notion as available. If no, mark as `not_available`.

### Step 2 — Present options

Show only available destinations, numbered:

```
Where should your research outputs land?

  1. Workspace — <workspace>/reference/research/  (always available)
  2. Vault — <vault-name> at <path>  (cowork-obsidian detected)
  3. Notion — pages in a chosen database  (Notion MCP detected)

Pick 1, 2, or 3:
```

If only workspace is available, tell the user: *"You only have one option right now (workspace). That's the default. If you install cowork-obsidian or Notion MCP later, you can re-run Phase 3 to switch."*

### Step 3 — Capture primary

User picks one. Write to `<workspace>/projects/research/research-preferences.md`:

```yaml
primary_destination: <workspace|vault|notion>
primary_destination_path: <full path or notion-database-id>
# if vault, also:
vault_name: <name>
vault_area: <which life-area sub-folder, e.g., "coaching">
# if notion, also:
notion_database_id: <id>
notion_database_name: <human-readable name>
```

If vault picked: ask which life-area sub-folder under the vault to write to (briefs land in `<vault>/<area>/wiki/sources/research/briefs/`).

If Notion picked: ask which database (paste-ready prompt to call `mcp__notion__list_databases` if Notion MCP supports it).

### Step 4 — Capture optional fold-back

> *"Want me to also copy outputs to a fold-back destination? Pick another option from the list, or type `skip`."*

If user picks a fold-back: append `fold_back_destination:` and `fold_back_path:` (and any required ID fields) to `research-preferences.md`. The fold-back is a SECONDARY copy — primary always gets written first; fold-back is asked-each-time in v0.1 (default no, ask each time).

If user skips: write `fold_back_destination: none`.

## Write

- `<workspace>/projects/research/research-preferences.md` — write or append the destination block (use [`../templates/research-preferences.md.template`](../templates/research-preferences.md.template) shape; if the file already exists, update only the destination fields, don't clobber other fields)
- `_aibos/state-research.md` — append:
  - `phase_3_destination: completed_at <ISO timestamp>`
  - `primary_destination: <workspace|vault|notion>`
  - `fold_back_destination: <workspace|vault|notion|none>`

## Resume

After this phase completes, mark `phase_3_destination` as `completed_at <ISO timestamp>` in state-research.md and set `next_pending_phase: 4`.

## Verification before advancing

Phase 3 is complete when ALL of these are true:

- Detection ran for all 3 destinations (workspace always; vault + Notion probed)
- `research-preferences.md` has `primary_destination` set to one of the 3 valid values
- The path / ID for the primary destination is captured and verified to exist (vault path on disk, Notion database accessible)
- `fold_back_destination` is set (either to a valid second option or to `none`)

If the user picks a vault or Notion destination but the path/ID can't be verified, halt and ask the user to fix the underlying setup before advancing.
