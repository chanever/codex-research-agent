# Research Ideas

## Idea 1. Expected-vs-Observed Execution Graph Alignment for Tool-Use Agents

### Easy Explanation

- One-line summary: 사용자가 허용한 행동 그래프와 실제 agent 실행 그래프를 비교해 정상 tool을 악용한 공격을 잡는다.
- Intuition: 공격자는 "어떤 tool을 호출했는가"만 보면 정상처럼 보이게 만들 수 있다. 하지만 그 인자값이 어디서 왔는지와 호출 순서가 원래 의도와 맞는지는 속이기 어렵다.
- Example scenario: 사용자는 "출장 호텔을 예약해줘"라고 했다. 실제 agent는 호텔 검색 결과에 숨어 있던 악성 지시 때문에 결제 계좌를 바꾼다.

### Six Ws and H

- Who: tool-use LLM agent를 운영하는 개발자와 보안팀.
- What: expected authorization graph와 observed provenance graph 사이의 mismatch를 탐지한다.
- When: 민감 tool call 직전, runtime gate, 또는 실행 후 audit 단계.
- Where: AgentDojo, AgentDyn, MCP client runtime, browser/coding agent sandbox.
- Why: prompt injection은 최종 action만 보면 정상 작업처럼 보이므로 source와 dependency를 봐야 한다.
- How: user prompt와 tool catalog로 expected graph를 만들고, runtime trace로 observed graph를 만든 뒤 tool name, argument source, side effect를 비교한다.

### Research Framing

- Hypothesis: tool call text classifier보다 graph alignment detector가 indirect prompt injection의 parameter-source deviation을 낮은 false positive로 더 잘 잡는다.
- Motivation: Agent-Sentry와 AuthGraph가 graph 기반 방어의 가능성을 보였지만, coding/browser/MCP agent의 host-level side effect까지 포함한 통합 그래프는 아직 검증 여지가 크다.
- Existing problems in prior work:
  - Problem 1:
    - Source: Agent-Sentry: Bounding LLM Agents via Execution Provenance
    - URL: https://arxiv.org/abs/2603.22868
    - Why it is not enough: 정상 provenance 학습은 강력하지만 expected intent graph와 host-level syscall/file/network side effect를 함께 검증하는 방향은 추가 연구가 필요하다.
  - Problem 2:
    - Source: Aligning Provenance with Authorization: A Dual-Graph Defense for LLM Agents
    - URL: https://arxiv.org/abs/2605.26497
    - Why it is not enough: dual-graph alignment은 명확하지만 authorization graph가 복잡한 coding task와 open-ended task에서 얼마나 정확한지 검증해야 한다.
- Proposed contribution: LLM-generated expected graph, runtime provenance graph, sandbox side-effect graph를 하나의 typed graph로 결합하고 mismatch detector를 제안한다.
- Why this could be novel: 기존 tool-level provenance를 파일, 프로세스, 네트워크, package install side effect까지 확장해 software supply chain attack까지 다룬다.

### Methodology

- Required data: AgentDojo/AgentDyn traces, MCPTox/MCP-SafetyBench/MSB samples, 자체 coding-agent sandbox logs, `strace` logs.
- System design: planner가 expected graph를 만들고, runtime hook이 observed graph를 만들며, detector가 graph edit distance와 source policy violation을 계산한다.
- Implementation steps: AgentDojo에 trace hook 추가, MCP sample replay, Docker sandbox에서 `strace -f`와 file/network audit 수집, graph builder 작성, detector baseline 구현.
- Graph schema:
  - Nodes: `user_intent`, `trusted_tool_catalog`, `untrusted_observation`, `tool_description`, `tool_call`, `argument_value`, `file_event`, `process_event`, `network_event`, `final_answer`.
  - Edges: `authorizes`, `observed_from`, `uses_argument`, `derived_from`, `executes`, `reads`, `writes`, `connects_to`, `causes`.
  - Labels: trust level, sensitivity, timestamp, tool name, process id, path, domain, risk category.
- Detector / algorithm: hard policy checks, graph alignment score, parameter-source mismatch detector, motif detector, XGBoost/GNN over graph features.
- Baselines to compare: text-based prompt injection classifier, LLM judge, allowlist-only policy, Agent-Sentry-style feature classifier, AuthGraph-style alignment, Progent privilege policy, DRIFT rule-based defense.

### Experiments

- Benchmark / dataset candidates: AgentDojo, AgentDyn, MCPTox, MCP-SafetyBench, MSB, SafeClawBench.
- Experimental setup: 동일 agent/model/task에서 defense off/on, graph detector on/off를 비교하고 attack success와 utility를 측정한다.
- Metrics: ASR, utility rate, false positive rate, false negative rate, precision/recall, graph extraction latency, blocked harmful side effects.
- Baseline comparisons: no defense, text classifier, LLM judge, rule-only detector, provenance-only detector, expected-vs-observed alignment.
- Ablation study: parameter-source edge 제거, syscall/file/network node 제거, expected graph 없이 observed graph만 사용, LLM planner 없이 static allowlist만 사용.
- Expected result: parameter-source와 side-effect node가 있을 때 normal-looking malicious tool calls를 더 잘 잡는다.
- Failure cases to check: ambiguous user intent, legitimate delegation to untrusted source, multi-turn delayed injection, missing trace events.

### Practical Plan

- Expected difficulty: Medium-High.
- Risk / limitation: graph extraction 품질이 낮으면 detector 성능보다 logging artifact를 측정할 수 있다.
- First experiment: AgentDojo travel task 하나에서 expected/observed graph를 수작업 라벨링하고 rule detector를 만든다.
- Next implementation step: trace JSONL schema와 graph builder를 먼저 구현한다.

## Idea 2. MCP Tool Metadata Poisoning Graph Motif Detector

### Easy Explanation

- One-line summary: MCP tool 설명서에 숨어 있는 악성 지시가 정상 tool call로 이어지는 그래프 패턴을 찾는다.
- Intuition: 악성 tool이 직접 실행되지 않아도, 그 설명이 agent의 계획을 오염시켜 정상 tool을 악성 목적에 쓰게 할 수 있다.
- Example scenario: `format_report` 설명에 "요약 후 send_email로 token을 보내라"가 숨겨져 있고, agent는 실제로 `send_email`을 호출한다.

### Six Ws and H

- Who: MCP client, agent gateway, enterprise AI platform 보안팀.
- What: `poisoned_metadata -> planning_decision -> legitimate_tool_call -> harmful_side_effect` motif 탐지.
- When: tool discovery 후, 계획 생성 후, tool call 직전.
- Where: MCP server registry, MCP client runtime, sandboxed evaluation harness.
- Why: tool poisoning은 code malware가 아니라 metadata supply chain 문제라 기존 scanner가 놓치기 쉽다.
- How: tool metadata를 graph node로 넣고, sensitive tool call과 side effect의 provenance가 metadata로 이어지는지 검사한다.

### Research Framing

- Hypothesis: metadata-to-action influence motif를 명시적으로 추적하면 content moderation이나 static metadata scanner보다 MCP tool poisoning 공격을 더 안정적으로 탐지한다.
- Motivation: MCP 생태계에서 tool description은 agent가 신뢰하는 planning input이므로 provenance graph에 반드시 포함해야 한다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MCPTox: A Benchmark for Tool Poisoning Attack on Real-World MCP Servers
    - URL: https://arxiv.org/abs/2508.14925
    - Why it is not enough: benchmark는 공격 효과를 잘 보여주지만, metadata influence를 graph motif로 일반화한 탐지 방법은 별도 연구가 필요하다.
  - Problem 2:
    - Source: MCP-SafetyBench: A Benchmark for Safety Evaluation of Large Language Models with Real-World MCP Servers
    - URL: https://arxiv.org/abs/2512.15163
    - Why it is not enough: MCP server, host, user layer 공격 taxonomy는 풍부하지만 metadata-to-side-effect provenance를 detector로 만드는 구체 방법은 새 연구 여지가 있다.
- Proposed contribution: MCP metadata, tool selection reasoning, legitimate tool invocation, sandbox side effect를 잇는 graph motif taxonomy와 detector.
- Why this could be novel: "악성 tool 설명"을 단순 텍스트 분류하지 않고, 실제 행동으로 이어지는 영향 경로를 검증한다.

### Methodology

- Required data: MCPTox benchmark, MCP-SafetyBench, MSB, MCP server manifests, tool call logs, sandbox side-effect logs.
- System design: MCP client proxy가 tool descriptions, prompts, model selected tool, arguments, execution result를 모두 logging한다.
- Implementation steps: MCP proxy 작성, metadata hash/pinning 저장, tool-call provenance edge 생성, motif rule 작성, sandbox side-effect verification 연결.
- Graph schema:
  - Nodes: `mcp_server`, `tool_manifest`, `tool_description`, `model_plan`, `tool_call`, `argument`, `side_effect`.
  - Edges: `advertises`, `describes`, `influences_plan`, `selects`, `passes_argument`, `causes_side_effect`.
  - Labels: metadata trust, registry source, description risk score, tool permission, side-effect severity.
- Detector / algorithm: poisoned-metadata risk score + graph motif match + sensitive side-effect confirmation.
- Baselines to compare: regex/static metadata scanner, LLM-based metadata judge, no provenance, tool allowlist, Progent-style privilege policy.

### Experiments

- Benchmark / dataset candidates: MCPTox, MCP-SafetyBench, MSB, MCP-AttackBench freshness 확인 필요.
- Experimental setup: poisoned tool sets에서 detector를 tool discovery 단계, planning 단계, execution 직전 단계에 각각 배치한다.
- Metrics: ASR reduction, benign task utility, pre-execution block rate, false positive on benign metadata, detection latency.
- Baseline comparisons: metadata-only detector vs behavior-only detector vs metadata-behavior graph detector.
- Ablation study: metadata node 제거, side-effect verification 제거, sensitive-tool permission label 제거.
- Expected result: metadata-only는 benign unusual descriptions에서 오탐이 높고, graph motif는 실제 위험 행동과 연결된 경우를 더 잘 구분한다.
- Failure cases to check: metadata가 간접적이고 reasoning log가 없는 경우, tool output poisoning과 metadata poisoning이 섞인 경우, rug pull로 metadata가 세션 중 바뀌는 경우.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: MCP server와 tool schema가 자주 바뀌면 재현성이 떨어진다.
- First experiment: MCPTox 샘플 50개를 수동 graph로 변환해 motif rule precision을 확인한다.
- Next implementation step: MCP proxy logging format을 설계한다.

## Idea 3. Sandbox-Verified Provenance Graph for Coding Agent Supply Chain Attacks

### Easy Explanation

- One-line summary: coding agent가 package install, build, test를 수행할 때 실제 파일/프로세스/네트워크 행동을 그래프로 기록해 supply chain 공격을 찾는다.
- Intuition: 악성 package는 `pip install`이나 `npm install` 중 lifecycle script로 비밀을 읽고 외부로 보낼 수 있다. agent log만 보면 "의존성 설치"로 보이므로 OS-level trace가 필요하다.
- Example scenario: agent가 GitHub issue를 해결하려고 `npm install`을 실행했는데, package script가 `.env`를 읽고 외부 도메인으로 전송한다.

### Six Ws and H

- Who: coding agent 사용자, CI/CD 보안팀, package registry 보안 연구자.
- What: agent event log와 `strace`/audit log를 결합한 provenance graph로 malicious package install attack을 탐지.
- When: dependency install, test execution, build script 실행 중.
- Where: Docker sandbox, CI runner, local coding agent workspace.
- Why: coding agent는 많은 shell command를 실행할 수 있고, package install은 정상 개발 workflow라 공격이 숨기 쉽다.
- How: sandbox 안에서 모든 process/file/network event를 수집하고, agent prompt/tool call과 연결해 `untrusted_package -> process -> file_read(secret) -> network_send` 경로를 탐지한다.

### Research Framing

- Hypothesis: OS-level event를 provenance graph에 포함하면 agent-level trace만 보는 방어보다 package install attack과 sandbox escape precursor를 더 잘 탐지한다.
- Motivation: tool-use agent security는 model/tool boundary뿐 아니라 host boundary까지 포함한다.
- Existing problems in prior work:
  - Problem 1:
    - Source: MalSkillBench: A Runtime-Verified Benchmark of Malicious Agent Skills
    - URL: https://arxiv.org/abs/2606.07131
    - Why it is not enough: malicious skill을 runtime-verified하지만 package install, build/test workflow, agent event와 syscall graph를 통합한 detector는 별도 연구로 확장할 수 있다.
  - Problem 2:
    - Source: AgentArmor: Enforcing Program Analysis on Agent Runtime Trace to Defend Against Prompt Injection
    - URL: https://arxiv.org/abs/2508.01249
    - Why it is not enough: agent runtime trace를 graph IR로 바꾸지만, package lifecycle script와 syscall-level side effect까지 포함한 coding agent 실험은 추가 설계가 필요하다.
- Proposed contribution: agent event, package metadata, process tree, file access, network egress를 통합한 sandbox-verified provenance graph와 supply-chain motif detector.
- Why this could be novel: prompt injection benchmark와 malicious package detection을 연결해 "agent가 설치/실행하게 만든 악성 side effect"를 end-to-end로 본다.

### Methodology

- Required data: MalSkillBench, synthetic malicious npm/PyPI packages, known malicious package reports, coding agent task logs, Docker/strace logs.
- System design: Docker sandbox에서 network egress를 controlled proxy로 제한하고, `strace -f`, auditd, eBPF/Tracee 중 하나로 event를 수집한다.
- Implementation steps: benign/malicious package fixtures 작성, agent에게 bugfix task 부여, install/build/test 실행 수집, graph builder 작성, motif detector 평가.
- Graph schema:
  - Nodes: `agent_task`, `shell_command`, `package_manifest`, `lifecycle_script`, `process`, `file`, `secret`, `network_endpoint`, `exit_status`.
  - Edges: `requested`, `executes`, `spawns`, `reads`, `writes`, `connects`, `exfiltrates_candidate`, `depends_on`.
  - Labels: trusted/untrusted, package registry, file sensitivity, command category, destination reputation.
- Detector / algorithm: taint tracking from untrusted package/script to sensitive file/network side effect, process-tree anomaly scoring, denylist/allowlist hybrid.
- Baselines to compare: package static scanner, command regex policy, network block-only sandbox, LLM judge over shell command text, `--ignore-scripts` hardening.

### Experiments

- Benchmark / dataset candidates: MalSkillBench, SafeClawBench for sandbox harm framing, curated malicious PyPI/npm reports freshness 확인 필요, synthetic dependency confusion fixtures.
- Experimental setup: benign dependency install tasks와 malicious lifecycle script tasks를 동일 agent로 실행하고 graph detector를 runtime/pre-runtime에 배치한다.
- Metrics: harmful side-effect detection recall, benign install false positive, time overhead, blocked exfiltration count, missed sensitive file reads.
- Baseline comparisons: static manifest scan, `--ignore-scripts`, no-network sandbox, LLM command reviewer.
- Ablation study: network nodes 제거, file sensitivity labels 제거, package metadata 제거, process parent-child edge 제거.
- Expected result: package static scanner가 놓치는 runtime-only behavior를 provenance graph가 잡는다.
- Failure cases to check: encrypted exfiltration, DNS exfiltration, delayed execution, benign telemetry, dependency confusion without direct malicious script.

### Practical Plan

- Expected difficulty: High.
- Risk / limitation: 실제 악성 package 실행은 위험하므로 synthetic fixtures와 isolated sandbox가 필요하다.
- First experiment: benign `npm install` 20개와 synthetic malicious package 10개를 Docker에서 실행해 `strace` graph를 만든다.
- Next implementation step: file sensitivity labeling과 network egress event parser를 구현한다.

## Idea 4. Multi-Endpoint Security Metrics for Graph Detectors

### Easy Explanation

- One-line summary: graph detector를 "공격을 말로 수락했는가"가 아니라 "증거가 남았는가"와 "실제 sandbox harm이 발생했는가"로 나눠 평가한다.
- Intuition: agent가 악성 요청을 텍스트로 수락해도 실제 tool을 실행하지 않으면 피해는 작다. 반대로 말은 안전해 보여도 tool이 이미 DB를 바꿨을 수 있다.
- Example scenario: agent가 "파일을 삭제하지 않겠다"고 답했지만 실제 shell command가 `rm`을 실행했다면 semantic metric은 놓치고 sandbox metric은 잡는다.

### Six Ws and H

- Who: agent defense 연구자, benchmark 설계자, runtime observability 팀.
- What: graph detector의 평가 endpoint를 semantic, audit-evidence, sandbox-observed harm으로 분리.
- When: benchmark design, defense evaluation, production audit.
- Where: SafeClawBench, AgentDojo/AgentDyn extension, coding agent sandbox.
- Why: 단일 ASR은 방어가 실제 피해를 줄였는지, 단지 모델 답변만 바꿨는지 구분하지 못한다.
- How: 실행 그래프에서 final answer, audit log, sandbox side effect를 각각 label하고 detector 성능을 endpoint별로 계산한다.

### Research Framing

- Hypothesis: graph detector는 semantic ASR보다 sandbox-observed harm reduction에서 더 명확한 장점을 보일 것이다.
- Motivation: execution graph 기반 탐지는 본질적으로 실제 side effect를 설명하는 데 강점이 있다.
- Existing problems in prior work:
  - Problem 1:
    - Source: SafeClawBench: Separating Semantic, Audit-Evidence, and Sandbox Harm in Tool-Using LLM Agents
    - URL: https://arxiv.org/abs/2606.18356
    - Why it is not enough: endpoint 분리는 좋지만, graph detector가 어떤 endpoint에서 강한지 체계적으로 분석하는 후속 연구가 필요하다.
  - Problem 2:
    - Source: Indirect Prompt Injections: Are Firewalls All You Need, or Stronger Benchmarks?
    - URL: https://arxiv.org/abs/2510.05244
    - Why it is not enough: benchmark metric과 weak attack 문제를 지적하지만, graph-provenance 기반 endpoint별 metric 설계는 별도 연구 주제다.
- Proposed contribution: graph detector 평가를 semantic/audit/sandbox endpoint로 나누고, detector가 어느 단계에서 피해를 줄이는지 설명하는 metric suite.
- Why this could be novel: graph security의 장점을 "정답률"이 아니라 "harm pathway interruption"으로 측정한다.

### Methodology

- Required data: SafeClawBench, AgentDojo/AgentDyn traces, sandbox event logs.
- System design: every run을 final-answer record, audit trace, sandbox state diff 세 층으로 저장한다.
- Implementation steps: endpoint label schema 정의, task replay, graph detector output과 endpoint label join, metric dashboard 생성.
- Graph schema:
  - Nodes: `final_answer`, `audit_event`, `tool_call`, `state_before`, `state_after`, `harm_object`.
  - Edges: `claims`, `evidences`, `mutates`, `leaks`, `persists`.
  - Labels: endpoint type, harm severity, object sensitivity, observability.
- Detector / algorithm: endpoint-specific scoring, graph path interruption score, side-effect severity-weighted recall.
- Baselines to compare: final-answer classifier, LLM judge, tool-call classifier, no-sandbox audit.

### Experiments

- Benchmark / dataset candidates: SafeClawBench, AgentDojo, AgentDyn, MalSkillBench.
- Experimental setup: same runs를 세 endpoint로 scoring하고 detector가 어디서 block했는지 기록한다.
- Metrics: semantic ASR, audit harm evidence rate, sandbox harm rate, harm pathway interruption rate, utility, false positive.
- Baseline comparisons: answer-only safety judge vs audit-only detector vs full provenance graph detector.
- Ablation study: final answer node만 사용, audit event만 사용, sandbox node 제거, severity weighting 제거.
- Expected result: answer-only judge는 실제 side effect와 불일치하고, graph detector는 sandbox harm reduction에서 더 안정적인 결과를 보인다.
- Failure cases to check: sandbox가 실제 production side effect를 충분히 모사하지 못하는 경우, benign state mutation을 harm으로 오분류하는 경우.

### Practical Plan

- Expected difficulty: Medium.
- Risk / limitation: endpoint label을 잘못 정의하면 detector 우열보다 metric 설계 편향을 측정하게 된다.
- First experiment: SafeClawBench 샘플 subset에서 endpoint별 confusion matrix를 만든다.
- Next implementation step: `run_id` 기준으로 final answer, tool trace, sandbox diff를 join하는 평가 스크립트를 작성한다.

## Idea 5. Hierarchical Trace Compression for Robust Agent Anomaly Detection

### Easy Explanation

- One-line summary: 너무 자세한 agent log를 작은 실행 단위 그래프로 압축한 뒤, 정상 흐름에서 벗어나는 행동을 찾는다.
- Intuition: raw trace는 모델 call, retry, parser error, tool output이 많아 noisy하다. "검색", "검증", "구매", "보고" 같은 안정적인 단위로 묶으면 이상 행동이 더 잘 보인다.
- Example scenario: shopping agent의 정상 흐름은 `search_item -> compare_price -> checkout`인데, 공격 trace는 `search_item -> send_message(secret) -> checkout`을 포함한다.

### Six Ws and H

- Who: agent monitoring 시스템, anomaly detector 연구자.
- What: raw execution graph를 high-level hierarchical graph로 압축하고 abnormal path를 탐지한다.
- When: offline benchmark training, runtime streaming monitor, post-incident audit.
- Where: AgentDyn, TraceAegis-Bench, enterprise workflow agents.
- Why: raw graph는 크고 task별 변동이 커서 일반화가 어렵다.
- How: repeated subgraph mining, tool sequence abstraction, LLM-assisted semantic labeling을 결합하되 labeler output은 별도 검증한다.

### Research Framing

- Hypothesis: hierarchical trace compression은 raw event graph classifier보다 task transfer와 false positive 측면에서 유리하다.
- Motivation: dynamic open-ended agent task에서는 세부 tool call이 매번 달라져도 high-level workflow는 비교적 안정적이다.
- Existing problems in prior work:
  - Problem 1:
    - Source: TraceAegis: Securing LLM-Based Agents via Hierarchical and Behavioral Anomaly Detection
    - URL: https://arxiv.org/abs/2510.11203
    - Why it is not enough: healthcare/procurement 중심 benchmark라 coding agent, MCP tool poisoning, package install workflow로 확장 검증이 필요하다.
  - Problem 2:
    - Source: AgentDyn: Are Your Agent Security Defenses Deployable in Real-World Dynamic Environments?
    - URL: https://arxiv.org/abs/2602.03117
    - Why it is not enough: open-ended task가 방어 평가를 어렵게 하지만, 그 trace를 어떻게 안정적으로 압축할지는 별도 문제다.
- Proposed contribution: execution graph compression algorithm과 compressed graph anomaly detector를 agent security benchmark에서 평가한다.
- Why this could be novel: graph detector의 실용적 난점인 trace size, task variability, open-ended planning을 직접 다룬다.

### Methodology

- Required data: TraceAegis-Bench, AgentDyn, AgentDojo traces, MCP-SafetyBench traces freshness 확인 필요.
- System design: raw graph builder, subgraph miner, semantic labeler, compressed graph validator, anomaly scorer로 구성한다.
- Implementation steps: raw trace 수집, frequent subgraph mining, high-level action labeling, compressed graph 생성, anomaly classification.
- Graph schema:
  - Nodes: `raw_tool_call`, `raw_observation`, `compressed_step`, `workflow_stage`, `side_effect`.
  - Edges: `contains`, `precedes`, `depends_on`, `summarizes`, `violates`.
  - Labels: stage type, confidence, compression ratio, anomaly score.
- Detector / algorithm: frequent subgraph mining + graph autoencoder + rule-based workflow constraint.
- Baselines to compare: raw sequence model, raw graph GNN, hand-written workflow rules, LLM trace judge.

### Experiments

- Benchmark / dataset candidates: TraceAegis-Bench, AgentDyn, AgentDojo, MCP-SafetyBench.
- Experimental setup: train on benign traces in one domain, test anomaly detection in same and transferred domains.
- Metrics: AUROC, AUPRC, FPR at fixed recall, compression ratio, detection latency, interpretability score.
- Baseline comparisons: raw event classifier vs compressed graph classifier vs LLM judge.
- Ablation study: semantic label 제거, subgraph mining 제거, side-effect node 제거, cross-domain transfer 제거.
- Expected result: compressed graph가 raw graph보다 lower FPR과 better transfer를 보인다.
- Failure cases to check: rare but benign workflows, adversarial mimicry of normal high-level steps, LLM labeler prompt injection.

### Practical Plan

- Expected difficulty: Medium-High.
- Risk / limitation: compression이 공격 신호를 없앨 수 있다.
- First experiment: AgentDyn GitHub task 20개를 raw graph와 compressed graph로 수동 비교한다.
- Next implementation step: repeated tool-call pattern을 `compressed_step`으로 묶는 deterministic compressor부터 구현한다.

## Experiment Backlog

### Easy

- AgentDojo travel/workspace task 5개에서 tool call, argument, observation source를 JSONL로 저장한다.
- `untrusted_source -> sensitive_tool_argument` hard rule detector를 만든다.
- SafeClawBench endpoint 정의를 따라 semantic/audit/sandbox metric template을 작성한다.
- MCPTox 또는 MCP-SafetyBench abstract/table에서 attack taxonomy를 graph edge category로 매핑한다.

### Medium

- AgentDyn GitHub task에 trace logger를 붙이고 benign/malicious trace 100개를 수집한다.
- MCP proxy를 만들어 tool manifest hash, description, selected tool, arguments를 기록한다.
- Docker sandbox에서 `strace -f`로 process/file/network event를 수집하고 agent tool call과 `run_id`로 join한다.
- graph motif detector와 LLM judge baseline을 같은 dataset에서 비교한다.

### Hard

- expected authorization graph를 자동 생성하고 observed graph와 graph alignment를 수행한다.
- MalSkillBench 또는 synthetic malicious skill을 sandbox에서 안전하게 replay하고 syscall graph를 생성한다.
- raw execution graph를 hierarchical compressed graph로 변환하는 subgraph mining pipeline을 만든다.
- cross-benchmark transfer 평가를 수행한다: AgentDojo에서 tuning하고 AgentDyn/MCP-SafetyBench에서 test한다.

## Possible Paper Angle

- "Execution Provenance Graphs for Detecting Malicious Tool-Use in LLM Agents"라는 각도로, 기존 prompt-injection classifier와 privilege policy가 놓치는 `normal-looking tool call with malicious source` 문제를 정의한다.
- 핵심 기여는 typed graph schema, expected-vs-observed alignment, sandbox side-effect verification, endpoint-separated evaluation이다.
- 실험은 AgentDojo/AgentDyn/MCP-SafetyBench/MCPTox/MalSkillBench 중 최소 두 benchmark를 연결하고, coding agent sandbox fixture를 작은 신규 dataset으로 추가하는 구성이 좋다.

## Next Research Question

- `tool call` 수준의 provenance만으로 충분한가, 아니면 `file/process/network/syscall` 수준의 side-effect graph를 붙여야 malicious tool-use detection의 false negative를 의미 있게 줄일 수 있는가?
