import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository_impl.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// 현재 로그인된 Firebase Auth 사용자의 uid. 로그아웃 상태면 null 값을 emit.
final authStateProvider = StreamProvider<String?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// 로그인된 사용자의 Firestore 프로필(`users/{uid}`)을 실시간으로 구독한다.
/// `points`/`badgeIds`는 이 스트림을 통해 읽기 전용으로만 노출된다.
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final uidAsync = ref.watch(authStateProvider);
  return uidAsync.when(
    data: (uid) {
      if (uid == null) return Stream.value(null);
      return ref.watch(authRepositoryProvider).watchCurrentUserProfile(uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(null),
  );
});
