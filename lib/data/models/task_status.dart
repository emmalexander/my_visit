enum TaskStatus {
  open('open'),
  done('done'),
  archived('archived'),
  unknown('unknown');

  const TaskStatus(this.value);
  final String value;

  static TaskStatus fromString(String? raw) {
    if (raw == null) return TaskStatus.open;
    switch (raw.toLowerCase()) {
      case 'done':
        return TaskStatus.done;
      case 'open':
        return TaskStatus.open;
      case 'archived':
        return TaskStatus.archived;
      default:
        return TaskStatus.unknown;
    }
  }

  bool get isOpen => this == TaskStatus.open;
  bool get isDone => this == TaskStatus.done;
  bool get isArchived => this == TaskStatus.archived;

  TaskStatus toggle() {
    if (this == TaskStatus.open) return TaskStatus.done;
    if (this == TaskStatus.done) return TaskStatus.open;
    return this; // Archived or unknown cannot be toggled
  }
}
