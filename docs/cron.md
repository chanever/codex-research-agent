# Cron

`scripts/nightly_run.sh` runs continuously by default. It repeats a full research cycle, sleeps for `NIGHTLY_RUN_INTERVAL_SECONDS`, and then runs again.

For cron, use `NIGHTLY_RUN_MODE=once` so each cron invocation performs one cycle and exits.

## Example

Print a cron example:

```bash
bash scripts/setup_cron.example.sh
```

Example schedule for 1:30 AM in Korea Standard Time:

```cron
TZ=Asia/Seoul
30 1 * * * cd /path/to/codex-research-agent && NIGHTLY_RUN_MODE=once bash scripts/nightly_run.sh >> logs/cron.log 2>&1
```

## What Nightly Run Does

The script:

- Loads `config/research.env` when present.
- Uses `TIMEZONE=Asia/Seoul` by default.
- Uses `NIGHTLY_RUN_MODE=loop` by default.
- Sleeps `NIGHTLY_RUN_INTERVAL_SECONDS=86400` seconds between cycles in loop mode.
- Runs `scripts/run_once.sh`.
- Leaves each run under `outputs/runs/YYYY_MM_DD_HH_MM/`.
- Copies the newest completed run into `outputs/latest/`.
- Copies latest outputs into `outputs/archive/YYYY-MM-DD/`.
- Runs `scripts/push_outputs.sh`.

To keep it running from a terminal:

```bash
bash scripts/nightly_run.sh
```

To run once:

```bash
NIGHTLY_RUN_MODE=once bash scripts/nightly_run.sh
```

## Server Notes

- Make sure Codex CLI is installed on the server.
- Make sure the Codex CLI is logged in for the user that owns the cron job.
- Use absolute paths in crontab.
- Check `logs/cron.log`, `logs/codex_stdout.log`, and `logs/codex_stderr.log` after the first run.
