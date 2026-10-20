import '../../../core/thresholds.dart';

/// Satu dokumen di Firestore `alert_logs`.
class AlertLog {
  const AlertLog({
    required this.id,
    required this.type,
    required this.parameter,
    required this.nilai,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  final String id;
  final ParamStatus type;
  final ParamKey parameter;
  final double nilai;
  final String title;
  final String description;
  final DateTime timestamp;
}
