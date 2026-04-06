---
name: recall
description: "Search vault by keyword with relevance scoring. Supports temporal filters, timeline mode, and active-topics mode."
category: query
depends_on: []
triggers:
  - "/recall [keyword]"
  - "search notes"
  - "find notes"
  - "recall"
  - "have I written about"
output_type: search-results
cost: low
---

# Recall — Obsidian Note Search

Quickly find relevant notes in the vault by keyword, scored and ranked.

> Configure your vault path in setup.sh or set the `VAULT_PATH` environment variable.

**Search and display only — never move or modify any notes.**

**Vault:** `$VAULT_PATH`

## Supported Modes

| Mode | Syntax | Description |
|------|--------|-------------|
| Basic search | `/recall keyword` | Standard keyword search with scoring |
| Temporal filter | `/recall keyword --since 2w` | Filter by time (e.g., `--since 1m`, `--month 2026-03`, `--between 2026-01 2026-03`) |
| Timeline | `/recall keyword --timeline` | ASCII activity chart showing note frequency over time |
| Active topics | `/recall --active-topics` | Top tags across the vault, ranked by frequency |

## Process

### Step 1 — Understand Search Intent

Analyze the user's keyword and expand into 2-5 related search terms.

Examples:
- `/recall deployment` → "deployment", "deploy", "CI/CD", "shipping", "release"
- `/recall database` → "database", "DB", "SQL", "Prisma", "schema"

**Temporal parsing:**
- `--since 2w` → filter notes modified within the last 2 weeks
- `--since 1m` → last month
- `--month 2026-03` → notes from March 2026
- `--between 2026-01 2026-03` → notes from January to March 2026

### Step 2 — Full Vault Search

**Search the entire vault at once, not folder by folder.** Use 3 methods in parallel for each search term:

1. **Filename** — Glob tool:
   ```
   Glob: pattern = "**/*keyword*", path = "$VAULT_PATH"
   ```

2. **Tags** — Grep tool:
   ```
   Grep: pattern = "tags:.*keyword", path = "$VAULT_PATH", glob = "**/*.md", -i = true
   ```

3. **Content** — Grep tool (fetch context directly):
   ```
   Grep: pattern = "keyword", path = "$VAULT_PATH", glob = "**/*.md", -i = true, output_mode = "content", -C = 2, head_limit = 50
   ```

**Run all search terms in parallel.** If results exceed 50 notes, take only the top 10 matches per method.

**Quality field:** For files in the results, check for a `quality:` frontmatter field. If present, note the value (high/medium/low) for Step 3 scoring.

**Temporal filter:** If `--since`, `--month`, or `--between` is specified, exclude notes whose `date:` frontmatter falls outside the range.

### Step 2.5 — Semantic Search (Optional)

If a `semantic_search` tool is available (e.g., vault-semantic-search MCP server):

1. Call `semantic_search(query=user's search terms, top_k=10)`
2. Add results to the Step 3 candidate pool, tagged as "semantic match"
3. Semantic search finds notes using different wording but the same concept

If the `semantic_search` tool is **not available**, skip this step silently.

### Step 3 — Score and Rank

Deduplicate all results, then score:

| Condition | Score |
|-----------|-------|
| Filename match | +3 |
| Tags match | +2 |
| Content match (+1 per distinct search term, max +3) | +1 to +3 |
| Located in `30 - Notes/` | +2 bonus |
| Located in `10 - Projects/` | +1 bonus |
| Recently modified (within 30 days) | +1 bonus |
| `quality: high` | +3 bonus |
| `quality: medium` | +1 bonus |
| `quality: low` | +0 |
| semantic_search score > 0.7 | +4 bonus |
| semantic_search score 0.5-0.7 | +2 bonus |

Take the Top 10. Break ties by folder priority: `30 > 10 > 20 > 00 > 40 > 99`.

### Step 4 — Display Results

For each Top 10 note, distill a one-sentence key insight from the Step 2 Grep content results (no need to Read unless context is insufficient).

**Standard mode:**
```
/recall [keyword] results

Found N related notes:

Most Relevant
1. [[Note Name]] (30 - Notes) — X pts
   > [One-sentence key insight]

2. [[Note Name]] (10 - Projects/XXX) — X pts
   > [One-sentence summary]

3. [[Note Name]] (20 - Areas/YYY) — X pts
   > [One-sentence summary]

Other Related
4-10. ...

Related Note Network
[[Note A]] <-> [[Note B]] (based on wikilinks)

Suggestion: [specific actionable suggestion]
```

**Timeline mode (`--timeline`):**
```
/recall [keyword] — Timeline

Activity for "keyword" (past 6 months):

2026-04  ████████  8 notes
2026-03  ████       4 notes
2026-02  ██         2 notes
2026-01               0 notes
2025-12  █           1 note
2025-11  ███         3 notes

Peak: 2026-04 (8 notes)
Total: 18 notes mentioning "keyword"
```

**Active topics mode (`--active-topics`):**
```
/recall --active-topics

Top 10 Active Topics (past 30 days):

1. deployment (12 mentions across 8 notes)
2. testing (9 mentions across 6 notes)
3. design-system (7 mentions across 5 notes)
...
```

### Step 5 — Follow-up Actions

```
Available actions:
- Enter a note number to view full content
- /recall [another keyword] to search a different topic
- /daily-review to process related Inbox notes
```

When the user enters a number, Read and display the corresponding note in full.

## Edge Cases

- **0 results:** Suggest 2-3 similar keywords to retry
- **Non-ASCII search terms:** Grep supports them natively
- **Missing folders:** Skip silently, do not error

## Guidelines

- **Read-only** — Never modify, move, or delete notes
- Keep technical terms in English
- Case-insensitive search
- Wikilinks use `[[Note Name]]` without the `.md` extension

## Related Skills

- [[daily-review]] — Process notes found in search results
- [[weekly-review]] — Surfaces resurfacing opportunities for older notes
- [[vault-lint]] — Find orphan notes that recall might miss
