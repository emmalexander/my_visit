import 'task_status.dart';

enum SyncStatus {
  synced,
  pending,
  inFlight,
  failed,
}

class TaskItem {
  const TaskItem({
    required this.id,
    this.title,
    required this.status,
    required this.updatedAt,
    this.syncStatus = SyncStatus.synced,
    this.pendingMutationSequence,
    this.lastError,
  });

  final String id;
  final String? title;
  final TaskStatus status;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  final int? pendingMutationSequence;
  final String? lastError;

  String get displayTitle =>
      (title != null && title!.trim().isNotEmpty) ? title! : 'Untitled visit';

  bool get isUntitled => title == null || title!.trim().isEmpty;

  bool get isPending => syncStatus == SyncStatus.pending || syncStatus == SyncStatus.inFlight;
  bool get isFailed => syncStatus == SyncStatus.failed;
  bool get isSynced => syncStatus == SyncStatus.synced;

  TaskItem copyWith({
    String? id,
    String? title,
    TaskStatus? status,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    int? pendingMutationSequence,
    String? lastError,
    bool clearLastError = false,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      pendingMutationSequence:
          pendingMutationSequence ?? this.pendingMutationSequence,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
    );
  }

  factory TaskItem.fromApiMap(Map<String, dynamic> map) {
    final rawDate = map['updatedAt'] as String?;
    final date = rawDate != null ? DateTime.parse(rawDate) : DateTime.now().toUtc();
    return TaskItem(
      id: map['id'] as String,
      title: map['title'] as String?,
      status: TaskStatus.fromString(map['status'] as String?),
      updatedAt: date,
      syncStatus: SyncStatus.synced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          status == other.status &&
          updatedAt == other.updatedAt &&
          syncStatus == other.syncStatus &&
          pendingMutationSequence == other.pendingMutationSequence;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      status.hashCode ^
      updatedAt.hashCode ^
      syncStatus.hashCode ^
      pendingMutationSequence.hashCode;
}
