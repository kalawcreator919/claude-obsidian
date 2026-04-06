---
name: obsidian-connect
description: "Verify Obsidian vault connection. Tests CLI access (Obsidian 1.12+), falls back to direct file Read/Write. Reports connection status and available methods."
category: system
depends_on: []
triggers:
  - "/obsidian-connect"
  - "connect to Obsidian"
  - "verify vault"
  - "check Obsidian"
output_type: status
cost: low
---

# Obsidian Connect

Verify Obsidian vault connection. Prefer CLI access; fall back to Read/Write/Edit tools if CLI is unavailable.

> Configure your vault path in setup.sh or set the `VAULT_PATH` environment variable.

## When to Use

- Initial setup — verify the vault is accessible
- After Obsidian updates — confirm CLI still works
- When CLI commands fail — diagnose the issue
- When other skills report vault access errors

## Connection Methods

### Method 1: Obsidian CLI (Preferred)

**Requirements:** Obsidian 1.12+ running with Settings > General > CLI enabled.

**Verify connection:**
```bash
obsidian read vault="VaultName" file="Home"
```

On success, returns the contents of Home.md (or any existing note).

### Method 2: Direct File Access (Fallback)

Use Read/Write/Edit tools to operate on vault markdown files directly:

```
Read: $VAULT_PATH/00 - Inbox/note-name.md
Write: $VAULT_PATH/00 - Inbox/new-note.md
Edit: $VAULT_PATH/30 - Notes/existing-note.md
```

This method always works as long as the vault path is correct and the filesystem is accessible.

## Process

### Step 1 — Verify Vault Path

Check that `$VAULT_PATH` exists and contains an `.obsidian/` directory (confirming it is an Obsidian vault):

```bash
ls "$VAULT_PATH/.obsidian" 2>/dev/null && echo "Vault found" || echo "Not a vault"
```

### Step 2 — Test CLI Access

```bash
obsidian read vault="VaultName" file="Home"
```

- **Success:** Report CLI is working
- **Failure:** Proceed to diagnosis

### Step 3 — Diagnose CLI Failure

Check the following:

| Check | How | Fix |
|-------|-----|-----|
| Obsidian running? | Check process list | Launch Obsidian desktop |
| CLI enabled? | Manual check in Settings | Settings > General > Command line interface > Enable |
| Version 1.12+? | Check About page | Update Obsidian |
| Windows path issue? | Command contains `:` | Use `MSYS_NO_PATHCONV=1` prefix or use fallback |

### Step 4 — Test Fallback

Verify direct file access works:

```bash
ls "$VAULT_PATH/00 - Inbox/"
```

If this succeeds, file-based access is available even without CLI.

### Step 5 — Report Status

```
Obsidian Connection Status
==========================

Vault path:    $VAULT_PATH
Vault exists:  Yes/No
CLI available: Yes/No (version X.X)
File access:   Yes/No

Recommended method: CLI / File access

Vault folders found:
  - 00 - Inbox/     (N files)
  - 10 - Projects/  (N files)
  - 20 - Areas/     (N files)
  - 30 - Notes/     (N files)
  - 40 - Daily/     (N files)
  - 99 - Archive/   (N files)
```

## CLI Command Reference

| Action | Command |
|--------|---------|
| Read | `obsidian read vault="VaultName" file="note-name"` |
| Create | `obsidian create vault="VaultName" name="YYYY-MM-DD Title" content="..."` |
| Append | `obsidian append vault="VaultName" file="note-name" content="..."` |
| Search | `obsidian search vault="VaultName" query="keyword"` |
| Daily note | `obsidian daily vault="VaultName"` |

**Content format:** Quote values containing spaces. Use `\n` for newlines, `\t` for tabs.

**Windows note:** Use `Obsidian.com` (not `Obsidian.exe`) for correct stdin/stdout handling in Git Bash / terminal.

## Common Problems

| Problem | Cause | Solution |
|---------|-------|----------|
| "Unable to connect to main process" | Obsidian not running or CLI not enabled | Launch Obsidian + enable CLI setting |
| "Command not found" | CLI not in PATH | Windows: use `Obsidian.com`; macOS/Linux: add to PATH |
| Colon subcommand fails | Git Bash on Windows parses `:` as drive path | Prefix with `MSYS_NO_PATHCONV=1` or use file fallback |
| Wrong vault | Multiple vaults installed | Specify the correct vault name in the command |

## Vault Structure Reference

```
00 - Inbox/          Entry point for all new notes
01 - Active/         Frequently opened notes (5-10 max)
10 - Projects/       Time-bound projects
20 - Areas/          Ongoing topics with no deadline
30 - Notes/          Atomic notes (one idea = one note)
40 - Daily/          Journal + review reports
99 - Archive/        Completed or outdated notes
    Sessions/        Processed session logs
```

Note naming format: `YYYY-MM-DD Title.md` (date prefix required)

## Related Skills

- [[daily-review]] — Requires vault access to process inbox
- [[session-to-obsidian]] — Requires vault access to write session notes
- [[vault-lint]] — Requires vault access to scan for issues
