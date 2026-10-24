import 'package:flutter_test/flutter_test.dart';
import 'package:my_visit/data/local/in_memory_task_local_store.dart';
import 'package:my_visit/data/local/shared_prefs_task_local_store.dart';
import 'package:my_visit/data/models/pending_mutation.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('TaskLocalStore Tests', () {
    test('InMemoryTaskLocalStore saves, retrieves, and removes mutations', () async {
      final store = InMemoryTaskLocalStore();
      await store.init();

      final seq1 = store.getNextSequenceNumber();
      final seq2 = store.getNextSequenceNumber();
      expect(seq2, greaterThan(seq1));

      final mutation = PendingMutation(
        taskId: 'task_1',
        targetStatus: 'done',
        taskTitle: 'Site visit #1',
        createdAt: DateTime.now().toUtc(),
        sequenceNumber: seq1,
      );

      await store.saveMutation(mutation);
      expect(store.getAllPendingMutations().length, equals(1));
      expect(store.getMutation('task_1'), equals(mutation));

      await store.markMutationFailed('task_1', 'Simulated failure');
      final failed = store.getMutation('task_1')!;
      expect(failed.isFailed, isTrue);
      expect(failed.lastError, equals('Simulated failure'));
      expect(failed.retryCount, equals(1));

      await store.removeMutation('task_1');
      expect(store.getAllPendingMutations(), isEmpty);
    });

    test('SharedPrefsTaskLocalStore survives app restarts and restores queued changes',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final store1 = SharedPrefsTaskLocalStore(prefs: prefs);
      await store1.init();

      final mutation = PendingMutation(
        taskId: 'task_42',
        targetStatus: 'done',
        taskTitle: 'Site visit #42',
        createdAt: DateTime.parse('2026-01-01T12:00:00.000Z'),
        sequenceNumber: store1.getNextSequenceNumber(),
      );

      await store1.saveMutation(mutation);
      expect(store1.getAllPendingMutations().length, equals(1));

      // Simulate App Restart: create brand new store instance with existing persisted preferences
      final store2 = SharedPrefsTaskLocalStore(prefs: prefs);
      await store2.init();

      final restoredList = store2.getAllPendingMutations();
      expect(restoredList.length, equals(1));
      expect(restoredList.first.taskId, equals('task_42'));
      expect(restoredList.first.targetStatus, equals('done'));
      expect(restoredList.first.taskTitle, equals('Site visit #42'));
      expect(restoredList.first.sequenceNumber, equals(1));

      // Next sequence number continues from previously persisted sequence
      expect(store2.getNextSequenceNumber(), equals(2));
    });
  });
}
