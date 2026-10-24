import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/local/drift/drift_task_local_store.dart';
import 'presentation/screens/visits_screen.dart';
import 'state/task_list_notifier.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize durable SQLite local store via Drift
  final localStore = DriftTaskLocalStore();
  await localStore.init();

  runApp(
    ProviderScope(
      overrides: [
        taskLocalStoreProvider.overrideWithValue(localStore),
      ],
      child: const MyVisitsApp(),
    ),
  );
}

class MyVisitsApp extends StatelessWidget {
  const MyVisitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Visits',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const VisitsScreen(),
    );
  }
}
