생성 완료했습니다.

- [daily_research_brief.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_05_20_46/daily_research_brief.md)
- [papers_to_read.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_05_20_46/papers_to_read.md)
- [research_ideas.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_05_20_46/research_ideas.md)

Today's Top 3 Actions:

1. `Agent-Sentry`를 먼저 읽고 provenance graph schema, feature set, evaluation metrics를 재현 가능한 형태로 정리한다.
2. AgentDojo/AgentDyn 중 하나를 선택해 tool-call trace를 `source -> argument -> tool_call -> side_effect` 그래프로 변환하는 최소 logger를 설계한다.
3. MalSkillBench 또는 PoisonedSkills 샘플로 Docker+strace/Falco 기반 runtime graph 수집 파이프라인을 작게 만들어 본다.

중요한 제한: MCPTox 데이터 저장소, MalSkillBench 데이터 다운로드/license, SafeClawBench Hugging Face dataset 상태는 사람이 최신 공개 상태를 한 번 더 확인해야 합니다. 웹 검색은 live로 수행했고, 요청 외 프로젝트/API/UI 파일은 만들지 않았습니다.