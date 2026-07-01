완료했습니다. 지정된 런 디렉터리에 정확히 세 파일만 생성했습니다.

- [daily_research_brief.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_06_29_16_49/daily_research_brief.md)
- [papers_to_read.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_06_29_16_49/papers_to_read.md)
- [research_ideas.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_06_29_16_49/research_ideas.md)

Today's Top 3 Actions:
1. AgentArmor와 AuthGraph를 먼저 읽고 execution/provenance graph schema 초안을 만든다.
2. AgentDojo 또는 AgentDyn에서 10개 task를 실행해 tool-call log를 graph JSONL로 변환한다.
3. `untrusted source -> sensitive sink` rule baseline을 만들고 graph feature 추가 효과를 측정한다.

중요한 제한: 여러 최신 논문은 arXiv abstract와 공개 metadata 중심으로 요약했으므로, 구현 세부와 재현성은 본문/코드로 추가 확인이 필요합니다. MCPTox는 primary source 상태를 충분히 확인하지 못해 파일 내에서 `freshness 확인 필요`로 표시했습니다.