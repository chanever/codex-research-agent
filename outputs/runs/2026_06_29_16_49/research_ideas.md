# Research Ideas

## Idea 1. Source-to-Sink Execution Graph Detector for Tool-Use Agents

### Easy Explanation

- One-line summary: 에이전트가 읽은 untrusted input이 민감한 tool action으로 흘러갔는지 그래프로 잡는다.
- Intuition: 사람도 "웹페이지가 시킨 말 때문에 회사 파일을 외부로 보냈다"면 이상하다고 본다. detector도 이 흐름을 그래프로 보면 된다.
- Example scenario: browser agent가 블로그 글을 읽다가 숨은 instruction 때문에 `read_internal_doc` 뒤 `send_email(attacker)`를 실행한다.

### Six Ws and H

- Who: browser/coding/tool-use agent를 운영하는 defender와 prompt injection을 심는 attacker.
- What: untrusted source에서 sensitive sink로 이어지는 실행 경로를 탐지한다.
- When: tool call 직전, tool call 직후, session 종료 후 forensic analysis 시점.
- Where: AgentDojo, AgentDyn, custom MCP sandbox, coding-agent Docker sandbox.
- Why: LLM output text만 보면 공격과 정상 행동을 구분하기 어렵기 때문이다.
- How: observation, prompt segment, tool call, file, network, credential access를 graph node로 만들고, `influenced/read/wrote/sent` edge를 추적한다.

### Research Framing

- Hypothesis: source-to-sink provenance path를 쓰면 prompt/text classifier보다 indirect prompt injection 탐지 precision과 recall이 높아진다.
- Motivation: 공격은 모델 내부보다 실행 흐름에 흔적을 남긴다.
- Existing problems in prior work:
  - Problem 1:
    - Source: AgentDojo
    - URL: https://arxiv.org/abs/2406.13352
    - Why it is not enough: benchmark는 공격/방어 평가 환경을 주지만, execution graph schema 자체를 중심으로 한 detector 연구는 별도 설계가 필요하다.
  - Problem 2:
    - Source: Content-Aware Attack Detection for LLM Agents
    - URL: https://arxiv.org/abs/2605.11053
    - Why it is not enough: content-aware traffic detection은 유용하지만, filesystem/process/syscall provenance까지 결합한 source-to-sink graph는 추가 연구 여지가 있다.
- Proposed contribution: agent event와 system event를 통합한 provenance graph detector와 공개 trace schema.
- Why this could be novel: 기존 prompt injection detector는 prompt/content 중심이 많고, agent runtime의 파일/네트워크 side effect까지 통합한 graph benchmark는 아직 정착되지 않았다.

### Methodology

- Required data: AgentDojo/AgentDyn task logs, tool-call arguments, observation source labels, optional sandbox logs.
- System design: agent wrapper가 모든 observation과 tool call을 event로 기록하고, graph builder가 session graph를 생성한다. detector는 rule baseline과 graph neural network 또는 path classifier 두 종류를 제공한다.
- Implementation steps:
  1. AgentDojo task 10개를 선택한다.
  2. tool wrapper에 event logger를 붙인다.
  3. observation source를 `trusted_user`, `untrusted_web`, `untrusted_doc`, `tool_output`으로 라벨링한다.
  4. sensitive sink를 `send_email`, `external_http`, `shell_exec`, `credential_read`로 정의한다.
  5. source-to-sink path 존재 여부와 path feature로 attack을 예측한다.
- Graph schema:
  - Nodes: user_prompt, external_observation, llm_decision, tool_call, tool_result, file, network_endpoint, credential, process.
  - Edges: observed, generated, invoked, returned, read, wrote, sent_to, influenced, derived_from.
  - Labels: trust level, sensitivity, action type, timestamp, model, tool server, sandbox id.
- Detector / algorithm: shortest risky path rule, taint propagation, temporal graph classifier.
- Baselines to compare: prompt classifier, tool-name allowlist, content-only classifier, no-provenance event sequence model.

### Experiments

- Benchmark / dataset candidates: AgentDojo, AgentDyn, MSB, SafeClawBench.
- Experimental setup: 동일한 task를 정상/공격 조건으로 실행하고, detector가 공격 성공 직전 또는 직후에 alert를 내는지 측정한다.
- Metrics: attack detection recall, false positive rate, attack success rate reduction, utility retention, time-to-detect, graph construction overhead.
- Baseline comparisons: LLM-as-judge safety classifier, regex/prompt filter, tool allowlist, content-aware detector.
- Ablation study: source labels 제거, sink sensitivity 제거, influence edge 제거, system-call edge 제거.
- Expected result: graph provenance가 있는 detector가 indirect injection과 data exfiltration에서 content-only baseline보다 안정적일 가능성이 높다.
- Failure cases to check: 사용자가 실제로 외부 전송을 요청한 정상 task, 민감도 라벨이 틀린 파일, multi-hop tool output.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: influence edge를 정확히 만들기 어렵다. 처음에는 conservative taint propagation으로 시작해야 한다.
- First experiment: AgentDojo task 5개에서 rule-based `untrusted_source -> sensitive_sink` detector를 구현한다.
- Next implementation step: graph JSONL schema와 visualization notebook을 만든다.

## Idea 2. MCP Tool Poisoning Attribution with Decision Dependence Graphs

### Easy Explanation

- One-line summary: 어떤 MCP tool 설명이나 server response가 agent의 나쁜 tool 선택을 유도했는지 역추적한다.
- Intuition: 공격자가 tool 설명에 악성 지시를 숨기면, agent는 그것을 정상 API 설명처럼 믿을 수 있다. 그래프는 "그 설명이 어떤 결정에 영향을 줬는가"를 보여준다.
- Example scenario: `calendar_search` tool 설명이 실제로는 email 내용을 외부로 보내라고 유도한다.

### Six Ws and H

- Who: MCP server를 공급하는 attacker, MCP client/agent 운영자, security auditor.
- What: poisoned tool metadata에서 malicious action까지의 dependence path를 찾는다.
- When: MCP server 연결 시, tool selection 시, incident 후 attribution 시.
- Where: MCP-based agent environment, MSB, MCPTox 후보 benchmark, custom MCP servers.
- Why: MCP tool 설명은 agent의 의사결정 입력이지만 보통 코드 실행 전까지는 위험이 드러나지 않는다.
- How: tool description, server manifest, model tool-selection rationale, invocation, downstream effect를 decision dependence graph로 연결한다.

### Research Framing

- Hypothesis: decision dependence graph는 poisoned MCP tool을 단순 anomaly detection보다 더 잘 attribution할 수 있다.
- Motivation: MCP ecosystem이 커질수록 malicious server/tool description 공격이 software supply chain 문제처럼 커질 수 있다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MindGuard
    - URL: https://arxiv.org/abs/2508.19070
    - Why it is not enough: decision dependence graph 방향은 강하지만, 다양한 MCP server와 coding/browser agent side effect까지 포함한 공개 재현 환경은 추가 확인이 필요하다.
  - Problem 2:
    - Source: MSB
    - URL: https://openreview.net/forum?id=QI2YK6U9cP
    - Why it is not enough: benchmark는 넓은 security task를 제공하지만, poisoned metadata의 원인 attribution 자체를 주 contribution으로 삼지는 않을 수 있다.
- Proposed contribution: MCP tool poisoning 전용 graph attribution benchmark와 detector.
- Why this could be novel: 공격 성공 여부뿐 아니라 "어떤 tool description node가 어떤 harmful edge를 만들었는지"를 정량화한다.

### Methodology

- Required data: MCP tool manifests, clean/poisoned tool descriptions, tool invocation logs, downstream file/network events.
- System design: MCP proxy가 tool list와 invocation traffic을 캡처하고, agent wrapper가 LLM decision context를 기록한다.
- Implementation steps:
  1. 정상 MCP server 5개와 poisoned variant 5개를 만든다.
  2. tool description diff와 invocation decision을 기록한다.
  3. harmful outcome label을 `credential_read`, `unauthorized_send`, `destructive_write` 등으로 만든다.
  4. poisoned node attribution score를 계산한다.
- Graph schema:
  - Nodes: MCP_server, tool_manifest, tool_description_span, llm_decision, tool_call, tool_output, resource, network_sink.
  - Edges: advertises, describes, selected_due_to, invokes, returns, influences, causes_side_effect.
  - Labels: clean/poisoned, trust boundary, permission scope, outcome severity.
- Detector / algorithm: taint propagation from poisoned description spans, attention/rationale-assisted edge scoring, graph path risk scoring.
- Baselines to compare: tool description static scanner, allowlist, LLM judge over tool metadata, runtime anomaly detector without attribution.

### Experiments

- Benchmark / dataset candidates: MSB, MCPTox `freshness 확인 필요`, AgentDojo MCP-style adaptation, custom MCP poisoning suite.
- Experimental setup: clean and poisoned MCP server variants를 동일 task에 연결하고 tool choice와 harmful outcome을 비교한다.
- Metrics: poisoning detection recall, attribution accuracy, false attribution rate, benign tool utility, runtime overhead.
- Baseline comparisons: static metadata scanner, content-aware traffic detector, tool allowlist.
- Ablation study: tool description span edge 제거, model rationale 제거, runtime side-effect edge 제거.
- Expected result: metadata-only scanner보다 runtime dependence graph가 실제 harmful outcome에 연결된 poisoning을 더 잘 구분한다.
- Failure cases to check: 정상 tool description이 길고 복잡한 경우, agent가 여러 tool을 섞어 쓰는 경우, poisoned instruction이 obfuscated된 경우.

### Practical Plan

- Expected difficulty: Medium to Hard
- Risk / limitation: MCP benchmark와 MCPTox primary data의 공개 상태를 확인해야 한다.
- First experiment: toy MCP server 두 개를 만들고 clean/poisoned description으로 같은 task를 실행한다.
- Next implementation step: MCP proxy event schema를 graph JSONL과 맞춘다.

## Idea 3. Docker/strace Provenance Graph for Coding Agent Package Install Attacks

### Easy Explanation

- One-line summary: coding agent가 package를 설치하거나 command를 실행할 때, 실제 syscall과 파일/네트워크 side effect를 그래프로 기록한다.
- Intuition: agent log에는 `npm install` 한 줄만 보여도, 내부 postinstall script가 secret file을 읽고 외부로 보낼 수 있다.
- Example scenario: malicious Python package가 설치 중 `~/.config/agent/tokens.json`을 읽고 HTTP POST를 보낸다.

### Six Ws and H

- Who: coding agent 사용자, package maintainer attacker, sandbox operator.
- What: package install attack과 malicious skill execution을 syscall provenance graph로 탐지한다.
- When: `pip install`, `npm install`, `uv run`, `pytest`, generated script execution 중.
- Where: Docker sandbox, CI runner, local coding agent workspace.
- Why: LLM/tool logs만으로는 subprocess 내부 행동을 볼 수 없기 때문이다.
- How: Docker에서 agent command를 실행하고 strace/eBPF/audit logs를 graph node/edge로 변환한다.

### Research Framing

- Hypothesis: agent-level tool graph와 syscall-level provenance graph를 결합하면 malicious package/skill 탐지 성능이 높아진다.
- Motivation: coding agent는 supply-chain attack에 취약하며, 실행된 package script가 실제 harmful behavior를 만든다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MalSkillBench
    - URL: https://arxiv.org/abs/2606.07131
    - Why it is not enough: malicious skill runtime verification benchmark는 유용하지만, coding agent package install trace와 일반 package manager lifecycle script로 확장할 필요가 있다.
  - Problem 2:
    - Source: Cuckoo: Stealthy and Persistent Attacks Against AI IDEs
    - URL: https://arxiv.org/abs/2506.01038
    - Why it is not enough: AI IDE 공격 시나리오는 중요하지만, syscall-level detector와 benchmark contribution은 별도로 설계할 수 있다.
- Proposed contribution: coding agent package install attack용 syscall provenance graph dataset과 detector.
- Why this could be novel: agent tool trace와 low-level syscall trace를 같은 graph에 합쳐, high-level intent와 low-level side effect를 함께 본다.

### Methodology

- Required data: package install commands, package metadata, lifecycle scripts, strace logs, Docker network/file events.
- System design: sandbox runner가 agent-generated command를 Docker에서 실행하고, syscall tracer가 file/network/process events를 기록한다.
- Implementation steps:
  1. benign/malicious package fixture를 만든다.
  2. agent에게 "dependency 설치 후 테스트 실행" 같은 coding task를 준다.
  3. strace로 `openat`, `connect`, `execve`, `unlink`, `chmod` 등을 기록한다.
  4. agent tool event와 syscall event를 timestamp로 join한다.
  5. graph detector가 suspicious install path를 탐지한다.
- Graph schema:
  - Nodes: agent_command, package, script, process, file_path, credential_file, network_endpoint, syscall.
  - Edges: installs, spawns, opens, reads, writes, connects, deletes, derives_from.
  - Labels: package trust, path sensitivity, network reputation, lifecycle phase, exit code.
- Detector / algorithm: rule-based syscall pattern detector, graph anomaly detector, known-good package behavior comparison.
- Baselines to compare: package static scanner, malware signature scanner, command allowlist, no-syscall agent log detector.

### Experiments

- Benchmark / dataset candidates: MalSkillBench, SafeClawBench, custom malicious npm/pip fixtures, MSB coding tasks.
- Experimental setup: Docker sandbox에서 benign/malicious package를 설치하게 하고 detector가 harmful side effect를 잡는지 측정한다.
- Metrics: detection recall, false positive rate on benign installs, overhead, blocked attack success, evidence path length.
- Baseline comparisons: static package scanner, Semgrep-like rule, simple network block, LLM judge over command text.
- Ablation study: network edge 제거, file sensitivity label 제거, agent command context 제거, syscall granularity 축소.
- Expected result: syscall provenance가 없으면 postinstall exfiltration 탐지가 크게 떨어질 가능성이 있다.
- Failure cases to check: 정상 package telemetry, build script의 광범위한 file read, obfuscated shell script.

### Practical Plan

- Expected difficulty: Hard
- Risk / limitation: sandbox escape는 다루지 않고, 우선 sandbox 안의 행위 관찰로 범위를 제한해야 한다.
- First experiment: malicious npm package fixture 하나와 benign package 5개를 만들어 strace graph를 비교한다.
- Next implementation step: Docker runner와 graph converter를 최소 구현한다.

## Idea 4. Graph-Based Utility-Preserving Policy for Agent Tool Calls

### Easy Explanation

- One-line summary: 위험한 tool call은 막되, 정상 작업은 최대한 유지하는 graph policy를 만든다.
- Intuition: 모든 shell이나 email tool을 막으면 안전하지만 쓸모가 없다. "어떤 출처에서 어떤 sink로 가는 경로인가"를 보면 더 섬세하게 막을 수 있다.
- Example scenario: 사용자가 직접 요청한 email 전송은 허용하지만, untrusted webpage가 유도한 email 전송은 승인을 요구한다.

### Six Ws and H

- Who: agent platform operator, enterprise security team, developer tools vendor.
- What: graph path policy로 tool call을 allow, deny, require_approval 중 하나로 결정한다.
- When: tool call 직전 pre-execution guardrail 시점.
- Where: browser agent, coding agent, MCP gateway, internal enterprise agent.
- Why: safety와 utility 사이의 tradeoff를 정량적으로 최적화해야 하기 때문이다.
- How: execution graph의 trust/sensitivity/path feature를 policy engine에 넣고 decision을 반환한다.

### Research Framing

- Hypothesis: graph path policy는 coarse tool allowlist보다 공격 성공률을 낮추면서 정상 task utility를 더 잘 유지한다.
- Motivation: agent security가 실서비스에 들어가려면 false positive와 사용자 방해를 줄여야 한다.
- Existing problems in prior work:
  - Problem 1:
    - Source: AuthGraph
    - URL: https://arxiv.org/abs/2605.26497
    - Why it is not enough: authorization graph 개념은 핵심이지만, benchmark별 utility-preserving policy tuning과 ablation은 별도 실험 여지가 있다.
  - Problem 2:
    - Source: Agent-Sentry
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: end-to-end security framework는 넓은 방향을 주지만, 구체적인 utility/security Pareto curve를 만드는 연구가 필요하다.
- Proposed contribution: graph policy language와 utility-preserving evaluation protocol.
- Why this could be novel: 보안 detector를 "많이 막는 모델"이 아니라 "정상 task를 유지하는 runtime policy"로 평가한다.

### Methodology

- Required data: normal/attack task traces, human-approved sensitive actions, tool permission metadata.
- System design: policy engine이 graph path를 query하고 decision을 agent runtime에 반환한다.
- Implementation steps:
  1. sensitive sinks와 trusted sources taxonomy를 만든다.
  2. policy rule을 DSL 또는 YAML로 작성한다.
  3. AgentDojo/MSB에서 normal/attack traces를 수집한다.
  4. allow/deny/approval policies를 비교한다.
- Graph schema:
  - Nodes: source, decision, tool_call, resource, sink, user_approval.
  - Edges: requested_by, influenced_by, accesses, sends_to, approved_by.
  - Labels: trust, sensitivity, reversibility, user_intent_match, permission scope.
- Detector / algorithm: graph query rules, risk scoring, thresholded approval policy.
- Baselines to compare: all-tools allowed, tool allowlist, static permission manifest, LLM safety judge.

### Experiments

- Benchmark / dataset candidates: AgentDojo, MSB, AgentDyn, SafeClawBench.
- Experimental setup: 같은 agent task를 여러 policy로 실행하고 공격 차단률과 정상 task 성공률을 비교한다.
- Metrics: attack success rate, normal task success rate, approval burden, false block rate, average decision latency.
- Baseline comparisons: allowlist, deny risky tools, LLM judge, content-aware traffic detector.
- Ablation study: user intent edge 제거, sensitivity label 제거, approval state 제거.
- Expected result: graph policy가 allowlist보다 정상 utility를 더 유지할 수 있다.
- Failure cases to check: 사용자가 실제로 위험한 작업을 요청한 경우, policy가 과도하게 approval을 요구하는 경우.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: user intent를 자동으로 판별하는 부분에서 오류가 날 수 있다.
- First experiment: YAML rule 5개로 AgentDojo attack 10개를 재평가한다.
- Next implementation step: graph query evaluator와 decision logger를 만든다.

## Idea 5. Cross-Benchmark Agent Security Trace Format

### Easy Explanation

- One-line summary: AgentDojo, AgentDyn, MSB, SafeClawBench 같은 benchmark의 실행 기록을 하나의 graph trace format으로 통일한다.
- Intuition: 지금은 benchmark마다 로그 형식이 달라 detector를 옮겨 실험하기 어렵다. 공통 포맷이 있으면 detector 재현성과 비교가 쉬워진다.
- Example scenario: AgentDojo의 email tool task와 SafeClawBench의 malicious skill task를 같은 `nodes/edges/labels` JSONL로 변환한다.

### Six Ws and H

- Who: agent security 연구자, benchmark maintainers, detector 개발자.
- What: cross-benchmark provenance graph trace schema와 converters.
- When: benchmark 실행 후 log export 단계.
- Where: AgentDojo, AgentDyn, MSB, SafeClawBench, MalSkillBench.
- Why: detector가 특정 benchmark logging format에 overfit되는 문제를 줄이기 위해.
- How: 각 benchmark의 native log를 공통 graph schema로 변환하고 validation suite를 제공한다.

### Research Framing

- Hypothesis: 공통 graph trace format은 detector 비교의 재현성을 높이고, cross-benchmark generalization 평가를 가능하게 한다.
- Motivation: agent security benchmark가 빠르게 늘지만, 실험 artifact 호환성이 낮으면 연구 축적이 어렵다.
- Existing problems in prior work:
  - Problem 1:
    - Source: AgentDyn
    - URL: https://arxiv.org/abs/2602.03117
    - Why it is not enough: 자동 dataset generation은 유용하지만, 다른 benchmark와 같은 trace schema로 비교하는 문제는 별도다.
  - Problem 2:
    - Source: SafeClawBench
    - URL: https://huggingface.co/datasets/sairights/safeclawbench
    - Why it is not enough: runtime verification data가 있어도 AgentDojo/MSB의 tool-call trace와 바로 합치려면 schema alignment가 필요하다.
- Proposed contribution: Agent Security Provenance Trace Format과 reference converters.
- Why this could be novel: 단일 detector 논문보다 community artifact 성격이 강하며, 후속 graph detector 연구의 기반이 될 수 있다.

### Methodology

- Required data: benchmark native logs, task metadata, attack labels, tool schemas, runtime side-effect logs.
- System design: converter adapters가 각 benchmark log를 canonical graph JSONL로 변환하고, validator가 required fields를 검사한다.
- Implementation steps:
  1. canonical schema v0.1을 정의한다.
  2. AgentDojo converter를 만든다.
  3. MSB/MCP converter를 만든다.
  4. SafeClawBench syscall/runtime converter를 만든다.
  5. sample detectors를 schema 위에서 실행한다.
- Graph schema:
  - Nodes: actor, prompt, observation, tool, action, resource, process, network, outcome.
  - Edges: contains, observes, decides, invokes, accesses, transforms, transmits, violates.
  - Labels: benchmark, task_id, attack_id, trust, sensitivity, timestamp, ground_truth.
- Detector / algorithm: schema validation, graph normalization, cross-benchmark feature extraction.
- Baselines to compare: benchmark-native detectors, event sequence model without normalization, prompt-only classifier.

### Experiments

- Benchmark / dataset candidates: AgentDojo, AgentDyn, MSB, SafeClawBench, MalSkillBench, MCPTox `freshness 확인 필요`.
- Experimental setup: detector를 AgentDojo에서 tune하고 MSB/SafeClawBench에서 zero-shot 평가한다.
- Metrics: cross-benchmark F1, schema coverage, conversion loss rate, runtime overhead, reproducibility score.
- Baseline comparisons: native log only, CSV event sequence, prompt-only trace.
- Ablation study: runtime side-effect fields 제거, trust labels 제거, benchmark metadata 제거.
- Expected result: canonical graph schema가 detector transfer를 쉽게 만들고, 어떤 benchmark에서 정보가 부족한지 명확히 드러낸다.
- Failure cases to check: benchmark가 LLM internal state를 기록하지 않는 경우, timestamp alignment가 어려운 경우, syscall data가 너무 커지는 경우.

### Practical Plan

- Expected difficulty: Medium
- Risk / limitation: 각 benchmark의 license와 log access 방식이 다를 수 있다.
- First experiment: AgentDojo 5개 trace를 canonical JSONL로 변환한다.
- Next implementation step: schema validator와 minimal visualization을 만든다.

## Experiment Backlog

### Easy

- AgentDojo task 5개를 실행해 tool-call event JSONL을 만든다.
- `untrusted_source -> sensitive_sink` rule detector를 구현한다.
- Graph node/edge taxonomy를 AuthGraph, AgentArmor, MindGuard 기준으로 비교표화한다.
- MSB repository의 task/server 구조를 읽고 MCP event field 후보를 정리한다.

### Medium

- AgentDojo와 AgentDyn trace를 같은 graph schema로 변환한다.
- toy MCP poisoned tool server를 만들고 MindGuard식 attribution score를 계산한다.
- graph policy engine을 YAML rule 기반으로 만들고 allow/deny/approval을 실험한다.
- SafeClawBench 또는 MalSkillBench 샘플을 실행해 runtime event를 graph에 붙인다.

### Hard

- Docker/strace 기반 coding-agent sandbox collector를 구현한다.
- benign/malicious package install trace dataset을 구축한다.
- graph neural network 또는 temporal graph classifier baseline을 학습한다.
- cross-benchmark zero-shot generalization 평가를 수행한다.

## Possible Paper Angle

- "Provenance Graphs for Detecting Malicious Tool Use in LLM Agents": AgentDojo/MSB/SafeClawBench를 공통 graph trace format으로 변환하고, source-to-sink detector가 prompt-only/content-only baseline보다 indirect injection과 tool poisoning을 더 잘 잡는지 평가한다.
- "Runtime Evidence Beats Prompt Filtering": coding agent package install attack에서 agent-level logs와 syscall provenance를 결합해 malicious package/skill detection을 수행한다.
- "Attributing MCP Tool Poisoning with Decision Dependence Graphs": poisoned tool description에서 harmful outcome까지의 causal path를 찾아 detection뿐 아니라 attribution metric을 제안한다.

## Next Research Question

- LLM agent에서 "influence edge"를 얼마나 정확하게, 얼마나 싸게 만들 수 있는가? 완전한 causal attribution이 어렵다면, conservative taint propagation만으로도 실제 공격 차단에 충분한가?
- Graph policy가 정상 작업을 막지 않으려면 user intent를 어떻게 표현해야 하는가?
- MCP server/tool description의 trust를 runtime provenance graph에 어떤 라벨로 넣어야 가장 재사용 가능한가?
