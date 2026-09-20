import 'package:equatable/equatable.dart';

/// 챌린지 진행 기간.
class ChallengePeriod extends Equatable {
  const ChallengePeriod({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  bool get isDeadlineNear {
    final remaining = end.difference(DateTime.now());
    return !remaining.isNegative && remaining <= const Duration(days: 1);
  }

  @override
  List<Object?> get props => [start, end];
}
