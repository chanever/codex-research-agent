완료했습니다. 지정된 출력 디렉터리에 정확히 세 Markdown 파일을 생성했습니다.

- [daily_research_brief.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_06_20_54/daily_research_brief.md)
- [papers_to_read.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_06_20_54/papers_to_read.md)
- [research_ideas.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_06_20_54/research_ideas.md)

Today's Top 3 Actions:

1. `Agent-Sentry`와 `AuthGraph`의 graph schema를 비교해 공통 최소 스키마를 만든다.
2. AgentDojo 또는 AgentDyn을 하나 골라 실행 로그를 provenance graph JSON으로 변환하는 tracer를 만든다.
3. 첫 baseline은 GNN보다 typed edge rule로 시작한다: `untrusted_observation -> sensitive_argument`, `tool_metadata -> privileged_tool_call`, `external_content -> memory_write`.

중요한 제한사항: 일부 2026 arXiv 자료는 공개 코드/데이터셋/peer review 상태를 추가 확인해야 합니다. 특히 `MCPTox`는 논문 HTML에서 anonymized repository를 언급하므로 현재 공개 데이터 위치는 재확인 필요로 표시했습니다.