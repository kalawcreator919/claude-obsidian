---
name: session-to-obsidian
description: Use when user wants to save, log, or record the current Claude Code session to Obsidian. Triggers on "save session", "record this to Obsidian", "log session".
---

# Session to Obsidian

Save a detailed summary of the current Claude Code session as an Obsidian note in `00 - Inbox/`.

## Process

### Step 1 — Early Exit Check

Before doing anything, evaluate the session:

- **Skip conditions:** Fewer than 5 exchanges, only a simple question was asked, or purely read files with no changes made
- If the session is too trivial, tell the user "This session is too short/trivial to be worth recording" and stop
- If the user insists, proceed anyway

### Step 2 — Summarize the Session

Analyze the entire conversation and extract the following:

1. **Title** — A concise, descriptive title (e.g. "Playwright MCP Setup + E2E Test Framework")
2. **What was discussed** — Core topics with specifics. Don't write "discussed configuration"; write "discussed trade-offs between Playwright MCP vs community edition"
3. **Changes made** — Include specific file paths, e.g.:
   - `~/.claude/settings.json` — Added `playwright` MCP server config
   - `apps/web/tests/e2e/login.spec.ts` — New login flow E2E test (38 lines)
4. **Decision context** — Record why A was chosen over B for every important decision, e.g.:
   - Chose Playwright MCP over community edition → officially maintained by Microsoft, better API stability
   - Used SQLite instead of PostgreSQL → no need for network DB at MVP stage, embedded is simpler
5. **Key insights** — 3 non-obvious insights (don't write "learned X"; write the specific finding)
6. **Incomplete / Follow-up** — Concrete actionable items, specifying:
   - Which file needs changes
   - What command to run
   - How to verify success (e.g. "run `npm test` and confirm all pass")

### Step 3 — Determine Note Type

Choose `type` based on session content:

| Type | When to use |
|------|-------------|
| `dev-session` | Writing code, debugging, setting up dev environment, skill development |
| `learning` | Researching tools, exploring concepts, reading documentation |
| `work-journal` | Work project progress |
| `project` | Project-level planning, architecture decisions |
| `note` | Atomic knowledge note, a single clear insight |
| `idea` | Brainstorming, exploring possibilities |
| `daily` | Diary-style entries |
| `fleeting` | Quick capture, no clear category |

### Step 4 — Generate the Note

**Filename format:** `YYYY-MM-DD Title.md`

**Full note structure:**

```markdown
---
title: "[Title]"
date: "YYYY-MM-DD"
type: [type]
status: active
tags: [inbox, [topic1], [topic2]]
# -- Custom --
source: "Claude Code Session"
---

# [Title]

## Summary
> [One sentence describing what this session accomplished]

## Session Content

### What was discussed
- [Specific topic with context]

### Changes made
- `[file path]` — [What changed] ([line count / nature of change])
- `[file path]` — [What changed]

### Decision log
| Decision | Reasoning |
|----------|-----------|
| [Chose A] | [Why not B — specific reasoning] |

## Technical Details

[Important code snippets, config settings, commands — wrapped in code blocks]

For example:
- Key config:
  ```json
  { "mcpServers": { "playwright": { "command": "npx", "args": ["@anthropic/mcp-playwright"] } } }
  ```
- Important commands:
  ```bash
  npx prisma db push --force-reset
  ```

## Key Insights
1. [Non-obvious insight 1 — be specific]
2. [Non-obvious insight 2]
3. [Non-obvious insight 3]

## Incomplete / Follow-up
- [ ] [Concrete action item] (file: `[path]`, verify: `[command]`)
- [ ] [Concrete action item]

## Related Notes
- [[Related note 1]]
- [[Related note 2]]
```

**Writing principles:**
- Write in English; keep technical terms as-is
- Specific > vague: always include exact file paths, commands, numbers
- Every sentence must carry substantive information — no filler
- Target word count: 300–500 words

### Step 5 — Add Wikilinks

Scan the Obsidian vault for related notes and add `[[wikilinks]]`:

1. Use the Glob tool to find `.md` files in the vault, prioritizing:
   - `{{VAULT}}/30 - Notes/*.md`
   - `{{VAULT}}/10 - Projects/*.md`
   - `{{VAULT}}/20 - Areas/*.md`
2. Match related notes based on session topics (keywords, project names, tool names)
3. Add matched note names to the "Related Notes" section as `[[note name]]` (without `.md`)
4. If no related notes are found, leave empty or write "No related notes found"

### Step 6 — Write to Inbox

**Always write to `00 - Inbox/`** — do not sort into folders directly.

Use the Write tool:
```
Write tool → file_path: "{{VAULT}}/00 - Inbox/YYYY-MM-DD [Title].md"
```

### Step 7 — Confirm

Report back:
- Note path (full path)
- Word count
- Tags
- Number of wikilinks added (list them)
- Remind the user that the next `/daily-review` will handle categorization of this note

## Guidelines

- **All notes go to `00 - Inbox/`** — categorization is handled by `/daily-review`
- First tag is always `inbox`; subsequent tags are topic tags
- Use `[[wikilinks]]` to link related notes, increasing knowledge graph density
- Specific > vague: file paths, commands, line numbers, error messages should all be recorded
- Decision context is mandatory: every trade-off must include "why A not B"
- Only record key code snippets (config, commands, workarounds) — don't dump everything
- **Multi-topic sessions** — Titles joining multiple topics with `+` are normal (e.g. "Fix X + Research Y + Configure Z"). Once in Inbox, `/daily-review` will automatically split them into separate notes
- **Do not split sessions yourself** — one session always produces one note; splitting is handled by `/daily-review`
