# 설정 가이드

## 1. 사용 가이드 (다른 프로젝트에서 동기화)

### 1.1 최초 설정 (한 번만)

#### 1. GitHub Token 생성

1. https://github.com/settings/tokens 접속
2. **Generate new token (classic)** 클릭
3. 권한 선택: `repo`, `read:packages`
4. 토큰 복사 (다시 볼 수 없음)

#### 2. .npmrc 설정

```bash
# Windows PowerShell
Set-Content -Path "$env:USERPROFILE\.npmrc" -Value "@ehhdrud:registry=https://npm.pkg.github.com`n//npm.pkg.github.com/:_authToken=발급받은토큰"

# Mac/Linux
echo "@ehhdrud:registry=https://npm.pkg.github.com" >> ~/.npmrc
echo "//npm.pkg.github.com/:_authToken=발급받은토큰" >> ~/.npmrc
```

> 토큰 값에 따옴표나 이스케이프 문자가 섞이지 않도록 `_authToken=ghp_...` 형태로 입력한다.

#### 3. .npmrc 확인

```bash
# Windows PowerShell
Get-Content "$env:USERPROFILE\.npmrc"

# Mac/Linux
cat ~/.npmrc
```

설정이 제대로 되었다면 다음과 같이 표시된다:
```
@ehhdrud:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=ghp_xxxxxxxxxxxx
```

### 1.2 동기화 실행

```bash
# 프로젝트 폴더에서
pnpm dlx @ehhdrud/prompt sync
```

> CLI는 `ehhdrud/prompt` 레포를 직접 clone하므로, npm 토큰과 별개로 해당 레포의 읽기 권한과 git 인증이 필요하다.

### 1.3 바로 사용

```bash
# Skills (슬래시 커맨드)
/review          # 코드 리뷰
/document        # 세션 작업 문서화
/debug           # 세션 기반 디버깅

# 또는 자연어로
"코드 리뷰해줘"
"방금 한 거 정리해줘"
"왜 안 돼?"
```

### 1.4 업데이트

원본 레포에 새 스킬/에이전트 추가 시 동일하게 실행:

```bash
pnpm dlx @ehhdrud/prompt sync
```

> 로컬에만 있는 커스텀 스킬/에이전트는 유지된다 (덮어쓰지 않음)

---

## 2. 배포 가이드 (CLI 패키지 업데이트)

### 2.1 GitHub Personal Access Token 생성

1. [GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. "Generate new token (classic)" 클릭
3. 권한 선택:
   - `write:packages` (패키지 업로드)
   - `read:packages` (패키지 다운로드)
   - `repo` (private repo 접근)
4. 토큰 복사해두기 (다시 볼 수 없음)

### 2.2 npm 인증

```bash
npm login --registry=https://npm.pkg.github.com

# Username: GitHub 사용자명
# Password: 위에서 생성한 토큰
# Email: GitHub 이메일
```

### 2.3 패키지 배포

```bash
# 1. 버전 올리기: VERSION, packages/prompt/package.json, bin/cli.js의 .version()을 같은 값으로 patch 업 후 커밋·push

# 2. 배포
cd packages/prompt
npm publish

# 3. 배포 확인 (새 버전이 목록에 있어야 함)
npm view @ehhdrud/prompt versions --registry https://npm.pkg.github.com
```

성공 시 `https://github.com/ehhdrud?tab=packages`에서 확인 가능.

### 2.4 배포 전 체크리스트

- [ ] **`bin` 이름이 OS 기본 명령과 겹치지 않는가** — 현재 `ehhdrud-prompt`. `prompt`, `sync`, `find`, `start`, `help` 같은 이름은 금지
- [ ] `VERSION`, `package.json`, `bin/cli.js`의 버전이 모두 같은가
- [ ] 배포 후 Windows에서 실제 실행해 출력이 나오는가

```bash
# 빈 폴더에서 실행 → "🔄 prompt 동기화 시작..."이 출력되어야 정상
pnpm dlx @ehhdrud/prompt sync --dry-run
```

> **주의 (v0.0.3에서 수정됨):** v0.0.2까지 `bin` 이름이 `prompt`였는데, Windows cmd 내장 명령 `prompt`와 충돌했다.
> `pnpm dlx @ehhdrud/prompt sync`가 설치 로그만 찍고 에러 없이 끝나면 이 문제다 (CLI 대신 cmd 내장 명령이 실행됨).
> 패키지 이름(`@ehhdrud/prompt`)과 `bin` 이름은 별개이며, `bin`이 하나뿐이면 `pnpm dlx`가 자동으로 그것을 실행하므로 사용 명령은 바뀌지 않는다.
