# Server Deployment Guide

이 문서는 GitHub에 업로드한 `codex-research-agent`를 서버에서 clone한 뒤, 매일 자동 실행하고 GitHub에 결과 Markdown을 push하는 방법을 설명한다.

권장 구조:

```txt
서버/VPS
→ git clone
→ config/research.env 생성
→ Codex CLI 로그인
→ scripts/check_server_ready.sh 확인
→ scripts/nightly_run.sh 수동 테스트
→ cron 등록
→ GitHub 앱에서 outputs/latest/*.md 확인
```

---

## 0. Before First GitHub Upload

이제 generated outputs는 GitHub 앱에서 보기 위해 Git에 올라갈 수 있다.

첫 업로드 전에 로컬에 남아 있는 smoke/test output을 올릴지 결정한다.

확인:

```bash
git status --short --untracked-files=all
find outputs/latest -maxdepth 1 -type f | sort
find outputs/runs -maxdepth 2 -type f | sort
```

테스트 output도 기록으로 남기고 싶으면 그대로 commit한다.

테스트 output을 올리고 싶지 않으면 업로드 전에 직접 정리한 뒤 commit한다. 삭제 전에는 필요한 파일이 아닌지 꼭 확인한다.

서버 운영용 첫 commit에는 보통 아래가 포함되면 충분하다.

```txt
project files
md/*.md
scripts/*.sh
config/research.env.example
outputs/*/.gitkeep
```

실제 daily output은 서버에서 첫 nightly run 이후 올라가도 된다.

---

## 1. Server Requirements

서버에 필요한 것:

```txt
Git
Codex CLI
Codex 로그인 또는 인증
GitHub push 권한
cron
```

Ubuntu 기준 기본 패키지:

```bash
sudo apt update
sudo apt install -y git curl ca-certificates
```

---

## 2. Install and Login to Codex CLI

Codex CLI 설치 후 확인:

```bash
which codex
codex --version
codex --help
```

로그인:

```bash
codex
```

서버에서 브라우저 로그인이 어렵다면 Codex CLI가 안내하는 device login 또는 서버 환경에 맞는 인증 방식을 사용한다.

확인:

```bash
codex --search --ask-for-approval never exec "Reply with: codex server auth ok"
```

---

## 3. Clone the Repository

private repo라면 SSH clone을 추천한다.

```bash
mkdir -p ~/apps
cd ~/apps
git clone git@github.com:YOUR_NAME/codex-research-agent.git
cd codex-research-agent
```

HTTPS를 쓰는 경우:

```bash
git clone https://github.com/YOUR_NAME/codex-research-agent.git
```

private repo에 push하려면 서버에 GitHub 인증이 필요하다.

선택지:

- SSH key 등록
- GitHub deploy key with write access
- GitHub CLI login
- HTTPS + personal access token

개인 서버라면 SSH key 방식이 가장 단순하다.

---

## 4. Create Runtime Config

```bash
cp config/research.env.example config/research.env
nano config/research.env
```

필수 확인:

```env
ENABLE_GITHUB_PUSH=true
GIT_BRANCH=master
GIT_OUTPUT_PATHS="outputs/latest outputs/runs outputs/archive"
GIT_PULL_BEFORE_PUSH=true
```

Codex 경로가 cron에서 안 잡힐 수 있으므로 절대경로를 넣어두면 안전하다.

```bash
which codex
```

예:

```env
CODEX_BIN=/usr/local/bin/codex
```

연구 주제 변경:

```env
RESEARCH_DOMAIN="LLM Agent Security"
RESEARCH_FOCUS="execution graph based detection for malicious tool-use agents"
RESEARCH_KEYWORDS="prompt injection,MCP security,tool-use security,provenance graph"
RESEARCH_QUESTIONS="What should I read this week, and what experiment should I run next?"
RESEARCH_SOURCE_TYPES="recent papers,arXiv papers,GitHub repositories,technical blogs,benchmarks,datasets"
RESEARCH_METHOD_HINTS="Prioritize reproducible papers, datasets, benchmarks, and implementation ideas."
```

---

## 5. Configure Git Commit Identity

`push_outputs.sh`는 Git identity가 없으면 local default를 설정한다.

명시적으로 설정하고 싶으면:

```bash
git config user.name "codex-research-agent"
git config user.email "codex-research-agent@users.noreply.github.com"
```

또는 `config/research.env`:

```env
GIT_COMMIT_USER_NAME=codex-research-agent
GIT_COMMIT_USER_EMAIL=codex-research-agent@users.noreply.github.com
```

---

## 6. Run Server Readiness Check

```bash
bash scripts/check_server_ready.sh
```

이 스크립트가 확인하는 것:

- `git` 설치 여부
- `codex` 설치 여부
- `--search`, `--ask-for-approval` 지원 여부
- Git repo 여부
- origin remote 여부
- 현재 branch와 `GIT_BRANCH` 일치 여부
- `ENABLE_GITHUB_PUSH=true` 여부
- outputs가 Git에서 track 가능한지
- cron 예시

`WARN`은 바로 실패는 아니지만 확인해야 한다. `FAIL`이 있으면 먼저 해결한다.

---

## 7. Smoke Test

전체 리서치 실행 전에 짧은 파일 생성 테스트를 한다.

```bash
cat > /tmp/codex-research-agent-smoke-prompt.md <<'EOF'
Create exactly the three runtime output files specified in the Runtime Configuration:
OUTPUT_DAILY_RESEARCH_BRIEF, OUTPUT_PAPERS_TO_READ, and OUTPUT_RESEARCH_IDEAS.
Put one short line in each file.
Do not create any other files.
Reply briefly.
EOF

PROMPT_FILE=/tmp/codex-research-agent-smoke-prompt.md \
OUTPUT_RUN_DIR=outputs/runs/server_smoke_test \
CODEX_WEB_SEARCH_MODE=config \
bash scripts/run_once.sh
```

확인:

```bash
find outputs/runs/server_smoke_test -maxdepth 1 -type f -print
ls -la outputs/latest
cat outputs/latest/final_response.md
```

---

## 8. Full Manual Test

실제 리서치 실행:

```bash
bash scripts/run_once.sh
```

오래 걸릴 수 있다. 진행 상황:

```bash
tail -f logs/codex_stderr.log
```

결과:

```bash
ls -la outputs/latest
cat outputs/latest/final_response.md
```

---

## 9. Nightly Run Test with Push

cron 등록 전, 수동으로 nightly 전체 흐름을 테스트한다.

```bash
bash scripts/nightly_run.sh
```

이 스크립트는:

```txt
run_once.sh 실행
→ outputs/latest 갱신
→ outputs/archive/YYYY-MM-DD/ 복사
→ push_outputs.sh 실행
→ git commit/push
```

확인:

```bash
git status --short
git log --oneline -5
```

GitHub 앱에서 확인:

```txt
outputs/latest/daily_research_brief.md
outputs/latest/papers_to_read.md
outputs/latest/research_ideas.md
```

---

## 10. Register Cron

cron 예시 출력:

```bash
bash scripts/setup_cron.example.sh
```

crontab 편집:

```bash
crontab -e
```

예:

```cron
TZ=Asia/Seoul
30 1 * * * cd /home/ubuntu/apps/codex-research-agent && bash scripts/nightly_run.sh >> logs/cron.log 2>&1
```

저장 후 확인:

```bash
crontab -l
```

---

## 11. Check Cron Result

다음날 또는 실행 시간 이후:

```bash
cd ~/apps/codex-research-agent
cat logs/cron.log
tail -n 120 logs/codex_stderr.log
ls -la outputs/latest
find outputs/archive -maxdepth 2 -type f | sort
git log --oneline -5
```

GitHub 앱에서 `outputs/latest/*.md`를 열면 Markdown이 렌더링되어 보인다.

---

## 12. Common Server Problems

### cron에서 `codex`를 못 찾음

원인:

- cron PATH가 일반 shell PATH와 다르다.

해결:

```bash
which codex
```

그 결과를 `config/research.env`에 넣는다.

```env
CODEX_BIN=/usr/local/bin/codex
```

### push가 실패함

확인:

```bash
git remote -v
git branch --show-current
git pull --ff-only origin master
git push origin master
```

원인:

- 서버에 GitHub push 권한 없음
- branch 이름 불일치
- remote가 HTTPS인데 token 없음
- GitHub repo가 protected branch 정책을 사용

### commit이 실패함

확인:

```bash
git config user.name
git config user.email
```

해결:

```bash
git config user.name "codex-research-agent"
git config user.email "codex-research-agent@users.noreply.github.com"
```

### 결과 파일이 안 생김

확인:

```bash
cat logs/codex_stderr.log
cat logs/codex_stdout.log
find outputs -maxdepth 3 -type f | sort
```

먼저 smoke test를 다시 실행한다.

### 전체 실행이 너무 오래 걸림

조정:

```env
TOP_K=3
CODEX_WEB_SEARCH_MODE=cached
RESEARCH_KEYWORDS="핵심 키워드 5개 정도"
```

---

## 13. Security Notes

중요:

- `config/research.env`를 commit하지 않는다.
- `.env`를 commit하지 않는다.
- Codex auth 파일을 repo에 넣지 않는다.
- GitHub token을 파일에 저장하지 않는다.
- outputs를 GitHub에 push하므로 repo는 private 권장이다.
- public repo에 outputs를 올리기 전에는 민감한 내용이 없는지 확인한다.
