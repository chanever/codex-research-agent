# Papers / Repositories to Read

## High Priority

### 1. ARGUS: Defending LLM Agents Against Context-Aware Prompt Injection

- Type: arXiv paper / AgentLure benchmark / provenance-aware defense
- URL: https://arxiv.org/abs/2605.03378
- Relevance Score: 9.4
- Why read first: Influence-Provenance Graph, span-level argument grounding, task-level invariant checking이 연구 초점과 거의 일치한다.
- Expected value: execution graph schema, attack surface taxonomy, argument-level provenance audit 설계에 직접 활용 가능.
- Related keywords: prompt injection, indirect prompt injection, provenance graph, execution graph, tool-use security, malicious tool-use detection
- Reading notes: 논문 HTML 일부 기반 요약. full paper에서 IPG data model, AgentLure attack vectors, white-box adaptive attack, token overhead, failure cases를 우선 확인.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / graph alignment defense
- URL: https://arxiv.org/abs/2605.26497
- Relevance Score: 9.2
- Why read first: injected reasoning graph와 clean authorization graph를 비교하는 방식은 execution graph anomaly detection의 가장 간결한 문제정의다.
- Expected value: graph baseline 생성, graph alignment checker, parameter-source-level deviation metric 설계.
- Related keywords: provenance graph, authorization graph, indirect prompt injection, tool-call parameter provenance, noninterference
- Reading notes: abstract 기반 요약. clean context isolation의 전제, AgentDojo/AgentDyn evaluation protocol, false positive tradeoff를 확인.

### 3. TraceAegis: Securing LLM-Based Agents via Hierarchical and Behavioral Anomaly Detection

- Type: arXiv paper / provenance-based anomaly detection / benchmark
- URL: https://arxiv.org/abs/2510.11203
- Relevance Score: 9.0
- Why read first: execution trace를 hierarchical stable unit과 behavioral constraint로 변환한다는 점이 malicious workflow detection에 적합하다.
- Expected value: 정상 trace abstraction, task-order violation, semantic consistency violation을 graph/sequence feature로 만드는 방법.
- Related keywords: execution trace, provenance-based analysis, behavioral anomaly detection, tool poisoning, malicious instructions
- Reading notes: abstract 기반 요약. TraceAegis-Bench 공개 여부와 healthcare/procurement trace schema를 확인해야 한다.

### 4. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: arXiv paper / benchmark / Hugging Face dataset
- URL: https://arxiv.org/abs/2606.18356
- Relevance Score: 8.9
- Why read first: sandbox-observed harm을 별도 endpoint로 분리해, Docker sandbox verification 기반 연구의 evaluation target을 잡는 데 유용하다.
- Expected value: semantic acceptance와 actual tool/state harm의 label 분리, executable protocol 설계.
- Related keywords: sandbox verification, tool-use security, prompt injection, memory poisoning, audit evidence, sandbox harm
- Reading notes: abstract 기반 요약. dataset URL은 https://huggingface.co/datasets/sairights/safeclawbench 이며, schema와 sandbox replay 방법은 직접 확인.

### 5. GitInject: Real-World Prompt Injection Attacks in AI-Powered CI/CD Pipelines

- Type: arXiv paper / coding-agent security framework claim
- URL: https://arxiv.org/abs/2606.09935
- Relevance Score: 8.8
- Why read first: coding agent가 CI/CD와 repository permission boundary 안에서 동작할 때 prompt injection이 software supply chain attack으로 이어지는 구체 사례를 제공한다.
- Expected value: GitHub workflow action graph, credentials, config-file injection, availability attack, sandbox boundary feature 설계.
- Related keywords: coding agent security, CI/CD, software supply chain attack, prompt injection, credential exfiltration, package install attack
- Reading notes: abstract 기반 요약. repository URL은 검색에서 확정하지 못했으므로 freshness 확인 필요.

## Medium Priority

### 6. AgentSecBench: Measuring Prompt Injection, Privacy Leakage, and Tool-Use Integrity in LLM Agents

- Type: arXiv paper / empirical security framework
- URL: https://arxiv.org/abs/2605.26269
- Relevance Score: 8.4
- Why read first: instruction-integrity, retrieval-confidentiality, capability-integrity를 intent-to-execution noninterference 관점에서 formalize한다.
- Expected value: graph detector의 보안 목표를 "authorized observation/capability projection"으로 정의하는 데 도움.
- Related keywords: noninterference, prompt injection, privacy leakage, capability integrity, provenance projection
- Reading notes: abstract 기반 요약. exact-marker experiments가 semantic security claim이 아니라 observable instantiation임을 유의.

### 7. MalTool: Malicious Tool Attacks on LLM Agents

- Type: arXiv paper / malicious tool generation framework / datasets
- URL: https://arxiv.org/abs/2602.12194
- Relevance Score: 8.3
- Why read first: malicious tool의 metadata뿐 아니라 code implementation 안에 CIA형 악성 행위를 심는 문제를 다룬다.
- Expected value: malicious package/tool dataset 생성, static detector vs execution graph detector 비교 baseline.
- Related keywords: malicious package detection, tool poisoning, software supply chain attack, coding LLM, malicious tool code
- Reading notes: abstract 기반 요약. arXiv v3에서는 standalone malicious tools와 embedded malicious behaviors 수치가 검색 snippet과 다를 수 있으므로 PDF 기준 확인.

### 8. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: arXiv paper / MCP benchmark
- URL: https://arxiv.org/abs/2508.14925
- Relevance Score: 8.2
- Why read first: 45 live MCP servers와 353 tools 기반으로 tool metadata poisoning을 체계화한다.
- Expected value: MCP tool description, tool registry, cross-tool metadata influence를 graph edge로 모델링하는 공격 corpus.
- Related keywords: MCP security, tool poisoning, malicious tool metadata, prompt injection, tool-use agent security
- Reading notes: abstract 기반 요약. dataset이 anonymized repository로 제시되어 있어 접근성과 license 확인 필요.

### 9. MCP-ITP: An Automated Framework for Implicit Tool Poisoning in MCP

- Type: arXiv paper / MCP attack generation framework
- URL: https://arxiv.org/abs/2601.07395
- Relevance Score: 8.1
- Why read first: poisoned tool 자체가 호출되지 않고 legitimate high-privilege tool 호출을 유도하는 implicit poisoning이 execution graph 관점에서 중요하다.
- Expected value: "uninvoked malicious metadata -> invoked benign-looking privileged tool" path 탐지 feature.
- Related keywords: MCP security, implicit tool poisoning, tool metadata, high-privilege tool, attack graph
- Reading notes: abstract 기반 요약. MCPTox 기반 evaluation과 detection LLM 회피 설정을 확인.

### 10. Defeating Prompt Injections by Design / CaMeL

- Type: arXiv paper / defense architecture
- URL: https://arxiv.org/abs/2503.18813
- Relevance Score: 7.9
- Why read first: trusted query에서 control/data flow를 추출하고 untrusted data가 program flow에 영향을 주지 못하게 하는 설계가 provenance enforcement의 기준선이다.
- Expected value: capability model, data-flow isolation, privileged/quarantined execution split 설계.
- Related keywords: prompt injection defense, data flow, control flow, capability, AgentDojo
- Reading notes: abstract 기반 요약. AgentDojo에서 67% task solvability와 security proof의 적용 범위를 확인.

## Low Priority

### 11. AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents

- Type: arXiv paper / GitHub repository / benchmark
- URL: https://arxiv.org/abs/2406.13352
- Relevance Score: 7.8
- Why read first: 현재 다수 후속 연구의 benchmark substrate다.
- Expected value: baseline tasks, attack/defense interface, tool-use environment scaffolding.
- Related keywords: prompt injection benchmark, tool-use agents, dynamic environment, AgentDojo
- Reading notes: repository는 https://github.com/ethz-spylab/agentdojo 에서 확인했다. 최신 commit/API는 freshness 확인 필요.

### 12. AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System

- Type: arXiv paper / benchmark
- URL: https://arxiv.org/abs/2602.03117
- Relevance Score: 7.7
- Why read first: static benchmark의 한계인 dynamic open-ended task와 helpful third-party instruction을 강조한다.
- Expected value: realistic task complexity, open-ended planning, over-defense 측정.
- Related keywords: indirect prompt injection, dynamic benchmark, real-world agent security, AgentDojo limitation
- Reading notes: abstract 기반 요약. GitHub repository URL은 논문 abstract에 https://github.com/leolee99/AgentDyn 으로 제시되나 직접 열람은 하지 못했다.

### 13. MCP Security Notification: Tool Poisoning Attacks

- Type: Security blog post / proof-of-concept writeup
- URL: https://invariantlabs.ai/blog/mcp-security-notification-tool-poisoning-attacks
- Relevance Score: 7.6
- Why read first: MCP tool description poisoning, rug pull, tool shadowing, cross-server exfiltration을 구체적 UI/agent scenario로 설명한다.
- Expected value: MCP trace graph에서 "AI-visible description"과 "user-visible approval"의 mismatch를 feature로 넣는 아이디어.
- Related keywords: MCP security, tool poisoning, tool shadowing, rug pull, cross-server protection
- Reading notes: security vendor blog이므로 독립 재현과 client version 확인 필요. 그래도 threat modeling에는 유용하다.

### 14. Model Context Protocol Specification 2025-06-18

- Type: Official specification
- URL: https://modelcontextprotocol.io/specification/2025-06-18
- Relevance Score: 7.4
- Why read first: MCP의 host/client/server, tools/resources/prompts, consent, authorization, tool safety 원칙을 공식적으로 확인할 수 있다.
- Expected value: MCP execution graph의 canonical entities와 trust boundaries 정의.
- Related keywords: MCP, tools, resources, prompts, authorization, tool safety
- Reading notes: spec은 보안 원칙을 제시하지만 enforcement는 implementor 책임이라고 밝힌다. 실제 client별 구현 차이를 따로 조사해야 한다.

### 15. OWASP Top 10 for Large Language Model Applications

- Type: Security guidance / taxonomy
- URL: https://owasp.org/www-project-top-10-for-large-language-model-applications/
- Relevance Score: 7.1
- Why read first: prompt injection, supply chain vulnerabilities, insecure plugin design, excessive agency를 공통 언어로 정리한다.
- Expected value: 논문 problem statement와 threat taxonomy 정렬.
- Related keywords: prompt injection, supply chain vulnerabilities, insecure plugin design, excessive agency
- Reading notes: practitioner guidance라 실험 방법론은 약하다. 연구 novelty 주장에는 직접 근거로 쓰기보다 background taxonomy로 사용.

## Reading Plan

### 30-minute plan

- ARGUS abstract/introduction과 IPG section을 훑고 node/edge schema만 추출한다.
- AuthGraph abstract와 method figure를 확인해 authorization graph 생성 조건을 적는다.
- SafeClawBench abstract에서 세 endpoint 정의를 뽑아 evaluation label 후보로 정리한다.

### 2-hour plan

- ARGUS, AuthGraph, TraceAegis를 나란히 읽고 다음 표를 만든다: graph node, edge, trust label, action label, violation predicate, benchmark, reported metric, failure mode.
- SafeClawBench와 AgentSecBench를 읽고 "semantic failure vs executable harm vs noninterference violation"의 label ontology를 만든다.
- GitInject와 MalTool에서 coding-agent/supply-chain attack primitive를 추출한다: config injection, credential read, package install, hidden network egress, workflow permission escalation.

### Deep reading plan

- AgentDojo/AgentDyn/AgentLure/TraceAegis-Bench/SafeClawBench 중 재현 가능한 benchmark 하나를 고르고, raw trace format을 분석한다.
- Docker sandbox에서 tool call, file I/O, process exec, network egress를 strace 또는 eBPF 계층으로 수집하는 최소 runner를 설계한다.
- Agent-level provenance graph와 OS-level event graph를 typed heterogeneous graph로 병합하고, benign/malicious edge violation rule set을 먼저 만든 뒤 learned classifier로 확장한다.
