# UI Extension

This project has no UI today. It is intentionally a terminal-based public template for Codex CLI research automation.

## Possible Future Shape

A later UI could read:

- `outputs/latest/daily_research_brief.md`
- `outputs/latest/papers_to_read.md`
- `outputs/latest/research_ideas.md`
- `outputs/archive/YYYY-MM-DD/`

## Vercel / Next.js

A Next.js app could render Markdown from `outputs/latest` and provide archive navigation by date. Keep the UI as a separate app or a clearly separated folder so the terminal template remains simple.

## GitHub as Storage

If outputs are pushed to a repository, the UI can use GitHub as a simple storage layer. For private research notes, use a private repository and avoid exposing personal outputs through a public deployment.

## Render Backend

A future Render backend could provide authentication, scheduled runs, and API access to archived briefs. That backend is intentionally out of scope for this template.
