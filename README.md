# codex-research-agent

A public-ready template for running a terminal-based Codex research agent with `codex --search ... exec`.

The project helps you research a topic, collect fresh sources, and generate three Markdown files for each run under `outputs/runs/YYYY_MM_DD_HH_MM/`. It also copies the newest completed run into `outputs/latest`.

It does not include a web UI, Notion integration, database, API server, or Python app.

## What It Creates

- `outputs/runs/YYYY_MM_DD_HH_MM/daily_research_brief.md`: a daily summary with recommended items, source URLs, relevance scores, and top actions.
- `outputs/runs/YYYY_MM_DD_HH_MM/papers_to_read.md`: a prioritized reading list with a short reading plan.
- `outputs/runs/YYYY_MM_DD_HH_MM/research_ideas.md`: at least five research ideas and an experiment backlog.
- `outputs/latest/`: a copy of the newest completed run.

Generated outputs are intended to be pushed to your configured GitHub repository so they can be read from the GitHub mobile app. Keep the repository private if the notes contain personal research context.

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
RESEARCH_QUESTIONS="How can execution/provenance graphs reveal malicious or risky tool-use behavior in agents?"
RESEARCH_SOURCE_TYPES="recent papers,arXiv papers,GitHub repositories,technical blogs,benchmarks,datasets,frameworks"
RESEARCH_METHOD_HINTS="Prioritize items that can become experiments, benchmarks, datasets, or implementation ideas."
OUTPUT_LANGUAGE=ko
TOP_K=5
CODEX_WEB_SEARCH_MODE=live
```

Values with spaces should stay inside quotes because this file is sourced by Bash.

The prompt reads these values at runtime. To switch research areas, update `RESEARCH_DOMAIN`, `RESEARCH_FOCUS`, `RESEARCH_KEYWORDS`, and optionally `RESEARCH_QUESTIONS`, `RESEARCH_SOURCE_TYPES`, and `RESEARCH_METHOD_HINTS`; you usually do not need to edit `prompts/make_research_brief.md`.

`CODEX_WEB_SEARCH_MODE` supports:

- `live`: fetch the most recent web results, equivalent to `--search`.
- `cached`: use Codex's default cached web search.
- `disabled`: turn off web search.
- `config`: do not pass a web search override; use your Codex config.

## Manual Run

```bash
bash scripts/run_once.sh
```

The script runs:

```bash
codex --search --ask-for-approval never exec --cd "$PROJECT_ROOT" --sandbox workspace-write --output-last-message outputs/runs/YYYY_MM_DD_HH_MM/final_response.md -
```

The prompt is passed through stdin. Standard output goes to `logs/codex_stdout.log`, and standard error goes to `logs/codex_stderr.log`.

Each run writes to `outputs/runs/YYYY_MM_DD_HH_MM/` and then copies the completed files into `outputs/latest/`.

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
GIT_BRANCH=master
GIT_OUTPUT_PATHS="outputs/latest outputs/runs outputs/archive"
```

Then run:

```bash
bash scripts/push_outputs.sh
```

Important: generated Markdown outputs are no longer ignored by `.gitignore`, so GitHub push can publish them. Use a private repository if the outputs contain personal research notes.

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

Generated research outputs may be committed when `ENABLE_GITHUB_PUSH=true`. Use a private repository for personal notes.

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

For VPS/server cron deployment, see `md/server_deployment.md`.

## Safety Principles

- Do not store credentials in this repo.
- Do not commit `config/research.env`.
- Keep the repository private if generated research outputs contain personal notes.
- Do not use `danger-full-access` or `--yolo` for this workflow.
- Do not force push from automation.
- Review generated research notes before making them public.
