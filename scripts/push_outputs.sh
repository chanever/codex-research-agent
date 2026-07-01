#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/config/research.env"

cd "$PROJECT_ROOT"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
else
  echo "Warning: config/research.env not found. Using default settings." >&2
fi

ENABLE_GITHUB_PUSH="${ENABLE_GITHUB_PUSH:-false}"
GIT_BRANCH="${GIT_BRANCH:-master}"
GIT_PULL_BEFORE_PUSH="${GIT_PULL_BEFORE_PUSH:-true}"
GIT_COMMIT_USER_NAME="${GIT_COMMIT_USER_NAME:-codex-research-agent}"
GIT_COMMIT_USER_EMAIL="${GIT_COMMIT_USER_EMAIL:-codex-research-agent@users.noreply.github.com}"
TIMEZONE="${TIMEZONE:-Asia/Seoul}"

if [[ "$ENABLE_GITHUB_PUSH" != "true" ]]; then
  echo "GitHub push disabled. Set ENABLE_GITHUB_PUSH=true in config/research.env to enable it."
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a Git repository." >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  echo "Error: Git remote 'origin' is not configured." >&2
  exit 1
fi

if [[ "$GIT_PULL_BEFORE_PUSH" == "true" ]]; then
  git pull --ff-only origin "$GIT_BRANCH"
fi

if ! git config user.name >/dev/null; then
  git config user.name "$GIT_COMMIT_USER_NAME"
fi

if ! git config user.email >/dev/null; then
  git config user.email "$GIT_COMMIT_USER_EMAIL"
fi

if ! git add .; then
  echo "Warning: Git could not add repository changes." >&2
  echo "Check .gitignore and repository permissions before enabling pushes." >&2
  exit 0
fi

if git diff --cached --quiet; then
  echo "No changes to commit."
  exit 0
fi

COMMIT_DATE="$(TZ="$TIMEZONE" date +%F)"
git commit -m "daily research brief: $COMMIT_DATE"
git push origin "$GIT_BRANCH"
