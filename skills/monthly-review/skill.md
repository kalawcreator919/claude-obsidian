---
name: monthly-review
description: Use when a month has passed since last review, or user wants deep self-insight on knowledge drift, merge overlapping notes, and archive completed projects. Triggers on "/monthly-review", "monthly review"
---

# Monthly Review

Monthly cleanup + deep self-insight. Triggered manually at end of month. Write report in Cantonese, technical terms in English. Insights must be direct and data-backed — no platitudes.

## Step 1 — Scan Vault + Collect This Month's Data

Scan `10 - Projects/`, `20 - Areas/`, `30 - Notes/` structure.

**Prefer aggregating from Weekly Reports:**
1. Glob for `*Weekly Review.md` in `40 - Daily/`
2. If >= 3 found: read and aggregate tags/topics/note counts, supplement with `find -mtime -30` for folder distribution
3. If < 3 found: fallback — `find -mtime -30` to scan all notes, compute folder distribution + top 10 tag frequency yourself

**If too few notes (< 10): simplify the report, skip knowledge drift analysis, only do basic stats.**

## Step 2 — Content Quality Scan

One scan, two outputs:

**A. Merge Suggestions** — Find notes with duplicate title keywords / >= 80% tag overlap / mutual references. List each group + reason. Do not auto-merge.

**B. Stub Notes** — Find notes with < 100 words / no structure / missing frontmatter fields. List name + word count. Do not auto-edit.

## Step 3 — Archive Completed Projects

Scan `10 - Projects/` for notes with `status: completed` / no edits in 30 days / clearly finished. List suggestions (up to 5 per batch), ask user to confirm each one before moving to `99 - Archive/`.

## Step 4 — Knowledge Drift Analysis (Core Value)

Compare Active Projects/Areas topics vs actual top 5 tag frequency from Step 1. Identify gaps: tags that are high-frequency but not in Active, and Active items with no related notes. If a previous Monthly Review exists, compare tag distribution changes. Insights must be honest and direct, backed by data — point out patterns the user hasn't noticed.

## Step 5 — Generate Monthly Report

Write to `40 - Daily/YYYY-MM Monthly Review.md`.

**Report sections (in order):**
1. Frontmatter: title/date/type:daily/status:active/tags:[daily, monthly-review]
2. This Month's Note Distribution — table: Location | Note Count | Percentage (6 folders + total)
3. Top 10 Tag Frequency — table: Tag | Count
4. Most Active Projects/Areas — numbered list with note count
5. Suggested Note Merges — wikilink pairs + reason (write "None" if none)
6. Notes Needing Expansion — wikilink + word count (write "None" if none)
7. Suggested Project Archives — wikilink + last modified date (write "None" if none)
8. Knowledge Drift Insights:
   - What you think you're focused on... (active projects/areas)
   - What the data says you're actually focused on... (top tags)
   - Insight (data-driven, direct, no platitudes)
   - Comparison with last month (write "First monthly review" if no previous one)
9. Month Summary — new notes / completed projects / archived notes / biggest achievement / next month's focus

After completion, report to user: report path, key knowledge drift findings, and action items to follow up on.
