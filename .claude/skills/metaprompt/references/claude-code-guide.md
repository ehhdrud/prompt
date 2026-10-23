# Claude Code 프롬프트 작성 가이드 요약

CLAUDE.md, SKILL.md, 서브에이전트, Claude Code에 보내는 지시문을 쓸 때의 공식 기준. 출처: Claude Code "Best practices", Agent Skills "Skill authoring best practices".

기준일: 2026-10-23

## 목차

1. 전제: 컨텍스트 윈도가 가장 중요한 자원
2. CLAUDE.md 작성
3. Claude Code에 보내는 지시문
4. SKILL.md 작성
5. 서브에이전트 작성
6. 안티패턴
7. 체크리스트
8. 출처

---

## 1. 전제: 컨텍스트 윈도가 가장 중요한 자원

- 컨텍스트가 차면 성능이 떨어지고 앞선 지시를 "잊는다". 모든 프롬프트 파일은 **토큰 비용 대비 효과**로 판단한다.
- 매 세션 로드되는 것(CLAUDE.md, 스킬 메타데이터)은 짧게. 가끔 필요한 지식은 스킬(온디맨드 로드)로 뺀다.
- 반드시 매번 일어나야 하는 동작은 프롬프트가 아니라 **hook**(결정적)으로 만든다. 프롬프트 지시는 권고일 뿐이다.

---

## 2. CLAUDE.md 작성

- 형식 제약 없음. 짧고 사람이 읽을 수 있게. `/init`으로 시작해 다듬는다.
- **각 줄에 묻는다: "이 줄을 지우면 Claude가 실수하는가?"** 아니면 지운다. 비대한 CLAUDE.md는 정작 중요한 규칙을 묻히게 한다.
- 규칙이 계속 무시되면 파일이 너무 긴 것이다. 하나의 줄에만 `IMPORTANT`를 붙인다. 여러 줄에 붙이면 아무것도 두드러지지 않는다.
- Claude가 CLAUDE.md에 답이 있는 걸 묻는다면 표현이 모호한 것이다.
- 코드처럼 다룬다: 문제가 생기면 리뷰, 정기적으로 가지치기, 변경 후 행동이 실제로 바뀌는지 관찰. `/doctor`가 코드로 유추 가능한 내용을 제안해 준다.

| 포함 | 제외 |
|---|---|
| 추측할 수 없는 Bash 명령 | 코드를 읽으면 알 수 있는 것 |
| 기본값과 다른 코드 스타일 | 언어 표준 관례 |
| 테스트 방법과 선호 러너 | 상세 API 문서 (링크로 대체) |
| 레포 에티켓 (브랜치명, PR 규칙) | 자주 바뀌는 정보 |
| 프로젝트 고유 아키텍처 결정 | 긴 설명·튜토리얼 |
| 환경 특이사항 (필수 env var) | 파일별 코드베이스 설명 |
| 자명하지 않은 함정 | "클린 코드를 써라" 같은 당연한 말 |

예시 형태:

```markdown
# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
```

컴팩션 보존 지시도 CLAUDE.md에 둘 수 있다: `When compacting, always preserve the full list of modified files and any test commands`

---

## 3. Claude Code에 보내는 지시문

### 구체적 맥락

| 전략 | Before | After |
|---|---|---|
| 범위 지정 | add tests for foo.py | write a test for foo.py covering the edge case where the user is logged out. avoid mocks. |
| 출처 지목 | why does ExecutionFactory have such a weird api? | look through ExecutionFactory's git history and summarize how its api came to be |
| 기존 패턴 참조 | add a calendar widget | look at how existing widgets are implemented on the home page to understand the patterns. HotDogWidget.php is a good example. follow the pattern to implement a new calendar widget … |
| 증상 서술 | fix the login bug | users report that login fails after session timeout. check the auth flow in src/auth/, especially token refresh. write a failing test that reproduces the issue, then fix it |

### 검증 수단 제공

Claude는 "끝나 보이면" 멈춘다. 통과/실패 신호(테스트, 빌드, 린터, 스크린샷 비교)를 주면 스스로 반복한다.

| 전략 | Before | After |
|---|---|---|
| 검증 기준 | implement a function that validates email addresses | write a validateEmail function. example test cases: user@example.com is true, invalid is false, user@.com is false. run the tests after implementing |
| 시각 검증 | make the dashboard look better 	| [paste screenshot] implement this design. take a screenshot of the result and compare it to the original. list differences and fix them |
| 근본 원인 | the build is failing | the build fails with this error: [paste error]. fix it and verify the build succeeds. address the root cause, don't suppress the error |

증거를 요구한다: 테스트 출력, 실행한 명령과 결과, 스크린샷. 단언보다 증거 검토가 빠르다.

### 탐색 → 계획 → 구현 → 커밋

- 불확실하거나 여러 파일을 건드리거나 낯선 코드면 plan mode로 탐색·계획을 먼저. diff를 한 문장으로 설명할 수 있으면 계획을 건너뛴다.
- 큰 기능은 인터뷰부터:

```text
I want to build [brief description]. Interview me in detail using the AskUserQuestion tool.

Ask about technical implementation, UI/UX, edge cases, concerns, and tradeoffs. Don't ask obvious questions, dig into the hard parts I might not have considered.

Keep interviewing until we've covered everything, then write a complete spec to SPEC.md.
```

- 좋은 스펙은 자족적이다: 관련 파일·인터페이스, 범위 밖, 끝의 E2E 검증 단계.

### 적대적 리뷰

```text
Use a subagent to review the rate limiter diff against PLAN.md. Check that
every requirement is implemented, the listed edge cases have tests, and
nothing outside the task's scope changed. Report gaps, not style preferences.
```

리뷰어는 요청받은 대로 "갭"을 항상 찾아낸다. 정확성·명시된 요구에 영향 있는 것만 보고하라고 제한한다.

### 컨텍스트 관리 지시

- 조사는 범위를 좁히거나 서브에이전트로: `Use subagents to investigate how our authentication system handles token refresh, and whether we have any existing OAuth utilities I should reuse.`
- 같은 문제를 두 번 교정했으면 `/clear` 후 배운 것을 담은 더 나은 초기 프롬프트로.

---

## 4. SKILL.md 작성

### 프론트매터

- `name`: 64자 이하, 소문자·숫자·하이픈만, XML 태그 금지, "anthropic"·"claude" 예약어 금지. 동명사형(`processing-pdfs`) 권장, 명사구·동사형도 허용. `helper`, `utils`, `tools`, `documents` 같은 모호한 이름 금지.
- `description`: 1~1024자, **3인칭**("Processes Excel files…"), **무엇을 + 언제**를 핵심 용어·트리거 문구와 함께. 100개 이상의 스킬 중에서 고르는 유일한 근거다.
  - 좋음: `Generate descriptive commit messages by analyzing git diffs. Use when the user asks for help writing commit messages or reviewing staged changes.`
  - 나쁨: `Helps with documents`
- "언제 쓰는가"는 전부 description에. 본문의 "When to use" 섹션은 트리거 후에만 로드되므로 무의미.
- 부작용 있는 워크플로우를 수동 호출 전용으로 하려면 `disable-model-invocation: true`. 인자는 `$ARGUMENTS`.

### 본문

- **500줄 이하.** 넘으면 `references/`로 분리하고 SKILL.md에서 **언제 읽을지** 명시해 링크.
- **간결성**: Claude는 이미 똑똑하다. 모르는 것만 넣는다. 각 단락에 "토큰 비용을 정당화하는가?"를 묻는다.
- **명령형**으로 쓴다.
- **자유도**: 깨지기 쉬운 작업(마이그레이션, 정확한 순서)은 정확한 스크립트·명령(저자유도), 맥락 의존 작업(코드 리뷰)은 원칙(고자유도).
- **점진적 공개**: 참조는 SKILL.md에서 **한 단계**만. 중첩 참조는 부분 읽기(`head -100`)로 누락된다. 100줄 넘는 참조 파일은 상단에 목차.
- **워크플로우**: 복잡한 작업은 순서 있는 단계 + 복사해 체크하는 체크리스트. "검증 → 수정 → 반복" 피드백 루프를 넣으면 품질이 크게 오른다.
- **템플릿 패턴**: 엄격하면 "ALWAYS use this exact template", 유연하면 "sensible default, use judgment".
- **예시 패턴**: 입력/출력 쌍 2~3개가 설명보다 낫다.
- **조건 분기**: "Creating? → A workflow / Editing? → B workflow". 분기가 커지면 파일로 분리.
- 선택지를 나열하지 말고 **기본값 + 탈출구** 하나: "Use pdfplumber. For scanned PDFs requiring OCR, use pdf2image with pytesseract instead."
- 시간 의존 정보 금지("8월 전엔 구 API…"). 과거 패턴은 `<details>` 섹션으로.
- 용어 통일 (API endpoint / URL / path 섞지 않기).
- 경로는 항상 슬래시(`scripts/helper.py`). MCP 툴은 `Server:tool_name`.
- 스크립트는 "실행하라"와 "참고로 읽어라"를 구분해 쓴다. 패키지 설치 전제를 명시한다.
- README, CHANGELOG, INSTALLATION_GUIDE 같은 보조 문서를 만들지 않는다.

### 개발 방식

- 문서보다 **평가를 먼저**: 스킬 없이 과제를 돌려 실패를 기록 → 3개 시나리오 작성 → 베이스라인 → 최소 지시 작성 → 반복.
- Claude A(저자)와 Claude B(사용자) 분리. B의 실제 사용을 관찰해 A에게 구체적으로 피드백. 어떤 파일을 읽는지, 참조를 놓치는지, 같은 파일을 반복해 읽는지(→ SKILL.md로 승격) 본다.
- 사용할 모든 모델(Haiku/Sonnet/Opus)에서 테스트. Haiku엔 충분한가, Opus엔 과설명이 아닌가.

---

## 5. 서브에이전트 작성

`.claude/agents/<name>.md`. 별도 컨텍스트·별도 툴 권한으로 실행된다. 파일을 많이 읽거나 집중이 필요한 작업에 쓴다.

```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
You are a senior security engineer. Review code for:
- Injection vulnerabilities (SQL, XSS, command injection)
- Authentication and authorization flaws
- Secrets or credentials in code
- Insecure data handling

Provide specific line references and suggested fixes.
```

- `description`은 자동 위임의 근거. 자동 위임을 원하면 "use proactively" 등 트리거 조건을 넣는다.
- 시스템 프롬프트 본문: 역할 한 문장 → 수행 항목 → 출력 형식(라인 참조, 제안 수정). 범위 밖 행동(수정하지 말고 보고만 등)을 명시.
- `tools`는 필요한 최소만. 읽기 전용 리뷰어엔 Edit/Write를 주지 않는다.
- 모델은 작업 난이도로: 깊은 추론은 opus, 균형은 sonnet, 빠르고 단순한 것은 haiku.
- 필드·형식 세부는 `/subagent-creator` 스킬을 따른다.

---

## 6. 안티패턴

- **잡탕 세션**: 무관한 작업을 한 세션에. → 작업 사이 `/clear`.
- **반복 교정**: 두 번 이상 같은 교정. → `/clear` 후 배운 것을 담은 새 프롬프트.
- **과잉 명세 CLAUDE.md**: 길어서 절반이 무시됨. → 가차 없이 가지치기, 이미 잘하는 건 삭제하거나 hook으로.
- **검증 없는 신뢰**: 그럴듯한 구현이 엣지 케이스를 놓침. → 테스트·스크립트·스크린샷. 검증 못 하면 배포 금지.
- **무한 탐색**: 범위 없는 "조사해줘". → 범위를 좁히거나 서브에이전트.

---

## 7. 체크리스트

```
핵심 품질
- [ ] description이 구체적이고 핵심 용어·트리거를 포함하는가
- [ ] description에 무엇을 + 언제가 모두 있는가 (3인칭)
- [ ] SKILL.md 본문 500줄 이하인가
- [ ] 상세는 별도 파일로 빠졌고 한 단계 참조인가
- [ ] 시간 의존 정보가 없는가
- [ ] 용어가 일관되는가
- [ ] 예시가 추상이 아니라 구체인가
- [ ] 워크플로우에 명확한 단계와 검증 루프가 있는가
- [ ] 각 줄을 지우면 실수가 생기는가 (아니면 삭제)

테스트
- [ ] 평가 시나리오 3개 이상
- [ ] 쓸 모델 전부에서 테스트
- [ ] 실제 사용 시나리오로 테스트
```

---

## 8. 출처

- Claude Code best practices: https://code.claude.com/docs/en/best-practices
- Skill authoring best practices: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- CLAUDE.md: https://code.claude.com/docs/en/memory
- Skills: https://code.claude.com/docs/en/skills
- Subagents: https://code.claude.com/docs/en/sub-agents
