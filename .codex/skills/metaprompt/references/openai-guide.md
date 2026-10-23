# OpenAI(GPT / Codex) 프롬프팅 공식 가이드 요약

OpenAI의 "GPT-5 prompting guide", "GPT-4.1 prompting guide", Platform "Prompt engineering" 문서를 Codex·GPT용 프롬프트 작성 관점으로 압축한 것이다. 영문 블록은 원문 또는 원문에 가까운 표현이다.

기준일: 2026-10-23

## 목차

1. 모델 유형과 메시지 역할
2. 권장 프롬프트 구조
3. 지시 따르기 특성
4. 에이전트 워크플로우
5. 코딩 (Codex)
6. 제거·주의해야 할 패턴
7. 메타프롬프팅 템플릿
8. 출처

---

## 1. 모델 유형과 메시지 역할

- **Reasoning 모델**(o-시리즈, GPT-5): 고수준 목표만 줘도 잘 함. "시니어 동료". 느리고 비싸다.
- **GPT 모델**(GPT-4.1 등): 빠르고 싸지만 과제·출력을 **정확하고 명시적으로** 지시해야 함. "주니어 동료".
- 역할: `developer` 메시지 = 앱의 규칙·비즈니스 로직(함수 정의), `user` = 최종 사용자 입력(함수 인자). developer가 user보다 우선. Responses API의 `instructions` 파라미터는 해당 요청에만 적용되고 `input`보다 우선.
- developer 메시지의 권장 순서: **Identity**(목적·스타일·목표) → **Instructions**(할 것·하지 말 것) → **Examples** → **Context**(요청마다 바뀌므로 끝에).
- 프롬프트 캐싱: 재사용되는 정적 내용을 프롬프트 **앞쪽**에, 요청 본문의 앞쪽 파라미터에 둔다.
- 운영 프롬프트는 재사용 프롬프트 객체가 아니라 **코드 안에** 두고 코드 리뷰·테스트·평가를 붙인다. 모델 스냅샷을 고정하고 평가로 버전 변화를 잡는다.

---

## 2. 권장 프롬프트 구조 (GPT-4.1 가이드)

```markdown
# Role and Objective

# Instructions

## Sub-categories for more detailed instructions

# Reasoning Steps

# Output Format

# Examples
## Example 1

# Context

# Final instructions and prompt to think step by step
```

필요에 따라 섹션을 더하고 뺀다.

### 구분자

- **Markdown**: 기본 출발점. 헤더로 큰 섹션, 백틱으로 코드.
- **XML**: 성능 좋고 준수율을 높인다. 섹션 감싸기, 예시 중첩, 메타데이터 속성(`<doc id='1' title='…'>`)에 적합. Cursor는 `<[instruction]_spec>` 형태의 XML 스펙 태그로 섹션 간 상호참조를 해 준수율을 높였다.
- **JSON**: 코딩 맥락에선 이해되지만 장황하고 이스케이프 필요. **문서 묶음에는 특히 성능이 나쁘다.** 문서 묶음은 XML 또는 `ID: 1 | TITLE: … | CONTENT: …` 파이프 구분이 좋다.

### 긴 컨텍스트

- 지시를 **컨텍스트 앞과 뒤 양쪽**에 둔다. 한 곳만 가능하면 **앞**.
- 외부 지식 사용 여부를 명시: `Only use the documents in the provided External Context to answer the User Query.`
- 많은 항목을 동시에 검색하거나 전체 상태를 추론해야 하는 과제(그래프 탐색)는 성능이 떨어진다.

---

## 3. 지시 따르기 특성

- GPT-4.1/5는 지시를 **문자 그대로, 매우 가깝게** 따른다. 기존 모델에서 의도를 유추해 주던 프롬프트는 한 문장의 명확한 지시로 교정된다.
- **모순·모호한 지시는 다른 모델보다 비용이 크다.** 모델이 조화시키려고 추론 토큰을 쓴다. 예: "환자 동의 전 예약 금지" vs "환자 연락 없이 자동 예약" → 한쪽을 명시적으로 예외 처리.
- 충돌 시 **프롬프트 끝에 가까운 지시**가 이긴다.
- 권장 작업 순서:
  1. 상단에 "Response Rules" 또는 "Instructions" 고수준 섹션
  2. 특정 행동별 하위 섹션 (예: `# Sample Phrases`)
  3. 순서가 있는 워크플로우는 번호 목록
  4. 행동이 어긋나면 충돌·미지정·오류 지시를 찾는다
  5. 행동을 보여주는 예시 추가. 예시가 보여주는 것은 규칙에도 명시
  6. ALL CAPS, 뇌물, 팁 같은 강조는 꼭 필요할 때만. 과도하게 엄격해진다.
- 흔한 실패:
  - 툴 호출 강제 → 환각 입력·null 입력. 정보가 없으면 사용자에게 묻는 **폴백**을 넣는다.
  - 샘플 문구를 그대로 반복 → 변형하라고 지시.
  - 요청 안 한 산문·포맷 추가 → 명시 지시 + 예시.
- GPT-5는 **verbosity 파라미터**로 최종 답 길이를, **reasoning_effort**로 사고 깊이를 조절한다. 자연어로 특정 맥락만 override 가능 (Cursor: 전역 verbosity low, 코딩 툴 출력만 "high verbosity" 지시).
- 마크다운은 **기본적으로 꺼져 있다.** 원하면 명시: 인라인 코드·코드 펜스·리스트·테이블 등 의미가 맞는 곳에만. 긴 대화에선 3~5 메시지마다 마크다운 지시를 다시 붙이면 유지된다.

---

## 4. 에이전트 워크플로우

### 세 가지 에이전틱 리마인더 (GPT-4.1, SWE-bench ~20% 향상)

```text
# Persistence
You are an agent - please keep going until the user's query is completely resolved, before ending your turn and yielding back to the user. Only terminate your turn when you are sure that the problem is solved.

# Tool-calling
If you are not sure about file content or codebase structure pertaining to the user's request, use your tools to read files and gather the relevant information: do NOT guess or make up an answer.

# Planning (optional)
You MUST plan extensively before each function call, and reflect extensively on the outcomes of the previous function calls. DO NOT do this entire process by making function calls only, as this can impair your ability to solve the problem and think insightfully.
```

- 툴은 프롬프트에 스키마를 적지 말고 **API `tools` 필드**로 전달(2% 향상). 툴 이름은 명확히, 설명은 상세히. 복잡한 사용례는 툴 설명이 아닌 `# Examples` 섹션에.
- Responses API에서 `previous_response_id`로 추론 컨텍스트를 이어주면 툴 호출 사이 계획을 다시 세우지 않아 성능·지연이 개선된다.
- 분리 가능한 과제는 **턴당 하나씩** 나눠 돌릴 때 최고 성능.

### 적극성(eagerness) 조절 (GPT-5)

**덜 적극적으로** (탐색 줄이기, 지연 줄이기):
- `reasoning_effort`를 낮춘다 (medium/low로 충분한 경우가 많다).
- 컨텍스트 수집 기준을 명시: 넓게 시작 → 병렬 집중 질의 → 수정 대상이 확정되거나 상위 결과가 ~70% 수렴하면 중단 → 신호가 충돌할 때만 한 번 더 → 수정할 심볼만 추적.
- 툴 호출 예산을 고정: 예 "검색은 최대 2회".
- **탈출구**: `even if it might not be fully correct` 같이 불확실해도 진행할 수 있게.

**더 적극적으로**:
- `reasoning_effort`를 올리고 persistence 프롬프트 추가 (사용자 확인을 요청하지 말고, 가정을 문서화한 뒤 진행).
- 중단 조건, 안전/불안전 동작, 사용자에게 넘겨도 되는 시점을 명시.
- **툴별 불확실성 임계값**을 다르게: 결제·체크아웃은 낮은 임계값에서 확인, 검색은 매우 높은 임계값, 파일 삭제는 grep보다 엄격.

### 툴 프리앰블

GPT-5는 툴 호출 전후로 계획·진행 상황을 설명할 수 있다. 목표 재진술 → 구조화된 계획 → 각 단계 서술 → 계획과 분리된 완료 요약을 요구할 수 있다.

### Minimal reasoning에서의 보완

1. 최종 답 시작에 사고 요약을 불릿으로 요청
2. 상세한 툴 프리앰블과 진행 업데이트 요청
3. 툴 지시를 모호하지 않게, persistence 리마인더로 조기 종료 방지
4. 명시적 계획 지시(쿼리를 하위 요청으로 분해하고 각각 완료 확인)

---

## 5. 코딩 (Codex)

- Codex의 프로젝트 지시 파일은 **AGENTS.md** (Claude Code의 CLAUDE.md에 대응). 같은 원칙: 짧게, 추측 불가한 명령·규칙·에티켓만.
- **코드베이스 표준에 맞추기**: 엔지니어링 원칙, 디렉터리 구조, 스택 기본값, UI/UX 규칙을 프롬프트에 요약하면 변경이 기존 코드에 섞여 든다.
- **0→1 앱 생성**: 모델이 스스로 5~7개 카테고리의 품질 루브릭을 비공개로 만들고 그 기준에 맞을 때까지 내부 반복하게 하는 "self-reflection" 프롬프트.
- Cursor의 교훈:
  - "Be THOROUGH when gathering information"은 작은 작업에서 과잉 검색을 유발. `maximize_` 접두어를 빼고 어조를 누그러뜨리니 판단이 좋아졌다.
  - 사용자가 변경을 거부할 수 있는 환경에선 **묻지 말고 수정안을 제시**하라고 지시.
  - 가독성·유지보수성 우선, code-golf 금지.
- Terminal-Bench 계열 지시 예: `rg`를 `ls -R`/`find`/`grep` 대신 사용, `apply_patch`로 편집, 근본 원인 수정·최소 변경·기존 스타일 준수, 불필요한 주석·저작권 헤더 금지, 끝내기 전 `git status`/`git diff` 확인, pre-commit 있으면 실행, 작은 작업은 짧은 요약·복잡한 작업은 상세 요약.
- SWE-bench 지시: 숨은 테스트가 엣지 케이스를 검사하므로 **철저히 검증**하라고 강조.

---

## 6. 제거·주의해야 할 패턴

| 패턴 | 문제 | 대체 |
|---|---|---|
| 서로 충돌하는 규칙 | 추론 토큰 낭비, 뒤쪽 규칙이 이김 | 예외를 명시해 한쪽으로 정리 |
| ALL CAPS, "MUST", 뇌물·팁 | 과도하게 엄격 | 꼭 필요한 한 곳에만 |
| "Be THOROUGH", `maximize_*` | 작은 작업에 과잉 탐색 | 완화한 어조, 탐색 기준·예산 명시 |
| 툴 호출 강제(없는 정보로) | 환각·null 입력 | 사용자에게 묻는 폴백 |
| 샘플 문구 그대로 | 반복 출력 | "vary these phrases" |
| 문서 묶음을 JSON으로 | 성능 저하 | XML 또는 파이프 구분 |
| 긴 컨텍스트 뒤에만 지시 | 준수율 저하 | 앞+뒤, 최소한 앞 |
| 수백 항목 일괄 처리 한 번에 | 긴 반복 출력에 저항 | 강하게 지시하거나 분할 |
| 병렬 툴 호출 전제 | 가끔 오류 | 테스트 후 필요 시 `parallel_tool_calls: false` |

---

## 7. 메타프롬프팅 템플릿 (GPT-5)

기존 프롬프트를 대부분 유지하면서 최소 수정으로 행동을 교정할 때:

```text
When asked to optimize prompts, give answers from your own perspective - explain what specific phrases could be added to, or deleted from, this prompt to more consistently elicit the desired behavior or prevent the undesired behavior.

Here's a prompt: [PROMPT]

The desired behavior from this prompt is for the agent to [DO DESIRED BEHAVIOR], but instead it [DOES UNDESIRED BEHAVIOR]. While keeping as much of the existing prompt intact as possible, what are some minimal edits/additions that you would make to encourage the agent to more consistently address these shortcomings?
```

---

## 8. 출처

- GPT-5 prompting guide: https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_prompting_guide
- GPT-4.1 prompting guide: https://developers.openai.com/cookbook/examples/gpt4-1_prompting_guide
- Prompt engineering (Platform): https://developers.openai.com/api/docs/guides/prompt-engineering
- Codex subagents: https://developers.openai.com/codex/subagents
