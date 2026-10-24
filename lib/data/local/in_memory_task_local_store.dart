import '../models/pending_mutation.dart';
import 'task_local_store.dart';

class InMemoryTaskLocalStore implements TaskLocalStore {
  final Map<String, PendingMutation> _cache = {};
  int _sequenceCounter = 0;

  @override
  Future<void> init() async {}

  @override
  List<PendingMutation> getAllPendingMutations() {
    return _cache.values.toList()
      ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
  }

  @override
  PendingMutation? getMutation(String taskId) => _cache[taskId];

  @override
  Future<void> saveMutation(PendingMutation mutation) async {
    _cache[mutation.taskId] = mutation;
  }

  @override
  Future<void> removeMutation(String taskId) async {
    _cache.remove(taskId);
  }

  @override
  Future<void> markMutationFailed(String taskId, String error) async {
    final existing = _cache[taskId];
    if (existing != null) {
      _cache[taskId] = existing.copyWith(
        isFailed: true,
        lastError: error,
        retryCount: existing.retryCount + 1,
      );
    }
  }

  @override
  Future<void> clearAll() async {
    _cache.clear();
  }

  @override
  int getNextSequenceNumber() {
    _sequenceCounter++;
    return _sequenceCounter;
  }
}
