// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PendingMutationsTableTable extends PendingMutationsTable
    with TableInfo<$PendingMutationsTableTable, PendingMutationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingMutationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetStatusMeta = const VerificationMeta(
    'targetStatus',
  );
  @override
  late final GeneratedColumn<String> targetStatus = GeneratedColumn<String>(
    'target_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskTitleMeta = const VerificationMeta(
    'taskTitle',
  );
  @override
  late final GeneratedColumn<String> taskTitle = GeneratedColumn<String>(
    'task_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalServerStatusMeta =
      const VerificationMeta('originalServerStatus');
  @override
  late final GeneratedColumn<String> originalServerStatus =
      GeneratedColumn<String>(
        'original_server_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFailedMeta = const VerificationMeta(
    'isFailed',
  );
  @override
  late final GeneratedColumn<bool> isFailed = GeneratedColumn<bool>(
    'is_failed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_failed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    targetStatus,
    taskTitle,
    originalServerStatus,
    createdAt,
    sequenceNumber,
    isFailed,
    lastError,
    retryCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_mutations_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingMutationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('target_status')) {
      context.handle(
        _targetStatusMeta,
        targetStatus.isAcceptableOrUnknown(
          data['target_status']!,
          _targetStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetStatusMeta);
    }
    if (data.containsKey('task_title')) {
      context.handle(
        _taskTitleMeta,
        taskTitle.isAcceptableOrUnknown(data['task_title']!, _taskTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_taskTitleMeta);
    }
    if (data.containsKey('original_server_status')) {
      context.handle(
        _originalServerStatusMeta,
        originalServerStatus.isAcceptableOrUnknown(
          data['original_server_status']!,
          _originalServerStatusMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('is_failed')) {
      context.handle(
        _isFailedMeta,
        isFailed.isAcceptableOrUnknown(data['is_failed']!, _isFailedMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  PendingMutationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMutationsTableData(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      targetStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_status'],
      )!,
      taskTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_title'],
      )!,
      originalServerStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_server_status'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
      isFailed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_failed'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
    );
  }

  @override
  $PendingMutationsTableTable createAlias(String alias) {
    return $PendingMutationsTableTable(attachedDatabase, alias);
  }
}

class PendingMutationsTableData extends DataClass
    implements Insertable<PendingMutationsTableData> {
  final String taskId;
  final String targetStatus;
  final String taskTitle;
  final String? originalServerStatus;
  final DateTime createdAt;
  final int sequenceNumber;
  final bool isFailed;
  final String? lastError;
  final int retryCount;
  const PendingMutationsTableData({
    required this.taskId,
    required this.targetStatus,
    required this.taskTitle,
    this.originalServerStatus,
    required this.createdAt,
    required this.sequenceNumber,
    required this.isFailed,
    this.lastError,
    required this.retryCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<String>(taskId);
    map['target_status'] = Variable<String>(targetStatus);
    map['task_title'] = Variable<String>(taskTitle);
    if (!nullToAbsent || originalServerStatus != null) {
      map['original_server_status'] = Variable<String>(originalServerStatus);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['sequence_number'] = Variable<int>(sequenceNumber);
    map['is_failed'] = Variable<bool>(isFailed);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['retry_count'] = Variable<int>(retryCount);
    return map;
  }

  PendingMutationsTableCompanion toCompanion(bool nullToAbsent) {
    return PendingMutationsTableCompanion(
      taskId: Value(taskId),
      targetStatus: Value(targetStatus),
      taskTitle: Value(taskTitle),
      originalServerStatus: originalServerStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(originalServerStatus),
      createdAt: Value(createdAt),
      sequenceNumber: Value(sequenceNumber),
      isFailed: Value(isFailed),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      retryCount: Value(retryCount),
    );
  }

  factory PendingMutationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMutationsTableData(
      taskId: serializer.fromJson<String>(json['taskId']),
      targetStatus: serializer.fromJson<String>(json['targetStatus']),
      taskTitle: serializer.fromJson<String>(json['taskTitle']),
      originalServerStatus: serializer.fromJson<String?>(
        json['originalServerStatus'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      isFailed: serializer.fromJson<bool>(json['isFailed']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<String>(taskId),
      'targetStatus': serializer.toJson<String>(targetStatus),
      'taskTitle': serializer.toJson<String>(taskTitle),
      'originalServerStatus': serializer.toJson<String?>(originalServerStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'isFailed': serializer.toJson<bool>(isFailed),
      'lastError': serializer.toJson<String?>(lastError),
      'retryCount': serializer.toJson<int>(retryCount),
    };
  }

  PendingMutationsTableData copyWith({
    String? taskId,
    String? targetStatus,
    String? taskTitle,
    Value<String?> originalServerStatus = const Value.absent(),
    DateTime? createdAt,
    int? sequenceNumber,
    bool? isFailed,
    Value<String?> lastError = const Value.absent(),
    int? retryCount,
  }) => PendingMutationsTableData(
    taskId: taskId ?? this.taskId,
    targetStatus: targetStatus ?? this.targetStatus,
    taskTitle: taskTitle ?? this.taskTitle,
    originalServerStatus: originalServerStatus.present
        ? originalServerStatus.value
        : this.originalServerStatus,
    createdAt: createdAt ?? this.createdAt,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    isFailed: isFailed ?? this.isFailed,
    lastError: lastError.present ? lastError.value : this.lastError,
    retryCount: retryCount ?? this.retryCount,
  );
  PendingMutationsTableData copyWithCompanion(
    PendingMutationsTableCompanion data,
  ) {
    return PendingMutationsTableData(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      targetStatus: data.targetStatus.present
          ? data.targetStatus.value
          : this.targetStatus,
      taskTitle: data.taskTitle.present ? data.taskTitle.value : this.taskTitle,
      originalServerStatus: data.originalServerStatus.present
          ? data.originalServerStatus.value
          : this.originalServerStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      isFailed: data.isFailed.present ? data.isFailed.value : this.isFailed,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsTableData(')
          ..write('taskId: $taskId, ')
          ..write('targetStatus: $targetStatus, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('originalServerStatus: $originalServerStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('isFailed: $isFailed, ')
          ..write('lastError: $lastError, ')
          ..write('retryCount: $retryCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    targetStatus,
    taskTitle,
    originalServerStatus,
    createdAt,
    sequenceNumber,
    isFailed,
    lastError,
    retryCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutationsTableData &&
          other.taskId == this.taskId &&
          other.targetStatus == this.targetStatus &&
          other.taskTitle == this.taskTitle &&
          other.originalServerStatus == this.originalServerStatus &&
          other.createdAt == this.createdAt &&
          other.sequenceNumber == this.sequenceNumber &&
          other.isFailed == this.isFailed &&
          other.lastError == this.lastError &&
          other.retryCount == this.retryCount);
}

class PendingMutationsTableCompanion
    extends UpdateCompanion<PendingMutationsTableData> {
  final Value<String> taskId;
  final Value<String> targetStatus;
  final Value<String> taskTitle;
  final Value<String?> originalServerStatus;
  final Value<DateTime> createdAt;
  final Value<int> sequenceNumber;
  final Value<bool> isFailed;
  final Value<String?> lastError;
  final Value<int> retryCount;
  final Value<int> rowid;
  const PendingMutationsTableCompanion({
    this.taskId = const Value.absent(),
    this.targetStatus = const Value.absent(),
    this.taskTitle = const Value.absent(),
    this.originalServerStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.isFailed = const Value.absent(),
    this.lastError = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingMutationsTableCompanion.insert({
    required String taskId,
    required String targetStatus,
    required String taskTitle,
    this.originalServerStatus = const Value.absent(),
    required DateTime createdAt,
    required int sequenceNumber,
    this.isFailed = const Value.absent(),
    this.lastError = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : taskId = Value(taskId),
       targetStatus = Value(targetStatus),
       taskTitle = Value(taskTitle),
       createdAt = Value(createdAt),
       sequenceNumber = Value(sequenceNumber);
  static Insertable<PendingMutationsTableData> custom({
    Expression<String>? taskId,
    Expression<String>? targetStatus,
    Expression<String>? taskTitle,
    Expression<String>? originalServerStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? sequenceNumber,
    Expression<bool>? isFailed,
    Expression<String>? lastError,
    Expression<int>? retryCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (targetStatus != null) 'target_status': targetStatus,
      if (taskTitle != null) 'task_title': taskTitle,
      if (originalServerStatus != null)
        'original_server_status': originalServerStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (isFailed != null) 'is_failed': isFailed,
      if (lastError != null) 'last_error': lastError,
      if (retryCount != null) 'retry_count': retryCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingMutationsTableCompanion copyWith({
    Value<String>? taskId,
    Value<String>? targetStatus,
    Value<String>? taskTitle,
    Value<String?>? originalServerStatus,
    Value<DateTime>? createdAt,
    Value<int>? sequenceNumber,
    Value<bool>? isFailed,
    Value<String?>? lastError,
    Value<int>? retryCount,
    Value<int>? rowid,
  }) {
    return PendingMutationsTableCompanion(
      taskId: taskId ?? this.taskId,
      targetStatus: targetStatus ?? this.targetStatus,
      taskTitle: taskTitle ?? this.taskTitle,
      originalServerStatus: originalServerStatus ?? this.originalServerStatus,
      createdAt: createdAt ?? this.createdAt,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      isFailed: isFailed ?? this.isFailed,
      lastError: lastError ?? this.lastError,
      retryCount: retryCount ?? this.retryCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (targetStatus.present) {
      map['target_status'] = Variable<String>(targetStatus.value);
    }
    if (taskTitle.present) {
      map['task_title'] = Variable<String>(taskTitle.value);
    }
    if (originalServerStatus.present) {
      map['original_server_status'] = Variable<String>(
        originalServerStatus.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (isFailed.present) {
      map['is_failed'] = Variable<bool>(isFailed.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutationsTableCompanion(')
          ..write('taskId: $taskId, ')
          ..write('targetStatus: $targetStatus, ')
          ..write('taskTitle: $taskTitle, ')
          ..write('originalServerStatus: $originalServerStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('isFailed: $isFailed, ')
          ..write('lastError: $lastError, ')
          ..write('retryCount: $retryCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetadataTableTable extends AppMetadataTable
    with TableInfo<$AppMetadataTableTable, AppMetadataTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetadataTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intValueMeta = const VerificationMeta(
    'intValue',
  );
  @override
  late final GeneratedColumn<int> intValue = GeneratedColumn<int>(
    'int_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, intValue, textValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_metadata_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetadataTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('int_value')) {
      context.handle(
        _intValueMeta,
        intValue.isAcceptableOrUnknown(data['int_value']!, _intValueMeta),
      );
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetadataTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetadataTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      intValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}int_value'],
      ),
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
    );
  }

  @override
  $AppMetadataTableTable createAlias(String alias) {
    return $AppMetadataTableTable(attachedDatabase, alias);
  }
}

class AppMetadataTableData extends DataClass
    implements Insertable<AppMetadataTableData> {
  final String key;
  final int? intValue;
  final String? textValue;
  const AppMetadataTableData({
    required this.key,
    this.intValue,
    this.textValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || intValue != null) {
      map['int_value'] = Variable<int>(intValue);
    }
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    return map;
  }

  AppMetadataTableCompanion toCompanion(bool nullToAbsent) {
    return AppMetadataTableCompanion(
      key: Value(key),
      intValue: intValue == null && nullToAbsent
          ? const Value.absent()
          : Value(intValue),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
    );
  }

  factory AppMetadataTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetadataTableData(
      key: serializer.fromJson<String>(json['key']),
      intValue: serializer.fromJson<int?>(json['intValue']),
      textValue: serializer.fromJson<String?>(json['textValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'intValue': serializer.toJson<int?>(intValue),
      'textValue': serializer.toJson<String?>(textValue),
    };
  }

  AppMetadataTableData copyWith({
    String? key,
    Value<int?> intValue = const Value.absent(),
    Value<String?> textValue = const Value.absent(),
  }) => AppMetadataTableData(
    key: key ?? this.key,
    intValue: intValue.present ? intValue.value : this.intValue,
    textValue: textValue.present ? textValue.value : this.textValue,
  );
  AppMetadataTableData copyWithCompanion(AppMetadataTableCompanion data) {
    return AppMetadataTableData(
      key: data.key.present ? data.key.value : this.key,
      intValue: data.intValue.present ? data.intValue.value : this.intValue,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataTableData(')
          ..write('key: $key, ')
          ..write('intValue: $intValue, ')
          ..write('textValue: $textValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, intValue, textValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetadataTableData &&
          other.key == this.key &&
          other.intValue == this.intValue &&
          other.textValue == this.textValue);
}

class AppMetadataTableCompanion extends UpdateCompanion<AppMetadataTableData> {
  final Value<String> key;
  final Value<int?> intValue;
  final Value<String?> textValue;
  final Value<int> rowid;
  const AppMetadataTableCompanion({
    this.key = const Value.absent(),
    this.intValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetadataTableCompanion.insert({
    required String key,
    this.intValue = const Value.absent(),
    this.textValue = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<AppMetadataTableData> custom({
    Expression<String>? key,
    Expression<int>? intValue,
    Expression<String>? textValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (intValue != null) 'int_value': intValue,
      if (textValue != null) 'text_value': textValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetadataTableCompanion copyWith({
    Value<String>? key,
    Value<int?>? intValue,
    Value<String?>? textValue,
    Value<int>? rowid,
  }) {
    return AppMetadataTableCompanion(
      key: key ?? this.key,
      intValue: intValue ?? this.intValue,
      textValue: textValue ?? this.textValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (intValue.present) {
      map['int_value'] = Variable<int>(intValue.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetadataTableCompanion(')
          ..write('key: $key, ')
          ..write('intValue: $intValue, ')
          ..write('textValue: $textValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedTasksTableTable extends CachedTasksTable
    with TableInfo<$CachedTasksTableTable, CachedTasksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedTasksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, status, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_tasks_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedTasksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedTasksTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedTasksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CachedTasksTableTable createAlias(String alias) {
    return $CachedTasksTableTable(attachedDatabase, alias);
  }
}

class CachedTasksTableData extends DataClass
    implements Insertable<CachedTasksTableData> {
  final String id;
  final String? title;
  final String status;
  final DateTime updatedAt;
  const CachedTasksTableData({
    required this.id,
    this.title,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CachedTasksTableCompanion toCompanion(bool nullToAbsent) {
    return CachedTasksTableCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory CachedTasksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedTasksTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CachedTasksTableData copyWith({
    String? id,
    Value<String?> title = const Value.absent(),
    String? status,
    DateTime? updatedAt,
  }) => CachedTasksTableData(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CachedTasksTableData copyWithCompanion(CachedTasksTableCompanion data) {
    return CachedTasksTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedTasksTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, status, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedTasksTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class CachedTasksTableCompanion extends UpdateCompanion<CachedTasksTableData> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String> status;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CachedTasksTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedTasksTableCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required String status,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<CachedTasksTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? status,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedTasksTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? title,
    Value<String>? status,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CachedTasksTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedTasksTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PendingMutationsTableTable pendingMutationsTable =
      $PendingMutationsTableTable(this);
  late final $AppMetadataTableTable appMetadataTable = $AppMetadataTableTable(
    this,
  );
  late final $CachedTasksTableTable cachedTasksTable = $CachedTasksTableTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pendingMutationsTable,
    appMetadataTable,
    cachedTasksTable,
  ];
}

typedef $$PendingMutationsTableTableCreateCompanionBuilder =
    PendingMutationsTableCompanion Function({
      required String taskId,
      required String targetStatus,
      required String taskTitle,
      Value<String?> originalServerStatus,
      required DateTime createdAt,
      required int sequenceNumber,
      Value<bool> isFailed,
      Value<String?> lastError,
      Value<int> retryCount,
      Value<int> rowid,
    });
typedef $$PendingMutationsTableTableUpdateCompanionBuilder =
    PendingMutationsTableCompanion Function({
      Value<String> taskId,
      Value<String> targetStatus,
      Value<String> taskTitle,
      Value<String?> originalServerStatus,
      Value<DateTime> createdAt,
      Value<int> sequenceNumber,
      Value<bool> isFailed,
      Value<String?> lastError,
      Value<int> retryCount,
      Value<int> rowid,
    });

class $$PendingMutationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PendingMutationsTableTable> {
  $$PendingMutationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetStatus => $composableBuilder(
    column: $table.targetStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalServerStatus => $composableBuilder(
    column: $table.originalServerStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFailed => $composableBuilder(
    column: $table.isFailed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingMutationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingMutationsTableTable> {
  $$PendingMutationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetStatus => $composableBuilder(
    column: $table.targetStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskTitle => $composableBuilder(
    column: $table.taskTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalServerStatus => $composableBuilder(
    column: $table.originalServerStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFailed => $composableBuilder(
    column: $table.isFailed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingMutationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingMutationsTableTable> {
  $$PendingMutationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get targetStatus => $composableBuilder(
    column: $table.targetStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get taskTitle =>
      $composableBuilder(column: $table.taskTitle, builder: (column) => column);

  GeneratedColumn<String> get originalServerStatus => $composableBuilder(
    column: $table.originalServerStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFailed =>
      $composableBuilder(column: $table.isFailed, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );
}

class $$PendingMutationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingMutationsTableTable,
          PendingMutationsTableData,
          $$PendingMutationsTableTableFilterComposer,
          $$PendingMutationsTableTableOrderingComposer,
          $$PendingMutationsTableTableAnnotationComposer,
          $$PendingMutationsTableTableCreateCompanionBuilder,
          $$PendingMutationsTableTableUpdateCompanionBuilder,
          (
            PendingMutationsTableData,
            BaseReferences<
              _$AppDatabase,
              $PendingMutationsTableTable,
              PendingMutationsTableData
            >,
          ),
          PendingMutationsTableData,
          PrefetchHooks Function()
        > {
  $$PendingMutationsTableTableTableManager(
    _$AppDatabase db,
    $PendingMutationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingMutationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PendingMutationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PendingMutationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> taskId = const Value.absent(),
                Value<String> targetStatus = const Value.absent(),
                Value<String> taskTitle = const Value.absent(),
                Value<String?> originalServerStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<bool> isFailed = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingMutationsTableCompanion(
                taskId: taskId,
                targetStatus: targetStatus,
                taskTitle: taskTitle,
                originalServerStatus: originalServerStatus,
                createdAt: createdAt,
                sequenceNumber: sequenceNumber,
                isFailed: isFailed,
                lastError: lastError,
                retryCount: retryCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String taskId,
                required String targetStatus,
                required String taskTitle,
                Value<String?> originalServerStatus = const Value.absent(),
                required DateTime createdAt,
                required int sequenceNumber,
                Value<bool> isFailed = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingMutationsTableCompanion.insert(
                taskId: taskId,
                targetStatus: targetStatus,
                taskTitle: taskTitle,
                originalServerStatus: originalServerStatus,
                createdAt: createdAt,
                sequenceNumber: sequenceNumber,
                isFailed: isFailed,
                lastError: lastError,
                retryCount: retryCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingMutationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingMutationsTableTable,
      PendingMutationsTableData,
      $$PendingMutationsTableTableFilterComposer,
      $$PendingMutationsTableTableOrderingComposer,
      $$PendingMutationsTableTableAnnotationComposer,
      $$PendingMutationsTableTableCreateCompanionBuilder,
      $$PendingMutationsTableTableUpdateCompanionBuilder,
      (
        PendingMutationsTableData,
        BaseReferences<
          _$AppDatabase,
          $PendingMutationsTableTable,
          PendingMutationsTableData
        >,
      ),
      PendingMutationsTableData,
      PrefetchHooks Function()
    >;
typedef $$AppMetadataTableTableCreateCompanionBuilder =
    AppMetadataTableCompanion Function({
      required String key,
      Value<int?> intValue,
      Value<String?> textValue,
      Value<int> rowid,
    });
typedef $$AppMetadataTableTableUpdateCompanionBuilder =
    AppMetadataTableCompanion Function({
      Value<String> key,
      Value<int?> intValue,
      Value<String?> textValue,
      Value<int> rowid,
    });

class $$AppMetadataTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetadataTableTable> {
  $$AppMetadataTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetadataTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetadataTableTable> {
  $$AppMetadataTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intValue => $composableBuilder(
    column: $table.intValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetadataTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetadataTableTable> {
  $$AppMetadataTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get intValue =>
      $composableBuilder(column: $table.intValue, builder: (column) => column);

  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);
}

class $$AppMetadataTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetadataTableTable,
          AppMetadataTableData,
          $$AppMetadataTableTableFilterComposer,
          $$AppMetadataTableTableOrderingComposer,
          $$AppMetadataTableTableAnnotationComposer,
          $$AppMetadataTableTableCreateCompanionBuilder,
          $$AppMetadataTableTableUpdateCompanionBuilder,
          (
            AppMetadataTableData,
            BaseReferences<
              _$AppDatabase,
              $AppMetadataTableTable,
              AppMetadataTableData
            >,
          ),
          AppMetadataTableData,
          PrefetchHooks Function()
        > {
  $$AppMetadataTableTableTableManager(
    _$AppDatabase db,
    $AppMetadataTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetadataTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetadataTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetadataTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int?> intValue = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataTableCompanion(
                key: key,
                intValue: intValue,
                textValue: textValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                Value<int?> intValue = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetadataTableCompanion.insert(
                key: key,
                intValue: intValue,
                textValue: textValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetadataTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetadataTableTable,
      AppMetadataTableData,
      $$AppMetadataTableTableFilterComposer,
      $$AppMetadataTableTableOrderingComposer,
      $$AppMetadataTableTableAnnotationComposer,
      $$AppMetadataTableTableCreateCompanionBuilder,
      $$AppMetadataTableTableUpdateCompanionBuilder,
      (
        AppMetadataTableData,
        BaseReferences<
          _$AppDatabase,
          $AppMetadataTableTable,
          AppMetadataTableData
        >,
      ),
      AppMetadataTableData,
      PrefetchHooks Function()
    >;
typedef $$CachedTasksTableTableCreateCompanionBuilder =
    CachedTasksTableCompanion Function({
      required String id,
      Value<String?> title,
      required String status,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CachedTasksTableTableUpdateCompanionBuilder =
    CachedTasksTableCompanion Function({
      Value<String> id,
      Value<String?> title,
      Value<String> status,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CachedTasksTableTableFilterComposer
    extends Composer<_$AppDatabase, $CachedTasksTableTable> {
  $$CachedTasksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedTasksTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedTasksTableTable> {
  $$CachedTasksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedTasksTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedTasksTableTable> {
  $$CachedTasksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CachedTasksTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedTasksTableTable,
          CachedTasksTableData,
          $$CachedTasksTableTableFilterComposer,
          $$CachedTasksTableTableOrderingComposer,
          $$CachedTasksTableTableAnnotationComposer,
          $$CachedTasksTableTableCreateCompanionBuilder,
          $$CachedTasksTableTableUpdateCompanionBuilder,
          (
            CachedTasksTableData,
            BaseReferences<
              _$AppDatabase,
              $CachedTasksTableTable,
              CachedTasksTableData
            >,
          ),
          CachedTasksTableData,
          PrefetchHooks Function()
        > {
  $$CachedTasksTableTableTableManager(
    _$AppDatabase db,
    $CachedTasksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedTasksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedTasksTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedTasksTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedTasksTableCompanion(
                id: id,
                title: title,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> title = const Value.absent(),
                required String status,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedTasksTableCompanion.insert(
                id: id,
                title: title,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedTasksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedTasksTableTable,
      CachedTasksTableData,
      $$CachedTasksTableTableFilterComposer,
      $$CachedTasksTableTableOrderingComposer,
      $$CachedTasksTableTableAnnotationComposer,
      $$CachedTasksTableTableCreateCompanionBuilder,
      $$CachedTasksTableTableUpdateCompanionBuilder,
      (
        CachedTasksTableData,
        BaseReferences<
          _$AppDatabase,
          $CachedTasksTableTable,
          CachedTasksTableData
        >,
      ),
      CachedTasksTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PendingMutationsTableTableTableManager get pendingMutationsTable =>
      $$PendingMutationsTableTableTableManager(_db, _db.pendingMutationsTable);
  $$AppMetadataTableTableTableManager get appMetadataTable =>
      $$AppMetadataTableTableTableManager(_db, _db.appMetadataTable);
  $$CachedTasksTableTableTableManager get cachedTasksTable =>
      $$CachedTasksTableTableTableManager(_db, _db.cachedTasksTable);
}
