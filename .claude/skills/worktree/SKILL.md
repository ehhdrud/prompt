---
name: worktree
description: Git worktree 관리 스킬. 브랜치별 독립 작업 환경을 생성/관리한다. 워크트리 생성(환경 셋업 포함), 목록 조회, 개발 서버 실행, 삭제/정리를 자동화한다. "워크트리", "worktree", "브랜치 병렬 작업", "동시 작업", "독립 작업 환경" 요청 시 사용.
---

# Git Worktree 관리

동일 레포에서 여러 브랜치를 독립 디렉토리로 동시 작업할 수 있게 한다.

## 워크트리 생성

기존 또는 새 브랜치로 워크트리를 생성하고 환경을 셋업한다.

```bash
bash <skill-path>/scripts/worktree-setup.sh <branch-name>
```

스크립트 동작:
1. `.gitignore`에 `.claude/worktrees/` 항목이 없으면 자동 추가
2. `.claude/worktrees/{branch-name}` 에 워크트리 생성 (슬래시는 하이픈으로 변환)
3. 프로젝트 루트의 `.env*` 파일 복사
4. 패키지 매니저 자동 감지 후 의존성 설치 (pnpm/yarn/bun/npm)

브랜치가 로컬에 없으면 HEAD 기준 새 브랜치를 생성한다.

워크트리 생성 완료 후, 사용자에게 **워크트리 디렉토리에서 새 Claude 세션을 시작하라고 안내**한다. 워크트리 경로에서 `claude`를 실행하면 cwd 자체가 워크트리가 되어 compact 후에도 작업 환경이 유지된다. 아래 명령어를 복사할 수 있게 제공한다:

```bash
cd <worktree-path> && claude
```

### WSL 환경 지원

WSL에서 실행 시 Node.js가 Windows에만 설치된 경우, 스크립트가 자동으로 `cmd.exe`를 통해 의존성 설치를 수행한다. 수동으로 설치해야 하는 경우:

```bash
# WSL에서 Windows 경로 변환 후 cmd.exe로 실행
WINPATH=$(wslpath -w <worktree-path>)
cmd.exe /c "cd /d $WINPATH && pnpm install"
```

## 목록 조회

```bash
git worktree list
```

## 개발 서버 실행

워크트리에서 개발 서버를 실행할 때 **포트 충돌을 방지**해야 한다.

```bash
cd <worktree-path>
pnpm dev -p 3001    # 기본 3000 대신 다른 포트 사용
```

WSL 환경에서 직접 실행이 안 되면 `cmd.exe`로 우회한다:

```bash
WINPATH=$(wslpath -w <worktree-path>)
cmd.exe /c "cd /d $WINPATH && pnpm dev -p 3001"
```

사용자에게 사용할 포트를 확인하거나, 기존 서버 포트와 겹치지 않는 포트를 제안한다.

## 커밋 및 푸시

워크트리에서의 git 작업은 원본 레포와 동일하게 동작한다. `.git` 히스토리를 공유하므로 별도 설정 없이 커밋/푸시가 가능하다.

```bash
cd <worktree-path>
git add .
git commit -m "feat: something"
git push origin <branch-name>
```

## 삭제/정리

```bash
# 워크트리만 삭제
bash <skill-path>/scripts/worktree-cleanup.sh <worktree-name>

# 워크트리 + 브랜치 함께 삭제
bash <skill-path>/scripts/worktree-cleanup.sh <worktree-name> --delete-branch
```

`<worktree-name>`은 디렉토리명 또는 전체 경로 모두 가능하다.

삭제 전 안전 체크:
- 커밋되지 않은 변경사항이 있으면 경고 후 확인 요청
- 푸시되지 않은 커밋이 있으면 경고 후 확인 요청

## .gitignore 설정

워크트리 폴더가 git에 추적되지 않도록 `.gitignore`에 반드시 추가해야 한다. setup 스크립트가 자동으로 추가하지만, 수동 생성 시 직접 확인할 것:

```gitignore
# Git worktrees
.claude/worktrees/
```

## 주의사항

- 하나의 브랜치는 하나의 워크트리에서만 체크아웃 가능
- 현재 체크아웃된 브랜치로는 워크트리 생성 불가
- `node_modules`, `.next`, `.env` 등 gitignore 대상 파일은 워크트리에 포함되지 않음 (스크립트가 .env 복사 및 의존성 설치를 자동 처리)
- 워크트리 삭제 전 반드시 커밋/푸시 여부를 확인할 것 (cleanup 스크립트가 자동 체크)
