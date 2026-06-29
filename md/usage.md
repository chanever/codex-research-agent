# Usage Guide

이 문서는 `codex-research-agent`를 처음 받아서 실제로 실행하고 운영하는 방법을 구체적으로 설명한다.

이 프로젝트는 웹 UI, DB, API 서버, Notion 연동 없이 Codex CLI만으로 연구 브리프 Markdown 파일을 생성하는 터미널 기반 템플릿이다.

---

## 1. Prerequisites

필요한 것:

- Git
- Codex CLI
- Codex 로그인
- 인터넷 연결

확인:

```bash
git --version
which codex
codex --version
```

`codex`가 없으면 Codex CLI를 먼저 설치하고 새 터미널을 열어 다시 확인한다.

로그인 확인:

```bash
codex
```

처음 실행하면 로그인 흐름이 뜰 수 있다.

---

## 2. Clone and Setup

GitHub에서 프로젝트를 clone한다.

```bash
git clone https://github.com/YOUR_NAME/codex-research-agent.git
cd codex-research-agent
```

설정 파일을 만든다.

```bash
cp config/research.env.example config/research.env
```

`config/research.env`는 개인 설정 파일이다. `.gitignore`에 의해 GitHub에 올라가지 않는다.

---

## 3. Configure Research Topic

`config/research.env`를 열어서 연구 주제를 바꾼다.

```bash
nano config/research.env
```

주로 수정할 값:

```env
RESEARCH_DOMAIN="LLM Agent Security"
RESEARCH_FOCUS="execution graph based detection for malicious tool-use agents"
RESEARCH_KEYWORDS="prompt injection,indirect prompt injection,tool-use security,MCP security"
OUTPUT_LANGUAGE=ko
TOP_K=5
MIN_RELEVANCE_SCORE=7.0
```

값에 공백이 있으면 따옴표를 유지해야 한다.

좋은 설정 예:

```env
RESEARCH_DOMAIN="AI Agent Security"
RESEARCH_FOCUS="detecting malicious tool-use agents with provenance graphs"
RESEARCH_KEYWORDS="prompt injection,tool poisoning,MCP security,agent benchmark,provenance graph"
OUTPUT_LANGUAGE=ko
TOP_K=5
```

---

## 4. Web Search Mode

웹 검색 설정은 `CODEX_WEB_SEARCH_MODE`로 제어한다.

```env
CODEX_WEB_SEARCH_MODE=live
```

지원 값:

```txt
live      최신 웹 검색을 사용한다. Codex CLI에 --search를 붙이는 것과 같다.
cached    Codex의 cached web search를 사용한다.
disabled  웹 검색을 끈다.
config    스크립트가 검색 옵션을 넘기지 않고 사용자 Codex config를 따른다.
```

추천:

- 최신 논문, 보안 글, GitHub repo를 찾는 목적이면 `live`
- 빠른 테스트나 네트워크 노출을 줄이고 싶으면 `cached`
- 프롬프트와 파일 생성만 테스트하고 싶으면 `config` 또는 `disabled`

공식 Codex 동작 기준으로 `--search`가 없더라도 web search는 기본적으로 cached 모드일 수 있다. 하지만 최신 자료 조사가 목적이면 `live`를 권장한다.

---

## 5. Run Once

한 번 실행:

```bash
bash scripts/run_once.sh
```

내부적으로는 대략 다음 형태로 Codex CLI를 실행한다.

```bash
codex --search --ask-for-approval never exec \
  --cd "$PROJECT_ROOT" \
  --sandbox workspace-write \
  --output-last-message outputs/runs/YYYY_MM_DD_HH_MM/final_response.md \
  -
```

주의:

- 실제 명령은 `CODEX_WEB_SEARCH_MODE` 값에 따라 달라진다.
- `live`일 때만 `--search`가 붙는다.
- 프롬프트는 stdin으로 전달된다.
- stdout/stderr는 `logs/`에 저장된다.

---

## 6. Output Structure

실행할 때마다 run-specific 폴더가 생성된다.

```txt
outputs/runs/YYYY_MM_DD_HH_MM/
```

예:

```txt
outputs/runs/2026_06_29_12_40/
```

각 run 폴더에 생성되는 파일:

```txt
daily_research_brief.md
papers_to_read.md
research_ideas.md
final_response.md
```

최신 실행 결과는 자동으로 `outputs/latest/`에도 복사된다.

```txt
outputs/latest/
  daily_research_brief.md
  papers_to_read.md
  research_ideas.md
  final_response.md
```

역할:

- `outputs/runs/...`: 실행별 기록 보관
- `outputs/latest`: 가장 최근 성공 실행 결과를 빠르게 확인하는 경로
- `outputs/archive/...`: nightly run에서 날짜별로 한 번 더 보관하는 경로

---

## 7. Check Results

최신 결과 확인:

```bash
ls -la outputs/latest
cat outputs/latest/final_response.md
```

개별 파일 확인:

```bash
cat outputs/latest/daily_research_brief.md
cat outputs/latest/papers_to_read.md
cat outputs/latest/research_ideas.md
```

특정 실행 결과 확인:

```bash
find outputs/runs -maxdepth 2 -type f | sort
```

가장 최근 run 폴더 찾기:

```bash
ls -1 outputs/runs | sort | tail -n 1
```

---

## 8. Logs

Codex 실행 로그는 `logs/`에 저장된다.

```txt
logs/codex_stdout.log
logs/codex_stderr.log
```

확인:

```bash
tail -n 120 logs/codex_stderr.log
tail -n 120 logs/codex_stdout.log
```

보통 `codex exec` 진행 상황, web search 기록, 경고는 stderr 쪽에 많이 나온다.

결과 파일이 생성되지 않았으면 먼저 확인할 것:

```bash
cat logs/codex_stderr.log
```

---

## 9. Smoke Test

전체 리서치 프롬프트는 오래 걸릴 수 있다. CLI, sandbox, output path가 정상인지 빠르게 확인하려면 짧은 smoke prompt를 사용한다.

```bash
cat > /private/tmp/codex-research-agent-smoke-prompt.md <<'EOF'
Create exactly the three runtime output files specified in the Runtime Configuration:
OUTPUT_DAILY_RESEARCH_BRIEF, OUTPUT_PAPERS_TO_READ, and OUTPUT_RESEARCH_IDEAS.
Put one short line in each file.
Do not create any other files.
Reply briefly.
EOF
```

실행:

```bash
PROMPT_FILE=/private/tmp/codex-research-agent-smoke-prompt.md \
OUTPUT_RUN_DIR=outputs/runs/smoke_test \
CODEX_WEB_SEARCH_MODE=config \
bash scripts/run_once.sh
```

확인:

```bash
find outputs/runs/smoke_test -maxdepth 1 -type f -print
ls -la outputs/latest
```

이 테스트가 성공하면 다음은 정상이라는 뜻이다.

- Codex CLI 설치
- Codex 로그인
- sandbox 쓰기 권한
- runtime output path 전달
- `outputs/latest` 복사
- final response 저장

---

## 10. Nightly Run

밤마다 실행할 때는 다음 스크립트를 사용한다.

```bash
bash scripts/nightly_run.sh
```

이 스크립트는:

1. `scripts/run_once.sh` 실행
2. `outputs/latest` 결과를 `outputs/archive/YYYY-MM-DD/`에 복사
3. `scripts/push_outputs.sh` 실행

GitHub push가 꺼져 있어도 nightly run 자체는 성공해야 한다.

---

## 11. Cron Setup

cron 예시 출력:

```bash
bash scripts/setup_cron.example.sh
```

예:

```cron
TZ=Asia/Seoul
30 1 * * * cd /path/to/codex-research-agent && bash scripts/nightly_run.sh >> logs/cron.log 2>&1
```

crontab 편집:

```bash
crontab -e
```

주의:

- cron에서는 PATH가 평소 터미널과 다를 수 있다.
- `codex`를 못 찾으면 `config/research.env`의 `CODEX_BIN`에 절대경로를 넣는다.

예:

```env
CODEX_BIN=/usr/local/bin/codex
```

---

## 12. GitHub Repository Connection

처음 GitHub에 올릴 때:

```bash
git init
git branch -M master
git add .
git commit -m "init codex research agent template"
git remote add origin https://github.com/YOUR_NAME/codex-research-agent.git
git push -u origin master
```

이미 remote가 있으면:

```bash
git remote -v
git remote set-url origin https://github.com/YOUR_NAME/codex-research-agent.git
```

중요:

- force push하지 않는다.
- GitHub token을 파일에 저장하지 않는다.
- `config/research.env`는 commit하지 않는다.

---

## 13. GitHub Push for Outputs

기본값은 push 비활성화다.

```env
ENABLE_GITHUB_PUSH=false
```

활성화:

```env
ENABLE_GITHUB_PUSH=true
GIT_BRANCH=master
GIT_OUTPUT_PATHS="outputs/latest outputs/runs outputs/archive"
```

실행:

```bash
bash scripts/push_outputs.sh
```

하지만 주의할 점이 있다.

기본 `.gitignore`는 생성된 연구 결과를 무시한다.

```gitignore
outputs/latest/*.md
outputs/runs/*
outputs/archive/*
```

그래서 outputs를 GitHub에 올리고 싶다면 `.gitignore`를 의도적으로 수정해야 한다.

추천:

- 템플릿 repo는 public으로 유지
- 개인 연구 결과 outputs는 private repo에 저장
- public repo에 outputs를 올리기 전에는 민감한 내용이 없는지 검토

---

## 14. Private Output Policy

기본적으로 GitHub에 올라가지 않는 파일:

```txt
config/research.env
.env
.env.*
logs/*.log
logs/*.jsonl
outputs/latest/*.md
outputs/runs/*
outputs/archive/*
```

GitHub에 올라가는 placeholder:

```txt
outputs/latest/.gitkeep
outputs/runs/.gitkeep
outputs/archive/.gitkeep
logs/.gitkeep
```

무시 규칙 확인:

```bash
git check-ignore -v config/research.env
git check-ignore -v outputs/latest/final_response.md
git check-ignore -v outputs/runs/smoke_test/final_response.md
git check-ignore -v logs/codex_stderr.log
```

---

## 15. Common Problems

### `codex: command not found`

확인:

```bash
which codex
codex --version
```

해결:

- Codex CLI 설치
- 새 터미널 열기
- `CODEX_BIN`에 절대경로 지정

```env
CODEX_BIN=/usr/local/bin/codex
```

### `unexpected argument '--search'`

현재 스크립트는 전역 옵션 형태를 사용한다.

```bash
codex --search --ask-for-approval never exec ...
```

그래도 문제가 나면:

```bash
codex --help
codex exec --help
```

그리고 `CODEX_WEB_SEARCH_MODE=config`로 우회 테스트한다.

### 결과 파일이 안 생김

확인:

```bash
cat logs/codex_stderr.log
find outputs -maxdepth 3 -type f | sort
```

가능한 원인:

- Codex 로그인 문제
- web search 또는 모델 실행이 오래 걸림
- 프롬프트가 너무 무거움
- `config/research.env`에 오래된 값이 남아 있음

### 전체 실행이 너무 오래 걸림

해결:

- 먼저 smoke test 실행
- `TOP_K=3`으로 줄이기
- `RESEARCH_KEYWORDS` 줄이기
- `CODEX_WEB_SEARCH_MODE=cached`로 바꾸기

---

## 16. Recommended Daily Workflow

매일 수동 실행:

```bash
cd /path/to/codex-research-agent
bash scripts/run_once.sh
cat outputs/latest/final_response.md
```

결과 읽기 순서:

1. `outputs/latest/final_response.md`
2. `outputs/latest/daily_research_brief.md`
3. `outputs/latest/papers_to_read.md`
4. `outputs/latest/research_ideas.md`

좋은 운영 방식:

- 중요한 source URL은 직접 열어 검증
- `freshness 확인 필요` 항목은 날짜와 원문 확인
- `abstract 기반 요약` 항목은 paper 본문을 나중에 읽기
- 마음에 드는 아이디어는 별도 연구 노트로 옮기기

---

## 17. What Not To Do

하지 말 것:

- `config/research.env`를 public repo에 commit
- `.env` 파일 commit
- Codex auth/token 저장
- GitHub token 저장
- `danger-full-access` 또는 `--yolo`를 기본값으로 사용
- 생성된 private outputs를 무심코 public repo에 push
- force push

이 프로젝트의 기본값은 안전하게 보수적으로 잡혀 있다. outputs를 공개하려면 `.gitignore`를 직접 수정하고 내용을 검토한 뒤 진행한다.
