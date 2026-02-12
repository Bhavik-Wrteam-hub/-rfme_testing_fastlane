class ReportReason {
  ReportReason({
    required this.id,
    required this.reason,
    required this.translatedReason,
  });

  factory ReportReason.fromMap(Map<String, dynamic> map) {
    return ReportReason(
      id: map['id'] as int,
      reason: map['reason'] as String,
      translatedReason: map['translated_reason'] as String,
    );
  }
  final int id;
  final String reason;
  final String translatedReason;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reason': reason,
      'translated_reason': translatedReason,
    };
  }
}
