---
name: review
description: 방금 구현된 코드를 FE/BE 전문가 관점에서 검토하고 수정. "리뷰", "review", "검토", "구현 점검" 요청 시 사용. FE/BE 범위를 자동 판별하고 references/fe-reviewer.md, references/be-reviewer.md의 기준을 적용한다.
---

# Review

방금 구현된 코드를 **전문가 시각으로 검토하고 잘못된 부분을 수정**하는 스킬.

FE/BE 범위를 판별한 뒤, 필요에 따라 `references/fe-reviewer.md`와 `references/be-reviewer.md`를 읽고 해당 기준으로 검토한다.

---

## 사용 방법

```
리뷰               # 방금 변경한 파일 전체 (git diff 기준 자동 감지)
리뷰 <경로>        # 특정 파일/디렉토리
FE 리뷰            # FE만 강제
BE 리뷰            # BE만 강제
FE 리뷰 <경로>     # FE + 범위 지정
```

---

## 워크플로우

### 1단계: 리뷰 범위 결정

- 인자 없음 → `git diff HEAD` + 스테이지 변경 + untracked 파일
- 경로 지정 → 해당 경로
- 범위가 비어 있으면 사용자에게 확인

### 2단계: FE / BE 라우팅

파일 경로 + 확장자 + **파일 내용**으로 분류한다. 확장자만으로 판정하지 말 것 — Next.js 서버 액션처럼 `.ts`/`.tsx`인데 서버 코드인 경우가 있다.

| 분류 | 힌트 |
|------|------|
| FE | `.tsx`, `.jsx`, `"use client"` 지시어, `src/components`, `src/hooks`, `.css`, `.scss`, `tailwind.config.*` |
| BE | `.py`, `.go`, `.java`, `.rb`, `controllers/`, `services/`, `repositories/`, `migrations/`, `schema.*`, `route.ts`(API Routes), `"use server"` 지시어, `actions/` 디렉토리 |
| 양쪽 | 공통 `.ts` 유틸, 타입 정의, `app/` 하위의 혼재 파일 → 양쪽 모두 디스패치 |

애매하면 사용자에게 묻는다. `fe`/`be` 강제 인자가 있으면 분류 생략.

### 3단계: 리뷰 기준 로드

FE 범위가 있으면 `references/fe-reviewer.md`를 읽고 기준을 적용한다.
BE 범위가 있으면 `references/be-reviewer.md`를 읽고 기준을 적용한다.
양쪽 범위가 모두 있으면 두 reference를 모두 읽고, 결과를 FE/BE 섹션으로 나누어 보고한다.

리뷰 시작 전 프로젝트 루트의 `CLAUDE.md`, `AGENTS.md`, `README.md` 중 존재하는 지침 파일을 확인한다.

### 4단계: 결과 취합

검토 결과는 발견 사항을 먼저 제시하고, 직접 수정한 항목과 사용자 판단이 필요한 항목을 구분한다.

형식:

```markdown
# 리뷰 결과

## FE
<FE 기준 검토 결과>

---

## BE
<BE 기준 검토 결과>

---

## 다음 액션
- 직접 수정한 항목은 이미 반영됨
- "사용자 판단 필요" 항목 중 선택할 것이 있으면 알려주세요
```

---

## 주의사항

- 자동 수정된 내용은 **바로 커밋하지 않는다.** 사용자가 확인 후 직접 커밋
- 리뷰 직후 `git diff`로 수정분을 사용자에게 안내
- 각 리뷰어 reference의 기준 항목 외 사소한 지적은 걸러낸다
- 리뷰 대상이 너무 크면(예: 50개 파일 이상) 사용자에게 범위를 좁힐지 확인
