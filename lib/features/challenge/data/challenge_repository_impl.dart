import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/challenge.dart';
import '../domain/challenge_repository.dart';
import '../domain/submission_method.dart';
import 'challenge_dto.dart';

class ChallengeRepositoryImpl implements ChallengeRepository {
  ChallengeRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.challenges);

  @override
  Stream<List<Challenge>> watchChallengesForClass({
    required String schoolCode,
    required String classCode,
  }) {
    return _collection
        .where('schoolCode', isEqualTo: schoolCode)
        .where('classCode', isEqualTo: classCode)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChallengeDto.fromSnapshot).toList());
  }

  @override
  Stream<List<Challenge>> watchChallengesForTeacher(String teacherId) {
    return _collection
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChallengeDto.fromSnapshot).toList());
  }

  @override
  Stream<Challenge?> watchChallenge(String challengeId) {
    return _collection
        .doc(challengeId)
        .snapshots()
        .map((doc) => doc.exists ? ChallengeDto.fromSnapshot(doc) : null);
  }

  @override
  Future<String> createChallenge({
    required String teacherId,
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
    required String schoolCode,
    required String classCode,
    required int? targetBookCount,
    required List<String> targetBooks,
    required List<SubmissionMethod> requiredMethods,
  }) async {
    final payload = ChallengeDto.toCreatePayload(
      teacherId: teacherId,
      title: title,
      description: description,
      start: start,
      end: end,
      schoolCode: schoolCode,
      classCode: classCode,
      targetBookCount: targetBookCount,
      targetBooks: targetBooks,
      requiredMethods: requiredMethods,
    );
    final doc = await _collection.add(payload);
    return doc.id;
  }
}
