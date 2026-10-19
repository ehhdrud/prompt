# Tailwind CSS v4 작성 규칙

AI는 Tailwind 클래스를 작성·수정할 때 아래 규칙을 따른다.

## 필수 규칙

- CSS 변수는 v4 축약 문법을 사용한다.
  - 금지: `bg-[var(--color)]`, `h-[var(--app-height)]`, `bg-[--color]`
  - 사용: `bg-(--color)`, `h-(--app-height)`
- spacing 값은 가능한 경우 Tailwind 스케일로 작성한다.
  - `w-[60px]` → `w-15`
  - `h-[56px]` → `h-14`
  - `gap-[18px]` → `gap-4.5`
  - 정확히 대응되는 값이 없을 때만 arbitrary value를 유지한다.
- 글자 크기는 프로젝트의 `text-N` 토큰만 사용한다.
  - 사용: `text-14`, `text-16`, `text-24`
  - 금지: `text-[14px]`, `text-sm`, `2xl:text-*`
- border와 CSS 변수는 canonical class를 사용한다.
  - `border-[1px]` → `border`
  - `bg-[var(--x)]` → `bg-(--x)`
- 클래스명은 문자열 조합으로 생성하지 않는다. 완성된 클래스 문자열을 매핑한다.

## v4 교체 문법

```text
!flex                         → flex!
hover:!bg-red-500             → hover:bg-red-500!
flex-shrink-0                 → shrink-0
flex-grow                     → grow
overflow-ellipsis             → text-ellipsis
bg-black bg-opacity-50        → bg-black/50
text-white text-opacity-70    → text-white/70
grid-cols-[max-content,auto]  → grid-cols-[max-content_auto]
focus:outline-none(v3 의도)   → focus:outline-hidden
ring(v3의 3px 의도)           → ring-3
scale-150 focus:transform-none → scale-150 focus:scale-none
```

## 주의할 동작 변경

- `button`은 v4에서 기본적으로 `cursor: default`다. 클릭 가능한 버튼에는 프로젝트 공통 버튼 클래스 또는 `cursor-pointer`를 적용한다.
- `border`와 `ring`의 기본 색상은 `currentColor`다. 디자인 색상이 필요하면 명시한다.
- 여러 variant를 중첩할 때는 v4의 왼쪽→오른쪽 적용 순서를 따른다.
  - `first:*:pt-0` → `*:first:pt-0`
- `hover:` 동작에 필수 기능을 의존하지 않는다. 터치 기기에서는 hover가 적용되지 않을 수 있다.
- 기존 파일을 수정할 때 같은 패턴을 전수 검색하고 동일 규칙으로 함께 정리한다.

## 작업 후 확인

1. Tailwind IntelliSense의 `suggestCanonicalClasses` 경고 확인
2. `git diff --check`
3. 변경 화면을 실제 브라우저에서 확인
