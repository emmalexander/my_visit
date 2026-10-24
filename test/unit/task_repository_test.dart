import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_visit/api/flaky_task_api.dart';
import 'package:my_visit/data/local/in_memory_task_local_store.dart';
import 'package:my_visit/data/models/pending_mutation.dart';
import 'package:my_visit/data/models/task_item.dart';
import 'package:my_visit/data/models/task_status.dart';
import 'package:my_visit/data/repository/task_repository_impl.dart';
import '../fakes/fake_flaky_task_api.dart';

void main() {
  late FakeFlakyTaskApi fakeApi;
  late InMemoryTaskLocalStore localStore;
  late TaskRepositoryImpl repository;

  setUp(() {
    fakeApi = FakeFlakyTaskApi();
    localStore = InMemoryTaskLocalStore();
    repository = TaskRepositoryImpl(api: fakeApi, localStore: localStore);
  });

  group('TaskRepository Pagination & Deduplication', () {
    test('deduplicates overlapping tasks across page boundaries', () async {
      // Simulate backend returning task_20 on both page 1 and page 2
      final existingPage1 = [
        TaskItem(
          id: 'task_19',
          title: 'Site visit #19',
          status: TaskStatus.open,
          updatedAt: DateTime.now().toUtc(),
        ),
        TaskItem(
          id: 'task_20',
          title: 'Site visit #20',
          status: TaskStatus.done,
          updatedAt: DateTime.now().toUtc(),
        ),
      ];

      fakeApi.customFetchHandler = ({cursor, query = '', limit = 20}) async {
        return TaskPage([
          // Repeating task_20 plus new task_21
          {
            'id': 'task_20',
            'title': 'Site visit #20',
            'status': 'done',
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          },
          {
            'id': 'task_21',
            'title': 'Site visit #21',
            'status': 'open',
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          },
        ], '40');
      };

      final result = await repository.fetchTasks(
        cursor: '20',
        existingTasks: existingPage1,
      );

      // Should only include task_21, task_20 is deduplicated!
      expect(result.tasks.length, equals(1));
      expect(result.tasks.first.id, equals('task_21'));
      expect(result.nextCursor, equals('40'));
    });
  });

  group('TaskRepository Optimistic Updates & Synchronization', () {
    test('immediate optimistic status changes are durably persisted before sync',
        () async {
      final initialTask = TaskItem(
        id: 'task_5',
        title: 'Site visit #5',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      final optimisticTask = await repository.toggleTaskStatus(initialTask);

      // Verify immediate UI model update
      expect(optimisticTask.status, equals(TaskStatus.done));
      expect(optimisticTask.syncStatus, equals(SyncStatus.pending));
      expect(optimisticTask.pendingMutationSequence, isNotNull);

      // Verify durable persistence in local store
      final persisted = localStore.getMutation('task_5');
      expect(persisted, isNotNull);
      expect(persisted!.targetStatus, equals('done'));
      expect(persisted.taskTitle, equals('Site visit #5'));
      expect(persisted.isFailed, isFalse);
    });

    test('successful mutation acknowledgement removes mutation from durable queue',
        () async {
      final task = TaskItem(
        id: 'task_1',
        title: 'Site visit #1',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      await repository.toggleTaskStatus(task);
      expect(localStore.getMutation('task_1'), isNotNull);

      fakeApi.customUpdateHandler = (id, status) async {
        return {
          'id': id,
          'title': 'Site visit #1',
          'status': status,
          'updatedAt': DateTime.now().toUtc().toIso8601String(),
        };
      };

      final syncResult = await repository.syncMutation('task_1');

      expect(syncResult.isSuccess, isTrue);
      expect(syncResult.updatedTask!.status, equals(TaskStatus.done));
      expect(syncResult.updatedTask!.syncStatus, equals(SyncStatus.synced));

      // Successfully acknowledged mutation must be cleaned from durable store
      expect(localStore.getMutation('task_1'), isNull);
    });

    test('definite server rejection (ApiException) keeps optimistic state and marks failed',
        () async {
      final task = TaskItem(
        id: 'task_2',
        title: 'Site visit #2',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      await repository.toggleTaskStatus(task);

      fakeApi.customUpdateHandler = (id, status) async {
        throw ApiException('Server error (simulated)');
      };

      final result = await repository.syncMutation('task_2');

      expect(result.isFailed, isTrue);
      expect(result.errorMessage, contains('Server error'));

      // Mutation is NOT deleted: kept durable with failed flag and error recorded
      final persisted = localStore.getMutation('task_2');
      expect(persisted, isNotNull);
      expect(persisted!.isFailed, isTrue);
      expect(persisted.lastError, contains('Server error'));
      expect(persisted.retryCount, equals(1));
    });

    test('ambiguous network failure (TimeoutException) keeps optimistic state and marks failed',
        () async {
      final task = TaskItem(
        id: 'task_3',
        title: 'Site visit #3',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      await repository.toggleTaskStatus(task);

      fakeApi.customUpdateHandler = (id, status) async {
        throw TimeoutException('No response from server');
      };

      final result = await repository.syncMutation('task_3');

      expect(result.isFailed, isTrue);
      final persisted = localStore.getMutation('task_3');
      expect(persisted, isNotNull);
      expect(persisted!.isFailed, isTrue);
    });

    test('out-of-order responses: newer user mutation cannot be overwritten by older in-flight response',
        () async {
      final task = TaskItem(
        id: 'task_7',
        title: 'Site visit #7',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      // User tap 1: toggle to 'done' (sequence 1)
      final taskAfterTap1 = await repository.toggleTaskStatus(task);
      expect(taskAfterTap1.pendingMutationSequence, equals(1));

      // Network request 1 starts and is in-flight (controlled by Completer)
      final completer1 = Completer<Map<String, dynamic>>();
      fakeApi.customUpdateHandler = (id, status) => completer1.future;

      final inFlightSync1 = repository.syncMutation('task_7');

      // WHILE request 1 is still in flight, user changes their mind and toggles back to 'open' (sequence 2)
      final taskAfterTap2 = await repository.toggleTaskStatus(taskAfterTap1);
      expect(taskAfterTap2.pendingMutationSequence, equals(2));
      expect(localStore.getMutation('task_7')!.sequenceNumber, equals(2));

      // Now request 1 arrives late from server
      completer1.complete({
        'id': 'task_7',
        'title': 'Site visit #7',
        'status': 'done', // old response for sequence 1
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
      });

      final result1 = await inFlightSync1;

      // Request 1 is detected as superseded!
      expect(result1.isSuperseded, isTrue);

      // The mutation in local store remains sequence 2 ('open')!
      final currentMutation = localStore.getMutation('task_7');
      expect(currentMutation, isNotNull);
      expect(currentMutation!.sequenceNumber, equals(2));
      expect(currentMutation.targetStatus, equals('open'));
    });

    test('archived visits cannot be toggled', () async {
      final archivedTask = TaskItem(
        id: 'task_89',
        title: 'Site visit #89',
        status: TaskStatus.archived,
        updatedAt: DateTime.now().toUtc(),
      );

      final result = await repository.toggleTaskStatus(archivedTask);
      expect(result.status, equals(TaskStatus.archived));
      expect(localStore.getAllPendingMutations(), isEmpty);
    });

    test('reconcileWithLocalState resolves server catch-up vs local newer intent', () {
      // Case A: server has caught up (e.g. after prior timeout)
      localStore.saveMutation(
        PendingMutation(
          taskId: 'task_10',
          targetStatus: 'done',
          createdAt: DateTime.now().toUtc(),
          sequenceNumber: 1,
        ),
      );

      final serverTaskSynced = TaskItem(
        id: 'task_10',
        title: 'Site visit #10',
        status: TaskStatus.done,
        updatedAt: DateTime.now().toUtc(),
      );

      final reconciledA = repository.reconcileWithLocalState(serverTaskSynced);
      expect(reconciledA.syncStatus, equals(SyncStatus.synced));
      expect(localStore.getMutation('task_10'), isNull,
          reason: 'Mutation cleaned when server matches target status');

      // Case B: server task still has old status
      localStore.saveMutation(
        PendingMutation(
          taskId: 'task_11',
          targetStatus: 'done',
          createdAt: DateTime.now().toUtc(),
          sequenceNumber: 2,
        ),
      );

      final serverTaskOld = TaskItem(
        id: 'task_11',
        title: 'Site visit #11',
        status: TaskStatus.open,
        updatedAt: DateTime.now().toUtc(),
      );

      final reconciledB = repository.reconcileWithLocalState(serverTaskOld);
      expect(reconciledB.status, equals(TaskStatus.done));
      expect(reconciledB.syncStatus, equals(SyncStatus.pending));
    });
  });
}
