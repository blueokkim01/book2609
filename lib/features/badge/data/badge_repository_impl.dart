import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/badge.dart';
import '../domain/badge_repository.dart';
import 'badge_dto.dart';

class BadgeRepositoryImpl implements BadgeRepository {
  BadgeRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Stream<List<ReadingBadge>> watchAllBadges() {
    return _firestore
        .collection(FirestorePaths.badges)
        .snapshots()
        .map((snap) => snap.docs.map(BadgeDto.fromSnapshot).toList());
  }
}
