import 'guardx_breadcrumb.dart';
import 'guardx_user.dart';

class GuardXEvent {
  GuardXEvent({
    required this.timestamp,
    required this.level,
    required this.errorType,
    required this.message,
    required this.stackTrace,
    required this.groupingKey,
    this.breadcrumbs = const <GuardXBreadcrumb>[],
    this.tags = const <String, String>{},
    this.user,
    this.deviceInfo,
    this.appInfo,
    this.extraContext = const <String, dynamic>{},
  });

  final DateTime timestamp;
  final String level;
  final String errorType;
  final String message;
  final String stackTrace;
  final String groupingKey;
  final List<GuardXBreadcrumb> breadcrumbs;
  final Map<String, String> tags;
  final GuardXUser? user;
  final Map<String, dynamic>? deviceInfo;
  final Map<String, dynamic>? appInfo;
  final Map<String, dynamic> extraContext;

  factory GuardXEvent.fromError({
    required Object error,
    required StackTrace stackTrace,
    List<GuardXBreadcrumb> breadcrumbs = const <GuardXBreadcrumb>[],
    Map<String, String> tags = const <String, String>{},
    GuardXUser? user,
    Map<String, dynamic>? extraContext,
  }) {
    final String stackTraceString = stackTrace.toString();
    final String errorType = error.runtimeType.toString();
    final String topFrame = _extractTopFrame(stackTraceString);
    return GuardXEvent(
      timestamp: DateTime.now().toUtc(),
      level: 'error',
      errorType: errorType,
      message: error.toString(),
      stackTrace: stackTraceString,
      groupingKey: '$errorType|$topFrame',
      breadcrumbs: breadcrumbs,
      tags: tags,
      user: user,
      deviceInfo: <String, dynamic>{
        'status': 'not_collected_in_mvp',
      },
      appInfo: <String, dynamic>{
        'status': 'not_collected_in_mvp',
      },
      extraContext: extraContext ?? <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timestamp': timestamp.toIso8601String(),
      'level': level,
      'errorType': errorType,
      'message': message,
      'stackTrace': stackTrace,
      'groupingKey': groupingKey,
      'breadcrumbs': breadcrumbs.map((GuardXBreadcrumb b) => b.toJson()).toList(),
      'tags': tags,
      'user': user?.toJson(),
      'deviceInfo': deviceInfo,
      'appInfo': appInfo,
      'extraContext': extraContext,
    };
  }

  factory GuardXEvent.fromJson(Map<String, dynamic> json) {
    return GuardXEvent(
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: json['level'] as String? ?? 'error',
      errorType: json['errorType'] as String? ?? 'UnknownError',
      message: json['message'] as String? ?? '',
      stackTrace: json['stackTrace'] as String? ?? '',
      groupingKey: json['groupingKey'] as String? ?? 'UnknownError|',
      breadcrumbs: (json['breadcrumbs'] as List? ?? <dynamic>[])
          .whereType<Map>()
          .map(
            (Map breadcrumb) =>
                GuardXBreadcrumb.fromJson(breadcrumb.cast<String, dynamic>()),
          )
          .toList(),
      tags: (json['tags'] as Map?)?.cast<String, String>() ?? <String, String>{},
      user: json['user'] is Map
          ? GuardXUser.fromJson((json['user'] as Map).cast<String, dynamic>())
          : null,
      deviceInfo: (json['deviceInfo'] as Map?)?.cast<String, dynamic>(),
      appInfo: (json['appInfo'] as Map?)?.cast<String, dynamic>(),
      extraContext: (json['extraContext'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
  }

  static String _extractTopFrame(String stackTrace) {
    final List<String> lines = stackTrace
        .split('\n')
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();
    return lines.isNotEmpty ? lines.first : 'unknown_top_frame';
  }
}
