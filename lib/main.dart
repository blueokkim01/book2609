import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'features/notification/data/fcm_background_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 백그라운드 FCM 메시지 핸들러는 최상위 함수여야 한다.
  registerFcmBackgroundHandler();

  runApp(const ProviderScope(child: ReadingChallengeApp()));
}
