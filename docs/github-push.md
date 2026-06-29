# GitHub Push

`scripts/push_outputs.sh` can commit and push generated outputs, but it is disabled by default.

## Enable

In `config/research.env`:

```env
ENABLE_GITHUB_PUSH=true
GIT_BRANCH=main
GIT_OUTPUT_PATHS="outputs/latest outputs/archive"
```

Then run:

```bash
bash scripts/push_outputs.sh
```

## Important Privacy Default

Generated Markdown outputs are ignored by Git by default:

```gitignore
outputs/latest/*.md
outputs/archive/*
```

This prevents accidentally publishing private research notes.

If you want to publish outputs to a public repository, edit `.gitignore` intentionally. For example, remove or narrow the generated output ignore rules. Then review the generated files before committing.

For ongoing automation, a private output repository is recommended. Keep the reusable template public and push personal research outputs only to a private repo.

## Commit Behavior

The script:

- Does nothing unless `ENABLE_GITHUB_PUSH=true`.
- Stages `GIT_OUTPUT_PATHS`.
- Exits successfully when there are no changes.
- Uses commit messages like `daily research brief: YYYY-MM-DD`.
- Pushes normally with `git push origin "$GIT_BRANCH"`.

It never force pushes.
