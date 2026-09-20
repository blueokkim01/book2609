/// 독후감/한줄평/신고 사유 텍스트에 대한 간단한 금칙어 필터.
///
/// 요구사항 범위상 형태소 분석이나 AI 기반 판별은 사용하지 않고,
/// 단순 부분 문자열 매칭 수준으로 제한한다. 최종 진위·수위 판단은
/// 교사의 육안 검토와 학생 신고 기능이 보완한다.
class ProfanityFilter {
  const ProfanityFilter._();

  /// 데모/기본 금칙어 목록. 운영 시 학교 정책에 맞게 원격 설정으로
  /// 교체 가능하도록 확장할 수 있다.
  static const List<String> _blockedWords = <String>[
    '바보',
    '멍청이',
    '죽어',
    '병신',
    '씨발',
    '개새끼',
  ];

  /// 금칙어가 포함되어 있으면 true.
  static bool containsProfanity(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), '').toLowerCase();
    return _blockedWords.any(normalized.contains);
  }

  /// 금칙어를 '*'로 마스킹한 문자열을 반환한다(제출 자체는 막지 않고
  /// 표시 단계에서 순화하고 싶을 때 사용).
  static String mask(String text) {
    var result = text;
    for (final word in _blockedWords) {
      if (word.isEmpty) continue;
      result = result.replaceAll(word, '*' * word.length);
    }
    return result;
  }
}
