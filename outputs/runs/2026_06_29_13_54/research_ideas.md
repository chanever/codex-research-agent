# Research Ideas

## Idea 1. Dual-Layer Execution Graph for Agent and Sandbox Events

- Hypothesis: LLM agent의 tool-call provenance graph와 Docker sandbox의 syscall/event graph를 함께 사용하면, prompt-only 또는 tool-call-only detector보다 malicious tool-use를 더 잘 탐지할 수 있다.
- Motivation: SafeClawBench는 semantic acceptance와 sandbox-observed harm이 다를 수 있음을 보여준다. ARGUS/AuthGraph는 agent-level provenance를 잘 다루지만 OS-level harm 증거는 상대적으로 약하다.
- Required data: agent conversation/tool traces, tool-call arguments, retrieved content spans, Docker file/process/network events, strace logs, benign/malicious task labels.
- Method: tool call, argument, observation, file path, process, network destination을 typed node로 만들고, provenance edge와 syscall edge를 시간순 heterogeneous graph로 병합한다.
- Evaluation: semantic attack acceptance, audit-visible harm, sandbox-observed harm 각각에 대해 AUROC, F1, false positive per task, detection latency를 측정한다.
- Expected difficulty: Medium
- Risk / limitation: syscall trace가 너무 noisy할 수 있고, legitimate package install이나 test execution을 악성으로 오탐할 위험이 있다.
- Connection to execution graph: agent action sequence와 sandbox event sequence를 하나의 execution graph로 결합한다.
- Connection to provenance: tool-call argument가 어떤 untrusted span에서 왔는지, 그 argument가 어떤 file/process/network event로 이어졌는지 추적한다.
- Connection to sandbox verification: Docker/strace 관측을 harm endpoint로 사용한다.
- First experiment: AgentDojo 또는 간단한 coding-agent task 20개를 Docker에서 실행해 `open`, `execve`, `connect`, `write` event를 수집하고 tool-call trace와 timestamp로 join한다.

## Idea 2. Authorization Graph vs Observed Execution Graph for Coding Agents

- Hypothesis: user intent에서 추출한 authorization graph와 실제 coding-agent execution graph를 비교하면 credential exfiltration, unauthorized package install, hidden network egress를 설명 가능한 방식으로 탐지할 수 있다.
- Motivation: AuthGraph의 dual-graph idea를 coding agent와 CI/CD agent에 적용하면 "허용된 작업"과 "실제로 한 작업"의 mismatch가 명확해진다.
- Required data: user issue/PR request, repository files, agent tool calls, GitHub Actions logs, secret access attempts, network events.
- Method: user request에서 허용된 resources/actions를 추출해 authorization graph를 만들고, 실제 file/process/network/tool graph와 typed graph alignment를 수행한다.
- Evaluation: attack scenario별 graph violation recall, benign coding task false positive, human-auditable explanation quality.
- Expected difficulty: Medium
- Risk / limitation: natural-language intent에서 authorization graph를 자동 생성할 때 ambiguity가 크다.
- Connection to execution graph: observed graph는 code edit, command execution, test, package install, network call을 포함한다.
- Connection to provenance: 각 action의 source evidence를 user request, repository file, tool output 중 어디에서 왔는지 표시한다.
- Connection to sandbox verification: observed graph는 sandbox에서 검증된 file/network/process event로 보강한다.
- First experiment: `fix failing test`와 `update docs` 같은 benign tasks에 허용 action templates를 수동 작성하고, malicious hidden instruction이 `.md`, issue body, CI config에 있을 때 graph deviation을 측정한다.

## Idea 3. Argument-Level Provenance for Package Install Attacks

- Hypothesis: package install command의 package name, version, registry URL, postinstall behavior에 대한 argument provenance를 추적하면 typo-squatting, dependency confusion, prompt-injected install attack을 조기에 차단할 수 있다.
- Motivation: coding agents는 error 해결 과정에서 `pip install`, `npm install`, `uv add` 같은 command를 실행한다. malicious package detection은 static package analysis뿐 아니라 "왜 이 package를 설치했는가"라는 provenance가 필요하다.
- Required data: coding-agent terminal traces, package manager logs, lockfiles, repository manifests, model reasoning/tool call arguments, package metadata.
- Method: install command의 각 token을 provenance unit으로 분리하고, user request/repo manifest/error log와 연결되지 않는 package argument를 suspicious edge로 표시한다.
- Evaluation: malicious install recall, benign dependency update precision, install-before-approval detection latency.
- Expected difficulty: Medium
- Risk / limitation: agent가 legitimate troubleshooting으로 새 package를 탐색할 수 있어 policy가 과도하면 utility가 낮아진다.
- Connection to execution graph: install command, package manager subprocess, network registry access, lockfile write를 graph path로 표현한다.
- Connection to provenance: package name이 untrusted web page, README injection, tool output, hallucination 중 어디서 왔는지 추적한다.
- Connection to sandbox verification: install 후 `postinstall` script, file writes, network egress를 sandbox event로 검증한다.
- First experiment: npm/pip typo-squatting dummy package registry를 로컬로 만들고, malicious README prompt가 agent에게 설치를 유도하는지 trace한다.

## Idea 4. MCP Tool Shadowing Detector

- Hypothesis: MCP client에 여러 server가 연결된 상황에서 tool metadata 간 cross-server influence edge를 만들면, malicious server가 trusted tool의 behavior를 shadowing하는 공격을 탐지할 수 있다.
- Motivation: Invariant Labs의 MCP tool poisoning writeup과 MCPTox/MCP-ITP는 tool metadata가 실행 전부터 model context를 오염시킬 수 있음을 보여준다.
- Required data: MCP server tool descriptions, tool schemas, user-visible approval text, model-visible full tool metadata, actual tool calls, cross-server resource access.
- Method: tool description 안에서 다른 server/tool/resource를 지칭하는 reference를 추출하고, untrusted metadata가 high-privilege trusted tool call에 영향을 주는 path를 score한다.
- Evaluation: MCPTox/MCP-ITP-style poisoned tools에서 ASR reduction, benign multi-server workflow false positive, user approval UI coverage.
- Expected difficulty: Easy to Medium
- Risk / limitation: natural-language description의 benign cross-tool documentation과 malicious shadowing을 구분하기 어렵다.
- Connection to execution graph: graph node는 MCP server, tool, metadata span, tool call, resource이며 edge는 "describes", "references", "invokes", "reads"이다.
- Connection to provenance: trusted tool call argument가 malicious tool metadata span에서 유래했는지 추적한다.
- Connection to sandbox verification: MCP server 실행을 container 안에 격리하고 file/network access를 관측한다.
- First experiment: two-server MCP toy setup을 만들고 malicious `add` tool description이 trusted `send_email` tool recipient를 바꾸도록 한 뒤, metadata-reference graph rule로 탐지한다.

## Idea 5. Trace Unit Mining for Normal Agent Workflows

- Hypothesis: 정상 agent task traces에서 반복되는 hierarchical trace unit을 학습하면, unseen prompt injection이나 tool poisoning이 execution order/semantic consistency를 깨는 순간을 탐지할 수 있다.
- Motivation: TraceAegis는 rule을 모두 수작업으로 만들기 어렵다는 문제를 hierarchical behavior abstraction으로 해결하려 한다.
- Required data: benign agent traces across coding, browser, email, procurement tasks; malicious variants with injected instructions; task success labels.
- Method: tool sequence를 macro-unit으로 segment하고, unit 간 allowed transition과 required evidence condition을 mining한다. 이후 graph path가 learned constraint를 위반하면 anomaly로 표시한다.
- Evaluation: unseen attack family generalization, task family transfer, false alarms on legitimate alternative workflows.
- Expected difficulty: Hard
- Risk / limitation: agent behavior variance가 커서 normal model이 brittle할 수 있다.
- Connection to execution graph: trace unit은 subgraph motif이며, anomaly는 motif order/edge semantics violation이다.
- Connection to provenance: 각 unit의 precondition evidence가 trusted source에서 왔는지 확인한다.
- Connection to sandbox verification: macro-unit이 실제 file/process/network side effect와 일치하는지 sandbox event로 검증한다.
- First experiment: 50개 benign coding tasks에서 `inspect -> edit -> test` motif를 추출하고, malicious README가 `curl | sh`를 삽입하는 경우 motif violation을 탐지한다.

## Idea 6. Multi-Endpoint Labels for Agent Security Evaluation

- Hypothesis: malicious tool-use detector를 단일 attack success label로 학습하는 것보다 semantic, audit-evidence, sandbox-harm multi-endpoint label로 학습하면 더 현실적인 risk triage가 가능하다.
- Motivation: SafeClawBench는 semantic failure와 sandbox harm이 반드시 일치하지 않는다고 주장한다. 실제 운영에서는 "위험한 말을 함", "위험한 tool call을 준비함", "실제 상태 변경 발생"을 다르게 처리해야 한다.
- Required data: prompt/output transcripts, audit logs, tool-call traces, sandbox state diffs, human labels.
- Method: 각 task run에 대해 three-head classifier를 만들고, graph encoder가 endpoint별 risk score를 산출하게 한다.
- Evaluation: endpoint별 calibration, escalation policy utility, false positive cost.
- Expected difficulty: Medium
- Risk / limitation: endpoint labeling 비용이 높고, sandbox replay 환경이 실제 production과 다를 수 있다.
- Connection to execution graph: graph representation에서 endpoint별 readout head를 둔다.
- Connection to provenance: audit-evidence endpoint는 harmful argument가 어떤 source에서 왔는지 요구한다.
- Connection to sandbox verification: sandbox-harm endpoint는 실제 state diff와 syscall evidence를 기준으로 한다.
- First experiment: 30개 toy tasks에 direct injection, indirect injection, tool-return injection을 넣고 세 label을 사람이 수동 부여해 baseline classifier를 만든다.

## Experiment Backlog

### Easy

- ARGUS/AuthGraph/TraceAegis의 graph schema를 표로 정리하고 공통 node/edge vocabulary를 만든다.
- MCP toy client/server 두 개를 만들어 malicious tool description이 trusted tool call에 영향을 주는 최소 예제를 만든다.
- Docker에서 coding-agent command를 실행하며 `strace -f -e trace=file,process,network`로 event log를 수집한다.
- AgentDojo repository를 클론해 trace/log format과 custom defense hook 위치를 확인한다.

### Medium

- tool-call argument provenance logger를 구현해 user prompt, tool output, retrieved file span, memory span 간 source attribution을 저장한다.
- package install attack용 로컬 npm/pip registry와 benign/malicious dummy package corpus를 만든다.
- SafeClawBench-style semantic/audit/sandbox harm labels를 작은 coding-agent benchmark에 적용한다.
- authorization graph를 수동으로 만들고 observed execution graph와 rule-based alignment checker를 작성한다.

### Hard

- agent-level provenance graph와 strace/eBPF event graph를 병합하는 heterogeneous graph encoder를 학습한다.
- benign trace unit mining으로 task-family별 normal workflow constraints를 자동 추출한다.
- GitHub Actions ephemeral repository 환경에서 GitInject-style attack을 재현하고 CI audit log를 graph로 변환한다.
- MCP-ITP-style implicit poisoning을 자동 생성하고 detector evasion robustness를 측정한다.

## Possible Paper Angle

- "From Prompt Acceptance to Sandbox Harm: Execution-Provenance Graphs for Detecting Malicious Tool Use in LLM Coding Agents"
- 핵심 기여는 agent-level provenance와 sandbox-observed side effects를 연결한 dual-layer execution graph, semantic/audit/sandbox multi-endpoint benchmark, 그리고 package install/MCP/coding-agent 공격에 대한 explainable graph violation detector로 잡을 수 있다.
- novelty를 과장하지 않기 위해 ARGUS/AuthGraph/TraceAegis/SafeClawBench와의 차이를 명확히 해야 한다: 기존 연구가 agent trace 또는 benchmark endpoint에 집중했다면, 이 angle은 tool-call argument provenance와 OS/container-level verification을 하나의 graph로 묶는 데 초점을 둔다.

## Next Research Question

- malicious tool-use agent를 탐지할 때, "untrusted context가 high-privilege action으로 이어지는 provenance path"만으로 충분한가, 아니면 실제 sandbox side effect까지 포함해야 false positive와 false negative를 동시에 줄일 수 있는가?
