#!/usr/bin/env bash
set -uo pipefail

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
NIGHTLY_RUN_MODE="${NIGHTLY_RUN_MODE:-loop}"
NIGHTLY_RUN_INTERVAL_SECONDS="${NIGHTLY_RUN_INTERVAL_SECONDS:-86400}"

run_cycle() (
  set -euo pipefail

  cd "$PROJECT_ROOT"

  local cycle_timestamp
  local archive_date
  local archive_dir

  cycle_timestamp="$(TZ="$TIMEZONE" date '+%F %T %Z')"
  archive_date="$(TZ="$TIMEZONE" date +%F)"
  archive_dir="$PROJECT_ROOT/outputs/archive/$archive_date"

  echo "Starting nightly research cycle: $cycle_timestamp"

  bash "$PROJECT_ROOT/scripts/run_once.sh"

  mkdir -p "$archive_dir"

  for file in \
    daily_research_brief.md \
    papers_to_read.md \
    research_ideas.md \
    final_response.md; do
    if [[ -f "$PROJECT_ROOT/outputs/latest/$file" ]]; then
      cp "$PROJECT_ROOT/outputs/latest/$file" "$archive_dir/$file"
    else
      echo "Warning: outputs/latest/$file not found; skipping archive copy." >&2
    fi
  done

  bash "$PROJECT_ROOT/scripts/push_outputs.sh"

  echo "Finished nightly research cycle: $(TZ="$TIMEZONE" date '+%F %T %Z')"
)

if [[ "$NIGHTLY_RUN_MODE" == "once" ]]; then
  run_cycle
  exit $?
fi

if [[ "$NIGHTLY_RUN_MODE" != "loop" ]]; then
  echo "Error: unsupported NIGHTLY_RUN_MODE: $NIGHTLY_RUN_MODE" >&2
  echo "Use one of: loop, once" >&2
  exit 2
fi

while true; do
  run_cycle
  status=$?

  if (( status != 0 )); then
    echo "Warning: nightly research cycle failed with status $status." >&2
  fi

  echo "Sleeping for $NIGHTLY_RUN_INTERVAL_SECONDS seconds. Press Ctrl-C to stop."
  sleep "$NIGHTLY_RUN_INTERVAL_SECONDS"
done
