---
name: monthly-review
description: "Monthly deep review with knowledge drift analysis. Aggregates weekly reports, scans for quality issues, suggests merges, archives completed projects, and tracks topic shifts over time."
category: maintenance
depends_on:
  - weekly-review
  - vault-lint
triggers:
  - "/monthly-review"
  - "monthly review"
output_type: report
cost: high
---

# Monthly Review

Monthly deep review — the most comprehensive analysis skill. Aggregates weekly reports, scans for content quality issues, suggests note merges for overlapping topics, archives completed projects, and analyzes knowledge drift (how your actual focus compares to your stated priorities).

> Configure your vault path in setup.sh or set the `VAULT_PATH` environment variable.

**Vault path:** `$VAULT_PATH`
**Report output:** `40 - Daily/YYYY-MM Monthly Review.md`

## Process

### Step 1 — Scan Vault and Collect This Month's Data

Scan `10 - Projects/`, `20 - Areas/`, `30 - Notes/` structure.

**Prefer aggregating from Weekly Reports:**
1. Glob for `*Weekly Review.md` in `40 - Daily/`
2. If >= 3 found for this month: read and aggregate tags, topics, note counts. Supplement with `find -mtime -30` for folder distribution.
3. If < 3 found: fallback — use `find -mtime -30` to scan all notes, compute folder distribution and top 10 tag frequency directly.

**If too few notes (< 10 in the month): simplify the report, skip knowledge drift analysis, produce basic statistics only.**

### Step 2 — Content Quality Scan

One scan, two outputs:

**A. Merge Suggestions** — Find notes with:
- Duplicate or near-duplicate title keywords
- >= 80% tag overlap
- Mutual wikilink references

List each group with the reason for suggested merge. **Do not auto-merge.**

**B. Stub Notes** — Find notes with:
- Fewer than 100 words
- No structural sections
- Missing frontmatter fields

List each stub with name and word count. **Do not auto-edit.**

### Step 3 — Archive Completed Projects

Scan `10 - Projects/` for notes that meet any of:
- `status: completed` in frontmatter
- No edits in 30+ days
- Content indicates the project is clearly finished

List suggestions (up to 5 per batch). **Ask the user to confirm each one before moving to `99 - Archive/`.**

Archive process (after confirmation):
1. Update frontmatter: `status: archived`, first tag to `archive`
2. Move to `99 - Archive/`

### Step 4 — Knowledge Drift Analysis (Core Value)

This is the most important section of the monthly review. Compare what the user thinks they are focused on versus what the data says.

**Process:**
1. Identify "stated focus" — active projects and areas from `10 - Projects/` and `20 - Areas/` folder names
2. Identify "actual focus" — top 5 tags by frequency from Step 1
3. Find gaps:
   - Tags that are high-frequency but not represented in active projects/areas
   - Active projects/areas with few or no related notes this month
4. If a previous Monthly Review exists in `40 - Daily/`, compare tag distribution changes month-over-month

**Insights must be honest, direct, and backed by data. Point out patterns the user may not have noticed. No platitudes.**

### Step 5 — Generate Monthly Report

Write to `40 - Daily/YYYY-MM Monthly Review.md`:

```markdown
---
title: "YYYY-MM Monthly Review"
date: "YYYY-MM-DD"
type: daily
status: active
tags: [daily, monthly-review]
---

# YYYY-MM Monthly Review

## This Month's Note Distribution
| Location | Note Count | Percentage |
|----------|------------|------------|
| 00 - Inbox | N | X% |
| 10 - Projects | N | X% |
| 20 - Areas | N | X% |
| 30 - Notes | N | X% |
| 40 - Daily | N | X% |
| 99 - Archive | N | X% |
| **Total** | **N** | **100%** |

## Top 10 Tag Frequency
| Tag | Count |
|-----|-------|
| tag-name | N |

## Most Active Projects/Areas
1. **Project/Area name** — N notes
2. ...

## Suggested Note Merges
(Write "None" if none)
- [[Note A]] + [[Note B]] — reason: overlapping content on [topic]

## Notes Needing Expansion
(Write "None" if none)
- [[Note Name]] — N words (stub, missing structure)

## Suggested Project Archives
(Write "None" if none)
- [[Project Name]] — last modified YYYY-MM-DD

## Knowledge Drift Insights

### What you think you are focused on
[List active projects and areas]

### What the data says you are actually focused on
[List top tags and their note counts]

### Insight
[Data-driven analysis. Be direct. Identify mismatches, unexpected patterns, or shifts in attention.]

### Comparison with last month
[Compare tag distributions. Write "First monthly review — no comparison available" if no previous review exists.]

## Month Summary
- New notes: N
- Completed projects: N
- Archived notes: N
- Most significant achievement: [based on data]
- Suggested focus for next month: [based on drift analysis]
```

After completion, report to the user:
- Report file path
- Key knowledge drift findings
- Action items to follow up on

## Guidelines

1. **Mostly read-only** — Only write the report and execute user-confirmed archives. Do not modify existing notes without confirmation.
2. **Data-driven insights** — Every claim in the drift analysis must reference specific note counts or tag frequencies.
3. **Wikilinks use `[[Note Name]]`** — Filename only, without paths or `.md`.
4. **If a Monthly Review already exists for the same month** — Use the Edit tool to append rather than overwrite.
5. **Respect user agency** — Merge and archive suggestions are suggestions only. Never auto-execute.

## Related Skills

- [[weekly-review]] — Provides the weekly data this skill aggregates
- [[daily-review]] — Produces the classified notes analyzed here
- [[vault-lint]] — Detailed health metrics complement the monthly overview
- [[recall]] — Dig deeper into topics identified by drift analysis
