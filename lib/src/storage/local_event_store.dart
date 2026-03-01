import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/guardx_event.dart';

class LocalEventStore {
  LocalEventStore({required this.fileName});

  final String fileName;

  Future<File> _resolveFile() async {
    final Directory docs = await getApplicationDocumentsDirectory();
    if (!docs.existsSync()) {
      await docs.create(recursive: true);
    }
    final File file = File('${docs.path}${Platform.pathSeparator}$fileName');
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    return file;
  }

  Future<void> appendEvent(GuardXEvent event) async {
    final File file = await _resolveFile();
    final String line = jsonEncode(event.toJson());
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }

  Future<List<GuardXEvent>> readRecentEvents({int limit = 20}) async {
    final File file = await _resolveFile();
    if (!file.existsSync()) {
      return <GuardXEvent>[];
    }
    final List<String> lines = await file.readAsLines();
    final List<String> recent = lines.reversed
        .where((String line) => line.trim().isNotEmpty)
        .take(limit)
        .toList()
        .reversed
        .toList();
    final List<GuardXEvent> events = <GuardXEvent>[];
    for (final String line in recent) {
      try {
        final dynamic decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          events.add(GuardXEvent.fromJson(decoded));
        } else if (decoded is Map) {
          events.add(GuardXEvent.fromJson(decoded.cast<String, dynamic>()));
        }
      } catch (_) {
        // Ignore malformed line.
      }
    }
    return events;
  }
}
