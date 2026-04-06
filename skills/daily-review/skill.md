---
name: daily-review
description: "Process inbox notes: detect raw clips, compile into atomic notes, split multi-topic notes, classify and move to correct vault folders"
category: knowledge-compilation
depends_on: []
triggers:
  - "/daily-review"
  - "process inbox"
  - "review inbox"
  - "organize notes"
output_type: report
cost: medium
---

# Daily Review — Knowledge Compilation

Process `00 - Inbox/` notes: detect raw clips, compile into atomic notes, split multi-topic entries, classify, and move to the correct vault location.

> Configure your vault path in setup.sh or set the `VAULT_PATH` environment variable.

**Core principle: one topic or idea = one note.**

## Constants

- **Vault**: `$VAULT_PATH`
- **Today**: use `date +%Y-%m-%d` to determine

## Process

### Step 1 — Scan Inbox

Use Bash `ls` to list all `.md` files in `00 - Inbox/`.

- Skip `_index.md`
- If the inbox is empty, inform the user and stop
- Display the note list with filenames and a first-line content summary

### Step 2 — Build Vault Context

Before classifying, understand the existing vault structure. The results of this step feed into all subsequent classification, wikilink, and move steps.

1. `ls` to scan `10 - Projects/`, `20 - Areas/`, `30 - Notes/` subfolders and filenames
2. For each project subfolder, read the Overview or main file (if one exists) to understand project scope
3. Retain this structure in memory — do not re-scan later

### Step 3 — Read Inbox Notes

Use the Read tool to read the full content (frontmatter + body) of each inbox note.

**Read order: short notes first (body < 20 lines), long notes second.**

Short notes are typically single-topic and can be processed quickly. Long notes (session logs, research documents) usually need splitting.

### Step 3.5 — Raw Clip Detection and Knowledge Compilation

Detect notes created by Obsidian Web Clipper or similar tools and compile them into atomic notes.

**Detection signals:**
- Frontmatter contains `source:` with a URL
- Tags include `clipping`, `web-clip`, or `raw`
- Body contains large blocks of unformatted article text
- Filename starts with a URL-style or article title pattern

**Compilation process (Karpathy Ingest pattern):**

For each detected raw clip:

1. **Extract key points** — Identify the 3-7 most important claims, insights, or facts from the article
2. **Create atomic notes** — For each key point, generate a note with:
   - Assertion-style title (e.g., "Transformer attention scales quadratically with sequence length")
   - Filename: `YYYY-MM-DD Assertion Title.md`
   - Frontmatter:
     ```yaml
     title: "Assertion Title"
     date: "YYYY-MM-DD"
     type: note
     status: active
     tags: [inbox, topic1, topic2]
     source_note: "[[Original Clip Name]]"
     source_url: "original article URL"
     ```
   - Body: the relevant excerpt from the article, plus a brief contextual note
   - `## Related` section with wikilinks to existing vault notes on the same topic
3. **Discover wikilinks** — For each atomic note, scan the vault context (Step 2) and find semantically related existing notes. Add them as `[[wikilinks]]` in the Related section.
4. **Archive the original clip** — Update the clip's frontmatter: set `status: archived`, first tag to `archive`. Add a `## Compiled Notes` section listing all generated atomic notes. Move to `99 - Archive/`.

**Skip compilation if:**
- The clip is already short (< 200 words) and single-topic — treat as a regular inbox note
- The clip has already been processed (check for `status: archived`)

Compiled notes proceed to Step 5 for classification.

### Step 4 — Split Multi-Topic Notes

For each note, determine whether it needs splitting.

**Signals that splitting is needed:**
- Title contains `+` or `,` connecting multiple topics
- Content has multiple `##`/`###` sections covering unrelated subjects
- Session log records multiple independent tasks

**Do not split when:**
- Only one core topic (sub-sections revolve around the same subject)
- Body is fewer than 5 lines
- Already an atomic note (`type: note`)

**Splitting process:**

1. Identify independent topics and extract each into a new note
2. New note format:
   - Filename: `YYYY-MM-DD Topic Title.md` (use the original note's date)
   - Frontmatter:
     ```yaml
     title: "Topic Title"
     date: "original note date"
     type: determined-by-content
     status: active
     tags: [inbox, relevant-tags]
     source_note: "[[Original Note Name]]"
     ```
   - Body: extracted content from the original note — **preserve the original text, do not rewrite or summarize**
   - Bottom `## Related` section linking back to the original and other split notes
3. Update the original note:
   - Change frontmatter: first tag to `archive`, status to `archived`
   - Add a `## Split Notes` section listing all child note wikilinks
   - Move to `99 - Archive/Sessions/`
4. Write child notes using the Write tool (initially into Inbox)
5. **Read back each child note to verify completeness**
6. Verified child notes proceed to Step 5

**Notes:**
- If the original has a "Follow-up" section, assign each item to the relevant child note
- Cross-topic content (e.g., comparison tables) should be copied into all relevant notes
- **Duplicate filename guard**: before writing, check if a file with the same name exists at the target; if so, append ` (2)` to the filename

### Step 5 — Three-Question Decision Tree Classification

For each note (original single-topic notes + child notes from Steps 3.5 and 4), apply the decision tree:

**Pre-rule:**
- `source: "Claude Code Session"` and not split in Step 4 → move directly to `99 - Archive/Sessions/`, skip the three questions

**Q1: Does it have a deadline or clear endpoint?** → Yes → `10 - Projects/{project-name}/`
**Q2: Is it an ongoing area of responsibility?** → Yes → `20 - Areas/{area-name}/`
**Q3: Is it a standalone idea or insight?** → Yes → `30 - Notes/`
**None of the above** → Keep in `00 - Inbox/`

Use the vault context from Step 2 to determine the specific project/area subfolder.

**Confidence threshold:**
- `>80%` → move automatically, log in report
- `<=80%` → add to the confirmation list (Step 8)

Record for each note: `filename`, `destination`, `confidence`, `reason`, `new_title` (only for Notes)

### Step 6 — Add Wikilinks

Using the vault context from Step 2 (no re-scanning), for each note being moved:

1. Compare content to find semantically related existing notes
2. Add a `## Related` section at the bottom with `[[Note Name]]` wikilinks
3. If the note already has sufficient wikilinks, do not add more

**Only add meaningful links — do not add links for the sake of it.**

### Step 6.5 — Quality Scoring

For each note being moved (excluding those going to Archive), assign a quality grade in frontmatter.

**Scoring rules:**

| Quality | Criteria (any one is sufficient) |
|---------|----------------------------------|
| `high` | Contains decision records, technical details, or original insights; wikilinks >= 3; word count > 300 with structure (>= 3 sections) |
| `medium` | Has structure (>= 2 sections); word count 100-300; has frontmatter with tags >= 2 |
| `low` | Pure clipboard paste / no structure / fewer than 100 words / missing frontmatter fields |

**Execution:** Use the Edit tool to add `quality: high/medium/low` in frontmatter (after `status:`).

**Notes:**
- Notes going to `99 - Archive/` do not need quality scoring
- Do not overwrite an existing `quality` field

### Step 7 — Execute Moves (Automatic)

Move all notes with confidence >80%.

**Standard move pattern:**
1. Confirm the target folder exists (create with `mkdir -p` if not)
2. **Duplicate filename guard**: check for existing files with the same name
3. Use the Edit tool to update the first frontmatter tag (see table below)
4. Use Bash `mv` to move

| Destination | First tag | Status | Additional action |
|-------------|-----------|--------|-------------------|
| `10 - Projects/{name}/` | `projects` | unchanged | — |
| `20 - Areas/{name}/` | `areas` | unchanged | — |
| `30 - Notes/` | `notes` | unchanged | Rewrite title as an assertion statement |
| `99 - Archive/Sessions/` | `archive` | `archived` | — |

**Move command:**
```bash
mv "$VAULT_PATH/source/filename.md" "$VAULT_PATH/destination/new-filename.md"
```

### Step 8 — Confirmation List

If any notes have confidence <=80%, display a list:

```
The following notes need your decision:

1. "Note Title" — [one-line summary]
   Suggestion: 10 - Projects/XXX (because...)
   Options: a) Projects/XXX  b) Areas/YYY  c) Notes  d) Keep in Inbox

2. ...
```

Wait for the user's response, then execute moves (same process as Step 7). If all notes were automatic, skip this step.

### Step 8.5 — Update MOC (Map of Content)

For each folder that received notes in this session, update (or create) `_index.md`.

**Process:**
1. List all `.md` files in the folder (excluding `_index.md`)
2. For each file, read frontmatter `title`, `date`, `quality`, and extract a one-sentence summary (<= 20 words) from the first paragraph
3. Sort by date descending
4. Write `_index.md` using the Write tool (overwrite previous version):

```markdown
# {Folder Name}

> Auto-generated, last updated: YYYY-MM-DD

| Note | Date | Quality | Summary |
|------|------|---------|---------|
| [[Note Name]] | 2026-03-26 | high | One-sentence summary |
| [[Note Name]] | 2026-03-25 | medium | One-sentence summary |

Total: N notes
```

**Notes:**
- Only update folders that received notes — do not refresh the entire vault
- Subfolders (e.g., `Projects/MyApp/`) have their own `_index.md`
- `99 - Archive/` does not need a MOC
- `40 - Daily/` does not need a MOC
- Summaries should be distilled from content, **not copied from the frontmatter title**

### Step 9 — Generate Daily Report

Write to `40 - Daily/YYYY-MM-DD Daily Review.md`. If the file already exists, use the Edit tool to append.

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
| [[Note Name]] | Target folder | auto/confirmed |

## Raw Clip Compilation
(If none: "No raw clips processed")

| Original Clip | Compiled Notes |
|---------------|----------------|
| [[Clip Name]] | [[Atomic Note A]], [[Atomic Note B]] |

## Split Notes
(If none: "No notes needed splitting")

| Original | Split Into |
|----------|-----------|
| [[Original Name]] | [[Child A]], [[Child B]] |

## Pending Confirmations
(If none: "All processed automatically")

## New Wikilinks
- [[Note A]] linked to → [[Note B]]

## Orphan Note Reminder
The following notes have no wikilinks — consider adding connections:
- [[Note Name]]
```

## Guidelines

1. **Do not rewrite note content** — Only modify frontmatter (title, tags, status) and add wikilinks. When splitting, extract original text without summarizing.
2. **Move with `mv`** — Do not copy + delete.
3. **Assertion-style titles** — Only for notes going to `30 - Notes/` (e.g., "Git Hooks" becomes "Git hooks can automate pre-commit checks").
4. **Preserve frontmatter** — Never delete existing fields when moving.
5. **Create missing folders** — Use `mkdir -p`.
6. **Duplicate filename guard** — Check before writing or moving; append ` (2)` if collision.
7. **Idempotent** — Running multiple times on the same day causes no harm: daily report is appended (not overwritten), already-moved notes do not reappear in Inbox.

## Related Skills

- [[session-to-obsidian]] — Creates the inbox notes this skill processes
- [[recall]] — Search for notes after they have been filed
- [[vault-lint]] — Health check complements daily review
- [[weekly-review]] — Aggregates daily review outcomes
- [[process-raw]] — Standalone raw clip processing (this skill includes it inline)
