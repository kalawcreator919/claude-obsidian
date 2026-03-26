# Vault Folder Structure

This guide describes the recommended Obsidian vault folder structure used by the claude-obsidian skills. The structure is inspired by the [PARA method](https://fortelabs.com/blog/para/) (Projects, Areas, Resources, Archives) with adaptations for daily reviews and session logging.

## Folder Overview

```
00 - Inbox/          Entry point for all new notes
01 - Active/         Frequently opened notes (keep 5-10 max)
10 - Projects/       Time-bound projects with deadlines
20 - Areas/          Ongoing topics with no deadline
30 - Notes/          Atomic notes (one idea = one note)
40 - Daily/          Journal entries + review reports
99 - Archive/        Completed or outdated notes
    Sessions/        Processed session logs
```

## Required Folders

These folders must exist for the core skills to function correctly.

### `00 - Inbox/`

The universal entry point. Every new note lands here first.

**Used by:**
- **session-to-obsidian** — writes session logs here
- **daily-review** — reads and processes notes from here, then moves them to their final destination

### `40 - Daily/`

Stores daily journals and all review reports.

**Used by:**
- **daily-review** — writes `YYYY-MM-DD Daily Review.md` reports here
- **weekly-review** — writes `YYYY-MM-DD Weekly Review.md` reports here
- **monthly-review** — writes `YYYY-MM Monthly Review.md` reports here; also reads past Weekly Reviews to aggregate data

### `99 - Archive/` and `99 - Archive/Sessions/`

Holds completed, outdated, or fully processed notes. The `Sessions/` subfolder specifically stores session logs that have been split or classified.

**Used by:**
- **daily-review** — moves archived session logs to `Sessions/`; moves split parent notes here after extracting child notes
- **monthly-review** — suggests archiving completed projects from `10 - Projects/` to here

## Optional Folders

These folders are used by the **daily-review** classification step and by search/analysis skills. If they do not exist, the skills will either skip them or create them as needed.

### `10 - Projects/`

For notes tied to a specific project with a deadline or clear endpoint. Daily-review classification question: *"Does it have a deadline or a clear endpoint?"* If yes, the note moves here into a project subfolder (e.g., `10 - Projects/MyApp/`).

**Used by:**
- **daily-review** — classification target
- **weekly-review** — scanned for vault context and tag analysis
- **monthly-review** — scanned for completed projects to archive
- **recall** — searched during note lookup (+1 bonus score for notes here)

### `20 - Areas/`

For ongoing areas of responsibility with no deadline. Daily-review classification question: *"Is it an ongoing area of responsibility?"* If yes, the note moves here into an area subfolder (e.g., `20 - Areas/Finance/`).

**Used by:**
- **daily-review** — classification target
- **weekly-review** — scanned for vault context
- **monthly-review** — scanned for knowledge drift analysis

### `30 - Notes/`

For atomic, standalone notes — one idea per note. Titles should be written as assertion statements (e.g., "Git hooks can automate pre-commit checks" rather than "Git Hooks"). Daily-review classification question: *"Is it a standalone idea or insight?"*

**Used by:**
- **daily-review** — classification target; rewrites titles as assertions when moving notes here
- **recall** — searched during note lookup (+2 bonus score for notes here)

### `01 - Active/`

A small working set of frequently opened notes (5-10 max). Not directly used by any skill, but useful for personal workflow.

## Note Naming Convention

All notes follow this filename format:

```
YYYY-MM-DD Title.md
```

Examples:
- `2026-03-26 Playwright MCP Setup.md`
- `2026-03-26 Daily Review.md`
- `2026-03 Monthly Review.md` (monthly reviews omit the day)

The date prefix ensures chronological sorting and prevents filename collisions.

## Frontmatter Format

Every note includes YAML frontmatter at the top of the file:

```yaml
---
title: "Note Title"
date: "2026-03-26"
type: dev-session
status: active
tags: [inbox, topic1, topic2]
---
```

### Fields

| Field | Required | Description |
|-------|----------|-------------|
| `title` | Yes | Human-readable title (quoted) |
| `date` | Yes | Creation date in `YYYY-MM-DD` format (not `created`) |
| `type` | Yes | One of: `fleeting`, `project`, `note`, `daily`, `dev-session`, `learning`, `work-journal`, `idea` |
| `status` | Yes | One of: `active`, `completed`, `archived` |
| `tags` | Yes | Array; first element is the folder category, followed by topic tags |

### Tag First-Element Convention

The first tag indicates where the note lives:

| Location | First tag |
|----------|-----------|
| `00 - Inbox/` | `inbox` |
| `10 - Projects/` | `projects` |
| `20 - Areas/` | `areas` |
| `30 - Notes/` | `notes` |
| `99 - Archive/` | `archive` |
| `40 - Daily/` | `daily` |

When daily-review moves a note, it updates this first tag to match the destination.

### Optional Fields

Skills may add additional frontmatter fields:

- `source: "Claude Code Session"` — added by session-to-obsidian
- `source_note: "[[Original Note]]"` — added by daily-review when splitting a note

## Customization

The folder names and paths referenced above are defaults. Users can customize them by editing the `skill.md` files in each skill's directory:

```
skills/
  session-to-obsidian/skill.md   — change Inbox path
  daily-review/skill.md          — change classification targets and folder names
  weekly-review/skill.md         — change scanned folders and report output path
  monthly-review/skill.md        — change scanned folders and report output path
  recall/skill.md                — change search paths and scoring bonuses
```

For example, to rename `30 - Notes/` to `30 - Zettelkasten/`, update the folder references in `daily-review/skill.md`, `weekly-review/skill.md`, `monthly-review/skill.md`, and `recall/skill.md`.

The `{{VAULT}}` placeholder in skill files resolves to the configured Obsidian vault path at runtime.
