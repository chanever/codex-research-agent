# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: Paper
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.8
- One-line takeaway: 실행 provenance graph에서 정상 행동 경계와 민감 argument 출처를 학습해 tool call을 차단한다.
- Background knowledge before reading: provenance graph, trusted/untrusted source, tool call sequence, anomaly detection을 알고 읽으면 좋다.
- Why read first: 현재 연구 질문인 "execution/provenance graph가 악성 tool-use 행동을 어떻게 드러내는가"에 가장 직접적으로 답한다.
- Expected value: baseline detector feature, graph schema, 실험 설계 아이디어를 얻을 수 있다.
- Related keywords: execution graph, provenance graph, tool-use security, indirect prompt injection, agentic workflow security
- Example scenario: untrusted email에서 온 계좌번호가 `transfer_money` argument로 흘러 들어갈 때, value tracing이 출처 불일치를 잡는다.
- What to pay attention to: 11개 structural detector, XGBoost feature, false positive/false negative tradeoff, benign trace mining 방식.
- Reading notes: 코딩 에이전트로 확장하려면 tool call뿐 아니라 process, file, network, syscall node가 필요하다.

### 2. From Agent Traces to Trust: Evidence Tracing and Execution Provenance in LLM Agents

- Type: Survey
- URL: https://arxiv.org/html/2606.04990v1
- Relevance Score: 9.2
- One-line takeaway: agent 실행을 감사 가능한 graph로 표현하는 개념, trace source, typed relation을 넓게 정리한다.
- Background knowledge before reading: W3C PROV, OpenTelemetry, RAG faithfulness, agent observability.
- Why read first: 내 graph schema의 용어와 범위를 정리하는 데 필요하다.
- Expected value: `Entity/Activity/Agent`, `SUPPORT/DERIVE/DEPEND-ON/UPDATE` 같은 relation 후보를 얻는다.
- Related keywords: provenance graph, execution graph, evidence tracing, sandbox verification
- Example scenario: `UserGoal -> RetrievedDoc -> Claim -> ToolCall -> FinalAction` 경로에서 어느 evidence가 행동을 정당화했는지 추적한다.
- What to pay attention to: evidence tracing과 execution provenance의 차이, trace source별 failure mode.
- Reading notes: survey이므로 성능 주장은 다른 실험 논문으로 보강해야 한다.

### 3. AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System

- Type: Paper / Repository
- URL: https://arxiv.org/html/2602.03117v1
- Relevance Score: 8.9
- One-line takeaway: 긴 trajectory와 multi-application task로 agent security defense의 deployability를 평가한다.
- Background knowledge before reading: AgentDojo 구조, user task/injection task/tool/environment 구성.
- Why read first: graph detector가 단순 one-step prompt injection이 아닌 실제적인 다단계 workflow에서 작동하는지 확인할 수 있다.
- Expected value: 실험 대상 task, attack vector, trace collection 후보를 얻는다.
- Related keywords: AgentDojo, prompt injection, agentic workflow security, GitHub agent, browser/coding agent security
- Example scenario: GitHub task 중 issue comment에 숨은 지시가 tool sequence를 바꾸는지 관찰한다.
- What to pay attention to: 평균 trajectory length, helpful instruction, dynamic planning이 기존 benchmark와 다른 점.
- Reading notes: GitHub 저장소는 https://github.com/SaFo-Lab/AgentDyn 이며 최신 모델/스크립트 실행성은 freshness 확인 필요.

### 4. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: Paper / Benchmark / Repository
- URL: https://arxiv.org/html/2508.14925v1
- Relevance Score: 8.8
- One-line takeaway: MCP tool description을 supply-chain 공격면으로 보고 실제 MCP server 기반 tool poisoning을 평가한다.
- Background knowledge before reading: MCP, tool description, tool selection, tool call JSON, ASR.
- Why read first: tool poisoning은 graph node에 tool spec provenance를 넣어야 하는 강한 이유를 준다.
- Expected value: `ToolDescription -> ModelPlan -> LegitimateToolCall -> HarmfulSink` 탐지 실험을 설계할 수 있다.
- Related keywords: MCP security, tool poisoning, malicious package detection, software supply chain attack
- Example scenario: 정상 `get_current_time` 요청인데 poisoned description이 먼저 SSH key를 읽게 만든다.
- What to pay attention to: attack template, risk category, 실제 MCP server 수, judge 기준.
- Reading notes: Inspect AI 구현은 https://github.com/stefanoamorelli/inspect-evals-mcptox 이며 공식성/버전은 확인 필요.

### 5. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: Paper / Dataset
- URL: https://arxiv.org/html/2606.18356v1
- Relevance Score: 8.5
- One-line takeaway: text-level failure와 실제 state harm을 분리해 agent security 평가를 더 정밀하게 만든다.
- Background knowledge before reading: sandbox, audit log, state oracle, prompt policy.
- Why read first: 내 탐지기가 어떤 ground truth를 맞춰야 하는지 정하는 데 중요하다.
- Expected value: semantic acceptance, audit evidence, sandbox harm을 분리한 metric 설계.
- Related keywords: sandbox verification, Docker sandbox, memory poisoning, indirect prompt injection
- Example scenario: 에이전트가 거절 문장을 출력해도 실제 파일을 위험하게 바꿨다면 sandbox harm으로 실패 처리한다.
- What to pay attention to: 600 task taxonomy, CoreFail@600, HarmEvidence, state-oracle endpoint.
- Reading notes: dataset과 harness 실행 재현성은 freshness 확인 필요.

## Medium Priority

### 1. Prompt Injection Attack to Tool Selection in LLM Agents / ToolHijacker

- Type: NDSS 2026 Paper
- URL: https://www.ndss-symposium.org/wp-content/uploads/2026-s675-paper.pdf
- Relevance Score: 8.2
- One-line takeaway: 악성 tool document를 최적화해 retrieval과 selection 단계 모두에서 선택을 가로챈다.
- Background knowledge before reading: retriever, top-k tool selection, no-box attack, optimization-based prompt injection.
- Why read first: tool execution 이전의 "선택 단계"도 provenance graph에 넣어야 함을 보여준다.
- Expected value: `ToolDocument -> RetrieverCandidate -> SelectedTool` edge를 설계할 근거.
- Related keywords: tool-use security, tool poisoning, MCP security
- Example scenario: 선물 추천 task에서 `GiftAdvisorPro`라는 악성 tool이 description 최적화로 항상 선택된다.
- What to pay attention to: gradient-free/gradient-based attack, 기존 defense 실패 이유.
- Reading notes: PDF 기반으로 확인했으며 구현 공개 여부는 별도 확인 필요.

### 2. Les Dissonances: Cross-Tool Harvesting and Polluting in Multi-Tool Empowered LLM Agents

- Type: Paper / Tool
- URL: https://arxiv.org/abs/2504.03111
- Relevance Score: 8.0
- One-line takeaway: 악성 tool이 여러 tool 사이의 control flow를 가로채 정보 수집과 오염을 수행할 수 있음을 보인다.
- Background knowledge before reading: multi-tool orchestration, task control flow, LangChain/LlamaIndex tools.
- Why read first: 실행 graph에서 "도구 간 흐름" 자체가 공격면임을 보여준다.
- Expected value: cross-tool edge와 flow hijacking detector 아이디어.
- Related keywords: agentic workflow security, tool-use security, software supply chain attack
- Example scenario: 정상 검색 tool 뒤에 악성 요약 tool이 끼어 들어 confidential data를 흡수하고 다음 tool output을 오염시킨다.
- What to pay attention to: XTHP 정의, Chord dynamic scanner, 취약 tool 비율.
- Reading notes: GitHub Chord 저장소는 https://github.com/river-li/Chord 로 확인됨.

### 3. "Do Not Mention This to the User": Detecting and Understanding Malicious Agent Skills

- Type: Paper / Dataset study
- URL: https://arxiv.org/html/2602.06547v3
- Relevance Score: 7.9
- One-line takeaway: public skill registry에서 악성 agent skill을 대규모로 수집하고 sandbox에서 행동 검증한다.
- Background knowledge before reading: agent skill, registry, sandbox execution, honeypot secret.
- Why read first: malicious package detection과 agent skill supply chain을 연결한다.
- Expected value: 정적 후보 탐지와 동적 sandbox verification 결합 방법.
- Related keywords: malicious package detection, coding agent security, sandbox verification
- Example scenario: 설치된 skill이 hook으로 prompt를 가로채고 환경변수 secret을 외부로 전송한다.
- What to pay attention to: 98,380 skill crawl, 157 malicious skill, Docker sandbox, monitored egress.
- Reading notes: USENIX Security 2026 윤리 기준 언급이 있어 재현 시 안전 절차를 따라야 한다.

### 4. WASP: Benchmarking Web Agent Security Against Prompt Injection Attacks

- Type: Paper / Repository
- URL: https://arxiv.org/abs/2504.18575
- Relevance Score: 7.7
- One-line takeaway: browser/web agent가 현실적인 웹 환경에서 hidden prompt injection에 얼마나 취약한지 end-to-end로 평가한다.
- Background knowledge before reading: WebArena, VisualWebArena, accessibility tree, browser automation.
- Why read first: browser agent security를 graph-based detection으로 확장할 실험장이 된다.
- Expected value: web page node, DOM/accessibility node, click/form-submit sink 설계.
- Related keywords: browser agent security, indirect prompt injection, agentic workflow security
- Example scenario: GitLab/Reddit 페이지에 숨은 지시가 있어 에이전트가 사용자의 원래 목표 대신 공격자 목표를 수행한다.
- What to pay attention to: partial success vs full attacker goal, realistic environment setup.
- Reading notes: GitHub 구현은 https://github.com/facebookresearch/wasp 이며 Docker/Playwright 설정 비용이 크다.

### 5. Prompt injection to RCE in AI agents

- Type: Security blog / technical writeup
- URL: https://blog.trailofbits.com/2025/10/22/prompt-injection-to-rce-in-ai-agents/
- Relevance Score: 7.6
- One-line takeaway: "safe command allowlist"가 argument injection 때문에 RCE로 이어질 수 있음을 실제 패턴으로 설명한다.
- Background knowledge before reading: shell execution, argument injection, command allowlist, `--` separator, sandboxing.
- Why read first: 코딩 에이전트의 실행 graph에는 shell command와 argument-level provenance가 반드시 들어가야 한다.
- Expected value: `go test -exec`, `rg --pre`, `git show --output` 같은 위험 sink 후보.
- Related keywords: coding agent security, syscall tracing, strace, Docker sandbox
- Example scenario: 에이전트가 허용된 `rg` 명령을 실행하지만 `--pre bash` 인자가 붙어 파일 내용이 실행된다.
- What to pay attention to: shell을 꺼도 argument injection은 남는다는 점, facade pattern 한계.
- Reading notes: 제품명은 공개되지 않았으므로 일반화는 조심해야 한다.

## Low Priority

### 1. Agent Security Bench (ASB)

- Type: Paper / Repository
- URL: https://github.com/agiresearch/asb
- Relevance Score: 7.4
- One-line takeaway: 다양한 agent 공격과 방어를 10개 scenario에서 평가하는 넓은 benchmark다.
- Background knowledge before reading: DPI, OPI, memory poisoning, Plan-of-Thought backdoor.
- Why read first: 넓은 taxonomy와 baseline defense를 얻기 좋지만 execution provenance 자체는 중심이 아니다.
- Expected value: 공격군 coverage 확인.
- Related keywords: benchmarks, prompt injection, memory poisoning
- Example scenario: 상담/투자/법률 agent가 악성 observation에 의해 잘못된 action plan을 세운다.
- What to pay attention to: scoring 방식과 내 graph detector가 적용 가능한 로그가 있는지.
- Reading notes: ICLR 2025 official code로 확인됨.

### 2. Agent-SafetyBench

- Type: Benchmark / Repository
- URL: https://github.com/thu-coai/Agent-SafetyBench
- Relevance Score: 7.1
- One-line takeaway: 다양한 agent safety risk category를 포함하는 benchmark다.
- Background knowledge before reading: LLM agent safety, scorer model, environment-based evaluation.
- Why read first: broader safety coverage를 원할 때 유용하다.
- Expected value: graph detector가 security 외 safety failure에도 확장되는지 확인.
- Related keywords: agent safety, benchmark, dataset
- Example scenario: agent가 안전하지 않은 결정을 내리는 여러 환경을 score한다.
- What to pay attention to: data/environment 공개 범위와 scorer model reliability.
- Reading notes: 2025-02-20 data/code release가 확인됨.

### 3. MCP-Bench

- Type: Benchmark / Repository
- URL: https://github.com/Accenture/mcp-bench
- Relevance Score: 7.0
- One-line takeaway: MCP 기반 tool discovery, selection, utilization 능력을 평가하는 benchmark다.
- Background knowledge before reading: MCP server, schema understanding, planning effectiveness.
- Why read first: 보안 benchmark는 아니지만 정상 MCP usage trace를 수집하는 데 쓸 수 있다.
- Expected value: benign trace mining과 utility-preserving defense 평가.
- Related keywords: MCP security, frameworks, tool-use benchmark
- Example scenario: 여러 MCP server에서 적절한 tool을 발견하고 순서대로 호출해 real-world task를 해결한다.
- What to pay attention to: security attack label이 없으므로 악성 injection을 별도로 추가해야 한다.
- Reading notes: NeurIPS 2025 Workshop 수락 표기는 freshness 확인 필요.

## Reading Plan

### 30-minute plan

- Agent-Sentry abstract/introduction/method의 graph feature 부분만 읽고 detector 후보 10개를 적는다.
- MCPTox introduction과 attack paradigm 표를 읽고 `ToolDescription` node가 필요한 이유를 정리한다.
- SafeClawBench introduction을 읽고 평가 라벨을 `semantic`, `audit`, `sandbox` 세 층으로 나눈다.

### 2-hour plan

- Agent-Sentry method와 evaluation을 상세히 읽고, 재현 가능한 feature 목록을 만든다.
- AgentDyn GitHub quickstart와 task 구조를 확인해 trace 추출 위치를 찾는다.
- Trail of Bits RCE writeup에서 command/argument sink 목록을 뽑아 코딩 에이전트 graph schema에 추가한다.

### Deep reading plan

- Agent-Sentry, Evidence Tracing survey, AgentDyn, MCPTox, SafeClawBench를 연결해 하나의 연구 설계 문서로 만든다.
- AgentDyn 또는 MCPTox 하나를 실제로 실행하고 raw log를 property graph로 변환한다.
- 같은 trace에 대해 content scanner, rule-based provenance detector, learned graph detector를 비교하는 파일럿 실험을 설계한다.
