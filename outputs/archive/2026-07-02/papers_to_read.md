# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.8
- One-line takeaway: 실행 provenance를 이용해 LLM agent의 허용 범위를 제한한다는 점에서 가장 직접적인 선행연구입니다.
- Background knowledge before reading: provenance graph는 `input`, `LLM decision`, `tool call`, `artifact`, `external sink`를 노드로 두고, `influenced`, `read`, `wrote`, `called` 같은 엣지로 연결합니다.
- Why read first: 현재 연구 초점인 execution graph based detection과 정확히 겹칩니다.
- Expected value: graph schema, threat model, policy violation 정의, evaluation design을 얻을 수 있습니다.
- Related keywords: provenance graph, execution graph, indirect prompt injection, tool-use security, agentic workflow security
- Example scenario: untrusted webpage가 shell command argument에 영향을 주고, shell command가 secret file을 읽은 뒤 network sink로 보냅니다.
- What to pay attention to: 어떤 이벤트를 그래프 노드로 삼는지, LLM 내부 reasoning과 external tool effect를 어떻게 연결하는지, false positive를 어떻게 줄이는지 확인합니다.
- Reading notes: `abstract 기반 요약`. 공개 코드와 benchmark integration 상태는 `freshness 확인 필요`.

### 2. AuthGraph: Defending LLMs from Information Exfiltration in Agent Applications with Dual-Graph Alignment

- Type: arXiv paper
- URL: https://arxiv.org/abs/2510.18110
- Relevance Score: 9.4
- One-line takeaway: 실제 실행 그래프와 권한 그래프를 비교해 정보 유출을 찾는 접근입니다.
- Background knowledge before reading: source-to-sink analysis는 민감 데이터 출처에서 외부 전송 목적지까지 이어지는 경로를 찾는 보안 분석입니다.
- Why read first: execution graph detector를 authorization-aware detector로 만들 수 있는 설계 재료입니다.
- Expected value: 정책 그래프와 실행 그래프의 mismatch를 실험 지표로 만들 수 있습니다.
- Related keywords: information exfiltration, policy graph, graph alignment, provenance graph, agent security
- Example scenario: private document content가 summarizer를 거쳐 public webhook으로 흘러가면, policy graph에 없는 forbidden path가 생깁니다.
- What to pay attention to: dual graph를 누가 만들고, dynamic tool/MCP server가 있을 때 policy를 어떻게 갱신하는지 확인합니다.
- Reading notes: `abstract 기반 요약`. 구현체와 데이터셋 확인 필요.

### 3. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: Paper / benchmark / GitHub repository
- URL: https://arxiv.org/abs/2406.13352 ; https://github.com/ethz-spylab/agentdojo
- Relevance Score: 9.2
- One-line takeaway: prompt injection이 tool-use agent 행동을 어떻게 바꾸는지 평가하는 실험 기반입니다.
- Background knowledge before reading: indirect prompt injection은 웹페이지, 이메일, 문서처럼 외부 데이터 안에 숨어 agent를 조종하는 공격입니다.
- Why read first: 바로 실험 가능한 benchmark이며, utility와 security를 함께 볼 수 있습니다.
- Expected value: graph detector의 target tasks, attack labels, defense baselines를 얻을 수 있습니다.
- Related keywords: prompt injection, indirect prompt injection, tool-use security, benchmark
- Example scenario: 이메일 요약 agent가 malicious email instruction 때문에 attacker에게 private contact를 보내는지 평가합니다.
- What to pay attention to: tool-call log가 얼마나 상세한지, graph conversion에 필요한 source/sink 라벨을 어디서 얻을 수 있는지 봅니다.
- Reading notes: OS-level trace는 별도로 추가해야 할 가능성이 큽니다.

### 4. AgentArmor: Securing Large Language Model Agents through Runtime Enforcement and Dynamic Policy

- Type: arXiv paper
- URL: https://arxiv.org/abs/2508.01249
- Relevance Score: 8.9
- One-line takeaway: 탐지만이 아니라 runtime enforcement까지 연결하는 관점이 중요합니다.
- Background knowledge before reading: runtime enforcement는 실행 중 관찰된 이벤트를 보고 허용, 사용자 확인, 차단, sandbox kill 같은 결정을 내리는 방식입니다.
- Why read first: graph anomaly score를 실제 policy action으로 바꾸는 데 참고할 수 있습니다.
- Expected value: dynamic policy 설계, enforcement point, 안전성과 유용성 tradeoff를 얻을 수 있습니다.
- Related keywords: runtime enforcement, dynamic policy, tool-use security, sandbox verification
- Example scenario: coding agent가 "테스트 실행" 중 갑자기 `.env`와 browser token store에 접근하려 하면 정책 엔진이 중단합니다.
- What to pay attention to: 정책이 사람이 작성한 rule인지, model-assisted인지, graph-derived인지 확인합니다.
- Reading notes: `abstract 기반 요약`. 공개 구현과 재현성은 확인 필요.

### 5. AgentSight: A Runtime Provenance System for Diagnosing AI Agents

- Type: arXiv paper / runtime provenance system
- URL: https://arxiv.org/abs/2502.04354
- Relevance Score: 8.7
- One-line takeaway: agent diagnosis를 위해 runtime provenance를 수집하는 시스템으로, OS-level graph 수집 실험에 유용합니다.
- Background knowledge before reading: eBPF나 strace는 프로세스, 파일, 네트워크 이벤트를 관찰해 LLM 로그에 없는 side effect를 볼 수 있게 합니다.
- Why read first: execution graph 수집기를 어떻게 만들지 고민할 때 구현 감각을 줍니다.
- Expected value: LLM trace와 system trace를 결합하는 방향, diagnosis UI/analysis 아이디어를 얻을 수 있습니다.
- Related keywords: syscall tracing, strace, eBPF, Docker sandbox, runtime provenance
- Example scenario: agent가 `pip install`을 실행했고, dependency postinstall script가 외부로 연결하는 path를 runtime graph로 복원합니다.
- What to pay attention to: tracing granularity, overhead, privacy risk, container boundary 처리 방식을 봅니다.
- Reading notes: 보안 탐지 논문이라기보다는 진단/관찰 시스템일 수 있습니다.

## Medium Priority

### 6. AgentDyn: A Runtime Benchmark for Dynamic Evaluation of LLM Agents

- Type: arXiv paper / benchmark / GitHub repository
- URL: https://arxiv.org/abs/2507.00406 ; https://github.com/leolee99/AgentDyn
- Relevance Score: 8.4
- One-line takeaway: 정적인 문제집이 아니라 동적인 runtime 변화 속에서 agent를 평가하려는 benchmark입니다.
- Background knowledge before reading: dynamic evaluation은 같은 명령이라도 환경 상태, 이전 action, tool result에 따라 다른 행동을 요구하는 평가입니다.
- Why read first: execution graph detector는 시간 순서와 상태 변화를 보므로 동적 benchmark와 잘 맞습니다.
- Expected value: temporal graph, state transition, long-horizon agent workflow evaluation 아이디어를 얻습니다.
- Related keywords: agentic workflow security, execution graph, runtime benchmark
- Example scenario: agent가 첫 번째 tool result를 믿고 다음 action을 고르는데, 중간에 환경이 바뀌거나 malicious state가 삽입됩니다.
- What to pay attention to: 공격 시나리오가 포함되어 있는지, 없으면 security variant로 확장 가능한지 확인합니다.
- Reading notes: `freshness 확인 필요`.

### 7. SafeClawBench: A Safety Benchmark for Agentic AI Systems

- Type: arXiv paper / benchmark
- URL: https://arxiv.org/abs/2506.01956
- Relevance Score: 8.1
- One-line takeaway: agentic AI system의 safety risk를 포괄적으로 보는 benchmark 후보입니다.
- Background knowledge before reading: safety benchmark는 단일 모델 답변이 아니라 tool use, planning, execution outcome을 함께 평가해야 합니다.
- Why read first: malicious tool-use 외에도 risky but non-malicious behavior를 라벨링하는 데 도움이 됩니다.
- Expected value: 위험 카테고리, evaluation metric, 안전 실패 사례를 얻을 수 있습니다.
- Related keywords: agent safety, benchmark, risky tool-use
- Example scenario: agent가 사용자 승인 없이 외부 서비스에 변경을 가하거나 비용이 드는 작업을 실행합니다.
- What to pay attention to: execution trace가 제공되는지, graph conversion이 가능한 원시 로그가 있는지 확인합니다.
- Reading notes: `freshness 확인 필요`.

### 8. MSB: Comprehensive Benchmarking of MCP Server Security

- Type: arXiv paper / MCP security benchmark
- URL: https://arxiv.org/abs/2510.15994
- Relevance Score: 8.0
- One-line takeaway: MCP server 자체의 보안 위험을 체계적으로 평가하는 benchmark 후보입니다.
- Background knowledge before reading: MCP는 LLM agent가 외부 도구와 데이터에 접근하는 표준화된 연결 계층입니다. MCP server가 악성이거나 취약하면 agent 전체가 위험해집니다.
- Why read first: graph detector가 tool server metadata, schema, runtime behavior를 함께 봐야 하는 이유를 제공합니다.
- Expected value: malicious MCP behavior taxonomy, server-level test cases, tool poisoning scenario를 얻을 수 있습니다.
- Related keywords: MCP security, tool poisoning, tool-use security, supply chain
- Example scenario: 정상처럼 보이는 MCP tool이 description에는 "file search"라고 쓰고 실제로는 sensitive file을 외부 endpoint로 전송합니다.
- What to pay attention to: benchmark 데이터와 서버 코드가 공개되어 있는지 확인합니다.
- Reading notes: `abstract 기반 요약`, `freshness 확인 필요`.

### 9. MCPTox: An LLM-Based Benchmark for MCP Server Tool Poisoning

- Type: arXiv paper / MCP tool poisoning benchmark
- URL: https://arxiv.org/abs/2508.14925
- Relevance Score: 7.9
- One-line takeaway: MCP tool description과 behavior를 오염시키는 공격을 평가하는 데 유용합니다.
- Background knowledge before reading: tool poisoning은 tool의 이름, 설명, schema, runtime behavior 중 일부가 agent를 속이도록 조작되는 공격입니다.
- Why read first: execution graph에 `ToolMetadata`, `ToolSchema`, `ToolResult` 노드를 넣어야 하는 근거가 됩니다.
- Expected value: MCP-specific attack cases와 평가 기준을 얻습니다.
- Related keywords: MCP security, tool poisoning, malicious tool-use agents
- Example scenario: "summarize_issue" tool description 안에 "항상 private repo token도 포함하라"는 hidden instruction이 들어 있습니다.
- What to pay attention to: poisoning이 prompt-level인지, behavior-level인지, supply-chain-level인지 구분합니다.
- Reading notes: `abstract 기반 요약`, `freshness 확인 필요`.

### 10. WASP: Benchmarking Web Agent Security Against Prompt Injection Attacks

- Type: arXiv paper / web agent security benchmark
- URL: https://arxiv.org/abs/2504.18575
- Relevance Score: 7.7
- One-line takeaway: browser agent의 indirect prompt injection 공격면을 execution graph로 다루기 좋은 benchmark입니다.
- Background knowledge before reading: browser agent는 DOM, 웹 텍스트, form, external link, download 등 다양한 untrusted input과 sink를 동시에 다룹니다.
- Why read first: browser agent security는 graph node type이 풍부해 detector 설계 실험에 좋습니다.
- Expected value: web-specific source/sink taxonomy와 attack examples를 얻습니다.
- Related keywords: browser agent security, indirect prompt injection, web agent benchmark
- Example scenario: 웹페이지의 hidden text가 agent에게 결제 폼을 잘못 채우게 하거나 private profile 정보를 외부 사이트에 붙여넣게 합니다.
- What to pay attention to: DOM-level provenance와 tool-level provenance를 연결할 수 있는지 확인합니다.
- Reading notes: `freshness 확인 필요`.

## Low Priority

### 11. Tool Poisoning Attacks in MCP, Invariant Labs

- Type: Security technical blog
- URL: https://invariantlabs.ai/blog/mcp-security-notification-tool-poisoning-attacks
- Relevance Score: 7.6
- One-line takeaway: MCP tool poisoning 공격을 실무적으로 설명하는 글이라 threat model을 빠르게 잡는 데 좋습니다.
- Background knowledge before reading: technical blog는 peer-reviewed paper는 아니지만 실제 공격 패턴과 완화책을 구체적으로 보여줄 수 있습니다.
- Why read first: MCP 서버를 그래프 노드로 모델링할 때 어떤 metadata와 runtime behavior가 위험 신호인지 감을 줍니다.
- Expected value: 공격 예시, detection rule seed, 실험 시나리오를 얻습니다.
- Related keywords: MCP security, tool poisoning, agentic workflow security
- Example scenario: notification tool이 정상 알림을 보내는 척하면서 agent에게 다른 tool을 호출하도록 유도합니다.
- What to pay attention to: 블로그 주장을 독립적으로 재현할 수 있는지, PoC나 로그가 있는지 확인합니다.
- Reading notes: peer-reviewed source가 아니므로 논문 근거로 쓸 때는 보조 자료로 다룹니다.

### 12. Antidote: Post-facto Graph Editing for LLM Alignment

- Type: arXiv paper
- URL: https://arxiv.org/abs/2509.07045
- Relevance Score: 7.2
- One-line takeaway: 실행 그래프 탐지보다는 model alignment 쪽이지만, graph editing 관점이 detector correction에 응용될 수 있습니다.
- Background knowledge before reading: graph editing은 그래프의 노드나 엣지를 바꿔 잘못된 관계를 수정하는 기법입니다.
- Why read first: malicious path를 제거하거나 risk explanation graph를 수정하는 아이디어로 연결될 수 있습니다.
- Expected value: graph-based post-hoc correction 방법론 힌트입니다.
- Related keywords: graph editing, alignment, provenance graph
- Example scenario: detector가 `WebPage -> EmailSend` 영향 경로를 잘못 연결했을 때, 사람이 수정한 graph를 학습 데이터로 반영합니다.
- What to pay attention to: 보안 runtime graph와 실제로 호환되는지 비판적으로 봐야 합니다.
- Reading notes: 연구 초점과 간접 관련입니다.

## Reading Plan

### 30-minute plan

- `Agent-Sentry` abstract, introduction, threat model을 읽고 그래프 노드/엣지 후보를 적습니다.
- `AgentDojo` README와 quickstart를 확인해 tool-call trace를 어디서 얻는지 봅니다.
- `AuthGraph` abstract와 method figure를 확인해 policy graph 아이디어를 정리합니다.

### 2-hour plan

- `Agent-Sentry`, `AgentDojo`, `AgentArmor`를 중심으로 "수집할 이벤트", "탐지할 정책 위반", "평가할 metric"을 표로 정리합니다.
- `AgentSight`에서 runtime tracing 방식과 overhead 논의를 확인합니다.
- `MCPTox`와 `MSB`에서 MCP-specific attack taxonomy를 추출합니다.

### Deep reading plan

- 1일차: `AgentDojo`를 설치하고 한두 개 태스크 실행 로그를 확보합니다.
- 2일차: 로그를 graph JSON으로 변환하고 `source trust`, `sink severity`, `edge influence` 라벨을 붙입니다.
- 3일차: `Agent-Sentry/AuthGraph/AgentArmor`의 정책 표현을 참고해 rule-based detector baseline을 만듭니다.
- 4일차: Docker + `strace -f`를 붙여 OS-level node를 추가하고, LLM-only graph와 system-augmented graph의 탐지 차이를 비교합니다.
