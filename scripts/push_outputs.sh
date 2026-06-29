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
GIT_BRANCH="${GIT_BRANCH:-main}"
GIT_OUTPUT_PATHS="${GIT_OUTPUT_PATHS:-outputs/latest outputs/archive}"
TIMEZONE="${TIMEZONE:-Asia/Seoul}"

if [[ "$ENABLE_GITHUB_PUSH" != "true" ]]; then
  echo "GitHub push disabled. Set ENABLE_GITHUB_PUSH=true in config/research.env to enable it."
  exit 0
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not inside a Git repository." >&2
  exit 1
fi

read -r -a output_paths <<< "$GIT_OUTPUT_PATHS"

if ! git add -- "${output_paths[@]}"; then
  echo "Warning: Git could not add the configured output paths." >&2
  echo "Generated Markdown outputs are ignored by default. Adjust .gitignore before enabling public output pushes." >&2
  exit 0
fi

if git diff --cached --quiet -- "${output_paths[@]}"; then
  echo "No output changes to commit."
  exit 0
fi

COMMIT_DATE="$(TZ="$TIMEZONE" date +%F)"
git commit -m "daily research brief: $COMMIT_DATE"
git push origin "$GIT_BRANCH"
