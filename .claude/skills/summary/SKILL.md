---
name: summary
description: 변경사항을 공유용 줄글 마크다운으로 정리. "정리해줘", "요약해줘", "변경사항 정리", "공유용으로 정리", "summary" 요청 시 사용. 커밋 로그, git diff, 또는 사용자가 지정한 범위의 변경사항을 분석하여 정리.
---

# Summary

변경사항을 간단한 줄글 마크다운으로 정리한다. 구조화된 문서(AS-IS/TO-BE)가 필요하면 document Task를 사용한다.

> **형식 규칙**: [FORMAT.md](./FORMAT.md) 참조

## 입력 소스

사용자가 지정한 범위에 따라 소스를 결정한다:

| 요청 | 소스 |
|------|------|
| "브랜치 정리", 범위 미지정 | `git diff origin/main..HEAD` |
| 특정 커밋 로그 지정 | `docs/git/commit-logs/` 내 해당 파일 |
| 특정 커밋 범위 지정 | `git log/diff` 해당 범위 |
| 현재 세션 작업 내용 | 대화 컨텍스트 기반 |

## 워크플로우

### 1단계: 변경사항 수집

입력 소스에 따라 적절한 방법으로 변경 내역을 수집한다.

```bash
# 브랜치 전체 (기본)
git diff origin/main..HEAD --name-status
git diff origin/main..HEAD --stat
git log origin/main..HEAD --oneline

# 특정 파일의 상세 diff
git diff origin/main..HEAD -- "파일경로"
```

### 2단계: 분석

- 모든 변경 파일의 diff를 읽고, 기능 단위로 그룹핑
- 코드 레벨이 아닌 **기능/동작 레벨**로 이해

### 3단계: 출력

[FORMAT.md](./FORMAT.md)의 형식 규칙을 따라 마크다운으로 출력한다.
