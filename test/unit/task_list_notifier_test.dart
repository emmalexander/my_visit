import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_visit/api/flaky_task_api.dart';
import 'package:my_visit/data/local/in_memory_task_local_store.dart';
import 'package:my_visit/data/models/task_item.dart';
import 'package:my_visit/data/models/task_status.dart';
import 'package:my_visit/data/repository/task_repository.dart';
import 'package:my_visit/data/repository/task_repository_impl.dart';
import 'package:my_visit/state/task_list_notifier.dart';
import 'package:my_visit/state/task_list_state.dart';
import '../fakes/fake_flaky_task_api.dart';

void main() {
  late FakeFlakyTaskApi fakeApi;
  late InMemoryTaskLocalStore localStore;
  late TaskRepository repository;
  late ProviderContainer container;

  setUp(() {
    fakeApi = FakeFlakyTaskApi();
    localStore = InMemoryTaskLocalStore();
    repository = TaskRepositoryImpl(api: fakeApi, localStore: localStore);

    container = ProviderContainer(
      overrides: [
        taskLocalStoreProvider.overrideWithValue(localStore),
        taskRepositoryProvider.overrideWithValue(repository),
        taskListProvider.overrideWith(
          () => TaskListNotifier(repository: repository, autoLoad: false),
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TaskListNotifier Pagination Tests', () {
    test('initial page load populates tasks and sets cursor', () async {
      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) async {
        return TaskPage([
          for (int i = 1; i <= 20; i++)
            {
              'id': 'task_$i',
              'title': 'Site visit #$i',
              'status': 'open',
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            }
        ], '20');
      };

      final notifier = container.read(taskListProvider.notifier);
      await notifier.loadInitial();

      final state = container.read(taskListProvider);
      expect(state.isLoadingFirstPage, isFalse);
      expect(state.tasks.length, equals(20));
      expect(state.nextCursor, equals('20'));
      expect(state.hasMore, isTrue);
    });

    test('loadNextPage appends subsequent page without replacing existing items',
        () async {
      int pageCount = 0;
      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) async {
        pageCount++;
        final start = cursor == null ? 1 : int.parse(cursor) + 1;
        return TaskPage([
          for (int i = start; i < start + 20; i++)
            {
              'id': 'task_$i',
              'title': 'Site visit #$i',
              'status': 'open',
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            }
        ], pageCount == 1 ? '20' : null);
      };

      final notifier = container.read(taskListProvider.notifier);
      await notifier.loadInitial();
      expect(container.read(taskListProvider).tasks.length, equals(20));

      await notifier.loadNextPage();
      final state = container.read(taskListProvider);
      expect(state.tasks.length, equals(40));
      expect(state.nextCursor, isNull);
      expect(state.hasMore, isFalse);
    });

    test('duplicate next-page request prevention', () async {
      final completer = Completer<TaskPage>();
      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) {
        if (cursor != null) {
          return completer.future;
        }
        return Future.value(TaskPage([
          {
            'id': 'task_1',
            'title': 'Site visit #1',
            'status': 'open',
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          }
        ], '1'));
      };

      final notifier = container.read(taskListProvider.notifier);
      await notifier.loadInitial();

      // Trigger loadNextPage twice while request is pending
      final f1 = notifier.loadNextPage();
      final f2 = notifier.loadNextPage();

      expect(container.read(taskListProvider).isLoadingNextPage, isTrue);

      completer.complete(TaskPage([
        {
          'id': 'task_2',
          'title': 'Site visit #2',
          'status': 'open',
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        }
      ], null));

      await f1;
      await f2;

      // Only one next-page fetch was issued
      expect(fakeApi.fetchCallsCount, equals(2)); // 1 initial + 1 next page
    });

    test('later-page failure preserves previously loaded tasks and allows retry',
        () async {
      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) async {
        if (cursor == null) {
          return TaskPage([
            {
              'id': 'task_1',
              'title': 'Site visit #1',
              'status': 'open',
              'updatedAt': DateTime.now().toUtc().toIso8601String(),
            }
          ], '1');
        }
        throw ApiException('Failed to load page 2');
      };

      final notifier = container.read(taskListProvider.notifier);
      await notifier.loadInitial();
      expect(container.read(taskListProvider).tasks.length, equals(1));

      // Attempt to load next page, which throws
      await notifier.loadNextPage();

      final state = container.read(taskListProvider);
      // Page 1 tasks MUST NOT be erased!
      expect(state.tasks.length, equals(1));
      expect(state.isLoadingNextPage, isFalse);
      expect(state.nextPageError, contains('Failed to load page 2'));

      // Now retry with working backend
      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) async {
        return TaskPage([
          {
            'id': 'task_2',
            'title': 'Site visit #2',
            'status': 'open',
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          }
        ], null);
      };

      await notifier.loadNextPage();
      final retriedState = container.read(taskListProvider);
      expect(retriedState.tasks.length, equals(2));
      expect(retriedState.nextPageError, isNull);
    });
  });

  group('TaskListNotifier Search and Race Condition Tests', () {
    test('rapid query changes: older response arriving late never replaces newer response',
        () async {
      final lagosCompleter = Completer<TaskPage>();
      final abujaCompleter = Completer<TaskPage>();

      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) {
        if (query == 'lagos') return lagosCompleter.future;
        if (query == 'abuja') return abujaCompleter.future;
        return Future.value(TaskPage([], null));
      };

      final notifier = container.read(taskListProvider.notifier);

      // User initiates search for Lagos (slow)
      notifier.onSearchChanged('lagos');
      // Wait past debounce
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // User immediately types Abuja (fast)
      notifier.onSearchChanged('abuja');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      // Abuja responds FIRST
      abujaCompleter.complete(TaskPage([
        {
          'id': 'task_abuja',
          'title': 'Site visit Abuja',
          'status': 'open',
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        }
      ], null));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Abuja results visible in state
      expect(container.read(taskListProvider).tasks.first.title,
          equals('Site visit Abuja'));

      // Lagos responds LATER (stale)
      lagosCompleter.complete(TaskPage([
        {
          'id': 'task_lagos',
          'title': 'Site visit Lagos',
          'status': 'open',
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        }
      ], null));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // CRITICAL ASSERTION: The late Lagos response must NOT overwrite Abuja!
      final finalState = container.read(taskListProvider);
      expect(finalState.searchQuery, equals('abuja'));
      expect(finalState.tasks.first.title, equals('Site visit Abuja'));
      expect(finalState.tasks.any((t) => t.title == 'Site visit Lagos'), isFalse);
    });

    test('clearing search immediately resets query and pagination', () async {
      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) async {
        return TaskPage([
          {
            'id': (query == null || query.isEmpty) ? 'task_all' : 'task_filtered',
            'title': (query == null || query.isEmpty) ? 'All tasks' : 'Filtered task',
            'status': 'open',
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          }
        ], null);
      };

      final notifier = container.read(taskListProvider.notifier);
      notifier.onSearchChanged('filter');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(container.read(taskListProvider).tasks.first.title,
          equals('Filtered task'));

      // Clear search
      notifier.clearSearch();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(taskListProvider);
      expect(state.searchQuery, isEmpty);
      expect(state.tasks.first.title, equals('All tasks'));
    });

    test('empty search results displays empty search state', () async {
      fakeApi.customFetchHandler = ({cursor, query, limit = 20}) async {
        return TaskPage([], null);
      };

      final notifier = container.read(taskListProvider.notifier);
      notifier.onSearchChanged('nonexistent');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      final state = container.read(taskListProvider);
      expect(state.tasks, isEmpty);
      expect(state.showEmptySearch, isTrue);
    });
  });

  group('TaskListNotifier Optimistic Status Updates and Synchronization', () {
    test('optimistic toggle updates UI instantly and reconciles with server on success',
        () async {
      final task = TaskItem(
        id: 'task_1',
        title: 'Site visit #1',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      final notifier = container.read(taskListProvider.notifier);
      // Seed state with task_1
      notifier.state = TaskListState(tasks: [task]);

      final updateCompleter = Completer<Map<String, dynamic>>();
      fakeApi.customUpdateHandler = (id, status) => updateCompleter.future;

      // Tap toggle
      final toggleFuture = notifier.toggleTask(task);
      await Future<void>.delayed(Duration.zero);

      // Instant optimistic update
      final optimisticState = container.read(taskListProvider);
      expect(optimisticState.tasks.first.status, equals(TaskStatus.done));
      expect(optimisticState.tasks.first.syncStatus, equals(SyncStatus.pending));
      expect(optimisticState.unsyncedCount, equals(1));

      // Server acknowledges
      updateCompleter.complete({
        'id': 'task_1',
        'title': 'Site visit #1',
        'status': 'done',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });

      await toggleFuture;

      final confirmedState = container.read(taskListProvider);
      expect(confirmedState.tasks.first.status, equals(TaskStatus.done));
      expect(confirmedState.tasks.first.syncStatus, equals(SyncStatus.synced));
      expect(confirmedState.unsyncedCount, equals(0));
    });

    test('failed update marks task failed, exposes lastFailedMutation, and allows retry',
        () async {
      final task = TaskItem(
        id: 'task_4',
        title: 'Site visit #4',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      final notifier = container.read(taskListProvider.notifier);
      notifier.state = TaskListState(tasks: [task]);

      fakeApi.customUpdateHandler = (id, status) async {
        throw ApiException('Server error (simulated)');
      };

      await notifier.toggleTask(task);

      final failedState = container.read(taskListProvider);
      // Task remains optimistically 'done', but syncStatus is failed
      expect(failedState.tasks.first.status, equals(TaskStatus.done));
      expect(failedState.tasks.first.syncStatus, equals(SyncStatus.failed));
      expect(failedState.lastFailedMutation, isNotNull);
      expect(failedState.lastFailedMutation!.taskId, equals('task_4'));
      expect(failedState.lastFailedMutation!.taskTitle, equals('Site visit #4'));

      // Dismiss banner
      notifier.dismissFailedBanner();
      expect(container.read(taskListProvider).lastFailedMutation, isNull);

      // Now retry when backend is healthy
      fakeApi.customUpdateHandler = (id, status) async {
        return {
          'id': 'task_4',
          'title': 'Site visit #4',
          'status': status,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        };
      };

      await notifier.retryMutation('task_4');
      final retriedState = container.read(taskListProvider);
      expect(retriedState.tasks.first.syncStatus, equals(SyncStatus.synced));
      expect(retriedState.unsyncedCount, equals(0));
    });
  });
}
