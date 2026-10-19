# refactor: Unify review skill and add notion-log

## 1. 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | ehhdrud |
| 브랜치 | main |
| 날짜 | 2026-10-19 |
| 버전 | v0.0.2 |

---

## 2. 커밋 메시지

```
refactor: Unify review skill and add notion-log

Version: v0.0.2

review 스킬을 단일 흐름으로 통합하고 daily-log를 notion-log로 교체

- fe-reviewer/be-reviewer 에이전트 제거, review 스킬 단일 워크플로우로 재작성
- Tailwind v4 규칙을 review/references로 분리 (Claude/Codex)
- commit 스킬에 review 선행 실행(0단계) 추가
- daily-log 스킬 제거, notion-log 스킬 신규 추가 (Claude/Codex)
- Codex debugger/refactorer를 스킬에서 .codex/agents TOML로 이전
- sync CLI에서 .toml 파일을 텍스트로 처리하도록 확장자 추가
- package.json에 files 필드 추가, 버전 0.0.2로 상향
- README, GUIDE, CLAUDE.md 구조 및 사용법 갱신
```

---

## 3. 변경 파일

| 상태 | 파일 | 설명 |
|------|------|------|
| D | .claude/agents/be-reviewer.md | BE 리뷰 에이전트 제거 |
| D | .claude/agents/fe-reviewer.md | FE 리뷰 에이전트 제거 |
| M | .claude/skills/commit/FORMAT.md | 커밋 본문 예시를 범용 예시로 교체 |
| M | .claude/skills/commit/SKILL.md | review 선행 실행 0단계 추가 |
| D | .claude/skills/daily-log/SKILL.md | notion-log로 대체되어 제거 |
| A | .claude/skills/notion-log/SKILL.md | 노션 달력 일일 기록 + 주간 요약 스킬 |
| M | .claude/skills/review/SKILL.md | 단일 리뷰 워크플로우로 재작성 |
| A | .claude/skills/review/references/TAILWIND_V4_RULES.md | Tailwind v4 규칙 분리 |
| A | .codex/agents/debugger.toml | Codex 디버거 서브에이전트 |
| A | .codex/agents/refactorer.toml | Codex 리팩토러 서브에이전트 |
| M | .codex/skills/commit/FORMAT.md | Claude 측과 동일 |
| M | .codex/skills/commit/SKILL.md | Claude 측과 동일 |
| D | .codex/skills/daily-log/SKILL.md | notion-log로 대체되어 제거 |
| D | .codex/skills/debugger/SKILL.md | agents TOML로 이전 |
| D | .codex/skills/refactorer/SKILL.md | agents TOML로 이전 |
| A | .codex/skills/notion-log/SKILL.md | 노션 달력 일일 기록 + 주간 요약 스킬 |
| M | .codex/skills/review/SKILL.md | 단일 리뷰 워크플로우로 재작성 |
| D | .codex/skills/review/references/be-reviewer.md | 단일 리뷰로 통합되어 제거 |
| D | .codex/skills/review/references/fe-reviewer.md | 단일 리뷰로 통합되어 제거 |
| A | .codex/skills/review/references/TAILWIND_V4_RULES.md | Tailwind v4 규칙 분리 |
| M | CLAUDE.md | .codex/agents 구조 추가 |
| M | GUIDE.md | npm 토큰 입력 및 레포 접근 권한 안내 추가 |
| M | README.md | 레포 구조/구성 요소 섹션 갱신 |
| M | VERSION | 0.0.1 → 0.0.2 |
| M | packages/prompt/bin/cli.js | CLI 버전 0.0.2 |
| M | packages/prompt/package.json | 버전 0.0.2, files 필드 추가 |
| M | packages/prompt/src/sync.js | TEXT_EXTENSIONS에 .toml 추가 |
| A | docs/git/commit-logs/v0.0.2/2026-10-19_main_ehhdrud.md | 본 커밋 로그 |

---

## 4. 변경 배경 및 결과

**Why**: review가 FE/BE 에이전트로 쪼개져 있어 라우팅 판단이 번거롭고, 변경을 프로젝트 전체 맥락에서 보지 못했다. 커밋 전에 리뷰를 빠뜨리는 경우도 있었다. daily-log는 노션 달력 기반 기록 방식으로 바꿀 필요가 있었고, Codex의 debugger/refactorer는 스킬이 아니라 서브에이전트로 정의하는 편이 맞았다.

**What**: review가 하나의 워크플로우로 컨벤션·SSOT·중복·책임 분리·변경 안전성을 순서대로 점검하고, 안전한 리팩터링까지 직접 수행한다. commit 스킬은 커밋 전에 review를 반드시 실행한다. Codex 에이전트가 공식 TOML 형식으로 정의되고, sync CLI가 이를 정상 동기화한다.

---

## 5. 중요 변경 사항

- review 스킬: 서브에이전트 디스패치 방식 → 단일 컨텍스트 검토 + 국소 리팩터링 + 검증
- commit 스킬: 0단계(필수 리뷰) 추가, 동작/공개 계약 영향 시 커밋 중단 규칙
- `sync.js`: `.toml`을 텍스트 파일로 인식하도록 확장 (Codex agents 동기화 대응)
- `package.json`: `files: ["bin", "src"]`로 배포 대상 명시
- 기존 `fe-reviewer`, `be-reviewer`, `daily-log`, Codex `debugger`/`refactorer` 스킬 제거

---

## 6. 통계

| 항목 | 값 |
|------|-----|
| 변경 파일 수 | 28 |
| 추가 라인 | +682 (로그 파일 제외) |
| 삭제 라인 | -1256 |

---

## 7. 요약

코드 리뷰 도구를 하나로 합쳐 더 단순하게 쓸 수 있게 했고, 커밋하기 전에 항상 리뷰를 거치도록 바꿨다. 매일 작업 기록은 노션 달력에 남기는 방식으로 새로 만들었다. Codex 쪽 보조 도구도 정식 형식으로 정리해 다른 프로젝트에 그대로 복사되도록 했다.
