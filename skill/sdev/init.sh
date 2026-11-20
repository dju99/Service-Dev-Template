#!/usr/bin/env bash
# sdev 초기 세팅
# GitHub 템플릿 저장소의 template/ 폴더를 현재 폴더로 복사(덮어쓰지 않음) → git 초기화 → 초기 커밋 → design-r0 태그
# 사용: 대상 폴더에서 bash <스킬 폴더>/init.sh
set -uo pipefail

# ▼ 템플릿 저장소 설정. 저장소를 만든 뒤 주소를 넣는다.
#   REF: 비워 두면 저장소의 기본 브랜치를 가져온다. 버전을 고정하려면 태그(예: v1)를 넣는 것을 권장한다.
REPO_URL="${SDEV_REPO_URL:-https://github.com/dju99/Service-Dev-Template.git}"
REF="${SDEV_REF:-}"

TARGET="$(pwd)"
command -v git >/dev/null 2>&1 || { echo "오류: git이 없습니다. https://git-scm.com 에서 설치한 뒤 다시 실행하세요."; exit 1; }
case "$REPO_URL" in __REPO_URL__|"") echo "오류: 템플릿 저장소 주소가 설정되지 않았습니다. 스킬 폴더의 init.sh에서 REPO_URL을 설정하세요."; exit 1;; esac

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
branch_opt=(); [ -n "$REF" ] && branch_opt=(--branch "$REF")
if ! GIT_TERMINAL_PROMPT=0 git clone -q --depth 1 "${branch_opt[@]}" "$REPO_URL" "$tmp/repo" 2>"$tmp/err"; then
  echo "오류: 템플릿을 가져오지 못했습니다. ($REPO_URL, ${REF:-기본 브랜치})"
  echo "원인: $(tail -n 2 "$tmp/err" | tr '\n' ' ')"
  echo "인터넷 연결, 저장소 주소와 버전(REF)을 확인하세요. 비공개 저장소라면 이 PC의 git이 GitHub에 로그인되어 있어야 합니다. (터미널에서 git clone으로 한 번 접근해 로그인하면 저장됩니다.)"
  exit 1
fi
src="$tmp/repo/template"
[ -d "$src" ] || { echo "오류: 저장소에 template/ 폴더가 없습니다."; exit 1; }
sha=$(git -C "$tmp/repo" rev-parse --short HEAD)

created=(); skipped=()
while IFS= read -r -d '' f; do
  rel="${f#"$src"/}"
  if [ -e "$TARGET/$rel" ]; then
    skipped+=("$rel")
  else
    mkdir -p "$(dirname "$TARGET/$rel")" && cp "$f" "$TARGET/$rel" && created+=("$rel")
  fi
done < <(find "$src" -type f -print0 | sort -z)

echo "템플릿: $REPO_URL (${REF:-기본 브랜치}, $sha)"
echo "생성: ${#created[@]}개"
if [ ${#skipped[@]} -eq 0 ]; then echo "건너뜀: 없음"
elif [ ${#created[@]} -eq 0 ]; then echo "건너뜀: ${#skipped[@]}개 (모두 이미 있음, 재실행)"
else echo "건너뜀(이미 있음): ${#skipped[@]}개"; printf '  - %s\n' "${skipped[@]}"; fi

cd "$TARGET"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then git init -q && echo "git: 저장소 초기화"; fi

# 커밋 대상: 템플릿 경로의 파일 중 아직 커밋되지 않은 것 (이번에 만든 파일 + 이전 실행에서 커밋하지 못한 파일)
to_add=()
while IFS= read -r -d '' f; do
  rel="${f#"$src"/}"
  if [ -e "$rel" ] && ! git ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then to_add+=("$rel"); fi
done < <(find "$src" -type f -print0 | sort -z)

if [ -z "$(git config user.name || true)" ] || [ -z "$(git config user.email || true)" ]; then
  echo "git: user.name / user.email이 없어 커밋과 태그를 건너뜀. 아래 두 명령을 실행한 뒤 /sdev를 다시 실행하면 커밋과 태그만 이어서 처리합니다."
  echo '  git config --global user.name "내 이름"'
  echo '  git config --global user.email "내이메일@example.com"'
elif [ ${#to_add[@]} -eq 0 ]; then
  echo "git: 커밋할 템플릿 파일이 없음 (이미 커밋됨)"
else
  if git add -- "${to_add[@]}" && git commit -q -m "chore: sdev 초기 세팅 (template $sha)"; then
    echo "git: 초기 커밋 완료 (템플릿 파일 ${#to_add[@]}개)"
  else
    echo "git: 커밋 실패. 위 메시지를 확인하세요."
  fi
fi
if [ -n "$(git config user.name || true)" ] && git rev-parse -q --verify HEAD >/dev/null; then
  if git rev-parse -q --verify refs/tags/design-r0 >/dev/null; then echo "git: design-r0 태그 있음"
  else git tag design-r0 && echo "git: design-r0 태그 생성"; fi
fi
case "$TARGET" in *OneDrive*) echo "경고: 현재 폴더가 OneDrive 안에 있습니다. 동기화가 .git 폴더와 충돌해 저장소가 손상될 수 있으니 C:\\dev\\프로젝트이름 처럼 OneDrive 밖으로 옮기는 것을 권장합니다.";; esac
echo "다음 단계: docs/requirements.md에 플랫폼(웹/앱)과 큰 요구사항을 적고, 시안을 요청하세요. 시안이 정해지면 '구현'이라고 입력합니다. (Codex CLI 설치와 codex login 필요)"
