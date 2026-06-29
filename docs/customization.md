# Customization

Customize the project through `config/research.env` and `prompts/make_research_brief.md`.

## Research Settings

Copy the example config:

```bash
cp config/research.env.example config/research.env
```

Then edit:

```env
RESEARCH_DOMAIN="LLM Agent Security"
RESEARCH_FOCUS="execution graph based detection for malicious tool-use agents"
RESEARCH_KEYWORDS="prompt injection,tool-use security,MCP security"
OUTPUT_LANGUAGE=ko
TOP_K=5
MIN_RELEVANCE_SCORE=7.0
CODEX_WEB_SEARCH_MODE=live
```

## Change Research Domain

Set `RESEARCH_DOMAIN`, `RESEARCH_FOCUS`, and `RESEARCH_KEYWORDS` to your topic. Keep values with spaces inside quotes because the file is sourced by Bash.

## Change TOP_K

Set:

```env
TOP_K=10
```

Then adjust the prompt if you want more than five items in `daily_research_brief.md`.

## Change Output Language

Set:

```env
OUTPUT_LANGUAGE=en
```

The prompt still asks Codex to preserve paper titles, repository names, benchmark names, dataset names, and framework names in their original English.

## Change Web Search Mode

Set:

```env
CODEX_WEB_SEARCH_MODE=live
```

Available values:

- `live`: fetch the most recent web results.
- `cached`: use Codex's cached web search.
- `disabled`: turn off web search.
- `config`: use your Codex config without passing a search override.

## Customize the Prompt

Edit `prompts/make_research_brief.md` to change:

- Source types
- Output file sections
- Scoring criteria
- Research idea format
- Human verification requirements

Keep the rule that only the three Markdown output files should be generated unless you intentionally change the workflow.
