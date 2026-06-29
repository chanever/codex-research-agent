# Usage

`scripts/run_once.sh` runs the research workflow once.

## Setup

```bash
cp config/research.env.example config/research.env
```

Edit `config/research.env` to set your research domain, focus, keywords, output language, and Codex CLI options.

## Run Once

```bash
bash scripts/run_once.sh
```

The script:

- Sources `config/research.env` when present.
- Creates `outputs/runs/YYYY_MM_DD_HH_MM`, `outputs/latest`, and `logs`.
- Runs `codex exec` with `--sandbox workspace-write` and `--ask-for-approval never`.
- Uses `CODEX_WEB_SEARCH_MODE=live` by default, which passes `--search`.
- Writes Codex stdout to `logs/codex_stdout.log`.
- Writes Codex stderr to `logs/codex_stderr.log`.
- Writes the final Codex response to `outputs/runs/YYYY_MM_DD_HH_MM/final_response.md`.
- Copies completed run files into `outputs/latest`.

## Generated Files

The prompt asks Codex to generate:

- `outputs/runs/YYYY_MM_DD_HH_MM/daily_research_brief.md`
- `outputs/runs/YYYY_MM_DD_HH_MM/papers_to_read.md`
- `outputs/runs/YYYY_MM_DD_HH_MM/research_ideas.md`

`outputs/latest` contains a copy of the newest completed run.

## Final Response

`outputs/runs/YYYY_MM_DD_HH_MM/final_response.md` contains the final response from Codex for that run. `outputs/latest/final_response.md` is copied from the newest completed run.

## Web Search Mode

Set `CODEX_WEB_SEARCH_MODE` in `config/research.env`:

- `live`: pass `--search` and fetch the most recent web results.
- `cached`: use Codex's cached web search.
- `disabled`: turn off web search.
- `config`: do not pass a search override; use your Codex config.
