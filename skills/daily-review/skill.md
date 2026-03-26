---
name: daily-review
description: Use when Obsidian Inbox has notes to process - splits multi-topic notes into atomic pieces, classifies and moves to correct vault location. Triggers on "/daily-review", "process inbox", "review inbox", "organize notes"
---

# Daily Review

Process notes in `00 - Inbox/`: split multi-topic notes into atomic pieces, classify, and move to the correct location.

**Core principle: one topic/idea = one note.**

## Constants

- **Vault**: `{{VAULT}}`
- **Today's date**: obtain via `date +%Y-%m-%d`

## Process

### Step 1 — Scan Inbox

Use Bash `ls` to list all `.md` files in `00 - Inbox/`.

- Skip `_index.md`
- If Inbox is empty, notify the user "Inbox is clear, nothing to process" and stop
- Show the user a list of notes with filenames and a one-line summary of each

### Step 2 — Build Vault Context

Before classifying, survey the existing vault structure. Results from this step are reused in all subsequent classification, wikilink, and move steps.

1. `ls` to scan subfolders and filenames in `10 - Projects/`, `20 - Areas/`, `30 - Notes/`
2. For each project subfolder, read the Overview / main file (if any) to understand project scope
3. Cache this structure — no need to rescan later

### Step 3 — Read Inbox Notes

Use the Read tool to read the full content (frontmatter + body) of each Inbox note.

**Reading order: short notes first (body < 20 lines), long notes after.**

Short notes are usually single-topic and can be processed quickly; long notes (session logs, research docs) usually need splitting.

### Step 4 — Split Multi-Topic Notes

For each note, determine whether it needs splitting.

**Signals that splitting is needed:**
- Title contains `+` or comma-like delimiters joining multiple topics
- Content has multiple `##`/`###` sections covering entirely different subjects
- Session log records multiple independent tasks

**No split needed when:**
- There is only one core topic (sub-sections all relate to the same thing)
- Body is fewer than 5 lines
- Already an atomic note (`type: note`)

**Splitting workflow:**

1. Identify independent topics and extract each into a new note
2. New note format:
   - Filename: `YYYY-MM-DD Topic Title.md` (reuse the original note's date)
   - Frontmatter:
     ```yaml
     title: "Topic Title"
     date: "original note date"
     type: {{determined by content}}
     status: active
     tags: [inbox, {{relevant tags}}]
     source_note: "[[original note name]]"
     ```
   - Body: extract relevant content from the original note — **preserve original text, do not rewrite or summarize**
   - Add a `## Related` section at the bottom linking back to the original note and other split notes
3. Handle the original note:
   - Update frontmatter: change first tag to `archive`, set status to `archived`
   - Add a `## Split Notes` section at the bottom listing all child note wikilinks
   - Move to `99 - Archive/Sessions/`
4. Use the Write tool to create child notes (write to Inbox first before moving to final destination)
5. **Use the Read tool to re-read each child note and verify content is complete with nothing missing**
6. After verification passes, child notes proceed to Step 5 for classification

**Notes:**
- If the original note has an "Incomplete / Follow-up" section, assign each follow-up to the relevant child note
- Cross-topic content (e.g., comparison tables) should be copied to all relevant notes
- **Duplicate filename guard**: before writing, check if a file with the same name exists at the target path; if so, append ` (2)` to the filename

### Step 5 — Three-Question Decision Tree Classification

For each note (original single-topic notes + child notes from Step 4), run the decision tree:

**Pre-classification rule:**
- `source: "Claude Code Session"` AND Step 4 determined no split needed → move directly to `99 - Archive/Sessions/`, skip the three questions

**Q1: Does it have a deadline or a clear endpoint?** → Yes → `10 - Projects/{project name}/`
**Q2: Is it an ongoing area of responsibility?** → Yes → `20 - Areas/{area name}/`
**Q3: Is it a standalone idea or insight?** → Yes → `30 - Notes/`
**None of the above** → keep in `00 - Inbox/`

Use the vault context from Step 2 to determine the specific project/area subfolder.

**Confidence threshold:**
- `>80%` → auto-move, record in report
- `≤80%` → add to confirmation list (Step 7)

For each note, record: `filename`, `destination`, `confidence`, `reason`, `new_title` (only needed for Notes)

### Step 6 — Add Wikilinks

Using the vault context from Step 2 (no rescan needed), for each note to be moved:

1. Compare content to find semantically related existing notes
2. Add a `## Related` section at the bottom of the note body with `[[note name]]` wikilinks
3. If the note already has sufficient wikilinks, do not add more

**Only add meaningful links — do not add links for the sake of it.**

### Step 6.5 — Quality Grading

For each note being moved (excluding those going to Archive), automatically determine a quality grade and write it into the frontmatter.

**Grading rules:**

| quality | Criteria (meeting any one is sufficient) |
|---------|----------------------------------------|
| `high` | Contains decision records, technical details, or original insights; wikilinks >= 3; word count > 300 with structure (>= 3 sections) |
| `medium` | Has structure (>= 2 sections); word count 100-300; has frontmatter with tags >= 2 |
| `low` | Pure clipboard paste / no structure / fewer than 100 words / frontmatter missing fields |

**Execution:** Use the Edit tool to add `quality: high/medium/low` to the frontmatter (insert after `status:`).

**Notes:**
- Notes going to `99 - Archive/` do not need quality grading
- Notes that already have a `quality` field should not be overwritten

### Step 7 — Execute Moves (Auto Portion)

Execute moves for all notes with confidence >80%.

**Standard move pattern:**
1. Confirm the target folder exists (if not → `mkdir -p`)
2. **Duplicate filename guard**: check if target has a file with the same name
3. Use the Edit tool to update the first value in frontmatter tags (see table below)
4. Use Bash `mv` to move

| Destination | First tag value | status | Additional action |
|-------------|----------------|--------|-------------------|
| `10 - Projects/{name}/` | `projects` | unchanged | — |
| `20 - Areas/{name}/` | `areas` | unchanged | — |
| `30 - Notes/` | `notes` | unchanged | Rewrite title as an assertion (keyword → opinion statement) |
| `99 - Archive/Sessions/` | `archive` | `archived` | — |

**Move command:**
```bash
mv "{{VAULT}}/source/filename.md" "{{VAULT}}/destination/new_filename.md"
```

### Step 8 — Confirmation List

If any notes have confidence ≤80%, present a list:

```
The following notes need your decision on where to file them:

1. "Note Title" — [one-line summary]
   Suggestion: 10 - Projects/XXX (because...)
   Options: a) Projects/XXX  b) Areas/YYY  c) Notes  d) Keep in Inbox

2. ...
```

Wait for user response, then execute moves (same flow as Step 7). If all notes were auto-moved, skip this step.

### Step 8.5 — Update MOC (Map of Content)

For each folder that received notes in this session, update (or create) its `_index.md`.

**Workflow:**
1. List all `.md` files in the folder (excluding `_index.md`)
2. For each note, read frontmatter `title`, `date`, `quality`, plus distill a one-line summary (<= 20 words) from the opening paragraph
3. Sort by date in descending order
4. Use the Write tool to write `_index.md` (overwrite the old version):

```markdown
# {Folder Name}

> Auto-generated, last updated: YYYY-MM-DD

| Note | Date | Quality | Summary |
|------|------|---------|---------|
| [[Note Name]] | 2026-03-26 | high | One-line summary |
| [[Note Name]] | 2026-03-25 | medium | One-line summary |

Total: N notes
```

**Notes:**
- Only update folders that received notes in this session — do not update the entire vault
- Subfolders (e.g., `TEC - TechPulse/`) have their own `_index.md` — do not mix with parent folder
- `99 - Archive/` does not need a MOC
- `40 - Daily/` does not need a MOC
- Summaries should be distilled from note content — **do not simply copy the frontmatter title** (titles are often too brief)

### Step 9 — Generate Daily Report

Write to `40 - Daily/YYYY-MM-DD Daily Review.md`. If it already exists, use the Edit tool to append.

```markdown
---
title: "YYYY-MM-DD Daily Review"
date: "YYYY-MM-DD"
type: daily
status: active
tags: [daily, review]
---

# YYYY-MM-DD Daily Review

## Inbox Processing
Processed N notes

| Note | Destination | Remarks |
|------|-------------|---------|
| [[note name]] | target folder | auto / pending confirmation |

## Split Notes
(If none, write "No notes needed splitting")

| Original Note | Split Into |
|---------------|------------|
| [[original note name]] | [[child note A]], [[child note B]] |

## Confirmation Results
(If none, write "All notes processed automatically")

## New Wikilinks
- [[Note A]] linked to → [[Note B]]

## Orphan Note Reminders
The following notes have no wikilinks — consider adding connections:
- [[note name]]
```

**Note:** Confirm `40 - Daily/` exists before writing.

## Important Rules

1. **Do not rewrite note content** — only modify frontmatter (title, tags, status) and add wikilinks; when splitting, extract original text as-is — do not summarize or rewrite
2. **Use `mv` for moves** — do not copy + delete
3. **Assertion titles** — only rewrite titles for notes going to `30 - Notes/` (e.g., "Git Hooks" → "Git Hooks can automate pre-commit checks")
4. **Preserve frontmatter** — do not delete any existing fields when moving
5. **Create folders if missing** — `mkdir -p`
6. **Duplicate filename guard** — before moving or writing, check if a file with the same name exists at the target; if so, append ` (2)` to the filename
7. **Idempotency** — running multiple times on the same day causes no issues: Daily Report appends without overwriting, already-moved notes do not reappear in Inbox
