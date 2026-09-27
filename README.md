# Anima

Unreal Engine **5.8.3** Installed Build를 사용하는 C++ 빈 프로젝트입니다.
이 저장소에는 게임 프로젝트의 소스, 설정, 콘텐츠만 포함합니다. 언리얼 엔진 배포본은 별도로 준비해야 합니다.

## 폴더 배치

```text
작업 폴더/
├─ InstalledBuild/
│  └─ Engine/
└─ Anima/                 이 저장소
   ├─ Anima.uproject
   ├─ Config/
   ├─ Content/
   └─ Source/
```

프로젝트 스크립트는 형제 폴더인 `InstalledBuild`를 자동으로 찾습니다.

## 최초 설정과 실행

Windows에서 Visual Studio C++ 빌드 도구와 Windows SDK를 설치한 뒤, 프로젝트 폴더에서 실행합니다.

```powershell
.\SetupProject.cmd
.\OpenEditor.cmd
```

`SetupProject.cmd`는 엔진 경로를 현재 사용자의 레지스트리에 등록하고 IDE 파일 생성과 `Development Editor / Win64` 빌드를 수행합니다. 다른 위치에 엔진이 있다면 경로를 지정합니다.

```powershell
.\SetupProject.cmd -EngineRoot "D:\YourInstalledBuild"
```

이후 C++ 수정 사항은 에디터를 닫고 `BuildEditor.cmd`로 빌드합니다. `Anima.sln`이나 Rider의 `Anima.uproject` 지원을 사용해 개발할 수 있습니다.

현재 확인한 빌드 환경은 Visual Studio 2022의 MSVC 14.44와 Windows SDK 10.0.22621.0입니다. 빌드 스크립트는 설치 빌드에 포함된 .NET을 사용합니다.

## 프로젝트 구성

- `Source/Anima/`: 게임 런타임 모듈
- `Source/Anima.Target.cs`, `Source/AnimaEditor.Target.cs`: 게임과 에디터 빌드 타깃
- `Config/`: 기본 프로젝트 설정
- `Content/Maps/Main.umap`: 시작 맵
- `Scripts/Project.ps1`: 엔진 연결, IDE 생성, 빌드, 실행

## 버전 관리

`Source`, `Config`, `Content`, 프로젝트 실행 스크립트는 Git에 포함합니다. `Binaries`, `Intermediate`, `Saved`, `DerivedDataCache`, IDE 생성물, 개인 Perforce 접속 설정은 `.gitignore`로 제외합니다. `Build` 폴더는 패키징 리소스를 담을 수 있으므로 제외하지 않습니다.

언리얼의 `.uasset`과 `.umap`은 바이너리 파일입니다. 콘텐츠가 커지면 Git LFS 도입을 검토하세요. 바이너리만 제공되는 플러그인은 필요한 `Binaries` 경로를 `.gitignore`에 예외로 지정해야 합니다.

Perforce와 함께 사용할 때는 관리 중인 파일을 수정하기 전에 체크아웃합니다. `.p4ignore`는 Git 내부 데이터와 언리얼 생성물을 Perforce 추가 대상에서 제외합니다.
