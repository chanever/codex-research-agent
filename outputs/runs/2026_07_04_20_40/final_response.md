생성 완료했습니다.

**Generated files**
- [daily_research_brief.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_04_20_40/daily_research_brief.md)
- [papers_to_read.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_04_20_40/papers_to_read.md)
- [research_ideas.md](/home/jhc7781/codex-research-agent/outputs/runs/2026_07_04_20_40/research_ideas.md)

**Today's Top 3 Actions**
1. Agent-Sentry의 graph schema와 detector feature를 최소 구현으로 정리하기
2. AgentDyn 또는 MCPTox 하나를 골라 tool log를 provenance graph로 변환하는 파일럿 만들기
3. `semantic unsafe`, `audit-visible harm`, `sandbox state harm` 라벨을 분리한 평가 프로토콜 설계하기

**Important limitations**
- 2026 arXiv/benchmark 자료가 많아 최신 버전, code release, venue 상태는 사람이 한 번 더 확인해야 합니다.
- MCPTox는 출처별 test case 수 표기가 달라 최신 camera-ready/공식 저장소 확인이 필요합니다.
- 공격 재현은 실제 secret이나 실제 계정 없이 sandbox/honeypot 환경에서만 수행해야 합니다.