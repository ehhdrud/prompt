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
cd packages/prompt

# 버전 올리기 (patch: 0.0.1 → 0.0.2)
npm version patch

# 배포
npm publish
```

성공 시 `https://github.com/ehhdrud?tab=packages`에서 확인 가능.
