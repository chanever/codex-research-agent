# Papers / Repositories to Read

## High Priority

### 1. AuthGraph: Decentralized Authorization with Deliberation for LLM Agent Tool Invocation

- Type: arXiv paper
- URL: https://arxiv.org/abs/2605.26497
- Relevance Score: 9.7
- One-line takeaway: tool invocation을 graph-based authorization 문제로 모델링한다.
- Background knowledge before reading: 정적 권한 정책은 agent의 runtime context를 충분히 반영하지 못한다. 같은 tool이라도 출처가 untrusted web content인지, 사용자가 직접 요청한 파일인지에 따라 위험도가 다르다.
- Why read first: execution graph를 탐지 결과가 아니라 실제 allow/deny decision으로 연결하는 가장 직접적인 자료다.
- Expected value: 내 연구의 graph schema, policy language, risk path 정의에 바로 영향을 줄 수 있다.
- Related keywords: tool-use security, provenance graph, agentic workflow security, authorization graph, MCP security
- Example scenario: `read_secrets -> summarize -> send_http` 경로가 생겼을 때, detector가 단순 alert가 아니라 tool call 승인 거부로 이어진다.
- What to pay attention to: graph node/edge 종류, policy evaluation 시점, multi-agent 또는 multi-tool 환경에서의 scalability, user intent를 어떻게 graph에 넣는지.
- Reading notes: abstract 기반 요약. 코드와 evaluation benchmark 공개 여부 확인 필요.

### 2. AgentArmor: Execution Trace Based Defense Against Indirect Prompt Injection Attacks on LLM Agents

- Type: arXiv paper
- URL: https://arxiv.org/abs/2508.01249
- Relevance Score: 9.3
- One-line takeaway: external observation이 tool action에 미친 영향을 trace/dependence graph로 추적한다.
- Background knowledge before reading: indirect prompt injection은 공격 명령이 문서, 웹페이지, repo file, email에 숨겨져 들어오는 공격이다.
- Why read first: 연구 초점인 execution/provenance graph based detection의 핵심 선행 연구다.
- Expected value: source-to-sink rule, dependence edge, trace instrumentation 설계에 직접 도움을 준다.
- Related keywords: indirect prompt injection, program dependence graph, browser agent security, coding agent security
- Example scenario: 웹페이지의 악성 instruction이 browser agent의 `send_email` 호출 argument에 영향을 미쳤는지 추적한다.
- What to pay attention to: LLM reasoning step의 dependency를 어떻게 근사하는지, trace granularity, false positive 원인, AgentDojo 같은 benchmark에서의 평가 방식.
- Reading notes: abstract 기반 요약. full paper에서 exact algorithm과 dataset 확인 필요.

### 3. Agent-Sentry: A Scalable End-to-End Agentic AI Security Framework

- Type: arXiv paper
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.5
- One-line takeaway: agent runtime 전체에 graph-based access control을 배치하는 framework 방향을 제시한다.
- Background knowledge before reading: agent security는 input sanitization만으로 부족하고 planning, memory, tool execution, output 단계가 모두 공격면이다.
- Why read first: 내 detector가 실제 agent framework 어디에 들어가야 하는지 architecture 관점을 준다.
- Expected value: instrumentation boundary, policy enforcement point, deployment overhead를 설계하는 데 유용하다.
- Related keywords: agentic workflow security, access control, tool-use security, prompt injection
- Example scenario: untrusted webpage에서 온 instruction이 internal document access와 external form submission으로 이어질 때 workflow-level로 차단한다.
- What to pay attention to: end-to-end라는 표현이 실제로 어느 단계까지 포함하는지, benchmark task가 얼마나 realistic한지.
- Reading notes: abstract 기반 요약. 구현체 공개 여부와 평가 재현성 확인 필요.

### 4. MindGuard: Tracking, Detecting, and Attributing MCP Tool Poisoning Attacks

- Type: arXiv paper
- URL: https://arxiv.org/abs/2508.19070
- Relevance Score: 9.1
- One-line takeaway: MCP tool poisoning을 decision dependence graph로 추적하고 attribution한다.
- Background knowledge before reading: MCP server/tool description은 agent의 tool choice에 영향을 주는 trusted-looking input이다.
- Why read first: MCP security와 graph attribution을 연결하는 선행 연구로, tool poisoning detection 실험의 기준이 된다.
- Expected value: poisoned tool description, tool choice, downstream action 사이의 edge를 어떻게 설계할지 힌트를 준다.
- Related keywords: MCP security, tool poisoning, decision dependence graph, provenance graph
- Example scenario: 오염된 MCP tool description이 agent에게 credential을 읽도록 유도하고, detector가 그 description node를 원인으로 attribution한다.
- What to pay attention to: poisoned tool의 정의, attribution metric, MCPTox 또는 자체 benchmark 구성.
- Reading notes: abstract 기반 요약. MCPTox primary source는 추가 확인 필요, `freshness 확인 필요`.

### 5. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: paper + GitHub repository
- URL: https://arxiv.org/abs/2406.13352 ; https://github.com/ethz-spylab/agentdojo
- Relevance Score: 8.9
- One-line takeaway: prompt injection 공격/방어를 실제 tool-use task 환경에서 평가하는 대표 benchmark다.
- Background knowledge before reading: benchmark가 있어야 detector의 attack success rate, utility retention, false positive를 비교할 수 있다.
- Why read first: execution graph detector의 첫 실험 환경으로 쓰기 좋다.
- Expected value: task, tool, injected instruction, success metric이 정리되어 있어 trace collector를 붙이기 쉽다.
- Related keywords: prompt injection, indirect prompt injection, tool-use security, benchmark
- Example scenario: user는 정상 업무를 요청했지만 외부 document가 다른 tool을 호출하라고 유도한다. detector는 graph에서 untrusted source가 tool action을 지배하는지 본다.
- What to pay attention to: task domains, attack variants, defense baseline, evaluation scripts.
- Reading notes: paper와 repository 모두 확인 권장. 최신 commit과 package compatibility는 직접 실행으로 검증해야 한다.

## Medium Priority

### 6. AgentDyn: Automated Prompt Injection Dataset Generation for Agent Evaluation

- Type: arXiv paper + GitHub repository
- URL: https://arxiv.org/abs/2602.03117 ; https://github.com/leolee99/AgentDyn
- Relevance Score: 8.6
- One-line takeaway: prompt injection evaluation dataset을 자동 생성해 더 다양한 agent attack trace를 만들 수 있게 한다.
- Background knowledge before reading: 수작업 benchmark는 coverage가 좁을 수 있으므로 graph detector 학습/평가에는 다양한 trace가 필요하다.
- Why read first: detector가 특정 benchmark에 overfit되는지 확인하는 확장 데이터 후보가 된다.
- Expected value: synthetic attack variation, train/test split, robustness evaluation에 유용하다.
- Related keywords: benchmark, dataset generation, indirect prompt injection, agent evaluation
- Example scenario: 같은 `read_and_email` task에 대해 수십 가지 숨은 instruction 변형을 만들고, graph detector가 공통 source-to-sink pattern을 잡는지 본다.
- What to pay attention to: generated attacks의 realism, model leakage, evaluation labels의 신뢰도.
- Reading notes: arXiv와 GitHub 확인. 실제 생성 스크립트 실행 가능 여부 검증 필요.

### 7. MSB: A Comprehensive Benchmark for Evaluating LLM-based Agents across Diverse Security Tasks and Risks

- Type: OpenReview paper + GitHub repository
- URL: https://openreview.net/forum?id=QI2YK6U9cP ; https://github.com/dongsenzhang/MSB
- Relevance Score: 8.7
- One-line takeaway: MCP 기반 security task와 risk를 넓게 다루는 benchmark 후보다.
- Background knowledge before reading: MCP는 agent와 tools를 연결하는 표준화된 인터페이스이므로, graph detector도 MCP event를 표준 노드로 기록할 수 있다.
- Why read first: MCP security benchmark가 필요할 때 가장 먼저 확인할 자료다.
- Expected value: safe/unsafe task 분리, tool misuse, security risk categories를 detector label로 전환할 수 있다.
- Related keywords: MCP security, benchmark, tool poisoning, agent security
- Example scenario: agent가 MCP filesystem tool과 browser tool을 함께 쓰며 민감 파일을 외부로 보내는 task에서, detector가 risk path를 찾는다.
- What to pay attention to: task taxonomy, risk labels, server definitions, reproducibility, license.
- Reading notes: OpenReview/ICLR 2026 submission 상태. 최종 accepted version 여부는 확인 필요.

### 8. Content-Aware Attack Detection for LLM Agents

- Type: arXiv paper
- URL: https://arxiv.org/abs/2605.11053
- Relevance Score: 8.8
- One-line takeaway: tool-call traffic의 내용과 context를 이용해 agent attack을 탐지한다.
- Background knowledge before reading: tool call 이름만으로는 위험을 판단할 수 없고, argument와 provenance가 중요하다.
- Why read first: graph node feature 설계에 도움을 준다.
- Expected value: content feature, session context, traffic-level detector baseline을 얻을 수 있다.
- Related keywords: tool-use security, content-aware detection, prompt injection, traffic analysis
- Example scenario: `send_email`이 정상인지 위험한지는 recipient, attachment origin, 이전 observation이 결정한다.
- What to pay attention to: content feature extraction 방법, privacy implications, real-time overhead.
- Reading notes: abstract 기반 요약. dataset과 code 공개 여부 확인 필요.

### 9. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: arXiv paper + Hugging Face dataset
- URL: https://arxiv.org/abs/2606.18356 ; https://huggingface.co/datasets/sairights/safeclawbench
- Relevance Score: 8.4
- One-line takeaway: tool-using agent의 실패를 semantic acceptance, audit-visible harm, sandbox-observed harm으로 분리해 평가한다.
- Background knowledge before reading: agent가 공격 의도에 텍스트로 동의하는 것과 실제 tool/state harm을 만드는 것은 다른 실패 모드다.
- Why read first: graph detector의 label을 "텍스트상 위험"이 아니라 "감사 로그 또는 sandbox에서 보이는 실제 harm"으로 나누는 데 유용하다.
- Expected value: execution graph detector가 어떤 endpoint를 예측해야 하는지 명확하게 만든다.
- Related keywords: sandbox verification, audit evidence, tool-use security, prompt injection
- Example scenario: 모델은 공격 지시에 노골적으로 동의하지 않았지만, sandbox에서는 database write나 memory poisoning이 실제 발생한다.
- What to pay attention to: 600개 task의 공격 family, 세 endpoint 정의, executable subset, state oracle.
- Reading notes: arXiv와 Hugging Face dataset 확인. 실제 executable fixtures 재현성은 직접 실행으로 검증 필요.

## Low Priority

### 10. MalSkillBench

- Type: repository + benchmark companion
- URL: https://arxiv.org/abs/2606.07131 ; https://github.com/lxyeternal/MalSkillBench
- Relevance Score: 8.2
- One-line takeaway: malicious agent skill을 Docker sandbox, system-call monitoring, LLM judge로 runtime-verified하는 benchmark다.
- Background knowledge before reading: agent skill ecosystem은 package ecosystem과 비슷하게 supply-chain risk가 생긴다.
- Why read first: code-level artifacts가 있으면 graph collector를 붙여 runtime traces를 만들 수 있다.
- Expected value: 3,944 malicious skills, 4,000 benign skills, attack taxonomy, Docker/strace 기반 verification pipeline을 graph detector 실험에 활용할 수 있다.
- Related keywords: malicious package detection, sandbox verification, package install attack
- Example scenario: agent가 marketplace skill을 설치하고 실행했더니 hidden subprocess가 생긴다.
- What to pay attention to: repository maturity, license, benchmark data size, verified malicious behaviors.
- Reading notes: paper/repository 확인. 데이터 전체 다운로드, 라이선스, verifier 실행 비용은 사람이 확인해야 한다.

### 11. Cuckoo: Stealthy and Persistent Attacks Against AI IDEs

- Type: arXiv paper
- URL: https://arxiv.org/abs/2506.01038
- Relevance Score: 7.8
- One-line takeaway: coding agent/AI IDE 환경에서 persistent attack이 어떻게 성립하는지 보는 데 유용하다.
- Background knowledge before reading: coding agent는 repository, extension, terminal, package manager를 다루므로 persistence와 supply-chain 공격면이 크다.
- Why read first: execution graph detector의 coding-agent threat model을 넓혀준다.
- Expected value: package install, IDE state, hidden file modification, command execution 같은 graph edge 후보를 얻을 수 있다.
- Related keywords: coding agent security, software supply chain attack, package install attack
- Example scenario: repository file이 agent에게 extension 설정을 바꾸게 하고, 이후 모든 coding session에서 공격자가 원하는 command가 실행된다.
- What to pay attention to: attack persistence mechanism, realistic user workflow, observable runtime events.
- Reading notes: abstract 기반 요약. 실험 artifact와 disclosure status 확인 필요.

### 12. MCPShield: Content-Aware Attack Detection for LLM Agents

- Type: GitHub repository / system artifact 후보
- URL: https://github.com/invariantlabs-ai/mcpshield
- Relevance Score: 7.5
- One-line takeaway: MCP/tool-call gateway 수준에서 content-aware detection을 구현한 artifact 후보로 보인다.
- Background knowledge before reading: MCP gateway는 agent와 tool server 사이의 traffic을 한 곳에서 관찰할 수 있는 좋은 enforcement point다.
- Why read first: paper idea를 구현체로 확인할 수 있다면 실험 baseline으로 쓰기 좋다.
- Expected value: detector deployment pattern, rule/config format, MCP message capture 방법.
- Related keywords: MCP security, tool-use security, content-aware detection
- Example scenario: MCPShield가 `filesystem.read` 결과가 `network.post`로 흘러가는 세션을 차단한다.
- What to pay attention to: 실제 공개 코드 범위, license, supported MCP servers, policy language.
- Reading notes: `freshness 확인 필요`. repository 상태와 paper 연결을 직접 확인해야 한다.

## Reading Plan

### 30-minute plan

- AgentArmor abstract/introduction/method figure를 읽고, source-to-sink graph schema를 1페이지로 요약한다.
- AgentDojo repository README를 보고 최소 task 하나를 실행할 수 있는지 확인한다.
- MSB README에서 MCP server/task 구조를 확인한다.

### 2-hour plan

- AuthGraph, AgentArmor, MindGuard의 graph 용어를 표로 비교한다: node, edge, trust label, decision point, metric.
- AgentDojo 또는 AgentDyn에서 5개 attack trace를 수집하고, JSONL event schema를 만든다.
- `untrusted_source_to_sensitive_sink` rule baseline을 설계한다.

### Deep reading plan

- AgentArmor와 MindGuard의 attribution 방법을 세부적으로 읽고, LLM reasoning dependency를 어떻게 근사하는지 비교한다.
- AuthGraph와 Agent-Sentry의 enforcement architecture를 비교해, detector가 pre-tool-call인지 post-tool-call인지 결정한다.
- SafeClawBench/MalSkillBench를 실행해 Docker/strace 기반 event를 graph에 합칠 수 있는지 검증한다.
