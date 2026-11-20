#!/usr/bin/env bash
# 시안/구현 상태 확인. 사용: bash scripts/state.sh
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE=design-reference/STATE.md
CH=design-reference/CHANGES.md
get() { sed -n "s/^$1:[[:space:]]*//p" "$STATE" | head -n1 | tr -d '\r'; }
d=$(get design_rev); i=$(get implemented_rev); url=$(get artifact_url)
echo "design_rev: $d"
echo "implemented_rev: $i"
echo "artifact_url: ${url:-(없음)}"
latest=$(git tag -l 'design-r*' 2>/dev/null | sed 's/^design-r//' | sort -n | tail -n1)
if [ -n "$latest" ] && [ "$latest" != "$d" ]; then
  echo "경고: 최신 태그 design-r$latest 와 design_rev $d 가 다릅니다. 시안 기록이 중간에 실패했을 수 있습니다."
fi
if [ "$d" = "$i" ]; then
  echo "최신 상태: 구현할 변경 없음"
else
  echo "구현 필요: r$((i+1)) ~ r$d (목표 rev: $d)"
fi
if grep -q '^## r-next' "$CH" 2>/dev/null; then
  echo "참고: 아직 커밋되지 않은 시안 기록(## r-next)이 있습니다. 이번 구현 대상이 아닙니다."
fi
exit 0
