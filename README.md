# GuardX

GuardX is an MVP crash logging plugin for Flutter. It captures framework and async uncaught errors, enriches them with breadcrumbs/tags/user context, and stores events locally as JSON lines.

## Quick Start

```dart
import 'package:guardx/guardx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GuardX.init(
    config: const GuardXConfig(
      logFileName: 'guardx_events.log',
      maxBreadcrumbs: 50,
    ),
  );
  runApp(const MyApp());
}
```

Capture manually:

```dart
try {
  throw StateError('Example error');
} catch (error, stack) {
  await GuardX.captureException(
    error,
    stack,
    context: {'screen': 'checkout'},
  );
}
```

## Example Screenshots

Placeholder:
- `example/screenshots/home.png`
- `example/screenshots/events.png`

## API Reference

- `GuardX.init({GuardXConfig config})`
- `GuardX.captureException(Object error, StackTrace stack, {Map<String, dynamic>? context})`
- `GuardX.addBreadcrumb(String message, {Map<String, dynamic>? data})`
- `GuardX.setUser({String? id, String? email, String? name})`
- `GuardX.setTag(String key, String value)`
- `GuardX.getRecentEvents({int limit = 20})`
