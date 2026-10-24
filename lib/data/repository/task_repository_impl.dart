import 'dart:async';
import '../../api/flaky_task_api.dart';
import '../local/task_local_store.dart';
import '../models/pending_mutation.dart';
import '../models/task_item.dart';
import '../models/task_status.dart';
import 'task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  TaskRepositoryImpl({
    required FlakyTaskApi api,
    required TaskLocalStore localStore,
  })  : _api = api,
        _localStore = localStore;

  final FlakyTaskApi _api;
  final TaskLocalStore _localStore;

  @override
  TaskLocalStore get localStore => _localStore;

  @override
  Future<TaskPageResult> fetchTasks({
    String? cursor,
    String query = '',
    int limit = 20,
    List<TaskItem> existingTasks = const [],
  }) async {
    final page = await _api.fetchTasks(
      cursor: cursor,
      query: query,
      limit: limit,
    );

    final rawTasks = page.items.map(TaskItem.fromApiMap).toList();
    final reconciledTasks = rawTasks.map(reconcileWithLocalState).toList();

    // Deduplicate tasks against existing loaded items to handle backend overlapping cursors
    final existingIds = existingTasks.map((t) => t.id).toSet();
    final uniqueTasks = <TaskItem>[];

    for (final task in reconciledTasks) {
      if (!existingIds.contains(task.id)) {
        existingIds.add(task.id);
        uniqueTasks.add(task);
      }
    }

    return TaskPageResult(
      tasks: uniqueTasks,
      nextCursor: page.nextCursor,
    );
  }

  @override
  Future<TaskItem> toggleTaskStatus(TaskItem task) async {
    if (task.status.isArchived) {
      return task;
    }

    final targetStatus = task.status.toggle();
    final sequence = _localStore.getNextSequenceNumber();

    final mutation = PendingMutation(
      taskId: task.id,
      targetStatus: targetStatus.value,
      taskTitle: task.displayTitle,
      originalServerStatus: task.status.value,
      createdAt: DateTime.now().toUtc(),
      sequenceNumber: sequence,
    );

    // 1. Durably persist user intent BEFORE initiating network call
    await _localStore.saveMutation(mutation);

    // 2. Return optimistic model for instant UI update
    return task.copyWith(
      status: targetStatus,
      syncStatus: SyncStatus.pending,
      pendingMutationSequence: sequence,
      clearLastError: true,
    );
  }

  @override
  Future<SyncResult> syncMutation(String taskId) async {
    final mutation = _localStore.getMutation(taskId);
    if (mutation == null) {
      return SyncResult(
        type: SyncResultType.success,
        taskId: taskId,
      );
    }

    try {
      final response = await _api.updateStatus(taskId, mutation.targetStatus);

      // Check whether a newer local mutation occurred while request was in-flight
      final currentMutation = _localStore.getMutation(taskId);
      if (currentMutation != null &&
          currentMutation.sequenceNumber > mutation.sequenceNumber) {
        return SyncResult(
          type: SyncResultType.superseded,
          taskId: taskId,
        );
      }

      // Reconcile and clean up durable queue
      await _localStore.removeMutation(taskId);
      final confirmed = TaskItem.fromApiMap(response).copyWith(
        syncStatus: SyncStatus.synced,
      );

      return SyncResult(
        type: SyncResultType.success,
        updatedTask: confirmed,
        taskId: taskId,
      );
    } catch (e) {
      // Check if superseded before marking failed
      final currentMutation = _localStore.getMutation(taskId);
      if (currentMutation != null &&
          currentMutation.sequenceNumber > mutation.sequenceNumber) {
        return SyncResult(
          type: SyncResultType.superseded,
          taskId: taskId,
        );
      }

      final errorMsg = e is ApiException
          ? e.message
          : (e is TimeoutException ? 'No response from server' : e.toString());

      await _localStore.markMutationFailed(taskId, errorMsg);

      return SyncResult(
        type: SyncResultType.failed,
        errorMessage: errorMsg,
        taskId: taskId,
      );
    }
  }

  @override
  Future<List<SyncResult>> syncAllPendingMutations() async {
    final pending = _localStore.getAllPendingMutations();
    final results = <SyncResult>[];
    for (final mutation in pending) {
      final result = await syncMutation(mutation.taskId);
      results.add(result);
    }
    return results;
  }

  @override
  TaskItem reconcileWithLocalState(TaskItem serverTask) {
    final mutation = _localStore.getMutation(serverTask.id);
    if (mutation == null) {
      return serverTask;
    }

    if (serverTask.status.value == mutation.targetStatus) {
      // Server already matches local intent (e.g. from prior timeout or background sync)
      _localStore.removeMutation(serverTask.id);
      return serverTask.copyWith(syncStatus: SyncStatus.synced);
    }

    // Local user intent is newer than server response
    return serverTask.copyWith(
      status: TaskStatus.fromString(mutation.targetStatus),
      syncStatus: mutation.isFailed ? SyncStatus.failed : SyncStatus.pending,
      pendingMutationSequence: mutation.sequenceNumber,
      lastError: mutation.lastError,
    );
  }
}
