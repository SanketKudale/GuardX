import 'package:flutter/material.dart';
import 'package:guardx/guardx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GuardX.init();
  GuardX.setUser(
    id: 'demo-user',
    email: 'demo@guardx.dev',
    name: 'Demo User',
  );
  GuardX.setTag('environment', 'example');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuardX Example',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const GuardXDemoPage(),
    );
  }
}

class GuardXDemoPage extends StatelessWidget {
  const GuardXDemoPage({super.key});

  Future<void> _throwFlutterError() async {
    throw StateError('Manual Flutter error button pressed');
  }

  Future<void> _throwAsyncError() async {
    Future<void>.delayed(const Duration(milliseconds: 100), () {
      throw ArgumentError('Uncaught async error from delayed future');
    });
  }

  Future<void> _addBreadcrumb() async {
    GuardX.addBreadcrumb(
      'User tapped Add Breadcrumb',
      data: <String, dynamic>{'source': 'demo_button'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GuardX Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: _throwFlutterError,
              child: const Text('Throw Flutter Error'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _throwAsyncError,
              child: const Text('Throw Async Error'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addBreadcrumb,
              child: const Text('Add Breadcrumb'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RecentEventsPage(),
                  ),
                );
              },
              child: const Text('View Recent Events'),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentEventsPage extends StatelessWidget {
  const RecentEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recent GuardX Events')),
      body: FutureBuilder<List<GuardXEvent>>(
        future: GuardX.getRecentEvents(limit: 20),
        builder: (BuildContext context, AsyncSnapshot<List<GuardXEvent>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<GuardXEvent> events = snapshot.data ?? <GuardXEvent>[];
          if (events.isEmpty) {
            return const Center(child: Text('No events yet.'));
          }
          return ListView.separated(
            itemCount: events.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (BuildContext context, int index) {
              final GuardXEvent event = events[index];
              return ListTile(
                title: Text(event.message),
                subtitle: Text(
                  '${event.errorType}\n${event.groupingKey}',
                ),
                isThreeLine: true,
                trailing: Text(event.timestamp.toLocal().toString()),
              );
            },
          );
        },
      ),
    );
  }
}
