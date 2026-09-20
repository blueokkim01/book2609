import 'package:flutter/material.dart';

import '../../domain/submission_status.dart';

class SubmissionStatusBadge extends StatelessWidget {
  const SubmissionStatusBadge({super.key, required this.status});

  final SubmissionStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, textColor) = switch (status) {
      SubmissionStatus.pending => (Colors.amber.shade100, Colors.amber.shade900),
      SubmissionStatus.approved => (Colors.green.shade100, Colors.green.shade900),
      SubmissionStatus.rejected => (Colors.red.shade100, Colors.red.shade900),
    };

    return Chip(
      label: Text(status.displayName),
      backgroundColor: color,
      labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w600),
    );
  }
}
