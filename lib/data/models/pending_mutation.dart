class PendingMutation {
  const PendingMutation({
    required this.taskId,
    required this.targetStatus,
    this.taskTitle,
    this.originalServerStatus,
    required this.createdAt,
    required this.sequenceNumber,
    this.retryCount = 0,
    this.isFailed = false,
    this.lastError,
  });

  final String taskId;
  final String targetStatus;
  final String? taskTitle;
  final String? originalServerStatus;
  final DateTime createdAt;
  final int sequenceNumber;
  final int retryCount;
  final bool isFailed;
  final String? lastError;

  PendingMutation copyWith({
    String? taskId,
    String? targetStatus,
    String? taskTitle,
    String? originalServerStatus,
    DateTime? createdAt,
    int? sequenceNumber,
    int? retryCount,
    bool? isFailed,
    String? lastError,
  }) {
    return PendingMutation(
      taskId: taskId ?? this.taskId,
      targetStatus: targetStatus ?? this.targetStatus,
      taskTitle: taskTitle ?? this.taskTitle,
      originalServerStatus: originalServerStatus ?? this.originalServerStatus,
      createdAt: createdAt ?? this.createdAt,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      retryCount: retryCount ?? this.retryCount,
      isFailed: isFailed ?? this.isFailed,
      lastError: lastError ?? this.lastError,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'targetStatus': targetStatus,
      'taskTitle': taskTitle,
      'originalServerStatus': originalServerStatus,
      'createdAt': createdAt.toIso8601String(),
      'sequenceNumber': sequenceNumber,
      'retryCount': retryCount,
      'isFailed': isFailed,
      'lastError': lastError,
    };
  }

  factory PendingMutation.fromMap(Map<String, dynamic> map) {
    return PendingMutation(
      taskId: map['taskId'] as String,
      targetStatus: map['targetStatus'] as String,
      taskTitle: map['taskTitle'] as String?,
      originalServerStatus: map['originalServerStatus'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      sequenceNumber: (map['sequenceNumber'] as num?)?.toInt() ?? 0,
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      isFailed: map['isFailed'] as bool? ?? false,
      lastError: map['lastError'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingMutation &&
          runtimeType == other.runtimeType &&
          taskId == other.taskId &&
          targetStatus == other.targetStatus &&
          sequenceNumber == other.sequenceNumber &&
          retryCount == other.retryCount &&
          isFailed == other.isFailed;

  @override
  int get hashCode =>
      taskId.hashCode ^
      targetStatus.hashCode ^
      sequenceNumber.hashCode ^
      retryCount.hashCode ^
      isFailed.hashCode;
}
