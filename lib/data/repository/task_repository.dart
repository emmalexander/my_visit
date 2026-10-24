import '../models/task_item.dart';
import '../local/task_local_store.dart';

class TaskPageResult {
  const TaskPageResult({
    required this.tasks,
    required this.nextCursor,
  });

  final List<TaskItem> tasks;
  final String? nextCursor;
}

enum SyncResultType {
  success,
  failed,
  superseded,
}

class SyncResult {
  const SyncResult({
    required this.type,
    this.updatedTask,
    this.errorMessage,
    required this.taskId,
  });

  final SyncResultType type;
  final TaskItem? updatedTask;
  final String? errorMessage;
  final String taskId;

  bool get isSuccess => type == SyncResultType.success;
  bool get isFailed => type == SyncResultType.failed;
  bool get isSuperseded => type == SyncResultType.superseded;
}

abstract class TaskRepository {
  TaskLocalStore get localStore;

  Future<TaskPageResult> fetchTasks({
    String? cursor,
    String query = '',
    int limit = 20,
    List<TaskItem> existingTasks = const [],
  });

  Future<TaskItem> toggleTaskStatus(TaskItem task);

  Future<SyncResult> syncMutation(String taskId);

  Future<List<SyncResult>> syncAllPendingMutations();

  TaskItem reconcileWithLocalState(TaskItem serverTask);
}
