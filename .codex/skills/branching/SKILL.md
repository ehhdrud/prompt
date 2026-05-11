---
name: branching
description: Git 브랜치 전략 관리. 브랜치 생성, 병합, 릴리즈 워크플로우를 자동화한다. 브랜치 만들어, 브랜치 생성, 릴리즈 시작, 핫픽스, feature 브랜치, release 브랜치, 브랜치 전략, branching, new branch, merge, 병합 요청 시 사용.
---

# Git Branching Strategy

## Branch Structure

```
main                        # 프로덕션 (배포)
├── develop                 # 통합 개발
│   ├── release/vX.Y.Z      # 릴리즈 준비
│   │   └── feature/*       # 기능 개발
│   └── hotfix/*            # 긴급 수정
```

## Branch Types

| Prefix | Base | Merge Target | Purpose |
|--------|------|-------------|---------|
| `release/vX.Y.Z` | `develop` | `develop` | 버전별 릴리즈 준비 |
| `feature/vX.Y.Z/기능명` | `release/vX.Y.Z` | `release/vX.Y.Z` | 기능 개발 (베이스 버전 명시) |
| `hotfix/이슈명` | `main` | `main` + `develop` | 프로덕션 긴급 수정 |

## Naming Rules

- `feature/vX.Y.Z` 단독 브랜치 생성 금지. 반드시 `feature/vX.Y.Z/기능명` 형태로 생성
- 하위 브랜치가 필요하면 `-`를 사용 (예: `기능명-세부작업`)

## Workflows

### 1. Release Start

```bash
# develop에서 release 브랜치 분기
git checkout develop
git pull origin develop
git checkout -b release/vX.Y.Z
git push -u origin release/vX.Y.Z
```

### 2. Feature Development

```bash
# release 브랜치에서 feature 분기
git checkout release/vX.Y.Z
git pull origin release/vX.Y.Z
git checkout -b feature/vX.Y.Z/기능명
git push -u origin feature/vX.Y.Z/기능명
```

### 3. Sync (Feature ← Release)

작업 중 주기적으로 release 브랜치의 변경사항을 pull하여 충돌 방지.

```bash
git checkout feature/vX.Y.Z/기능명
git pull origin release/vX.Y.Z
# 충돌 해결 후 push
```

### 4. Feature Merge

```bash
# feature → release PR 생성
gh pr create --base release/vX.Y.Z --head feature/vX.Y.Z/기능명
```

### 5. Release Complete

```bash
# release → develop PR
gh pr create --base develop --head release/vX.Y.Z
# develop → main PR (프로덕션 배포)
gh pr create --base main --head develop
```

### 6. Hotfix

```bash
git checkout main
git pull origin main
git checkout -b hotfix/이슈명
# 수정 후
gh pr create --base main --head hotfix/이슈명
# main 병합 후 develop에도 반영
git checkout develop && git pull origin main
```

## Execution Guide

사용자 요청에 따라 적절한 워크플로우를 실행한다.

1. 현재 브랜치와 상태를 먼저 확인 (`git branch`, `git status`)
2. 버전 번호가 명시되지 않으면 사용자에게 질문
3. 기능명이 명시되지 않으면 사용자에게 질문
4. 브랜치 생성 전 base 브랜치가 최신인지 확인 (`git pull`)
5. 브랜치 생성 후 자동으로 remote에 push (`-u` 플래그 사용)
6. PR 생성 시 `gh pr create` 사용
