import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_visit/data/local/drift/app_database.dart';
import 'package:my_visit/data/local/drift/drift_task_local_store.dart';
import 'package:my_visit/data/models/pending_mutation.dart';
import 'package:my_visit/data/models/task_item.dart';
import 'package:my_visit/data/models/task_status.dart';

void main() {
  group('DriftTaskLocalStore Tests (SQLite through Drift)', () {
    late AppDatabase db;
    late DriftTaskLocalStore store;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      store = DriftTaskLocalStore(database: db);
      await store.init();
    });

    tearDown(() async {
      await store.close();
    });

    test('saves, retrieves, and removes pending mutations in SQLite', () async {
      final seq1 = store.getNextSequenceNumber();
      final seq2 = store.getNextSequenceNumber();
      expect(seq2, greaterThan(seq1));

      final mutation = PendingMutation(
        taskId: 'task_100',
        targetStatus: 'done',
        taskTitle: 'Site inspection #100',
        originalServerStatus: 'open',
        createdAt: DateTime.now().toUtc(),
        sequenceNumber: seq1,
      );

      await store.saveMutation(mutation);

      expect(store.getAllPendingMutations().length, equals(1));
      expect(store.getMutation('task_100'), equals(mutation));

      // Verify row exists directly in Drift SQLite table
      final dbRows = await db.select(db.pendingMutationsTable).get();
      expect(dbRows.length, equals(1));
      expect(dbRows.first.taskId, equals('task_100'));
      expect(dbRows.first.targetStatus, equals('done'));
      expect(dbRows.first.taskTitle, equals('Site inspection #100'));
      expect(dbRows.first.sequenceNumber, equals(seq1));

      // Mark failed
      await store.markMutationFailed('task_100', 'Database network timeout');
      final failed = store.getMutation('task_100')!;
      expect(failed.isFailed, isTrue);
      expect(failed.lastError, equals('Database network timeout'));
      expect(failed.retryCount, equals(1));

      final updatedDbRow = await (db.select(db.pendingMutationsTable)
            ..where((t) => t.taskId.equals('task_100')))
          .getSingle();
      expect(updatedDbRow.isFailed, isTrue);
      expect(updatedDbRow.lastError, equals('Database network timeout'));
      expect(updatedDbRow.retryCount, equals(1));

      // Remove mutation
      await store.removeMutation('task_100');
      expect(store.getAllPendingMutations(), isEmpty);

      final emptyDbRows = await db.select(db.pendingMutationsTable).get();
      expect(emptyDbRows, isEmpty);
    });

    test('caches tasks in SQLite and retrieves them', () async {
      final tasks = [
        TaskItem(
          id: 'task_1',
          title: 'Roof assessment',
          status: TaskStatus.open,
          updatedAt: DateTime.parse('2026-03-01T10:00:00Z'),
        ),
        TaskItem(
          id: 'task_2',
          title: null, // edge case: untitled
          status: TaskStatus.done,
          updatedAt: DateTime.parse('2026-03-01T11:00:00Z'),
        ),
      ];

      await store.cacheTasks(tasks);

      final cached = await store.getCachedTasks();
      expect(cached.length, equals(2));
      expect(cached[0].id, equals('task_1'));
      expect(cached[0].title, equals('Roof assessment'));
      expect(cached[0].status, equals(TaskStatus.open));
      expect(cached[1].id, equals('task_2'));
      expect(cached[1].title, isNull);
      expect(cached[1].status, equals(TaskStatus.done));
    });

    test('reloads mutations and continues sequence counter on fresh store initialization',
        () async {
      final seq = store.getNextSequenceNumber();

      final mutation = PendingMutation(
        taskId: 'task_persisted',
        targetStatus: 'done',
        taskTitle: 'Safety check',
        createdAt: DateTime.parse('2026-02-15T08:30:00Z'),
        sequenceNumber: seq,
      );

      await store.saveMutation(mutation);

      // Create a second store instance pointing to the same active database
      final store2 = DriftTaskLocalStore(database: db);
      await store2.init();

      final restored = store2.getAllPendingMutations();
      expect(restored.length, equals(1));
      expect(restored.first.taskId, equals('task_persisted'));
      expect(restored.first.sequenceNumber, equals(seq));

      // Ensure sequence counter resumes monotonically
      final nextSeq = store2.getNextSequenceNumber();
      expect(nextSeq, equals(seq + 1));
    });

    test('clearAll clears mutations and cached tasks from SQLite', () async {
      await store.saveMutation(
        PendingMutation(
          taskId: 'task_del',
          targetStatus: 'open',
          taskTitle: 'Delete me',
          createdAt: DateTime.now().toUtc(),
          sequenceNumber: 1,
        ),
      );

      await store.cacheTasks([
        TaskItem(
          id: 'task_del',
          title: 'Delete me',
          status: TaskStatus.open,
          updatedAt: DateTime.now().toUtc(),
        ),
      ]);

      expect(store.getAllPendingMutations().length, equals(1));
      expect((await store.getCachedTasks()).length, equals(1));

      await store.clearAll();

      expect(store.getAllPendingMutations(), isEmpty);
      expect((await store.getCachedTasks()), isEmpty);
    });
  });
}
