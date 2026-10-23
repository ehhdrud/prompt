# Claude 프롬프팅 공식 가이드 요약

Anthropic 공식 문서 "Prompting best practices" 중 모델 세대와 무관하게 유지되는 원칙을 프롬프트 작성 관점으로 압축한 것이다. 영문 블록은 공식 문서의 샘플 프롬프트를 **그대로** 옮긴 것이므로 필요 시 그대로 복사해 쓴다.

기준일: 2026-10-23

## 목차

1. 일반 원칙
2. 출력과 형식 제어
3. 툴 사용
4. 사고와 추론
5. 에이전트 시스템
6. 출처

> 모델별 행동 특성·처방과 구식 패턴 표는 변동이 잦아 [claude-models.md](claude-models.md)로 분리했다.

---

## 1. 일반 원칙

### 명확하고 직접적으로

- Claude를 "똑똑하지만 내 작업 관행을 모르는 신입"으로 본다. 요구를 정확히 설명할수록 결과가 좋다.
- **검증법**: 맥락 없는 동료에게 프롬프트를 보여줘 따라 할 수 있는지 본다. 동료가 헷갈리면 Claude도 헷갈린다.
- 출력 형식과 제약을 구체적으로 적는다. 순서·완전성이 중요하면 번호 목록으로 단계를 적는다.
- 과제 범위를 넘는 것을 원하면 명시적으로 요청한다. 암시로는 안 된다.

```text
Less effective:  Create an analytics dashboard
More effective:  Create an analytics dashboard. Include as many relevant features and interactions as possible. Go beyond the basics to create a fully-featured implementation.
```

### 맥락과 이유를 붙인다

규칙에 **왜**를 붙이면 Claude가 그 이유로부터 일반화한다.

```text
Less effective:  NEVER use ellipses
More effective:  Your response will be read aloud by a text-to-speech engine, so never use ellipses since the text-to-speech engine will not know how to pronounce them.
```

### 예시를 효과적으로

- 예시는 형식·톤·구조를 잡는 가장 신뢰할 만한 수단이다. **3~5개** 권장.
- 조건: **관련성**(실제 사용례와 유사), **다양성**(엣지 케이스 포함, 의도치 않은 패턴 학습 방지), **구조화**(`<example>`, 여러 개면 `<examples>`로 감싸 지시와 구분).
- 모델은 예시를 매우 충실히 따른다. 원하는 행동만 보여줘야 한다.

### XML 태그로 구조화

- 지시·맥락·예시·입력이 섞일 때 `<instructions>`, `<context>`, `<input>` 등으로 감싼다.
- 태그 이름은 일관되고 서술적으로. 계층이 있으면 중첩한다 (`<documents>` 안에 `<document index="n">`).

### 역할 부여

시스템 프롬프트의 한 문장짜리 역할만으로도 톤과 초점이 달라진다. 예: `You are a helpful coding assistant specializing in Python.`

### 긴 컨텍스트(20k 토큰 이상)

- **긴 자료는 프롬프트 맨 위**, 질문·지시·예시는 그 아래. 질문을 끝에 두면 품질이 최대 30% 향상.
- 문서마다 `<document index="n"><source>…</source><document_content>…</document_content></document>` 구조.
- 긴 문서 과제는 **먼저 관련 구절을 인용**하게 한 뒤 과제를 수행시킨다 (`<quotes>` → `<info>`).

### 모델 자기 인식

앱에서 모델이 자신을 정확히 밝혀야 하면 시스템 프롬프트에 명시한다.

```text
The assistant is Claude, created by Anthropic. The current model is Claude Opus 5.5.
```

---

## 2. 출력과 형식 제어

- **하지 말 것 대신 할 것을 말한다.** "Do not use markdown" → "Your response should be composed of smoothly flowing prose paragraphs."
- **XML 형식 지시자**: "Write the prose sections of your response in <smoothly_flowing_prose_paragraphs> tags."
- **프롬프트 스타일을 출력 스타일에 맞춘다.** 프롬프트에서 마크다운을 빼면 출력의 마크다운도 준다.
- 최신 모델은 이전보다 간결하고 사실 중심이다. 툴 호출 후 요약을 생략하기도 한다. 요약을 원하면: `After completing a task that involves tool use, provide a quick summary of the work you've done.`
- 수식은 기본 LaTeX. 평문을 원하면: `Format your response in plain text only. Do not use LaTeX, MathJax, or any markup notation such as \( \), $, or \frac{}{}. Write all math expressions using standard text characters (e.g., "/" for division, "*" for multiplication, and "^" for exponents).`

### 마크다운·불릿 최소화 블록 (긴 글용)

```text
<avoid_excessive_markdown_and_bullet_points>
When writing reports, documents, technical explanations, analyses, or any long-form
content, write in clear, flowing prose using complete paragraphs and sentences. Use
standard paragraph breaks for organization and reserve markdown primarily for `inline
code`, code blocks (```...```), and simple headings (## and ###). Avoid using **bold**
and *italics*.

DO NOT use ordered lists (1. ...) or unordered lists (*) unless: a) you're presenting
truly discrete items where a list format is the best option, or b) the user explicitly
requests a list or ranking

Instead of listing items with bullets or numbers, incorporate them naturally into
sentences. This guidance applies especially to technical writing. Using prose instead of
excessive formatting will improve user satisfaction. NEVER output a series of overly
short bullet points.

Your goal is readable, flowing text that guides the reader naturally through ideas
rather than fragmenting information into isolated points.
</avoid_excessive_markdown_and_bullet_points>
```

> Fable 5.1은 원래 포맷팅을 덜 쓰므로 이 블록이 오히려 필요한 구조를 억제한다. claude-models.md의 "채팅 포맷팅" 규칙으로 대체한다.

### Prefill 대체 (4.6 이후 마지막 assistant 턴 prefill은 400 에러)

| 기존 prefill 용도 | 대체 |
|---|---|
| JSON/분류 형식 강제 | structured outputs(`output_config.format`) 또는 스키마를 명시한 지시 + 재시도. 분류는 enum 툴 |
| 서두 제거 ("Here is…") | `Respond directly without preamble. Do not start with phrases like 'Here is...', 'Based on...', etc.` 또는 XML 태그/structured output |
| 이어쓰기 | 유저 메시지로: `Your previous response was interrupted and ended with \`[previous_response]\`. Continue from where you left off.` |
| 역할·맥락 주입 | 유저 턴에 리마인더 삽입, 또는 툴/컴팩션으로 하이드레이션 |

---

## 3. 툴 사용

- 최신 모델은 지시를 문자 그대로 따른다. "Can you suggest some changes?"면 **제안만** 한다. 행동을 원하면 `Change this function to improve its performance.`처럼 동사로 지시한다.
- 기본적으로 행동하게:

```text
<default_to_action>
By default, implement changes rather than only suggesting them. If the user's intent is
unclear, infer the most useful likely action and proceed, using tools to discover any
missing details instead of guessing. Try to infer the user's intent about whether a tool
call (e.g., file edit or read) is intended or not, and act accordingly.
</default_to_action>
```

- 기본적으로 신중하게:

```text
<do_not_act_before_instructions>
Do not jump into implementation or change files unless clearly instructed to make
changes. When the user's intent is ambiguous, default to providing information, doing
research, and providing recommendations rather than taking action. Only proceed with
edits, modifications, or implementations when the user explicitly requests them.
</do_not_act_before_instructions>
```

- **공격적 어조를 완화한다.** "CRITICAL: You MUST use this tool when..." → "Use this tool when...". 현행 모델은 시스템 프롬프트에 민감해 과잉 트리거된다.
- 병렬 툴 호출 강화:

```text
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies between the tool
calls, make all of the independent tool calls in parallel. Prioritize calling tools
simultaneously whenever the actions can be done in parallel rather than sequentially.
For example, when reading 3 files, run 3 tool calls in parallel to read all 3 files into
context at the same time. Maximize use of parallel tool calls where possible to increase
speed and efficiency. However, if some tool calls depend on previous calls to inform
dependent values like the parameters, do NOT call these tools in parallel and instead
call them sequentially. Never use placeholders or guess missing parameters in tool
calls.
</use_parallel_tool_calls>
```

- 병렬 억제: `Execute operations sequentially with brief pauses between each step to ensure stability.`
- 툴 설명은 "언제 쓰는지 + 입력 의미"를 서술한다. MCP 툴은 `Server:tool_name` 완전한 이름으로 적는다.

---

## 4. 사고와 추론

- 4.6 이후는 adaptive thinking. 5.x(Fable, Opus 5.5)는 **항상 켜짐**. 사고량 제어는 프롬프트가 아니라 `effort` 파라미터로 한다.
- **일반 지시가 세부 절차보다 낫다.** "think thoroughly"가 사람이 쓴 단계별 계획보다 좋은 추론을 낸다. 모델의 추론은 사람이 처방한 것을 넘는다.
- **워크드 예시는 사고에도 영향**을 준다. 문제 → 적용 방법 → 기대 답 순으로 제시.
- **출력에 추론을 쓰게 하지 않는다.** 5.x 모델에 `<thinking>` 태그로 추론을 쓰라고 하면 `reasoning_extraction` 거절이 나올 수 있다. 짧은 설명이나 수행 요약은 요청 가능. (사고가 꺼진 구형 모델에서만 수동 CoT + `<answer>` 태그 사용)
- **자체 검증 요청**: `Before you finish, verify your answer against [test criteria].` 코딩·수학에서 효과적. 단 Opus 5는 스스로 잘 검증하므로 과검증 지시는 제거.
- 툴 결과 후 성찰 유도:

```text
After receiving tool results, carefully reflect on their quality and determine optimal
next steps before proceeding. Use your thinking to plan and iterate based on this new
information, and then take the best next action.
```

- 사고 과다 억제(결정 후 재검토 반복 방지):

```text
When you're deciding how to approach a problem, choose an approach and commit to it.
Avoid revisiting decisions unless you encounter new information that directly
contradicts your reasoning. If you're weighing two approaches, pick one and see it
through. You can always course-correct later if the chosen approach fails.
```

- 사고 트리거 억제(큰 시스템 프롬프트에서 매번 사고할 때):

```text
Thinking adds latency and should only be used when it will meaningfully improve
answer quality - typically for problems that require multistep reasoning. When in
doubt, respond directly.
```

- 과잉 탐색 완화: "Default to using [tool]" → "Use [tool] when it would enhance your understanding of the problem". "If in doubt, use [tool]"는 삭제. 그래도 과하면 effort를 낮춘다.

---

## 5. 에이전트 시스템

### 컨텍스트 한계와 장기 작업

컴팩션이나 외부 저장이 있는 하네스라면 알려준다. 모르면 한계 근처에서 작업을 서둘러 마무리한다.

```text
Your context window will be automatically compacted as it approaches its limit, allowing
you to continue working indefinitely from where you left off. Therefore, do not stop
tasks early due to token budget concerns. As you approach your token budget limit, save
your current progress and state to memory before the context window refreshes. Always be
as persistent and autonomous as possible and complete tasks fully, even if the end of
your budget is approaching. Never artificially stop any task early regardless of the
context remaining.
```

여러 컨텍스트 윈도에 걸친 작업:
1. 첫 윈도는 프레임워크 세팅(테스트 작성, 셋업 스크립트), 이후 윈도는 todo 반복.
2. 테스트를 구조화 형식(`tests.json`)으로 먼저 작성·추적. `It is unacceptable to remove or edit tests because this could lead to missing or buggy functionality.`
3. `init.sh` 같은 편의 스크립트를 만들게 한다.
4. 컴팩션 대신 새 윈도로 시작하는 것도 고려. 시작 방법을 처방: `Call pwd; you can only read and write files in this directory.` / `Review progress.txt, tests.json, and the git logs.` / `Manually run through a fundamental integration test before moving on to implementing new features.`
5. 검증 툴(브라우저, 컴퓨터 사용)을 제공.
6. 컨텍스트를 끝까지 쓰게:

```text
This is a very long task, so it may be beneficial to plan out your work clearly. It's
encouraged to spend your entire output context working on the task - just make sure you
don't run out of context with significant uncommitted work. Continue working
systematically until you have completed this task.
```

상태 관리: 구조화 데이터는 JSON, 진행 메모는 자유 텍스트, git을 체크포인트로, 점진적 진행을 명시적으로 요구.

### 자율성과 안전

```text
Consider the reversibility and potential impact of your actions. You are encouraged to
take local, reversible actions like editing files or running tests, but for actions that
are hard to reverse, affect shared systems, or could be destructive, ask the user before
proceeding.

Examples of actions that warrant confirmation:
- Destructive operations: deleting files or branches, dropping database tables, rm -rf
- Hard to reverse operations: git push --force, git reset --hard, amending published commits
- Operations visible to others: pushing code, commenting on PRs/issues, sending
messages, modifying shared infrastructure

When encountering obstacles, do not use destructive actions as a shortcut. For example,
don't bypass safety checks (e.g. --no-verify) or discard unfamiliar files that may be
in-progress work.
```

### 리서치

성공 기준을 명시하고, 복수 출처 검증을 요구한다. 복잡한 리서치:

```text
Search for this information in a structured way. As you gather data, develop several
competing hypotheses. Track your confidence levels in your progress notes to improve
calibration. Regularly self-critique your approach and plan. Update a hypothesis tree or
research notes file to persist information and provide transparency. Break down this
complex research task systematically.
```

### 서브에이전트

최신 모델은 알아서 위임한다. 과용 시:

```text
Use subagents when tasks can run in parallel, require isolated context, or involve
independent workstreams that don't need to share state. For simple tasks, sequential
operations, single-file edits, or tasks where you need to maintain context across steps,
work directly rather than delegating.
```

### 프롬프트 체이닝

대부분의 다단계 추론은 내부에서 처리된다. 중간 산출물 검사나 파이프라인 강제가 필요할 때만 분리. 가장 흔한 패턴은 **초안 → 기준 대비 리뷰 → 수정**의 자기 교정 체인.

### 코딩 에이전트 처방

- 임시 파일 정리: `If you create any temporary new files, scripts, or helper files for iteration, clean up these files by removing them at the end of the task.`
- 과잉 엔지니어링 억제:

```text
Avoid over-engineering. Only make changes that are directly requested or clearly
necessary. Keep solutions simple and focused:

- Scope: Don't add features, refactor code, or make "improvements" beyond what was
asked. A bug fix doesn't need surrounding code cleaned up. A simple feature doesn't need
extra configurability.

- Documentation: Don't add docstrings, comments, or type annotations to code you didn't
change. Only add comments where the logic isn't self-evident.

- Defensive coding: Don't add error handling, fallbacks, or validation for scenarios
that can't happen. Trust internal code and framework guarantees. Only validate at system
boundaries (user input, external APIs).

- Abstractions: Don't create helpers, utilities, or abstractions for one-time
operations. Don't design for hypothetical future requirements. The right amount of
complexity is the minimum needed for the current task.
```

- 테스트 통과만 노리는 하드코딩 방지:

```text
Please write a high-quality, general-purpose solution using the standard tools
available. Do not create helper scripts or workarounds to accomplish the task more
efficiently. Implement a solution that works correctly for all valid inputs, not just
the test cases. Do not hard-code values or create solutions that only work for specific
test inputs. Instead, implement the actual logic that solves the problem generally.

Focus on understanding the problem requirements and implementing the correct algorithm.
Tests are there to verify correctness, not to define the solution. Provide a principled
implementation that follows best practices and software design principles.

If the task is unreasonable or infeasible, or if any of the tests are incorrect, please
inform me rather than working around them. The solution should be robust, maintainable,
and extendable.
```

- 코드 환각 억제:

```text
<investigate_before_answering>
Never speculate about code you have not opened. If the user references a specific file,
you MUST read the file before answering. Make sure to investigate and read relevant
files BEFORE answering questions about the codebase. Never make any claims about code
before investigating unless you are certain of the correct answer - give grounded and
hallucination-free answers.
</investigate_before_answering>
```

- 프론트엔드 "AI slop" 회피: `<frontend_aesthetics>` 블록(타이포·색·모션·배경 지시, Inter/Roboto/보라 그라데이션 회피). Opus 5.5는 일반론보다 **피할 패턴을 구체적으로 나열**할 때 반응한다. 예: `Do not use a cream or off-white background, italic accent words in headlines, numbered "01/02/03" section labels, monospace labels, or pill-shaped buttons.`

---

## 6. 출처

- Prompting best practices: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices
- Prompt engineering overview: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview
- 일반 프롬프트 엔지니어링 블로그: https://claude.com/blog/best-practices-for-prompt-engineering
