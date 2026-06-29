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
CODEX_WEB_SEARCH_MODE="${CODEX_WEB_SEARCH_MODE:-live}"
RUN_TIMESTAMP="$(TZ="$TIMEZONE" date +%Y_%m_%d_%H_%M)"
OUTPUT_RUN_DIR="${OUTPUT_RUN_DIR:-outputs/runs/$RUN_TIMESTAMP}"
OUTPUT_LATEST_DIR="${OUTPUT_LATEST_DIR:-outputs/latest}"
CODEX_OUTPUT_LAST_MESSAGE="${CODEX_OUTPUT_LAST_MESSAGE:-}"

if [[ -z "$CODEX_OUTPUT_LAST_MESSAGE" || "$CODEX_OUTPUT_LAST_MESSAGE" == "outputs/latest/final_response.md" ]]; then
  CODEX_OUTPUT_LAST_MESSAGE="$OUTPUT_RUN_DIR/final_response.md"
fi

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

CODEX_HELP="$("$CODEX_BIN" --help 2>&1 || true)"

if [[ "$CODEX_WEB_SEARCH_MODE" == "live" && "$CODEX_HELP" != *"--search"* ]]; then
  cat >&2 <<EOF
Error: the installed Codex CLI does not support 'codex --search'.

This template requires live web search for current research automation.
Update Codex CLI to a version that supports '--search', or set web_search = "live"
in your Codex config if your CLI supports that configuration path.

Current Codex binary:
$CODEX_BIN
EOF
  exit 2
fi

if [[ "$CODEX_HELP" != *"--ask-for-approval"* ]]; then
  cat >&2 <<EOF
Error: the installed Codex CLI does not support 'codex --ask-for-approval'.

Update Codex CLI to a version that supports non-interactive approval control.

Current Codex binary:
$CODEX_BIN
EOF
  exit 2
fi

CODEX_GLOBAL_ARGS=()

case "$CODEX_WEB_SEARCH_MODE" in
  live)
    CODEX_GLOBAL_ARGS+=(--search)
    ;;
  cached)
    CODEX_GLOBAL_ARGS+=(--config 'web_search="cached"')
    ;;
  disabled)
    CODEX_GLOBAL_ARGS+=(--config 'web_search="disabled"')
    ;;
  config)
    ;;
  *)
    cat >&2 <<EOF
Error: unsupported CODEX_WEB_SEARCH_MODE: $CODEX_WEB_SEARCH_MODE

Use one of: live, cached, disabled, config.
EOF
    exit 2
    ;;
esac

CODEX_COMMAND=("$CODEX_BIN")
if (( ${#CODEX_GLOBAL_ARGS[@]} > 0 )); then
  CODEX_COMMAND+=("${CODEX_GLOBAL_ARGS[@]}")
fi
CODEX_COMMAND+=(
  --ask-for-approval "$CODEX_APPROVAL"
  exec
  --cd "$PROJECT_ROOT"
  --sandbox "$CODEX_SANDBOX"
  --output-last-message "$CODEX_OUTPUT_LAST_MESSAGE"
  -
)

if [[ "$CODEX_OUTPUT_LAST_MESSAGE" = /* ]]; then
  CODEX_OUTPUT_PATH="$CODEX_OUTPUT_LAST_MESSAGE"
else
  CODEX_OUTPUT_PATH="$PROJECT_ROOT/$CODEX_OUTPUT_LAST_MESSAGE"
fi

mkdir -p "$PROJECT_ROOT/$OUTPUT_RUN_DIR" "$PROJECT_ROOT/$OUTPUT_LATEST_DIR" "$PROJECT_ROOT/logs"
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
- CODEX_WEB_SEARCH_MODE: $CODEX_WEB_SEARCH_MODE
- OUTPUT_DIR: $OUTPUT_RUN_DIR
- OUTPUT_DAILY_RESEARCH_BRIEF: $OUTPUT_RUN_DIR/daily_research_brief.md
- OUTPUT_PAPERS_TO_READ: $OUTPUT_RUN_DIR/papers_to_read.md
- OUTPUT_RESEARCH_IDEAS: $OUTPUT_RUN_DIR/research_ideas.md

---

EOF
  cat "$PROMPT_FILE"
} | "${CODEX_COMMAND[@]}" > "$PROJECT_ROOT/logs/codex_stdout.log" 2> "$PROJECT_ROOT/logs/codex_stderr.log"

for file in \
  daily_research_brief.md \
  papers_to_read.md \
  research_ideas.md \
  final_response.md; do
  if [[ -f "$PROJECT_ROOT/$OUTPUT_RUN_DIR/$file" ]]; then
    cp "$PROJECT_ROOT/$OUTPUT_RUN_DIR/$file" "$PROJECT_ROOT/$OUTPUT_LATEST_DIR/$file"
  fi
done

echo "Run outputs: $OUTPUT_RUN_DIR"
