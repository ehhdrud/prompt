# feat(skills): Add metaprompt skill with official prompting guides

## 1. 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | ehhdrud |
| 브랜치 | main |
| 날짜 | 2026-10-23 |
| 버전 | v0.0.3 |

---

## 2. 커밋 메시지

```
feat(skills): Add metaprompt skill with official prompting guides

Version: v0.0.3

Anthropic·OpenAI 공식 프롬프팅 가이드를 근거로 프롬프트를 설계·작성·진단하는 metaprompt 스킬 추가

- 인터뷰 모드: 9개 질문 영역이 확인·위임될 때까지 질문 후 작성, "바로"로 생략 가능
- 신규 작성(설계 절차·골격)과 개선(진단 표) 두 모드 지원
- references: Claude 세대 무관 원칙, 현행 모델별 처방·구식 패턴,
  Claude Code(CLAUDE.md·SKILL.md·서브에이전트), OpenAI(GPT-5/4.1·Codex), 메타프롬프트 템플릿
- update 모드: 출처 URL 재조회로 레퍼런스 갱신, 원본 레포에서만 실행되도록 가드
- 기준일 6개월 초과 시 사용 시점에 공식 문서를 확인하는 신선도 체크
- .codex/skills/metaprompt 미러링 (파일 형식 참조·질문 방식 줄만 차이)
- README 레포 구조·구성 요소·작성 가이드·레퍼런스 갱신 규칙 반영
```

---

## 3. 변경 파일

| 상태 | 파일 | 설명 |
|------|------|------|
| A | `.claude/skills/metaprompt/SKILL.md` | 인터뷰 → 레퍼런스 로드 → 설계/진단 → 작성 → 자체 검토 → 출력 워크플로우, 갱신 모드 |
| A | `.claude/skills/metaprompt/references/claude-guide.md` | Anthropic "Prompting best practices" 중 세대 무관 원칙 요약 (공식 샘플 프롬프트 원문 포함) |
| A | `.claude/skills/metaprompt/references/claude-models.md` | Fable 5.1 / Opus 5.5 / Sonnet 5.5 행동 특성별 처방, 제거할 구식 패턴 표 |
| A | `.claude/skills/metaprompt/references/claude-code-guide.md` | CLAUDE.md·SKILL.md·서브에이전트 작성 기준 (Claude Code best practices, Skill authoring) |
| A | `.claude/skills/metaprompt/references/openai-guide.md` | GPT-5 / GPT-4.1 프롬프팅 가이드, Codex 코딩 지시 요약 |
| A | `.claude/skills/metaprompt/references/metaprompt-template.md` | Anthropic 메타프롬프트 절차, 변수 규칙, 시스템/태스크/툴 설명 골격, 산출물 형식 |
| A | `.codex/skills/metaprompt/**` | Claude 버전 미러. SKILL.md의 파일 형식 참조와 질문 방식 2줄만 Codex용으로 변경 |
| M | `README.md` | 레포 구조·Skills·Codex Skills 테이블에 metaprompt 추가, 작성 가이드와 레퍼런스 갱신 규칙 추가 |

---

## 4. 변경 배경 및 결과

프롬프트를 쓸 때 감에 의존해 품질이 들쭉날쭉했고, 모델 세대가 바뀌면서 예전에 통하던 기법(prefill, `<thinking>` 태그 요구, "MUST"·"CRITICAL" 강조)이 현행 모델에서는 오히려 역효과를 내는데도 그대로 쓰이고 있었다. 공식 가이드는 흩어져 있고 양이 많아 매번 찾아 읽기 어려웠다.

모델 제조사의 공식 프롬프팅 가이드를 요약한 레퍼런스를 스킬 안에 두고, 프롬프트를 새로 쓰거나 고칠 때 그 근거로 작성하는 `/metaprompt` 스킬을 추가했다. 대상이 Claude면 Anthropic 가이드를, Codex·GPT면 OpenAI 가이드를 읽으며, Claude Code용 CLAUDE.md·SKILL.md·서브에이전트 본문 작성도 같은 스킬로 처리한다.

애매한 요구를 가정으로 메우고 바로 결과를 뽑는 경향을 막기 위해 기본 동작을 인터뷰 모드로 두었다. 목적·독자·입력·출력·예외·제약·참고 자료·실행 환경·평가 9개 영역이 확인되거나 사용자가 위임할 때까지 2~4개씩 질문하고, 위임된 영역의 가정은 설계 메모에 남긴다. 요청에 "바로"를 넣으면 생략된다.

레퍼런스가 낡는 문제는 세 겹으로 대비했다. 변동이 잦은 모델별 처방을 별도 파일로 분리했고, `/metaprompt update`가 출처 URL을 다시 읽어 바뀐 부분만 반영하며, 기준일이 6개월을 넘으면 사용 시점에 공식 문서를 확인해 갱신을 권한다. 갱신은 원본 레포에서만 실행되도록 가드를 두어 프로젝트에서 고친 내용이 sync에 덮어써지는 일을 막는다.

---

## 5. 중요 변경 사항

- 산출물은 항상 프롬프트다. 완성 프롬프트 + 설계 메모(적용 원칙, 가정, 변수) + 검증 제안(대표 입력 2~3개) 세 덩어리로 출력한다
- 개선 모드는 명확성·동기·모순·과잉 강조·부정 지시·구식 패턴·예시·범위·구조 9개 항목으로 진단해 "문제 → 근거 → 수정안" 표를 만든 뒤 수정한다
- 레퍼런스 분리: `claude-guide.md`(세대 무관 원칙)와 `claude-models.md`(현행 모델 처방·구식 패턴). 영문 샘플 프롬프트는 공식 문서 원문 그대로 수록
- 모든 레퍼런스 상단에 `기준일: YYYY-MM-DD`, 하단에 출처 URL 섹션. update 모드가 이를 기준으로 동작
- update 모드 0단계: `git remote get-url origin`이 `ehhdrud/prompt`를 가리키지 않으면 갱신하지 않고 원본 레포 안내 후 종료
- `.claude`/`.codex` 공용 스킬을 쓸 때는 양쪽 가이드의 공통 원칙만 사용하고 한쪽에서만 유효한 기법은 넣지 않는다
- `packages/` 변경 없음. VERSION 0.0.3 유지, npm publish 불필요

---

## 6. 통계

| 항목 | 값 |
|------|-----|
| 변경 파일 수 | 13 |
| 추가 라인 | +2523 (로그 파일 제외) |
| 삭제 라인 | -1 |

---

## 7. 요약

"프롬프트 써 줘"라고 하면 모델 회사의 공식 사용 설명서를 근거로 프롬프트를 대신 작성해 주는 `/metaprompt` 스킬이 생겼다. 챗봇 지시문, 작업 지시, 스킬·에이전트 본문, CLAUDE.md까지 모두 같은 방식으로 만들 수 있고, 기존 프롬프트를 주면 요즘 모델에서 역효과를 내는 표현을 찾아 고쳐 준다.

바로 결과를 내지 않고 목적·독자·출력 형식·예외 상황 등을 먼저 물어본 뒤 작성하므로, 애매한 요청을 스킬이 제멋대로 해석하는 일이 줄어든다. 급하면 "바로 만들어줘"로 질문을 건너뛸 수 있다.

새 모델이 나오면 이 레포에서 `/metaprompt update`를 한 번 돌리면 레퍼런스가 최신 공식 문서에 맞춰 갱신되고, 각 프로젝트는 평소처럼 sync로 받는다.
