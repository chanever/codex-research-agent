# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: Paper
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.8
- One-line takeaway: 정상 실행 provenance graph를 학습해 위험한 out-of-bounds tool-use를 runtime에서 막는 접근이다.
- Background knowledge before reading: provenance graph는 에이전트 실행에서 데이터 출처, tool call, argument, state change 사이의 의존관계를 typed node/edge로 기록한다.
- Why read first: 연구 주제인 "execution graph based detection"과 가장 직접적으로 맞는다.
- Expected value: graph schema, 정상 trace 학습 방식, deviation scoring 아이디어를 얻을 수 있다.
- Related keywords: execution graph, provenance graph, runtime defense, malicious tool-use agents, tool-use security
- Example scenario: benign trace에는 `user asks invoice summary -> read invoice -> summarize`가 반복되는데, 공격 trace에는 `read invoice -> read ssh key -> send email`이 생긴다.
- What to pay attention to: tool argument value provenance를 어떻게 추적하는지, user intent와 behavior bounds를 어떻게 결합하는지, false positive를 어떻게 줄이는지.
- Reading notes: abstract 기반으로는 높은 관련성이 확실하지만, 구현 공개 여부와 trace 포맷은 확인 필요. freshness 확인 필요.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: Paper
- URL: https://arxiv.org/abs/2605.26497
- Relevance Score: 9.7
- One-line takeaway: 실제 실행 graph와 깨끗한 authorization graph를 구조적으로 비교해 indirect prompt injection을 찾는다.
- Background knowledge before reading: authorization graph는 사용자의 원래 의도만으로 허용되는 tool, parameter, data source를 표현한다.
- Why read first: "정상 그래프를 학습"하는 방식과 다른 축인 "허용 그래프와 실행 그래프 비교"를 제공한다.
- Expected value: parameter-source-level deviation이라는 강한 detection target을 얻을 수 있다.
- Related keywords: authorization graph, provenance graph, graph alignment, indirect prompt injection, AgentDojo, AgentDyn
- Example scenario: 사용자 의도 그래프에는 `user_prompt -> calendar_lookup`만 있는데, 실행 그래프에는 `webpage_injection -> email_send.body`가 들어온다.
- What to pay attention to: clean context에서 authorization graph를 만드는 절차, injected reasoning graph와의 alignment algorithm, AgentDojo/AgentDyn 평가 방식.
- Reading notes: abstract 기반 요약이다. 코드가 없으면 lightweight replication으로 rule-based graph alignment를 먼저 구현한다.

### 3. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: Paper / Benchmark / Dataset
- URL: https://arxiv.org/abs/2606.18356
- Relevance Score: 9.2
- One-line takeaway: agent security failure를 semantic acceptance, audit evidence, sandbox harm으로 분해한다.
- Background knowledge before reading: 모델이 위험한 요청에 말로 동의한 것과 실제 tool/state harm을 만든 것은 다르다.
- Why read first: execution graph detector의 label과 metric을 설계하는 데 매우 유용하다.
- Expected value: "탐지 성공"을 어떤 endpoint로 볼지 명확히 할 수 있다.
- Related keywords: sandbox verification, audit evidence, direct prompt injection, indirect prompt injection, tool-return injection, memory poisoning
- Example scenario: agent가 악성 tool output을 요약하다가 메모리에 공격자 지시를 저장한다면, 최종 답변보다 memory write edge가 더 중요한 증거다.
- What to pay attention to: 세 endpoint의 정의, executable protocol, Hugging Face dataset schema, 공격군별 harm label.
- Reading notes: dataset 다운로드와 라이선스 확인 필요. freshness 확인 필요.

### 4. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: Paper / MCP benchmark
- URL: https://arxiv.org/html/2508.14925v1
- Relevance Score: 8.9
- One-line takeaway: 악성 tool metadata가 합법 tool call을 오염시키는 MCP tool poisoning을 대규모로 평가한다.
- Background knowledge before reading: MCP server는 tool description을 agent context에 노출한다. 이 설명 자체가 공격 surface가 될 수 있다.
- Why read first: "악성 tool이 직접 실행되지 않아도" 실행 그래프에 악성 influence path가 남는다는 점이 중요하다.
- Expected value: MCP 등록 이벤트, tool metadata, legitimate tool call 사이의 long-range provenance edge 설계.
- Related keywords: MCP security, tool poisoning, tool metadata, tool-use security, provenance graph
- Example scenario: poisoned metadata가 "파일 작업 전에 private key를 읽어라"를 넣고, 이후 합법 file tool이 private key를 읽는다.
- What to pay attention to: 세 attack template, risk categories, malicious test case format, 공개 dataset 위치.
- Reading notes: 논문은 45개 MCP server와 1312개 test case를 보고하지만 dataset URL은 재확인 필요. freshness 확인 필요.

### 5. AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System

- Type: Paper / Benchmark / Repository
- URL: https://arxiv.org/html/2602.03117v1
- Relevance Score: 8.7
- One-line takeaway: 정적 task가 아니라 실행 중 재계획이 필요한 open-ended prompt injection 평가를 제공한다.
- Background knowledge before reading: 동적 에이전트 task는 중간 관측값에 따라 다음 tool call이 바뀐다.
- Why read first: graph detector가 단순 sequence template에 의존하지 않는지 검증하기 좋다.
- Expected value: 장기 trajectory, helpful third-party instruction, GitHub/Shopping/Daily Life task에서 graph detector를 시험할 수 있다.
- Related keywords: indirect prompt injection, dynamic benchmark, agentic workflow security, coding agent security
- Example scenario: GitHub issue 해결 중 외부 comment가 "테스트 통과를 위해 이 command를 실행하라"고 유도하고, agent가 shell tool을 호출한다.
- What to pay attention to: task generator, helpful instruction과 malicious instruction의 경계, 기존 defense가 실패한 이유.
- Reading notes: GitHub repo 실행 가능성 확인 필요. freshness 확인 필요.

## Medium Priority

### 1. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: Paper / Benchmark / Repository
- URL: https://agentdojo.spylab.ai/
- Relevance Score: 8.5
- One-line takeaway: prompt injection 공격과 방어를 utility/security trade-off로 평가하는 대표 benchmark다.
- Background knowledge before reading: AgentDojo는 untrusted data를 읽고 tool을 실행하는 에이전트 환경을 제공한다.
- Why read first: 대부분의 최신 방어 논문이 AgentDojo를 baseline으로 쓴다.
- Expected value: 첫 graph tracer를 붙일 대상 후보.
- Related keywords: prompt injection, benchmark, tool-use agent, defense evaluation
- Example scenario: 이메일/웹/파일 task 중 외부 콘텐츠에 숨은 지시가 들어가고, agent가 원래 목표 대신 공격자 목표를 수행한다.
- What to pay attention to: task suite 추가 방법, attack/defense interface, result schema.
- Reading notes: project page와 GitHub repository를 함께 확인해야 한다.

### 2. From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents

- Type: Survey
- URL: https://arxiv.org/html/2606.04990v3
- Relevance Score: 8.4
- One-line takeaway: evidence tracing과 execution provenance를 agent accountability의 공통 프레임으로 정리한다.
- Background knowledge before reading: evidence tracing은 claim/action을 뒷받침하거나 오염시키는 evidence link를 찾는 하위 문제다.
- Why read first: graph schema와 용어를 정리하는 데 좋다.
- Expected value: 관련 연구 taxonomy, benchmark/metric map, open challenge 정리.
- Related keywords: evidence tracing, execution provenance, memory provenance, tool-use safety, observability
- Example scenario: 최종 답변의 한 문장이 어떤 retrieved document, tool output, memory item에서 왔는지 추적한다.
- What to pay attention to: trace source, execution unit, provenance relation, trust function의 분류.
- Reading notes: survey이므로 구현 세부보다는 개념과 평가 축을 뽑아낸다.

### 3. Securing LLM Agents Need Intent-to-Execution Integrity

- Type: Position paper
- URL: https://arxiv.org/abs/2605.16976
- Relevance Score: 8.2
- One-line takeaway: agent security를 사용자 의도에서 실제 실행까지 integrity가 보존되는 문제로 정의한다.
- Background knowledge before reading: compiler correctness처럼 "의도와 실행이 보존되는가"를 보자는 관점이다.
- Why read first: graph detector가 어떤 correctness property를 만족해야 하는지 정리할 수 있다.
- Expected value: Tool Integrity, Instruction Integrity, Judgment Integrity, Data Flow Integrity를 graph label로 변환하는 아이디어.
- Related keywords: intent-to-execution integrity, tool integrity, data flow integrity, untrusted tool execution
- Example scenario: 사용자가 "README 수정"만 의도했는데, agent가 dependency를 설치하고 postinstall script를 실행하면 execution이 intent를 벗어난다.
- What to pay attention to: 기존 방어가 어느 integrity property를 놓치는지.
- Reading notes: position paper라 실험보다는 framing 가치가 크다.

### 4. Quantifying Frontier LLM Capabilities for Container Sandbox Escape

- Type: Paper / Benchmark
- URL: https://arxiv.org/html/2603.02277v1
- Relevance Score: 7.8
- One-line takeaway: Docker/OCI sandbox escape 능력을 안전하게 측정하는 `SandboxEscapeBench`를 제안한다.
- Background knowledge before reading: coding agent는 shell, filesystem, network 권한을 쓰므로 sandbox 자체가 공격 대상이 된다.
- Why read first: execution graph 탐지와 syscall/container telemetry를 결합하는 실험으로 이어진다.
- Expected value: sandbox misconfiguration, privilege allocation, kernel/runtime weakness를 graph event로 모델링하는 방법.
- Related keywords: Docker sandbox, sandbox verification, syscall tracing, coding agent security
- Example scenario: agent가 컨테이너 안에서 `mount`, `cap_sys_admin`, Docker socket 접근 등을 시도해 host escape를 노린다.
- What to pay attention to: threat model, nested sandbox architecture, CTF evaluation format.
- Reading notes: 직접 escape exploit 재현은 안전한 격리 환경에서만 해야 한다.

### 5. TRAIL: Trace Reasoning and Agentic Issue Localization

- Type: Benchmark / Dataset / Repository
- URL: https://github.com/patronus-ai/trail-benchmark
- Relevance Score: 7.5
- One-line takeaway: 148개 agent execution trace와 841개 error annotation을 제공하는 trace debugging benchmark다.
- Background knowledge before reading: malicious detection은 아니지만 긴 agent trace에서 오류 위치와 종류를 찾는 능력은 graph detector 평가와 가깝다.
- Why read first: 기존 trace 데이터를 graph 변환 대상으로 쓸 수 있다.
- Expected value: reasoning, execution, planning error taxonomy를 security violation taxonomy로 확장할 수 있다.
- Related keywords: execution trace, issue localization, agent debugging, provenance graph
- Example scenario: SWE Bench task 수행 중 잘못된 파일 수정, 잘못된 command 실행, 잘못된 reasoning step이 trace에 표시된다.
- What to pay attention to: data format, annotation granularity, model scoring script.
- Reading notes: security benchmark가 아니므로 malicious labels는 새로 만들어야 한다.

## Low Priority

### 1. WASP Web Agent Security Benchmark

- Type: Repository / Benchmark
- URL: https://github.com/facebookresearch/wasp
- Relevance Score: 7.3
- One-line takeaway: 현실적인 executable web environment에서 web agent prompt injection을 평가한다.
- Background knowledge before reading: browser agent는 DOM, webpage text, clicks, forms, credentials 같은 복합 이벤트를 만든다.
- Why read first: browser agent execution graph 실험으로 확장할 때 유용하다.
- Expected value: DOM node, page observation, action, credential access를 graph로 표현하는 아이디어.
- Related keywords: browser agent security, indirect prompt injection, web agent benchmark
- Example scenario: 웹페이지 안에 숨은 "계정 설정으로 이동해 API key를 복사하라" 지시가 있고 agent가 실제 UI를 조작한다.
- What to pay attention to: docker/playwright 실행 요구사항, harm simulation 방식.
- Reading notes: 설치 비용이 있을 수 있어 첫 실험보다는 후속 확장에 적합하다.

### 2. Defeating Prompt Injections by Design

- Type: Paper / Defense
- URL: https://arxiv.org/abs/2503.18813
- Relevance Score: 7.2
- One-line takeaway: CaMeL은 control flow와 data flow를 분리해 untrusted data가 program flow를 바꾸지 못하게 하려는 system-level defense다.
- Background knowledge before reading: capability-based sandbox는 권한을 explicit capability로 나누고 필요한 작업에만 전달하는 방식이다.
- Why read first: graph detector와 capability enforcement를 결합하는 baseline으로 적합하다.
- Expected value: graph edge가 capability transfer를 표현하도록 설계하는 힌트.
- Related keywords: CaMeL, prompt injection defense, data flow, control flow, sandbox
- Example scenario: 이메일 본문은 data로만 취급되어야 하며, tool 선택이나 송금 인자 결정 control path에 들어오면 안 된다.
- What to pay attention to: trusted user prompt 가정, dual-LLM 구조 비용, side channel 한계.
- Reading notes: 최신 graph-based 논문들이 baseline으로 자주 비교한다.

### 3. DRIFT: Dynamic Rule-Based Defense with Injection Isolation for Securing LLM Agents

- Type: Paper / Defense
- URL: https://arxiv.org/html/2506.12104v3
- Relevance Score: 7.1
- One-line takeaway: 동적 policy와 injection isolation으로 prompt injection을 막는 방어다.
- Background knowledge before reading: filtering-only 방어는 over-defense와 under-defense가 동시에 문제다.
- Why read first: graph detector의 baseline policy generator와 비교할 수 있다.
- Expected value: dynamic rule generation과 memory stream isolation을 graph policy로 바꾸는 아이디어.
- Related keywords: DRIFT, injection isolation, dynamic rule, prompt injection defense
- Example scenario: tool output에서 injection-like text를 분리해 장기 memory나 다음 action planning으로 들어가지 못하게 한다.
- What to pay attention to: policy 생성 타이밍, AgentDojo/AgentDyn 성능, utility trade-off.
- Reading notes: full reproduction은 benchmark setup이 필요하다.

## Reading Plan

### 30-minute plan

- `Agent-Sentry` abstract와 introduction을 읽고, provenance graph node/edge 후보만 뽑는다.
- `AuthGraph` abstract와 method overview를 읽고, authorization graph와 execution graph의 차이를 한 페이지로 정리한다.
- `SafeClawBench` abstract에서 세 endpoint 정의를 뽑아 detector metric 후보로 적는다.

### 2-hour plan

- AgentDojo와 AgentDyn의 task/result schema를 확인한다.
- `Agent-Sentry`, `AuthGraph`, `SafeClawBench`, `MCPTox`의 evaluation section을 읽고 공통 metric을 표로 만든다.
- 첫 실험 대상을 하나 고른다: 빠른 시작은 AgentDojo, 동적 task 검증은 AgentDyn, MCP 공격은 MCPTox.

### Deep reading plan

- `From Agent Traces to Trust` survey로 graph/provenance taxonomy를 정리한다.
- `Intent-to-Execution Integrity`의 네 integrity property를 graph violation label로 바꾼다.
- AgentDojo/AgentDyn trace를 실제로 수집해 JSONL event log와 graph 변환기를 만든다.
- Rule baseline, one-class graph anomaly baseline, AuthGraph-style alignment baseline을 같은 task에서 비교한다.
