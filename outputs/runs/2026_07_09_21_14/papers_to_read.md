# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper / runtime defense
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.8
- One-line takeaway: 정상 실행 provenance를 학습해 out-of-bound tool call을 막는 실행 그래프 기반 방어다.
- Background knowledge before reading: provenance graph, source tracking, user intent alignment, AgentDojo/AgentDyn 기본 구조를 알고 읽으면 좋다.
- Why read first: 연구 질문과 거의 동일한 문제를 다룬다. "tool argument value가 어디서 왔는가"를 보안 신호로 쓰는 방법을 바로 참고할 수 있다.
- Expected value: graph schema, 정상 trace 학습, policy decision point 설계에 대한 직접적인 baseline.
- Related keywords: provenance graph, execution graph, tool-use security, indirect prompt injection, runtime defense.
- Example scenario: Slack agent가 untrusted webpage에서 읽은 이메일 주소를 민감 메시지 수신자로 사용하면, provenance mismatch로 차단한다.
- What to pay attention to: 정상 trace 수집 방법, feature 정의, block decision rule, utility-preserving 조건, AgentDojo/AgentDyn 평가 세팅.
- Reading notes: abstract 기반 요약. code 공개와 peer-review 상태는 freshness 확인 필요.

### 2. TraceAegis: Securing LLM-Based Agents via Hierarchical and Behavioral Anomaly Detection

- Type: arXiv paper / trace anomaly detection / benchmark
- URL: https://arxiv.org/abs/2510.11203
- Relevance Score: 9.5
- One-line takeaway: 실행 trace를 계층화하고 behavioral rule을 추출해 abnormal agent workflow를 탐지한다.
- Background knowledge before reading: agent trace, workflow constraint, anomaly detection, semantic consistency.
- Why read first: raw graph가 너무 크고 noisy할 때 stable execution unit으로 추상화하는 방법을 제공한다.
- Expected value: graph abstraction layer, rule extraction, benign/abnormal trace benchmark 설계.
- Related keywords: execution trace, provenance-based analysis, anomaly detection, behavioral rule, TraceAegis-Bench.
- Example scenario: procurement agent가 quote 비교 없이 purchase order를 먼저 생성하면 execution order violation으로 탐지한다.
- What to pay attention to: hierarchical unit 정의, abnormal label 생성, healthcare/procurement 외 task로 일반화 가능한지.
- Reading notes: abstract 기반 요약. TraceAegis-Bench artifact 공개 위치와 license는 freshness 확인 필요.

### 3. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / graph alignment defense
- URL: https://arxiv.org/abs/2605.26497
- Relevance Score: 9.4
- One-line takeaway: observed provenance graph와 expected authorization graph를 비교해 tool 및 인자 출처 위반을 탐지한다.
- Background knowledge before reading: authorization policy, graph alignment, prompt injection, parameter provenance.
- Why read first: "실제 trace가 이미 공격자에 의해 오염될 수 있다"는 문제를 깨끗한 authorization graph로 해결하려 한다.
- Expected value: expected-vs-observed graph alignment 연구 아이디어의 핵심 참고문헌.
- Related keywords: authorization graph, provenance graph, parameter-source-level deviation, tool-use security.
- Example scenario: 사용자는 flight search 결과에서 flight_id를 고르라고 했지만, 실제 `book_flight.flight_id`가 hotel webpage에서 왔다면 차단한다.
- What to pay attention to: authorization graph 생성 prompt, graph builder prompts, tool name check와 parameter source check, false positive 사례.
- Reading notes: full text 확인. multi-agent cross-agent flow는 논문도 한계로 언급한다.

### 4. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: arXiv paper / benchmark / dataset
- URL: https://arxiv.org/abs/2606.18356
- Relevance Score: 9.0
- One-line takeaway: agent 보안 평가 endpoint를 semantic, audit evidence, sandbox harm으로 분리한다.
- Background knowledge before reading: ASR, audit logs, sandbox side effects, prompt injection benchmark metrics.
- Why read first: execution graph detector는 final answer보다 side effect 차단에서 강점을 가질 가능성이 크므로, 평가 지표 설계에 중요하다.
- Expected value: graph detector를 어떤 metric으로 평가해야 하는지에 대한 기준.
- Related keywords: sandbox-observed harm, audit evidence, memory poisoning, tool-return injection, benchmark.
- Example scenario: agent가 안전한 답을 했지만 DB write tool을 실행했다면 semantic metric은 놓치고 sandbox harm metric은 잡는다.
- What to pay attention to: 세 endpoint의 label 방식, sandbox harm과 semantic check가 불일치하는 케이스, dataset 재현 절차.
- Reading notes: full text 확인. Hugging Face dataset version은 freshness 확인 필요.

### 5. MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills

- Type: arXiv paper / benchmark / malicious skill dataset
- URL: https://arxiv.org/abs/2606.07131
- Relevance Score: 8.9
- One-line takeaway: agent skill 공격을 Docker sandbox와 syscall monitoring으로 검증한 최신 benchmark다.
- Background knowledge before reading: coding agent skill, supply chain attack, prompt injection, code injection, syscall monitoring.
- Why read first: 연구 키워드인 malicious package detection, sandbox verification, strace, Docker sandbox와 직접 맞닿는다.
- Expected value: runtime-verified malicious behavior label을 만드는 방법, code+instruction hybrid detector 설계.
- Related keywords: malicious package detection, coding agent security, system-call monitoring, sandbox verification.
- Example scenario: `lint_helper` skill이 AGENTS.md instruction으로 agent를 속이고 script가 `.env`를 읽어 외부로 보낸다.
- What to pay attention to: Generate-Verify-Feedback pipeline, syscall monitoring schema, prompt injection 샘플의 verification yield, benign matching 방식.
- Reading notes: abstract 기반 요약. dataset/code 공개 위치와 안전한 취급 절차는 freshness 확인 필요.

## Medium Priority

### 1. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: NeurIPS benchmark / GitHub repository
- URL: https://arxiv.org/abs/2406.13352
- Relevance Score: 8.8
- One-line takeaway: indirect prompt injection 방어를 평가하는 가장 널리 쓰이는 동적 tool-use benchmark 중 하나다.
- Background knowledge before reading: user task와 attacker goal 분리, tool-call agent loop, utility/ASR tradeoff.
- Why read first: 새 graph detector의 초기 실험 환경으로 적합하고, 여러 최신 방어 논문이 평가축으로 사용한다.
- Expected value: reproducible task suite, attack/defense interface, trace logging hook 삽입 위치.
- Related keywords: prompt injection, indirect prompt injection, tool-use security, benchmark.
- Example scenario: 사용자는 Slack 초대를 요청했지만 웹페이지의 malicious instruction이 phishing link 전송을 유도한다.
- What to pay attention to: task/attack 정의 방식, pipeline component API, benchmark saturation 이슈.
- Reading notes: repository API는 변경 가능하므로 현재 버전 확인 필요.

### 2. AgentDyn: Are Your Agent Security Defenses Deployable in Real-World Dynamic Environments?

- Type: arXiv paper / benchmark / GitHub repository
- URL: https://arxiv.org/abs/2602.03117
- Relevance Score: 8.7
- One-line takeaway: AgentDojo보다 더 open-ended하고 dynamic한 task로 기존 방어의 취약성과 과방어를 드러낸다.
- Background knowledge before reading: AgentDojo, dynamic planning, helpful third-party instruction, over-defense.
- Why read first: graph detector가 static benchmark에 과적합되는지 확인하는 확장 실험에 필요하다.
- Expected value: Shopping, GitHub, Daily Life 도메인의 open-ended injection cases.
- Related keywords: AgentDyn, adaptive benchmark, indirect prompt injection, real-world agent security.
- Example scenario: GitHub task에서 issue 해결에 도움이 되는 외부 지시와 악성 지시가 섞여 agent가 잘못된 repository action을 수행한다.
- What to pay attention to: 60 open-ended tasks, 560 injection test cases, 기존 방어의 utility/security tradeoff.
- Reading notes: GitHub artifact와 arXiv v3 일치 여부는 freshness 확인 필요.

### 3. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: arXiv paper / MCP benchmark
- URL: https://arxiv.org/abs/2508.14925
- Relevance Score: 8.7
- One-line takeaway: 실제 MCP server와 tool metadata를 대상으로 tool poisoning 취약성을 평가한다.
- Background knowledge before reading: MCP, tool manifest, tool description, metadata poisoning.
- Why read first: `tool_description -> plan -> legitimate_tool_call -> harmful side effect` motif detector의 핵심 데이터 후보.
- Expected value: MCP tool poisoning attack templates와 real-world MCP tool catalog.
- Related keywords: MCP security, tool poisoning, indirect prompt injection, tool-use security.
- Example scenario: `summarize_pdf` tool 설명에 hidden exfiltration instruction이 들어 있고, agent가 정상 email tool로 secret을 보낸다.
- What to pay attention to: 45 MCP servers, 353 tools, malicious test case 생성 방식, attack category taxonomy.
- Reading notes: abstract 기반 요약. anonymized repository에서 최종 공개 저장소로 바뀌었는지 확인 필요.

### 4. MCP-SafetyBench: A Benchmark for Safety Evaluation of Large Language Models with Real-World MCP Servers

- Type: arXiv paper / MCP safety benchmark
- URL: https://arxiv.org/abs/2512.15163
- Relevance Score: 8.5
- One-line takeaway: MCP server, host, user layer를 가로지르는 20개 공격 유형과 multi-step task를 제공한다.
- Background knowledge before reading: MCP host/client/server architecture, multi-server tool use, attack taxonomy.
- Why read first: MCP-specific graph schema에서 server-side, host-side, user-side node/edge를 어떻게 나눌지 힌트를 준다.
- Expected value: MCP attack taxonomy, multi-turn evaluation, real-world MCP server integration.
- Related keywords: MCP security, MCP-SafetyBench, host-side attack, tool poisoning, replay injection.
- Example scenario: user는 JNJ holdings를 요청했지만 tool manifest가 parameter를 TSLA로 바꿔 agent가 잘못된 금융 분석을 수행한다.
- What to pay attention to: 20 attack types, five domains, task success와 defense success 사이의 tradeoff.
- Reading notes: full text 확인. GitHub repository와 dataset version 확인 필요.

### 5. AgentArmor: Enforcing Program Analysis on Agent Runtime Trace to Defend Against Prompt Injection

- Type: arXiv paper / program analysis framework
- URL: https://arxiv.org/abs/2508.01249
- Relevance Score: 8.4
- One-line takeaway: agent runtime trace를 CFG/DFG/PDG 같은 graph IR로 변환해 policy violation을 검사한다.
- Background knowledge before reading: control-flow graph, data-flow graph, program dependence graph, taint tracking.
- Why read first: execution trace를 "분석 가능한 프로그램"으로 보는 관점이 연구 설계에 매우 유용하다.
- Expected value: trace-to-graph IR 변환, sensitive data flow policy, trust boundary rule.
- Related keywords: execution graph, program analysis, PDG, prompt injection defense.
- Example scenario: browser agent가 untrusted webpage를 읽은 뒤 clipboard secret을 외부 POST 요청에 넣으면 PDG의 forbidden flow로 탐지한다.
- What to pay attention to: graph generator, property registry, type system, AgentDojo 평가 결과.
- Reading notes: arXiv 및 project artifact 최신성 확인 필요.

## Low Priority

### 1. Progent: Programmable Privilege Control for LLM Agents

- Type: arXiv paper / privilege control defense
- URL: https://arxiv.org/abs/2504.11703
- Relevance Score: 7.8
- One-line takeaway: tool name과 argument에 대한 symbolic privilege policy로 최소 권한 원칙을 적용한다.
- Background knowledge before reading: least privilege, policy DSL, tool-call authorization.
- Why read first: graph detector의 deterministic baseline이나 policy layer로 쓰기 좋다.
- Expected value: graph detector와 결합할 수 있는 runtime policy language.
- Related keywords: privilege control, policy enforcement, tool-use security.
- Example scenario: user task에 필요 없는 `send_email` tool은 policy가 닫고, 필요한 `calendar_search`만 허용한다.
- What to pay attention to: LLM-generated policy의 adaptive attack resilience, false positive 처리.
- Reading notes: graph 기반은 아니므로 core reading 뒤에 보면 된다.

### 2. DRIFT: Dynamic Rule-Based Defense with Injection Isolation for Securing LLM Agents

- Type: NeurIPS paper / rule-based defense
- URL: https://arxiv.org/abs/2506.12104
- Relevance Score: 7.7
- One-line takeaway: dynamic security policy와 memory/injection isolation을 결합해 prompt injection을 방어한다.
- Background knowledge before reading: control constraint, data constraint, injection isolation, AgentDojo/ASB/AgentDyn.
- Why read first: graph detector가 비교해야 할 strong rule-based baseline으로 적합하다.
- Expected value: control-level/data-level constraints를 graph rule로 재해석하는 힌트.
- Related keywords: prompt injection, dynamic rule, injection isolation, agent security.
- Example scenario: tool trajectory가 user task에서 계획한 순서와 다르면 dynamic validator가 차단한다.
- What to pay attention to: Secure Planner, Dynamic Validator, Injection Isolator의 역할 분리.
- Reading notes: 그래프 기반 detector의 직접 선행연구는 아니지만 평가 baseline으로 중요하다.

### 3. Agentic MCP Security Best Practices Guide

- Type: technical guide / security best practices
- URL: https://labs.cloudsecurityalliance.org/agentic/agentic-mcp-security-best-practices-v1/
- Relevance Score: 7.5
- One-line takeaway: MCP tool poisoning, rug pull, hidden instruction 같은 운영 위협을 control framework와 연결한다.
- Background knowledge before reading: MCP host/client/server, OWASP Agentic Applications, MITRE ATLAS.
- Why read first: 연구 아이디어를 실제 운영 control과 threat model로 번역하는 데 유용하다.
- Expected value: graph detector의 production integration point와 policy terminology.
- Related keywords: MCP security, tool poisoning, rug pull, supply chain integrity.
- Example scenario: 승인된 MCP server가 나중에 tool description을 바꿔 hidden exfiltration instruction을 심는다.
- What to pay attention to: tool description baseline validation, anomalous metadata change detection, OWASP/MITRE mapping.
- Reading notes: industry guide이므로 실험 수치보다는 threat model 정리에 사용한다.

## Reading Plan

### 30-minute plan

- Agent-Sentry abstract/introduction/evaluation setup을 읽고 graph schema 후보를 메모한다.
- AuthGraph abstract와 graph alignment/checker 부분을 읽고 expected-vs-observed 비교 항목을 뽑는다.
- SafeClawBench의 endpoint 정의만 읽고 metric을 `semantic`, `audit`, `sandbox`로 나눈다.

### 2-hour plan

- Agent-Sentry, TraceAegis, AuthGraph를 이어 읽으며 공통 graph node/edge vocabulary를 만든다.
- AgentDojo와 AgentDyn의 task/attack interface를 비교해 첫 실험 환경을 정한다.
- MCPTox/MCP-SafetyBench에서 MCP-specific attack taxonomy를 추출해 metadata poisoning motif를 정의한다.

### Deep reading plan

- High Priority 5개를 모두 읽고 `source provenance`, `authorization`, `hierarchical trace`, `sandbox harm`, `runtime verification` 관점으로 표를 만든다.
- AgentDojo 또는 AgentDyn repository를 내려받아 trace hook 삽입 지점을 확인한다.
- `strace -f` 또는 eBPF 기반 sandbox logging과 agent event log를 합치는 최소 JSONL schema를 설계한다.
- 첫 baseline으로 hard rule detector, LLM judge, graph motif detector를 구현할 실험 프로토콜을 작성한다.
