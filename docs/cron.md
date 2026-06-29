# Cron

`scripts/nightly_run.sh` is intended for scheduled runs.

## Example

Print a cron example:

```bash
bash scripts/setup_cron.example.sh
```

Example schedule for 1:30 AM in Korea Standard Time:

```cron
TZ=Asia/Seoul
30 1 * * * cd /path/to/codex-research-agent && bash scripts/nightly_run.sh >> logs/cron.log 2>&1
```

## What Nightly Run Does

The script:

- Loads `config/research.env` when present.
- Uses `TIMEZONE=Asia/Seoul` by default.
- Runs `scripts/run_once.sh`.
- Leaves each run under `outputs/runs/YYYY_MM_DD_HH_MM/`.
- Copies the newest completed run into `outputs/latest/`.
- Copies latest outputs into `outputs/archive/YYYY-MM-DD/`.
- Runs `scripts/push_outputs.sh`.

GitHub push is disabled by default, so nightly runs still succeed without publishing outputs.

## Server Notes

- Make sure Codex CLI is installed on the server.
- Make sure the Codex CLI is logged in for the user that owns the cron job.
- Use absolute paths in crontab.
- Check `logs/cron.log`, `logs/codex_stdout.log`, and `logs/codex_stderr.log` after the first run.
