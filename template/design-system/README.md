> **sdev 배치 안내**: 이 폴더는 프로젝트 루트의 `design-system/`에 놓인다. 아래 "쓰는 법" 1~2번은 sdev가 이미 처리했다(`CLAUDE.md`, `AGENTS.md`에 규칙이 들어 있다).
> 린트는 루트에서 설정 경로를 지정해 실행한다. 예: `npx stylelint --config design-system/.stylelintrc.json "src/**/*.css"`
> ESLint는 루트 `eslint.config.mjs`에서 `design-system/eslint.design.mjs`의 `designRules`를 import한다.
> 토큰 값(`design/tokens.css`, `design/tokens.ts`)은 Claude Code만 수정한다. Codex는 읽기만 한다.

# 디자인 시스템 파일 구성

```
DESIGN.md              항상 읽는 핵심 규칙 (짧게 유지)
design/
  tokens.css           웹용 토큰 — 값은 여기서만 정의
  tokens.ts            JS/RN용 토큰 — tokens.css와 같은 값
  foundations.md       색·글자·간격·모서리·그림자 사용 규칙
  components.md        컴포넌트별 상세 규칙 (§번호로 필요한 부분만)
  checklist.md         작업 후 자체 검사용
.stylelintrc.json      CSS 하드코딩 값 차단
eslint.design.mjs      JS/TS 하드코딩 값 차단
```

## 쓰는 법

1. 프로젝트 루트에 그대로 복사한다.
2. Claude Code라면 `CLAUDE.md`에 한 줄 추가: `UI 작업 전에 DESIGN.md를 읽고 따른다.`
3. 린트 설치
   ```
   npm i -D stylelint stylelint-declaration-strict-value
   npx stylelint "**/*.css"
   ```
   ESLint는 `eslint.config.mjs`에서 `designRules`를 import해 배열에 펼쳐 넣는다.
4. 메인 색은 민트(`--primary` #087D81 / 다크 #75DCD4)다. 색을 바꿀 땐 `tokens.css`·`tokens.ts` 두 파일만 고친다.

## 유지 규칙

- DESIGN.md는 40줄을 넘기지 않는다. 늘어나면 상세 파일로 옮긴다.
- 린트로 잡을 수 있는 규칙은 문서보다 린트에 추가한다.
- 잘 만든 컴포넌트가 생기면 `design/examples/`에 넣고 components.md 해당 섹션에서 "이 파일 패턴을 따른다"로 연결한다.
