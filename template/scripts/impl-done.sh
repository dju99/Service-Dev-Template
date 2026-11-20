#!/usr/bin/env bash
# 구현 마무리: implemented_rev 기록, 목표 rev 이하 CHANGES 항목 삭제, 커밋 (시안 파일은 커밋하지 않음)
# 사용: bash scripts/impl-done.sh <목표rev> "요약"
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
target="${1:-}"; msg="${2:-구현}"
case "$target" in ''|*[!0-9]*) echo "사용법: bash scripts/impl-done.sh <목표rev> \"요약\""; exit 1;; esac
[ -n "$(git config user.name || true)" ] && [ -n "$(git config user.email || true)" ] || {
  echo "오류: git user.name / user.email이 설정되지 않았습니다."; exit 1; }
STATE=design-reference/STATE.md
CH=design-reference/CHANGES.md
d=$(sed -n 's/^design_rev:[[:space:]]*//p' "$STATE" | head -n1 | tr -d '\r')
i=$(sed -n 's/^implemented_rev:[[:space:]]*//p' "$STATE" | head -n1 | tr -d '\r')
if [ "$target" -le "$i" ] || [ "$target" -gt "$d" ]; then
  echo "오류: 목표 rev $target 이(가) 범위를 벗어났습니다. (implemented_rev $i, design_rev $d)"; exit 1
fi
bak=$(mktemp -d); cp "$STATE" "$CH" "$bak/"
trap 'cp "$bak/STATE.md" "$STATE"; cp "$bak/CHANGES.md" "$CH"; echo "오류: 중단되어 STATE.md와 CHANGES.md를 되돌렸습니다."' ERR
sed -i "s/^implemented_rev:.*/implemented_rev: $target/" "$STATE"
awk -v t="$target" '
  /^## r[0-9]+[[:space:]]*$/ { n=$2; gsub(/[^0-9]/,"",n); skip=(n+0<=t); if (skip) next }
  /^## / { skip=0 }
  !skip { print }
' "$CH" > "$CH.tmp" && mv "$CH.tmp" "$CH"
git add -A -- . ':(exclude)design-reference' ':(exclude)design-system'
git add "$STATE" "$CH"
git commit -q -m "impl: r$target $msg"
trap - ERR
echo "r$target 구현 기록 및 커밋 완료"
