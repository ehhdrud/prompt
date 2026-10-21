<!-- See README.md for full project documentation -->

# Project: prompt

Claude Code / Codex 프롬프트 관리용 개인 레포. `.claude/`와 `.codex/` 폴더(skills, agents)를 각 프로젝트에 동기화한다.

## Structure

- `.claude/skills/` — Claude Code 스킬 정의 (SKILL.md)
- `.claude/agents/` — 서브에이전트 정의
- `.codex/skills/` — Codex 스킬 정의
- `.codex/agents/` — Codex 서브에이전트 정의 (TOML)
- `packages/prompt/` — 동기화 CLI
- `README.md` — 전체 문서 (레포 구조, 작성법, 동기화 정책)
- `GUIDE.md` — 설정 및 사용 가이드

## Rules

- 커밋 컨벤션은 `/commit` 스킬(`.claude/skills/commit/SKILL.md`)을 따른다
- `packages/` 하위 변경 시 커밋 전에 `VERSION`과 `packages/prompt/package.json`의 버전을 patch 업하여 커밋에 포함한다
- CLI 배포(`npm publish`) 전 `GUIDE.md` 2.4 체크리스트 확인. 특히 `bin` 이름은 OS 내장 명령과 겹치면 안 된다 (`prompt` 사용 금지 — Windows cmd 내장 명령과 충돌해 아무 출력 없이 종료됨)
- 새 skill/agent 추가 시 README.md 섹션 2(레포 구조), 섹션 3(구성 요소) 반드시 업데이트
- 동기화 방향: 원본 → 프로젝트 (단방향)
- 프로젝트 → 원본은 PR로 수동 반영
