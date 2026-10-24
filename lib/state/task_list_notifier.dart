import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/flaky_task_api.dart';
import '../data/local/task_local_store.dart';
import '../data/models/task_item.dart';
import '../data/repository/task_repository.dart';
import '../data/repository/task_repository_impl.dart';
import 'task_list_state.dart';

class TaskListNotifier extends Notifier<TaskListState> {
  TaskListNotifier({
    TaskRepository? repository,
    TaskListState? initialState,
    bool autoLoad = true,
  })  : _injectedRepo = repository,
        _initialState = initialState,
        _autoLoad = autoLoad;

  final TaskRepository? _injectedRepo;
  final TaskListState? _initialState;
  final bool _autoLoad;
  late final TaskRepository _repository;

  Timer? _debounceTimer;
  int _searchGeneration = 0;

  @override
  TaskListState build() {
    _repository = _injectedRepo ?? ref.read(taskRepositoryProvider);
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    if (_initialState != null) {
      return _initialState;
    }

    // Compute initial unsynced mutations count from local storage
    final initialUnsynced = _repository.localStore.getAllPendingMutations().length;

    // Trigger initial load and startup recovery only if autoLoad is enabled
    if (_autoLoad) {
      Future.microtask(() => _init());
    }

    return TaskListState(
      isLoadingFirstPage: true,
      unsyncedCount: initialUnsynced,
    );
  }

  Future<void> _init() async {
    // 1. First recover any pending mutations from local store
    _syncPendingMutationsInBackground();

    // 2. Fetch the first page of visits
    await loadInitial();
  }

  int _computeUnsyncedCount() {
    return _repository.localStore.getAllPendingMutations().length;
  }

  Future<void> _syncPendingMutationsInBackground() async {
    final pending = _repository.localStore.getAllPendingMutations();
    for (final mutation in pending) {
      if (mutation.isFailed) {
        // Do not auto-retry immediately if already marked failed, wait for user retry or next refresh
        continue;
      }
      final result = await _repository.syncMutation(mutation.taskId);
      if (result.isSuccess && result.updatedTask != null) {
        _applyConfirmedTask(result.updatedTask!);
      } else if (result.isFailed) {
        _markTaskFailedInState(mutation.taskId, result.errorMessage ?? 'Sync failed');
      }
    }
  }

  void _applyConfirmedTask(TaskItem confirmedTask) {
    final updated = state.tasks.map((t) {
      if (t.id == confirmedTask.id) {
        return confirmedTask;
      }
      return t;
    }).toList();

    state = state.copyWith(
      tasks: updated,
      unsyncedCount: _computeUnsyncedCount(),
    );
  }

  void _markTaskFailedInState(String taskId, String error) {
    final failedMutation = _repository.localStore.getMutation(taskId);
    final updated = state.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(
          syncStatus: SyncStatus.failed,
          lastError: error,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(
      tasks: updated,
      unsyncedCount: _computeUnsyncedCount(),
      lastFailedMutation: failedMutation,
    );
  }

  Future<void> loadInitial() async {
    final generation = ++_searchGeneration;
    state = state.copyWith(
      isLoadingFirstPage: true,
      clearFirstPageError: true,
      nextCursor: null,
      hasMore: true,
    );

    try {
      final result = await _repository.fetchTasks(
        cursor: null,
        query: state.searchQuery,
        limit: 20,
      );

      if (_searchGeneration != generation) {
        return; // Stale response discarded
      }

      state = state.copyWith(
        tasks: result.tasks,
        isLoadingFirstPage: false,
        nextCursor: result.nextCursor,
        clearNextCursor: result.nextCursor == null,
        hasMore: result.nextCursor != null,
        unsyncedCount: _computeUnsyncedCount(),
      );
    } catch (e) {
      if (_searchGeneration != generation) {
        return;
      }

      final errorMsg = e is ApiException
          ? e.message
          : (e is TimeoutException ? 'Connection timed out' : e.toString());

      state = state.copyWith(
        isLoadingFirstPage: false,
        firstPageError: errorMsg,
        unsyncedCount: _computeUnsyncedCount(),
      );
    }
  }

  Future<void> loadNextPage() async {
    if (state.isLoadingNextPage || !state.hasMore || state.nextCursor == null) {
      return;
    }

    final generation = _searchGeneration;
    state = state.copyWith(
      isLoadingNextPage: true,
      clearNextPageError: true,
    );

    try {
      final result = await _repository.fetchTasks(
        cursor: state.nextCursor,
        query: state.searchQuery,
        limit: 20,
        existingTasks: state.tasks,
      );

      if (_searchGeneration != generation) {
        return;
      }

      final combined = [...state.tasks, ...result.tasks];
      state = state.copyWith(
        tasks: combined,
        isLoadingNextPage: false,
        nextCursor: result.nextCursor,
        clearNextCursor: result.nextCursor == null,
        hasMore: result.nextCursor != null,
        unsyncedCount: _computeUnsyncedCount(),
      );
    } catch (e) {
      if (_searchGeneration != generation) {
        return;
      }

      final errorMsg = e is ApiException
          ? e.message
          : (e is TimeoutException ? 'Connection timed out' : 'Failed to load more');

      state = state.copyWith(
        isLoadingNextPage: false,
        nextPageError: errorMsg,
      );
    }
  }

  Future<void> refresh() async {
    // Preserve active search query and avoid showing full screen skeleton
    final generation = ++_searchGeneration;

    try {
      final result = await _repository.fetchTasks(
        cursor: null,
        query: state.searchQuery,
        limit: 20,
      );

      if (_searchGeneration != generation) {
        return;
      }

      state = state.copyWith(
        tasks: result.tasks,
        nextCursor: result.nextCursor,
        hasMore: result.nextCursor != null,
        clearFirstPageError: true,
        clearNextPageError: true,
        unsyncedCount: _computeUnsyncedCount(),
      );

      // Attempt to sync any pending mutations
      _syncPendingMutationsInBackground();
    } catch (_) {
      // Refresh failure should NOT erase usable loaded content
      // Maintain existing tasks and notify via subtle feedback if needed
    }
  }

  void onSearchChanged(String query) {
    if (query == state.searchQuery && !state.isLoadingFirstPage) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _executeSearch('');
  }

  Future<void> _executeSearch(String query) async {
    final generation = ++_searchGeneration;
    state = state.copyWith(
      searchQuery: query,
      isLoadingFirstPage: true,
      clearFirstPageError: true,
      tasks: const [],
      nextCursor: null,
      hasMore: true,
    );

    try {
      final result = await _repository.fetchTasks(
        cursor: null,
        query: query,
        limit: 20,
      );

      if (_searchGeneration != generation) {
        return; // Stale search result rejected!
      }

      state = state.copyWith(
        tasks: result.tasks,
        isLoadingFirstPage: false,
        nextCursor: result.nextCursor,
        clearNextCursor: result.nextCursor == null,
        hasMore: result.nextCursor != null,
        unsyncedCount: _computeUnsyncedCount(),
      );
    } catch (e) {
      if (_searchGeneration != generation) {
        return;
      }

      final errorMsg = e is ApiException
          ? e.message
          : (e is TimeoutException ? 'Connection timed out' : e.toString());

      state = state.copyWith(
        isLoadingFirstPage: false,
        firstPageError: errorMsg,
        unsyncedCount: _computeUnsyncedCount(),
      );
    }
  }

  Future<void> toggleTask(TaskItem task) async {
    if (task.status.isArchived) {
      return;
    }

    // 1. Optimistic update and durable save
    final optimistic = await _repository.toggleTaskStatus(task);

    final updatedTasks = state.tasks.map((t) {
      return t.id == task.id ? optimistic : t;
    }).toList();

    state = state.copyWith(
      tasks: updatedTasks,
      unsyncedCount: _computeUnsyncedCount(),
      clearLastFailedMutation: true,
    );

    // 2. Perform network synchronization
    final result = await _repository.syncMutation(task.id);

    if (result.isSuccess && result.updatedTask != null) {
      // Verify sequence before applying confirmed
      final currentList = state.tasks.map((t) {
        if (t.id == task.id &&
            t.pendingMutationSequence == optimistic.pendingMutationSequence) {
          return result.updatedTask!;
        }
        return t;
      }).toList();

      state = state.copyWith(
        tasks: currentList,
        unsyncedCount: _computeUnsyncedCount(),
      );
    } else if (result.isFailed) {
      _markTaskFailedInState(task.id, result.errorMessage ?? 'Sync failed');
    }
  }

  Future<void> retryMutation(String taskId) async {
    final pending = _repository.localStore.getMutation(taskId);
    if (pending == null) return;

    // Update in-memory task to inFlight state
    final inFlightList = state.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(
          syncStatus: SyncStatus.inFlight,
          clearLastError: true,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(
      tasks: inFlightList,
      clearLastFailedMutation: true,
    );

    final result = await _repository.syncMutation(taskId);

    if (result.isSuccess && result.updatedTask != null) {
      _applyConfirmedTask(result.updatedTask!);
    } else if (result.isFailed) {
      _markTaskFailedInState(taskId, result.errorMessage ?? 'Retry failed');
    }
  }

  void dismissFailedBanner() {
    state = state.copyWith(clearLastFailedMutation: true);
  }
}

// Manual provider declaration (No code generation!)
final taskListProvider = NotifierProvider<TaskListNotifier, TaskListState>(
  TaskListNotifier.new,
);

final flakyTaskApiProvider = Provider<FlakyTaskApi>((ref) {
  return FlakyTaskApi();
});

final taskLocalStoreProvider = Provider<TaskLocalStore>((ref) {
  throw UnimplementedError('Must override taskLocalStoreProvider in main()');
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    api: ref.watch(flakyTaskApiProvider),
    localStore: ref.watch(taskLocalStoreProvider),
  );
});
