---
name: recall
description: Use when user wants to find old Obsidian notes by keyword, topic, or project name. Triggers on "/recall [keyword]", "search notes", "find notes", "recall", "have I written about"
---

# Recall — Obsidian Note Search

Quickly find relevant notes in the vault by keyword, scored and ranked.

**Search and display only — never move or modify any notes.**

**Vault:** `{{VAULT}}`

## Process

### Step 1 — Understand Search Intent

Analyze the user's keyword and expand into 2-5 related search terms.

Examples:
- `/recall Paperclip` → "Paperclip", "AI orchestrator", "agents", "automation"
- `/recall crystal` → "crystal", "金米", "kimmi", "bracelet"

### Step 2 — Full Vault Search

**Search the entire vault at once, not folder by folder.** Use 3 methods in parallel for each search term:

1. **Filename** — Glob tool:
   ```
   Glob: pattern = "**/*keyword*", path = "{{VAULT}}"
   ```

2. **Tags** — Grep tool:
   ```
   Grep: pattern = "tags:.*keyword", path = "{{VAULT}}", glob = "**/*.md", -i = true
   ```

3. **Content** — Grep tool (fetch context directly, no need to Read afterwards):
   ```
   Grep: pattern = "keyword", path = "{{VAULT}}", glob = "**/*.md", -i = true, output_mode = "content", -C = 2, head_limit = 50
   ```

**Run all search terms in parallel.** If results are too many (>50 notes), take only the top 10 matches per method.

**Quality field:** For files in the search results, use Grep to check for a `quality:` frontmatter field. If present, note the value (high/medium/low) for use in Step 3 scoring.

### Step 2.5 — Semantic Search (if vault-semantic-search MCP is available)

If the `semantic_search` tool is available (user has the vault-semantic-search MCP server installed):

1. Call `semantic_search(query=user's search terms, top_k=10)`
2. Add results to the Step 3 candidate pool, tagged as "semantic match"
3. Semantic search can find notes that use different wording but are conceptually related (e.g., searching "managing lots of notes" finds "knowledge management optimization")

If the `semantic_search` tool is **not available** (user hasn't installed it), **skip this step** and rely on keyword search only. Do not raise an error.

### Step 3 — Score and Rank

Deduplicate all results, then score:

| Condition | Score |
|-----------|-------|
| Filename match | +3 |
| Tags match | +2 |
| Content match (+1 per distinct search term, max +3) | +1 ~ +3 |
| Located in `30 - Notes/` | +2 bonus |
| Located in `10 - Projects/` | +1 bonus |
| Recently modified (within 30 days) | +1 bonus |
| `quality: high` | +3 bonus |
| `quality: medium` | +1 bonus |
| `quality: low` | +0 |
| semantic_search score > 0.7 | +4 bonus |
| semantic_search score 0.5-0.7 | +2 bonus |

Take Top 10. Break ties by folder priority: 30 > 10 > 20 > 00 > 40 > 99.

### Step 4 — Display Results

For each Top 10 note, distill a one-sentence key insight from the Step 2 Grep content results (no need to Read unless context is insufficient).

```
🔍 `/recall [keyword]` results

Found N related notes:

**🔝 Most Relevant**
1. [[Note Name]] (30 - Notes) ⭐ X pts
   > [One-sentence key insight]

2. [[Note Name]] (10 - Projects/XXX) ⭐ X pts
   > [One-sentence summary]

3. [[Note Name]] (20 - Areas/YYY) ⭐ X pts
   > [One-sentence summary]

**📁 Other Related**
4-10. ...

**🕸️ Related Note Network**
[[Note A]] ← → [[Note B]] (based on wikilinks)

💡 Suggestion: [specific actionable suggestion]
```

### Step 5 — Follow-up Actions

```
📌 Available actions:
- Enter a note number to view full content
- `/recall [another keyword]` to search a different topic
- `/daily-review` to process related Inbox notes
```

When the user enters a number, Read and display the corresponding note in full.

## Edge Cases

- **0 results:** Suggest 2-3 similar keywords to retry
- **Chinese search terms:** Grep supports them natively
- **Missing folders:** Skip silently, do not error

## Guidelines

- **Read-only** — never modify, move, or delete notes
- Summaries in the user's language; keep technical terms in English
- Case insensitive search
- `[[Note Name]]` without `.md` extension
