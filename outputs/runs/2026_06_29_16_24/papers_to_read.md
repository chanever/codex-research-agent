# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: Paper
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.8
- Why read first: 연구 질문인 "execution/provenance graph가 malicious tool-use를 어떻게 드러내는가"에 가장 직접적인 답을 준다.
- Expected value: benign execution boundary, argument provenance feature, residual LLM judge 설계를 비교 기준선으로 삼을 수 있다.
- Related keywords: execution provenance, tool-use security, prompt injection, AgentDojo, AgentDyn
- Reading notes: benign trace 학습 방식, out-of-bound tool call 정의, false positive 처리, model-independent 적용 여부를 중점 확인한다.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: Paper
- URL: https://arxiv.org/abs/2605.26497
- Relevance Score: 9.6
- Why read first: "실제 실행 graph"와 "허용된 authorization graph"를 분리해 parameter-source-level deviation을 탐지하는 설계가 실험 아이디어로 바로 이어진다.
- Expected value: clean-context authorization baseline, source_tools constraint, graph alignment checker를 구현 가능한 detector로 바꿀 수 있다.
- Related keywords: provenance graph, authorization graph, indirect prompt injection, parameter pollution, tool-use security
- Reading notes: injected reasoning graph가 오염을 허용하면서도 detection에 쓰이는 부분, replan mechanism, AgentDojo/AgentDyn 평가 세부를 확인한다.

### 3. AgentArmor: Enforcing Program Analysis on Agent Runtime Trace to Defend Against Prompt Injection

- Type: Paper
- URL: https://arxiv.org/abs/2508.01249
- Relevance Score: 9.3
- Why read first: agent trace를 program IR/PDG로 해석하는 관점이 syscall tracing과 provenance graph를 결합하는 데 유용하다.
- Expected value: CFG/DFG/PDG, property registry, type-system policy checking을 agent security에 이식하는 방법을 얻을 수 있다.
- Related keywords: execution graph, program dependence graph, prompt injection, coding agent security, data-flow policy
- Reading notes: trace-to-graph 변환의 신뢰성, LLM graph annotator 사용 여부, policy language가 실제 MCP/coding-agent event에 맞는지 확인한다.

### 4. MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents

- Type: Paper + Repository
- URL: https://arxiv.org/abs/2510.15994
- Relevance Score: 8.8
- Why read first: MCP 공격을 planning, invocation, response handling 단계로 나누기 때문에 graph feature를 단계별로 설계하기 좋다.
- Expected value: 12개 attack taxonomy, executable MCP tools, Net Resilient Performance metric을 detector 평가에 재사용할 수 있다.
- Related keywords: MCP security, tool poisoning, retrieval injection, tool-transfer, benchmark
- Reading notes: GitHub repository https://github.com/dongsenzhang/MSB 에서 attack instance 형식과 로그 가능 지점을 확인한다.

### 5. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: Paper + Benchmark
- URL: https://arxiv.org/abs/2508.14925
- Relevance Score: 9.0
- Why read first: tool metadata poisoning이 execution graph detector에 어떤 provenance edge를 요구하는지 가장 분명하게 보여준다.
- Expected value: poisoned metadata, legitimate tool misuse, hidden malicious goal 사이의 causal chain을 그래프로 표현하는 실험 재료가 된다.
- Related keywords: MCP security, tool poisoning, malicious tool metadata, supply chain attack, prompt injection
- Reading notes: 공개 저장소 https://github.com/zhiqiangwang4/MCPTox-Benchmark 의 최신 데이터와 arXiv 수치 차이를 확인한다.

## Medium Priority

### 1. TraceAegis: Securing LLM-Based Agents via Hierarchical and Behavioral Anomaly Detection

- Type: Paper
- URL: https://arxiv.org/abs/2510.11203
- Relevance Score: 8.4
- Why read first: 정상 agent behavior를 hierarchical execution unit과 behavioral rules로 추상화하는 anomaly detection 계열이다.
- Expected value: graph motif 또는 rule mining 방식의 baseline detector 설계에 도움된다.
- Related keywords: provenance-based analysis, anomaly detection, execution trace, tool poisoning
- Reading notes: abstract 기반 요약. TraceAegis-Bench 공개 여부, healthcare/procurement scenario의 event schema, abnormal label 정의를 확인한다.

### 2. From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents

- Type: Survey
- URL: https://arxiv.org/abs/2606.04990
- Relevance Score: 8.2
- Why read first: evidence tracing과 execution provenance 용어, trace granularity, representation, trust function을 체계화한다.
- Expected value: 논문 related work와 taxonomy backbone으로 쓸 수 있다.
- Related keywords: execution provenance, evidence tracing, provenance graph, tool-use safety, observability
- Reading notes: survey이므로 novelty claim보다 용어 정리, benchmark gap, trace schema open problems를 뽑아낸다.

### 3. AgentDojo

- Type: Benchmark + Repository
- URL: https://github.com/ethz-spylab/agentdojo
- Relevance Score: 8.0
- Why read first: 많은 graph/provenance defense가 AgentDojo를 평가 환경으로 쓴다.
- Expected value: realistic tasks와 security test cases를 실행 trace 수집 harness로 바꿀 수 있다.
- Related keywords: prompt injection, benchmark, tool-integrated agents, AgentDojo
- Reading notes: 97 realistic tasks와 629 security test cases 구조, tool call logging hook, attack/defense plugin 구조를 확인한다.

### 4. AgentDyn

- Type: Benchmark + Repository
- URL: https://github.com/leolee99/AgentDyn
- Relevance Score: 7.9
- Why read first: dynamic/open-ended task에서 static benchmark defense가 깨지는지 확인하는 데 중요하다.
- Expected value: execution graph detector가 fixed plan에 과적합되는지 평가할 수 있다.
- Related keywords: dynamic planning, prompt injection, AgentDojo, open-ended benchmark
- Reading notes: 60 tasks, 560 injection cases의 open-ended trajectory가 graph alignment detector에 어떤 부담을 주는지 본다.

### 5. AgentProvenance

- Type: GitHub repository / implementation idea
- URL: https://github.com/ByteYellow/AgentProvenance
- Relevance Score: 8.1
- Why read first: sandboxed agent execution, file diff, process/network/runtime telemetry, risk signal을 causality graph로 묶는 구현 방향과 매우 가깝다.
- Expected value: white-box tool context와 zero-SDK runtime telemetry를 상관시키는 schema 아이디어를 얻을 수 있다.
- Related keywords: provenance graph, eBPF, Falco, Tetragon, Docker sandbox, coding agent security
- Reading notes: 연구 논문은 아니므로 freshness 확인 필요. 구현 성숙도, 라이선스, 실제 eBPF receiver 완성도를 clone 후 확인한다.

## Low Priority

### 1. Trail of Bits mcp-context-protector

- Type: GitHub repository / security wrapper
- URL: https://github.com/trailofbits/mcp-context-protector
- Relevance Score: 7.6
- Why read first: trust-on-first-use pinning과 tool description validation이 provenance graph의 metadata integrity feature로 이어질 수 있다.
- Expected value: MCP server configuration drift, tool description 변경 감지, ANSI sanitization 같은 실용 control을 확인한다.
- Related keywords: MCP security, tool poisoning, prompt injection, trust-on-first-use
- Reading notes: graph detector와 결합하면 "metadata changed after approval" edge를 risk feature로 만들 수 있다.

### 2. MCP Tool Poisoning Experiments

- Type: GitHub repository / attack experiments
- URL: https://github.com/invariantlabs-ai/mcp-injection-experiments
- Relevance Score: 7.5
- Why read first: tool poisoning PoC를 빠르게 재현해 provenance logging을 붙일 수 있다.
- Expected value: 최소 MCP attack fixture 구축에 유용하다.
- Related keywords: MCP security, tool poisoning, indirect prompt injection, malicious tool metadata
- Reading notes: freshness 확인 필요. 최신 mcp-scan/agent-scan 계열로 대체되었는지 확인한다.

### 3. Jumping the line: How MCP servers can attack you before you ever use them

- Type: Technical blog
- URL: https://blog.trailofbits.com/2025/04/21/jumping-the-line-how-mcp-servers-can-attack-you-before-you-ever-use-them/
- Relevance Score: 7.4
- Why read first: malicious MCP server가 tool invocation 전 단계에서 model context를 오염시키는 threat model을 잘 설명한다.
- Expected value: pre-execution metadata ingestion node를 graph에 반드시 넣어야 하는 이유를 정리할 수 있다.
- Related keywords: MCP security, line jumping, tool poisoning, prompt injection
- Reading notes: 블로그 기반이므로 논문 근거와 분리해서 threat model 사례로만 사용한다.

### 4. Poison everywhere: No output from your MCP server is safe

- Type: Technical blog
- URL: https://www.cyberark.com/resources/threat-research-blog/poison-everywhere-no-output-from-your-mcp-server-is-safe
- Relevance Score: 7.2
- Why read first: description field뿐 아니라 schema 전체와 output까지 공격 표면이 확장된다는 점을 보여준다.
- Expected value: graph node type을 tool description, schema field, tool output, error message까지 확장할 근거가 된다.
- Related keywords: full-schema poisoning, MCP security, tool poisoning, tool output attack
- Reading notes: vendor blog이므로 PoC 세부와 재현 가능성을 확인한다.

### 5. awesome-agent-runtime-security

- Type: GitHub curated list
- URL: https://github.com/bureado/awesome-agent-runtime-security
- Relevance Score: 7.0
- Why read first: sandbox, eBPF, MicroVM, gVisor, WASM, seccomp 계열 구현 후보를 빠르게 훑을 수 있다.
- Expected value: Docker sandbox verification과 syscall tracing 실험 환경 선택에 도움된다.
- Related keywords: Docker sandbox, gVisor, eBPF, seccomp, coding agent security
- Reading notes: curated list라 freshness 확인 필요. 각 프로젝트의 실제 유지보수 상태는 별도 확인한다.

## Reading Plan

### 30-minute plan

- Agent-Sentry abstract와 method overview를 읽고 detector feature를 세 줄로 요약한다.
- AuthGraph abstract와 Figure/architecture 부분을 읽고 IRG/AG/Checker 세 컴포넌트를 도식화한다.
- MCPTox와 MSB abstract를 읽고 benchmark에서 바로 수집 가능한 trace field를 적는다.

### 2-hour plan

- AgentArmor, Agent-Sentry, AuthGraph를 비교표로 정리한다: graph representation, trusted/untrusted source, policy target, benchmark, metric, limitation.
- MSB GitHub와 MCPTox GitHub를 열어 sample format, tool execution path, logging hook 가능 지점을 확인한다.
- AgentDojo/AgentDyn에서 tool-call trace를 뽑을 수 있는 최소 실행 루트를 찾는다.

### Deep reading plan

- AgentArmor의 trace-to-PDG 변환과 AuthGraph의 parameter-source alignment를 결합한 hybrid detector 설계를 문서화한다.
- MCPTox 또는 MSB 20개 샘플을 골라 수동으로 provenance graph schema를 만든다.
- Docker/Falco/Tetragon 또는 strace 기반 runtime telemetry를 tool-call graph와 join하는 key(pid, container_id, timestamp, cwd, tool_call_id)를 정의한다.
- baseline detector 3개를 설계한다: motif rule, out-of-bound classifier, authorization graph alignment.
