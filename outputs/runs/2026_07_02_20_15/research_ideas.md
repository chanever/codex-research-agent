# Research Ideas

## Idea 1. Provenance Graph Detector for Indirect Prompt Injection in Tool-Use Agents

### Easy Explanation

- One-line summary: agent가 읽은 외부 텍스트가 어떤 tool-call에 영향을 줬는지 그래프로 따라가서, 위험한 source-to-sink 경로를 탐지합니다.
- Intuition: "나쁜 문장"을 찾는 것보다 "그 문장이 실제로 위험한 행동을 만들었는가"를 보는 편이 더 강합니다.
- Example scenario: 이메일 본문에 hidden instruction이 있고, agent가 contacts를 export해 attacker email로 보냅니다. 그래프는 `EmailBody -> LLMDecision -> ContactRead -> EmailSend` 경로를 위험하게 표시합니다.

### Six Ws and H

- Who: defender는 agent platform 운영자, attacker는 untrusted document/email/webpage 작성자입니다.
- What: indirect prompt injection이 privileged tool-use로 이어지는 실행 경로를 탐지합니다.
- When: agent가 tool을 호출하기 전, 또는 실행 직후 audit 단계에서 사용합니다.
- Where: AgentDojo 같은 tool-use benchmark, browser agent, coding agent sandbox에서 실행합니다.
- Why: 문자열 기반 guardrail은 실제 실행 영향 여부를 놓치거나 false positive가 많습니다.
- How: 관찰 로그를 provenance graph로 변환하고, untrusted source에서 sensitive sink로 이어지는 forbidden path를 찾습니다.

### Research Framing

- Hypothesis: tool-use agent의 prompt injection 성공 여부는 실행 provenance graph의 source-to-sink path feature로 더 정확히 구분할 수 있습니다.
- Motivation: agent 보안 실패는 대개 단일 메시지가 아니라 `외부 입력 -> reasoning -> tool call -> side effect`로 이어지는 흐름입니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents
    - URL: https://arxiv.org/abs/2406.13352
    - Why it is not enough: benchmark는 공격과 방어 평가에 유용하지만, execution/provenance graph detector 자체의 schema와 policy를 완전히 제공하는 것은 아닙니다.
  - Problem 2:
    - Source: Agent-Sentry: Bounding LLM Agents via Execution Provenance
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: provenance 기반 방어의 방향은 직접적이지만, 다양한 benchmark와 OS-level side effect까지 결합하는 재현 실험은 별도로 설계해야 합니다.
- Proposed contribution: AgentDojo 로그를 provenance graph로 변환하는 공개 schema와 rule-based/learning-based detector baseline을 제안합니다.
- Why this could be novel: agent security benchmark를 graph security benchmark로 재구성하고, 정상 utility 손실과 security gain을 함께 측정하는 점이 기여가 될 수 있습니다.

### Methodology

- Required data: AgentDojo task logs, tool-call arguments/results, attack labels, user goal/attacker goal labels.
- System design: trace collector, graph builder, policy engine, detector, evaluation runner로 나눕니다.
- Implementation steps:
  1. AgentDojo 실행 로그에서 observation, model output, tool call, tool result를 추출합니다.
  2. 각 이벤트를 graph node로 만들고 순서 및 영향 관계 edge를 추가합니다.
  3. input source를 trusted/user/untrusted로 라벨링합니다.
  4. tool sink를 benign/sensitive/external/irreversible로 라벨링합니다.
  5. forbidden path rule과 graph classifier를 비교합니다.
- Graph schema:
  - Nodes: `UserInstruction`, `UntrustedDocument`, `LLMStep`, `ToolCall`, `ToolResult`, `SensitiveData`, `ExternalSink`
  - Edges: `observed_by`, `influenced`, `called`, `returned`, `contains`, `sent_to`
  - Labels: source trust, sink severity, task id, attack id, timestamp, tool name
- Detector / algorithm: forbidden path matching, path-length-weighted risk score, graph neural network baseline, temporal rule engine.
- Baselines to compare: prompt-only classifier, tool-name allowlist, LLM-as-judge safety classifier, AgentDojo built-in defense baselines.

### Experiments

- Benchmark / dataset candidates: AgentDojo, WASP, SafeClawBench.
- Experimental setup: 동일 agent와 동일 task에서 graph detector를 켜고 끄며 attack success rate와 utility를 비교합니다.
- Metrics: attack success rate reduction, utility retention, false positive rate, false negative rate, detection latency, explanation path quality.
- Baseline comparisons: prompt-only moderation, static tool policy, allow/deny list, LLM judge.
- Ablation study: source trust 라벨 제거, sink severity 제거, temporal edge 제거, tool result node 제거.
- Expected result: graph detector는 단순 prompt classifier보다 tool-use 결과와 연결된 공격을 더 잘 잡고, 정상 external action은 덜 차단할 가능성이 있습니다.
- Failure cases to check: 정상 사용자가 untrusted 문서를 요약해 외부로 보내는 legitimate workflow, tool result가 길어 influence edge가 부정확한 경우.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: influence edge를 정확히 추론하기 어렵습니다. 처음에는 conservative heuristic으로 시작해야 합니다.
- First experiment: AgentDojo 한 도메인에서 JSONL trace를 graph JSON으로 변환하고 forbidden path rule 5개를 평가합니다.
- Next implementation step: `untrusted source -> external sink`, `untrusted source -> credential access`, `untrusted source -> irreversible action` 규칙을 구현합니다.

## Idea 2. OS-Augmented Execution Graphs for Coding Agent Supply-Chain Attacks

### Easy Explanation

- One-line summary: coding agent의 shell/tool 로그에 Docker, strace, filesystem, network trace를 붙여 package install 공격을 탐지합니다.
- Intuition: agent는 "테스트를 실행했다"고 말하지만, 실제 프로세스는 package postinstall script, subprocess, network exfiltration을 수행할 수 있습니다.
- Example scenario: agent가 `pip install helpful-lib`를 실행했는데 설치 스크립트가 `.env`를 읽고 외부 서버로 보냅니다.

### Six Ws and H

- Who: defender는 coding agent sandbox 운영자, attacker는 malicious package maintainer나 compromised dependency입니다.
- What: package install, build script, test command 중 발생하는 위험한 OS 이벤트를 graph로 탐지합니다.
- When: dependency install, test, build, browser automation 실행 중입니다.
- Where: Docker sandbox, CI runner, local coding agent environment입니다.
- Why: LLM tool-call 로그에는 subprocess와 syscall-level side effect가 빠질 수 있습니다.
- How: `strace -f`, auditd, eBPF, Docker network log를 수집해 tool-call graph와 병합합니다.

### Research Framing

- Hypothesis: LLM-level execution graph에 OS-level event nodes를 추가하면 malicious package install attack 탐지율이 올라갑니다.
- Motivation: software supply chain attack은 agent가 직접 악의적 명령을 생성하지 않아도 dependency script가 실행되면서 발생합니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: AgentSight: A Runtime Provenance System for Diagnosing AI Agents
    - URL: https://arxiv.org/abs/2502.04354
    - Why it is not enough: runtime provenance 수집 방향은 유용하지만, coding agent supply-chain attack benchmark와 detector metric을 직접 제공하는지는 확인이 필요합니다.
  - Problem 2:
    - Source: AgentArmor: Securing Large Language Model Agents through Runtime Enforcement and Dynamic Policy
    - URL: https://arxiv.org/abs/2508.01249
    - Why it is not enough: runtime policy enforcement는 중요하지만, package manager postinstall script와 syscall trace를 결합한 그래프 평가셋은 별도 구축이 필요합니다.
- Proposed contribution: coding agent run을 LLM event와 OS event가 결합된 heterogeneous graph로 만들고, package-install attack detection benchmark를 제안합니다.
- Why this could be novel: agent security와 software supply-chain detection을 execution graph 하나로 연결합니다.

### Methodology

- Required data: coding agent shell command logs, Docker filesystem diff, `strace -f` logs, network connection logs, synthetic malicious packages.
- System design: sandbox runner, trace normalizer, graph merger, risk scorer, replay evaluator.
- Implementation steps:
  1. Docker container에서 agent-generated commands를 실행합니다.
  2. `strace -f -e trace=file,process,network`로 OS 이벤트를 수집합니다.
  3. command timestamp와 PID tree를 기준으로 tool-call과 syscall event를 연결합니다.
  4. 민감 파일 경로, network egress, subprocess spawn, package script execution을 라벨링합니다.
  5. 정상 패키지와 악성 패키지를 섞은 실험셋을 만듭니다.
- Graph schema:
  - Nodes: `AgentCommand`, `Process`, `Package`, `Script`, `File`, `NetworkEndpoint`, `Secret`
  - Edges: `spawned`, `opened`, `read`, `wrote`, `connected_to`, `installed`, `triggered_by`
  - Labels: syscall type, path sensitivity, endpoint reputation, package source, command origin
- Detector / algorithm: suspicious path rule, package provenance rule, process tree anomaly score, graph contrastive classifier.
- Baselines to compare: static package scanner, network egress denylist, shell command regex filter, Docker no-network policy.

### Experiments

- Benchmark / dataset candidates: synthetic PyPI/npm malicious package set, malicious package detection datasets found during further search, AgentDojo coding-style tasks if adapted, `freshness 확인 필요`.
- Experimental setup: normal dependency install tasks와 malicious dependency install tasks를 50:50으로 구성하고 detector 성능을 측정합니다.
- Metrics: detection F1, false block rate, sensitive file access recall, network exfiltration recall, overhead, graph build time.
- Baseline comparisons: no-network sandbox, static allowlist, package reputation lookup, LLM judge over command string.
- Ablation study: syscall node 제거, network node 제거, package metadata 제거, LLM command node 제거.
- Expected result: OS-augmented graph는 command string만 보는 baseline보다 postinstall/script 기반 공격을 더 잘 잡습니다.
- Failure cases to check: 정상 build script가 네트워크를 사용하거나 홈 디렉터리 config를 읽는 경우.

### Practical Plan

- Expected difficulty: Medium to Hard
- Risk / limitation: syscall trace는 noisy하며 privacy-sensitive path가 포함될 수 있습니다.
- First experiment: 간단한 malicious npm package PoC와 benign package를 만들어 Docker 안에서 `strace` graph를 비교합니다.
- Next implementation step: PID tree와 file/network event를 NetworkX graph로 변환하는 최소 parser를 만듭니다.

## Idea 3. Dual-Graph Authorization for MCP Tool Poisoning

### Easy Explanation

- One-line summary: MCP tool이 말로 약속한 기능과 실제 실행 행동을 각각 그래프로 만들고, 둘이 어긋나면 tool poisoning으로 의심합니다.
- Intuition: "파일 검색 도구"라고 소개된 MCP server가 실제로 secret 파일을 읽고 외부로 보내면 metadata graph와 runtime graph가 맞지 않습니다.
- Example scenario: `search_docs`라는 MCP tool description은 문서 검색만 말하지만 실행 중 `.env`를 읽고 webhook에 연결합니다.

### Six Ws and H

- Who: defender는 MCP client/agent runtime 운영자, attacker는 악성 MCP server 또는 compromised tool provider입니다.
- What: MCP tool metadata, schema, description, runtime behavior 사이의 불일치를 탐지합니다.
- When: MCP server 등록 시, tool 호출 전, tool 호출 후 audit 단계에서 사용합니다.
- Where: MCP-enabled coding agent, research agent, enterprise automation agent입니다.
- Why: MCP tool은 agent 권한을 확장하므로 tool 자체가 공격면이 됩니다.
- How: tool metadata graph와 runtime execution graph를 만들고 dual-graph alignment로 비교합니다.

### Research Framing

- Hypothesis: MCP tool poisoning은 metadata graph와 runtime behavior graph의 structural mismatch로 탐지할 수 있습니다.
- Motivation: tool description prompt injection과 malicious runtime behavior는 모두 agent가 tool을 신뢰한다는 전제를 악용합니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MCPTox: An LLM-Based Benchmark for MCP Server Tool Poisoning
    - URL: https://arxiv.org/abs/2508.14925
    - Why it is not enough: MCP tool poisoning 평가에 초점이 있지만, OS/runtime provenance graph까지 결합한 detector는 별도 설계가 필요합니다.
  - Problem 2:
    - Source: MSB: Comprehensive Benchmarking of MCP Server Security
    - URL: https://arxiv.org/abs/2510.15994
    - Why it is not enough: benchmark가 server security를 폭넓게 다루더라도, metadata-behavior graph alignment 알고리즘은 추가 연구 주제가 될 수 있습니다.
  - Problem 3:
    - Source: Tool Poisoning Attacks in MCP, Invariant Labs
    - URL: https://invariantlabs.ai/blog/mcp-security-notification-tool-poisoning-attacks
    - Why it is not enough: 실무 공격 설명은 유용하지만 peer-reviewed benchmark와 정량 평가가 필요합니다.
- Proposed contribution: MCP server의 declared capability graph와 observed behavior graph를 비교하는 poisoning detector를 제안합니다.
- Why this could be novel: MCP 특화 metadata, schema, runtime trace를 하나의 graph alignment problem으로 공식화합니다.

### Methodology

- Required data: MCP tool descriptions, JSON schemas, server code or sandboxed execution trace, tool-call logs, poisoning labels.
- System design: metadata parser, sandbox executor, trace collector, graph aligner, risk reporter.
- Implementation steps:
  1. MCP tool name/description/schema에서 declared objects, actions, sinks를 추출합니다.
  2. tool을 sandbox에서 sample input으로 실행하고 file/network/process trace를 수집합니다.
  3. declared graph와 observed graph를 비교합니다.
  4. undeclared sensitive file access, undeclared network sink, hidden instruction phrase를 risk feature로 만듭니다.
  5. MCPTox/MSB task에서 detector를 평가합니다.
- Graph schema:
  - Nodes: `ToolDescription`, `DeclaredAction`, `DeclaredResource`, `RuntimeProcess`, `File`, `NetworkEndpoint`, `ToolResult`
  - Edges: `claims_to_access`, `accepts_argument`, `observed_read`, `observed_write`, `observed_connect`, `returns`
  - Labels: declared/observed, trust level, resource sensitivity, schema field, endpoint domain
- Detector / algorithm: graph edit distance, undeclared sink rule, semantic mismatch classifier, hidden instruction scanner.
- Baselines to compare: description-only LLM classifier, schema allowlist, runtime network block, manual MCP permission manifest.

### Experiments

- Benchmark / dataset candidates: MCPTox, MSB, Invariant Labs MCP poisoning examples, custom MCP servers.
- Experimental setup: benign MCP servers와 poisoned MCP servers를 동일 agent workflow에 연결하고 detector가 registration-time 또는 runtime-time에 잡는지 평가합니다.
- Metrics: poisoning detection F1, runtime overhead, benign tool false positive rate, undeclared sink recall, explanation precision.
- Baseline comparisons: static text scan, LLM judge over tool description, pure sandbox allowlist.
- Ablation study: description graph 제거, schema graph 제거, runtime graph 제거, endpoint reputation feature 제거.
- Expected result: metadata와 runtime을 함께 보는 detector가 description-only scanner보다 behavior-level poisoning을 더 잘 잡습니다.
- Failure cases to check: legitimate tool이 optional network access를 쓰지만 description에 자세히 적지 않은 경우.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: MCP server를 안전하게 sandbox에서 실행하는 harness가 필요합니다.
- First experiment: benign/poisoned toy MCP server 10개를 만들고 declared-vs-observed graph mismatch rule을 평가합니다.
- Next implementation step: JSON schema와 tool description을 declared graph로 변환하는 parser를 만듭니다.

## Idea 4. Temporal Graph Anomaly Detection for Browser Agent Security

### Easy Explanation

- One-line summary: browser agent가 페이지를 읽고 클릭하고 폼을 제출하는 순서를 시간 그래프로 만들고, prompt injection으로 생긴 이상한 action path를 찾습니다.
- Intuition: 위험한 browser agent 행동은 한 번의 click보다 "untrusted DOM text를 읽은 뒤 private data를 외부 form에 넣는 순서"에서 드러납니다.
- Example scenario: 웹페이지 hidden text가 agent에게 profile page의 private phone number를 외부 contact form에 붙여넣게 합니다.

### Six Ws and H

- Who: defender는 browser agent runtime, attacker는 malicious webpage operator입니다.
- What: DOM observation에서 external action까지 이어지는 temporal execution graph를 탐지합니다.
- When: web browsing task 수행 중입니다.
- Where: web automation benchmark, browser extension agent, enterprise web workflow입니다.
- Why: web agent는 untrusted DOM과 high-impact actions가 가까이 붙어 있어 indirect prompt injection에 취약합니다.
- How: DOM node, screenshot region, model action, browser event, network request를 temporal graph로 연결합니다.

### Research Framing

- Hypothesis: browser agent prompt injection은 temporal graph에서 `untrusted DOM -> private data access -> external submission` 패턴으로 잘 포착됩니다.
- Motivation: web agent는 text-only guardrail보다 DOM provenance와 action sequence 분석이 필요합니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: WASP: Benchmarking Web Agent Security Against Prompt Injection Attacks
    - URL: https://arxiv.org/abs/2504.18575
    - Why it is not enough: benchmark는 web prompt injection 평가에 유용하지만, temporal provenance graph detector는 별도 contribution이 될 수 있습니다.
  - Problem 2:
    - Source: AgentDojo: A Dynamic Environment to Evaluate Prompt Injection Attacks and Defenses for LLM Agents
    - URL: https://arxiv.org/abs/2406.13352
    - Why it is not enough: 일반 tool-use benchmark라 DOM-level provenance와 browser event graph는 직접 추가해야 할 수 있습니다.
- Proposed contribution: browser agent action을 DOM-provenance temporal graph로 변환하고 risky path detector를 제안합니다.
- Why this could be novel: prompt injection defense를 page text classification이 아니라 DOM/action provenance 문제로 바꿉니다.

### Methodology

- Required data: browser action traces, DOM snapshots, form submissions, page origins, private data labels, prompt injection labels.
- System design: browser instrumentation, DOM provenance extractor, temporal graph builder, path detector, replay evaluator.
- Implementation steps:
  1. browser automation 실행 중 DOM snapshot과 action log를 수집합니다.
  2. visible text, hidden text, iframe, origin을 source node로 라벨링합니다.
  3. click, type, copy, paste, submit, navigation을 action node로 만듭니다.
  4. private data field와 external domain sink를 표시합니다.
  5. risky temporal pattern을 탐지합니다.
- Graph schema:
  - Nodes: `DOMText`, `FormField`, `BrowserAction`, `PrivateData`, `URL`, `NetworkRequest`
  - Edges: `visible_to`, `selected`, `typed_into`, `submitted_to`, `navigated_to`, `temporally_before`
  - Labels: origin, visibility, sensitivity, action type, timestamp
- Detector / algorithm: temporal path rules, sequence-to-graph classifier, origin-aware taint tracking.
- Baselines to compare: prompt scanner over page text, URL denylist, browser action allowlist, LLM judge.

### Experiments

- Benchmark / dataset candidates: WASP, AgentDojo web-like tasks, SafeClawBench web scenarios if available.
- Experimental setup: benign browsing tasks와 malicious prompt injection pages를 replay하며 detector가 risky submission 전에 경고하는지 측정합니다.
- Metrics: attack prevention rate, benign task completion rate, warning precision, detection lead time, path explanation accuracy.
- Baseline comparisons: hidden text removal, prompt-only classifier, domain allowlist.
- Ablation study: DOM origin 제거, hidden-text label 제거, temporal edge 제거, network request node 제거.
- Expected result: temporal graph detector는 "malicious instruction이 실제 action에 영향을 준 경우"에 더 정확한 경고를 줄 수 있습니다.
- Failure cases to check: 사용자가 의도적으로 cross-site form submission을 수행하는 정상 업무.

### Practical Plan

- Expected difficulty: Hard
- Risk / limitation: browser trace instrumentation과 benchmark replay가 복잡합니다.
- First experiment: Playwright로 toy web task 5개를 만들고 DOM/action/network graph를 수집합니다.
- Next implementation step: `DOMText(origin=untrusted) -> TypeAction -> FormField(sensitive/external)` 패턴 rule을 구현합니다.

## Idea 5. Graph-Based Safety Case Generator for Human Verification of Agent Runs

### Easy Explanation

- One-line summary: agent 실행이 끝난 뒤 사람이 빠르게 검토할 수 있도록 "왜 이 실행이 안전하거나 위험한지"를 그래프 경로 중심으로 요약합니다.
- Intuition: security analyst는 모든 로그를 볼 시간이 없습니다. 위험한 경로 3개와 정상 경로 3개만 보여줘도 검토가 쉬워집니다.
- Example scenario: agent run report가 "untrusted issue text influenced shell command, but no sensitive file/network sink was reached"라고 설명합니다.

### Six Ws and H

- Who: human reviewer, security engineer, research evaluator입니다.
- What: agent run의 security-relevant provenance path를 요약하고 검토 질문을 생성합니다.
- When: offline audit, benchmark evaluation, incident triage, high-risk action 승인 전입니다.
- Where: coding agent logs, browser agent logs, MCP tool-call logs입니다.
- Why: 자동 detector만으로는 false positive/negative를 완전히 없애기 어렵고 설명 가능성이 필요합니다.
- How: execution graph에서 top-k risky paths를 추출하고, 각 path의 source, edge, sink, missing evidence를 한국어/영어 report로 생성합니다.

### Research Framing

- Hypothesis: graph path explanation은 raw logs나 LLM summary보다 human verification speed와 correctness를 개선합니다.
- Motivation: graph detector는 실용화되려면 사람이 왜 차단했는지 이해할 수 있어야 합니다.
- Existing problems in prior work:
  - Problem 1:
    - Source: Agent-Sentry: Bounding LLM Agents via Execution Provenance
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: provenance 기반 방어는 중요하지만, reviewer-facing safety case의 사용자 연구는 별도 연구 주제가 될 수 있습니다.
  - Problem 2:
    - Source: AgentSight: A Runtime Provenance System for Diagnosing AI Agents
    - URL: https://arxiv.org/abs/2502.04354
    - Why it is not enough: diagnosis provenance는 유용하지만, prompt injection/security decision을 위한 structured safety case generation은 별도 평가가 필요합니다.
- Proposed contribution: agent execution graph에서 자동으로 safety case와 verification checklist를 생성하는 방법을 제안합니다.
- Why this could be novel: detection 성능뿐 아니라 human-in-the-loop verification efficiency를 지표로 삼습니다.

### Methodology

- Required data: detector outputs, execution graphs, ground-truth attack labels, human review logs if available.
- System design: path ranker, explanation generator, uncertainty annotator, reviewer UI-less Markdown report generator.
- Implementation steps:
  1. 각 graph에서 risk score가 높은 path를 top-k로 추출합니다.
  2. path를 source, transformation, sink, evidence, missing evidence로 분해합니다.
  3. 사람이 확인해야 할 질문을 생성합니다.
  4. raw log summary와 graph path summary를 비교하는 소규모 사용자 평가를 설계합니다.
- Graph schema:
  - Nodes: `Source`, `AgentDecision`, `ToolCall`, `RuntimeEvent`, `Sink`, `Policy`
  - Edges: `influenced`, `violates`, `allowed_by`, `requires_review`
  - Labels: confidence, severity, evidence pointer, uncertainty reason
- Detector / algorithm: k-shortest risky paths, policy violation explanation, LLM-assisted natural language rendering with citations to graph node ids.
- Baselines to compare: raw logs, chronological trace table, LLM summary without graph constraints.

### Experiments

- Benchmark / dataset candidates: AgentDojo traces, OS-augmented coding agent traces, MCP toy benchmark, SafeClawBench.
- Experimental setup: reviewers classify runs as safe/unsafe using different report formats.
- Metrics: review accuracy, time-to-decision, reviewer confidence, missed critical path rate, hallucinated explanation rate.
- Baseline comparisons: raw JSON trace, LLM-generated summary, static policy violation list.
- Ablation study: remove uncertainty notes, remove graph node citations, remove benign path summary.
- Expected result: graph-grounded report가 raw logs보다 빠르고, unconstrained LLM summary보다 덜 hallucinate할 가능성이 있습니다.
- Failure cases to check: graph builder가 잘못 만든 edge를 report가 과신하는 경우.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: human evaluation이 필요해 시간이 듭니다. 처음에는 expert self-evaluation으로 시작할 수 있습니다.
- First experiment: AgentDojo run 20개에 대해 graph path report를 생성하고, 사람이 공격 성공 여부를 얼마나 빨리 판단하는지 측정합니다.
- Next implementation step: graph node id를 포함한 Markdown safety case template을 만듭니다.

## Experiment Backlog

### Easy

- AgentDojo 한 태스크를 실행해 tool-call trace를 graph JSON으로 변환합니다.
- `untrusted source -> external sink` forbidden path rule을 구현합니다.
- MCP toy server 3개를 만들고 declared-vs-observed behavior mismatch를 수동 라벨링합니다.
- Docker container에서 `strace -f -e trace=file,process,network` 로그를 수집해 CSV로 정규화합니다.

### Medium

- AgentDojo 3개 도메인에서 graph detector와 prompt-only classifier를 비교합니다.
- malicious npm/PyPI toy package를 만들어 package install attack graph를 수집합니다.
- Browser toy benchmark를 Playwright로 만들고 DOM/action/network temporal graph를 생성합니다.
- MCP tool description graph와 runtime graph의 graph edit distance baseline을 구현합니다.

### Hard

- AgentDojo, WASP, MCPTox/MSB를 공통 graph schema로 통합합니다.
- eBPF 기반 trace collector를 붙여 low-overhead runtime provenance를 수집합니다.
- graph neural network 또는 temporal graph transformer로 attack path를 학습합니다.
- human-in-the-loop safety case evaluation을 설계해 reviewer study를 수행합니다.

## Possible Paper Angle

- "From Prompt Logs to Execution Provenance: Graph-Based Detection of Malicious Tool-Use in LLM Agents"
- 핵심 기여는 공통 execution graph schema, AgentDojo/MCP/coding-agent trace 변환기, graph policy detector, OS-augmented ablation, human-verifiable path explanation입니다.
- novelty를 과장하지 않으려면 `Agent-Sentry`, `AuthGraph`, `AgentArmor`, `AgentDojo`를 직접 선행연구로 인정하고, 차별점은 benchmark unification과 system-level trace integration으로 잡는 편이 안전합니다.

## Next Research Question

- LLM agent 실행에서 "influence edge"를 어떻게 믿을 수 있게 만들 것인가?
- static prompt/tool logs만으로 충분한가, 아니면 syscall/network/file trace가 필수인가?
- graph detector가 정상 workflow를 얼마나 방해하는가?
- policy graph는 사람이 작성해야 하는가, 아니면 tool schema와 organization policy에서 자동 생성할 수 있는가?
- MCP server가 self-declared metadata와 다른 행동을 할 때, registration-time sandboxing만으로 충분한가?
