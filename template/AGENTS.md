# AGENTS.md: 구현 담당 (Codex)

Codex는 **구현 담당**이다. 시안은 Claude Code가 Figma형 캔버스로 만든다.
보통 Claude Code의 `scripts/impl.sh`가 목표 rev와 변경 목록을 프롬프트로 넘겨 실행한다.

## 기술 스택
아직 정해지지 않았다. 첫 구현 때 `docs/requirements.md`의 `## 플랫폼`(웹/앱)과 시안을 보고 정한 뒤 아래에 기록하고, 이후에는 유지한다.
```
- 프레임워크/언어:
- 스타일링:
- 패키지 매니저:
- 실행 방법:
- 토큰 사용 방식: (웹은 design-system/design/tokens.css, 앱은 tokens.ts를 import 또는 복사. 복사본이면 경로)
```

## 구현 절차
1. **범위**: 프롬프트의 목표 rev와 변경 목록을 그대로 쓴다. `state.sh`와 `CHANGES.md`는 다시 읽지 않는다.
2. **최초 구현** (`implemented_rev` 0): `design-reference/README.md`, `docs/requirements.md`, `design-reference/canvas-source/` 전체, `design-system/DESIGN.md`를 읽는다.
3. **그 외**: 변경 목록의 항목만 처리한다.
   - 아트보드와 값(전→후)이 구체적인 항목은 **diff 없이** 바로 구현한다.
   - 새 아트보드이거나 모호한 항목만 diff를 본다. `README.md` 화면 구성 표에서 아트보드의 파일 이름을 찾아, 그 파일만 읽는다.
     ```
     git diff --stat design-r{implemented_rev}..design-r{목표} -- design-reference/canvas-source design-system
     git diff -U0 design-r{implemented_rev}..design-r{목표} -- {필요한 파일}
     ```
   - REQ ID가 적힌 항목은 `docs/requirements.md`에서 그 ID만 찾아 읽는다.
4. **디자인 규칙**: UI 코드를 새로 쓰거나 스타일 판단이 필요할 때만 `design-system/DESIGN.md`를 세션당 한 번 읽고, 관련 상세 파일만 연다. `[토큰]`·`[동작]`만 바뀐 경우는 읽지 않는다.
5. **구현 규칙**: 값은 토큰만 쓴다. `[토큰]` 변경은 토큰 파일이 이미 갱신되어 있으므로, 앱 쪽에 복사본이 있을 때만 그 파일을 갱신한다.
6. **린트**: 웹/JS 계열 스택이면 첫 구현 때 `design-system/README.md` 안내대로 린트를 설정하고, `package.json`의 `lint` 스크립트 하나로 실행되게 묶는다. 샌드박스에서는 npm이 막힐 수 있으므로 직접 실행하지 않아도 된다. (`impl.sh`가 밖에서 실행한다) 프롬프트에 린트 오류가 주어지면 함께 고친다.
7. **마무리**: 커밋, `scripts/impl-done.sh` 실행, `STATE.md`·`CHANGES.md` 수정을 하지 않는다. `impl.sh`가 처리한다.
8. **보고**: 마지막 메시지에 구현한 rev, **사람이 시안과 비교해 볼 아트보드 목록**, 모호해서 판단을 미룬 점만 짧게 쓴다.

## 직접 요청받은 경우
프롬프트에 목표 rev가 없으면 `bash scripts/state.sh`로 목표 rev를 확인하고, `CHANGES.md`에서 그 rev 이하의 `## r번호` 항목만 읽어 같은 절차로 구현한다. 마무리는 사용자에게 `bash scripts/impl-done.sh {목표 rev} "요약"` 실행을 요청한다.

## 지켜야 할 것
- `design-reference/`, `design-system/`, `docs/`는 수정하지 않는다.
- 시안과 명세가 충돌하거나 항목이 모호하면 임의로 판단하지 말고 보고한다.
