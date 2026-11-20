# Service-Dev-Template (sdev 템플릿 저장소)

Claude Code의 `/sdev` 스킬이 새 프로젝트를 세팅할 때 가져가는 템플릿과, 그 스킬 자체를 담은 저장소입니다.

## 구성
```
template/     /sdev가 새 프로젝트 폴더로 그대로 복사하는 파일 (프로젝트 구조와 같음)
skill/sdev/   Claude Code 스킬 (SKILL.md, init.sh)
```

## 처음 설정
1. 이 저장소를 GitHub에 올린다.
2. `skill/sdev/init.sh`의 `REPO_URL`은 `https://github.com/dju99/Service-Dev-Template.git`으로 설정되어 있다. 저장소를 옮기면 이 값을 바꾼다.
3. `REF`를 비워 두면 기본 브랜치를 가져온다. 버전을 고정하려면 태그를 만들고(`git tag v1 && git push --tags`), `REF`를 `v1`로 바꾼다. (권장)
4. `skill/sdev` 폴더를 `~/.claude/skills/sdev`에 복사한다. (Windows: `C:\Users\내이름\.claude\skills\sdev`)

## 템플릿 고치기
- `template/` 안의 파일을 고치고 커밋한다.
- `REF`를 태그로 고정했다면 새 태그(`v2`)를 만들고 `init.sh`의 `REF`를 바꾼다. 이미 만든 프로젝트에는 영향이 없다.
- 각 프로젝트의 초기 커밋 메시지에 어떤 템플릿 커밋에서 만들었는지(`template abc1234`)가 남는다.

## 주의
- 비공개 저장소라면 각 PC의 git이 GitHub에 로그인되어 있어야 한다.
- `.sh` 파일은 줄바꿈이 LF여야 한다. `.gitattributes`가 이를 고정한다.
