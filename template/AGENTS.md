# AGENTS.md: 구현 담당 (Codex)

Codex는 **구현 담당**이다. 시안은 Claude Code가 Figma형 캔버스로 만든다. 이 파일의 절차만 따른다.

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
1. **시작**: 프롬프트에 목표 rev와 변경 목록이 주어졌으면 그대로 쓴다. (`state.sh`, `CHANGES.md`를 다시 읽지 않는다.) 주어지지 않았으면 `bash scripts/state.sh`를 실행해 "최신 상태"면 보고하고 끝내고, 아니면 출력의 **목표 rev**를 기억한다. 작업 중 시안이 더 바뀌어도 목표 rev까지만 구현한다.
2. **최초 구현** (`implemented_rev` 0): `design-reference/README.md`, `docs/requirements.md`, `CHANGES.md`의 `[동작]` 항목, `design-reference/canvas-source/` 전체, `design-system/DESIGN.md`를 읽는다.
3. **그 외**: 프롬프트로 받은 변경 목록을 쓴다. 받지 못했으면 `design-reference/CHANGES.md`에서 목표 rev 이하의 `## r번호` 항목만 읽는다. `## r-next`는 진행 중인 시안이므로 무시한다.
   - 아트보드와 값(전→후)이 구체적인 항목은 **diff 없이** 바로 구현한다.
   - 새 아트보드이거나 모호한 항목만 diff를 본다. 규모를 먼저 보고 필요한 파일만 읽는다.
     ```
     git diff --stat design-r{implemented_rev}..design-r{목표} -- design-reference/canvas-source design-system
     git diff -U0 design-r{implemented_rev}..design-r{목표} -- {필요한 파일}
     ```
   - REQ ID가 적힌 항목은 `docs/requirements.md`에서 그 ID만 찾아 읽는다.
4. **디자인 규칙**: UI 코드를 새로 쓰거나 스타일 판단이 필요할 때만 `design-system/DESIGN.md`를 세션당 한 번 읽고, 관련 상세 파일만 연다. `[토큰]`·`[동작]`만 바뀐 경우는 읽지 않는다.
5. **구현 규칙**: 값은 토큰만 쓴다. `[토큰]` 변경은 토큰 파일이 이미 갱신되어 있으므로, `src/`에 복사본이 있을 때만 그 파일을 갱신한다.
6. **린트**: 웹/JS 계열 스택이면 첫 구현 때 `design-system/README.md` 안내대로 한 번 설정한다. 이후에는 변경한 파일에만 실행하고 에러만 확인한다.
7. **동작 규칙 남기기**: 구현한 `[동작]` 중 REQ ID가 없고, 여러 화면에 걸치거나 이후에도 지켜야 하는 규칙은 `docs/requirements.md`의 "동작 규칙" 섹션에 `RULE-번호`로 한 줄 추가한다. 번호는 기존 `RULE-`의 다음 번호.
8. **마무리**: `bash scripts/impl-done.sh {목표 rev} "요약"`을 실행한다. `implemented_rev` 기록, 목표 rev 이하 CHANGES 항목 삭제, 커밋(시안 폴더 제외)을 한 번에 처리한다. `STATE.md`·`CHANGES.md` 수정이나 커밋을 직접 하지 않는다.
9. **보고**: 마지막 메시지에 구현한 rev, **사람이 시안과 비교해 볼 아트보드 목록**, 추가한 `RULE-` ID, 모호해서 판단을 미룬 점만 짧게 쓴다. (이 메시지가 Claude Code를 거쳐 사용자에게 전달된다.)

## 지켜야 할 것
- `design-reference/`와 `design-system/`은 수정하지 않는다. (스크립트가 처리하는 `STATE.md`, `CHANGES.md` 제외)
- `docs/requirements.md`에서는 "동작 규칙" 섹션에 추가만 한다. 기존 항목은 수정하지 않는다.
- 시안과 명세가 충돌하거나 항목이 모호하면 임의로 판단하지 말고 보고한다.
- git 명령이 환경 때문에 막히면 `CHANGES.md` 설명과 아트보드 이름으로 작업하고, 막혔다는 사실을 보고한다.
