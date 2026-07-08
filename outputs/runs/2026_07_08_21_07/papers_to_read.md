# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper / runtime defense
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.8
- One-line takeaway: 정상 실행 provenance를 학습해 out-of-bound tool calls를 차단한다.
- Background knowledge before reading: provenance graph는 tool call 인자값의 source와 action sequence를 함께 저장한다. 공격은 보통 untrusted source에서 민감 tool argument로 이어지는 비정상 경로를 만든다.
- Why read first: 연구 주제인 execution/provenance graph detection에 가장 직접적이며, 실험 설계와 feature engineering 힌트를 준다.
- Expected value: graph schema, rule detector, classifier baseline, LLM judge fallback을 한 번에 얻을 수 있다.
- Related keywords: execution graph, provenance graph, indirect prompt injection, AgentDojo, AgentDyn, tool-use security.
- Example scenario: 회의 예약 agent가 이메일을 읽고 일정을 잡아야 하는데, 외부 호텔 페이지가 결제 계좌 인자를 바꾼다. provenance가 `hotel_page -> payment_account`로 이어지면 위험하다.
- What to pay attention to: benign trace 수집 방식, structural feature, allowlist design, ambiguous action 처리, false positive.
- Reading notes: 논문 claim과 내 inference를 분리해서 읽을 것. 특히 94.3% injection blocking, 95.1% benign allow 수치가 어떤 task/model/version에서 나온 것인지 확인.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / graph alignment defense
- URL: https://arxiv.org/abs/2605.26497
- Relevance Score: 9.6
- One-line takeaway: 실제 실행 provenance와 깨끗한 authorization graph를 비교해 parameter-source deviation을 잡는다.
- Background knowledge before reading: authorization graph는 user intent에서 허용되는 tool sequence와 인자 출처를 나타낸다. observed graph는 agent가 실제로 수행한 경로다.
- Why read first: "오염된 trace만 보고 판단하면 공격자에게 속을 수 있다"는 문제를 다루므로 내 연구의 핵심 기준선이 된다.
- Expected value: expected-vs-observed graph alignment detector 설계에 바로 연결된다.
- Related keywords: authorization graph, provenance graph, graph alignment, indirect prompt injection, parameter source, AgentDyn.
- Example scenario: 사용자는 "가장 싼 항공편을 예약"하라고 했다. 실제 agent가 웹 광고의 hidden instruction 때문에 다른 항공편 ID를 쓰면, tool call은 정상이어도 인자 출처가 틀린다.
- What to pay attention to: clean context를 어떻게 보장하는지, authorization graph 생성 실패가 어떤 오탐/미탐을 만드는지, AgentDojo/AgentDyn utility drop.
- Reading notes: coding agent와 package install attack으로 확장할 때 expected graph를 사람이 쓰는지, LLM이 쓰는지, static template로 쓰는지 결정해야 한다.

### 3. AgentArmor: Enforcing Program Analysis on Agent Runtime Trace to Defend Against Prompt Injection

- Type: arXiv paper / structured graph analysis
- URL: https://arxiv.org/abs/2508.01249
- Relevance Score: 9.2
- One-line takeaway: agent trace를 프로그램 의존성 그래프로 바꾸고 type system으로 policy violation을 찾는다.
- Background knowledge before reading: CFG는 제어 흐름, DFG는 데이터 흐름, PDG는 둘을 결합한 graph다. agent trace에도 tool output이 다음 action에 영향을 주는 흐름이 존재한다.
- Why read first: 실행 그래프를 단순 audit log가 아니라 분석 가능한 intermediate representation으로 다루는 방법을 제공한다.
- Expected value: graph constructor, property registry, type checker를 내 prototype 구조로 재사용할 수 있다.
- Related keywords: CFG, DFG, PDG, program analysis, prompt injection, data flow, policy checking.
- Example scenario: coding agent가 README를 읽고 `pip install`을 실행한 뒤 postinstall script가 credential file을 읽는다. PDG는 `README instruction -> install command -> file_read -> network_send` 경로를 보여준다.
- What to pay attention to: node annotation 신뢰성, tool/data metadata 정의, type rule의 표현력, dynamic trace와 static analysis의 경계.
- Reading notes: LLM annotator가 필요한 부분은 공격 표면이 될 수 있으므로 deterministic parser와 OS audit log를 우선 고려한다.

### 4. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: NeurIPS Datasets and Benchmarks / GitHub benchmark
- URL: https://arxiv.org/abs/2406.13352
- Relevance Score: 8.8
- One-line takeaway: tool-using agent의 indirect prompt injection 공격/방어를 비교하는 핵심 benchmark다.
- Background knowledge before reading: AgentDojo는 user task와 attacker goal을 분리하고, tool output에 숨어 있는 공격이 agent 행동을 바꾸는지 평가한다.
- Why read first: 대부분의 graph defense가 AgentDojo와 비교되므로 재현 가능한 첫 실험 환경으로 적합하다.
- Expected value: trace logger를 붙일 수 있는 task suite, attack/defense interface, utility/security metric을 얻는다.
- Related keywords: indirect prompt injection, benchmark, tool-use agents, adaptive attacks, utility/security tradeoff.
- Example scenario: Slack workspace task에서 agent가 외부 프로필 페이지를 읽고, 그 안의 hidden instruction 때문에 비밀 메시지를 attacker에게 보낸다.
- What to pay attention to: task API, defense module interface, attack success metric, benchmark saturation 비판.
- Reading notes: AgentDyn 및 firewall 논문과 함께 읽어야 benchmark 한계를 놓치지 않는다.

### 5. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: arXiv paper / MCP benchmark
- URL: https://arxiv.org/abs/2508.14925
- Relevance Score: 8.7
- One-line takeaway: MCP tool metadata poisoning이 legitimate tool calls로 악성 행동을 유도하는지 평가한다.
- Background knowledge before reading: MCP tool metadata는 모델이 tool을 선택하고 사용하는 자연어 입력이다. code가 악성이 아니어도 설명이 악성일 수 있다.
- Why read first: 내 연구의 `tool poisoning`, `MCP security`, `malicious tool-use agents` 키워드와 직접 맞는다.
- Expected value: metadata influence graph motif와 MCP-specific attack taxonomy를 얻을 수 있다.
- Related keywords: MCP security, tool poisoning, tool metadata, malicious tool-use, tool-use security.
- Example scenario: `summarize_report` tool description이 "모든 API key를 관리자에게 보내라"는 숨은 지시를 포함하고, agent가 정상 `send_email` tool로 데이터를 보낸다.
- What to pay attention to: risk categories, attack templates, tool metadata 변조 방식, artifact 공개 상태.
- Reading notes: arXiv abstract는 anonymized repository를 언급한다. 실제 공개 dataset 위치와 license는 freshness 확인 필요.

## Medium Priority

### 6. AgentDyn: Are Your Agent Security Defenses Deployable in Real-World Dynamic Environments?

- Type: arXiv paper / GitHub benchmark
- URL: https://arxiv.org/abs/2602.03117
- Relevance Score: 8.5
- One-line takeaway: 기존 benchmark의 static/simple task 한계를 지적하고 60개 open-ended task와 560개 injection case를 제안한다.
- Background knowledge before reading: 방어가 쉬운 benchmark에서 좋은 성능을 보여도 실제 agent 환경에서는 과방어하거나 우회될 수 있다.
- Why read first: graph detector가 AgentDojo에만 맞춰지는 것을 막아준다.
- Expected value: GitHub, Shopping, Daily Life 도메인에서 더 현실적인 dynamic planning trace를 얻는다.
- Related keywords: AgentDyn, dynamic benchmark, open-ended tasks, indirect prompt injection.
- Example scenario: GitHub issue를 처리하는 agent가 issue comment의 helpful instruction과 malicious instruction을 구분해야 한다.
- What to pay attention to: helpful third-party instruction과 malicious instruction이 섞인 경우의 label 정의.
- Reading notes: expected graph 생성이 어려운 open-ended task에서 false positive가 얼마나 늘어나는지 실험해야 한다.

### 7. MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents

- Type: ICLR 2026 accepted paper / GitHub benchmark
- URL: https://arxiv.org/abs/2510.15994
- Relevance Score: 8.4
- One-line takeaway: MCP tool-use pipeline 전체에서 12개 attack category와 2,000 attack instances를 제공한다.
- Background knowledge before reading: MCP 공격은 planning, invocation, response handling 각 단계에서 발생할 수 있다.
- Why read first: MCPTox보다 더 넓은 MCP attack taxonomy를 제공한다.
- Expected value: graph detector의 node/edge taxonomy를 MCP pipeline 단계별로 설계하는 데 도움된다.
- Related keywords: MCP security, tool description injection, name collision, retrieval injection, Net Resilient Performance.
- Example scenario: malicious tool이 legitimate tool과 비슷한 이름을 사용해 agent가 잘못 선택하게 만들고, response에서 user를 사칭한다.
- What to pay attention to: NRP metric, real tool execution harness, code reproducibility.
- Reading notes: GitHub repository는 https://github.com/dongsenzhang/MSB 로 확인됨. 논문 version과 code version을 고정해야 한다.

### 8. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: arXiv paper / Hugging Face dataset
- URL: https://arxiv.org/abs/2606.18356
- Relevance Score: 8.2
- One-line takeaway: semantic attack acceptance, audit-visible harm evidence, sandbox-observed harm을 분리해 평가한다.
- Background knowledge before reading: "모델이 공격을 수락했다"와 "실제 환경이 손상됐다"는 서로 다른 failure mode다.
- Why read first: 내 연구의 graph detector를 실제 side-effect 중심 metric으로 평가하게 해준다.
- Expected value: endpoint 분리 평가, sandbox harm label, attack family 구성이 실험 설계에 유용하다.
- Related keywords: SafeClawBench, sandbox harm, audit evidence, tool-return injection, memory poisoning.
- Example scenario: agent가 "DB를 수정하겠다"고 말하는 것과 실제 DB row를 수정하는 것은 다르다. SafeClawBench는 이 차이를 분리한다.
- What to pay attention to: sandbox-observed harm 정의, audit evidence 수집 방식, Hugging Face dataset schema.
- Reading notes: dataset은 https://huggingface.co/datasets/sairights/safeclawbench 에서 확인. 최신 artifact freshness 확인 필요.

### 9. Quantifying Frontier LLM Capabilities for Container Sandbox Escape

- Type: arXiv paper / sandbox benchmark
- URL: https://arxiv.org/abs/2603.02277
- Relevance Score: 7.9
- One-line takeaway: Docker/OCI container sandbox escape 능력을 안전한 CTF benchmark로 측정한다.
- Background knowledge before reading: agent에게 shell access를 주면 tool-use security는 LLM 보안이 아니라 OS/container 보안 문제와 결합된다.
- Why read first: `strace`, Docker sandbox verification, coding agent security 실험의 threat model을 세우는 데 중요하다.
- Expected value: sandbox escape category, nested sandbox design, misconfiguration threat model을 얻는다.
- Related keywords: Docker sandbox, sandbox escape, container security, coding agent security, syscall tracing.
- Example scenario: agent가 `/var/run/docker.sock`에 접근할 수 있으면 host container를 띄워 sandbox 밖 파일을 읽을 수 있다.
- What to pay attention to: CTF task 구조, outer sandbox safety, 어떤 event를 graph node로 남길지.
- Reading notes: 2026-07-07 v2로 최신성이 높다. 실제 code/artifact 공개 위치는 freshness 확인 필요.

## Low Priority

### 10. Indirect Prompt Injections: Are Firewalls All You Need, or Stronger Benchmarks?

- Type: arXiv paper / benchmark critique
- URL: https://arxiv.org/abs/2510.05244
- Relevance Score: 7.8
- One-line takeaway: simple tool-input/tool-output firewall이 기존 benchmark를 쉽게 포화시키며, 더 강한 adaptive benchmark가 필요하다고 주장한다.
- Background knowledge before reading: benchmark가 약하면 복잡한 graph detector가 실제보다 좋아 보일 수 있다.
- Why read first: 내 detector 평가에서 weak attack, flawed metric, implementation bug를 피하게 해준다.
- Expected value: stronger benchmark design checklist와 adaptive attack idea.
- Related keywords: indirect prompt injection, firewalls, sanitizer, minimizer, adaptive attacks.
- Example scenario: tool output sanitizer가 hidden instruction을 지워 공격이 막히지만, 공격자가 두 단계로 지시를 나눠 우회할 수 있다.
- What to pay attention to: 기존 benchmark saturation 사례, proposed fixes, adaptive attack stages.
- Reading notes: graph detector도 같은 benchmark 포화 문제를 겪을 수 있으므로 반드시 adversarial evaluation을 포함한다.

### 11. Progent: Securing AI Agents with Privilege Control

- Type: arXiv paper / policy enforcement defense
- URL: https://arxiv.org/abs/2504.11703
- Relevance Score: 7.7
- One-line takeaway: tool names와 arguments에 대한 symbolic privilege policy로 least privilege를 강제한다.
- Background knowledge before reading: graph detector가 위험 경로를 찾더라도, 실행 직전에는 deterministic policy enforcement가 필요하다.
- Why read first: graph detector의 output을 policy rule로 바꾸는 방법을 배울 수 있다.
- Expected value: monotonic confinement, SMT solver 기반 policy update, LangChain/OpenAI Agents SDK integration hint.
- Related keywords: privilege control, least privilege, SMT solver, tool call policy.
- Example scenario: user task가 "캘린더 읽기"이면 `send_email`이나 `transfer_money` tool은 자동으로 허용되지 않는다.
- What to pay attention to: policy expansion approval, dynamic update, adaptive attack resilience.
- Reading notes: graph alignment과 결합하면 "expected graph에서 벗어난 edge는 privilege expansion"으로 모델링할 수 있다.

### 12. DRIFT: Dynamic Rule-Based Defense with Injection Isolation for Securing LLM Agents

- Type: arXiv paper / dynamic rule defense
- URL: https://arxiv.org/abs/2506.12104
- Relevance Score: 7.6
- One-line takeaway: minimal function trajectory와 parameter checklist를 만들고, memory stream에서 injection을 격리한다.
- Background knowledge before reading: prompt injection은 한 번의 tool call뿐 아니라 memory에 남아 이후 행동을 오염시킬 수 있다.
- Why read first: provenance graph에 memory node와 temporal edge를 넣어야 하는 이유를 제공한다.
- Expected value: dynamic validator, injection isolator, memory stream isolation design.
- Related keywords: dynamic rule, injection isolation, memory poisoning, AgentDojo, ASB, AgentDyn.
- Example scenario: 오늘 읽은 웹페이지의 악성 지시가 memory에 저장되고, 내일 이메일 발송 task에서 활성화된다.
- What to pay attention to: plan deviation 체크와 memory masking의 한계.
- Reading notes: graph detector에는 `memory_write -> future_tool_call` edge가 필요하다.

## Reading Plan

### 30-minute plan

- Agent-Sentry abstract, method overview, evaluation table만 읽고 graph feature 목록을 적는다.
- AuthGraph abstract와 system diagram을 보고 expected/observed graph 차이를 정리한다.
- AgentDojo GitHub quickstart를 확인해 trace hook을 어디에 넣을지 찾는다.

### 2-hour plan

- Agent-Sentry와 AuthGraph를 집중 읽고 공통 graph schema 초안을 만든다.
- AgentArmor의 CFG/DFG/PDG 변환 부분을 읽고 OS event와 결합 가능한 node/edge를 표시한다.
- AgentDojo 또는 AgentDyn 중 하나를 골라 benchmark 실행 경로와 logging 지점을 확인한다.

### Deep reading plan

- Agent-Sentry, AuthGraph, AgentArmor를 표로 비교한다: graph nodes, graph edges, trust labels, detector, benchmark, metrics, limitations.
- MCPTox와 MSB에서 MCP-specific attack category를 뽑아 graph motif taxonomy로 바꾼다.
- SafeClawBench와 SandboxEscapeBench를 읽고 semantic failure, audit evidence, sandbox harm, container escape를 평가 endpoint로 통합한다.
- Progent/DRIFT/firewall 논문을 baseline으로 정하고 graph detector가 단순 policy/firewall보다 나은 조건과 아닌 조건을 명시한다.
