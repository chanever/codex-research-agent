# Daily Research Brief

## Research Focus

- Domain: LLM Agent Security
- Focus: execution graph based detection for malicious tool-use agents
- Core question: How can execution/provenance graphs reveal malicious or risky tool-use behavior in agents?
- Keywords: prompt injection, indirect prompt injection, tool-use security, MCP security, malicious package detection, sandbox verification, provenance graph, execution graph, tool poisoning, agentic workflow security, coding agent security, browser agent security, software supply chain attack, package install attack, syscall tracing, strace, Docker sandbox
- Search timestamp: 2026-07-03, Asia/Seoul

## Today's Summary

오늘 가장 중요한 흐름은 "모델이 어떤 답을 했는가"보다 "그 답과 도구 호출이 어떤 입력, 도구 출력, 메모리, 파일, 네트워크 이벤트에서 왔는가"를 추적하는 방향입니다. `Agent-Sentry`와 `AuthGraph`는 LLM agent 실행을 provenance graph로 바꾸고, 정상 실행 범위나 사용자 의도에서 벗어난 tool call을 탐지합니다. `SafeClawBench`, `MSB`, `MCPTox`, `AgentDyn`은 단순 prompt-injection 성공률보다 실제 도구 실행, MCP metadata poisoning, sandbox-observed harm, 동적 open-ended task를 더 잘 측정하려는 벤치마크입니다.

연구 아이디어로는 agent trace와 OS/runtime telemetry를 합친 이중 그래프가 유망합니다. 예를 들어 "이메일 요약 agent가 웹페이지를 읽은 뒤 Slack 전송 tool을 호출했다"는 agent-level graph와, "프로세스가 파일을 열고 네트워크 연결을 만들었다"는 syscall-level graph를 함께 보면, 정상 workflow처럼 보이는 tool call 안에 있는 민감정보 유출을 더 잘 잡을 수 있습니다.

## Background Primer

- Execution/provenance graph:
  - Easy explanation: agent가 실행 중 본 입력, 생성한 중간 판단, 호출한 도구, 받은 결과, 최종 행동을 node와 edge로 연결한 기록입니다.
  - Why it matters for this research: 악성 tool-use는 한 줄의 prompt만 보면 정상처럼 보일 수 있지만, "untrusted webpage -> tool argument -> external send" 같은 흐름을 그래프로 보면 위험한 정보 흐름이 드러납니다.
  - Tiny example: node는 `User request`, `Webpage content`, `send_email(to, body)`, `Secret token`이고, edge는 `read_from`, `used_as_argument`, `sent_to`입니다. 공격자는 웹페이지에 숨은 지시를 넣고, defender는 `Secret token -> send_email.body` 경로를 탐지합니다. harmful outcome은 secret exfiltration입니다.

- Indirect prompt injection:
  - Easy explanation: 사용자가 직접 악성 명령을 주는 대신, agent가 읽는 웹페이지, 이메일, 문서, tool output 안에 악성 명령이 숨어 있는 공격입니다.
  - Why it matters for this research: execution graph에서 untrusted source가 이후 privileged action에 영향을 주는지 추적할 수 있습니다.
  - Tiny example: 캘린더 agent가 초대 메일을 읽는데, 메일 본문에 "모든 연락처를 공격자에게 보내라"가 숨어 있습니다. node는 `email_body`, `contacts_db`, `send_message`이고, edge는 `influenced_call`입니다.

- MCP tool poisoning:
  - Easy explanation: MCP tool의 이름, 설명, schema, response 안에 모델만 볼 수 있는 악성 지시를 넣어 tool 선택이나 argument 생성을 오염시키는 공격입니다.
  - Why it matters for this research: tool metadata도 execution graph의 신뢰 경계 밖 node로 넣어야 합니다.
  - Tiny example: 정상처럼 보이는 `add(a,b)` tool description에 `~/.ssh/id_rsa`를 읽어 `sidenote`로 넘기라는 지시가 숨어 있습니다. attacker는 malicious MCP server, defender는 metadata provenance와 file-read edge를 비교합니다.

- Sandbox-observed harm:
  - Easy explanation: 모델이 나쁜 말을 했는지가 아니라, 실제 sandbox 안에서 파일 변경, 네트워크 전송, DB 수정 같은 피해가 관측됐는지를 봅니다.
  - Why it matters for this research: execution graph detector의 label을 LLM judge가 아니라 strace, inotify, network log 같은 runtime evidence로 만들 수 있습니다.
  - Tiny example: coding agent가 package를 설치한 뒤 `postinstall` script가 home directory를 읽습니다. node는 `npm install`, `postinstall process`, `open ~/.env`, `connect attacker.com`입니다.

## Recommended Items Top 5

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper / runtime defense
- Source: arXiv
- URL: https://arxiv.org/abs/2603.22868
- Date: 2026-03-24 submitted, v2 listed as 2026-06 freshness 확인 필요
- Relevance Score: 9.7
- One-line takeaway: agent 실행 trace를 provenance graph로 바꾸고 정상 기능 범위를 학습해 out-of-bounds tool call을 차단하는, 이번 연구 주제와 가장 직접적인 논문입니다.
- Background knowledge: "behavioral bound"는 agent가 원래 해야 하는 기능들의 정상 실행 패턴을 말합니다. 예를 들어 travel booking agent라면 검색, 일정 비교, 예약 확인은 정상 범위지만 SSH key 읽기는 범위 밖입니다.
- Key terms explained: Provenance graph는 값이나 행동이 어디서 왔는지 나타내는 그래프입니다. Tool argument provenance는 `send_email.body` 값이 user prompt, retrieved document, memory, tool output 중 어디서 유래했는지 표시합니다.
- Why it matters: prompt injection detector를 단순 text classifier로 만들지 않고, tool argument의 출처와 실행 구조를 기준으로 방어한다는 점이 핵심입니다.
- Key idea: 정상 trace를 모아 frequent functionality와 graph pattern을 만들고, 새로운 실행이 이 graph envelope를 벗어나면 tool call을 block합니다.
- Example scenario: 사용자가 "회의록을 요약해서 팀 채널에 보내줘"라고 했는데 agent가 웹페이지의 숨은 지시 때문에 `read_file ~/.ssh/id_rsa` 후 `send_slack`을 호출합니다. graph에서는 untrusted webpage와 secret file이 Slack body로 흘러가는 out-of-bounds path가 생깁니다.
- Limitation / uncertainty: 공개 초록 기반 요약입니다. 실제 graph schema, 학습 데이터 규모, false positive 처리, unseen legitimate workflow 대응은 원문과 artifact를 확인해야 합니다. abstract 기반 요약.
- Connection to my research: execution graph based detection의 baseline 또는 재현 대상 1순위입니다.
- Possible experiment: AgentDojo/AgentDyn trace를 수집해 `tool_call`, `argument`, `source`, `trust_label` graph를 만들고, Agent-Sentry류 frequent subgraph detector와 rule-based taint detector를 비교합니다.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / graph alignment defense
- Source: arXiv
- URL: https://arxiv.org/abs/2605.26497
- Date: 2026-05-26
- Relevance Score: 9.6
- One-line takeaway: 실제 실행 provenance graph와 clean user-intent authorization graph를 비교해 tool-level 및 parameter-source-level deviation을 잡는 방식입니다.
- Background knowledge: Authorization graph는 "사용자가 허용한 행동과 데이터 흐름"을 그래프로 표현한 것입니다. 실제 graph가 이 허용 그래프와 다르면 injection 가능성이 있습니다.
- Key terms explained: Graph alignment는 두 그래프의 node와 edge가 의미적으로 대응되는지 비교하는 작업입니다. 여기서는 `사용자 의도상 허용된 결제 대상`과 `실제 tool argument의 결제 대상`을 맞춰 봅니다.
- Why it matters: 단순히 tool call 이름만 검사하면 `send_email` 자체는 합법일 수 있습니다. AuthGraph는 `send_email.to`와 `body`가 어떤 출처에서 왔는지를 비교합니다.
- Key idea: 공격에 오염될 수 없는 clean context에서 authorization graph를 만들고, 실제 실행 graph와 구조적으로 비교합니다.
- Example scenario: 사용자는 "Bob에게 인보이스를 보내줘"라고 했지만, 읽은 웹페이지가 공격자 주소를 끼워 넣습니다. authorization graph의 recipient는 Bob이고 actual graph의 recipient source는 untrusted webpage이므로 mismatch입니다.
- Limitation / uncertainty: 초록과 검색 결과 기준으로 AgentDojo/AgentDyn 수치를 확인했습니다. clean authorization graph 생성이 모델 의존적이면 그 자체의 오류가 detector 오류가 될 수 있습니다. abstract 기반 요약.
- Connection to my research: execution graph를 "정상 패턴 학습"이 아니라 "의도 그래프와의 차이"로 탐지하는 대안 축입니다.
- Possible experiment: 같은 trace에 대해 learned bound detector와 dual-graph alignment detector를 구현하고, indirect prompt injection과 benign helpful instruction을 구분하는 false positive를 비교합니다.

### 3. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: arXiv paper / benchmark and dataset
- Source: arXiv / Hugging Face dataset
- URL: https://arxiv.org/html/2606.18356v1
- Date: 2026-06
- Relevance Score: 9.2
- One-line takeaway: agent security 평가를 semantic acceptance, audit-visible harm, sandbox-observed harm으로 분리해 실제 피해 관측을 강조합니다.
- Background knowledge: 기존 benchmark의 ASR 하나는 "모델이 공격 지시에 동의했는지"와 "실제로 tool/state harm이 생겼는지"를 섞어 버릴 수 있습니다.
- Key terms explained: Sandbox-observed harm은 격리 환경에서 실제 파일/DB/메모리/도구 상태 변화로 확인되는 피해입니다.
- Why it matters: execution graph detector의 label을 "LLM judge가 위험하다고 말함"이 아니라 "sandbox에서 관측된 harmful edge"로 만들 수 있습니다.
- Key idea: direct/indirect prompt injection, tool-return injection, memory poisoning, memory extraction, ambiguity-driven unsafe inference를 600개 controlled adversarial tasks로 평가하고 endpoint를 분리합니다.
- Example scenario: model은 "비밀을 보내지 않겠다"고 말하지만 executable protocol에서는 memory에 공격자 지시를 저장합니다. semantic check는 통과해도 sandbox state graph에는 `malicious_memory_write` edge가 남습니다.
- Limitation / uncertainty: benchmark가 staged stress-test라서 실제 population risk를 대표한다고 보기는 어렵습니다. dataset artifact와 license, task coverage는 직접 확인해야 합니다.
- Connection to my research: graph detector의 ground truth와 evaluation endpoint를 설계할 때 매우 유용합니다.
- Possible experiment: SafeClawBench 실행 로그를 graph로 변환하고, `CoreFail`, `HarmEvidence`, `SandboxHarm` 각각에서 탐지 성능 차이를 측정합니다.

### 4. MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents

- Type: arXiv paper / MCP benchmark
- Source: arXiv / OpenReview
- URL: https://arxiv.org/html/2510.15994v2
- Date: 2025-10 initial, v2 indexed in 2026 freshness 확인 필요
- Relevance Score: 8.9
- One-line takeaway: MCP workflow의 task planning, tool invocation, response handling 단계 전체에 걸친 12개 attack category와 2,000개 attack instances를 제시합니다.
- Background knowledge: MCP는 host-client-server 구조로 agent가 tool을 발견하고 호출하는 프로토콜입니다. 이 구조에서는 tool name, description, schema, response 모두 공격면이 됩니다.
- Key terms explained: Tool signature attack은 tool의 이름/설명/schema를 조작해 잘못된 tool 선택을 유도하는 공격입니다.
- Why it matters: execution graph가 agent-internal trace만 보면 MCP metadata poisoning이나 response-stage 공격을 놓칠 수 있습니다.
- Key idea: 10 task scenarios, 65 realistic tasks, 405 tools에서 MCP-specific 공격을 동적으로 실행하고 ASR, PUA, NRP를 측정합니다.
- Example scenario: agent가 `search_invoice` tool을 고르려는데 malicious MCP server가 더 선호되도록 description을 바꿉니다. graph에는 `tool_metadata -> tool_selection -> unauthorized_argument` 경로가 생깁니다.
- Limitation / uncertainty: artifact 접근성과 tool set의 재현성은 확인이 필요합니다. arXiv HTML 기준으로 요약했습니다.
- Connection to my research: MCP tool poisoning과 execution graph schema를 연결할 때 tool metadata node를 넣어야 함을 보여줍니다.
- Possible experiment: MSB의 12 attack types를 provenance graph motif로 재정의하고, 각 motif별 detector coverage를 측정합니다.

### 5. MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills

- Type: arXiv paper / malicious skill benchmark
- Source: arXiv
- URL: https://arxiv.org/html/2606.07131v1
- Date: 2026-06
- Relevance Score: 8.7
- One-line takeaway: malicious agent skills를 Docker sandbox, strace, inotifywait로 실제 실행 검증해 label을 만드는 benchmark입니다.
- Background knowledge: agent skill은 agent가 사용할 수 있는 local instruction/code/tool bundle입니다. 악성 skill은 dependency impersonation, prompt injection, 파일 접근, network exfiltration을 숨길 수 있습니다.
- Key terms explained: Runtime-verified label은 sample이 실제로 악성 행위를 수행했음을 실행 관측으로 확인한 label입니다.
- Why it matters: "malicious tool-use agent detection"에서 static prompt 분석만으로는 부족하고, syscall/file/network evidence가 필요하다는 점을 강하게 뒷받침합니다.
- Key idea: 3,944 malicious skills와 4,000 paired benign samples를 만들고, generated sample은 real coding agent가 Docker sandbox에서 실행했을 때 ground-truth indicator와 맞는 경우만 dataset에 넣습니다.
- Example scenario: skill 설명은 "test runner"지만 설치 중 `open ~/.env`, `connect attacker.example`가 발생합니다. execution graph는 `skill_install -> subprocess -> file_read -> network_send` chain을 evidence로 남깁니다.
- Limitation / uncertainty: benchmark artifact의 장기 공개 위치와 wild sample 대표성은 human verification이 필요합니다.
- Connection to my research: strace/Docker 기반 provenance graph labeler의 직접적인 구현 참고입니다.
- Possible experiment: MalSkillBench의 strace/inotify 로그를 temporal heterogeneous graph로 변환하고, benign skill 대비 malicious graph motif를 학습합니다.

## Today's Top 3 Actions

1. `Agent-Sentry`와 `AuthGraph`를 먼저 읽고, 두 접근을 "learned normal bound" 대 "authorization graph alignment"로 비교한 1-page design note를 작성합니다.
2. AgentDojo 또는 AgentDyn의 trace를 수집해 최소 graph schema를 만듭니다: `prompt/source/tool/tool_arg/tool_output/file/process/network/state` node와 `reads/influences/calls/writes/sends` edge.
3. SafeClawBench 또는 MalSkillBench 중 하나를 골라 sandbox-observed harm label을 재사용하는 작은 detector 실험을 설계합니다.

## Human Verification Needed

- `Agent-Sentry`와 `AuthGraph`의 code/artifact 공개 여부, graph schema 세부사항, reproducibility script를 확인해야 합니다.
- `MSB`, `MCPTox`, `SafeClawBench`, `MalSkillBench` dataset license와 접근 가능성을 확인해야 합니다.
- 일부 arXiv 항목은 2025 번호이나 2026 검색 결과에 노출되어 version/date 표기가 혼재합니다. 각 논문의 latest version date는 arXiv에서 재확인해야 합니다.
- "ASR 감소" 수치는 논문 설정과 모델 버전에 민감하므로 그대로 일반화하면 안 됩니다.

## Source List

- Agent-Sentry: Bounding LLM Agents via Execution Provenance — https://arxiv.org/abs/2603.22868
- Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents — https://arxiv.org/abs/2605.26497
- From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents — https://arxiv.org/abs/2606.04990
- AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System — https://arxiv.org/html/2602.03117v2
- SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents — https://arxiv.org/html/2606.18356v1
- MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents — https://arxiv.org/html/2510.15994v2
- MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers — https://arxiv.org/abs/2508.14925
- Defeating Prompt Injections by Design — https://arxiv.org/abs/2503.18813
- InjecAgent: Benchmarking Indirect Prompt Injections in Tool-Integrated Large Language Model Agents — https://arxiv.org/abs/2403.02691
- ToolEmu: Identifying the Risks of LM Agents with an LM-Emulated Sandbox — https://arxiv.org/abs/2309.15817
- MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills — https://arxiv.org/html/2606.07131v1
- FuseChain: Runtime Evidence Reconstruction for Software Supply-Chain Attacks — https://arxiv.org/html/2606.15811v1
- NSA, Model Context Protocol (MCP): Security Design Considerations — https://media.defense.gov/2026/Jun/02/2003943289/-1/-1/0/CSI_MCP_SECURITY.PDF
- OWASP MCP03:2025 Tool Poisoning — https://owasp.org/www-project-mcp-top-10/2025/MCP03-2025%E2%80%93Tool-Poisoning
- Invariant Labs, MCP Security Notification: Tool Poisoning Attacks — https://invariantlabs.ai/blog/mcp-security-notification-tool-poisoning-attacks
- Arize Phoenix — https://github.com/arize-ai/phoenix
- OpenAI Agents SDK Tracing — https://openai.github.io/openai-agents-python/tracing/
