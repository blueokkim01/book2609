import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/badge.dart';

class BadgeDto {
  const BadgeDto._();

  static ReadingBadge fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw StateError('badges/${doc.id} 문서가 존재하지 않습니다.');
    }
    return ReadingBadge(
      id: doc.id,
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      iconName: data['iconName'] as String? ?? 'emoji_events',
      criteriaDescription: data['criteriaDescription'] as String? ?? '',
    );
  }
}
