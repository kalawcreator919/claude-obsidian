# claude-obsidian

Obsidian knowledge management skills for Claude Code.

Turn your Obsidian vault into a structured second brain — capture sessions, process your inbox, search your notes, and run periodic reviews, all from the Claude Code CLI.

[繁體中文版](README.zh-TW.md)

## Features

- Automatically save Claude Code sessions as Obsidian notes
- Process and classify inbox notes into the correct vault folders
- Search your vault by keyword with relevance scoring
- Run weekly and monthly knowledge reviews with drift analysis
- Verify and troubleshoot your Obsidian vault connection

## Quick Start

1. Clone the repository:

   ```bash
   git clone https://github.com/kalawcreator919/claude-obsidian.git
   ```

2. Run the setup script:

   ```bash
   cd claude-obsidian
   bash setup.sh
   ```

3. Restart Claude Code. The skills will be available immediately.

## Skills Overview

| Skill | Command | Description |
|-------|---------|-------------|
| Daily Review | `/daily-review` | Process inbox: split multi-topic notes, classify, and move to the correct folder |
| Session to Obsidian | `/session-to-obsidian` | Save the current Claude Code session as an Obsidian note |
| Recall | `/recall [keyword]` | Search vault by keyword with relevance scoring |
| Weekly Review | `/weekly-review` | Weekly knowledge accumulation analysis |
| Monthly Review | `/monthly-review` | Monthly deep review with knowledge drift analysis |
| Obsidian Connect | `/obsidian-connect` | Verify vault connection and troubleshoot issues |

## Recommended Workflow

```
Daily:    /session-to-obsidian  -->  /daily-review
Weekly:   /weekly-review
Monthly:  /monthly-review
Ad hoc:   /recall [keyword]
```

1. **Capture** -- After each working session, run `/session-to-obsidian` to save a summary to your vault's inbox.
2. **Process** -- Run `/daily-review` to split, classify, and file inbox notes into the appropriate folders.
3. **Review** -- Use `/weekly-review` at the end of each week to analyze knowledge accumulation, and `/monthly-review` for deeper trend and drift analysis.
4. **Search** -- Use `/recall` anytime to find notes by keyword.

## Vault Structure

The skills expect an Obsidian vault organized with the following folders:

| Folder | Purpose |
|--------|---------|
| `00 - Inbox/` | Entry point for all new notes |
| `01 - Active/` | Notes you work with daily (5-10 max) |
| `10 - Projects/` | Time-bound projects |
| `20 - Areas/` | Ongoing areas of responsibility |
| `30 - Notes/` | Atomic notes (one idea per note) |
| `40 - Daily/` | Daily journal and review reports |
| `99 - Archive/` | Completed or retired notes |

For more details, see [docs/vault-structure.md](docs/vault-structure.md).

## Languages

- English (default)
- Traditional Chinese (繁體中文)

Note content written to Obsidian defaults to Traditional Chinese. Skill interfaces and documentation are available in both languages.

## Requirements

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- [Obsidian](https://obsidian.md/) desktop app
- Obsidian CLI (optional, requires Obsidian 1.12+) -- enables direct vault writes; falls back to file system access if unavailable

## License

[MIT](LICENSE)
