# Usage

`scripts/run_once.sh` runs the research workflow once.

## Setup

```bash
cp config/research.env.example config/research.env
```

Edit `config/research.env` to set your research domain, focus, keywords, output language, and Codex CLI options.

Before a real run, check the local environment:

```bash
bash scripts/check_server_ready.sh
```

## Change Research Topic

Most topic changes only require editing `config/research.env`; you usually do not need to edit `prompts/make_research_brief.md`.

Example for a different research field:

```env
RESEARCH_DOMAIN="Robotics Foundation Models"
RESEARCH_FOCUS="vision-language-action models for household manipulation"
RESEARCH_KEYWORDS="VLA model,robot foundation model,RT-2,OpenVLA,manipulation benchmark,embodied AI"
RESEARCH_QUESTIONS="Which recent VLA models are reproducible, and what benchmarks should I compare first?"
RESEARCH_SOURCE_TYPES="recent papers,arXiv papers,GitHub repositories,benchmarks,datasets,technical blogs"
RESEARCH_METHOD_HINTS="Prioritize open-source models, available datasets, benchmark protocols, and low-cost reproduction paths."
OUTPUT_LANGUAGE=ko
TOP_K=5
```

`scripts/run_once.sh` injects these values into the prompt at runtime, and `prompts/make_research_brief.md` uses them as the source of truth for the research topic.

## Run Once

```bash
bash scripts/run_once.sh
```

The script:

- Sources `config/research.env` when present.
- Creates `outputs/runs/YYYY_MM_DD_HH_MM`, `outputs/latest`, and `logs`.
- Runs `codex exec` with the configured `CODEX_SANDBOX` and `--ask-for-approval never`.
- Uses `CODEX_WEB_SEARCH_MODE=live` by default, which passes `--search`.
- Writes Codex stdout to `logs/codex_stdout.log`.
- Writes Codex stderr to `logs/codex_stderr.log`.
- Writes the final Codex response to `outputs/runs/YYYY_MM_DD_HH_MM/final_response.md`.
- Copies completed run files into `outputs/latest`.

## Sandbox Notes

`CODEX_SANDBOX` controls how much filesystem and command access Codex has while generating files.

- `workspace-write`: safer default when it works; writes are limited to the workspace.
- `danger-full-access`: no Codex sandbox restrictions; useful on Linux servers where `workspace-write` fails because of `bwrap`/namespace permissions.

If `logs/codex_stderr.log` contains:

```txt
bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted
```

set this in `config/research.env` on that server:

```env
CODEX_SANDBOX=danger-full-access
```

Use `danger-full-access` only for trusted repositories and prompts.

## Generated Files

The prompt asks Codex to generate:

- `outputs/runs/YYYY_MM_DD_HH_MM/daily_research_brief.md`
- `outputs/runs/YYYY_MM_DD_HH_MM/papers_to_read.md`
- `outputs/runs/YYYY_MM_DD_HH_MM/research_ideas.md`

`outputs/latest` contains a copy of the newest completed run.

The generated brief is designed to be readable for someone who does not already know every paper or benchmark. It includes background knowledge, key-term explanations, example scenarios, and research ideas structured with implementation plans, benchmark candidates, baselines, and expected contributions.

## Final Response

`outputs/runs/YYYY_MM_DD_HH_MM/final_response.md` contains the final response from Codex for that run. `outputs/latest/final_response.md` is copied from the newest completed run.

## Web Search Mode

Set `CODEX_WEB_SEARCH_MODE` in `config/research.env`:

- `live`: pass `--search` and fetch the most recent web results.
- `cached`: use Codex's cached web search.
- `disabled`: turn off web search.
- `config`: do not pass a search override; use your Codex config.
