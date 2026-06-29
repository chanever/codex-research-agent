#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/config/research.env"
PROMPT_FILE="${PROMPT_FILE:-$PROJECT_ROOT/prompts/make_research_brief.md}"

cd "$PROJECT_ROOT"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
else
  echo "Warning: config/research.env not found. Using default settings." >&2
fi

RESEARCH_DOMAIN="${RESEARCH_DOMAIN:-LLM Agent Security}"
RESEARCH_FOCUS="${RESEARCH_FOCUS:-execution graph based detection for malicious tool-use agents}"
RESEARCH_KEYWORDS="${RESEARCH_KEYWORDS:-prompt injection,indirect prompt injection,tool-use security,MCP security,malicious package detection,sandbox verification,provenance graph,execution graph,tool poisoning,agentic workflow security,coding agent security,browser agent security,software supply chain attack,package install attack,syscall tracing,strace,Docker sandbox}"
OUTPUT_LANGUAGE="${OUTPUT_LANGUAGE:-ko}"
TOP_K="${TOP_K:-5}"
MIN_RELEVANCE_SCORE="${MIN_RELEVANCE_SCORE:-7.0}"
TIMEZONE="${TIMEZONE:-Asia/Seoul}"

CODEX_BIN="${CODEX_BIN:-codex}"
CODEX_SANDBOX="${CODEX_SANDBOX:-workspace-write}"
CODEX_APPROVAL="${CODEX_APPROVAL:-never}"
CODEX_OUTPUT_LAST_MESSAGE="${CODEX_OUTPUT_LAST_MESSAGE:-outputs/latest/final_response.md}"

if ! command -v "$CODEX_BIN" >/dev/null 2>&1; then
  if [[ "$CODEX_BIN" == "codex" && -x "/Applications/Codex.app/Contents/Resources/codex" ]]; then
    CODEX_BIN="/Applications/Codex.app/Contents/Resources/codex"
  else
    cat >&2 <<EOF
Error: Codex CLI not found: $CODEX_BIN

Install Codex CLI, add it to PATH, or set CODEX_BIN in config/research.env.
On macOS with the Codex desktop app, this may work:

CODEX_BIN="/Applications/Codex.app/Contents/Resources/codex"
EOF
    exit 127
  fi
fi

CODEX_EXEC_HELP="$("$CODEX_BIN" exec --help 2>&1 || true)"

if [[ "$CODEX_EXEC_HELP" != *"--search"* ]]; then
  cat >&2 <<EOF
Error: the installed Codex CLI does not support 'codex exec --search'.

This template requires live web search for current research automation.
Update Codex CLI to a version that supports '--search', or set web_search = "live"
in your Codex config if your CLI supports that configuration path.

Current Codex binary:
$CODEX_BIN
EOF
  exit 2
fi

if [[ "$CODEX_EXEC_HELP" != *"--ask-for-approval"* ]]; then
  cat >&2 <<EOF
Error: the installed Codex CLI does not support 'codex exec --ask-for-approval'.

Update Codex CLI to a version that supports non-interactive approval control.

Current Codex binary:
$CODEX_BIN
EOF
  exit 2
fi

if [[ "$CODEX_OUTPUT_LAST_MESSAGE" = /* ]]; then
  CODEX_OUTPUT_PATH="$CODEX_OUTPUT_LAST_MESSAGE"
else
  CODEX_OUTPUT_PATH="$PROJECT_ROOT/$CODEX_OUTPUT_LAST_MESSAGE"
fi

mkdir -p "$PROJECT_ROOT/outputs/latest" "$PROJECT_ROOT/logs"
mkdir -p "$(dirname "$CODEX_OUTPUT_PATH")"

if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "Error: prompt file not found: $PROMPT_FILE" >&2
  exit 1
fi

{
  cat <<EOF
# Runtime Configuration

- RESEARCH_DOMAIN: $RESEARCH_DOMAIN
- RESEARCH_FOCUS: $RESEARCH_FOCUS
- RESEARCH_KEYWORDS: $RESEARCH_KEYWORDS
- OUTPUT_LANGUAGE: $OUTPUT_LANGUAGE
- TOP_K: $TOP_K
- MIN_RELEVANCE_SCORE: $MIN_RELEVANCE_SCORE
- TIMEZONE: $TIMEZONE

---

EOF
  cat "$PROMPT_FILE"
} | "$CODEX_BIN" exec \
  --cd "$PROJECT_ROOT" \
  --sandbox "$CODEX_SANDBOX" \
  --ask-for-approval "$CODEX_APPROVAL" \
  --search \
  --output-last-message "$CODEX_OUTPUT_LAST_MESSAGE" \
  - > "$PROJECT_ROOT/logs/codex_stdout.log" 2> "$PROJECT_ROOT/logs/codex_stderr.log"
