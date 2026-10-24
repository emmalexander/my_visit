import '../models/pending_mutation.dart';

abstract class TaskLocalStore {
  Future<void> init();
  List<PendingMutation> getAllPendingMutations();
  PendingMutation? getMutation(String taskId);
  Future<void> saveMutation(PendingMutation mutation);
  Future<void> removeMutation(String taskId);
  Future<void> markMutationFailed(String taskId, String error);
  Future<void> clearAll();
  int getNextSequenceNumber();
}
