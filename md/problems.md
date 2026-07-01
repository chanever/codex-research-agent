# Problems Encountered

이 문서는 `codex-research-agent` 템플릿을 만들고 테스트하면서 실제로 발견한 문제와 해결 내용을 기록한다.

## 1. `codex` Command Not Found

처음 `bash scripts/run_once.sh`를 실행했을 때 결과 파일이 생성되지 않았다.

`logs/codex_stderr.log`에는 다음과 같은 에러가 있었다.

```txt
scripts/run_once.sh: line 63: codex: command not found
```

원인:

- 사용자 터미널의 `PATH`에 Codex CLI가 없었다.
- Codex 데스크톱 앱 내부에는 Codex 바이너리가 있었지만, 일반 터미널에서는 `codex` 명령으로 접근할 수 없었다.

확인 명령:

```bash
which codex
codex --version
```

해결:

- Codex CLI를 설치하고 새 터미널에서 `which codex`로 확인했다.
- 이후 `/usr/local/bin/codex`가 잡혔다.

현재 스크립트 보완:

- `scripts/run_once.sh`는 `CODEX_BIN`을 찾지 못하면 명확한 에러를 출력한다.
- macOS Codex 앱 번들 경로가 있으면 fallback으로 사용할 수 있게 했다.

---

## 2. Codex CLI Option Position Mismatch

초기 구현은 다음 형태를 기준으로 했다.

```bash
codex exec --search --ask-for-approval never ...
```

하지만 설치된 `codex-cli 0.142.3`에서는 `--search`와 `--ask-for-approval`이 `exec` 하위 옵션이 아니라 전역 옵션으로 동작했다.

문제 증상:

```txt
error: unexpected argument '--search' found
error: unexpected argument '--ask-for-approval' found
```

현재 설치된 CLI에서 맞는 형태:

```bash
codex --search --ask-for-approval never exec ...
```

해결:

- `scripts/run_once.sh`의 Codex 실행 명령을 전역 옵션 먼저 붙이는 방식으로 변경했다.
- `README.md`와 `docs/usage.md`의 예시도 같은 방식으로 수정했다.

---

## 3. `--search` 없이도 Web Search가 가능한지 혼동

초기에는 최신 연구 조사가 목표라서 `--search`를 반드시 붙이도록 설계했다.

공식 Codex 매뉴얼 확인 결과:

- Codex CLI는 web search가 기본적으로 켜져 있다.
- 기본 모드는 `cached`이다.
- `--search`는 `web_search = "live"`와 동일하며, 최신 웹 결과를 가져오도록 한다.
- `web_search = "disabled"`로 끌 수도 있다.

정리:

```txt
--search 없음   -> 기본 cached web search
--search 있음   -> live web search
web_search=live -> --search와 동일
```

해결:

- `CODEX_WEB_SEARCH_MODE` 환경변수를 추가했다.

지원 값:

```txt
live      # --search 사용
cached    # -c 'web_search="cached"' 사용
disabled  # -c 'web_search="disabled"' 사용
config    # 아무 검색 옵션도 넘기지 않고 사용자 Codex config를 따름
```

실제 연구 자동화에는 최신 자료 확인이 중요하므로 기본값은 `live`로 유지했다.

---

## 4. Long Full Research Run

`run_once.sh`가 옵션 문제를 해결한 뒤에는 실제로 web search까지 진입했다.

로그에는 다음과 같은 검색 흔적이 남았다.

```txt
web search: LLM agent security tool-use agents prompt injection provenance graph execution graph paper arXiv
web search: AgentDojo benchmark LLM agents prompt injection
web search: MCP security
```

하지만 전체 리서치 프롬프트는 몇 분 동안 파일 쓰기 단계로 넘어가지 않았다.

원인 추정:

- 프롬프트가 긴 편이다.
- 검색 대상이 많다.
- `TOP_K=5`와 최소 5개 연구 아이디어 작성 요구가 있어 정리 시간이 길다.
- 모델이 여러 검색 결과를 비교하느라 오래 걸릴 수 있다.

확인:

- 짧은 smoke prompt로 실행하면 파일 생성은 정상 동작했다.
- 따라서 Codex CLI, 인증, sandbox 쓰기 권한, final response 저장 기능 자체는 정상이다.

대응:

- 전체 연구 실행은 10분 이상 기다릴 수 있다.
- 빠른 테스트에는 짧은 smoke prompt를 사용한다.
- 필요하면 `TOP_K=3`, 키워드 축소, 출력 분량 축소 등으로 프롬프트를 가볍게 만들 수 있다.

---

## 5. Output Directory Structure Needed Per Run

초기 구조는 모든 결과를 `outputs/latest/`에만 생성했다.

문제:

- 실행할 때마다 이전 결과가 덮어써질 수 있다.
- 과거 실행 결과를 비교하기 어렵다.
- cron이나 nightly run에서 날짜별 기록과 latest 역할이 섞인다.

해결:

- 매 실행마다 다음 형식의 폴더를 만들도록 변경했다.

```txt
outputs/runs/YYYY_MM_DD_HH_MM/
```

예:

```txt
outputs/runs/2026_06_29_12_40/
```

생성 파일:

```txt
daily_research_brief.md
papers_to_read.md
research_ideas.md
final_response.md
```

그리고 성공한 실행 결과를 `outputs/latest/`로 복사한다.

효과:

- `outputs/runs/...`는 실행별 기록이다.
- `outputs/latest/`는 최신 결과만 보는 편의 경로다.
- GitHub 앱에서 보기로 한 현재 운영 방식에서는 둘 다 Git에 올라갈 수 있다. 개인 내용이 포함되면 repo를 private으로 유지한다.

---

## 6. Prompt Had Hardcoded `outputs/latest` Paths

출력 경로를 run directory로 바꾸면서, 기존 `prompts/make_research_brief.md`의 하드코딩된 경로가 문제가 됐다.

기존:

```txt
outputs/latest/daily_research_brief.md
outputs/latest/papers_to_read.md
outputs/latest/research_ideas.md
```

문제:

- wrapper script가 run-specific output path를 만들더라도, 프롬프트가 계속 `outputs/latest`에 쓰라고 지시할 수 있다.

해결:

- `run_once.sh`가 runtime configuration에 다음 값을 주입한다.

```txt
OUTPUT_DIR
OUTPUT_DAILY_RESEARCH_BRIEF
OUTPUT_PAPERS_TO_READ
OUTPUT_RESEARCH_IDEAS
```

- 프롬프트는 이 값들이 있으면 해당 경로를 우선 사용하도록 수정했다.
- 값이 없을 때만 `outputs/latest/...`를 fallback으로 사용한다.

---

## 7. Empty Bash Array with `set -u`

`CODEX_WEB_SEARCH_MODE=config`에서는 Codex에 web search 관련 인자를 넘기지 않는다.

이때 `CODEX_GLOBAL_ARGS` 배열이 비어 있고, `set -u`가 켜져 있어 다음 에러가 발생했다.

```txt
scripts/run_once.sh: line 145: CODEX_GLOBAL_ARGS[@]: unbound variable
```

해결:

- Codex 명령 전체를 `CODEX_COMMAND` 배열로 조립했다.
- `CODEX_GLOBAL_ARGS`가 비어 있지 않을 때만 추가하도록 분기했다.

검증:

```bash
PROMPT_FILE=/private/tmp/codex-research-agent-smoke-prompt.md \
OUTPUT_RUN_DIR=outputs/runs/2026_06_29_12_40_smoke \
CODEX_WEB_SEARCH_MODE=config \
bash scripts/run_once.sh
```

결과:

```txt
Run outputs: outputs/runs/2026_06_29_12_40_smoke
```

---

## 8. Local `config/research.env` Is Ignored but Still Affects Runs

`config/research.env`는 `.gitignore`에 의해 Git에 올라가지 않는다.

문제:

- 템플릿 파일인 `config/research.env.example`을 수정해도, 이미 복사해둔 로컬 `config/research.env`에는 예전 값이 남아 있을 수 있다.
- 실제 실행은 `config/research.env`를 source하므로 로컬 설정이 우선 적용된다.

예:

```env
CODEX_OUTPUT_LAST_MESSAGE=outputs/latest/final_response.md
GIT_OUTPUT_PATHS="outputs/latest outputs/archive"
```

해결:

- 로컬 `config/research.env`도 최신 구조에 맞게 수정했다.
- 스크립트는 예전 값 `outputs/latest/final_response.md`가 있으면 새 run directory의 `final_response.md`로 자동 보정한다.

주의:

- public repo에는 `config/research.env`를 올리지 않는다.
- 사용자에게는 `research.env.example` 변경 후 자신의 `research.env`도 확인하라고 안내해야 한다.

---

## 9. GitHub Branch Name

초기 문서 일부에는 `main` 브랜치가 남아 있었다.

사용자는 `master` 브랜치를 사용하기로 했다.

해결:

- `config/research.env.example`의 기본값을 `GIT_BRANCH=master`로 변경했다.
- README와 docs의 GitHub push 예시도 `master` 기준으로 수정했다.

---

## 10. Output Push Policy Changed

초기에는 출력 디렉터리를 `outputs/runs`로 추가하면서 generated outputs를 `.gitignore`로 막았다.

초기 ignore 규칙:

```gitignore
outputs/latest/*.md
outputs/runs/*
outputs/archive/*
!outputs/latest/.gitkeep
!outputs/runs/.gitkeep
!outputs/archive/.gitkeep
```

이후 사용자가 GitHub 앱에서 결과 Markdown을 바로 보기로 하면서 outputs ignore 규칙을 제거했다.

현재 정책:

```txt
outputs/latest/*.md      trackable
outputs/runs/**/*        trackable
outputs/archive/**/*     trackable
config/research.env      ignored
logs/*.log               ignored
```

검증:

```bash
git check-ignore -v config/research.env
git check-ignore -v logs/codex_stderr.log
git check-ignore outputs/latest/final_response.md || echo "outputs/latest is trackable"
git check-ignore outputs/runs/2026_06_29_12_40_smoke/final_response.md || echo "outputs/runs is trackable"
```

결과:

- generated run outputs trackable
- latest outputs trackable
- private config ignored
- logs ignored

주의:

- outputs가 GitHub에 올라가므로 repo를 private으로 유지하는 것을 권장한다.

---

## Current Recommended Test Flow

빠른 smoke test:

```bash
cat > /private/tmp/codex-research-agent-smoke-prompt.md <<'EOF'
Create exactly the three runtime output files specified in the Runtime Configuration:
OUTPUT_DAILY_RESEARCH_BRIEF, OUTPUT_PAPERS_TO_READ, and OUTPUT_RESEARCH_IDEAS.
Put one short line in each file.
Do not create any other files.
Reply briefly.
EOF

PROMPT_FILE=/private/tmp/codex-research-agent-smoke-prompt.md \
OUTPUT_RUN_DIR=outputs/runs/2026_06_29_12_40_smoke \
CODEX_WEB_SEARCH_MODE=config \
bash scripts/run_once.sh
```

전체 연구 실행:

```bash
bash scripts/run_once.sh
```

전체 실행은 웹 검색과 긴 정리 작업 때문에 오래 걸릴 수 있다.

---

## 11. Server Sandbox Failure and `danger-full-access`

Callisto 서버에서 `CODEX_SANDBOX=workspace-write`로 `scripts/run_once.sh`를 실행하면 Codex 내부 명령 실행이 다음 오류로 실패할 수 있다.

```txt
bwrap: loopback: Failed RTM_NEWADDR: Operation not permitted
```

증상:

- Codex의 웹 조사는 진행된다.
- `final_response.md`는 실패 메시지로 생성될 수 있다.
- 하지만 `daily_research_brief.md`, `papers_to_read.md`, `research_ideas.md`는 실제로 생성되지 않는다.
- Codex가 내부에서 `mkdir -p` 또는 파일 쓰기 도구를 실행하려 할 때 sandbox 생성 단계에서 막힌다.

원인:

- `workspace-write`는 Codex가 작업 디렉터리 안에서만 파일을 쓰도록 OS-level sandbox를 적용한다.
- Linux 환경에서는 Codex sandbox가 `bubblewrap`/namespace 기능에 의존할 수 있다.
- 현재 서버 환경에서는 해당 namespace 또는 loopback 설정 권한이 허용되지 않아 `bwrap`가 실패한다.

서버용 해결:

```env
CODEX_SANDBOX=danger-full-access
```

이 설정은 `config/research.env`에 둔다.

```bash
grep '^CODEX_SANDBOX=' config/research.env
```

기대 출력:

```txt
CODEX_SANDBOX=danger-full-access
```

주의사항:

- `danger-full-access`는 Codex가 sandbox 제한 없이 현재 사용자 권한으로 명령을 실행한다.
- 개인 서버, 신뢰하는 repository, 신뢰하는 prompt에서만 사용하는 것이 좋다.
- public/untrusted repository나 외부에서 받은 prompt를 그대로 실행할 때는 위험할 수 있다.
- 로컬 PC에서 `workspace-write`가 정상 동작한다면 로컬에서는 계속 `workspace-write`를 유지하는 편이 더 안전하다.
- 이 설정은 서버의 sandbox 권한 문제를 우회하기 위한 운영상 선택이지, 기본적으로 더 안전한 설정은 아니다.
