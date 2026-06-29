# Daily Research Brief

## Research Focus

- Domain: LLM Agent Security
- Focus: execution graph based detection for malicious tool-use agents
- Keywords: prompt injection, indirect prompt injection, tool-use security, MCP security, malicious package detection, sandbox verification, provenance graph, execution graph, tool poisoning, agentic workflow security, coding agent security, browser agent security, software supply chain attack, package install attack, syscall tracing, strace, Docker sandbox
- Search mode: live web search
- Search date: 2026-06-29, Asia/Seoul

## Today's Summary

오늘 확인한 흐름은 세 갈래다. 첫째, ARGUS, AuthGraph, TraceAegis처럼 agent execution trace를 provenance graph 또는 dual graph로 바꾸어 tool-call argument의 출처와 권한 근거를 비교하는 연구가 빠르게 구체화되고 있다. 둘째, SafeClawBench와 AgentSecBench는 "모델이 공격을 받아들였는가"와 "실제 tool/state harm이 발생했는가"를 분리하려는 방향을 제시한다. 셋째, GitInject, MalTool, MCPTox, MCP-ITP는 coding agent, CI/CD agent, MCP tool ecosystem에서 prompt injection과 tool/package supply-chain 공격이 결합되는 실제성 높은 위협을 보여준다.

나의 연구 주제인 "malicious tool-use agents의 execution graph 기반 탐지"에는 ARGUS/AuthGraph/TraceAegis가 가장 직접적이다. 다만 sandbox verification과 syscall/strace 계층까지 내려간 탐지는 아직 LLM-agent 보안 논문에서는 상대적으로 빈 공간으로 보인다. 따라서 다음 실험은 agent-level provenance graph와 OS/container-level event graph를 결합해 semantic acceptance, audit-visible evidence, sandbox-observed harm을 동시에 예측하는 방향이 유망하다.

## Recommended Items Top 5

### 1. ARGUS: Defending LLM Agents Against Context-Aware Prompt Injection

- Type: arXiv paper / benchmark + defense
- Source: arXiv
- URL: https://arxiv.org/abs/2605.03378
- Date: 2026-05-05
- Relevance Score: 9.4
- Why it matters: AgentLure benchmark와 ARGUS defense가 context-dependent task에서 prompt injection을 다루며, Influence-Provenance Graph(IPG)를 핵심 메커니즘으로 사용한다. execution graph/provenance 기반 탐지 연구와 가장 직접적으로 맞닿아 있다.
- Key idea: runtime context entry를 span 단위로 나누고, state-changing tool call의 각 argument가 어떤 benign/adversarial span에서 왔는지 추적한 뒤, user query와 trusted runtime evidence에 대해 action을 감사한다.
- Limitation / uncertainty: 논문 HTML 일부와 abstract 기반으로 요약했다. 코드 저장소가 anonymous.4open.science로 제시되어 있어 장기 접근성, benchmark 재현성, 세부 prompt 및 ablation은 사람이 직접 확인해야 한다.
- Connection to my research: execution graph의 node를 tool observation, memory, retrieved document, skill, inter-agent message로 두고 edge를 argument provenance로 정의하는 설계 참고점이다.
- Possible experiment: AgentDojo 또는 자체 tool-use sandbox에서 tool-call argument별 provenance edge를 기록하고, ARGUS식 local audit 신호와 OS-level file/network event를 결합한 anomaly classifier를 만든다.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / defense
- Source: arXiv
- URL: https://arxiv.org/abs/2605.26497
- Date: 2026-05-26
- Relevance Score: 9.2
- Why it matters: AuthGraph는 실제 실행 trajectory에서 얻은 injected reasoning graph와 clean context에서 도출한 authorization graph를 구조적으로 비교한다. "정상 권한 그래프 vs 실제 실행 그래프"라는 탐지 문제 정의가 명확하다.
- Key idea: indirect prompt injection으로 오염될 수 있는 provenance graph와, 오염될 수 없는 isolated clean authorization graph를 만든 뒤 tool-level 및 parameter-source-level deviation을 찾는다.
- Limitation / uncertainty: abstract 기반 요약이다. clean authorization graph를 현실 agent에서 어떻게 안정적으로 생성하는지, dynamic/open-ended task에서 false positive가 얼마나 나는지 확인 필요.
- Connection to my research: execution graph 기반 malicious tool-use detection에서 "baseline graph"를 어떻게 정의할지에 대한 강한 후보 모델이다.
- Possible experiment: user intent로부터 허용된 file path, network domain, package install action, credential access를 authorization graph로 만들고, 실제 tool/syscall trace graph와 graph edit distance 또는 typed edge violation으로 비교한다.

### 3. TraceAegis: Securing LLM-Based Agents via Hierarchical and Behavioral Anomaly Detection

- Type: arXiv paper / provenance-based anomaly detection
- Source: arXiv
- URL: https://arxiv.org/abs/2510.11203
- Date: 2025-10-13
- Relevance Score: 9.0
- Why it matters: TraceAegis는 agent execution trace를 hierarchical execution unit과 behavioral constraints로 추상화해 abnormal behavior를 탐지한다. prompt injection뿐 아니라 tool poisoning, malicious instruction으로 인한 execution flow compromise를 다룬다.
- Key idea: 정상 agent behavior의 안정적인 실행 단위를 만들고, task completion에 필요한 순서/의미 제약을 규칙화해 trace가 이를 위반하는지 검사한다.
- Limitation / uncertainty: abstract 기반 요약이다. TraceAegis-Bench의 데이터와 코드 공개 상태, healthcare/procurement 외 domain generalization은 확인 필요.
- Connection to my research: execution graph detection에서 graph mining, hierarchical abstraction, sequence semantic consistency를 결합하는 기본 프레임으로 쓸 수 있다.
- Possible experiment: coding agent의 정상 task trace에서 "read issue -> inspect files -> edit -> test -> final" 같은 macro-unit을 학습하고, package install, credential read, hidden network call이 끼어드는지 탐지한다.

### 4. SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents

- Type: arXiv paper / benchmark + dataset
- Source: arXiv, Hugging Face dataset
- URL: https://arxiv.org/abs/2606.18356
- Date: 2026-06-16
- Relevance Score: 8.9
- Why it matters: tool-use agent 보안 평가를 semantic attack acceptance, audit-visible harm evidence, sandbox-observed tool/state harm으로 분리한다. sandbox verification을 연구 목표에 넣을 때 평가 endpoint 설계가 매우 중요하다.
- Key idea: 600 adversarial tasks와 여섯 attack family를 사용해 "말로는 동의했지만 실제 harm은 없는 경우"와 "semantic check는 통과했지만 sandbox harm이 발생한 경우"를 분리한다.
- Limitation / uncertainty: abstract 기반 요약이다. Hugging Face dataset의 세부 schema, sandbox protocol, agent endpoint별 재현 조건은 사람이 직접 검증해야 한다.
- Connection to my research: execution graph 탐지 모델의 label을 단일 ASR로 두지 않고 semantic/audit/sandbox harm 다중 label로 둘 근거를 제공한다.
- Possible experiment: Docker sandbox 안에서 agent task를 실행하고 file write, db mutation, network egress, memory persistence를 harm endpoint로 분리해 graph detector를 평가한다.

### 5. GitInject: Real-World Prompt Injection Attacks in AI-Powered CI/CD Pipelines

- Type: arXiv paper / open-source framework claim
- Source: arXiv
- URL: https://arxiv.org/abs/2606.09935
- Date: 2026-06-07
- Relevance Score: 8.8
- Why it matters: AI coding agents가 PR, issue, CI/CD workflow에서 untrusted repository content를 읽고 elevated permissions로 행동하는 supply-chain threat를 실제 GitHub workflow에서 평가한다.
- Key idea: ephemeral repositories와 실제 workflow run을 만들어 sandbox constraints, credential handling, permission boundaries가 production처럼 동작하는 상태에서 prompt injection 공격을 평가한다.
- Limitation / uncertainty: abstract 기반 요약이다. arXiv에는 open-source framework라고 되어 있으나, 검색 결과에서 repository URL은 확정하지 못했다. 코드 공개 위치와 재현 가능성은 freshness 확인 필요.
- Connection to my research: coding agent security에서 execution graph가 GitHub event, workflow permission, secret access, file diff, tool call을 함께 포함해야 함을 보여준다.
- Possible experiment: GitInject식 ephemeral repo 환경에서 agent action graph와 GitHub Actions audit log를 합쳐 credential exfiltration path를 탐지한다.

## Today's Top 3 Actions

1. ARGUS, AuthGraph, TraceAegis를 읽고 provenance node/edge schema를 비교해 공통 execution graph schema 초안을 만든다.
2. SafeClawBench의 semantic, audit-evidence, sandbox harm endpoint를 참고해 자체 Docker/strace 기반 labeling protocol을 설계한다.
3. GitInject/MalTool/MCPTox에서 공격 템플릿을 추출해 coding-agent + MCP-agent용 malicious tool-use trace corpus를 만든다.

## Human Verification Needed

- ARGUS/AgentLure anonymous repository의 접근 가능성, license, dataset schema, reproducibility script 확인.
- AuthGraph가 clean authorization graph를 생성하는 절차와 evaluation split, baseline implementation 확인.
- TraceAegis-Bench의 실제 공개 여부, data format, 정상/비정상 trace labeling 기준 확인.
- SafeClawBench Hugging Face dataset의 executable sandbox protocol과 harm label 정의 확인.
- GitInject repository URL, CI provider별 실험 조건, secret handling mitigation의 실제 coverage 확인.
- MalTool datasets 수치가 arXiv 버전별로 다르게 표시될 수 있으므로 최신 v3 PDF 기준으로 재확인.
- MCP 보안 글은 vendor/security-lab writeup이므로 독립 재현 또는 CVE/issue tracker corroboration 필요.

## Source List

- ARGUS: Defending LLM Agents Against Context-Aware Prompt Injection, https://arxiv.org/abs/2605.03378
- Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents, https://arxiv.org/abs/2605.26497
- TraceAegis: Securing LLM-Based Agents via Hierarchical and Behavioral Anomaly Detection, https://arxiv.org/abs/2510.11203
- SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents, https://arxiv.org/abs/2606.18356
- SafeClawBench dataset, https://huggingface.co/datasets/sairights/safeclawbench
- GitInject: Real-World Prompt Injection Attacks in AI-Powered CI/CD Pipelines, https://arxiv.org/abs/2606.09935
- AgentSecBench: Measuring Prompt Injection, Privacy Leakage, and Tool-Use Integrity in LLM Agents, https://arxiv.org/abs/2605.26269
- MalTool: Malicious Tool Attacks on LLM Agents, https://arxiv.org/abs/2602.12194
- MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers, https://arxiv.org/abs/2508.14925
- MCP-ITP: An Automated Framework for Implicit Tool Poisoning in MCP, https://arxiv.org/abs/2601.07395
- Defeating Prompt Injections by Design / CaMeL, https://arxiv.org/abs/2503.18813
- AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents, https://arxiv.org/abs/2406.13352
- AgentDojo repository, https://github.com/ethz-spylab/agentdojo
- AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System, https://arxiv.org/abs/2602.03117
- MCP Security Notification: Tool Poisoning Attacks, https://invariantlabs.ai/blog/mcp-security-notification-tool-poisoning-attacks
- Model Context Protocol Specification 2025-06-18, https://modelcontextprotocol.io/specification/2025-06-18
- OWASP Top 10 for Large Language Model Applications, https://owasp.org/www-project-top-10-for-large-language-model-applications/
