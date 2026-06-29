# Research Ideas

This is an example only. It is not based on a fresh literature review.

## Idea 1. Detect Tool Poisoning with Execution Graph Motifs

- Hypothesis: Malicious tool-use agents produce graph motifs that differ from benign automation.
- Motivation: Tool poisoning may appear as unusual dependency, file, network, or package-install edges.
- Required data: Agent transcripts, tool calls, filesystem events, package operations.
- Method: Build execution graphs and compare motif frequencies.
- Evaluation: Precision, recall, and false positive rate on labeled tasks.
- Expected difficulty: Medium
- Risk / limitation: Benign workflows can also be unusual.
- Connection to execution graph: Graph motifs are the primary signal.
- Connection to provenance: Edges preserve causal chains.
- Connection to sandbox verification: Sandbox traces provide ground truth events.
- First experiment: Instrument a toy coding-agent task with benign and malicious package install attempts.

## Idea 2. Provenance-Aware Prompt Injection Triage

- Hypothesis: Indirect prompt injection becomes easier to triage when external content is linked to later tool calls.
- Motivation: The causal path from document content to action is often unclear.
- Required data: Browser-agent sessions and content provenance.
- Method: Link observed instructions, model decisions, and tool invocations.
- Evaluation: Human triage time and detection accuracy.
- Expected difficulty: Medium
- Risk / limitation: Causal attribution may be ambiguous.
- Connection to execution graph: Instruction nodes connect to action nodes.
- Connection to provenance: Source URLs and content spans become provenance records.
- Connection to sandbox verification: Sandbox logs validate actual effects.
- First experiment: Create controlled web pages with benign and malicious instructions.

## Idea 3. Sandbox Escape Intent Signals

- Hypothesis: Failed attempts to access blocked resources are useful early-warning signals.
- Motivation: Malicious agents may probe sandbox boundaries before causing damage.
- Required data: Syscall traces, denied filesystem paths, network policy events.
- Method: Score boundary-probing behavior across tasks.
- Evaluation: Detection before successful harmful action.
- Expected difficulty: Hard
- Risk / limitation: Legitimate debugging can look similar.
- Connection to execution graph: Denied operations are graph events.
- Connection to provenance: Probe events can be traced to prior commands.
- Connection to sandbox verification: Sandbox policy is the measurement layer.
- First experiment: Compare benign build failures with adversarial probing tasks.

## Idea 4. Supply Chain Attack Replay for Coding Agents

- Hypothesis: Package installation attacks can be replayed safely to benchmark coding-agent defenses.
- Motivation: Coding agents frequently install dependencies.
- Required data: Synthetic malicious package metadata and install traces.
- Method: Use isolated package registries or mocked package managers.
- Evaluation: Whether the agent detects, avoids, or reports suspicious installs.
- Expected difficulty: Medium
- Risk / limitation: Must avoid real credential exposure.
- Connection to execution graph: Package actions become dependency edges.
- Connection to provenance: Package metadata links to the triggering task.
- Connection to sandbox verification: The sandbox contains install side effects.
- First experiment: Create a fake package with suspicious postinstall behavior in an isolated environment.

## Idea 5. Relevance Scoring for Agent Security Evidence

- Hypothesis: Evidence from execution graphs can rank incidents by research and security relevance.
- Motivation: Not every suspicious action deserves the same attention.
- Required data: Labeled incident traces and analyst notes.
- Method: Combine graph features, source type, and action severity.
- Evaluation: Agreement with expert ranking.
- Expected difficulty: Easy
- Risk / limitation: Expert labels may be inconsistent.
- Connection to execution graph: Features come from node and edge patterns.
- Connection to provenance: Source reliability affects scoring.
- Connection to sandbox verification: Verified effects increase confidence.
- First experiment: Score ten manually curated traces.

## Experiment Backlog

### Easy

- Convert one agent transcript into a simple node-edge Markdown table.

### Medium

- Capture filesystem and package-manager events from a sandboxed coding task.

### Hard

- Build a labeled benchmark of benign and malicious tool-use traces.

## Possible Paper Angle

- Execution Graphs for Detecting Malicious Tool-Use in LLM Agents.

## Next Research Question

- Which graph features distinguish malicious tool-use from normal task completion?
