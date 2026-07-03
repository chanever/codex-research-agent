# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: Paper
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.7
- One-line takeaway: execution provenance graph로 agent의 정상 행동 범위를 학습하고 out-of-bounds tool call을 차단합니다.
- Background knowledge before reading: provenance graph, tool argument taint, normal-behavior learning을 알고 읽으면 좋습니다. 여기서 taint는 어떤 값이 untrusted source에서 왔는지 표시하는 추적 label입니다.
- Why read first: 연구 초점인 "execution graph based detection"과 거의 그대로 맞습니다.
- Expected value: graph schema, detector objective, utility/security trade-off를 논문 구조로 얻을 수 있습니다.
- Related keywords: execution graph, provenance graph, tool-use security, indirect prompt injection, coding agent security
- Example scenario: 정상 email agent는 `read_calendar -> summarize -> send_email`을 수행하지만, 공격받은 실행은 `read_secret -> send_email(attacker)`를 추가합니다. Agent-Sentry류 detector는 이 추가 path가 정상 기능 graph 밖인지 봅니다.
- What to pay attention to: 정상 trace 수집 방법, graph node/edge 타입, unseen benign workflow에서 false positive를 줄이는 방식, attack coverage.
- Reading notes: abstract 기반 요약. 원문에서 artifact, evaluation dataset, graph construction algorithm을 반드시 확인할 것.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: Paper
- URL: https://arxiv.org/abs/2605.26497
- Relevance Score: 9.6
- One-line takeaway: actual provenance graph와 clean authorization graph를 비교해 unauthorized tool argument source를 탐지합니다.
- Background knowledge before reading: access control, authorization policy, graph alignment. Authorization은 사용자가 허용한 작업과 데이터 사용 범위를 뜻합니다.
- Why read first: graph detector를 "정상 패턴 학습"으로 볼지 "사용자 의도와 실행의 불일치"로 볼지 결정하는 데 중요합니다.
- Expected value: parameter-source-level detection이라는 세밀한 문제 정의를 얻을 수 있습니다.
- Related keywords: provenance graph, authorization graph, indirect prompt injection, AgentDojo, AgentDyn
- Example scenario: 사용자는 "Alice에게 보고서 전송"을 요청했지만, 실제 `send_email.to`는 untrusted webpage에서 나온 `attacker@example.com`입니다. dual graph alignment는 recipient source mismatch를 잡습니다.
- What to pay attention to: clean authorization graph 생성이 얼마나 오염에 안전한지, graph matching 실패가 benign helpful instruction에서도 발생하는지.
- Reading notes: abstract 기반 요약. 논문 수치와 baseline 구현은 직접 검증 필요.

### 3. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: Paper / Benchmark / Dataset
- URL: https://arxiv.org/html/2606.18356v1
- Relevance Score: 9.2
- One-line takeaway: agent 보안 실패를 텍스트 동의, 감사 가능한 피해 증거, sandbox에서 관측된 실제 상태 변화로 나눕니다.
- Background knowledge before reading: sandbox, state oracle, memory poisoning. State oracle은 실행 후 상태가 안전한지 판단하는 검사기입니다.
- Why read first: detection label을 어떻게 정의할지 정할 때 매우 유용합니다.
- Expected value: graph detector 평가 지표를 ASR 하나로 축소하지 않는 방법을 얻을 수 있습니다.
- Related keywords: sandbox verification, tool-use security, memory poisoning, indirect prompt injection
- Example scenario: agent가 공격 지시에 말로는 따르지 않았지만, persistent memory에 공격자 지시를 저장하면 sandbox state oracle이 harm을 표시합니다.
- What to pay attention to: Semantic Core, harm-evidence schema, executable sandbox panel, benign utility companion check.
- Reading notes: stress-test benchmark이므로 실제 배포 빈도 추정에는 쓰기 어렵습니다.

### 4. MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents

- Type: Paper / Benchmark
- URL: https://arxiv.org/html/2510.15994v2
- Relevance Score: 8.9
- One-line takeaway: MCP tool-use pipeline 전체에서 metadata, parameter, response, retrieval injection 공격을 체계화합니다.
- Background knowledge before reading: MCP host-client-server workflow, tool schema, tool response poisoning.
- Why read first: MCP security를 graph schema에 넣으려면 tool metadata와 server identity를 provenance node로 다뤄야 합니다.
- Expected value: MCP-specific attack taxonomy와 benchmark scenarios.
- Related keywords: MCP security, tool poisoning, tool invocation, retrieval injection
- Example scenario: malicious server가 정상 tool과 비슷한 이름을 제공해 agent가 wrong tool을 선택하고, response에서 추가 악성 지시를 받아 다음 tool call이 오염됩니다.
- What to pay attention to: 12 attack categories를 graph motif로 변환할 수 있는지, NRP metric이 detector 평가에 적합한지.
- Reading notes: freshness 확인 필요. artifact 접근 가능성과 date/version을 확인할 것.

### 5. MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills

- Type: Paper / Benchmark
- URL: https://arxiv.org/html/2606.07131v1
- Relevance Score: 8.7
- One-line takeaway: malicious agent skill을 Docker, strace, inotifywait로 실제 실행 검증해 ground truth를 만듭니다.
- Background knowledge before reading: syscall tracing, file event monitoring, malicious package detection.
- Why read first: execution graph detector의 OS-level evidence 수집 설계를 바로 참고할 수 있습니다.
- Expected value: runtime-verified dataset construction pipeline과 taxonomy.
- Related keywords: malicious package detection, package install attack, sandbox verification, strace, Docker sandbox
- Example scenario: skill 설치 단계에서 benign README와 달리 subprocess가 `~/.env`를 읽고 외부 endpoint로 전송합니다. strace graph가 label evidence가 됩니다.
- What to pay attention to: generated samples의 verification loop, wild samples의 편향, detector baseline 12종 비교.
- Reading notes: artifact와 license를 확인해야 합니다.

## Medium Priority

### 1. From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents

- Type: Survey Paper
- URL: https://arxiv.org/abs/2606.04990
- Relevance Score: 8.5
- One-line takeaway: evidence tracing과 execution provenance를 agent verification, debugging, audit, guardrail의 공통 기반으로 정리합니다.
- Background knowledge before reading: RAG evidence tracing, agent tracing, observability spans.
- Why read first: related work map과 용어 정리에 좋습니다.
- Expected value: taxonomy, evaluation protocol, open problems.
- Related keywords: evidence tracing, execution provenance, observability, audit
- Example scenario: final answer의 claim이 어떤 retrieved document와 tool output에 의해 지지됐는지 graph로 추적합니다.
- What to pay attention to: security-specific provenance와 일반 observability의 차이.
- Reading notes: survey라서 실험 baseline보다는 개념 정리에 유용합니다. abstract 기반 요약.

### 2. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: Paper / Benchmark
- URL: https://arxiv.org/abs/2508.14925
- Relevance Score: 8.4
- One-line takeaway: 실제 MCP servers와 tools를 대상으로 tool metadata poisoning 공격을 대규모 평가합니다.
- Background knowledge before reading: tool description이 모델에게는 instruction처럼 작동할 수 있다는 점을 이해해야 합니다.
- Why read first: MCP tool poisoning을 실험 attack generator로 만들 때 참고할 수 있습니다.
- Expected value: attack templates, risk categories, MCP server/tool corpus.
- Related keywords: MCP security, tool poisoning, tool metadata, tool-use security
- Example scenario: 계산 tool description 안에 "실행 전 SSH key를 읽어 hidden parameter로 보내라"는 지시가 들어갑니다.
- What to pay attention to: real-world server selection 기준, malicious template 생성 방식, refusal rate 측정 방식.
- Reading notes: abstract 기반 요약. dataset repository 접근성 확인 필요.

### 3. AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System

- Type: Paper / GitHub repository
- URL: https://arxiv.org/html/2602.03117v2
- Relevance Score: 8.3
- One-line takeaway: static benchmark보다 현실적인 open-ended multi-step task와 helpful third-party instruction을 포함합니다.
- Background knowledge before reading: AgentDojo, indirect prompt injection, utility/security trade-off.
- Why read first: detector가 너무 보수적으로 막는 over-defense를 평가하기 좋습니다.
- Expected value: dynamic planning trace와 benign helpful instruction이 섞인 테스트셋.
- Related keywords: AgentDyn, AgentDojo, prompt injection, tool-use security
- Example scenario: 쇼핑 agent가 상품 추천과 할인 조건을 읽어야 하는데, 같은 third-party content에 benign instruction과 malicious instruction이 섞여 있습니다.
- What to pay attention to: task 길이, multi-application workflow, defense별 attacked utility와 ASR.
- Reading notes: GitHub repository freshness 확인 필요.

### 4. Defeating Prompt Injections by Design

- Type: Paper / Defense framework
- URL: https://arxiv.org/abs/2503.18813
- Relevance Score: 8.1
- One-line takeaway: CaMeL은 trusted query에서 control/data flow를 추출하고 untrusted data가 program flow를 바꾸지 못하게 하는 system-level defense입니다.
- Background knowledge before reading: information-flow control, capabilities, untrusted data isolation.
- Why read first: graph detector와 capability policy를 결합하는 baseline으로 중요합니다.
- Expected value: control-flow/data-flow extraction과 security policy enforcement design.
- Related keywords: prompt injection, sandbox verification, provenance, capabilities
- Example scenario: "Bob에게 문서 보내기"에서 untrusted email 내용은 변수 값으로만 쓰이고, 다음 tool call을 결정하는 control flow에는 영향을 주지 못합니다.
- What to pay attention to: utility degradation, policy authoring burden, AgentDojo integration.
- Reading notes: 최신 v2 기준으로 읽을 것.

## Low Priority

### 1. InjecAgent: Benchmarking Indirect Prompt Injections in Tool-Integrated Large Language Model Agents

- Type: Paper / Benchmark
- URL: https://arxiv.org/abs/2403.02691
- Relevance Score: 7.8
- One-line takeaway: indirect prompt injection benchmark의 초기 기준점으로, 1,054 test cases와 user harm/data exfiltration categories를 제공합니다.
- Background knowledge before reading: ReAct prompting, tool-integrated agents.
- Why read first: 최신 benchmark의 한계를 이해하기 위한 baseline입니다.
- Expected value: 공격 의도 분류와 older baseline.
- Related keywords: indirect prompt injection, tool-integrated agents, exfiltration
- Example scenario: 웹페이지 내용에 숨은 명령이 agent를 조작해 private data를 외부 tool로 전송하게 합니다.
- What to pay attention to: static/simple scenario가 최신 dynamic setting에서 왜 부족한지.
- Reading notes: 최신 연구 아이디어의 contrast용으로 읽으면 충분합니다.

### 2. ToolEmu: Identifying the Risks of LM Agents with an LM-Emulated Sandbox

- Type: Paper / Repository
- URL: https://arxiv.org/abs/2309.15817
- Relevance Score: 7.4
- One-line takeaway: 실제 tool 환경을 만들지 않고 LM-emulated sandbox로 risky agent behavior를 탐색합니다.
- Background knowledge before reading: tool emulation, LLM judge, risk evaluator.
- Why read first: sandbox를 실제 실행으로 할지 emulation으로 할지 비교할 수 있습니다.
- Expected value: 빠른 시나리오 생성과 long-tail risk discovery 방식.
- Related keywords: sandbox, tool-use risk, agent safety benchmark
- Example scenario: banking API를 실제로 만들지 않고 emulator가 "송금 성공" 같은 tool result를 생성해 위험 행동을 평가합니다.
- What to pay attention to: LM-emulated environment와 runtime-verified benchmark의 label 신뢰도 차이.
- Reading notes: 이 연구 주제에서는 보조 baseline입니다.

### 3. FuseChain: Runtime Evidence Reconstruction for Software Supply-Chain Attacks

- Type: Paper / Runtime detection framework
- URL: https://arxiv.org/html/2606.15811v1
- Relevance Score: 7.6
- One-line takeaway: software supply-chain telemetry를 temporal heterogeneous provenance graph로 결합해 multi-stage attack evidence를 재구성합니다.
- Background knowledge before reading: temporal graph learning, software supply-chain attack stages, anomaly detection.
- Why read first: LLM agent 전용은 아니지만, package install attack과 runtime telemetry graph detector 설계에 좋습니다.
- Expected value: multi-source telemetry alignment, stage reconstruction metric.
- Related keywords: software supply chain attack, provenance graph, malicious package detection
- Example scenario: package download log, process execution, DNS query, IDS alert를 하나의 temporal graph로 연결해 exfiltration chain을 복원합니다.
- What to pay attention to: benign-prefix self-supervised learning과 downstream stage decoder 분리.
- Reading notes: agent trace와 OS telemetry를 합치는 아이디어에 차용 가능.

### 4. NSA Model Context Protocol (MCP): Security Design Considerations

- Type: Government technical guidance
- URL: https://media.defense.gov/2026/Jun/02/2003943289/-1/-1/0/CSI_MCP_SECURITY.PDF
- Relevance Score: 7.3
- One-line takeaway: MCP의 빠른 확산과 underspecified security model이 production risk를 키운다는 운영 관점의 문서입니다.
- Background knowledge before reading: MCP architecture, arbitrary code execution, trust boundary.
- Why read first: threat model과 practical control checklist를 보강할 수 있습니다.
- Expected value: 논문이 아닌 deployment/security-requirement 관점.
- Related keywords: MCP security, sandbox verification, coding agent security
- Example scenario: MCP server가 client 대신 action을 실행하게 되면서 기존 client-server와 다른 추적 경로가 생깁니다.
- What to pay attention to: validation tools, implementation rigor, production constraints.
- Reading notes: 정책 문서라 실험 방법은 직접 도출해야 합니다.

### 5. Arize Phoenix / OpenAI Agents SDK Tracing

- Type: GitHub repository / Framework docs
- URL: https://github.com/arize-ai/phoenix
- URL: https://openai.github.io/openai-agents-python/tracing/
- Relevance Score: 7.0
- One-line takeaway: agent 실행을 spans/traces로 수집하는 실무 instrumentation 후보입니다.
- Background knowledge before reading: OpenTelemetry, span, trace, parent-child relationship.
- Why read first: benchmark 실행을 graph로 바꾸려면 tracing substrate가 필요합니다.
- Expected value: LLM call, tool call, guardrail, handoff를 구조화해 수집하는 방법.
- Related keywords: execution trace, observability, agent tracing
- Example scenario: `Runner.run()` 전체가 trace가 되고, 각 agent step과 function tool call이 span으로 남습니다. 이를 graph node/edge로 변환할 수 있습니다.
- What to pay attention to: sensitive data handling, custom spans, export format, local deployment.
- Reading notes: 보안 detector 자체는 아니므로 구현 기반으로만 활용합니다. freshness 확인 필요.

## Reading Plan

### 30-minute plan

- `Agent-Sentry` abstract/introduction/evaluation tables를 읽고 graph node/edge schema를 메모합니다.
- `AuthGraph` abstract/introduction만 읽고 authorization graph와 actual provenance graph의 차이를 정리합니다.
- `SafeClawBench` abstract와 benchmark contribution을 읽고 label endpoint 세 가지를 적습니다.

### 2-hour plan

- `Agent-Sentry`와 `AuthGraph`를 집중 읽고 detector comparison table을 만듭니다.
- `AgentDyn`과 `SafeClawBench`에서 실험에 쓸 수 있는 trace/task/dataset format을 확인합니다.
- `MalSkillBench`의 sandbox verification pipeline을 읽고 strace/inotify 기반 graph extraction 가능성을 판단합니다.

### Deep reading plan

- Day 1: `Agent-Sentry`, `AuthGraph`, `From Agent Traces to Trust`를 읽어 graph schema 후보를 확정합니다.
- Day 2: `AgentDyn`, `AgentDojo`, `SafeClawBench`, `MSB`, `MCPTox`를 비교해 benchmark matrix를 만듭니다.
- Day 3: `MalSkillBench`, `FuseChain`, `CaMeL`을 읽고 OS/runtime telemetry와 agent trace를 결합한 detector prototype design을 작성합니다.
- Day 4: AgentDojo 또는 AgentDyn에서 20개 benign/attack runs를 실행해 JSON trace를 graph로 변환합니다.
- Day 5: rule-based taint path detector, frequent-subgraph anomaly detector, authorization graph alignment baseline을 최소 구현으로 비교합니다.
