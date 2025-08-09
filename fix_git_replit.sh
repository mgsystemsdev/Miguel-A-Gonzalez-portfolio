#!/usr/bin/env bash
set -euo pipefail

# ======= EDIT THESE THREE VALUES =======
NEW_REMOTE="https://github.com/mgsystemsdev/Miguel-A-Gonzalez-portfolio.git"
GIT_USER_NAME="Miguel A. Gonzalez"
GIT_USER_EMAIL="mg.systems.dev@gmail.com"
# ======================================

BRANCH="main"
NUKE="${1:-}"   # pass --reinit to force a fresh .git

echo "==> Starting Git repair for Replit (branch: $BRANCH)"
date

if [ ! -d ".git" ] || [ "$NUKE" = "--reinit" ]; then
  echo "==> (Re)initializing Git repository"
  [ -d ".git" ] && mv .git ".git.bak-$(date +%Y%m%d-%H%M%S)" || true
  git init
fi

echo "==> Backing up current .git"
cp -R .git ".git.bak-$(date +%Y%m%d-%H%M%S)" || true

echo "==> Removing common lock files"
find .git -name "*.lock" -type f -print -delete || true
rm -f .git/index.lock .git/packed-refs.lock .git/refs/heads/*.lock .git/refs/remotes/origin/*.lock 2>/dev/null || true

echo "==> Basic repo health checks"
git status || true
git fsck || true
git reflog expire --all --expire=now || true
git repack -Ad || true
git gc --prune=now || true

echo "==> Configuring identity"
git config user.name "$GIT_USER_NAME"
git config user.email "$GIT_USER_EMAIL"

echo "==> Ensuring branch is '$BRANCH'"
# Create branch if absent; ignore error if already on it
git rev-parse --verify "$BRANCH" >/dev/null 2>&1 || git checkout -b "$BRANCH"
git branch -M "$BRANCH"

echo "==> Setting remote 'origin' to new URL"
if git remote get-url origin >/dev/null 2>&1; then
  git remote remove origin
fi
git remote add origin "$NEW_REMOTE"
git remote -v

echo "==> Staging & committing working tree"
git add -A
if git diff --cached --quiet; then
  echo "   (No changes to commit; continuing)"
else
  git commit -m "Repo repair: clear locks, set identity, relink origin"
fi

echo "==> Pushing to '$NEW_REMOTE' on branch '$BRANCH'"
git push -u origin "$BRANCH"

echo "==> Verification"
git status
git remote -v
echo "==> Done."