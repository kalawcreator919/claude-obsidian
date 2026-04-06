---
name: vault-lint
description: "Scan vault for contradictions, staleness, orphans, and content gaps. Generates a Health Score out of 100 with structured lint report. Auto-fixes only safe items."
category: maintenance
depends_on: []
triggers:
  - "/vault-lint"
  - "lint vault"
  - "check vault"
  - "scan notes"
output_type: report
cost: medium
---

# Vault Lint — Knowledge Health Check

Scan the Obsidian vault across four dimensions, score each out of 25, and produce a Health Score out of 100. Auto-fix only safe, mechanical items. Everything else is report-only.

> Configure your vault path in setup.sh or set the `VAULT_PATH` environment variable.

**Vault path:** `$VAULT_PATH`
**Report output:** `40 - Daily/YYYY-MM-DD Vault Lint.md`

## Health Score Dimensions

| Dimension | Max Score | What it measures |
|-----------|-----------|------------------|
| Contradictions | 25 | Conflicting claims across notes |
| Staleness | 25 | Outdated active notes, expired TODOs |
| Orphans | 25 | Disconnected notes, broken wikilinks |
| Gaps | 25 | Missing overviews, referenced-but-nonexistent notes |

**Scoring:** Each dimension starts at 25 and loses points per issue found:
- Critical issue: -5 points
- Warning: -2 points
- Info: -1 point

Minimum score per dimension is 0. Total Health Score = sum of all four dimensions.

## Process

### Step 1 — Build Note Index

Scan the entire vault (excluding `.obsidian/`, `.trash/`, and `Attachments/`):

```bash
find "$VAULT_PATH" -name "*.md" -not -path "*/.obsidian/*" -not -path "*/.trash/*" -not -path "*/Attachments/*"
```

For each note, read frontmatter and extract:
- `title`, `date`, `status`, `tags`, `type`
- All `[[wikilinks]]` in the body
- Word count
- Last modified date (from filesystem)

Build an in-memory index: `{ filename → { frontmatter, wikilinks, word_count, modified_date } }`

### Step 2 — Contradiction Scan (25 points)

Search for conflicting claims across notes. Focus on:

**2a. Factual conflicts:**
- Grep for common assertion patterns (dates, numbers, "X is Y", "X uses Y")
- Compare claims about the same entity across different notes
- Flag when Note A says "Project X uses React" but Note B says "Project X uses Vue"

**2b. Status conflicts:**
- Notes with `status: active` that reference a project marked `status: completed`
- Multiple notes claiming to be the "overview" or "main doc" for the same project

**2c. Date conflicts:**
- Frontmatter `date` that does not match the filename date prefix
- Future dates (unless the note is a plan)

**Severity:**
- Factual conflict between notes: Critical (-5)
- Status mismatch: Warning (-2)
- Date mismatch: Info (-1)

**Auto-fix (safe):** Correct date mismatches where the filename date is clearly correct and frontmatter date is a typo (off by one day or transposed digits). Log all auto-fixes.

### Step 3 — Staleness Scan (25 points)

Detect notes that should be active but have gone cold.

**3a. Stale active notes:**
- `status: active` but not modified in 14+ days
- Severity: Warning (-2 each, max -10)

**3b. Expired TODOs:**
- Grep for `- [ ]` items with dates that have passed
- Grep for "by [date]", "deadline: [date]", "due: [date]" patterns
- Severity: Warning (-2 each, max -10)

**3c. Orphaned follow-ups:**
- Notes with `## Follow-up` or `## Unfinished` sections where items are > 30 days old
- Severity: Info (-1 each)

**Auto-fix (safe):** Update frontmatter `status: active` to `status: stale` for notes not modified in 30+ days (not 14 — use a more conservative threshold for auto-fix). Log all changes.

### Step 4 — Orphan Scan (25 points)

Find disconnected notes and broken links.

**4a. Orphan notes (no inbound wikilinks):**
- For each note in the index, check if any other note links to it via `[[Note Name]]`
- Notes in `40 - Daily/` and `99 - Archive/` are exempt (they are naturally less connected)
- Severity: Info (-1 each, max -15)

**4b. Broken wikilinks:**
- For each `[[Note Name]]` found in vault notes, verify the target file exists
- Severity: Warning (-2 each, max -10)

**4c. Self-referencing notes:**
- Notes that link to themselves: Info (-1 each)

**Auto-fix:** None. Orphan resolution requires judgment about which links to add.

### Step 5 — Gap Scan (25 points)

Find missing content that should exist.

**5a. Projects without overviews:**
- Each subfolder in `10 - Projects/` should have at least one overview or index file
- Check for `_index.md`, `Overview.md`, or a file matching the folder name
- Severity: Warning (-2 each)

**5b. Referenced-but-nonexistent notes:**
- Same as broken wikilinks from Step 4b (counted here too for the gap dimension)
- Severity: Warning (-2 each, max -10)

**5c. Empty folders:**
- Subfolders in `10 - Projects/`, `20 - Areas/` with zero `.md` files
- Severity: Info (-1 each)

**5d. Missing frontmatter:**
- Notes without required fields (`title`, `date`, `type`, `status`, `tags`)
- Severity: Info (-1 each, max -10)

**Auto-fix (safe):** Add missing `status: active` to notes that have all other frontmatter fields. Log all changes.

### Step 6 — Compute Health Score

Sum the four dimension scores:

```
Health Score = Contradictions + Staleness + Orphans + Gaps
```

**Interpretation:**
| Score | Rating | Meaning |
|-------|--------|---------|
| 90-100 | Excellent | Vault is well-maintained |
| 70-89 | Good | Minor issues to address |
| 50-69 | Fair | Several areas need attention |
| 25-49 | Poor | Significant maintenance needed |
| 0-24 | Critical | Vault health is severely degraded |

### Step 7 — Generate Lint Report

Write to `40 - Daily/YYYY-MM-DD Vault Lint.md`:

```markdown
---
title: "YYYY-MM-DD Vault Lint"
date: "YYYY-MM-DD"
type: daily
status: active
tags: [daily, vault-lint]
---

# YYYY-MM-DD Vault Lint Report

## Health Score: XX/100 — [Rating]

| Dimension | Score | Issues |
|-----------|-------|--------|
| Contradictions | XX/25 | N issues |
| Staleness | XX/25 | N issues |
| Orphans | XX/25 | N issues |
| Gaps | XX/25 | N issues |

## Contradictions

### Critical
- [[Note A]] vs [[Note B]] — [description of conflict]

### Warnings
- [[Note Name]] — status mismatch: [details]

## Staleness

### Stale Active Notes (not modified in 14+ days)
- [[Note Name]] — last modified YYYY-MM-DD (N days ago)

### Expired TODOs
- [[Note Name]] — "TODO item text" (due YYYY-MM-DD)

## Orphan Notes (no inbound links)

- [[Note Name]] (10 - Projects/)
- [[Note Name]] (30 - Notes/)

### Broken Wikilinks
- [[Non-existent Note]] — referenced in [[Source Note]]

## Content Gaps

### Projects Without Overviews
- 10 - Projects/ProjectName/ — no overview file found

### Missing Frontmatter
- [[Note Name]] — missing: type, tags

## Auto-Fixes Applied
- [[Note Name]] — corrected date in frontmatter (2026-03-62 → 2026-03-26)
- [[Note Name]] — added status: active (was missing)

(Write "No auto-fixes needed" if none were applied)

## Recommended Actions
1. [Highest priority action based on score]
2. [Second priority]
3. [Third priority]
```

### Step 8 — Report to User

Display a summary in the terminal:

```
Vault Lint Complete
===================

Health Score: XX/100 (Rating)

  Contradictions:  XX/25
  Staleness:       XX/25
  Orphans:         XX/25
  Gaps:            XX/25

Auto-fixes applied: N
Issues requiring attention: N

Full report: $VAULT_PATH/40 - Daily/YYYY-MM-DD Vault Lint.md

Top 3 recommended actions:
1. [action]
2. [action]
3. [action]
```

## Guidelines

1. **Conservative auto-fix** — Only fix mechanical issues where the correct value is unambiguous (date typos, missing status field). Never rewrite content, merge notes, or delete anything.
2. **Log everything** — Every auto-fix must be recorded in the report with before/after values.
3. **Exempt folders** — `40 - Daily/` and `99 - Archive/` are exempt from orphan checks. `Templates/` is exempt from all checks.
4. **Performance** — For vaults with 500+ notes, limit contradiction scanning to notes modified in the last 90 days. Report the scan scope in the output.
5. **Idempotent** — Running multiple times on the same day appends to the existing report rather than overwriting.

## Related Skills

- [[daily-review]] — Addresses issues found by lint (moving notes, adding wikilinks)
- [[weekly-review]] — Includes a lint health summary in its report
- [[monthly-review]] — Uses lint data for the content quality scan
- [[recall]] — Helps find notes to resolve broken wikilinks
