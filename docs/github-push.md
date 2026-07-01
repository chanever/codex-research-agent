# GitHub Push

`scripts/push_outputs.sh` can commit and push generated outputs, but it is disabled by default.

## Enable

In `config/research.env`:

```env
ENABLE_GITHUB_PUSH=true
GIT_BRANCH=master
GIT_OUTPUT_PATHS="outputs/latest outputs/runs outputs/archive"
```

## Prerequisites

Before enabling automatic push, confirm:

- The repository has an `origin` remote.
- The current branch matches `GIT_BRANCH`.
- The machine has permission to push to the GitHub repository.
- The repository should usually be private if generated outputs contain personal research notes.

Check:

```bash
git remote -v
git branch --show-current
git status --short
git push --dry-run origin master
```

If the dry run fails, configure one of:

- SSH key
- GitHub deploy key with write access
- GitHub CLI login
- HTTPS personal access token

## Push Once

After `ENABLE_GITHUB_PUSH=true`, run:

```bash
bash scripts/push_outputs.sh
```

This only pushes files that are already present under `GIT_OUTPUT_PATHS`.

## Run Research and Push

`scripts/run_once.sh` creates research outputs but does not push by itself.

To run the full flow manually:

```bash
bash scripts/nightly_run.sh
```

This runs:

```txt
run_once.sh
→ copy latest outputs into outputs/archive/YYYY-MM-DD/
→ push_outputs.sh
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
