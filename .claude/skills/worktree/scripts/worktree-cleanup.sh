#!/usr/bin/env bash
set -euo pipefail

# Git Worktree Cleanup Script
# Removes a worktree and optionally deletes its branch
#
# Usage: worktree-cleanup.sh <worktree-name-or-path> [--delete-branch]
#   worktree-name-or-path: Worktree directory name or full path
#   --delete-branch:       Also delete the associated branch

TARGET="${1:?Usage: worktree-cleanup.sh <worktree-name-or-path> [--delete-branch]}"
DELETE_BRANCH=false
if [ "${2:-}" = "--delete-branch" ]; then
  DELETE_BRANCH=true
fi

PROJECT_ROOT="$(git rev-parse --show-toplevel)"
WORKTREE_BASE="$PROJECT_ROOT/.claude/worktrees"

# Resolve worktree path
if [ -d "$TARGET" ]; then
  WORKTREE_PATH="$(cd "$TARGET" && pwd)"
elif [ -d "$WORKTREE_BASE/$TARGET" ]; then
  WORKTREE_PATH="$WORKTREE_BASE/$TARGET"
else
  echo "ERROR: Worktree not found: $TARGET" >&2
  echo "Available worktrees:" >&2
  git worktree list >&2
  exit 1
fi

# Get branch name before removal
BRANCH=$(git -C "$WORKTREE_PATH" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

# Safety check: uncommitted changes
if [ -n "$(git -C "$WORKTREE_PATH" status --porcelain 2>/dev/null)" ]; then
  echo "WARNING: Uncommitted changes detected in $WORKTREE_PATH" >&2
  git -C "$WORKTREE_PATH" status --short >&2
  echo "" >&2
  read -rp "Continue with removal? (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# Safety check: unpushed commits
UNPUSHED=$(git -C "$WORKTREE_PATH" log @{u}..HEAD --oneline 2>/dev/null || echo "")
if [ -n "$UNPUSHED" ]; then
  echo "WARNING: Unpushed commits detected:" >&2
  echo "$UNPUSHED" >&2
  echo "" >&2
  read -rp "Continue with removal? (y/N): " confirm
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Aborted."
    exit 0
  fi
fi

# Remove worktree
echo "==> Removing worktree: $WORKTREE_PATH"
git worktree remove "$WORKTREE_PATH" --force

# Prune stale worktree entries
git worktree prune

# Optionally delete branch
if [ "$DELETE_BRANCH" = true ] && [ -n "$BRANCH" ] && [ "$BRANCH" != "HEAD" ]; then
  echo "==> Deleting branch: $BRANCH"
  git branch -D "$BRANCH"
fi

echo ""
echo "==> Cleanup complete!"
git worktree list
