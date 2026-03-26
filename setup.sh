#!/usr/bin/env bash
set -e

# ─────────────────────────────────────────────
# claude-obsidian setup script
# Installs Obsidian skills for Claude Code
# ─────────────────────────────────────────────

SKILLS=(daily-review session-to-obsidian recall weekly-review monthly-review obsidian-connect)
SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILLS_DIR="$SCRIPT_DIR/skills"

# Colors (skip if not a terminal)
if [ -t 1 ]; then
  BOLD='\033[1m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  CYAN='\033[0;36m'
  RESET='\033[0m'
else
  BOLD='' GREEN='' YELLOW='' CYAN='' RESET=''
fi

info()  { echo -e "${CYAN}[info]${RESET}  $*"; }
ok()    { echo -e "${GREEN}[ok]${RESET}    $*"; }
warn()  { echo -e "${YELLOW}[warn]${RESET}  $*"; }

# ── 1. Ask for vault path ────────────────────
DEFAULT_VAULT="$HOME/Documents/Obsidian"
echo ""
echo -e "${BOLD}Obsidian Skills Installer${RESET}"
echo "────────────────────────"
echo ""
read -rp "Obsidian vault path [$DEFAULT_VAULT]: " VAULT_PATH
VAULT_PATH="${VAULT_PATH:-$DEFAULT_VAULT}"

# Expand ~ if user typed it literally
VAULT_PATH="${VAULT_PATH/#\~/$HOME}"

# Resolve to absolute path
VAULT_PATH="$(cd "$VAULT_PATH" 2>/dev/null && pwd || echo "$VAULT_PATH")"

if [ ! -d "$VAULT_PATH" ]; then
  warn "Directory '$VAULT_PATH' does not exist yet — it will be created."
fi

# ── 2. Ask for language ──────────────────────
echo ""
echo "Language / 語言:"
echo "  [1] English (default)"
echo "  [2] 繁體中文"
read -rp "Choice [1]: " LANG_CHOICE
LANG_CHOICE="${LANG_CHOICE:-1}"

case "$LANG_CHOICE" in
  2)  LANG_LABEL="繁體中文"; SKILL_SOURCE="skill.zh-TW.md" ;;
  *)  LANG_LABEL="English";  SKILL_SOURCE="skill.md" ;;
esac

# ── 3. Verify source skills exist ────────────
if [ ! -d "$SOURCE_SKILLS_DIR" ]; then
  echo "Error: skills directory not found at $SOURCE_SKILLS_DIR"
  exit 1
fi

for skill in "${SKILLS[@]}"; do
  src="$SOURCE_SKILLS_DIR/$skill/$SKILL_SOURCE"
  if [ ! -f "$src" ]; then
    echo "Error: missing skill file: $src"
    exit 1
  fi
done

# ── 4. Create required vault folders ─────────
echo ""
info "Creating required vault folders..."

REQUIRED_DIRS=("00 - Inbox" "40 - Daily" "99 - Archive/Sessions")
for dir in "${REQUIRED_DIRS[@]}"; do
  target="$VAULT_PATH/$dir"
  if [ ! -d "$target" ]; then
    mkdir -p "$target"
    ok "Created $dir"
  else
    info "$dir already exists"
  fi
done

# ── 5. Optionally create recommended folders ─
echo ""
read -rp "Create recommended folders (10-Projects, 20-Areas, 30-Notes)? [y/N]: " CREATE_RECOMMENDED
if [[ "$CREATE_RECOMMENDED" =~ ^[Yy]$ ]]; then
  RECOMMENDED_DIRS=("10 - Projects" "20 - Areas" "30 - Notes")
  for dir in "${RECOMMENDED_DIRS[@]}"; do
    target="$VAULT_PATH/$dir"
    if [ ! -d "$target" ]; then
      mkdir -p "$target"
      ok "Created $dir"
    else
      info "$dir already exists"
    fi
  done
fi

# ── 6. Install skills ────────────────────────
echo ""
info "Installing skills to $SKILLS_DIR..."

mkdir -p "$SKILLS_DIR"

INSTALLED=()
BACKED_UP=()

for skill in "${SKILLS[@]}"; do
  dest_dir="$SKILLS_DIR/$skill"
  dest_file="$dest_dir/skill.md"
  src_file="$SOURCE_SKILLS_DIR/$skill/$SKILL_SOURCE"

  # Backup existing skill
  if [ -f "$dest_file" ]; then
    cp "$dest_file" "$dest_file.bak"
    BACKED_UP+=("$skill")
  fi

  mkdir -p "$dest_dir"

  # Copy skill file (always install as skill.md)
  cp "$src_file" "$dest_file"

  # Replace {{VAULT}} with actual vault path
  # Use | as sed delimiter to avoid issues with / in paths
  sed -i "s|{{VAULT}}|$VAULT_PATH|g" "$dest_file"

  INSTALLED+=("$skill")
done

# ── 7. Summary ────────────────────────────────
echo ""
echo "════════════════════════════════════════"
echo -e "${BOLD}Installation Summary${RESET}"
echo "════════════════════════════════════════"
echo ""
echo "  Vault path:   $VAULT_PATH"
echo "  Language:      $LANG_LABEL"
echo "  Skills dir:   $SKILLS_DIR"
echo ""

if [ ${#BACKED_UP[@]} -gt 0 ]; then
  echo "  Backed up (*.bak):"
  for s in "${BACKED_UP[@]}"; do
    echo "    - $s"
  done
  echo ""
fi

echo "  Installed skills:"
for s in "${INSTALLED[@]}"; do
  echo -e "    ${GREEN}+${RESET} $s"
done

echo ""
echo "  Vault folders created:"
for dir in "${REQUIRED_DIRS[@]}"; do
  echo "    - $dir"
done
if [[ "$CREATE_RECOMMENDED" =~ ^[Yy]$ ]]; then
  for dir in "${RECOMMENDED_DIRS[@]}"; do
    echo "    - $dir"
  done
fi

echo ""
ok "Done. Restart Claude Code to load the new skills."
echo ""
