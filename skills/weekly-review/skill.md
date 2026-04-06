---
name: weekly-review
description: "Weekly knowledge accumulation analysis. Collects past 7 days of notes, analyzes trends, identifies resurfacing opportunities, and generates a health-scored report."
category: maintenance
depends_on:
  - vault-lint
triggers:
  - "/weekly-review"
  - "weekly review"
output_type: report
cost: medium
---

# Weekly Review

Weekly knowledge accumulation analysis — collect the past 7 days of new and modified notes, analyze folder distribution and tag frequency trends, identify resurfacing opportunities for valuable older notes, and generate a weekly report.

> Configure your vault path in setup.sh or set the `VAULT_PATH` environment variable.

**Vault path:** `$VAULT_PATH`
**Report output:** `40 - Daily/YYYY-MM-DD Weekly Review.md`
**Read-only:** Analysis only; do not modify any existing notes (except writing the report).

## Process

### Step 1 — Build Vault Context

Scan the vault structure to understand existing Projects/Areas/Notes:

```bash
ls "$VAULT_PATH/10 - Projects/"
ls "$VAULT_PATH/20 - Areas/"
ls "$VAULT_PATH/30 - Notes/"
```

### Step 2 — Collect This Week's Data

Find all `.md` notes created or modified in the past 7 days:

```bash
find "$VAULT_PATH" -name "*.md" -mtime -7 -not -path "*/.obsidian/*" -not -path "*/.trash/*"
```

Use the Read tool to read each note and record:
- Filename and containing folder
- Frontmatter tags
- Content length (word count)
- Number of wikilinks

### Step 3 — Tag Analysis

Count the occurrences of each tag across this week's notes.

**Exclude meta tags:** `daily`, `review`, `weekly-review`, `inbox`, `fleeting`, `active`, `completed`, `archived`, `archive`, `projects`, `areas`, `notes`

Identify the **3 most frequent core topics** and write a one-sentence description for each.

### Step 4 — Note Value Assessment

Score each note from this week (1-5):

| Criterion | High-score indicators |
|-----------|----------------------|
| Content completeness | Contains technical details, decision context, step-by-step records |
| Wikilink count | More links = richer knowledge network |
| Insight depth | Contains analysis and reflection, not just factual records |
| Reusability | Can be referenced by other notes in the future |

Select the **Top 3-5 most valuable notes** with a one-sentence explanation for each.

### Step 5 — Resurface Older Notes

Based on the 3 core topics from Step 3, use the Grep tool to find related older notes (more than 7 days old):

```
Grep: pattern = "topic keyword", path = "$VAULT_PATH", glob = "**/*.md", output_mode = "files_with_matches", -i = true
```

Exclude notes already processed this week. Find 1-3 notes per topic and briefly explain why they are worth revisiting — for example, they contain related decisions, contradictory findings, or complementary insights.

### Step 6 — Run Vault Lint Summary

Call the [[vault-lint]] skill logic to generate a health summary for inclusion in the report.

If vault-lint is not available as a separate skill, perform a lightweight scan:
- Count orphan notes (notes with no inbound wikilinks)
- Count notes with `status: active` but not modified in 14+ days (stale)
- Report the Health Score estimate

### Step 7 — Generate Weekly Report

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

### Folder Distribution
| Folder | Notes | Percentage |
|--------|-------|------------|
| 10 - Projects | N | X% |
| 20 - Areas | N | X% |
| 30 - Notes | N | X% |
| 00 - Inbox | N | X% |
| 40 - Daily | N | X% |
| 99 - Archive | N | X% |
| **Total** | **N** | **100%** |

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
- [[Old note name]] — [Why it is relevant now]

## Vault Health Summary
Health Score: XX/100
- Contradictions: X found
- Stale notes: X found
- Orphan notes: X found
- Content gaps: X found

## Weekly Summary
- Notes created: N
- Notes modified: N
- Most active folder: XXX
- Raw clips compiled: N
- Suggested focus for next week: [Trend-based recommendation]
```

**Edge case:** If there are no notes this week, the report should state "No notes were created or modified this week" instead of generating empty tables.

## Guidelines

1. **Read-only** — Do not modify any existing notes; only produce the report.
2. **Wikilinks use `[[Note Name]]`** — Filename only, without paths or `.md`.
3. **Scores must be justified** — Provide an explanation for every score.
4. **If a Weekly Review already exists for the same date** — Use the Edit tool to append rather than overwrite.

## Related Skills

- [[daily-review]] — Produces the notes this skill analyzes
- [[monthly-review]] — Aggregates weekly reviews for deeper analysis
- [[vault-lint]] — Provides the health score included in the report
- [[recall]] — Can be used to dig deeper into resurfaced topics
