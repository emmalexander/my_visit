import 'dart:ffi';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

class PendingMutationsTable extends Table {
  TextColumn get taskId => text()();
  TextColumn get targetStatus => text()();
  TextColumn get taskTitle => text()();
  TextColumn get originalServerStatus => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get sequenceNumber => integer()();
  BoolColumn get isFailed => boolean().withDefault(const Constant(false))();
  TextColumn get lastError => text().nullable()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {taskId};
}

class AppMetadataTable extends Table {
  TextColumn get key => text()();
  IntColumn get intValue => integer().nullable()();
  TextColumn get textValue => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

class CachedTasksTable extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [PendingMutationsTable, AppMetadataTable, CachedTasksTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      if (Platform.isAndroid) {
        try {
          await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
        } catch (_) {}

        open.overrideFor(OperatingSystem.android, () {
          try {
            return DynamicLibrary.open('libsqlite3.so');
          } catch (_) {
            try {
              return DynamicLibrary.open('libsqlite.so');
            } catch (_) {
              return DynamicLibrary.process();
            }
          }
        });
      }

      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'my_visit.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
