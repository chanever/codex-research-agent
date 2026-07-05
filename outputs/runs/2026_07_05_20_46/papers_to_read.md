# Papers / Repositories to Read

## High Priority

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper
- URL: https://arxiv.org/abs/2603.22868
- Relevance Score: 9.8
- One-line takeaway: 실행 provenance를 직접 runtime defense로 쓰는 핵심 논문이다.
- Background knowledge before reading: AgentDojo/AgentDyn, prompt injection, action trace, provenance graph, false positive/false negative 개념을 알고 읽으면 좋다.
- Why read first: 연구 초점과 가장 정확히 맞다. "그래프가 왜 malicious tool-use를 드러내는가"에 대한 baseline claim을 제공한다.
- Expected value: graph schema, feature engineering, runtime blocking policy, replay evaluation 설계의 출발점.
- Related keywords: execution graph, provenance graph, indirect prompt injection, AgentDojo, AgentDyn, runtime guardrail.
- Example scenario: untrusted email text가 `send_email(to=attacker)`의 recipient 인자를 만들면, 그 흐름이 provenance graph의 suspicious path가 된다.
- What to pay attention to: benign execution bound를 어떻게 학습하는지, LLM judge를 언제 호출하는지, sensitive argument allowlist가 얼마나 일반화되는지.
- Reading notes: 재현 계획을 세울 때 trace format, 5,380 trace dataset 구성, ABR/FPR/FNR/utility metric을 별도 표로 정리하라.

### 2. From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents

- Type: arXiv survey
- URL: https://arxiv.org/abs/2606.04990
- Relevance Score: 9.4
- One-line takeaway: provenance-aware agent 연구의 taxonomy와 open challenges를 정리한다.
- Background knowledge before reading: RAG, tool-use agents, memory, observability, evidence attribution.
- Why read first: 연구의 용어와 범위를 넓히는 데 필요하다. 특히 memory provenance와 tool-use provenance를 한 schema 안에 넣는 데 도움 된다.
- Expected value: 논문 introduction/related work를 쓸 때 쓸 수 있는 구조화된 framing.
- Related keywords: evidence tracing, memory lineage, trust functions, process-level accountability, graph-structured provenance.
- Example scenario: agent가 오래전 memory를 근거로 결제 tool을 호출할 때, memory가 어떤 사용자/웹/도구 결과에서 생겼는지 추적한다.
- What to pay attention to: trace source, evidence unit, provenance relation, representation form, evaluation protocol의 분류.
- Reading notes: "execution graph based detection"에 직접 쓸 수 있는 schema 요소만 추려서 1-page design note로 만들 것.

### 3. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: benchmark paper / GitHub repository
- URL: https://arxiv.org/abs/2406.13352, https://github.com/ethz-spylab/agentdojo
- Relevance Score: 9.0
- One-line takeaway: tool-using agents의 prompt injection 평가를 위한 대표 환경이다.
- Background knowledge before reading: tool-calling, task success vs attack success, external content as untrusted data.
- Why read first: Agent-Sentry와 AgentDyn이 이 환경을 기반으로 하므로 실험 재현의 공통 토대다.
- Expected value: 빠르게 실행 가능한 benchmark harness와 injection task 구조.
- Related keywords: prompt injection, indirect prompt injection, tool-use security, benchmark.
- Example scenario: travel booking tool에서 untrusted hotel listing이 agent의 선택을 공격자 목표로 바꾼다.
- What to pay attention to: task specification, utility criteria, security test case labeling, defense interface.
- Reading notes: 내 detector를 붙이려면 어디서 tool-call trace를 hook할지 repo 구조를 확인해야 한다.

### 4. AgentDyn: Are Your Agent Security Defenses Deployable in Real-World Dynamic Environments?

- Type: benchmark paper / GitHub repository
- URL: https://arxiv.org/abs/2602.03117, https://github.com/leolee99/AgentDyn
- Relevance Score: 8.9
- One-line takeaway: static benchmark보다 더 open-ended하고 동적인 agent security 평가를 제안한다.
- Background knowledge before reading: AgentDojo, prompt-level defense, over-defense, dynamic planning.
- Why read first: execution graph detector가 실제 복잡한 task에서 false positive를 얼마나 내는지 확인하기 좋다.
- Expected value: Shopping/GitHub/Daily Life scenario의 더 현실적인 trace.
- Related keywords: dynamic environment, helpful third-party instructions, prompt injection defense.
- Example scenario: GitHub issue의 외부 지시가 정상 작업 지시처럼 보이지만, 실제로는 파일/secret 접근을 유도한다.
- What to pay attention to: 기존 10개 defense가 실패하는 조건과 "helpful instruction"이 공격과 어떻게 구분 어려운지.
- Reading notes: 정상 trace 다양성이 커질수록 graph anomaly detector의 threshold가 어떻게 흔들리는지 실험 아이디어를 뽑을 것.

### 5. MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents

- Type: arXiv paper / benchmark
- URL: https://arxiv.org/abs/2510.15994
- Relevance Score: 8.8
- One-line takeaway: MCP의 task planning, tool invocation, response handling 전 단계를 공격면으로 보는 end-to-end benchmark다.
- Background knowledge before reading: MCP, tool registry, tool descriptions, tool responses, ASR/PUA/NRP.
- Why read first: MCP metadata와 tool response를 graph node로 넣어야 한다는 근거를 준다.
- Expected value: MCP-specific attack taxonomy 12종과 2,000 attack instances.
- Related keywords: MCP security, tool signature attack, tool parameter attack, tool response attack, retrieval injection.
- Example scenario: tool name collision으로 agent가 유사한 악성 tool을 선택하고, 그 응답이 다음 tool call을 유도한다.
- What to pay attention to: real tools를 실행하는 harness와 NRP metric이 detector 평가에 어떻게 쓰일 수 있는지.
- Reading notes: metadata provenance, server identity, tool signature를 trace schema에 포함할 수 있는지 확인.

## Medium Priority

### 6. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: arXiv paper / benchmark
- URL: https://arxiv.org/abs/2508.14925
- Relevance Score: 8.6
- One-line takeaway: MCP tool metadata poisoning을 대규모로 평가한다.
- Background knowledge before reading: tool poisoning, function hijacking, MCP servers.
- Why read first: "악성 도구 자체는 실행되지 않고 legitimate tool이 악성 행동을 수행"하는 구조가 execution graph 연구에 중요하다.
- Expected value: 45 MCP servers, 353 authentic tools, 1,312 malicious test cases 기반의 tool poisoning threat model.
- Related keywords: MCP security, malicious tool metadata, legitimate tool misuse.
- Example scenario: 시간 조회 tool 설명에 secret file 읽기 지시가 숨어 있고, agent가 별도 file tool을 호출한다.
- What to pay attention to: poisoned metadata와 실제 harmful tool call 사이의 causal link를 어떻게 labeling했는지.
- Reading notes: 데이터 저장소 공개 상태는 freshness 확인 필요.

### 7. MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills

- Type: arXiv paper / benchmark / GitHub repository
- URL: https://arxiv.org/abs/2606.07131, https://github.com/lxyeternal/MalSkillBench
- Relevance Score: 8.7
- One-line takeaway: malicious agent skill을 Docker sandbox와 system-call monitoring으로 검증한 benchmark다.
- Background knowledge before reading: agent skills, SKILL.md, code injection, prompt injection, malicious package datasets.
- Why read first: runtime evidence를 ground truth로 쓰는 점이 syscall tracing 기반 연구와 직접 연결된다.
- Expected value: code+instruction 관계를 탐지하는 hybrid detector 설계.
- Related keywords: malicious skills, Docker sandbox, system-call monitoring, supply chain security.
- Example scenario: SKILL.md의 harmless-looking code block이 `.env` 읽기와 HTTP exfiltration을 수행한다.
- What to pay attention to: Generate-Verify-Feedback pipeline, 108-cell taxonomy, detector baselines.
- Reading notes: strace/Falco 이벤트를 provenance graph에 넣는 최소 변환기를 설계할 것.

### 8. Supply-Chain Poisoning Attacks Against LLM Coding Agent Skill Ecosystems

- Type: arXiv paper
- URL: https://arxiv.org/abs/2604.03081
- Relevance Score: 8.5
- One-line takeaway: coding agent가 skill 문서의 예제를 신뢰해 복사/실행하는 특성을 action-space hijacking으로 연결한다.
- Background knowledge before reading: coding agents, skill marketplace, package install attack, MITRE ATT&CK.
- Why read first: malicious package/skill 공급망 공격을 execution graph detector 실험으로 바꾸기 좋다.
- Expected value: DDIPE threat model과 15 ATT&CK category 기반 payload taxonomy.
- Related keywords: supply-chain poisoning, DDIPE, coding agent security, package install attack.
- Example scenario: Kubernetes YAML 예제가 `privileged: true`와 host root mount를 "best practice"처럼 포함한다.
- What to pay attention to: model-level alignment과 framework-level guardrail의 비대칭 실패.
- Reading notes: 실제 공격 payload는 안전한 toy payload로 축소해 재현해야 한다.

### 9. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: arXiv paper / dataset
- URL: https://arxiv.org/abs/2606.18356
- Relevance Score: 8.3
- One-line takeaway: semantic acceptance, audit-visible harm evidence, sandbox-observed harm을 분리해 측정한다.
- Background knowledge before reading: prompt injection, memory poisoning, sandbox evaluation.
- Why read first: "모델이 동의했는가"와 "실제 harm이 발생했는가"를 구분하는 평가 철학이 중요하다.
- Expected value: detector metric을 final answer 중심에서 runtime harm 중심으로 바꿀 근거.
- Related keywords: sandbox harm, audit evidence, tool-return injection, memory extraction.
- Example scenario: agent 답변은 안전해 보이지만 sandbox 상태에는 unauthorized file write가 남는다.
- What to pay attention to: 600 controlled adversarial tasks와 세 endpoint가 어떻게 라벨링되는지.
- Reading notes: Hugging Face dataset license와 schema는 확인 필요.

### 10. Securing AI Agents with Information-Flow Control

- Type: arXiv paper / Microsoft Research page
- URL: https://arxiv.org/abs/2505.23643, https://www.microsoft.com/en-us/research/publication/securing-ai-agents-with-information-flow-control/
- Relevance Score: 8.1
- One-line takeaway: confidentiality/integrity label과 dynamic taint tracking으로 agent planner의 안전 속성을 강제한다.
- Background knowledge before reading: information-flow control, taint tracking, lattice labels.
- Why read first: provenance graph detector를 policy enforcement로 확장할 이론적 기반이다.
- Expected value: graph labels와 source-to-sink policy 설계.
- Related keywords: IFC, FIDES, taint tracking, integrity labels, confidentiality labels.
- Example scenario: untrusted webpage label이 붙은 데이터가 `send_email` body에는 들어갈 수 있어도 `recipient`나 `payment_amount`에는 들어가지 못하게 한다.
- What to pay attention to: selective hide/reveal primitive와 expressiveness/security trade-off.
- Reading notes: Agent-Sentry와 차이를 정리하라. Agent-Sentry는 trace-bound detection, FIDES는 planner-level deterministic policy에 가깝다.

## Low Priority

### 11. InjecAgent: Benchmarking Indirect Prompt Injections in Tool-Integrated Large Language Model Agents

- Type: ACL paper / benchmark / GitHub repository
- URL: https://arxiv.org/abs/2403.02691, https://github.com/uiuc-kang-lab/InjecAgent
- Relevance Score: 7.8
- One-line takeaway: indirect prompt injection benchmark의 중요한 초기 기준점이다.
- Background knowledge before reading: ReAct, user tools, attacker tools, data exfiltration.
- Why read first: AgentDojo 이전/병렬의 공격 의도 분류와 exfiltration task를 이해하는 데 좋다.
- Expected value: 공격 목표를 direct harm과 private data exfiltration으로 나누는 labeling 참고.
- Related keywords: indirect prompt injection, tool-integrated agents, exfiltration.
- Example scenario: 외부 문서가 calendar/email tool을 이용해 사용자 private data를 공격자에게 보내게 만든다.
- What to pay attention to: 1,054 test cases, 17 user tools, 62 attacker tools 구성.
- Reading notes: 최신 model에는 결과가 달라질 수 있어 freshness 확인 필요.

### 12. CHASE: LLM Agents for Dissecting Malicious PyPI Packages

- Type: arXiv paper / AIWARE 2025 paper
- URL: https://arxiv.org/html/2601.06838v1
- Relevance Score: 7.5
- One-line takeaway: multi-agent malware analysis가 malicious package triage에 유용하다는 사례다.
- Background knowledge before reading: PyPI malware, deobfuscation, deterministic security tools.
- Why read first: malicious package detection을 agent workflow로 수행할 때 hallucination/context confusion을 어떻게 줄이는지 볼 수 있다.
- Expected value: package 분석 report를 provenance graph로 바꾸는 아이디어.
- Related keywords: malicious PyPI, multi-agent system, GuardDog, MalGuard.
- Example scenario: Worker agent가 obfuscated downloader를 해석하고 Supervisor가 "install-time payload + remote fetch" 결론을 낸다.
- What to pay attention to: deterministic tools와 LLM reasoning을 어떻게 결합하는지.
- Reading notes: detection metric이 매우 높게 보고되므로 dataset leakage/selection bias를 검증해야 한다.

### 13. PYPILINE: Malicious PyPI Package Detection via Suspicious API Knowledge and Agent Workflow

- Type: arXiv paper
- URL: https://arxiv.org/html/2606.19063v1
- Relevance Score: 7.3
- One-line takeaway: suspicious API knowledge와 agent workflow를 결합해 PyPI package를 탐지한다.
- Background knowledge before reading: suspicious API, package metadata, vector database, LLM classification.
- Why read first: static suspicious API를 runtime graph feature와 결합하는 실험 baseline이 될 수 있다.
- Expected value: malicious package behavior category와 interpretability 관점.
- Related keywords: malicious PyPI detection, suspicious API, agent workflow.
- Example scenario: package가 `subprocess`, `requests`, credential file read를 조합하면 high-risk behavior sequence로 본다.
- What to pay attention to: 5,000 package dataset과 23,413 package analysis의 ground truth 품질.
- Reading notes: evaluation split과 기존 dataset 출처를 검증해야 한다.

### 14. SafeDep Dynamic Malware Analysis of Open Source Packages at Scale

- Type: technical blog / engineering writeup
- URL: https://safedep.io/dynamic-analysis-oss-package-at-scale/
- Relevance Score: 7.2
- One-line takeaway: untrusted package를 Docker/DIND sandbox에서 실행하고 Falco로 system-call-level event를 수집하는 실무 설계다.
- Background knowledge before reading: Docker, Kubernetes, DIND, Falco, eBPF, sandbox threat model.
- Why read first: 연구 prototype의 runtime monitoring architecture 참고용.
- Expected value: strace 대신 OS-level monitor를 쓰는 이유, event schema, network isolation 설계.
- Related keywords: Docker sandbox, Falco, eBPF, runtime monitoring, malicious package analysis.
- Example scenario: npm package install script가 reverse shell을 시도하면 Falco event로 network/process action을 기록한다.
- What to pay attention to: sandbox escape threat를 어떻게 다루는지와 "관찰하고 싶은 악성 행동"과 "막아야 할 행동"의 구분.
- Reading notes: blog claim이므로 논문보다 낮은 우선순위. 구현 세부는 직접 검증 필요.

### 15. NVIDIA Practical Security Guidance for Sandboxing Agentic Workflows and Managing Execution Risk

- Type: technical blog / security guidance
- URL: https://developer.nvidia.com/blog/practical-security-guidance-for-sandboxing-agentic-workflows-and-managing-execution-risk/
- Relevance Score: 7.1
- One-line takeaway: coding agent의 OS-level sandbox control을 실무 위협모델 관점에서 정리한다.
- Background knowledge before reading: IDE agent, file/network permissions, prompt injection in repos/PRs/MCP responses.
- Why read first: 실험 환경을 안전하게 제한하는 기본 원칙을 제공한다.
- Expected value: network egress, workspace 밖 write/read, config file write, secret injection, lifecycle management controls.
- Related keywords: coding agent sandbox, network egress control, workspace isolation, MCP config risk.
- Example scenario: malicious repo의 `AGENT.md`가 agent에게 shell script를 실행시키려 할 때, network egress와 config write control이 피해를 제한한다.
- What to pay attention to: "manual approval habituation" 문제와 OS-level control 우선순위.
- Reading notes: guidance이므로 실험 결과가 아니라 구현 체크리스트로 사용.

## Reading Plan

### 30-minute plan

- Agent-Sentry abstract, method overview, evaluation metrics를 읽고 핵심 graph features를 적는다.
- From Agent Traces to Trust의 taxonomy 부분만 훑어 schema 후보를 고른다.
- MalSkillBench abstract와 contribution을 읽고 runtime-verified label이 어떻게 만들어지는지 확인한다.

### 2-hour plan

- Agent-Sentry 전체를 읽고 `source`, `argument`, `action`, `sensitive sink`를 내 schema로 변환한다.
- AgentDojo와 AgentDyn repo의 trace/logging 가능 지점을 확인한다.
- MSB/MCPTox attack taxonomy를 읽고 MCP-specific node/edge type을 추가한다.
- MalSkillBench/PoisonedSkills에서 skill 문서, generated code, syscall event를 잇는 toy example을 설계한다.

### Deep reading plan

- 1일차: Agent-Sentry 재현 가능성 조사, trace schema 작성, evaluation metric 확정.
- 2일차: AgentDojo 또는 AgentDyn 실행 환경 구성, benign/attack trace 20개 수집.
- 3일차: MalSkillBench 샘플 20개를 Docker sandbox에서 안전하게 실행하고 strace/Falco event 수집.
- 4일차: rule-based source-to-sink detector, graph anomaly baseline, LLM judge baseline을 비교.
- 5일차: 실패 케이스 분석. benign helpful instruction과 malicious injection이 그래프상 어떻게 구분되지 않는지 정리.
