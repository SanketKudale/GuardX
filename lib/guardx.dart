import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'src/models/guardx_breadcrumb.dart';
import 'src/models/guardx_config.dart';
import 'src/models/guardx_event.dart';
import 'src/models/guardx_user.dart';
import 'src/storage/local_event_store.dart';

export 'src/models/guardx_config.dart';
export 'src/models/guardx_event.dart';
export 'src/models/guardx_user.dart';

class GuardX {
  GuardX._();

  static GuardXConfig _config = const GuardXConfig();
  static LocalEventStore? _store;
  static FlutterExceptionHandler? _previousFlutterErrorHandler;
  static ErrorCallback? _previousPlatformErrorHandler;
  static final List<GuardXBreadcrumb> _breadcrumbs = <GuardXBreadcrumb>[];
  static final Map<String, String> _tags = <String, String>{};
  static GuardXUser? _user;
  static bool _isInitialized = false;
  static bool _isCapturing = false;

  static Future<void> init({GuardXConfig config = const GuardXConfig()}) async {
    _config = config;
    _store = LocalEventStore(fileName: config.logFileName);
    _isInitialized = true;

    if (config.autoCaptureFlutterErrors) {
      _previousFlutterErrorHandler ??= FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        unawaited(
          captureException(
            details.exception,
            details.stack ?? StackTrace.current,
            context: <String, dynamic>{
              'library': details.library,
              'context': details.context?.toDescription(),
              'informationCollector':
                  details.informationCollector?.call().join('\n'),
            },
          ),
        );
        _previousFlutterErrorHandler?.call(details);
      };
    }

    if (config.autoCapturePlatformErrors) {
      _previousPlatformErrorHandler ??= PlatformDispatcher.instance.onError;
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        unawaited(captureException(error, stack));
        final bool previouslyHandled =
            _previousPlatformErrorHandler?.call(error, stack) ?? false;
        return previouslyHandled || config.markPlatformErrorsHandled;
      };
    }
  }

  static Future<void> captureException(
    Object error,
    StackTrace stack, {
    Map<String, dynamic>? context,
  }) async {
    if (_isCapturing) {
      return;
    }
    _isCapturing = true;
    try {
      if (!_isInitialized) {
        await init();
      }
      final GuardXEvent event = GuardXEvent.fromError(
        error: error,
        stackTrace: stack,
        breadcrumbs: List<GuardXBreadcrumb>.from(_breadcrumbs),
        tags: Map<String, String>.from(_tags),
        user: _user,
        extraContext: context,
      );
      await _store?.appendEvent(event);
    } catch (_) {
      // Never throw from the logger.
    } finally {
      _isCapturing = false;
    }
  }

  static void addBreadcrumb(String message, {Map<String, dynamic>? data}) {
    try {
      _breadcrumbs.add(
        GuardXBreadcrumb(
          message: message,
          data: data ?? <String, dynamic>{},
        ),
      );
      final int overflow = _breadcrumbs.length - _config.maxBreadcrumbs;
      if (overflow > 0) {
        _breadcrumbs.removeRange(0, overflow);
      }
    } catch (_) {
      // Never throw from the logger.
    }
  }

  static void setUser({String? id, String? email, String? name}) {
    try {
      if (id == null && email == null && name == null) {
        _user = null;
        return;
      }
      _user = GuardXUser(id: id, email: email, name: name);
    } catch (_) {
      // Never throw from the logger.
    }
  }

  static void setTag(String key, String value) {
    try {
      _tags[key] = value;
    } catch (_) {
      // Never throw from the logger.
    }
  }

  static Future<List<GuardXEvent>> getRecentEvents({int limit = 20}) async {
    try {
      if (!_isInitialized) {
        await init();
      }
      return await _store?.readRecentEvents(limit: limit) ?? <GuardXEvent>[];
    } catch (_) {
      return <GuardXEvent>[];
    }
  }
}
