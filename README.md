# -ENG

일상의 소리를 영어 리듬으로 바꾸고, 시각·청각·촉각으로 익히는 Flutter 앱 프로토타입입니다.

## 구현된 흐름

- 홈: 디바이스 상태, 주간 수집 현황, 최근 수집 단어
- 라이브러리: 컬러 단어 카드, 검색·리듬별 필터·즐겨찾기, 날짜별 수집 캘린더
- 리듬 수집: 소리 길이 기록 → 반복 패턴 확정 → 영어 음절 매칭 → 단어 변환
- 단어 학습: 실제 영어 TTS, 0.75x/1.0x/1.2x 속도, 재생과 동기화된 음절 하이라이트
- 텍스트 스캔: 수집 단어를 문장 안에서 찾아 리듬으로 재활성화
- 디바이스: 연결 상태, 진동 강도, 잡음 필터링 설정

## 개발 환경

- Flutter 3.47.0 stable
- Dart 3.13.0
- Android/Web TTS: `flutter_tts`
- Android 및 Web 플랫폼 파일 생성 완료
- Chrome 웹 실행 및 릴리스 빌드 검증 완료

Flutter의 Windows 경로 호환성을 위해 영문 프로젝트 연결 경로도 준비되어 있습니다.

```powershell
Set-Location C:\Users\user\develop\dash_eng_app
flutter pub get
flutter run -d chrome
```

웹 릴리스 빌드는 다음 명령으로 다시 생성할 수 있습니다.

```powershell
flutter build web --release
```

산출물은 `build/web`에 생성됩니다.

## Android 실행

Android Studio, API 36 SDK, NDK 28.2, Pixel 6 API 36 에뮬레이터 구성이 완료되어 있습니다. 가상 기기 이름은 `ENG_Pixel_6_API_36`입니다.

```powershell
flutter emulators --launch ENG_Pixel_6_API_36
flutter run -d emulator-5554
```

APK를 다시 만들려면 다음을 실행합니다.

```powershell
flutter build apk --debug
flutter build apk --release
```

산출물은 `build/app/outputs/flutter-apk/`에 생성됩니다.
