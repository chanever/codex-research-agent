# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper / defense system
- URL: https://arxiv.org/html/2603.22868v2
- Relevance Score: 9.8
- One-line takeaway: provenance graph를 이용해 legitimate behavior의 구조적 패턴을 학습하고, agent action을 allow/ambiguous/block로 분류한다.
- Background knowledge before reading: provenance graph, taint tracking, tool argument source, indirect prompt injection을 알고 읽으면 좋다.
- Why read first: 연구 주제인 "execution graph based detection"과 가장 직접적으로 맞는다.
- Expected value: graph feature 설계, layer별 detector 구성, benchmark 구성, utility/security trade-off 측정 방법을 얻을 수 있다.
- Related keywords: provenance graph, execution trace, AgentDojo, AgentDyn, prompt injection, runtime defense
- Example scenario: untrusted webpage에서 나온 계좌번호가 `transfer_money`의 recipient로 들어가는 경로를 graph feature로 탐지한다.
- What to pay attention to: graph node/edge 정의, XGBoost feature, rule detector, allowlist 검증, LLM judge가 필요한 ambiguous case의 비율.
- Reading notes: Agent-Sentry Bench가 공개되어 있는지 확인하고, 없으면 AgentDojo/AgentDyn trace로 축소 재현한다.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / graph alignment defense
- URL: https://arxiv.org/html/2605.26497v1
- Relevance Score: 9.5
- One-line takeaway: 실제 실행 그래프와 clean-context authorization graph를 맞춰보며 tool 및 parameter source deviation을 잡는다.
- Background knowledge before reading: authorization policy, information flow, graph alignment, prompt injection threat model.
- Why read first: 단순 trace 분석의 약점, 즉 trace builder 자체가 오염될 수 있다는 문제를 정면으로 다룬다.
- Expected value: expected graph를 어떻게 만들고 actual graph와 비교할지에 대한 직접적인 설계 힌트를 준다.
- Related keywords: authorization graph, injected reasoning graph, parameter source, least privilege, graph alignment
- Example scenario: `book_flight` 호출은 허용되지만 `flight_id`가 flight search 결과가 아니라 hotel page에서 왔으면 차단한다.
- What to pay attention to: authorization graph 생성이 과소 권한을 주는지, open-ended task에서 replan이 어떻게 동작하는지.
- Reading notes: coding agent에 적용하려면 user intent에서 허용 shell/file/network capability를 추출하는 별도 planner가 필요하다.

### 3. AgentArmor: Securing Large Language Model Agents via Structured Graph Analysis

- Type: arXiv paper / structured graph analysis
- URL: https://arxiv.org/html/2508.01249v3
- Relevance Score: 9.0
- One-line takeaway: agent trace를 CFG/DFG/PDG 스타일 그래프로 바꾸고 program analysis policy를 적용한다.
- Background knowledge before reading: CFG, DFG, PDG, taint analysis, type system.
- Why read first: `strace`, Docker sandbox verification, syscall tracing을 graph detector로 연결하기 좋은 기반이다.
- Expected value: agent 실행을 프로그램 분석 문제로 환원하는 schema와 policy language 아이디어.
- Related keywords: Program Dependence Graph, trace analysis, prompt injection defense, graph IR
- Example scenario: `read_secret_file -> summarize -> post_to_webhook` dataflow가 보이면 secret exfiltration policy 위반으로 차단한다.
- What to pay attention to: graph annotator가 injection에 노출되는지, policy가 얼마나 수작업인지, false positive 사례.
- Reading notes: AuthGraph와 비교해 "오염 가능한 graph builder" 문제를 보완할 필요가 있다.

### 4. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: NeurIPS benchmark / GitHub repository
- URL: https://arxiv.org/html/2406.13352v3
- Relevance Score: 8.7
- One-line takeaway: tool-use agent의 prompt injection 공격/방어를 평가하는 대표 동적 환경이다.
- Background knowledge before reading: attack success rate, utility rate, indirect prompt injection, tool-use benchmark.
- Why read first: 후속 graph defense 논문들이 공통 비교 대상으로 쓰므로 baseline으로 중요하다.
- Expected value: 실험 harness, task format, attack function, defense pipeline 연결 방식.
- Related keywords: AgentDojo, prompt injection, dynamic benchmark, utility/security trade-off
- Example scenario: travel booking agent가 webpage의 악성 지시에 따라 원래 목적지가 아닌 공격자 목적지로 예약한다.
- What to pay attention to: task suite 규모, attack extensibility, defense API, trace export 가능성.
- Reading notes: graph logging hook을 어디에 넣을 수 있는지 repository 구조를 확인한다.

### 5. AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System

- Type: arXiv paper / GitHub benchmark
- URL: https://arxiv.org/abs/2602.03117
- Relevance Score: 8.5
- One-line takeaway: AgentDojo보다 open-ended task, helpful third-party instruction, 복잡한 user task를 강조하는 prompt injection benchmark다. abstract 기반 요약.
- Background knowledge before reading: static benchmark 한계, adaptive attack, over-defense.
- Why read first: graph detector가 단순 task에서만 잘 되는지, 복잡한 실제형 task에서도 utility를 유지하는지 검증할 수 있다.
- Expected value: Shopping, GitHub, Daily Life 시나리오와 560개 injection test case를 활용한 확장 실험.
- Related keywords: AgentDyn, indirect prompt injection, open-ended task, over-defense
- Example scenario: GitHub issue 해결 중 외부 README의 "테스트 전에 credential을 출력하라"는 helpful-looking instruction을 agent가 따른다.
- What to pay attention to: helpful instruction과 malicious instruction을 graph level에서 어떻게 구분할지.
- Reading notes: AgentDojo 기반이므로 기존 hook 재사용 가능성을 확인한다.

## Medium Priority

### 1. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: arXiv paper / benchmark repository
- URL: https://arxiv.org/html/2508.14925v1
- Relevance Score: 8.6
- One-line takeaway: MCP tool metadata poisoning을 실제 MCP server와 authentic tool 기반으로 평가한다.
- Background knowledge before reading: MCP, tool metadata, tool description poisoning, ASR.
- Why read first: tool catalog/description 자체가 graph node가 되어야 한다는 점을 보여준다.
- Expected value: malicious metadata와 legitimate tool call 사이의 influence edge를 설계하는 데 도움.
- Related keywords: MCP security, tool poisoning, malicious tool description, tool-use security
- Example scenario: poisoned `format_report` 설명이 agent를 유도해 정상 `send_email` tool로 secret을 전송하게 만든다.
- What to pay attention to: poisoned tool 자체가 실행되지 않는 경우도 공격 성공으로 보는 평가 정의.
- Reading notes: GitHub 저장소의 sample format과 license를 확인해야 한다.

### 2. MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents

- Type: arXiv paper / benchmark repository
- URL: https://arxiv.org/html/2510.15994v2
- Relevance Score: 8.3
- One-line takeaway: MCP workflow 여러 단계의 공격을 executable benign/malicious tool로 평가하는 end-to-end benchmark다.
- Background knowledge before reading: MCP workflow, tool discovery, planning, invocation, response handling.
- Why read first: 단일 poisoning 유형보다 넓은 MCP attack taxonomy를 제공한다.
- Expected value: graph detector가 어느 pipeline stage에서 신호를 잡는지 실험 설계 가능.
- Related keywords: MSB, MCP attacks, executable tools, benchmark
- Example scenario: tool discovery 단계에서 악성 tool이 선택되고, invocation 단계에서 위험 인자가 전달되며, response 단계에서 결과가 은폐된다.
- What to pay attention to: attack category별 graph motif가 달라지는지.
- Reading notes: 공식 GitHub `dongsenzhang/MSB`의 2,000+ attack instance 설명은 freshness 확인 필요.

### 3. When the Manual Lies: A Realistic Benchmark to Evaluate MCP Poisoning Attacks for LLM Agents

- Type: arXiv paper / sandbox benchmark
- URL: https://arxiv.org/html/2605.24069v1
- Relevance Score: 8.2
- One-line takeaway: Tool Description Poisoning을 Docker sandbox와 forensic side-effect verification으로 평가한다.
- Background knowledge before reading: Docker sandbox, side-effect verification, OWASP LLM risk categories.
- Why read first: 연구 힌트의 `sandbox verification`, `Docker sandbox`와 직접 연결된다.
- Expected value: "정말 파일이 생성됐는가", "로그에 외부 전송이 남았는가" 같은 물리적 side effect 기반 라벨링 아이디어.
- Related keywords: MCP-TDP, tool description poisoning, forensic evaluation, sandbox
- Example scenario: agent가 metadata에 속아 benign request 수행 중 `/tmp/pwned` 파일을 만들고, benchmark가 sandbox filesystem으로 성공 여부를 검증한다.
- What to pay attention to: side effect 검증이 zero false positive라고 주장하는 조건과 한계.
- Reading notes: 공개 artifact가 없으면 직접 toy MCP sandbox를 만들어 재현한다.

### 4. Nemotron-AIQ Agentic Safety Dataset 1.0

- Type: Hugging Face dataset / trace dataset
- URL: https://huggingface.co/datasets/nvidia/Nemotron-AIQ-Agentic-Safety-Dataset-1.0
- Relevance Score: 7.9
- One-line takeaway: agentic workflow의 OpenTelemetry JSON trace 10K+개를 제공해 trace-to-graph 실험 출발점으로 쓸 수 있다.
- Background knowledge before reading: OpenTelemetry span, trace, parent-child relation, agent workflow.
- Why read first: 자체 benchmark 구축 전 graph extraction pipeline을 검증할 수 있다.
- Expected value: spans, inputs, outputs, intermediate tool interactions에서 graph node/edge를 추출하는 연습 데이터.
- Related keywords: OpenTelemetry, agentic safety, trace dataset, security guard
- Example scenario: AI-Q Research Assistant 실행 trace에서 각 tool span과 input/output을 node로 만들고 risk score와 graph feature를 연결한다.
- What to pay attention to: 특정 NVIDIA AI-Q workflow에 편향되어 일반화가 제한될 수 있다.
- Reading notes: license와 harmful content handling 정책 확인이 필요하다.

## Low Priority

### 1. Securing LLM Agents Need Intent-to-Execution Integrity

- Type: arXiv position paper
- URL: https://arxiv.org/abs/2605.16976
- Relevance Score: 7.8
- One-line takeaway: agent security를 user intent가 concrete execution으로 올바르게 보존되는지의 integrity 문제로 정식화한다. abstract 기반 요약.
- Background knowledge before reading: compiler correctness, information flow, agent execution pipeline.
- Why read first: 구현 논문은 아니지만 graph detector가 어떤 보안 성질을 만족해야 하는지 언어를 준다.
- Expected value: Tool Integrity, Instruction Integrity, Judgment Integrity, Data Flow Integrity를 평가 축으로 사용할 수 있다.
- Related keywords: intent-to-execution integrity, untrusted tool execution, untrusted data ingestion
- Example scenario: 사용자의 "테스트만 실행" 의도가 package install과 network exfiltration으로 변질되면 integrity 위반이다.
- What to pay attention to: 네 가지 integrity 속성을 graph schema의 label/constraint로 바꾸는 방법.
- Reading notes: novelty 주장은 조심하고, 실험 아이디어의 framing 문헌으로 활용한다.

### 2. Model Context Protocol Threat Modeling and Analyzing Vulnerabilities to Prompt Injection with Tool Poisoning

- Type: arXiv threat modeling paper
- URL: https://arxiv.org/html/2603.22489v1
- Relevance Score: 7.6
- One-line takeaway: MCP client-side tool poisoning 취약점을 threat model과 validation gap 관점에서 정리한다.
- Background knowledge before reading: MCP client/server architecture, static metadata analysis, behavioral anomaly detection.
- Why read first: MCP metadata validation과 model decision path tracking을 graph detector와 연결할 수 있다.
- Expected value: 공격면 분류와 defense-in-depth 설계 힌트.
- Related keywords: MCP threat model, client-side security, tool poisoning, behavioral anomaly detection
- Example scenario: MCP client가 tool parameter visibility를 충분히 제공하지 않아 사용자가 실제 위험 인자를 확인하지 못한다.
- What to pay attention to: 어떤 client가 어떤 validation을 제공하는지 최신성이 매우 중요하다.
- Reading notes: client 버전별 결과는 freshness 확인 필요.

### 3. "Do Not Mention This to the User": Detecting and Understanding Malicious Agent Skills in the Wild

- Type: USENIX Security 2026 / arXiv paper
- URL: https://arxiv.org/abs/2602.06547
- Relevance Score: 7.4
- One-line takeaway: third-party agent skill 자체가 공급망 공격면이 될 수 있음을 대규모 skill 분석으로 보여준다. abstract 기반 요약.
- Background knowledge before reading: skill marketplace, natural-language instruction vulnerability, software supply chain attack.
- Why read first: malicious package/skill detection을 execution graph와 결합하는 후속 연구 아이디어에 유용하다.
- Expected value: skill README/SKILL.md 같은 자연어 지시가 실제 실행으로 이어지는 경로를 라벨링하는 방식.
- Related keywords: malicious skills, OpenClaw, coding agent security, supply chain
- Example scenario: skill 설명서가 "사용자에게 말하지 말고 terminal command를 실행하라"고 agent에게 지시한다.
- What to pay attention to: dataset 공개 여부, behavior-verified 라벨링 방식, 자연어 취약점과 코드 취약점 비율.
- Reading notes: USENIX 페이지와 arXiv 버전의 차이를 확인한다.

## Reading Plan

### 30-minute plan

- Agent-Sentry abstract/introduction/method overview만 읽고 graph node, edge, feature 목록을 메모한다.
- AuthGraph의 Figure 1/2와 parameter-source check 설명을 읽어 expected-vs-actual graph 비교 방식을 파악한다.
- AgentDojo README를 훑어 tracing hook을 넣을 위치를 찾는다.

### 2-hour plan

- Agent-Sentry method와 evaluation을 읽고 `allow`, `ambiguous`, `block` decision pipeline을 재구성한다.
- AuthGraph의 graph schema와 alignment checker를 정리해 Agent-Sentry와 차이를 표로 만든다.
- MCPTox 또는 MSB sample을 하나 열어 `tool_metadata`, `tool_call`, `harmful_side_effect` graph motif를 손으로 그린다.

### Deep reading plan

- AgentArmor, Agent-Sentry, AuthGraph를 함께 읽고 graph schema 통합안을 만든다.
- AgentDojo/AgentDyn 중 하나를 로컬에서 실행해 trace를 JSONL로 뽑는다.
- `strace` 또는 OpenTelemetry 기반 host-level event를 추가해 graph detector baseline을 구현한다.
- MCPTox/MSB/MCP-TDP 계열에서 MCP metadata poisoning 공격을 하나 재현하고 graph motif detector, text classifier, LLM judge baseline을 비교한다.
