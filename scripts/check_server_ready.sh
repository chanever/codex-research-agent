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
  echo "FAIL: config/research.env not found. Copy config/research.env.example first."
  exit 1
fi

CODEX_BIN="${CODEX_BIN:-codex}"
CODEX_WEB_SEARCH_MODE="${CODEX_WEB_SEARCH_MODE:-live}"
ENABLE_GITHUB_PUSH="${ENABLE_GITHUB_PUSH:-false}"
GIT_BRANCH="${GIT_BRANCH:-master}"
GIT_OUTPUT_PATHS="${GIT_OUTPUT_PATHS:-outputs/latest outputs/runs outputs/archive}"

failures=0

check_ok() {
  echo "OK: $1"
}

check_warn() {
  echo "WARN: $1"
}

check_fail() {
  echo "FAIL: $1"
  failures=$((failures + 1))
}

if command -v git >/dev/null 2>&1; then
  check_ok "git found: $(command -v git)"
else
  check_fail "git not found"
fi

if command -v "$CODEX_BIN" >/dev/null 2>&1; then
  check_ok "codex found: $(command -v "$CODEX_BIN")"
  "$CODEX_BIN" --version || true
else
  check_fail "Codex CLI not found: $CODEX_BIN"
fi

if "$CODEX_BIN" --help 2>/dev/null | grep -q -- "--ask-for-approval"; then
  check_ok "Codex supports --ask-for-approval"
else
  check_fail "Codex does not appear to support --ask-for-approval"
fi

if [[ "$CODEX_WEB_SEARCH_MODE" == "live" ]]; then
  if "$CODEX_BIN" --help 2>/dev/null | grep -q -- "--search"; then
    check_ok "Codex supports --search for live web search"
  else
    check_fail "CODEX_WEB_SEARCH_MODE=live but Codex does not appear to support --search"
  fi
else
  check_ok "CODEX_WEB_SEARCH_MODE=$CODEX_WEB_SEARCH_MODE"
fi

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  check_ok "inside a Git repository"
else
  check_fail "not inside a Git repository"
fi

if git remote get-url origin >/dev/null 2>&1; then
  check_ok "origin remote: $(git remote get-url origin)"
else
  check_fail "origin remote is not configured"
fi

current_branch="$(git branch --show-current 2>/dev/null || true)"
if [[ "$current_branch" == "$GIT_BRANCH" ]]; then
  check_ok "current branch matches GIT_BRANCH: $GIT_BRANCH"
else
  check_warn "current branch is '$current_branch', but GIT_BRANCH is '$GIT_BRANCH'"
fi

if [[ "$ENABLE_GITHUB_PUSH" == "true" ]]; then
  check_ok "ENABLE_GITHUB_PUSH=true"
else
  check_warn "ENABLE_GITHUB_PUSH is not true; nightly runs will not push outputs"
fi

if git config user.name >/dev/null && git config user.email >/dev/null; then
  check_ok "git commit identity configured"
else
  check_warn "git commit identity is not configured; push_outputs.sh will set local defaults"
fi

mkdir -p outputs/latest outputs/runs outputs/archive logs

if git check-ignore -q outputs/latest/__server_ready_check__.md; then
  check_warn "outputs/latest appears to be ignored by Git"
else
  check_ok "outputs/latest is trackable"
fi

if git check-ignore -q outputs/runs/__server_ready_check__/final_response.md; then
  check_warn "outputs/runs appears to be ignored by Git"
else
  check_ok "outputs/runs is trackable"
fi

echo "Configured GIT_OUTPUT_PATHS: $GIT_OUTPUT_PATHS"
echo
echo "Suggested cron entry:"
echo "TZ=${TIMEZONE:-Asia/Seoul}"
echo "30 1 * * * cd $PROJECT_ROOT && bash scripts/nightly_run.sh >> logs/cron.log 2>&1"

if (( failures > 0 )); then
  echo
  echo "Server readiness check failed with $failures issue(s)."
  exit 1
fi

echo
echo "Server readiness check passed."
