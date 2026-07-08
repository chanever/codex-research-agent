생성 완료했습니다. 새로 만든 파일은 정확히 세 개입니다.

- [daily_research_brief.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_08_21_07/daily_research_brief.md)
- [papers_to_read.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_08_21_07/papers_to_read.md)
- [research_ideas.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_08_21_07/research_ideas.md)

Today's Top 3 Actions:

1. Agent-Sentry, AuthGraph, AgentArmor를 먼저 읽고 `expected authorization graph + observed provenance graph + sandbox side-effect graph` 최소 스키마를 설계한다.
2. AgentDojo 또는 AgentDyn에 tracing hook을 붙여 observation, tool call, argument source, file/network side effect를 JSONL graph로 저장하는 prototype을 만든다.
3. MCPTox/MSB 중 하나를 선택해 MCP tool metadata node를 추가하고 `untrusted metadata -> sensitive legitimate tool call` motif detector baseline을 만든다.

중요한 제한사항: 일부 2026 arXiv/benchmark 자료는 preprint 또는 최신 artifact 상태라 peer-review 여부, 공식 코드 공개 여부, dataset license, 논문 버전과 저장소 버전 일치 여부를 사람이 한 번 더 확인해야 합니다.