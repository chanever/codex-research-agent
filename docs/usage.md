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
- Creates `outputs/latest` and `logs`.
- Runs `codex exec` with `--search`, `--sandbox workspace-write`, and `--ask-for-approval never`.
- Writes Codex stdout to `logs/codex_stdout.log`.
- Writes Codex stderr to `logs/codex_stderr.log`.
- Writes the final Codex response to `outputs/latest/final_response.md`.

## Generated Files

The prompt asks Codex to generate:

- `outputs/latest/daily_research_brief.md`
- `outputs/latest/papers_to_read.md`
- `outputs/latest/research_ideas.md`

## Final Response

`outputs/latest/final_response.md` contains the final response from Codex. It should briefly list the generated files, the top three actions, and any limitations.
