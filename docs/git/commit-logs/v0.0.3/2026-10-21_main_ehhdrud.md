# fix(cli): Rename bin to avoid Windows prompt conflict

## 1. 기본 정보

| 항목 | 내용 |
|------|------|
| 작성자 | ehhdrud |
| 브랜치 | main |
| 날짜 | 2026-10-21 |
| 버전 | v0.0.3 |

---

## 2. 커밋 메시지

```
fix(cli): Rename bin to avoid Windows prompt conflict

Version: v0.0.3

Windows에서 sync가 실행되지 않던 문제를 bin 이름 변경으로 해결

- bin 이름을 prompt에서 ehhdrud-prompt로 변경 (cmd 내장 명령 충돌)
- cli.js의 name/version을 패키지와 일치하도록 갱신
- GUIDE.md 배포 절차 정리 및 배포 전 체크리스트(2.4) 추가
- CLAUDE.md에 bin 이름 규칙 추가
- VERSION, package.json 버전 0.0.3으로 상향
```

---

## 3. 변경 파일

| 상태 | 파일 | 설명 |
|------|------|------|
| M | packages/prompt/package.json | bin 이름 `ehhdrud-prompt`로 변경, 버전 0.0.3 |
| M | packages/prompt/bin/cli.js | `.name()`, `.version()` 갱신 |
| M | VERSION | 0.0.3 |
| M | GUIDE.md | 배포 절차 수정, 2.4 배포 전 체크리스트 추가 |
| M | CLAUDE.md | 배포 전 체크리스트 확인 및 bin 이름 규칙 추가 |
| A | docs/git/commit-logs/v0.0.3/2026-10-21_main_ehhdrud.md | 커밋 로그 |

---

## 4. 변경 배경 및 결과

Windows에서 `pnpm dlx @ehhdrud/prompt sync`를 실행하면 패키지 설치 로그만 출력되고 동기화가 전혀 수행되지 않았다. 원인은 CLI의 `bin` 이름 `prompt`가 Windows cmd 내장 명령 `prompt`와 겹쳐, 실행 시 CLI 대신 cmd 내장 명령이 에러 없이 실행된 것이다. v0.0.1부터 존재하던 문제다.

`bin` 이름을 OS 명령과 겹치지 않는 `ehhdrud-prompt`로 바꿔 해결했다. `bin`이 하나뿐이면 `pnpm dlx`가 자동으로 그것을 실행하므로, 사용자가 입력하는 명령은 `pnpm dlx @ehhdrud/prompt sync` 그대로다.

같은 실수를 반복하지 않도록 GUIDE.md에 배포 전 체크리스트를, CLAUDE.md에 규칙을 추가했다.

---

## 5. 중요 변경 사항

- `package.json`의 `bin` 키: `prompt` → `ehhdrud-prompt`
- 전역 설치 시 실행 명령이 `ehhdrud-prompt`로 바뀐다 (`pnpm dlx` 사용 시 영향 없음)
- 배포 버전 갱신 위치를 `VERSION`, `package.json`, `bin/cli.js` 세 곳으로 명시

---

## 6. 통계

| 항목 | 값 |
|------|-----|
| 변경 파일 수 | 6 |
| 추가 라인 | +27 (로그 제외) |
| 삭제 라인 | -10 (로그 제외) |

---

## 7. 요약

Windows PC에서 프롬프트 동기화 명령을 실행해도 아무 일도 일어나지 않던 문제를 고쳤다. 사용하는 명령어는 그대로이며, 이제 Windows에서도 정상적으로 스킬과 에이전트가 동기화된다. 다음 배포 때 같은 문제가 생기지 않도록 배포 체크리스트를 문서에 추가했다.
