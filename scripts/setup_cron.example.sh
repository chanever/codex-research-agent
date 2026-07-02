#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cat <<EOF
Copy the following example into your crontab manually with: crontab -e

TZ=Asia/Seoul
30 1 * * * cd $PROJECT_ROOT && NIGHTLY_RUN_MODE=once bash scripts/nightly_run.sh >> logs/cron.log 2>&1
EOF
