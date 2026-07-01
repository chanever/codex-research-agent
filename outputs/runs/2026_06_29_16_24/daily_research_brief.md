# Daily Research Brief

## Research Focus

- Domain: LLM Agent Security
- Focus: execution graph based detection for malicious tool-use agents
- Question: How can execution/provenance graphs reveal malicious or risky tool-use behavior in agents?
- Method hint: 실험, 벤치마크, 데이터셋, 구현 아이디어로 이어질 수 있는 자료를 우선한다.

## Today's Summary

최근 흐름은 "LLM이 공격 문자열을 알아보게 만들자"보다, 에이전트 실행을 관찰 가능한 그래프/추적으로 바꾸고 그 위에서 정책, 이상 탐지, provenance alignment를 수행하는 방향으로 이동하고 있다. AgentArmor, Agent-Sentry, AuthGraph, TraceAegis는 모두 실행 trace를 구조화해 도구 호출 순서, 인자 출처, 데이터 흐름, 정상 행동 경계에서 벗어난 행동을 탐지하려는 계열이다.

MCP 쪽에서는 MCPTox와 MCP Security Bench (MSB)가 실험 재료로 중요하다. 둘 다 도구 설명, 도구 스키마, 도구 응답, tool invocation pipeline이 공격 표면이 된다는 점을 정량화한다. execution/provenance graph 연구를 하려면 AgentDojo/AgentDyn류의 간접 prompt injection 벤치마크와 MCPTox/MSB류의 MCP tool poisoning 벤치마크를 trace 수집용 harness로 재구성하는 것이 가장 빠른 출발점이다.

## Recommended Items Top 5

### 1. Agent-Sentry: Bounding LLM Agents via Execution Provenance

- Type: arXiv paper / runtime defense
- Source: arXiv
- URL: https://arxiv.org/abs/2603.22868
- Date: 2026-03-24 submitted, 2026-05-08 revised
- Relevance Score: 9.8
- Why it matters: 실행 provenance로 benign execution의 경계를 학습하고, 그 경계를 벗어난 tool call을 차단하는 방식이라 연구 초점과 가장 직접적으로 맞닿아 있다.
- Key idea: action sequence와 함수 인자 provenance를 구조적으로 분류하고, 민감 인자 allowlist와 잔여 케이스용 LLM judge를 계층적으로 붙인다.
- Limitation / uncertainty: 논문 결과는 AgentDojo/AgentDyn 환경 중심이다. 실제 coding agent의 shell, package install, network, filesystem event까지 확장될 때 feature drift와 false positive를 검증해야 한다.
- Connection to my research: "정상 실행 그래프의 structural/provenance pattern"을 학습해 malicious tool-use agent를 탐지하는 기준선으로 쓸 수 있다.
- Possible experiment: 동일한 task를 benign/malicious seed로 여러 번 실행해 tool-call DAG, argument-source edge, syscall/process edge를 수집하고 Agent-Sentry식 out-of-bound detector를 재현한다.

### 2. Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents

- Type: arXiv paper / graph alignment defense
- Source: arXiv
- URL: https://arxiv.org/abs/2605.26497
- Date: 2026-05-26
- Relevance Score: 9.6
- Why it matters: 실제 실행 provenance graph와 clean context에서 만든 authorization graph를 분리해 비교한다. prompt injection에 오염된 실행 그래프 자체를 "신호"로 쓰는 설계가 중요하다.
- Key idea: Injected Reasoning Graph는 실제 trajectory를 기록하고, Authorization Graph는 user intent와 tool catalog만으로 만든다. Graph Alignment Checker가 tool-level deviation과 parameter-source-level deviation을 잡는다.
- Limitation / uncertainty: clean authorization graph 생성이 user intent ambiguity와 dynamic replanning에서 얼마나 안정적인지는 별도 검증이 필요하다.
- Connection to my research: provenance graph를 단순 post-hoc audit이 아니라 authorization baseline과 대조하는 탐지 구조로 바꿀 수 있다.
- Possible experiment: MCP tool poisoning payload가 만든 parameter pollution을 AuthGraph 방식의 source_tools constraint로 탐지할 수 있는지 MCPTox 샘플에 적용한다.

### 3. AgentArmor: Enforcing Program Analysis on Agent Runtime Trace to Defend Against Prompt Injection

- Type: arXiv paper / program-analysis-style runtime defense
- Source: arXiv
- URL: https://arxiv.org/abs/2508.01249
- Date: 2025-08-02 submitted, 2025-11-18 revised
- Relevance Score: 9.3
- Why it matters: agent runtime trace를 CFG/DFG/PDG 같은 program representation으로 추상화하고 type-system style policy checking을 수행한다.
- Key idea: trace graph constructor, property registry, type system을 통해 sensitive data flow, trust boundary, policy violation을 검사한다.
- Limitation / uncertainty: graph construction 단계가 LLM/heuristic에 의존할 경우 attacker-controlled observation이 attribution을 흔들 수 있다. AuthGraph가 지적한 단일 trace graph의 한계를 함께 읽어야 한다.
- Connection to my research: syscall tracing, Docker sandbox event, tool call trace를 하나의 PDG 비슷한 IR로 결합하는 구현 아이디어를 준다.
- Possible experiment: AgentDojo task를 실행하면서 tool call trace와 파일/네트워크 이벤트를 병합한 PDG를 만들고, "untrusted observation -> sensitive sink" 경로 탐지를 구현한다.

### 4. MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers

- Type: arXiv paper / benchmark / dataset
- Source: arXiv, GitHub mirror/implementation
- URL: https://arxiv.org/abs/2508.14925
- Date: 2025-08-19
- Relevance Score: 9.0
- Why it matters: MCP tool metadata 자체가 공격 표면이라는 점을 45개 real-world MCP servers, 353개 tools, 1312개 malicious test cases로 정량화한다.
- Key idea: malicious instruction을 tool description/metadata에 넣어 실제로는 poisoned tool을 호출하지 않고도 legitimate high-privilege tool을 오용하게 만든다.
- Limitation / uncertainty: arXiv 페이지와 공개 저장소의 test-case 수/카테고리 수가 일부 버전 차이를 보일 수 있어 최신 데이터셋 버전은 사람이 확인해야 한다.
- Connection to my research: provenance graph가 tool metadata origin, registration-time trust, later tool invocation 사이의 causal edge를 기록해야 함을 보여준다.
- Possible experiment: MCPTox 케이스를 실행하면서 "poisoned metadata node -> model decision node -> legitimate tool call node" edge를 자동 추출하고 ASR와 graph anomaly score의 상관을 본다.

### 5. MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents

- Type: arXiv paper / benchmark / GitHub repository
- Source: arXiv, GitHub
- URL: https://arxiv.org/abs/2510.15994
- Date: 2025-10-14 submitted, 2026-03-24 revised
- Relevance Score: 8.8
- Why it matters: MCP tool-use pipeline 전체를 task planning, tool invocation, response handling 단계로 나누고 12개 공격 taxonomy와 2000개 attack instances를 제공한다.
- Key idea: benign/malicious real tools를 MCP로 실행해 simulation이 아니라 executable harness에서 attack robustness를 측정한다.
- Limitation / uncertainty: 모델별 결과는 빠르게 낡을 수 있다. 2026년 최신 agent/client 조합에서는 재평가가 필요하다.
- Connection to my research: execution graph detector의 평가셋으로 바로 쓸 수 있고, stage별 graph feature를 설계하기 좋다.
- Possible experiment: MSB의 12개 attack class별로 graph motif를 정의하고, motif 기반 detector와 learned graph classifier를 비교한다.

## Today's Top 3 Actions

1. Agent-Sentry, AuthGraph, AgentArmor를 같은 표로 정리해 trace representation, policy target, benchmark, failure mode를 비교한다.
2. MCPTox 또는 MSB 중 하나를 골라 최소 실행 harness를 만들고 tool-call trace, argument provenance, process/file/network telemetry schema를 먼저 정의한다.
3. "tool metadata poisoning -> legitimate tool misuse"를 provenance graph motif로 표현하고, motif rule baseline을 만든 뒤 learned anomaly detector와 비교한다.

## Human Verification Needed

- MCPTox 공개 데이터셋/공식 GitHub의 최신 test-case 수, risk category 수, AAAI 2026 출판 정보가 arXiv 버전과 일치하는지 확인 필요.
- MSB GitHub repository가 논문과 동일한 2000 attack instances와 405 tools를 포함하는지 clone 후 확인 필요.
- Agent-Sentry, AuthGraph, AgentArmor의 code release 여부와 재현 가능성을 확인 필요.
- AgentDyn/TraceAegis-Bench가 공개 데이터셋인지, 접근 가능한 benchmark harness가 있는지 확인 필요.
- coding agent 환경에서 syscall/eBPF/Falco/Tetragon 이벤트를 어떤 granularity로 저장할지 개인정보/비밀정보 노출 위험 검토 필요.

## Source List

- Agent-Sentry: Bounding LLM Agents via Execution Provenance: https://arxiv.org/abs/2603.22868
- Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents: https://arxiv.org/abs/2605.26497
- AgentArmor: Enforcing Program Analysis on Agent Runtime Trace to Defend Against Prompt Injection: https://arxiv.org/abs/2508.01249
- MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers: https://arxiv.org/abs/2508.14925
- MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents: https://arxiv.org/abs/2510.15994
- TraceAegis: Securing LLM-Based Agents via Hierarchical and Behavioral Anomaly Detection: https://arxiv.org/abs/2510.11203
- From Agent Traces to Trust: A Survey of Evidence Tracing and Execution Provenance in LLM Agents: https://arxiv.org/abs/2606.04990
- AgentDojo GitHub: https://github.com/ethz-spylab/agentdojo
- AgentDyn GitHub: https://github.com/leolee99/AgentDyn
- MCPTox GitHub: https://github.com/zhiqiangwang4/MCPTox-Benchmark
- MSB GitHub: https://github.com/dongsenzhang/MSB
- AgentProvenance GitHub: https://github.com/ByteYellow/AgentProvenance
- Trail of Bits mcp-context-protector: https://github.com/trailofbits/mcp-context-protector
- Invariant Labs MCP Tool Poisoning Experiments: https://github.com/invariantlabs-ai/mcp-injection-experiments
- Trail of Bits, "Jumping the line: How MCP servers can attack you before you ever use them": https://blog.trailofbits.com/2025/04/21/jumping-the-line-how-mcp-servers-can-attack-you-before-you-ever-use-them/
- CyberArk, "Poison everywhere: No output from your MCP server is safe": https://www.cyberark.com/resources/threat-research-blog/poison-everywhere-no-output-from-your-mcp-server-is-safe
