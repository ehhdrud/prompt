#!/usr/bin/env bash
set -euo pipefail

# Git Worktree Setup Script
# Creates a worktree with environment setup (env copy + dependency install)
#
# Usage: worktree-setup.sh <branch-name> [worktree-base-dir]
#   branch-name:      Target branch (existing or new)
#   worktree-base-dir: Base directory for worktrees (default: .claude/worktrees)

BRANCH="${1:?Usage: worktree-setup.sh <branch-name> [worktree-base-dir]}"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
WORKTREE_BASE="${2:-$PROJECT_ROOT/.claude/worktrees}"
WORKTREE_NAME="${BRANCH//\//-}"
WORKTREE_PATH="$WORKTREE_BASE/$WORKTREE_NAME"

# Detect WSL environment
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
  IS_WSL=true
fi

# Run a package manager command (handles WSL → Windows delegation)
run_pkg_cmd() {
  if [ "$IS_WSL" = true ]; then
    local win_path
    win_path=$(wslpath -w "$WORKTREE_PATH")
    cmd.exe /c "cd /d $win_path && $*" 2>&1
  else
    "$@"
  fi
}

# Validate git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "ERROR: Not inside a git repository" >&2
  exit 1
fi

# Check if already in a worktree targeting the same branch
if git worktree list | grep -q "\[$BRANCH\]"; then
  echo "ERROR: Branch '$BRANCH' is already checked out in another worktree:" >&2
  git worktree list | grep "\[$BRANCH\]" >&2
  exit 1
fi

# Ensure .claude/worktrees is in .gitignore
GITIGNORE="$PROJECT_ROOT/.gitignore"
if [ -f "$GITIGNORE" ]; then
  if ! grep -qF '.claude/worktrees' "$GITIGNORE"; then
    echo "" >> "$GITIGNORE"
    echo "# Git worktrees" >> "$GITIGNORE"
    echo ".claude/worktrees/" >> "$GITIGNORE"
    echo "==> Added .claude/worktrees/ to .gitignore"
  fi
else
  echo "# Git worktrees" > "$GITIGNORE"
  echo ".claude/worktrees/" >> "$GITIGNORE"
  echo "==> Created .gitignore with .claude/worktrees/"
fi

# Create worktree base directory
mkdir -p "$WORKTREE_BASE"

# Create worktree
echo "==> Creating worktree at $WORKTREE_PATH"
if git show-ref --verify --quiet "refs/heads/$BRANCH" 2>/dev/null; then
  git worktree add "$WORKTREE_PATH" "$BRANCH"
else
  echo "    Branch '$BRANCH' not found locally. Creating new branch from HEAD."
  git worktree add -b "$BRANCH" "$WORKTREE_PATH"
fi

# Copy .env files
echo "==> Copying environment files"
ENV_COUNT=0
for env_file in "$PROJECT_ROOT"/.env*; do
  [ -f "$env_file" ] || continue
  cp "$env_file" "$WORKTREE_PATH/"
  echo "    Copied $(basename "$env_file")"
  ENV_COUNT=$((ENV_COUNT + 1))
done
if [ "$ENV_COUNT" -eq 0 ]; then
  echo "    No .env files found to copy"
fi

# Detect package manager and install dependencies
echo "==> Installing dependencies"
cd "$WORKTREE_PATH"
if [ -f "pnpm-lock.yaml" ]; then
  echo "    Detected pnpm"
  run_pkg_cmd pnpm install
elif [ -f "yarn.lock" ]; then
  echo "    Detected yarn"
  run_pkg_cmd yarn install
elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
  echo "    Detected bun"
  run_pkg_cmd bun install
elif [ -f "package-lock.json" ]; then
  echo "    Detected npm"
  run_pkg_cmd npm install
elif [ -f "package.json" ]; then
  echo "    No lockfile found. Using npm install"
  run_pkg_cmd npm install
else
  echo "    No package.json found. Skipping dependency install."
fi

echo ""
echo "==> Worktree ready!"
echo "    Path:   $WORKTREE_PATH"
echo "    Branch: $BRANCH"
echo ""
echo "    Next: cd $WORKTREE_PATH"
