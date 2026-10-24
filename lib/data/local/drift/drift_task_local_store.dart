import 'dart:async';
import 'package:drift/drift.dart';
import '../../models/pending_mutation.dart';
import '../../models/task_item.dart';
import '../../models/task_status.dart';
import '../task_local_store.dart';
import 'app_database.dart';

class DriftTaskLocalStore implements TaskLocalStore {
  DriftTaskLocalStore({AppDatabase? database}) : _database = database;

  AppDatabase? _database;
  AppDatabase get database => _database!;

  final Map<String, PendingMutation> _cache = {};
  int _sequenceCounter = 0;

  @override
  Future<void> init() async {
    _database ??= AppDatabase();

    // 1. Recover sequence counter from metadata table
    final metadataRow = await (_database!.select(_database!.appMetadataTable)
          ..where((tbl) => tbl.key.equals('mutation_sequence_counter')))
        .getSingleOrNull();

    _sequenceCounter = metadataRow?.intValue ?? 0;

    // 2. Load all existing pending mutations from SQLite
    final rows = await _database!.select(_database!.pendingMutationsTable).get();
    _cache.clear();

    for (final row in rows) {
      final mutation = PendingMutation(
        taskId: row.taskId,
        targetStatus: row.targetStatus,
        taskTitle: row.taskTitle,
        originalServerStatus: row.originalServerStatus,
        createdAt: row.createdAt,
        sequenceNumber: row.sequenceNumber,
        isFailed: row.isFailed,
        lastError: row.lastError,
        retryCount: row.retryCount,
      );
      _cache[row.taskId] = mutation;
      if (row.sequenceNumber > _sequenceCounter) {
        _sequenceCounter = row.sequenceNumber;
      }
    }
  }

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
    await _database!.into(_database!.pendingMutationsTable).insertOnConflictUpdate(
          PendingMutationsTableCompanion.insert(
            taskId: mutation.taskId,
            targetStatus: mutation.targetStatus,
            taskTitle: mutation.taskTitle ?? 'Untitled visit',
            originalServerStatus: Value(mutation.originalServerStatus),
            createdAt: mutation.createdAt,
            sequenceNumber: mutation.sequenceNumber,
            isFailed: Value(mutation.isFailed),
            lastError: Value(mutation.lastError),
            retryCount: Value(mutation.retryCount),
          ),
        );
  }

  @override
  Future<void> removeMutation(String taskId) async {
    _cache.remove(taskId);
    await (_database!.delete(_database!.pendingMutationsTable)
          ..where((tbl) => tbl.taskId.equals(taskId)))
        .go();
  }

  @override
  Future<void> markMutationFailed(String taskId, String error) async {
    final existing = _cache[taskId];
    if (existing != null) {
      final updated = existing.copyWith(
        isFailed: true,
        lastError: error,
        retryCount: existing.retryCount + 1,
      );
      _cache[taskId] = updated;

      await (_database!.update(_database!.pendingMutationsTable)
            ..where((tbl) => tbl.taskId.equals(taskId)))
          .write(
        PendingMutationsTableCompanion(
          isFailed: const Value(true),
          lastError: Value(error),
          retryCount: Value(updated.retryCount),
        ),
      );
    }
  }

  @override
  Future<void> clearAll() async {
    _cache.clear();
    await _database!.delete(_database!.pendingMutationsTable).go();
    await _database!.delete(_database!.cachedTasksTable).go();
  }

  @override
  int getNextSequenceNumber() {
    _sequenceCounter++;
    unawaited(
      _database!.into(_database!.appMetadataTable).insertOnConflictUpdate(
            AppMetadataTableCompanion.insert(
              key: 'mutation_sequence_counter',
              intValue: Value(_sequenceCounter),
            ),
          ),
    );
    return _sequenceCounter;
  }

  // Cached visits management for SQLite offline persistence
  Future<void> cacheTasks(List<TaskItem> tasks) async {
    await _database!.batch((batch) {
      for (final task in tasks) {
        batch.insert(
          _database!.cachedTasksTable,
          CachedTasksTableCompanion.insert(
            id: task.id,
            title: Value(task.title),
            status: task.status.value,
            updatedAt: task.updatedAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<List<TaskItem>> getCachedTasks() async {
    final rows = await _database!.select(_database!.cachedTasksTable).get();
    return rows.map((row) {
      return TaskItem(
        id: row.id,
        title: row.title,
        status: TaskStatus.fromString(row.status),
        updatedAt: row.updatedAt,
      );
    }).toList();
  }

  Future<void> close() async {
    await _database?.close();
  }
}
