import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_visit/data/local/in_memory_task_local_store.dart';
import 'package:my_visit/data/models/task_item.dart';
import 'package:my_visit/data/models/task_status.dart';
import 'package:my_visit/data/repository/task_repository.dart';
import 'package:my_visit/data/repository/task_repository_impl.dart';
import 'package:my_visit/presentation/screens/visits_screen.dart';
import 'package:my_visit/presentation/widgets/first_load_error_view.dart';
import 'package:my_visit/presentation/widgets/later_page_error_row.dart';
import 'package:my_visit/presentation/widgets/skeleton_shimmer_view.dart';
import 'package:my_visit/presentation/widgets/update_failed_banner.dart';
import 'package:my_visit/state/task_list_notifier.dart';
import 'package:my_visit/state/task_list_state.dart';
import 'fakes/fake_flaky_task_api.dart';

void main() {
  late FakeFlakyTaskApi fakeApi;
  late InMemoryTaskLocalStore localStore;
  late TaskRepository repository;

  setUp(() {
    fakeApi = FakeFlakyTaskApi();
    localStore = InMemoryTaskLocalStore();
    repository = TaskRepositoryImpl(api: fakeApi, localStore: localStore);
  });

  Widget buildTestableWidget({List<dynamic> overrides = const []}) {
    return ProviderScope(
      overrides: [
        taskLocalStoreProvider.overrideWithValue(localStore),
        taskRepositoryProvider.overrideWithValue(repository),
        ...overrides,
      ],
      child: const MaterialApp(
        home: VisitsScreen(),
      ),
    );
  }

  group('VisitsScreen UI States Tests', () {
    testWidgets('renders skeleton shimmer view on first load', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          overrides: [
            taskListProvider.overrideWith(() {
              return TaskListNotifier(
                repository: repository,
                initialState: const TaskListState(
                  isLoadingFirstPage: true,
                  tasks: [],
                ),
              );
            }),
          ],
        ),
      );

      expect(find.byType(SkeletonShimmerView), findsOneWidget);
      expect(find.text('My visits'), findsOneWidget);
    });

    testWidgets('renders first-page error view with retry button on initial load failure',
        (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FirstLoadErrorView(
              message: 'Simulated network error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text("Couldn't load your visits"), findsOneWidget);
      expect(find.text('Check your connection and try again.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('renders task list with status icons, untitled visits, and badges',
        (tester) async {
      final tasks = [
        TaskItem(
          id: 'task_1',
          title: 'Site visit #1',
          status: TaskStatus.done,
          updatedAt: DateTime.parse('2026-01-01T01:00:00.000Z'),
          syncStatus: SyncStatus.synced,
        ),
        TaskItem(
          id: 'task_2',
          title: 'Site visit #2',
          status: TaskStatus.done,
          updatedAt: DateTime.parse('2026-01-01T01:37:00.000Z'),
          syncStatus: SyncStatus.pending,
        ),
        TaskItem(
          id: 'task_4',
          title: 'Site visit #4',
          status: TaskStatus.open,
          updatedAt: DateTime.parse('2026-01-01T02:51:00.000Z'),
          syncStatus: SyncStatus.failed,
        ),
        TaskItem(
          id: 'task_53',
          title: null, // edge case: null title
          status: TaskStatus.done,
          updatedAt: DateTime.parse('2026-01-02T09:04:00.000Z'),
          syncStatus: SyncStatus.synced,
        ),
        TaskItem(
          id: 'task_89',
          title: 'Site visit #89',
          status: TaskStatus.archived, // edge case: archived status
          updatedAt: DateTime.parse('2026-01-03T07:16:00.000Z'),
          syncStatus: SyncStatus.synced,
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          overrides: [
            taskListProvider.overrideWith(() {
              return TaskListNotifier(
                repository: repository,
                initialState: TaskListState(
                  tasks: tasks,
                  isLoadingFirstPage: false,
                  unsyncedCount: 2,
                ),
              );
            }),
          ],
        ),
      );

      // Verify header unsynced count badge
      expect(find.text('2 unsynced'), findsOneWidget);

      // Verify row items
      expect(find.text('Site visit #1'), findsOneWidget);
      expect(find.text('Site visit #2'), findsOneWidget);
      expect(find.text('Site visit #4'), findsOneWidget);
      expect(find.text('Untitled visit'), findsOneWidget); // Null title fallback!
      expect(find.text('Site visit #89'), findsOneWidget);

      // Verify badges
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Not saved · Retry'), findsOneWidget);
      expect(find.text('Archived'), findsOneWidget);
    });

    testWidgets('renders empty search results when no visits match query',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          overrides: [
            taskListProvider.overrideWith(() {
              return TaskListNotifier(
                repository: repository,
                initialState: const TaskListState(
                  tasks: [],
                  searchQuery: 'visit #900',
                  isLoadingFirstPage: false,
                ),
              );
            }),
          ],
        ),
      );

      expect(find.text('No visits match "visit #900"'), findsOneWidget);
    });

    testWidgets('renders later-page error row at bottom of list without losing items',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          overrides: [
            taskListProvider.overrideWith(() {
              return TaskListNotifier(
                repository: repository,
                initialState: TaskListState(
                  tasks: [
                    TaskItem(
                      id: 'task_1',
                      title: 'Site visit #1',
                      status: TaskStatus.open,
                      updatedAt: DateTime.now().toUtc(),
                    ),
                  ],
                  isLoadingFirstPage: false,
                  nextPageError: 'Failed to load more',
                ),
              );
            }),
          ],
        ),
      );

      // Page 1 item still visible
      expect(find.text('Site visit #1'), findsOneWidget);
      // Later page error row visible at bottom
      expect(find.byType(LaterPageErrorRow), findsOneWidget);
      expect(find.text("Couldn't load more"), findsOneWidget);
    });

    testWidgets('floating update failed banner displays and triggers retry',
        (tester) async {
      bool retryTapped = false;
      bool dismissTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: UpdateFailedBanner(
                    taskTitle: 'Site visit #4',
                    onRetry: () => retryTapped = true,
                    onDismiss: () => dismissTapped = true,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text("Couldn't update Site visit #4"), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryTapped, isTrue);

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissTapped, isTrue);
    });

    testWidgets('responsive layout on 320dp width and 200% font scale has no overflow',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });

      FlutterErrorDetails? caughtDetails;
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };

      await tester.pumpWidget(
        buildTestableWidget(
          overrides: [
            taskListProvider.overrideWith(() {
              return TaskListNotifier(
                repository: repository,
                initialState: TaskListState(
                  tasks: [
                    TaskItem(
                      id: 'task_2',
                      title: 'Site visit #2',
                      status: TaskStatus.done,
                      updatedAt: DateTime.parse('2026-01-01T01:37:00.000Z'),
                      syncStatus: SyncStatus.pending,
                    ),
                    TaskItem(
                      id: 'task_4',
                      title: 'Site visit #4 with a very long address description',
                      status: TaskStatus.open,
                      updatedAt: DateTime.parse('2026-01-01T02:51:00.000Z'),
                      syncStatus: SyncStatus.failed,
                    ),
                  ],
                  isLoadingFirstPage: false,
                  unsyncedCount: 3,
                ),
              );
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();
      FlutterError.onError = originalOnError;

      expect(caughtDetails, isNull);
      expect(find.text('My visits'), findsOneWidget);
      expect(find.text('3 unsynced'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Not saved · Retry'), findsOneWidget);
    });
  });
}
