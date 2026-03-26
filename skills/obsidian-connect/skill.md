---
name: obsidian-connect
description: Use when connecting to Obsidian, verifying vault access, or troubleshooting Obsidian CLI issues
---

# Obsidian Connect

Verify Obsidian vault connection. Prefer CLI; fall back to Read/Write/Edit tools.

## When to Use

- User requests to connect to Obsidian
- Obsidian CLI commands fail
- Verifying vault access

## Connection

**Vault:** `{{VAULT}}`
**Method:** Obsidian CLI (requires Obsidian 1.12+ running + Settings → General → CLI enabled)

### Verify Connection

```bash
obsidian read vault="Obsidian" file="Home"
```

On success, returns the contents of Home.md. On failure, try the fallback method.

## CLI Commands

| Action | Command |
|--------|---------|
| Read | `obsidian read vault="Obsidian" file="<name>"` |
| Create | `obsidian create vault="Obsidian" name="YYYY-MM-DD Title" content="..."` |
| Append | `obsidian append vault="Obsidian" file="<name>" content="..."` |
| Search | `obsidian search vault="Obsidian" query="keyword"` |
| Daily note | `obsidian daily vault="Obsidian"` |
| Tasks | `obsidian tasks vault="Obsidian" todo` |

**Windows note:** Use `Obsidian.com` (not `Obsidian.exe`) for correct stdin/stdout handling.

**Content format:** Quote values containing spaces. Use `\n` for newlines, `\t` for tabs.

## Steps

1. Run `obsidian read vault="Obsidian" file="Home"` to test the connection
2. Success: report that the connection is working
3. Failure: check the following
   - Is Obsidian desktop running?
   - Is CLI enabled? (Settings → General → Command line interface)
   - Is the version 1.12+?
   - On Windows, are you using `Obsidian.com`?

## Fallback (when CLI is unavailable)

Use Read/Write/Edit tools to operate on vault markdown files directly:

```
Read: {{VAULT}}\00 - Inbox\note-name.md
Write: {{VAULT}}\00 - Inbox\new-note.md
Edit: {{VAULT}}\30 - Notes\existing-note.md
```

## Common Mistakes

| Problem | Cause | Solution |
|---------|-------|----------|
| Unable to connect to main process | Obsidian not running or CLI not enabled | Launch Obsidian + enable CLI setting |
| Command not found | CLI not in PATH | Windows: confirm using `Obsidian.com` |
| Colon subcommand not working | Windows Git Bash parses `:` as a drive path | Use `MSYS_NO_PATHCONV=1` or use the fallback method |

## Vault Structure

```
00 - Inbox/          Collection layer: entry point for all new notes
01 - Active/         Frequently opened notes (5-10 max)
10 - Projects/       Time-bound projects
20 - Areas/          Ongoing topics with no deadline
30 - Notes/          Atomic notes (one idea = one note)
40 - Daily/          Journal + review reports
99 - Archive/        Completed or outdated notes
    Sessions/        Processed session logs
Attachments/
Home.md
Templates/
```

Note naming format: `YYYY-MM-DD Title.md` (date must come first)
