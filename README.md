# claude-obsidian — Knowledge Compilation Skills for Claude Code

Turn your Obsidian vault into a self-maintaining knowledge base. Inspired by [Karpathy's LLM Wiki](https://x.com/karpathy/status/1927101613498171681) architecture, these skills let Claude Code act as your **knowledge compiler** — ingesting raw content, maintaining structured notes, and continuously checking vault health.

[繁體中文版](README.zh-TW.md)

## Architecture

```
Raw Sources          Knowledge Compilation          Maintenance
(Web Clips,    -->   (Daily Review +          -->   (Vault Lint +
 Sessions)           Session-to-Obsidian)            Weekly/Monthly Review)
     |                       |                              |
  Inbox/raw/          Atomic Notes with              Health Score /100
  Inbox/               Wikilinks                    + Contradiction Check
                                                    + Staleness Detection
```

## Three Operations

From Karpathy's LLM Wiki model, this skill set implements three core operations:

### Ingest

`/daily-review` processes your inbox and raw clips into atomic notes. Web Clipper articles are detected automatically, broken into assertion-titled atomic notes with key points extraction, and woven into your knowledge graph via wikilink discovery. Multi-topic session logs are split into standalone notes. Everything is classified through a three-question decision tree (Projects / Areas / Notes / Archive).

### Query

`/recall` searches your vault with three-way parallel search (filename + tags + content), relevance scoring, temporal filters (`--since 2w`, `--month 2026-03`), timeline mode (ASCII activity chart), and active-topics mode.

### Lint

`/vault-lint` scans for contradictions, staleness, orphans, and content gaps across four dimensions, each scored out of 25 for a total Health Score out of 100. Safe mechanical issues are auto-fixed; everything else is report-only.

## Skills

| Skill | Command | Description |
|-------|---------|-------------|
| **Daily Review** | `/daily-review` | Process inbox: detect raw clips, compile atomic notes, split multi-topic entries, classify and move |
| **Session to Obsidian** | `/session-to-obsidian` | Save the current Claude Code session as a structured Obsidian note |
| **Recall** | `/recall [keyword]` | Search vault by keyword with relevance scoring, temporal filters, and timeline mode |
| **Weekly Review** | `/weekly-review` | Weekly knowledge accumulation analysis with resurfacing and health summary |
| **Monthly Review** | `/monthly-review` | Monthly deep review with knowledge drift analysis, merge suggestions, and archival |
| **Vault Lint** | `/vault-lint` | Health Score /100: contradictions, staleness, orphans, gaps |
| **Obsidian Connect** | `/obsidian-connect` | Verify vault connection and troubleshoot access issues |

## Recommended Workflow

```
Daily:    /session-to-obsidian  →  /daily-review
Weekly:   /weekly-review
Monthly:  /monthly-review
Ad hoc:   /recall [keyword]
On demand: /vault-lint
```

1. **Capture** — After each working session, run `/session-to-obsidian` to save a structured summary to your vault's inbox.
2. **Compile** — Run `/daily-review` to ingest raw clips into atomic notes, split multi-topic entries, classify, and file everything into the correct folders.
3. **Query** — Use `/recall` anytime to find notes by keyword, with scoring, temporal filters, or timeline view.
4. **Review** — Use `/weekly-review` at the end of each week for accumulation trends and resurfacing. Use `/monthly-review` for drift analysis and deep cleanup.
5. **Lint** — Run `/vault-lint` periodically to catch contradictions, stale notes, orphans, and content gaps before they accumulate.

## Vault Structure

The skills expect an Obsidian vault organized with these folders (created automatically by `setup.sh`):

| Folder | Purpose |
|--------|---------|
| `00 - Inbox/` | Entry point for all new notes and raw clips |
| `01 - Active/` | Notes you work with daily (5-10 max) |
| `10 - Projects/` | Time-bound projects with deadlines |
| `20 - Areas/` | Ongoing areas of responsibility |
| `30 - Notes/` | Atomic notes (one idea per note, assertion-style titles) |
| `40 - Daily/` | Daily journal, review reports, lint reports |
| `99 - Archive/` | Completed or retired notes; `Sessions/` subfolder for processed logs |

**Note naming:** `YYYY-MM-DD Title.md` (date prefix required)

**Frontmatter format:**
```yaml
---
title: "Note Title"
date: "2026-03-26"
type: dev-session    # fleeting | project | note | daily | dev-session | learning | work-journal | idea
status: active       # active | completed | archived
tags: [inbox, topic1, topic2]
---
```

For detailed structure documentation, see [docs/vault-structure.md](docs/vault-structure.md).

## Configuration

All skills use `$VAULT_PATH` to locate your Obsidian vault. Set it up in one of two ways:

### Option 1: Run setup.sh (recommended)

```bash
bash setup.sh
```

The script will prompt for your vault path, save it to `skills/.vault-config`, install all skills to `~/.claude/skills/`, and create required vault folders.

### Option 2: Environment variable

```bash
export VAULT_PATH="/path/to/your/obsidian/vault"
```

Add this to your shell profile (`.bashrc`, `.zshrc`, etc.) for persistence.

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/kalawcreator919/claude-obsidian.git

# 2. Run setup
cd claude-obsidian
bash setup.sh

# 3. Restart Claude Code — skills are ready
```

After setup, try:
- `/obsidian-connect` — verify your vault is accessible
- `/session-to-obsidian` — save your first session
- `/daily-review` — process your inbox
- `/vault-lint` — check your vault health

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [Obsidian](https://obsidian.md/) desktop app
- Obsidian CLI (optional, requires Obsidian 1.12+) — enables direct vault commands; falls back to file system access if unavailable

## Contributing

Contributions are welcome. Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-skill`)
3. Follow the existing skill format (YAML frontmatter, Process section, Guidelines, Related Skills)
4. Test with your own vault
5. Open a pull request

## License

[MIT](LICENSE)
