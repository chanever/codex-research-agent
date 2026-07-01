# Research Ideas

## Idea 1. MCP Tool Metadata Poisoning을 provenance graph motif로 탐지

- Hypothesis: malicious tool metadata가 실제로 호출되지 않더라도, "tool metadata node -> model decision node -> legitimate tool call node" causal path가 정상 실행보다 비정상적인 graph motif를 만든다.
- Motivation: MCPTox는 poisoned tool이 실행되지 않아도 legitimate high-privilege tool이 오용될 수 있음을 보여준다.
- Required data: MCPTox samples, MCP tools/list metadata, model prompts, tool call logs, final action labels.
- Method: tool registration metadata, visible user task, model decision, invoked tool, parameter source를 typed graph로 저장하고 poisoning-specific motif rule을 만든다.
- Evaluation: Attack Success Rate, motif recall, benign false positive, model/client별 generalization.
- Expected difficulty: Medium
- Risk / limitation: tool metadata가 prompt에 삽입되는 방식이 client마다 달라 trace normalization이 어렵다.
- Connection to research focus: execution/provenance graph가 malicious tool-use의 원인 노드를 드러내는지 직접 평가한다.
- Connection to key concepts: tool poisoning, MCP security, provenance graph, agentic workflow security.
- Connection to evaluation / validation: MCPTox와 MSB의 attack labels를 ground truth로 사용한다.
- First experiment: MCPTox 50개 샘플에서 manual graph annotation을 만들고 motif rule 5개를 작성한다.

## Idea 2. Authorization Graph와 Runtime Provenance Graph의 parameter-source alignment

- Hypothesis: tool call sequence만 보는 detector보다 parameter value의 출처를 확인하는 graph alignment가 cross-tool pollution과 indirect prompt injection을 더 잘 잡는다.
- Motivation: AuthGraph는 authorization graph와 injected reasoning graph의 분리가 parameter-source-level deviation detection에 효과적이라고 주장한다.
- Required data: AgentDojo/AgentDyn task, tool observations, tool parameters, user intent, attack labels.
- Method: user prompt와 tool catalog로 expected source_tools constraint를 만들고, runtime trace에서 parameter value가 어떤 observation에서 왔는지 approximate matching한다.
- Evaluation: ASR reduction, task utility, parameter-source violation precision/recall.
- Expected difficulty: Medium-Hard
- Risk / limitation: semantic paraphrase나 transformed values는 exact text matching으로 provenance를 잡기 어렵다.
- Connection to research focus: 실행 그래프 기반 탐지를 authorization baseline과 연결한다.
- Connection to key concepts: indirect prompt injection, provenance graph, execution graph, tool-use security.
- Connection to evaluation / validation: AgentDojo/AgentDyn의 known attacks와 benign task completion을 같이 측정한다.
- First experiment: travel/email domain에서 10개 task만 골라 source_tools constraint를 수동 작성하고 자동 matching baseline을 만든다.

## Idea 3. Coding agent의 tool-call graph와 syscall/process graph 결합

- Hypothesis: coding agent 공격은 LLM tool trace만으로는 부족하고, execve/openat/connect 같은 runtime telemetry를 결합해야 package install attack과 data exfiltration을 포착할 수 있다.
- Motivation: coding agents는 shell, package manager, test runner, browser, MCP server를 통해 실제 시스템 행동을 만든다.
- Required data: sandboxed coding-agent runs, shell command logs, strace/Falco/Tetragon events, file diffs, network attempts, benign/malicious labels.
- Method: tool_call_id 또는 시간/PID/container_id를 key로 tool-call graph와 process tree graph를 join하고, suspicious sink(secret file read, outbound connect, chmod, credential path access)를 risk edge로 표시한다.
- Evaluation: malicious run detection rate, benign developer task false positive, overhead, event loss rate.
- Expected difficulty: Hard
- Risk / limitation: eBPF/Falco/Tetragon setup이 환경 의존적이고, telemetry에 비밀 경로/파일명이 포함될 수 있다.
- Connection to research focus: execution graph를 LLM trace에서 OS-level provenance graph로 확장한다.
- Connection to key concepts: coding agent security, syscall tracing, strace, Docker sandbox, software supply chain attack.
- Connection to evaluation / validation: synthetic malicious npm/pip install attack과 benign package install을 비교한다.
- First experiment: Docker 컨테이너에서 benign `pip install`과 malicious postinstall PoC를 실행하고 strace event를 NetworkX DAG로 변환한다.

## Idea 4. Normal-behavior boundary learning vs rule-based graph motif 비교

- Hypothesis: Agent-Sentry식 benign boundary learning은 unseen benign workflows에 취약할 수 있고, motif/rule detector는 낮은 recall을 보일 수 있다. 두 접근의 failure mode는 상호보완적이다.
- Motivation: execution graph 기반 보안 연구는 "정상에서 벗어남"과 "명시적 위험 motif" 사이의 균형을 잡아야 한다.
- Required data: benign repeated runs, attack runs, task domain labels, graph features.
- Method: 동일 graph schema에서 one-class/anomaly classifier, supervised graph classifier, hand-written motif rules를 비교한다.
- Evaluation: detection AUROC, per-attack-class recall, benign utility preservation, domain transfer.
- Expected difficulty: Medium
- Risk / limitation: benign trace diversity가 부족하면 detector가 brittle해진다.
- Connection to research focus: execution graph 기반 탐지 전략을 정량 비교한다.
- Connection to key concepts: execution graph, provenance graph, malicious tool-use agents, benchmark.
- Connection to evaluation / validation: AgentDojo, AgentDyn, MSB attack classes별 confusion matrix를 만든다.
- First experiment: AgentDojo 한 domain에서 benign 100 runs와 attack 100 runs를 수집해 graph-level feature baseline을 만든다.

## Idea 5. MCP configuration drift와 tool rug-pull의 provenance-aware verification

- Hypothesis: tool description/schema/server config의 trust-on-first-use snapshot과 실행 시점 metadata hash를 provenance graph에 포함하면 tool rug-pull과 silent metadata poisoning을 조기에 탐지할 수 있다.
- Motivation: MCP는 도구 discovery metadata가 model context에 직접 들어가므로 supply-chain style drift가 위험하다.
- Required data: MCP server config snapshots, tools/list responses, schema hashes, approval records, runtime tool calls.
- Method: approved metadata snapshot을 graph root로 두고, 실행 시점 metadata와 hash diff를 edge로 연결한다. 변경된 metadata를 사용한 tool call은 high-risk path로 표시한다.
- Evaluation: metadata-change detection, benign update approval friction, attack prevention rate.
- Expected difficulty: Easy-Medium
- Risk / limitation: legitimate tool updates가 잦은 환경에서는 approval fatigue가 생길 수 있다.
- Connection to research focus: execution graph가 "어떤 tool definition을 보고 행동했는가"를 증명하게 만든다.
- Connection to key concepts: MCP security, tool poisoning, tool poisoning supply chain, provenance graph.
- Connection to evaluation / validation: mcp-context-protector와 Invariant MCP poisoning PoC를 비교 실험한다.
- First experiment: 로컬 MCP server의 tool description을 benign에서 malicious로 바꾸고, snapshot diff edge가 tool call risk score를 올리는지 확인한다.

## Idea 6. Browser agent prompt injection에서 DOM provenance와 action graph 결합

- Hypothesis: browser agent 공격은 webpage DOM/text/image provenance와 click/form-submit/download action graph를 연결하면 malicious instruction source를 더 잘 분리할 수 있다.
- Motivation: browser agent는 untrusted webpage content와 high-impact browser actions가 직접 연결된다.
- Required data: browser agent traces, DOM snapshots, tool/action logs, page origin, injected content labels.
- Method: DOM node, OCR text, model observation, planned action, browser event를 typed graph로 만들고 origin/domain trust와 action sink를 연결한다.
- Evaluation: malicious form submission/download prevention, benign browsing task completion, origin-aware false positive.
- Expected difficulty: Hard
- Risk / limitation: multimodal injection과 dynamic DOM mutation은 provenance capture가 어렵다.
- Connection to research focus: execution/provenance graph를 browser agent security로 확장한다.
- Connection to key concepts: browser agent security, indirect prompt injection, provenance graph, agentic workflow security.
- Connection to evaluation / validation: AgentDojo web/travel task 또는 custom browser injection benchmark를 사용한다.
- First experiment: Playwright 기반 mini-browser agent에서 webpage text injection이 어떤 action으로 이어지는지 DOM node id까지 기록한다.

## Experiment Backlog

### Easy

- Agent-Sentry/AuthGraph/AgentArmor/TraceAegis 비교표 작성.
- MCPTox 20개 샘플을 읽고 tool metadata poisoning graph schema 초안 작성.
- MCP tool metadata snapshot hash와 runtime hash 비교 스크립트 작성.
- strace로 `execve`, `openat`, `connect`만 추출해 process DAG 생성.

### Medium

- AgentDojo 한 domain에서 benign/attack trace를 수집하고 graph motif rule baseline 구현.
- MSB attack class별 graph feature template 작성.
- tool call log와 Docker/Falco/Tetragon event를 timestamp/container_id로 join.
- source_tools constraint를 수동 작성하고 parameter-source matching baseline 구현.

### Hard

- AuthGraph-style authorization graph를 자동 생성하고 dynamic replanning을 제한된 방식으로 지원.
- Graph neural network 또는 sequence+graph hybrid classifier로 malicious run detection.
- coding agent package install attack dataset 구축: benign install, typosquat, postinstall exfiltration, credential access.
- browser/GUI agent의 DOM provenance와 OS-level telemetry를 함께 수집하는 end-to-end harness.

## Possible Paper Angle

- "Provenance Graphs for Detecting Malicious Tool-Use in LLM Agents"라는 방향이 가능하다. 핵심 기여는 MCP/tool-call provenance와 OS-level runtime telemetry를 통합한 typed execution graph schema, MCPTox/MSB/AgentDojo를 재사용한 evaluation harness, 그리고 motif rule/authorization alignment/anomaly learning 세 detector의 비교가 될 수 있다.
- 더 좁은 각도로는 "Parameter-Source Provenance for Tool Poisoning Detection in MCP Agents"가 좋다. MCPTox/MSB 위에서 poisoned metadata, untrusted tool output, legitimate tool misuse 사이의 path를 정량화하면 실험 범위가 선명하다.

## Next Research Question

- 실행 그래프에서 "악성"을 최종 결과가 아니라 어떤 중간 구조로 정의할 수 있는가? 특히 tool metadata, untrusted observation, parameter value, process syscall, network sink 사이의 어떤 typed path가 model/client가 바뀌어도 안정적인 malicious signal로 남는가?
