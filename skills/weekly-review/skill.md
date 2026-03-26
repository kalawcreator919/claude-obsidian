---
name: weekly-review
description: Use when a week has passed since last review, or user wants to analyze knowledge accumulation trends and resurface valuable old notes. Triggers on "/weekly-review", "weekly review".
---

# Weekly Review

Weekly knowledge review — analyze knowledge accumulation trends in the Obsidian vault and resurface valuable older notes.

**Vault path:** `{{VAULT}}`
**Report output:** `40 - Daily/YYYY-MM-DD Weekly Review.md`
**Read-only:** Analysis only; do not modify any existing notes.

## Process

### Step 1 — Build Vault Context

Scan the vault structure to understand existing Projects/Areas/Notes:

```bash
ls "{{VAULT}}/10 - Projects/"
ls "{{VAULT}}/20 - Areas/"
ls "{{VAULT}}/30 - Notes/"
```

### Step 2 — Collect This Week's Data

Find all `.md` notes created or modified in the past 7 days:

```bash
find "{{VAULT}}" -name "*.md" -mtime -7 -not -path "*/.obsidian/*" -not -path "*/.trash/*"
```

Use the Read tool to read each note and record:
- Filename and containing folder
- Frontmatter tags
- Content length
- Number of wikilinks

### Step 3 — Tag Analysis

Count the occurrences of each tag.

**Exclude meta tags:** `daily`, `review`, `weekly-review`, `inbox`, `fleeting`, `active`, `completed`, `archived`, `archive`, `projects`, `areas`, `notes`

Identify the **3 most frequent core topics** and write a one-sentence description for each.

### Step 4 — Note Value Assessment

Score each note from this week (1-5):

| Criterion | High-score indicators |
|-----------|----------------------|
| Content completeness | Contains technical details, decision context, step-by-step records |
| Wikilink count | More links = richer knowledge network |
| Insight depth | Contains analysis and reflection, not just factual records |
| Reusability | Can be referenced by other notes |

Select the **Top 3-5 most valuable notes** with a one-sentence explanation for each.

### Step 5 — Resurface Older Notes

Based on the 3 core topics from Step 3, use the Grep tool to find related older notes (more than 7 days old):

```
Grep: pattern = "topic keyword", path = "{{VAULT}}", glob = "**/*.md", output_mode = "files_with_matches", -i = true
```

Exclude notes already processed this week. Find 1-3 notes per topic and briefly explain why they are worth revisiting.

### Step 6 — Generate Weekly Report

Calculate this week's date range (Monday to Sunday). Write to `40 - Daily/YYYY-MM-DD Weekly Review.md`:

```markdown
---
title: "YYYY-MM-DD Weekly Review"
date: "YYYY-MM-DD"
type: daily
status: active
tags: [daily, weekly-review]
---

# YYYY-MM-DD Weekly Review
Week of YYYY-MM-DD to YYYY-MM-DD

## Knowledge Accumulation This Week

### Tag Statistics
| Tag | Occurrences | Key Notes |
|-----|-------------|-----------|
| tag-name | N | [[Note A]], [[Note B]] |

### 3 Core Topics
1. **[Topic name]** — [One-sentence description]
2. ...
3. ...

## Most Valuable Notes This Week

1. **[[Note name]]** (5/5) — [Why it is valuable]
2. ...

## Older Notes Worth Revisiting
- [[Old note name]] — [Why it is relevant]

## Weekly Summary
- Notes created: N
- Notes modified: N
- Most active folder: XXX
- Suggested focus for next week: [Trend-based recommendation]
```

**Edge case:** If there are no notes this week, the report should state "No notes were created or modified this week" instead of generating empty tables.

## Important Rules

1. **Read-only** — Do not modify any existing notes; only produce the report.
2. **English report** — Keep technical terms as-is (folder names, tool names, frontmatter fields).
3. **Wikilinks use `[[Note name]]`** — No paths, filename only (without `.md`).
4. **Scores must be justified** — Provide an explanation for every score.
5. **If a Weekly Review already exists for the same date** — Use the Edit tool to append rather than overwrite.
