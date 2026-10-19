# Claude Code / Codex 프롬프트 레포

Claude Code와 Codex에서 쓰는 스킬·에이전트를 한 곳에 모아 관리하는 개인 레포. `.claude/`와 `.codex/`를 각 프로젝트로 동기화해서 같은 프롬프트 자산을 어디서나 쓰는 것이 목적이다.

---

## 1. 만든 이유

### 해결하려는 문제
- 잘 만든 프롬프트가 특정 프로젝트 안에만 남고 다른 프로젝트에서 재사용되지 않음
- 프로젝트마다 다른 컨벤션 (커밋, 문서, 코드 전반)으로 일관성이 떨어짐

### 기대 효과

| 효과 | 설명 |
|------|------|
| **생산성** | 검증된 프롬프트를 새 프로젝트에 즉시 적용 |
| **일관성** | FE/BE 프로젝트 전반에 동일한 규칙 적용 |
| **품질** | 코드 리뷰·테스트 등 자동화된 체크리스트 |
| **가시성** | 각 프로젝트의 기술 스택·구조·규칙을 한눈에 파악 |

---

## 2. 레포 구조

```
prompt/                          # 개인 프롬프트 레포
│
├── .claude/                     # Claude Code 프로젝트로 동기화되는 폴더
│   │
│   ├── skills/                  # 스킬 정의
│   │   ├── summary/SKILL.md         # 변경사항 요약 정리
│   │   ├── summary/FORMAT.md        # 요약 형식 규칙
│   │   ├── branching/SKILL.md       # Git 브랜치 전략 관리
│   │   ├── commit/SKILL.md          # 커밋 메시지 작성
│   │   ├── document/SKILL.md        # 문서화 (research/plan/task)
│   │   ├── document/FORMAT.md       # 문서화 타입별 출력 형식
│   │   ├── worktree/SKILL.md        # Git worktree 관리
│   │   ├── notion-log/SKILL.md      # 노션 달력 일일 기록 + 주간 요약
│   │   ├── review/SKILL.md          # 변경 코드 구조 검토 및 리팩터링
│   │   ├── skill-creator/           # 스킬 생성 가이드
│   │   └── subagent-creator/        # 서브에이전트 생성 가이드
│   │
│   ├── agents/                  # 서브에이전트 정의
│   │   ├── debugger.md          # 버그 분석 전문 (opus)
│   │   └── refactorer.md        # 리팩토링 전문 (sonnet)
│   │
│   └── settings.local.json      # 로컬 설정 (gitignore)
│
├── .codex/                      # Codex 프로젝트로 동기화되는 폴더
│   │
│   ├── skills/                  # Codex 스킬 정의
│   │   ├── summary/SKILL.md         # 변경사항 요약 정리
│   │   ├── summary/FORMAT.md        # 요약 형식 규칙
│   │   ├── branching/SKILL.md       # Git 브랜치 전략 관리
│   │   ├── commit/SKILL.md          # 커밋 메시지 작성
│   │   ├── document/SKILL.md        # 문서화 (research/plan/task)
│   │   ├── document/FORMAT.md       # 문서화 타입별 출력 형식
│   │   ├── worktree/SKILL.md        # Git worktree 관리
│   │   ├── notion-log/SKILL.md      # 노션 달력 일일 기록 + 주간 요약
│   │   ├── review/SKILL.md          # 변경 코드 구조 검토 및 리팩터링
│   │   └── review/references/       # 조건부 스타일 규칙 (Tailwind v4 등)
│   │
│   └── agents/                  # Codex 서브에이전트 정의 (TOML)
│       ├── debugger.toml        # 버그 분석 전문 (read-only)
│       └── refactorer.toml      # 리팩토링 전문 (read-only)
│
├── .gitignore
└── README.md   # 현재 문서
```

---

## 3. 현재 구성 요소

### Skills

| 스킬 | 용도 | 트리거 예시 |
|------|------|------------|
| `/summary` | 변경사항 요약 정리 | "정리해줘", "요약해줘", "변경사항 정리" |
| `/document` | 문서화 (research/plan/task) | "플랜", "리서치", "작업요약" |
| `/branching` | Git 브랜치 전략 관리 | "브랜치 만들어", "릴리즈 시작" |
| `/commit` | 커밋 메시지 작성 | "커밋해줘" |
| `/worktree` | Git worktree 관리 | "워크트리", "병렬 작업" |
| `/notion-log` | 현재 레포 내 커밋을 노션 달력에 일일 기록 + 주간 요약 | "노션에 올려", "노션로그", "일일 기록", "주간 요약" |
| `/review` | 변경 코드 구조 검토, 리팩터링 및 검증 | "리뷰", "검토", "코드 점검" |

> **summary vs document Task**: `/summary`는 간단한 줄글 요약, `/document task`는 AS-IS/TO-BE 구조화 문서.

### Agents

| 에이전트 | 모델 | 용도 |
|----------|------|------|
| `debugger` | opus | 복잡한 버그 분석 |
| `refactorer` | sonnet | 코드 구조 개선 |

### Codex Skills

| 스킬 | 용도 | 트리거 예시 |
|------|------|------------|
| `summary` | 변경사항 요약 정리 | "정리해줘", "요약해줘", "변경사항 정리" |
| `document` | 문서화 (research/plan/task) | "플랜", "리서치", "작업요약" |
| `branching` | Git 브랜치 전략 관리 | "브랜치 만들어", "릴리즈 시작" |
| `commit` | 커밋 메시지 작성 | "커밋해줘" |
| `worktree` | Git worktree 관리 | "워크트리", "병렬 작업" |
| `notion-log` | 현재 레포 내 커밋을 노션 달력에 일일 기록 + 주간 요약 | "노션에 올려", "노션로그", "일일 기록", "주간 요약" |
| `review` | 변경 코드 구조 검토, 리팩터링 및 검증 | "리뷰", "검토", "코드 점검" |

### Codex Agents

| 에이전트 | 추론 강도 | 용도 |
|----------|-----------|------|
| `debugger` | high | 복잡한 버그 분석 |
| `refactorer` | medium | 코드 구조 개선 |

---

## 4. 동기화 정책

> 📘 **설정 및 사용 가이드**: [GUIDE.md](./GUIDE.md) 참조

### 동기화 방향

```
prompt (원본 레포)
        │
        │  단방향: 원본 → 프로젝트
        ▼
각 프로젝트
```

### 동기화 방식: Merge (병합)

```
원본 레포                    프로젝트
.claude/           →        .claude/
├── skills/                 ├── skills/
│   └── commit/             │   ├── commit/      ← 덮어쓰기
│   └── review/             │   ├── review/      ← 덮어쓰기
│                           │   └── my-custom/   ← 유지 (원본에 없음)
└── agents/                 └── agents/
    └── code-reviewer.md        ├── code-reviewer.md  ← 덮어쓰기
                                └── my-debugger.md    ← 유지 (원본에 없음)

.codex/            →        .codex/
├── skills/                 ├── skills/
│   ├── commit/             │   ├── commit/      ← 덮어쓰기
│   └── review/             │   ├── review/      ← 덮어쓰기
│                           │   └── my-custom/   ← 유지 (원본에 없음)
└── agents/                 └── agents/
    └── debugger.toml           ├── debugger.toml     ← 덮어쓰기
                                └── my-agent.toml     ← 유지 (원본에 없음)
```

---

## 5. 프롬프트 작성 가이드

- **Claude Skill 작성**: `/skill-creator` 스킬 참조 (`.claude/skills/skill-creator/SKILL.md`)
- **Agent 작성**: `/subagent-creator` 스킬 참조 (`.claude/skills/subagent-creator/SKILL.md`)
- **Codex Skill 작성**: Codex 내장 `skill-creator` 스킬 기준으로 `.codex/skills/{name}/SKILL.md` 작성
- **Codex Agent 작성**: `.codex/agents/{name}.toml`에 `name`, `description`, `developer_instructions` 필수 키로 작성 ([Codex Subagents](https://developers.openai.com/codex/subagents))

### 문서 업데이트 필수

> **새로운 skill 또는 agent 추가 시, 반드시 아래 항목을 업데이트하세요:**
> 1. **레포 구조** (섹션 2) - 새 파일 경로 추가
> 2. **현재 구성 요소** (섹션 3) - Skills 또는 Agents 테이블에 추가
>
> ※ 동기화 CLI는 GitHub 레포를 직접 clone하므로, main 브랜치에 커밋만 반영되면 다른 프로젝트에서 sync로 받을 수 있다.
> `npm publish`는 `packages/prompt/` 내부 코드(CLI 로직)가 변경된 경우에만 필요하다.
> 현재 CLI는 `.claude/`와 `.codex/`를 함께 동기화한다.

---

## 6. 커밋 컨벤션

### 형식

```
<type>(<scope>): <subject>
```

### Type

| Type | 설명 |
|------|------|
| `feat` | 새로운 프롬프트 추가 |
| `fix` | 기존 프롬프트 버그/오류 수정 |
| `improve` | 프롬프트 품질 개선 |
| `docs` | 문서 수정 |
| `chore` | 구조 변경, 설정 파일 수정 |

### Scope

| Scope | 설명 |
|-------|------|
| `skills` | SKILL.md 관련 |
| `agents` | Agent 관련 |
| `docs` | 문서 관련 |

### 예시

```bash
feat(skills): Add document skill for session recap
improve(agents): Enhance debugger with opus model
fix(skills): Fix review output format
```
