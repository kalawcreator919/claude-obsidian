---
name: session-to-obsidian
description: "Save Claude Code session summaries as structured Obsidian notes in Inbox. Captures discussions, file changes, decisions, insights, and follow-ups."
category: knowledge-compilation
depends_on: []
triggers:
  - "/session-to-obsidian"
  - "save session"
  - "record this to Obsidian"
  - "log session"
output_type: note
cost: low
---

# Session to Obsidian

Save a detailed summary of the current Claude Code session as an Obsidian note in `00 - Inbox/`.

> Configure your vault path in setup.sh or set the `VAULT_PATH` environment variable.

## Process

### Step 1 — Early Exit Check

Before doing anything, evaluate the session:

- **Skip conditions:** Session has fewer than 5 exchanges, consists of a single simple question, or only reads files without making any changes
- If the session is too trivial, inform the user and stop
- If the user insists on recording it, proceed

### Step 2 — Summarize the Session

Analyze the entire conversation and extract:

1. **Title** — A concise, descriptive title (e.g., "Playwright MCP Setup + E2E Test Framework")
2. **What was discussed** — Core topics with context. Be specific: not "discussed configuration" but "compared Playwright MCP vs community edition for test reliability"
3. **What changed** — Specific file paths and the nature of each change:
   - `~/.claude/settings.json` — added `playwright` MCP server config
   - `apps/web/tests/e2e/login.spec.ts` — new login flow E2E test (38 lines)
4. **Decision context** — For every important decision, record why option A was chosen over option B:
   - Chose Playwright MCP over community version → official Microsoft maintenance, better API stability
   - Chose SQLite over PostgreSQL → MVP stage does not need a network DB, embedded is simpler
5. **Key insights** — 3 non-obvious discoveries. Be concrete: not "learned about X" but the specific finding
6. **Unfinished / Follow-up** — Concrete, actionable items with:
   - Which file needs changes
   - What command to run
   - How to verify success (e.g., "run `npm test` and confirm all pass")

### Step 3 — Determine Note Type

Choose the `type` based on session content:

| Type | When to use |
|------|-------------|
| `dev-session` | Writing code, debugging, configuring dev environments, skill development |
| `learning` | Researching tools, exploring concepts, reading documentation |
| `work-journal` | Work project progress |
| `project` | Project-level planning, architecture decisions |
| `note` | Atomic knowledge, a clear standalone insight |
| `idea` | Brainstorming, exploring possibilities |
| `daily` | Journal-style recording |
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
tags: [inbox, topic1, topic2]
source: "Claude Code Session"
---

# [Title]

## Summary
> [One sentence: what was accomplished in this session]

## Session Content

### What Was Discussed
- [Specific topic with context]

### What Changed
- `[file path]` — [what changed] ([line count / nature of change])
- `[file path]` — [what changed]

### Decision Log
| Decision | Rationale |
|----------|-----------|
| [Chose A] | [Why not B — specific reasoning] |

## Technical Details

[Important code snippets, config, commands in code blocks]

Example:
- Key config:
  ```json
  { "mcpServers": { "playwright": { "command": "npx", "args": ["@anthropic/mcp-playwright"] } } }
  ```
- Important command:
  ```bash
  npx prisma db push --force-reset
  ```

## Key Insights
1. [Non-obvious insight 1 — be specific]
2. [Non-obvious insight 2]
3. [Non-obvious insight 3]

## Unfinished / Follow-up
- [ ] [Concrete action item] (file: `[path]`, verify: `[command]`)
- [ ] [Concrete action item]

## Related
- [[Related note 1]]
- [[Related note 2]]
```

**Writing principles:**
- Be specific: always include file paths, commands, numbers
- Every sentence must carry substantive information — no filler
- Target word count: 300-500 words

### Step 5 — Add Wikilinks

Scan the Obsidian vault for related notes and add `[[wikilinks]]`:

1. Use the Glob tool to find `.md` files in the vault, prioritizing:
   - `$VAULT_PATH/30 - Notes/*.md`
   - `$VAULT_PATH/10 - Projects/**/*.md`
   - `$VAULT_PATH/20 - Areas/**/*.md`
2. Match related notes based on session topics (keywords, project names, tool names)
3. Add matched note names to the "Related" section as `[[Note Name]]` (without `.md`)
4. If no related notes are found, write "No related notes found yet"

### Step 6 — Write to Inbox

**Always write to `00 - Inbox/`** — do not classify into folders directly.

```
Write tool → file_path: "$VAULT_PATH/00 - Inbox/YYYY-MM-DD [Title].md"
```

### Step 7 — Confirm

Report to the user:
- Note path (full path)
- Word count
- Tags
- Number of wikilinks added (and which ones)
- Reminder that `/daily-review` will classify this note

## Guidelines

- **All notes go to `00 - Inbox/`** — classification is handled by `/daily-review`
- The first tag is always `inbox`; subsequent tags are topic-specific
- Use `[[wikilinks]]` to link related notes, increasing knowledge graph density
- Specific over vague: file paths, commands, line numbers, error messages should all be recorded
- Decision context is mandatory: every trade-off must include "why A not B"
- Only record key code snippets (config, commands, workarounds) — do not dump everything
- **Multi-topic sessions** — Titles connected with `+` are fine (e.g., "Fix X + Research Y + Configure Z"). The `/daily-review` skill will split them into individual notes later.
- **Do not split sessions yourself** — One session always produces one note. Splitting is handled by `/daily-review`.

## Related Skills

- [[daily-review]] — Processes the inbox notes this skill creates
- [[recall]] — Find related notes before or after saving
- [[vault-lint]] — Ensures the saved note meets quality standards
