# codex-research-agent

`codex-research-agent`는 Codex CLI를 이용해 연구 주제를 자동으로 조사하고, 매 실행마다 Markdown 형식의 리서치 결과물을 생성하는 터미널 기반 프로젝트입니다.

이 프로젝트의 목적은 단순합니다.

```txt
정해둔 연구 주제
→ Codex CLI가 웹 검색으로 최신 자료 조사
→ Markdown 리서치 브리프 생성
→ GitHub에 자동 push
→ GitHub 앱에서 핸드폰으로 바로 확인
```

웹 UI, 데이터베이스, API 서버, Notion 연동, Python 앱은 포함하지 않습니다. 이 프로젝트는 서버나 개인 컴퓨터에서 `bash` 스크립트와 `cron`으로 돌아가는 가벼운 연구 자동화 템플릿입니다.

---

## 이 프로젝트가 하는 일

사용자가 `config/research.env`에 연구 분야와 키워드를 적어두면, `scripts/run_once.sh`가 Codex CLI를 실행합니다.

Codex는 설정된 연구 주제를 기준으로 웹 검색을 수행하고, 아래 3개의 Markdown 파일을 생성합니다.

```txt
daily_research_brief.md
papers_to_read.md
research_ideas.md
```

각 실행 결과는 실행 시각별 폴더에 저장됩니다.

```txt
outputs/runs/YYYY_MM_DD_HH_MM/
```

예:

```txt
outputs/runs/2026_06_29_01_30/
```

가장 최신 결과는 항상 아래 폴더에도 복사됩니다.

```txt
outputs/latest/
```

따라서 핸드폰 GitHub 앱에서는 보통 아래 파일만 열어보면 됩니다.

```txt
outputs/latest/daily_research_brief.md
outputs/latest/papers_to_read.md
outputs/latest/research_ideas.md
```

---

## 생성되는 파일

### `daily_research_brief.md`

하루 리서치 요약 파일입니다.

포함 내용:

- 오늘 조사한 자료 요약
- 추천 자료 Top N
- 각 자료의 URL
- 날짜
- relevance score
- 왜 중요한지
- 내 연구와의 연결점
- 가능한 실험 아이디어
- 오늘 할 Top 3 action

### `papers_to_read.md`

논문, GitHub repository, benchmark, dataset, framework 등을 우선순위별로 정리한 읽기 목록입니다.

포함 내용:

- High / Medium / Low priority
- 먼저 읽어야 하는 이유
- 기대되는 가치
- 관련 키워드
- 30분 / 2시간 / deep reading plan

### `research_ideas.md`

조사한 자료를 바탕으로 만들 수 있는 연구 아이디어 목록입니다.

포함 내용:

- 최소 5개 이상의 연구 아이디어
- 가설
- 필요한 데이터
- 방법론
- 평가 방법
- 예상 난이도
- 한계
- 첫 실험 제안

### `final_response.md`

Codex 실행이 끝난 뒤 마지막 응답을 저장한 파일입니다.

주로 아래 내용을 빠르게 확인할 때 사용합니다.

- 생성된 파일 목록
- 오늘의 Top 3 action
- 실행 중 확인된 제한사항

---

## 전체 폴더 구조

```txt
codex-research-agent/
  prompts/
    make_research_brief.md

  scripts/
    run_once.sh
    nightly_run.sh
    push_outputs.sh
    setup_cron.example.sh
    check_server_ready.sh

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

  docs/
    usage.md
    cron.md
    github-push.md
    customization.md
    ui-extension.md

  md/
    initial_prompts.md
    problems.md
    usage.md
    server_deployment.md

  logs/
    .gitkeep

  README.md
  .gitignore
  LICENSE
```

---

## 필요한 준비물

로컬 또는 서버에 아래가 필요합니다.

```txt
Git
Codex CLI
Codex 로그인
bash
cron 또는 system scheduler
GitHub repository
```

확인 명령:

```bash
git --version
which codex
codex --version
```

Codex CLI가 로그인되어 있는지도 확인합니다.

```bash
codex
```

---

## 빠른 시작

```bash
git clone https://github.com/YOUR_NAME/codex-research-agent.git
cd codex-research-agent
cp config/research.env.example config/research.env
bash scripts/run_once.sh
```

실행 후 결과 확인:

```bash
ls -la outputs/latest
cat outputs/latest/final_response.md
```

개별 결과 확인:

```bash
cat outputs/latest/daily_research_brief.md
cat outputs/latest/papers_to_read.md
cat outputs/latest/research_ideas.md
```

---

## 연구 주제 바꾸는 방법

연구 분야는 `config/research.env`에서 바꿉니다.

```bash
nano config/research.env
```

주로 수정할 값은 아래입니다.

```env
RESEARCH_DOMAIN="LLM Agent Security"
RESEARCH_FOCUS="execution graph based detection for malicious tool-use agents"
RESEARCH_KEYWORDS="prompt injection,indirect prompt injection,tool-use security,MCP security"
RESEARCH_QUESTIONS="How can execution/provenance graphs reveal malicious or risky tool-use behavior in agents?"
RESEARCH_SOURCE_TYPES="recent papers,arXiv papers,GitHub repositories,technical blogs,benchmarks,datasets,frameworks"
RESEARCH_METHOD_HINTS="Prioritize items that can become experiments, benchmarks, datasets, or implementation ideas."
OUTPUT_LANGUAGE=ko
TOP_K=5
```

값에 공백이 있으면 따옴표를 유지해야 합니다. `config/research.env`는 Bash에서 `source`되는 파일이기 때문입니다.

다른 분야로 바꾸는 예:

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

대부분의 경우 연구 주제를 바꾸기 위해 `prompts/make_research_brief.md`를 직접 수정할 필요는 없습니다. `run_once.sh`가 `research.env` 값을 프롬프트 앞에 주입하고, 프롬프트는 그 값을 기준으로 조사합니다.

프롬프트 자체를 수정해야 하는 경우는 출력 형식이나 워크플로우를 바꾸고 싶을 때입니다.

예:

- `research_ideas.md` 구조를 바꾸고 싶을 때
- 논문만 조사하고 GitHub repository는 제외하고 싶을 때
- relevance score 기준을 바꾸고 싶을 때
- 결과 파일을 3개가 아니라 4개로 늘리고 싶을 때

---

## 웹 검색 모드

웹 검색 동작은 `CODEX_WEB_SEARCH_MODE`로 제어합니다.

```env
CODEX_WEB_SEARCH_MODE=live
```

지원 값:

```txt
live      최신 웹 검색 사용. Codex CLI의 --search와 동일한 목적
cached    Codex의 cached web search 사용
disabled  웹 검색 끔
config    스크립트에서 검색 옵션을 넘기지 않고 사용자 Codex config를 따름
```

최신 논문이나 보안 글을 찾는 목적이라면 `live`를 권장합니다.

빠른 테스트나 네트워크 노출을 줄이고 싶다면 `cached` 또는 `config`를 사용할 수 있습니다.

---

## 한 번 실행하기

```bash
bash scripts/run_once.sh
```

이 스크립트는 내부적으로 Codex CLI를 실행합니다.

개념적으로는 아래와 비슷합니다.

```bash
codex --search --ask-for-approval never exec \
  --cd "$PROJECT_ROOT" \
  --sandbox workspace-write \
  --output-last-message outputs/runs/YYYY_MM_DD_HH_MM/final_response.md \
  -
```

실제 명령은 `CODEX_WEB_SEARCH_MODE`, `CODEX_BIN`, `CODEX_SANDBOX` 등 설정값에 따라 조립됩니다.

실행 중 로그는 아래에 저장됩니다.

```txt
logs/codex_stdout.log
logs/codex_stderr.log
```

진행 상황 확인:

```bash
tail -f logs/codex_stderr.log
```

---

## 빠른 smoke test

전체 리서치 프롬프트는 시간이 오래 걸릴 수 있습니다. 서버 설정이나 Codex CLI 상태만 빠르게 확인하려면 smoke test를 먼저 실행합니다.

```bash
cat > /tmp/codex-research-agent-smoke-prompt.md <<'EOF'
Create exactly the three runtime output files specified in the Runtime Configuration:
OUTPUT_DAILY_RESEARCH_BRIEF, OUTPUT_PAPERS_TO_READ, and OUTPUT_RESEARCH_IDEAS.
Put one short line in each file.
Do not create any other files.
Reply briefly.
EOF

PROMPT_FILE=/tmp/codex-research-agent-smoke-prompt.md \
OUTPUT_RUN_DIR=outputs/runs/smoke_test \
CODEX_WEB_SEARCH_MODE=config \
bash scripts/run_once.sh
```

확인:

```bash
find outputs/runs/smoke_test -maxdepth 1 -type f -print
ls -la outputs/latest
cat outputs/latest/final_response.md
```

이 테스트가 통과하면 아래가 정상이라는 뜻입니다.

- Codex CLI 실행
- Codex 인증
- workspace-write sandbox에서 파일 생성
- runtime output path 전달
- `outputs/latest` 복사
- `final_response.md` 저장

---

## 밤마다 자동 실행하기

자동 실행용 스크립트는 아래입니다.

```bash
bash scripts/nightly_run.sh
```

이 스크립트는 다음 순서로 동작합니다.

```txt
run_once.sh 실행
→ outputs/runs/YYYY_MM_DD_HH_MM/ 생성
→ outputs/latest/ 갱신
→ outputs/archive/YYYY-MM-DD/에 복사
→ push_outputs.sh 실행
→ 설정이 켜져 있으면 GitHub에 commit/push
```

cron 예시 출력:

```bash
bash scripts/setup_cron.example.sh
```

예:

```cron
TZ=Asia/Seoul
30 1 * * * cd /path/to/codex-research-agent && bash scripts/nightly_run.sh >> logs/cron.log 2>&1
```

위 설정은 한국 시간 기준 매일 새벽 1시 30분에 실행합니다.

---

## GitHub push 설정

GitHub push는 기본적으로 꺼져 있습니다.

```env
ENABLE_GITHUB_PUSH=false
```

자동 push를 켜려면 `config/research.env`에서 아래처럼 설정합니다.

```env
ENABLE_GITHUB_PUSH=true
GIT_BRANCH=master
GIT_OUTPUT_PATHS="outputs/latest outputs/runs outputs/archive"
GIT_PULL_BEFORE_PUSH=true
GIT_COMMIT_USER_NAME=codex-research-agent
GIT_COMMIT_USER_EMAIL=codex-research-agent@users.noreply.github.com
```

수동 push 테스트:

```bash
bash scripts/push_outputs.sh
```

이 프로젝트는 GitHub 앱에서 Markdown 결과를 바로 보기 위해 generated outputs를 Git에 올릴 수 있게 되어 있습니다.

따라서 개인 연구 내용이 들어간다면 GitHub repository를 private으로 운영하는 것을 권장합니다.

---

## 서버에 배포해서 운영하기

항상 자동으로 실행하려면 노트북보다는 서버나 VPS에서 돌리는 것이 안정적입니다.

서버 운영 흐름:

```txt
GitHub에 프로젝트 push
→ 서버에서 git clone
→ Codex CLI 설치 및 로그인
→ config/research.env 생성
→ scripts/check_server_ready.sh 실행
→ scripts/nightly_run.sh 수동 테스트
→ cron 등록
→ GitHub 앱에서 outputs/latest/*.md 확인
```

서버 준비 상태 확인:

```bash
bash scripts/check_server_ready.sh
```

자세한 서버 배포 가이드는 아래 문서를 참고하세요.

```txt
md/server_deployment.md
```

---

## 핸드폰에서 보는 방법

추천 방식은 GitHub private repository에 결과 Markdown을 push하고, GitHub 모바일 앱에서 보는 것입니다.

GitHub 앱에서 주로 볼 파일:

```txt
outputs/latest/daily_research_brief.md
outputs/latest/papers_to_read.md
outputs/latest/research_ideas.md
```

GitHub는 Markdown을 자동 렌더링하므로, 핸드폰에서도 읽기 편합니다.

---

## Git에 올라가면 안 되는 것

아래 파일은 GitHub에 올리면 안 됩니다.

```txt
config/research.env
.env
.env.*
logs/*.log
logs/*.jsonl
Codex auth 파일
GitHub token
credential
```

현재 `.gitignore`는 위 항목들을 무시합니다.

반대로 아래 outputs는 GitHub 앱에서 보기 위해 Git에 올라갈 수 있습니다.

```txt
outputs/latest/*.md
outputs/runs/**/*
outputs/archive/**/*
```

민감한 연구 내용이 포함될 수 있으므로 private repository 사용을 권장합니다.

---

## 로그 확인

```bash
cat logs/codex_stdout.log
cat logs/codex_stderr.log
cat logs/cron.log
```

실행 중에는:

```bash
tail -f logs/codex_stderr.log
```

cron 실행 후에는:

```bash
cat logs/cron.log
```

---

## 자주 생기는 문제

### `codex: command not found`

확인:

```bash
which codex
codex --version
```

cron에서만 실패한다면 `config/research.env`에 Codex 절대경로를 넣습니다.

```env
CODEX_BIN=/usr/local/bin/codex
```

### 결과 파일이 생성되지 않음

로그 확인:

```bash
cat logs/codex_stderr.log
```

가능한 원인:

- Codex CLI 미설치
- Codex 로그인 안 됨
- 웹 검색 또는 모델 실행이 오래 걸림
- `config/research.env` 설정 오류
- `CODEX_WEB_SEARCH_MODE=live`인데 현재 Codex CLI가 `--search`를 지원하지 않음

### GitHub push가 안 됨

확인:

```bash
git remote -v
git branch --show-current
git status --short
git pull --ff-only origin master
git push origin master
```

가능한 원인:

- 서버에 GitHub push 권한 없음
- branch 이름 불일치
- private repo 인증 실패
- Git commit identity 없음
- protected branch 정책

### 전체 실행이 너무 오래 걸림

조정할 수 있는 값:

```env
TOP_K=3
CODEX_WEB_SEARCH_MODE=cached
RESEARCH_KEYWORDS="핵심 키워드 5개 정도"
```

먼저 smoke test로 기본 실행이 되는지 확인한 뒤 전체 리서치를 실행하는 것이 좋습니다.

---

## 참고 문서

프로젝트 내부 문서:

```txt
docs/usage.md
docs/cron.md
docs/github-push.md
docs/customization.md
docs/ui-extension.md
md/usage.md
md/server_deployment.md
md/problems.md
md/initial_prompts.md
```

각 문서의 역할:

- `docs/usage.md`: 간단한 실행 설명
- `docs/cron.md`: cron 설정
- `docs/github-push.md`: GitHub push 설명
- `docs/customization.md`: 연구 주제와 프롬프트 커스터마이징
- `docs/ui-extension.md`: 나중에 UI로 확장하는 방향
- `md/usage.md`: 더 자세한 사용 가이드
- `md/server_deployment.md`: 서버 배포 가이드
- `md/problems.md`: 개발 중 겪은 문제와 해결 기록
- `md/initial_prompts.md`: 이 프로젝트를 Codex로 재현하기 위한 초기 프롬프트

---

## 안전 원칙

- `config/research.env`를 commit하지 않습니다.
- `.env` 파일을 commit하지 않습니다.
- Codex 로그인 정보나 token을 저장소에 넣지 않습니다.
- GitHub token을 파일로 저장하지 않습니다.
- `danger-full-access` 또는 `--yolo`를 기본 실행 옵션으로 쓰지 않습니다.
- 자동화가 force push를 하지 않도록 합니다.
- outputs를 GitHub에 올릴 경우 repository를 private으로 유지하는 것을 권장합니다.
- public repository에 outputs를 올리기 전에는 민감한 내용이 없는지 반드시 확인합니다.
