# GitHub Push

`scripts/push_outputs.sh` can commit and push generated outputs, but it is disabled by default.

## Enable

In `config/research.env`:

```env
ENABLE_GITHUB_PUSH=true
GIT_BRANCH=master
GIT_OUTPUT_PATHS="outputs/latest outputs/runs outputs/archive"
```

Then run:

```bash
bash scripts/push_outputs.sh
```

## Output Tracking

Generated Markdown outputs are tracked by Git so they can be pushed and viewed from GitHub:

```txt
outputs/latest
outputs/runs
outputs/archive
```

Use a private repository when outputs contain personal research notes. If you keep the template public, consider using a separate private output repository.

## Commit Behavior

The script:

- Does nothing unless `ENABLE_GITHUB_PUSH=true`.
- Stages `GIT_OUTPUT_PATHS`.
- Exits successfully when there are no changes.
- Uses commit messages like `daily research brief: YYYY-MM-DD`.
- Pushes normally with `git push origin "$GIT_BRANCH"`.

It never force pushes.
