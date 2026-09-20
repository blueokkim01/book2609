import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import '../domain/user_role.dart';
import 'user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<String?> authStateChanges() =>
      _auth.authStateChanges().map((user) => user?.uid);

  @override
  Stream<AppUser?> watchCurrentUserProfile(String uid) => _firestore
      .doc(FirestorePaths.userDoc(uid))
      .snapshots()
      .map((doc) => doc.exists ? UserDto.fromSnapshot(doc) : null);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    return UserDto.fromSnapshot(doc);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String nickname,
    required String schoolCode,
    required String classCode,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;

    final payload = UserDto.newUserPayload(
      role: role,
      nickname: nickname,
      schoolCode: schoolCode,
      classCode: classCode,
    );

    await _firestore.doc(FirestorePaths.userDoc(uid)).set(payload);

    final doc = await _firestore.doc(FirestorePaths.userDoc(uid)).get();
    return UserDto.fromSnapshot(doc);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> recordGuardianConsent({
    required String studentUid,
    required String consentBy,
  }) =>
      _firestore.doc(FirestorePaths.userDoc(studentUid)).update({
        'guardianConsent': {
          'consented': true,
          'consentAt': DateTime.now().toIso8601String(),
          'consentBy': consentBy,
        },
      });
}
