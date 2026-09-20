// 이 파일은 자동 생성 placeholder입니다.
// 실제 배포 전 `flutterfire configure` 명령으로 재생성해야 합니다.
// 참고: https://firebase.google.com/docs/flutter/setup
// coverage:ignore-file
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// flutterfire configure 실행 전까지 사용되는 placeholder 옵션.
///
/// 실제 프로젝트에서는 `flutterfire configure`가 Firebase 콘솔의 값으로
/// 이 파일 전체를 덮어써야 한다. 아래 값들은 컴파일을 위한 더미 값이다.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions는 이 플랫폼에 대해 구성되지 않았습니다. '
          'flutterfire configure를 실행하세요.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'reading-challenge-app',
    storageBucket: 'reading-challenge-app.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'reading-challenge-app',
    storageBucket: 'reading-challenge-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'reading-challenge-app',
    storageBucket: 'reading-challenge-app.appspot.com',
    iosBundleId: 'com.example.readingChallenge',
  );
}
