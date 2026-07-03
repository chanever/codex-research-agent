# Research Ideas

## Idea 1. Dual Provenance Graph Detector for Indirect Prompt Injection

### Easy Explanation

- One-line summary: agent가 실제로 한 일의 그래프와 사용자가 허용한 일의 그래프를 비교해, 외부 문서나 웹페이지가 도구 인자를 오염시켰는지 찾습니다.
- Intuition: "보내기" 도구 자체는 정상이어도, 누구에게 무엇을 보내는지가 외부 공격 문서에서 왔다면 위험합니다.
- Example scenario: 사용자가 "Bob에게 회의록을 보내줘"라고 했는데, 읽은 웹페이지가 `attacker@example.com`을 끼워 넣어 `send_email.to`가 바뀝니다.

### Six Ws and H

- Who: tool-use LLM agent를 운영하는 개발자와 보안 분석가.
- What: actual execution provenance graph와 user-intent authorization graph의 mismatch를 탐지.
- When: agent가 privileged tool call을 실행하기 직전.
- Where: email, browser, coding, GitHub, shopping, MCP agent workflow.
- Why: indirect prompt injection은 텍스트만 보면 정상 업무 흐름처럼 보일 수 있기 때문입니다.
- How: clean user request에서 허용 graph를 만들고, 실제 trace graph의 tool name, argument value, argument source, trust boundary를 비교합니다.

### Research Framing

- Hypothesis: tool-call-level checking보다 parameter-source-level graph alignment가 indirect prompt injection의 false negative를 줄이면서 utility를 보존할 수 있다.
- Motivation: 공격은 흔히 허용된 tool을 악용합니다. 따라서 "이 tool이 허용됐는가"보다 "이 argument가 허용된 source에서 왔는가"가 중요합니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: Agent-Sentry: Bounding LLM Agents via Execution Provenance
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: 정상 행동 범위를 학습하는 방식은 새로운 legitimate workflow를 공격으로 오탐할 수 있고, 사용자별 authorization intent를 직접 표현하지 않을 수 있습니다.
  - Problem 2:
    - Source: Defeating Prompt Injections by Design
    - URL: https://arxiv.org/abs/2503.18813
    - Why it is not enough: system-level isolation은 강하지만 agent framework나 policy design 변경 부담이 큽니다. 이미 존재하는 agent trace를 사후/직전 검사하는 detector와 비교가 필요합니다.
- Proposed contribution: clean authorization graph와 actual provenance graph를 비교하는 lightweight detector를 설계하고, AgentDojo/AgentDyn에서 utility-security trade-off를 평가합니다.
- Why this could be novel: 기존 provenance defense를 재현하는 수준을 넘어, "authorization graph 생성 오류", "helpful third-party instruction", "동적 open-ended task"에서의 failure mode를 체계적으로 분석할 수 있습니다.

### Methodology

- Required data: AgentDojo, AgentDyn traces; user request; tool specs; tool outputs; final tool calls; attack labels.
- System design: agent runner 앞단에 trace collector를 두고, privileged tool call 직전에 graph checker가 call을 승인/차단합니다.
- Implementation steps:
  - AgentDojo 또는 AgentDyn runner에서 prompt, retrieved content, tool output, tool call arguments를 JSONL로 저장합니다.
  - user request만 입력한 clean planner로 authorization graph를 생성합니다.
  - actual trace에서 source-to-argument edge를 추출합니다.
  - graph alignment rule을 적용해 unauthorized source가 privileged sink에 도달하면 block합니다.
  - LLM judge 없이 benchmark label과 tool execution outcome으로 평가합니다.
- Graph schema:
  - Nodes: `UserInstruction`, `UntrustedContent`, `ToolSpec`, `ToolCall`, `ToolArgument`, `ToolOutput`, `MemoryItem`, `ExternalSink`.
  - Edges: `authorizes`, `read`, `contains`, `influences`, `calls`, `used_as_argument`, `writes`, `sends`.
  - Labels: `trusted`, `untrusted`, `privileged`, `sensitive`, `allowed`, `blocked`, `attack_success`.
- Detector / algorithm: graph alignment plus taint rule. If an untrusted node reaches a privileged argument not authorized by the clean graph, flag it.
- Baselines to compare: no defense, prompt-only defense, tool allowlist, CaMeL, Agent-Sentry-style behavioral bound, LLM-as-judge detector.

### Experiments

- Benchmark / dataset candidates: AgentDojo, AgentDyn, InjecAgent, SafeClawBench.
- Experimental setup: 동일 model과 tool set에서 benign tasks와 attack tasks를 실행하고 detector를 on/off합니다.
- Metrics: ASR, task success rate, false positive rate, blocked harmful tool calls, parameter-source mismatch precision/recall.
- Baseline comparisons: Agent-Sentry, CaMeL, prompt sandwich, tool filter, LLM classifier.
- Ablation study: clean graph 없이 taint만 사용, taint 없이 tool-name check만 사용, source trust label 제거, memory node 제거.
- Expected result: tool-name-only baseline보다 exfiltration과 recipient manipulation 공격에서 ASR을 낮추고, over-blocking은 authorization graph 품질에 좌우될 것입니다.
- Failure cases to check: user가 실제로 외부 문서의 값을 사용하라고 허용한 경우, clean planner가 user intent를 잘못 해석한 경우, argument가 paraphrase되어 source matching이 어려운 경우.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: graph extraction과 source attribution이 모델 출력 형식에 민감합니다.
- First experiment: AgentDojo email/workspace suite에서 `send_email` argument source를 추적하는 rule detector를 만듭니다.
- Next implementation step: OpenTelemetry span 또는 framework trace를 JSON graph로 변환하는 adapter를 작성합니다.

## Idea 2. Agent Trace + Syscall Graph for Runtime-Verified Malicious Tool Use

### Easy Explanation

- One-line summary: agent가 "무슨 tool을 불렀는지"와 sandbox 안에서 실제 프로세스가 "무슨 파일을 읽고 어디로 연결했는지"를 하나의 그래프로 합칩니다.
- Intuition: agent 로그에는 정상 `pip install`처럼 보여도, syscall 로그에는 `~/.env` 읽기와 외부 전송이 남을 수 있습니다.
- Example scenario: coding agent가 dependency를 설치했는데 malicious package의 postinstall script가 SSH key를 읽고 네트워크로 보냅니다.

### Six Ws and H

- Who: coding agent, package installer, malicious package author, security evaluator.
- What: agent-level trace와 OS-level trace를 결합한 temporal provenance graph.
- When: package install, test execution, code generation 후 command execution 단계.
- Where: Docker sandbox, CI runner, local coding agent workspace.
- Why: prompt/tool log만으로는 실제 side effect를 충분히 검증할 수 없습니다.
- How: Docker sandbox에서 strace, inotifywait, network log를 수집하고 agent trace의 command/tool call span과 시간 기준으로 정렬합니다.

### Research Framing

- Hypothesis: agent trace와 syscall trace를 결합하면 static malicious-package scanner보다 agent-triggered supply-chain attack을 더 정확히 탐지할 수 있다.
- Motivation: agent는 사용자의 개발 권한으로 package install과 command execution을 자동 수행하므로 software supply chain risk가 agent workflow 안으로 들어옵니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills
    - URL: https://arxiv.org/html/2606.07131v1
    - Why it is not enough: malicious skill benchmark는 runtime verification을 제공하지만, agent intent/tool-call provenance와 OS event graph를 결합한 detector 연구는 별도로 설계할 수 있습니다.
  - Problem 2:
    - Source: FuseChain: Runtime Evidence Reconstruction for Software Supply-Chain Attacks
    - URL: https://arxiv.org/html/2606.15811v1
    - Why it is not enough: software supply-chain telemetry graph는 강하지만 LLM agent의 prompt, tool decision, MCP metadata 같은 agent-native evidence를 중심에 두지는 않습니다.
- Proposed contribution: coding agent execution을 `agent decision -> shell command -> process tree -> file/network event` temporal graph로 만들고 malicious package install attack을 탐지합니다.
- Why this could be novel: LLM agent provenance와 traditional runtime provenance를 연결해 "agent가 유발한 supply-chain attack"이라는 세부 문제를 정의합니다.

### Methodology

- Required data: MalSkillBench, malicious npm/PyPI samples, benign package installs, agent command traces.
- System design: sandbox runner가 agent를 실행하고, trace collector가 agent spans와 strace/inotify/network events를 같은 run id로 저장합니다.
- Implementation steps:
  - Docker image에 strace, inotifywait, tcpdump 또는 eBPF 대체 도구를 설치합니다.
  - agent command execution마다 timestamped span id를 부여합니다.
  - child process tree와 file/network events를 span id에 매핑합니다.
  - sensitive path read와 unexpected outbound connection motif를 추출합니다.
  - malicious/benign classifier 또는 anomaly detector를 학습합니다.
- Graph schema:
  - Nodes: `AgentStep`, `ToolCall`, `ShellCommand`, `Process`, `File`, `Socket`, `Package`, `Script`.
  - Edges: `executes`, `spawns`, `opens`, `reads`, `writes`, `connects`, `downloads`, `installed_by`.
  - Labels: `benign`, `malicious`, `sensitive_path`, `external_domain`, `postinstall`, `test_command`.
- Detector / algorithm: rule-based suspicious motif detector plus temporal graph neural network baseline. 초기에는 `postinstall -> sensitive_read -> external_connect` motif를 사용합니다.
- Baselines to compare: static package scanner, semgrep/rule scanner, LLM code review, syscall-only detector, agent-trace-only detector.

### Experiments

- Benchmark / dataset candidates: MalSkillBench, FuseChain/SynthChain artifact freshness 확인 필요, malicious PyPI/npm datasets, SafeClawBench executable sandbox panel.
- Experimental setup: benign package install tasks와 malicious package install tasks를 coding agent에게 수행시켜 traces를 수집합니다.
- Metrics: detection precision/recall, time-to-detection, harmful syscall recall, false positives on benign build scripts, graph explanation length.
- Baseline comparisons: OS-only telemetry vs agent+OS telemetry, static scanner vs runtime graph detector.
- Ablation study: network edge 제거, file edge 제거, agent step edge 제거, time window size 변경.
- Expected result: agent+OS graph가 syscall-only보다 "왜 이 command가 실행됐는지"를 더 잘 설명하고, static scanner보다 obfuscated runtime behavior를 더 잘 잡을 가능성이 있습니다.
- Failure cases to check: 정상 build script가 많은 파일을 읽거나 외부 다운로드를 수행하는 경우, network가 proxy를 통해 집계되어 domain attribution이 어려운 경우.

### Practical Plan

- Expected difficulty: Medium to Hard.
- Risk / limitation: Docker 내부 syscall 수집은 OS/kernel 설정에 따라 달라지고, trace volume이 큽니다.
- First experiment: 단일 malicious Python package와 benign package 10개로 strace graph motif detector를 만듭니다.
- Next implementation step: `strace -f -tt -e trace=file,process,network` 로그를 graph JSON으로 변환합니다.

## Idea 3. MCP Tool Metadata Provenance and Drift Detection

### Easy Explanation

- One-line summary: MCP tool의 설명, schema, 이름이 언제 누구에 의해 바뀌었는지 추적하고, 변경된 metadata가 tool 선택과 인자 생성에 미친 영향을 탐지합니다.
- Intuition: tool 자체는 같은 이름이어도 description이 바뀌면 모델이 완전히 다른 행동을 할 수 있습니다.
- Example scenario: 어제는 정상 `summarize_pdf` tool이었지만 오늘 description에 "먼저 private repo를 읽어라"는 숨은 지시가 들어갑니다.

### Six Ws and H

- Who: MCP client, MCP server provider, agent operator, malicious server maintainer.
- What: tool metadata version provenance와 agent execution graph의 연결.
- When: MCP server discovery, tool schema refresh, tool selection, tool invocation 전.
- Where: Cursor-like coding agents, browser agents, enterprise MCP gateways.
- Why: MCP tool poisoning은 실행 전 metadata 단계에서 이미 agent decision을 오염시킵니다.
- How: tool metadata를 versioned artifact로 pinning하고, metadata diff와 downstream tool-call changes를 graph로 연결합니다.

### Research Framing

- Hypothesis: MCP tool metadata drift와 downstream execution change를 함께 보면 tool poisoning을 단순 schema validation보다 더 잘 탐지할 수 있다.
- Motivation: tool descriptions are instructions to models. 사용자가 보지 못하는 metadata 변화가 권한 있는 행동을 유도할 수 있습니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers
    - URL: https://arxiv.org/abs/2508.14925
    - Why it is not enough: benchmark는 tool poisoning 취약성을 측정하지만, 운영 환경에서 metadata version drift를 지속적으로 감시하는 detector는 별도 문제입니다.
  - Problem 2:
    - Source: OWASP MCP03:2025 Tool Poisoning
    - URL: https://owasp.org/www-project-mcp-top-10/2025/MCP03-2025%E2%80%93Tool-Poisoning
    - Why it is not enough: guidance는 공격 유형과 대응을 설명하지만, graph 기반 drift-to-harm attribution 실험 설계는 제공하지 않습니다.
- Proposed contribution: MCP metadata provenance graph를 정의하고, metadata change가 tool selection, argument source, harmful sink에 연결될 때 risk score를 계산합니다.
- Why this could be novel: tool poisoning을 "prompt text classification"이 아니라 "metadata supply-chain provenance" 문제로 다룹니다.

### Methodology

- Required data: MCPTox, MSB, Invariant Labs MCP injection examples, MCP server snapshots.
- System design: MCP gateway가 tool list/schema/description을 매번 hash하고, 변화가 생기면 approval 또는 shadow evaluation을 수행합니다.
- Implementation steps:
  - MCP tool metadata를 normalized JSON으로 저장하고 hash를 계산합니다.
  - description/schema diff에서 hidden instruction, new parameter, changed permission semantics를 추출합니다.
  - 같은 user task를 old metadata와 new metadata로 replay해 tool selection divergence를 측정합니다.
  - divergence가 privileged sink와 연결되면 alert를 냅니다.
- Graph schema:
  - Nodes: `MCPServer`, `ToolVersion`, `ToolDescription`, `ToolSchema`, `Parameter`, `AgentDecision`, `ToolCall`, `ExternalSink`.
  - Edges: `served_by`, `supersedes`, `contains_instruction`, `selected_due_to`, `adds_parameter`, `calls`, `sends_to`.
  - Labels: `trusted_server`, `new_version`, `hidden_instruction`, `privileged_sink`, `approved`, `unapproved`.
- Detector / algorithm: metadata diff classifier plus replay-based behavioral divergence score plus provenance path risk.
- Baselines to compare: manual approval, static allowlist, schema-only validation, LLM prompt-injection classifier over description.

### Experiments

- Benchmark / dataset candidates: MCPTox, MSB, OWASP MCP injection examples, Invariant Labs examples.
- Experimental setup: poisoned and benign tool metadata pairs를 만들고, 동일 user tasks에서 tool selection과 argument changes를 측정합니다.
- Metrics: poisoning detection recall, benign metadata update false positive, behavioral divergence, harmful sink prevention rate.
- Baseline comparisons: classifier-only vs graph drift detector vs pinned metadata.
- Ablation study: hash pinning만 사용, diff semantics 제거, replay 제거, downstream provenance edge 제거.
- Expected result: 단순 description classifier보다, metadata change와 actual execution change를 결합한 detector가 benign wording update와 malicious instruction을 더 잘 구분할 수 있습니다.
- Failure cases to check: 정상 기능 추가가 tool selection을 크게 바꾸는 경우, 공격자가 metadata를 거의 바꾸지 않고 response poisoning만 쓰는 경우.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: MCP ecosystem tool metadata format이 다양하고, replay cost가 큽니다.
- First experiment: MCPTox sample 50개로 old/new metadata graph를 만들고 hidden instruction path를 rule로 탐지합니다.
- Next implementation step: MCP server discovery output을 canonical JSON으로 저장하는 recorder를 작성합니다.

## Idea 4. Multi-Endpoint Evaluation for Graph-Based Agent Security Detectors

### Easy Explanation

- One-line summary: detector가 "공격 문장을 거절했는지"뿐 아니라 "감사 로그에서 피해 증거가 있는지", "sandbox 상태가 실제로 바뀌었는지"를 따로 평가합니다.
- Intuition: 말로는 안전해 보여도 파일을 바꿨다면 실패이고, 말로는 위험해 보여도 실행 피해가 없다면 다른 종류의 실패입니다.
- Example scenario: agent가 "요청을 처리했습니다"라고 말하지만, 실제로는 DB에 공격자 계정을 추가했습니다.

### Six Ws and H

- Who: benchmark 설계자, detector 개발자, agent platform operator.
- What: graph detector 평가를 semantic, audit-evidence, sandbox-harm endpoint로 분리.
- When: detector 논문/프로토타입 평가 단계.
- Where: SafeClawBench, AgentDojo, AgentDyn, custom Docker sandbox.
- Why: ASR 하나만 쓰면 detector가 무엇을 막았는지 알 수 없습니다.
- How: 각 run에 대해 final text, audit graph, sandbox state graph를 별도 label로 저장하고 metric을 분리합니다.

### Research Framing

- Hypothesis: graph-based detector는 semantic attack acceptance보다 audit-evidence harm과 sandbox-observed harm에서 더 큰 강점을 보일 것이다.
- Motivation: execution graph의 장점은 실제 행동과 데이터 흐름을 보는데 있습니다. 텍스트 judge metric만 쓰면 장점이 드러나지 않습니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents
    - URL: https://arxiv.org/html/2606.18356v1
    - Why it is not enough: endpoint separation을 제공하지만, graph detector가 각 endpoint에서 어떤 failure mode를 보이는지 별도 연구가 필요합니다.
  - Problem 2:
    - Source: AgentDyn: A Dynamic Open-Ended Benchmark for Evaluating Prompt Injection Attacks of Real-World Agent Security System
    - URL: https://arxiv.org/html/2602.03117v2
    - Why it is not enough: dynamic open-ended task는 현실적이지만 sandbox-observed harm과 graph evidence endpoint를 모두 분리하지는 않을 수 있습니다.
- Proposed contribution: graph detector evaluation protocol을 제시하고, endpoint별 성능과 failure case를 보고합니다.
- Why this could be novel: "graph detector가 ASR을 낮춘다"보다 "어떤 harm layer를 실제로 잡는가"를 명확히 보여줍니다.

### Methodology

- Required data: SafeClawBench, AgentDyn, AgentDojo, optional custom sandbox tasks.
- System design: 동일 run을 세 계층으로 기록합니다: final response, audit graph, sandbox state graph.
- Implementation steps:
  - benchmark run에서 final answer와 tool trace를 저장합니다.
  - tool trace를 audit evidence graph로 변환합니다.
  - sandbox state diff를 state graph로 변환합니다.
  - detector output과 endpoint labels를 cross-tab으로 분석합니다.
- Graph schema:
  - Nodes: `FinalText`, `Claim`, `ToolCall`, `Evidence`, `StateObject`, `Memory`, `DatabaseRow`, `File`.
  - Edges: `supports`, `contradicts`, `writes`, `deletes`, `discloses`, `persists`.
  - Labels: `semantic_fail`, `harm_evidence`, `sandbox_harm`, `benign_utility`.
- Detector / algorithm: endpoint-aware evaluation harness, detector는 Idea 1/2/3의 graph checker를 plug-in합니다.
- Baselines to compare: LLM judge, keyword refusal detector, tool-call allowlist, no defense.

### Experiments

- Benchmark / dataset candidates: SafeClawBench, AgentDyn, AgentDojo, ToolEmu.
- Experimental setup: 동일 tasks에서 detector를 켜고 끄며 세 endpoint를 각각 측정합니다.
- Metrics: CoreFail, HarmEvidence, SandboxHarm, task utility, endpoint disagreement rate, explanation fidelity.
- Baseline comparisons: text-only detector vs audit graph detector vs sandbox graph detector.
- Ablation study: final text만 평가, audit graph만 평가, sandbox state만 평가, 세 endpoint 결합.
- Expected result: graph detector는 semantic-only failures에는 약할 수 있지만 audit/sandbox harm에는 더 직접적으로 강할 것입니다.
- Failure cases to check: sandbox oracle이 피해를 놓치는 경우, audit evidence가 너무 coarse해서 harmful edge를 만들지 못하는 경우.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: benchmark마다 harm definition이 달라 통합 metric 설계가 어렵습니다.
- First experiment: SafeClawBench의 600-case Semantic Core 중 일부를 graph endpoint로 재표현합니다.
- Next implementation step: endpoint별 confusion matrix report template을 만듭니다.

## Idea 5. Provenance Motif Mining for Agentic Workflow Security

### Easy Explanation

- One-line summary: 여러 공격 benchmark에서 반복되는 위험한 그래프 모양, 즉 motif를 찾아 detector rule과 benchmark taxonomy로 만듭니다.
- Intuition: 공격 문구는 달라도 `untrusted input -> sensitive data read -> external send` 같은 구조는 반복됩니다.
- Example scenario: browser agent, email agent, coding agent에서 모두 "외부 내용이 비밀 데이터 전송을 유도"하는 공통 motif가 발견됩니다.

### Six Ws and H

- Who: agent security researcher, benchmark maintainer, SOC analyst.
- What: malicious tool-use graph motif library.
- When: benchmark analysis, detector rule authoring, incident triage.
- Where: AgentDojo, InjecAgent, MSB, MCPTox, SafeClawBench, MalSkillBench.
- Why: benchmark마다 attack label이 달라 비교가 어렵기 때문에 구조적 공통 언어가 필요합니다.
- How: benchmark traces를 통일 graph schema로 변환하고 frequent malicious subgraph와 benign subgraph 차이를 mining합니다.

### Research Framing

- Hypothesis: attack family 이름보다 provenance motif가 detector generalization을 더 잘 설명한다.
- Motivation: "prompt injection", "tool poisoning", "package install attack"은 표면은 다르지만 위험한 source-to-sink path는 유사할 수 있습니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MCP Security Bench (MSB)
    - URL: https://arxiv.org/html/2510.15994v2
    - Why it is not enough: MCP-specific taxonomy는 풍부하지만 다른 benchmark와 공통 비교 가능한 graph motif taxonomy가 필요합니다.
  - Problem 2:
    - Source: InjecAgent: Benchmarking Indirect Prompt Injections in Tool-Integrated Large Language Model Agents
    - URL: https://arxiv.org/abs/2403.02691
    - Why it is not enough: attack intention categories는 useful하지만 execution-level motif와 runtime harm을 충분히 표현하지 못합니다.
- Proposed contribution: agent security benchmark들을 하나의 provenance motif vocabulary로 재라벨링하고, motif별 detector 성능을 보고합니다.
- Why this could be novel: benchmark 간 generalization을 attack names가 아니라 graph structures 기준으로 비교합니다.

### Methodology

- Required data: AgentDojo, InjecAgent, AgentDyn, MSB, MCPTox, SafeClawBench, MalSkillBench.
- System design: 각 benchmark adapter가 native trace를 common graph format으로 변환하고, motif miner가 malicious-only frequent subgraphs를 찾습니다.
- Implementation steps:
  - common graph schema를 정의합니다.
  - benchmark별 trace adapter를 작성합니다.
  - malicious runs와 benign runs의 frequent subgraph 차이를 계산합니다.
  - 사람이 해석 가능한 motif 이름을 붙입니다.
  - motif별 detector rule과 benchmark coverage table을 만듭니다.
- Graph schema:
  - Nodes: `TrustedUser`, `UntrustedSource`, `ToolMetadata`, `ToolCall`, `Argument`, `SensitiveObject`, `ExternalSink`, `Process`, `Memory`.
  - Edges: `authorizes`, `injects`, `selects`, `flows_to`, `reads`, `writes`, `exfiltrates`, `persists`.
  - Labels: `attack_family`, `benchmark`, `harm_type`, `trust_boundary`, `motif_id`.
- Detector / algorithm: frequent subgraph mining, graph edit distance clustering, manually validated motif rules.
- Baselines to compare: benchmark-native labels, keyword taxonomy, MITRE ATLAS-style manual categories freshness 확인 필요.

### Experiments

- Benchmark / dataset candidates: AgentDojo, AgentDyn, MCPTox, MSB, SafeClawBench, MalSkillBench.
- Experimental setup: 각 benchmark에서 100개 안팎의 runs를 graph로 변환하고 motif coverage를 측정합니다.
- Metrics: motif support, benign overlap rate, cross-benchmark transfer recall, detector precision/recall by motif.
- Baseline comparisons: train on AgentDojo test on AgentDyn, train on MCPTox test on MSB, motif detector vs text classifier.
- Ablation study: metadata nodes 제거, runtime nodes 제거, trust labels 제거, temporal order 제거.
- Expected result: source-to-sink motif는 benchmark를 넘어 전이될 가능성이 있고, metadata-only motif는 MCP benchmark에 특화될 가능성이 있습니다.
- Failure cases to check: graph extraction 품질이 benchmark마다 달라 motif 차이가 artifact일 수 있습니다.

### Practical Plan

- Expected difficulty: Hard.
- Risk / limitation: trace formats가 제각각이고, subgraph mining은 noisy graph에서 해석이 어렵습니다.
- First experiment: AgentDojo와 AgentDyn만 대상으로 3개 motif를 수작업 정의해 transfer 가능성을 봅니다.
- Next implementation step: common graph JSON schema와 adapter interface를 먼저 고정합니다.

## Experiment Backlog

### Easy

- AgentDojo email/workspace suite에서 `untrusted_content -> send_email.body` taint path rule을 구현합니다.
- MCP tool description 20개 benign/poisoned pair를 만들어 hidden instruction keyword와 graph drift detector를 비교합니다.
- OpenAI Agents SDK 또는 LangSmith/Phoenix trace를 graph JSON으로 변환하는 proof-of-concept를 만듭니다.

### Medium

- AgentDyn에서 helpful third-party instruction과 malicious instruction을 구분하는 authorization graph detector를 평가합니다.
- SafeClawBench subset을 실행해 semantic/audit/sandbox endpoint별 detector confusion matrix를 만듭니다.
- Docker sandbox에서 coding agent command execution을 strace로 기록하고 process-file-network graph를 생성합니다.

### Hard

- MalSkillBench식 runtime verification pipeline을 agent tool/plugin/package install 공격으로 확장합니다.
- MSB와 MCPTox를 unified MCP provenance graph schema로 변환하고 metadata poisoning motif library를 만듭니다.
- agent trace와 OS telemetry를 결합한 temporal graph neural detector를 학습하고 cross-benchmark transfer를 평가합니다.

## Possible Paper Angle

- "Execution Provenance Graphs for Detecting Malicious Tool-Use in LLM Agents"라는 방향이 가장 자연스럽습니다. 기여는 1) agent trace와 runtime telemetry를 통합한 graph schema, 2) source-to-sink 및 authorization-alignment detector, 3) AgentDojo/AgentDyn/SafeClawBench/MalSkillBench subset에서 endpoint-aware evaluation, 4) cross-benchmark provenance motif analysis로 잡을 수 있습니다.

## Next Research Question

- LLM agent의 tool call argument가 untrusted source에서 유래했는지를 얼마나 정확하고 저비용으로 추적할 수 있으며, 이 source attribution이 실제 sandbox-observed harm을 얼마나 잘 예측하는가?
