#!/usr/bin/env bash
# 시안 수정 마무리: design_rev +1, CHANGES.md의 '## r-next'에 번호 부여, 커밋, 태그
# 사용: bash scripts/design-commit.sh "변경 요약"
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
msg="${1:-}"
[ -n "$msg" ] || { echo "사용법: bash scripts/design-commit.sh \"변경 요약\""; exit 1; }
[ -n "$(git config user.name || true)" ] && [ -n "$(git config user.email || true)" ] || {
  echo "오류: git user.name / user.email이 설정되지 않았습니다."; exit 1; }
STATE=design-reference/STATE.md
CH=design-reference/CHANGES.md
d=$(sed -n 's/^design_rev:[[:space:]]*//p' "$STATE" | head -n1 | tr -d '\r')
case "$d" in ''|*[!0-9]*) echo "오류: STATE.md의 design_rev를 읽을 수 없습니다."; exit 1;; esac
new=$((d+1))
if git rev-parse -q --verify "refs/tags/design-r$new" >/dev/null; then
  echo "오류: design-r$new 태그가 이미 있습니다. bash scripts/state.sh 로 점검하세요."; exit 1
fi
bak=$(mktemp -d); cp "$STATE" "$CH" "$bak/"
trap 'cp "$bak/STATE.md" "$STATE"; cp "$bak/CHANGES.md" "$CH"; echo "오류: 중단되어 STATE.md와 CHANGES.md를 되돌렸습니다."' ERR
sed -i "s/^design_rev:.*/design_rev: $new/" "$STATE"
sed -i "s/^## r-next[[:space:]]*$/## r$new/" "$CH"
git add design-reference design-system docs
git commit -q -m "design: r$new $msg"
git tag "design-r$new"
trap - ERR
echo "r$new 커밋 및 태그 완료"
