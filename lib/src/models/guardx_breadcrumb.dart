class GuardXBreadcrumb {
  GuardXBreadcrumb({
    required this.message,
    this.data = const <String, dynamic>{},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  final DateTime timestamp;
  final String message;
  final Map<String, dynamic> data;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'message': message,
      'data': data,
    };
  }

  factory GuardXBreadcrumb.fromJson(Map<String, dynamic> json) {
    return GuardXBreadcrumb(
      timestamp: DateTime.parse(json['timestamp'] as String),
      message: json['message'] as String? ?? '',
      data: (json['data'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
  }
}
