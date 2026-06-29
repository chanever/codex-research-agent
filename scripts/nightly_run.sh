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

TIMEZONE="${TIMEZONE:-Asia/Seoul}"
ARCHIVE_DATE="$(TZ="$TIMEZONE" date +%F)"
ARCHIVE_DIR="$PROJECT_ROOT/outputs/archive/$ARCHIVE_DATE"

bash "$PROJECT_ROOT/scripts/run_once.sh"

mkdir -p "$ARCHIVE_DIR"

for file in \
  daily_research_brief.md \
  papers_to_read.md \
  research_ideas.md \
  final_response.md; do
  if [[ -f "$PROJECT_ROOT/outputs/latest/$file" ]]; then
    cp "$PROJECT_ROOT/outputs/latest/$file" "$ARCHIVE_DIR/$file"
  else
    echo "Warning: outputs/latest/$file not found; skipping archive copy." >&2
  fi
done

bash "$PROJECT_ROOT/scripts/push_outputs.sh"
