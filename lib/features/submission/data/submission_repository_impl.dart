import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/quiz_answer.dart';
import '../domain/submission.dart';
import '../domain/submission_repository.dart';
import '../domain/submission_status.dart';
import 'submission_dto.dart';

class SubmissionRepositoryImpl implements SubmissionRepository {
  SubmissionRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.submissions);

  @override
  Future<String> createSubmission({
    required String userId,
    required String challengeId,
    required String bookTitle,
    required Uint8List photoBytes,
    required String photoFileName,
    String? reviewText,
    List<QuizAnswer>? quizAnswers,
  }) async {
    // 제출 문서 id를 먼저 발급해 스토리지 경로에 사용한다.
    final docRef = _collection.doc();

    final storagePath = FirestorePaths.submissionPhotoStoragePath(
      uid: userId,
      submissionId: docRef.id,
      fileName: photoFileName,
    );
    final storageRef = _storage.ref(storagePath);
    await storageRef.putData(
      photoBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final photoUrl = await storageRef.getDownloadURL();

    final payload = SubmissionDto.toCreatePayload(
      userId: userId,
      challengeId: challengeId,
      bookTitle: bookTitle,
      photoUrl: photoUrl,
      reviewText: reviewText,
      quizAnswers: quizAnswers,
    );

    await docRef.set(payload);
    return docRef.id;
  }

  @override
  Stream<List<Submission>> watchSubmissionsForStudent(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SubmissionDto.fromSnapshot).toList());
  }

  @override
  Stream<List<Submission>> watchSubmissionsForChallenge(String challengeId) {
    return _collection
        .where('challengeId', isEqualTo: challengeId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SubmissionDto.fromSnapshot).toList());
  }

  @override
  Stream<List<Submission>> watchPendingSubmissionsForChallenges(
    List<String> challengeIds,
  ) {
    if (challengeIds.isEmpty) return Stream.value(const []);
    // Firestore whereIn은 최대 30개까지 지원한다. 학급당 챌린지 수가 그보다
    // 많아질 가능성은 낮다고 가정한다.
    final limited = challengeIds.take(30).toList();
    return _collection
        .where('challengeId', whereIn: limited)
        .where('status', isEqualTo: SubmissionStatus.pending.firestoreValue)
        .orderBy('submittedAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(SubmissionDto.fromSnapshot).toList());
  }

  @override
  Future<void> approve(String submissionId) => _collection.doc(submissionId).update({
        'status': SubmissionStatus.approved.firestoreValue,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewerNote': FieldValue.delete(),
      });

  @override
  Future<void> reject(String submissionId, {required String reason}) =>
      _collection.doc(submissionId).update({
        'status': SubmissionStatus.rejected.firestoreValue,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewerNote': reason,
      });
}
