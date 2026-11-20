#!/usr/bin/env bash
# "구현" 트리거: 점검 → 구현 범위 정리 → codex exec 실행 → 최종 보고 출력
# 사용: bash scripts/impl.sh
set -uo pipefail
root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "오류: git 저장소가 아닙니다."; exit 1; }
cd "$root"
STATE=design-reference/STATE.md
CH=design-reference/CHANGES.md
REQ=docs/requirements.md
README=design-reference/README.md
get() { sed -n "s/^$1:[[:space:]]*//p" "$STATE" | head -n1 | tr -d '\r'; }
d=$(get design_rev); i=$(get implemented_rev)

if [ "$d" = "$i" ]; then echo "최신 상태: 구현할 변경 없음 (r$d)"; exit 0; fi
if ! git rev-parse -q --verify "refs/tags/design-r$d" >/dev/null; then
  echo "오류: design-r$d 태그가 없습니다. 시안 기록이 중간에 실패했을 수 있습니다. bash scripts/state.sh 로 점검하세요."; exit 1
fi
if [ -n "$(git status --porcelain -- design-reference/canvas-source design-system docs 2>/dev/null)" ]; then
  echo "참고: 커밋되지 않은 시안 변경이 있습니다. 이번 구현은 r$d까지만 반영합니다."
fi

# 최초 구현 전 확인
if [ "$i" = "0" ]; then
  platform=$(awk '/^## /{f=($0 ~ /^## 플랫폼/); next} f && NF {print; exit}' "$REQ" | tr -d '\r')
  case "$platform" in ''|'('*) echo "중단: docs/requirements.md의 '## 플랫폼'(웹/앱)이 비어 있습니다. 채운 뒤 다시 실행하세요."; exit 1;; esac
  rows=$(awk '/^## /{f=($0 ~ /^## 화면 구성/); n=0; next} f && /^\|/ {n++; if (n>2) {t=$0; gsub(/[|[:space:]]/,"",t); if (t!="") c++}} END{print c+0}' "$README")
  if [ "$rows" = "0" ]; then echo "중단: design-reference/README.md의 '화면 구성' 표가 비어 있습니다. Claude Code에 채워 달라고 한 뒤 다시 실행하세요."; exit 1; fi
fi

command -v codex >/dev/null 2>&1 || { echo "오류: codex CLI를 찾을 수 없습니다. 설치와 로그인(codex login)을 확인하세요."; exit 1; }

# 이번 범위(r$((i+1)) ~ r$d)의 변경 목록만 추출 (r-next 제외)
changes=$(awk -v lo="$i" -v hi="$d" '
  /^## r[0-9]+[[:space:]]*$/ { n=$2; gsub(/[^0-9]/,"",n); keep=(n+0>lo && n+0<=hi); if (keep) print; next }
  /^## / { keep=0; next }
  keep { print }' "$CH" | tr -d '\r')

if [ "$i" = "0" ]; then
  scope="최초 구현이다. AGENTS.md의 최초 구현 절차대로 읽는다."
else
  scope="state.sh와 CHANGES.md는 다시 읽지 않아도 된다. 이번 범위의 변경 목록은 아래와 같다."
fi
prompt="AGENTS.md 절차대로 구현한다.
목표 rev: $d (구현 범위: r$((i+1)) ~ r$d, 현재 implemented_rev: $i)
$scope
${changes:-(기록된 항목 없음)}

마무리는 반드시 bash scripts/impl-done.sh $d \"요약\" 으로 한다.
마지막 메시지는 이 형식으로만 쓴다:
- 구현: r$d
- 검수할 아트보드:
- 추가한 RULE ID:
- 판단을 미룬 점:"

echo "Codex 실행 중 (목표 r$d)..."
out=$(codex exec --sandbox workspace-write "$prompt" 2>/dev/null </dev/null); rc=$?
if [ $rc -ne 0 ]; then
  echo "오류: Codex 실행이 실패했습니다 (종료 코드 $rc). 터미널에서 codex login 상태를 확인하세요."
  [ -n "$out" ] && echo "$out" | tail -n 20
  exit 1
fi
echo "$out"
after=$(get implemented_rev)
if [ "$after" != "$d" ]; then
  echo "경고: implemented_rev가 아직 $after 입니다. Codex가 마무리 스크립트를 실행하지 못했을 수 있습니다. 변경 내용을 확인한 뒤 bash scripts/impl-done.sh $d \"요약\" 을 실행하세요."
fi
