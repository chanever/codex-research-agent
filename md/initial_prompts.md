# Initial Prompt for Codex

아래 프롬프트는 처음 보는 개발자가 Codex에 그대로 넣어 `codex-research-agent` 프로젝트를 재현할 수 있도록 만든 초기 구현 프롬프트다.

```md
# Role

너는 배포 가능한 오픈소스용 Codex Research Agent 프로젝트를 구현하는 개발 에이전트다.

이 프로젝트는 사용자가 Codex CLI의 `codex exec`를 사용해서 최신 연구 자료를 조사하고, 3개의 Markdown 리서치 결과물을 생성하도록 돕는 터미널 기반 프로젝트다.

중요:

- 웹 UI를 만들지 마라.
- Notion 연동을 만들지 마라.
- DB를 만들지 마라.
- API 서버를 만들지 마라.
- Python 앱을 만들지 마라.
- 지금 목표는 public GitHub repo에 업로드할 수 있는 재사용 가능한 프로젝트 템플릿을 만드는 것이다.

---

# Project Name

프로젝트 폴더 이름은 다음으로 하라.

```txt
codex-research-agent
```

---

# Main Goal

이 프로젝트는 다음 흐름으로 동작해야 한다.

```txt
사용자 clone
→ config/research.env.example을 config/research.env로 복사
→ 사용자가 연구 주제 설정
→ bash scripts/run_once.sh 실행
→ Codex CLI 실행
→ outputs/runs/YYYY_MM_DD_HH_MM/에 3개 Markdown 파일과 final_response.md 생성
→ outputs/latest/에 최신 실행 결과 복사
→ 선택적으로 archive 저장
→ 선택적으로 GitHub에 outputs push
```

---

# Public Repository Safety

이 프로젝트는 public GitHub repo로 공개될 수 있어야 한다.

GitHub에 올라가야 하는 것:

```txt
prompts/
scripts/
config/research.env.example
examples/
docs/
md/
README.md
.gitignore
LICENSE
outputs/latest/.gitkeep
outputs/runs/.gitkeep
outputs/archive/.gitkeep
logs/.gitkeep
```

GitHub에 올라가면 안 되는 것:

```txt
config/research.env
.env
.env.*
logs/*.log
logs/*.jsonl
credential
token
Codex login 정보
GitHub token
```

생성된 outputs는 GitHub 모바일 앱에서 보기 위해 push할 수 있다. 단, 개인 연구 내용이 포함될 수 있으므로 repo를 private으로 운영하는 것을 권장한다.

---

# Target Project Structure

다음 구조를 생성하라.

```txt
codex-research-agent/
  prompts/
    make_research_brief.md

  scripts/
    run_once.sh
    nightly_run.sh
    push_outputs.sh
    setup_cron.example.sh

  config/
    research.env.example

  outputs/
    latest/
      .gitkeep
    runs/
      .gitkeep
    archive/
      .gitkeep

  examples/
    sample_daily_research_brief.md
    sample_papers_to_read.md
    sample_research_ideas.md

  logs/
    .gitkeep

  docs/
    usage.md
    cron.md
    github-push.md
    customization.md
    ui-extension.md

  md/
    initial_prompts.md
    problems.md

  README.md
  .gitignore
  LICENSE
```

---

# Core Behavior

## scripts/run_once.sh

이 스크립트는 Codex Research Agent를 한 번 실행한다.

요구사항:

1. `set -euo pipefail` 사용
2. 프로젝트 루트 자동 계산
3. `config/research.env`가 있으면 source
4. 없으면 warning만 출력하고 기본값 사용
5. `outputs/runs/YYYY_MM_DD_HH_MM`, `outputs/latest`, `logs` 디렉토리 생성
6. `codex exec` 실행
7. `--sandbox workspace-write` 사용
8. `--ask-for-approval never` 사용
9. 프롬프트는 stdin으로 전달
10. stdout은 `logs/codex_stdout.log`에 저장
11. stderr는 `logs/codex_stderr.log`에 저장
12. final response는 해당 run directory의 `final_response.md`에 저장
13. 성공 후 run directory의 결과 파일을 `outputs/latest/`로 복사

지원할 환경변수:

```env
CODEX_BIN=codex
CODEX_SANDBOX=workspace-write
CODEX_APPROVAL=never
CODEX_WEB_SEARCH_MODE=live
CODEX_OUTPUT_LAST_MESSAGE=
OUTPUT_RUN_DIR=
OUTPUT_LATEST_DIR=outputs/latest
```

`OUTPUT_RUN_DIR`가 비어 있으면 다음 형식으로 자동 생성하라.

```txt
outputs/runs/YYYY_MM_DD_HH_MM
```

`CODEX_WEB_SEARCH_MODE`는 다음 값을 지원하라.

```txt
live      # --search 사용, 최신 웹 검색
cached    # -c 'web_search="cached"' 사용
disabled  # -c 'web_search="disabled"' 사용
config    # 웹 검색 옵션을 넘기지 않고 사용자 Codex config를 따름
```

현재 Codex CLI에서는 `--search`와 `--ask-for-approval`이 `exec` 뒤가 아니라 전역 옵션으로 동작할 수 있으므로, 실행 형태는 다음을 기준으로 하라.

```bash
cat prompts/make_research_brief.md | codex \
  --search \
  --ask-for-approval never \
  exec \
  --cd "$PROJECT_ROOT" \
  --sandbox workspace-write \
  --output-last-message outputs/runs/YYYY_MM_DD_HH_MM/final_response.md \
  -
```

단, 실제 스크립트에서는 환경변수와 배열을 사용해 안전하게 인자를 구성하라.

---

## scripts/nightly_run.sh

이 스크립트는 밤마다 실행할 용도다.

요구사항:

1. `set -euo pipefail` 사용
2. 프로젝트 루트 자동 계산
3. `config/research.env`가 있으면 source
4. `TIMEZONE` 기본값은 `Asia/Seoul`
5. `scripts/run_once.sh` 실행
6. 실행 후 오늘 날짜 기준 archive 폴더 생성
7. `outputs/latest`의 아래 파일들을 archive로 복사

```txt
daily_research_brief.md
papers_to_read.md
research_ideas.md
final_response.md
```

8. archive 경로:

```txt
outputs/archive/YYYY-MM-DD/
```

9. `scripts/push_outputs.sh` 실행
10. GitHub push가 꺼져 있어도 nightly run 자체는 성공해야 함

---

## scripts/push_outputs.sh

이 스크립트는 생성된 outputs를 GitHub에 commit/push한다.

요구사항:

1. `set -euo pipefail` 사용
2. 프로젝트 루트 자동 계산
3. `config/research.env`가 있으면 source
4. `ENABLE_GITHUB_PUSH=false`가 기본값
5. `ENABLE_GITHUB_PUSH=true`일 때만 commit/push 실행
6. `GIT_BRANCH` 기본값은 `master`
7. `GIT_OUTPUT_PATHS` 설정 지원
8. 기본 commit 대상:

```txt
outputs/latest outputs/runs outputs/archive
```

9. 변경사항이 없으면 commit하지 않고 정상 종료
10. commit message 형식:

```txt
daily research brief: YYYY-MM-DD
```

11. force push 금지
12. token이나 credential 출력 금지

---

## scripts/setup_cron.example.sh

cron 등록 예시 스크립트다.

요구사항:

1. 실제로 crontab을 수정하지 말고, 사용자가 복사해서 쓸 수 있는 예시를 출력하라.
2. 한국 시간 기준 매일 새벽 1시 30분 실행 예시를 포함하라.

예시:

```cron
TZ=Asia/Seoul
30 1 * * * cd /path/to/codex-research-agent && bash scripts/nightly_run.sh >> logs/cron.log 2>&1
```

---

# config/research.env.example

아래 값을 포함하라.

```env
# ===== Research Settings =====
RESEARCH_DOMAIN="LLM Agent Security"
RESEARCH_FOCUS="execution graph based detection for malicious tool-use agents"
RESEARCH_KEYWORDS="prompt injection,indirect prompt injection,tool-use security,MCP security,malicious package detection,sandbox verification,provenance graph,execution graph,tool poisoning,agentic workflow security,coding agent security,browser agent security,software supply chain attack,package install attack,syscall tracing,strace,Docker sandbox"
RESEARCH_QUESTIONS="How can execution/provenance graphs reveal malicious or risky tool-use behavior in agents?"
RESEARCH_SOURCE_TYPES="recent papers,arXiv papers,GitHub repositories,technical blogs,benchmarks,datasets,frameworks"
RESEARCH_METHOD_HINTS="Prioritize items that can become experiments, benchmarks, datasets, or implementation ideas."
OUTPUT_LANGUAGE=ko
TOP_K=5
MIN_RELEVANCE_SCORE=7.0

# ===== Runtime =====
TIMEZONE=Asia/Seoul
OUTPUT_RUN_DIR=
OUTPUT_LATEST_DIR=outputs/latest

# ===== Codex CLI =====
CODEX_BIN=codex
CODEX_SANDBOX=workspace-write
CODEX_APPROVAL=never
CODEX_WEB_SEARCH_MODE=live
CODEX_OUTPUT_LAST_MESSAGE=

# ===== GitHub Push =====
ENABLE_GITHUB_PUSH=false
GIT_BRANCH=master
GIT_OUTPUT_PATHS="outputs/latest outputs/runs outputs/archive"
```

---

# prompts/make_research_brief.md Requirements

`prompts/make_research_brief.md`는 실제 Codex가 연구 브리핑을 만들 때 읽는 프롬프트다.

이 프롬프트는 반드시 다음을 지시해야 한다.

1. 오직 아래 3개 md 파일만 생성할 것. 단, wrapper가 runtime output path를 제공하면 그 경로를 우선 사용하라.

```txt
OUTPUT_DAILY_RESEARCH_BRIEF
OUTPUT_PAPERS_TO_READ
OUTPUT_RESEARCH_IDEAS
```

기본 fallback:

```txt
outputs/latest/daily_research_brief.md
outputs/latest/papers_to_read.md
outputs/latest/research_ideas.md
```

2. 앱, 서버, DB, Notion, UI를 만들지 말 것
3. 웹 검색을 사용해 최신 자료를 조사할 것
4. freshness를 확인하지 못한 내용은 `freshness 확인 필요`라고 표시할 것
5. 논문 본문을 읽지 못하고 abstract만 봤으면 `abstract 기반 요약`이라고 표시할 것
6. 각 자료에 `Relevance Score` 0~10을 부여할 것
7. 출처 URL을 반드시 포함할 것
8. 연구 아이디어는 최소 5개 작성할 것
9. 출력 언어는 기본 한국어로 할 것
10. 논문 제목, repo 이름, benchmark 이름은 영어 원문을 유지할 것
11. 최종 응답은 생성한 파일 목록과 Top 3 Actions만 간단히 보고할 것

---

# Output File Templates

## daily_research_brief.md

```md
# Daily Research Brief

## Research Focus

...

## Today's Summary

...

## Recommended Items Top 5

### 1. Title

- Type:
- Source:
- URL:
- Date:
- Relevance Score:
- Why it matters:
- Key idea:
- Limitation / uncertainty:
- Connection to my research:
- Possible experiment:

## Today's Top 3 Actions

1.
2.
3.

## Human Verification Needed

-

## Source List

-
```

## papers_to_read.md

```md
# Papers / Repositories to Read

## High Priority

### 1. Title

- Type:
- URL:
- Relevance Score:
- Why read first:
- Expected value:
- Related keywords:
- Reading notes:

## Medium Priority

...

## Low Priority

...

## Reading Plan

### 30-minute plan

-

### 2-hour plan

-

### Deep reading plan

-
```

## research_ideas.md

```md
# Research Ideas

## Idea 1. Title

- Hypothesis:
- Motivation:
- Required data:
- Method:
- Evaluation:
- Expected difficulty:
- Risk / limitation:
- Connection to research focus:
- Connection to key concepts:
- Connection to evaluation / validation:
- First experiment:

최소 5개 아이디어를 작성하라.

## Experiment Backlog

### Easy

-

### Medium

-

### Hard

-

## Possible Paper Angle

-

## Next Research Question

-
```

---

# Examples

`examples/`에는 샘플 파일 3개를 생성하라.

주의:

- 실제 최신 논문이라고 단정하지 마라.
- 예시임을 명확히 표시하라.
- source URL은 placeholder 또는 example 형태로 둬도 된다.

파일:

```txt
examples/sample_daily_research_brief.md
examples/sample_papers_to_read.md
examples/sample_research_ideas.md
```

---

# .gitignore

다음을 포함하라.

```gitignore
# secrets
.env
.env.*
config/research.env

# logs
logs/*.log
logs/*.jsonl

# keep directory placeholders
!logs/.gitkeep

# OS/editor
.DS_Store
.vscode/
.idea/

# temp
tmp/
.cache/
```

README에는 다음을 명확히 써라.

```txt
Generated outputs are intended to be pushed to your configured GitHub repository so they can be read from the GitHub mobile app. Keep the repository private if the notes contain personal research context.
```

---

# Docs

다음 문서를 생성하라.

```txt
docs/usage.md
docs/cron.md
docs/github-push.md
docs/customization.md
docs/ui-extension.md
```

각 문서에는 실행 방법, cron, GitHub push, 커스터마이징, 나중에 UI로 확장하는 방법을 설명하라.

---

# LICENSE

MIT License를 생성하라.

---

# Safety Rules

반드시 지켜라.

1. 실제 credential을 생성하거나 저장하지 마라.
2. `.env` 또는 `config/research.env`를 생성하지 마라.
3. `danger-full-access` 또는 `--yolo` 옵션을 사용하지 마라.
4. force push하지 마라.
5. 기존 파일을 삭제하지 마라.
6. UI, Notion, DB, API 서버를 만들지 마라.
7. logs와 credentials는 기본적으로 Git에 올라가지 않게 하라.
8. generated outputs는 GitHub 앱에서 보기 위해 추적 가능하게 하되, private repo 사용을 권장하라.
9. 스크립트에서 token 값을 echo하지 마라.

---

# Verification

구현 후 다음을 수행하라.

1. 파일 구조 확인
2. shell scripts 문법 확인

```bash
bash -n scripts/run_once.sh
bash -n scripts/nightly_run.sh
bash -n scripts/push_outputs.sh
bash -n scripts/setup_cron.example.sh
```

3. 실행 권한 부여

```bash
chmod +x scripts/run_once.sh scripts/nightly_run.sh scripts/push_outputs.sh scripts/setup_cron.example.sh
```

4. 가능하면 짧은 smoke prompt로 `run_once.sh`가 `outputs/runs/...`와 `outputs/latest`에 파일을 만드는지 확인하라.

---

# Final Response

최종 응답은 간결하게 작성하라.

포함할 것:

```md
## Implementation Summary

- Created project:
- Created files:
- Main run command:
- Output directory behavior:
- Web search behavior:
- GitHub push behavior:
- Private output policy:
- Verification:
- Notes / limitations:
```
```
