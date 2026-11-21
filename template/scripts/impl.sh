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

LINTLOG="$(git rev-parse --git-dir)/sdev-lint.txt"   # 지난 구현의 린트 오류 (커밋되지 않는 위치)
BUILDLOG="$(git rev-parse --git-dir)/sdev-build.txt" # 지난 구현의 빌드 오류 (커밋되지 않는 위치)
if [ "$d" = "$i" ]; then
  echo "최신 상태: 구현할 변경 없음 (r$d)"
  [ -s "$LINTLOG" ] && echo "참고: 지난 구현의 린트 오류가 남아 있습니다. 다음 구현 때 함께 고칩니다."
  [ -s "$BUILDLOG" ] && echo "참고: 지난 구현의 빌드 오류가 남아 있습니다. 다음 구현 때 함께 고칩니다."
  exit 0
fi
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
lintnote=""
if [ -s "$LINTLOG" ]; then lintnote="지난 구현의 린트 오류도 함께 고친다:
$(head -n 40 "$LINTLOG")
"; fi
buildnote=""
if [ -s "$BUILDLOG" ]; then buildnote="지난 구현의 빌드 오류도 함께 고친다:
$(grep -iE "error|e: |failed|exception|unresolved" "$BUILDLOG" | head -n 40)
"; fi
prompt="AGENTS.md 절차대로 구현한다.
목표 rev: $d (구현 범위: r$((i+1)) ~ r$d, 현재 implemented_rev: $i)
$scope
${changes:-(기록된 항목 없음)}

${lintnote}${buildnote}
빌드와 린트는 직접 실행하지 않아도 된다. 구현이 끝나면 이 스크립트(impl.sh)가 밖에서 실행한다.
git 커밋과 scripts/impl-done.sh 실행은 하지 않는다. 구현이 끝나면 이 스크립트(impl.sh)가 기록과 커밋을 처리한다.
마지막 메시지는 이 형식으로만 쓴다:
- 구현: r$d
- 검수할 아트보드:
- 판단을 미룬 점:"

echo "Codex 실행 중 (목표 r$d)..."
errlog=$(mktemp)
out=$(codex exec --sandbox workspace-write "$prompt" 2>"$errlog" </dev/null); rc=$?
if [ $rc -ne 0 ]; then
  echo "오류: Codex 실행이 실패했습니다 (종료 코드 $rc). 아래는 Codex가 남긴 마지막 오류 메시지입니다."
  grep -iE "error|fail|denied|not found|unauthorized|invalid|model" "$errlog" | tail -n 8 | sed 's/^/  | /'
  [ -s "$errlog" ] && ! grep -qiE "error|fail|denied|not found|unauthorized|invalid|model" "$errlog" && tail -n 8 "$errlog" | sed 's/^/  | /'
  echo "자주 있는 원인: 모델 설정(~/.codex/config.toml의 model), 로그인(codex login), 네트워크."
  rm -f "$errlog"
  exit 1
fi
rm -f "$errlog"
echo "$out"

# 마무리: Codex 샌드박스는 .git에 쓸 수 없으므로 기록과 커밋은 여기서 처리한다.
n=$(git status --porcelain -- . ':(exclude)design-reference' ':(exclude)design-system' 2>/dev/null | grep -c . || true)
if [ "$n" = "0" ]; then echo "변경 파일: 0개 (코드 변경 없이 구현 완료로 기록합니다)"; else echo "변경 파일: ${n}개"; fi
bash scripts/impl-done.sh "$d" "구현" || {
  echo "경고: 구현은 끝났지만 기록과 커밋에 실패했습니다. 위 메시지를 확인한 뒤 bash scripts/impl-done.sh $d \"요약\" 을 실행하세요."
  exit 1
}

# 빌드: Codex 샌드박스에서는 Gradle·npm이 막힐 수 있으므로 여기서 실행한다.
# 명령을 바꾸려면 환경 변수 SDEV_BUILD_CMD를 쓴다. (예: SDEV_BUILD_CMD="./gradlew :app:assembleRelease")
build_cmd="${SDEV_BUILD_CMD:-}"
build_skip=""
if [ -z "$build_cmd" ]; then
  if [ -f gradlew ] || [ -f gradlew.bat ]; then
    # Gradle은 JDK가 필요하다. JAVA_HOME·PATH에 없으면 흔한 설치 위치(Android Studio 내장 JDK 등)를 찾는다.
    if [ -z "${JAVA_HOME:-}" ] && ! command -v java >/dev/null 2>&1; then
      for jh in "/c/Program Files/Android/Android Studio/jbr" "$HOME/AppData/Local/Programs/Android Studio/jbr" \
                "/Applications/Android Studio.app/Contents/jbr/Contents/Home" /c/Program\ Files/Java/jdk* \
                /c/Program\ Files/Eclipse\ Adoptium/jdk* /c/Program\ Files/Microsoft/jdk* "$HOME"/.jdks/*; do
        if [ -x "$jh/bin/java" ] || [ -x "$jh/bin/java.exe" ]; then export JAVA_HOME="$jh"; break; fi
      done
    fi
    if [ -z "${JAVA_HOME:-}" ] && ! command -v java >/dev/null 2>&1; then
      build_skip="JDK를 찾지 못해 빌드를 건너뜁니다. Android Studio를 설치하거나 JAVA_HOME을 설정하면 다음 구현부터 빌드합니다."
    elif [ -f gradlew.bat ] && case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) true;; *) false;; esac; then
      [ -n "${JAVA_HOME:-}" ] && export JAVA_HOME="$(cygpath -w "$JAVA_HOME" 2>/dev/null || echo "$JAVA_HOME")"
      build_cmd="cmd.exe //c '.\\gradlew.bat assembleDebug --console=plain'"
    else
      build_cmd="sh ./gradlew assembleDebug --console=plain"
    fi
  elif [ -f package.json ] && grep -qE '"build"[[:space:]]*:' package.json && [ -d node_modules ] && command -v npm >/dev/null 2>&1; then
    build_cmd="npm run -s build"
  fi
fi
if [ -n "$build_skip" ]; then
  rm -f "$BUILDLOG"; echo "참고: $build_skip"
elif [ -n "$build_cmd" ]; then
  echo "빌드 중: $build_cmd"
  if eval "$build_cmd" >"$BUILDLOG" 2>&1; then
    rm -f "$BUILDLOG"; echo "빌드: 통과"
  else
    echo "빌드: 실패. 다음 구현 때 Codex가 함께 고칩니다. 오류 줄:"
    { grep -iE "error|e: |failed|exception|unresolved" "$BUILDLOG" || tail -n 8 "$BUILDLOG"; } | head -n 8 | sed 's/^/  | /'
  fi
fi

# 린트: Codex 샌드박스에서는 npm이 막히므로 여기서 실행한다.
if [ -f package.json ] && grep -qE '"lint"[[:space:]]*:' package.json; then
  if [ -d node_modules ] && command -v npm >/dev/null 2>&1; then
    if npm run -s lint >"$LINTLOG" 2>&1; then
      rm -f "$LINTLOG"; echo "린트: 통과"
    else
      echo "린트: 오류 $(grep -c . "$LINTLOG")줄. 다음 구현 때 Codex가 함께 고칩니다. 마지막 몇 줄:"
      tail -n 8 "$LINTLOG" | sed 's/^/  | /'
    fi
  else
    echo "참고: 린트를 실행하지 않았습니다. 프로젝트 폴더에서 npm install을 한 번 실행하면 다음 구현부터 자동으로 실행됩니다."
  fi
fi
