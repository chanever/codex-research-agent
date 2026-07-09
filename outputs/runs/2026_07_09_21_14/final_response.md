생성 완료했습니다.

파일:
- [daily_research_brief.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_09_21_14/daily_research_brief.md)
- [papers_to_read.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_09_21_14/papers_to_read.md)
- [research_ideas.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_09_21_14/research_ideas.md)

Today's Top 3 Actions:
1. Agent-Sentry, TraceAegis, AuthGraph를 먼저 읽고 `expected authorization graph + observed provenance graph + sandbox side-effect graph` 최소 스키마 설계.
2. AgentDojo 또는 AgentDyn에 tracing hook을 붙여 JSONL graph prototype 생성.
3. MCPTox/MCP-SafetyBench/MalSkillBench 중 하나로 `untrusted metadata/skill instruction -> legitimate tool/script call -> harmful side effect` motif detector baseline 작성.

중요 제한:
- 일부 최신 arXiv 자료는 preprint라 peer-review, 코드 공개, dataset license 확인이 필요합니다.
- MalSkillBench/MCPTox류 artifact는 실제 공개 위치와 안전한 취급 절차를 별도로 검증해야 합니다.
- 실제 악성 package나 skill 실행은 synthetic/neutralized sample과 격리 sandbox로 시작하는 전제가 필요합니다.