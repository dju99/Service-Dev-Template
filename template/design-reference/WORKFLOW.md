# WORKFLOW: 시안 → 개발 작업 안내 (사람용)

이 파일은 사람이 읽는 설명서다. Claude Code와 Codex는 각각 `CLAUDE.md`, `AGENTS.md`의 절차만 따르며, 이 파일은 읽지 않아도 된다.
절차를 바꿀 때는 `CLAUDE.md`, `AGENTS.md`를 고치고 이 파일의 설명도 맞춰 둔다.

## 역할
| | 담당 | 수정하는 곳 |
|---|---|---|
| Claude Code | 시안, 디자인 토큰, 요구사항, 변경 기록 | `design-reference/`, `design-system/`, `docs/` |
| Codex | 구현 | `src/`와 루트 설정 파일, `requirements.md`의 "동작 규칙" 섹션 |
| 사람 | 요구사항 작성, 디자인 규칙 관리, 구현 검수 | `docs/requirements.md`, `design-system/` |

## 폴더와 파일
| 경로 | 내용 |
|---|---|
| `CLAUDE.md`, `AGENTS.md` | 각 도구의 절차. 세션 시작 때 자동으로 읽힌다 |
| `docs/requirements.md` | 플랫폼(웹/앱), 큰 요구사항(`REQ-`), 동작 규칙(`RULE-`) |
| `design-system/` | 디자인 규칙과 토큰 (`DESIGN.md`가 입구) |
| `design-reference/STATE.md` | `design_rev`, `implemented_rev`, 아티팩트 URL |
| `design-reference/CHANGES.md` | 아직 구현되지 않은 변경 목록 |
| `design-reference/README.md` | 화면 구성(아트보드 목록), 데이터 모델 |
| `design-reference/canvas-source/` | Figma형 캔버스 시안 원본 |
| `scripts/` | 상태 확인과 커밋을 처리하는 스크립트 |

## 스크립트
| 명령 | 누가 | 하는 일 |
|---|---|---|
| `bash scripts/state.sh` | 누구나 | 현재 rev, 구현 필요 범위, 어긋남 경고 출력 |
| `bash scripts/design-commit.sh "요약"` | Claude Code | `design_rev` +1, `## r-next`에 번호 부여, 커밋, `design-r번호` 태그 |
| `bash scripts/impl.sh` | Claude Code ("구현" 입력 시) | 상태 점검, 최초 구현 전 확인, 구현 범위 정리, `codex exec` 실행, 최종 보고 출력 |
| `bash scripts/impl-done.sh 목표rev "요약"` | Codex | `implemented_rev` 기록, 목표 rev 이하 CHANGES 삭제, 커밋 (시안 폴더 제외) |

## 흐름
1. 빈 폴더에서 `/sdev`를 실행한다.
2. `docs/requirements.md`에 플랫폼(웹/앱)과 큰 요구사항을 쓴다.
3. Claude Code에 시안을 요청한다. 첫 아티팩트가 만들어지면 URL이 바로 `STATE.md`에 기록된다.
4. 시안을 다듬는다. 수정할 때마다 Claude Code가 캔버스 수정, 게시, 규칙 검사, 기록, 커밋까지 처리하고 `r번호 반영 완료` 한 줄로 보고한다.
5. 시안이 어느 정도 정해지면 Claude Code에 **`구현`** 이라고만 입력한다. Claude Code가 `scripts/impl.sh`로 Codex를 실행하고, 끝나면 검수할 아트보드 목록을 전달한다.
   - 실행 중에는 그 Claude Code 세션이 Codex가 끝날 때까지 기다린다. 그동안 시안을 고치려면 Claude Code 세션을 하나 더 연다.
   - Codex를 직접 쓰고 싶으면 Codex에 `AGENTS.md 절차대로 최신 시안 변경분만 구현해줘`라고 요청해도 같은 절차로 동작한다.
6. **검수**: Codex가 보고한 아트보드를 아티팩트와 실제 화면으로 비교한다.
   - 구현이 시안과 다르면 Codex에 바로 수정을 요청한다.
   - 시안 자체를 바꾸고 싶으면 Claude Code에 요청한다. (4번으로 돌아감)
7. 4~6을 반복한다. 시안 수정과 구현은 동시에 진행해도 된다. Codex는 시작할 때의 rev까지만 구현하고, 그 뒤의 변경은 다음 요청에서 처리한다.

## 개발 시작 전 확인 (최초 구현)
- `requirements.md`의 `## 플랫폼`, `README.md`의 화면 구성 표는 `impl.sh`가 자동으로 확인하고, 비어 있으면 실행하지 않는다.
- 필요한 `[동작]` 규칙이 `CHANGES.md`에 남아 있는지는 사람이 한 번 훑어본다.

## CHANGES.md 예시
```
## r7
- [동작] 호가 클릭 시 주문 패널이 열림. 닫기는 바깥 영역 클릭 (REQ-021 신규, Desktop-Main)
- [추가] 종목 상세에 뉴스 탭 (Mobile-Detail)
- [삭제] 뉴스 카드 이미지 (Desktop-Main)
- [스타일] 관심종목 행 높이 44→40px (Desktop-Main)
- [토큰] --primary #087D81 → #0A8F94 (tokens.css, tokens.ts 갱신)
```
최초 구현 전에는 `[동작]`과 아트보드 추가·삭제만 기록된다.

## 토큰 소모를 줄이는 방법
Codex 한 번의 비용은 **고정 비용**(규칙 파일, 상태 확인)과 **변경 비용**(바뀐 부분을 읽고 `src/`를 고치는 일)으로 나뉜다. 변경이 작아도 고정 비용은 매번 든다.
1. **모아서 요청한다.** 새 화면이 확정되었거나 `[동작]` 변경이 있을 때 요청하고, `[스타일]`·`[토큰]` 변경은 모았다가 한 번에 요청한다. 중간에 되돌린 변경은 최종 차이만 남는다.
2. **구현 요청마다 새 Codex 세션을 쓴다.** `impl.sh`는 매번 새로 실행하므로 자동으로 지켜진다. Codex를 직접 쓸 때는 요청 하나가 끝나면 세션을 새로 시작한다.
3. `CHANGES.md`가 구체적이면 Codex가 diff를 읽지 않는다. 기록이 부실하다고 느끼면 Claude Code에 더 구체적으로 쓰라고 요청한다.

## 문제가 생겼을 때
- `bash scripts/state.sh`에서 "최신 태그와 design_rev가 다르다"는 경고가 나오면 Claude Code에 상태 점검을 요청한다.
- 두 도구가 동시에 커밋하면 `index.lock` 오류가 날 수 있다. 잠시 후 같은 명령을 다시 실행하면 된다.
- `requirements.md`를 Claude Code와 Codex가 같은 시간에 고치면 한쪽 커밋에 다른 쪽의 수정이 섞여 들어갈 수 있다. 내용은 보존되므로 큰 문제는 아니다.
