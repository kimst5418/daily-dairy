# 나의 일기장 📖

개인용 안드로이드 일기장 앱. WebView 껍데기 + HTML 본체 구조로, 코드를 이 레포에 푸시하면 앱이 자동으로 업데이트를 받아온다.

## 구조

- `diary-app/assets/index.html` — 앱 본체 (UI, 기능 전부). **여길 수정하면 앱이 업데이트됨**
- `version.json` — 배포 버전 번호. HTML 수정 후 `ver`를 1 올려서 같이 푸시해야 앱이 새 버전을 받음
- `diary-app/smali/` — 네이티브 코드 (WebView 셸 + 파일 저장 브릿지). 거의 수정할 일 없음
- `diary-app/build_apk.py` — APK 빌드 + 서명 스크립트
- `나의일기장.apk` — 서명된 설치 파일

## 업데이트 배포 방법

1. `diary-app/assets/index.html` 수정
2. 파일 안의 `var APP_VER = N;`을 1 올림
3. `version.json`의 `ver`도 같은 값으로 올림
4. `git push`

앱은 하루에 한 번(또는 설정 → 지금 확인) 새 버전을 확인하고, 다운로드 후 다음 실행부터 적용된다.
문제가 생기면 앱 설정에서 "내장 버전으로 복원"을 누르면 APK에 들어있는 버전으로 돌아간다.

## 데이터

일기 데이터는 폰 내부 저장소(`diary.json`)에만 저장되며 이 레포와 무관하다.
