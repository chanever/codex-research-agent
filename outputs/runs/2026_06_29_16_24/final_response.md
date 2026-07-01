완료했습니다. 생성된 파일은 정확히 3개입니다.

- [daily_research_brief.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_06_29_16_24/daily_research_brief.md)
- [papers_to_read.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_06_29_16_24/papers_to_read.md)
- [research_ideas.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_06_29_16_24/research_ideas.md)

Today's Top 3 Actions:

1. Agent-Sentry, AuthGraph, AgentArmor를 같은 표로 정리해 trace representation, policy target, benchmark, failure mode를 비교한다.
2. MCPTox 또는 MSB 중 하나를 골라 최소 실행 harness를 만들고 tool-call trace, argument provenance, process/file/network telemetry schema를 먼저 정의한다.
3. `tool metadata poisoning -> legitimate tool misuse`를 provenance graph motif로 표현하고, motif rule baseline을 만든 뒤 learned anomaly detector와 비교한다.

중요한 제한: 일부 GitHub 저장소와 benchmark의 최신 데이터 수, 공개 범위, 재현 가능성은 clone 후 확인이 필요합니다. 특히 MCPTox/MSB의 공개 코드와 논문 수치 일치 여부, Agent-Sentry/AuthGraph/AgentArmor의 code release 여부는 사람이 검증해야 합니다.