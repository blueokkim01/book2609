import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../domain/guardian_link.dart';
import '../domain/guardian_link_repository.dart';
import 'guardian_link_dto.dart';

class GuardianLinkRepositoryImpl implements GuardianLinkRepository {
  GuardianLinkRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.guardianLinks);

  @override
  Stream<List<GuardianLink>> watchLinksForParent(String parentUid) {
    return _collection
        .where('parentUid', isEqualTo: parentUid)
        .snapshots()
        .map((snap) => snap.docs.map(GuardianLinkDto.fromSnapshot).toList());
  }

  @override
  Future<void> createLink({
    required String parentUid,
    required String studentUid,
    required String consentBy,
  }) {
    final payload = GuardianLinkDto.toCreatePayload(
      parentUid: parentUid,
      studentUid: studentUid,
      consentBy: consentBy,
    );
    // 문서 id를 `{parentUid}_{studentUid}`로 고정해 firestore.rules가 학생
    // 문서를 읽을 권한이 있는지 exists() 한 번으로 판별할 수 있게 하고,
    // 동일 학부모-학생 조합의 중복 연결도 자연히 방지한다.
    return _collection.doc('${parentUid}_$studentUid').set(payload);
  }
}
