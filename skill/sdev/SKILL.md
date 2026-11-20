---
name: sdev
description: 빈 폴더(또는 새 프로젝트 폴더)에 "시안 → 개발" 워크플로우 초기 세팅을 한 번에 만든다. GitHub 템플릿 저장소에서 CLAUDE.md, AGENTS.md, docs/requirements.md, design-system/(디자인 규칙·토큰), design-reference/(STATE·CHANGES·README·WORKFLOW·canvas-source), scripts/, src/ 를 가져와 복사하고 git 초기화·초기 커밋·design-r0 태그까지 처리한다. 사용자가 /sdev 를 입력하거나 "프로젝트 초기 세팅", "시안-개발 워크플로우 세팅", "CLAUDE.md AGENTS.md 만들어줘" 같은 요청을 하면 반드시 이 스킬을 사용한다.
---

# sdev: 시안-개발 워크플로우 초기 세팅

현재 폴더에서 이 SKILL.md와 같은 폴더에 있는 `init.sh`를 실행한다.

```
bash "<이 스킬 폴더>/init.sh"
```

- 사용자에게 아무것도 묻지 않는다.
- 스크립트가 템플릿 가져오기, 덮어쓰기 없는 복사, git 초기화, 초기 커밋, `design-r0` 태그, 경로 경고를 모두 처리한다.
- 출력 내용을 짧게 정리해 보고한다. (생성 개수, 건너뛴 파일, git 결과, 경고, 다음 단계)

## 실패했을 때
- 스크립트가 출력한 오류와 안내를 그대로 전달한다.
- **템플릿 파일을 직접 작성하거나 기억으로 만들어 내지 않는다.** 템플릿의 원본은 GitHub 저장소뿐이다. 가져오지 못하면 원인만 알리고 끝낸다.
- bash를 실행할 수 없는 환경이면, Git for Windows(bash 포함) 설치가 필요하다고 안내한다.
