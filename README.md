# codex-research-agent

A public-ready template for running a terminal-based Codex research agent with `codex exec --search`.

The project helps you research a topic, collect fresh sources, and generate three Markdown files under `outputs/latest`.

It does not include a web UI, Notion integration, database, API server, or Python app.

## What It Creates

- `outputs/latest/daily_research_brief.md`: a daily summary with recommended items, source URLs, relevance scores, and top actions.
- `outputs/latest/papers_to_read.md`: a prioritized reading list with a short reading plan.
- `outputs/latest/research_ideas.md`: at least five research ideas and an experiment backlog.

By default, generated outputs are ignored by Git to prevent accidentally publishing private research notes.

## Prerequisites

- Codex CLI installed
- Codex CLI logged in
- Git installed

## Quick Start

```bash
git clone https://github.com/YOUR_NAME/codex-research-agent.git
cd codex-research-agent
cp config/research.env.example config/research.env
bash scripts/run_once.sh
```

## Customize Your Research Topic

Edit `config/research.env`:

```env
RESEARCH_DOMAIN="LLM Agent Security"
RESEARCH_FOCUS="execution graph based detection for malicious tool-use agents"
RESEARCH_KEYWORDS="prompt injection,indirect prompt injection,tool-use security,MCP security"
OUTPUT_LANGUAGE=ko
TOP_K=5
```

Values with spaces should stay inside quotes because this file is sourced by Bash.

## Manual Run

```bash
bash scripts/run_once.sh
```

The script runs:

```bash
codex exec --cd "$PROJECT_ROOT" --sandbox workspace-write --ask-for-approval never --search --output-last-message outputs/latest/final_response.md -
```

The prompt is passed through stdin. Standard output goes to `logs/codex_stdout.log`, and standard error goes to `logs/codex_stderr.log`.

## Nightly Cron

Print a cron example:

```bash
bash scripts/setup_cron.example.sh
```

Example:

```cron
TZ=Asia/Seoul
30 1 * * * cd /path/to/codex-research-agent && bash scripts/nightly_run.sh >> logs/cron.log 2>&1
```

Nightly runs copy generated files into `outputs/archive/YYYY-MM-DD/`.

## GitHub Push

GitHub push is off by default:

```env
ENABLE_GITHUB_PUSH=false
```

To enable:

```env
ENABLE_GITHUB_PUSH=true
GIT_BRANCH=main
GIT_OUTPUT_PATHS="outputs/latest outputs/archive"
```

Then run:

```bash
bash scripts/push_outputs.sh
```

Important: generated Markdown outputs are ignored by `.gitignore` by default. If you want to publish outputs, intentionally edit `.gitignore` first and review the generated files before pushing. For personal research notes, a private output repository is recommended.

## Public Template vs Private Outputs

The public repository should contain:

- `prompts/`
- `scripts/`
- `config/research.env.example`
- `examples/`
- `docs/`
- `README.md`
- `.gitignore`
- `LICENSE`
- `.gitkeep` placeholders

The public repository should not contain:

- `config/research.env`
- `.env` files
- credentials or tokens
- Codex login information
- logs
- personal generated research outputs

## Logs

Check:

- `logs/codex_stdout.log`
- `logs/codex_stderr.log`
- `logs/cron.log` if using cron

## Troubleshooting

- If `codex` is not found, set `CODEX_BIN` in `config/research.env`.
- If Codex is not logged in, log in before running the scripts.
- If no Markdown files are generated, inspect `logs/codex_stderr.log`.
- If GitHub push does nothing, confirm `ENABLE_GITHUB_PUSH=true` and review `.gitignore`.
- If cron does not run, use absolute paths and confirm the cron user has Codex access.

## Future UI Extension

This template intentionally has no UI. Later, you can add a Next.js or Vercel app that reads `outputs/latest` and `outputs/archive`, or a backend on Render that manages scheduled runs and authenticated access.

See `docs/ui-extension.md`.

## Safety Principles

- Do not store credentials in this repo.
- Do not commit `config/research.env`.
- Do not publish private research outputs by accident.
- Do not use `danger-full-access` or `--yolo` for this workflow.
- Do not force push from automation.
- Review generated research notes before making them public.
