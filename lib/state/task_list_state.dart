import '../data/models/pending_mutation.dart';
import '../data/models/task_item.dart';

class TaskListState {
  const TaskListState({
    this.tasks = const [],
    this.isLoadingFirstPage = false,
    this.firstPageError,
    this.isLoadingNextPage = false,
    this.nextPageError,
    this.nextCursor,
    this.hasMore = true,
    this.searchQuery = '',
    this.lastFailedMutation,
    this.unsyncedCount = 0,
  });

  final List<TaskItem> tasks;
  final bool isLoadingFirstPage;
  final String? firstPageError;
  final bool isLoadingNextPage;
  final String? nextPageError;
  final String? nextCursor;
  final bool hasMore;
  final String searchQuery;
  final PendingMutation? lastFailedMutation;
  final int unsyncedCount;

  bool get isEmpty => tasks.isEmpty && !isLoadingFirstPage && firstPageError == null;
  bool get isSearching => searchQuery.trim().isNotEmpty;
  bool get showEmptySearch => isEmpty && isSearching;
  bool get showEmptyList => isEmpty && !isSearching;

  TaskListState copyWith({
    List<TaskItem>? tasks,
    bool? isLoadingFirstPage,
    String? firstPageError,
    bool clearFirstPageError = false,
    bool? isLoadingNextPage,
    String? nextPageError,
    bool clearNextPageError = false,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    String? searchQuery,
    PendingMutation? lastFailedMutation,
    bool clearLastFailedMutation = false,
    int? unsyncedCount,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoadingFirstPage: isLoadingFirstPage ?? this.isLoadingFirstPage,
      firstPageError:
          clearFirstPageError ? null : (firstPageError ?? this.firstPageError),
      isLoadingNextPage: isLoadingNextPage ?? this.isLoadingNextPage,
      nextPageError:
          clearNextPageError ? null : (nextPageError ?? this.nextPageError),
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      lastFailedMutation: clearLastFailedMutation
          ? null
          : (lastFailedMutation ?? this.lastFailedMutation),
      unsyncedCount: unsyncedCount ?? this.unsyncedCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskListState &&
          runtimeType == other.runtimeType &&
          isLoadingFirstPage == other.isLoadingFirstPage &&
          firstPageError == other.firstPageError &&
          isLoadingNextPage == other.isLoadingNextPage &&
          nextPageError == other.nextPageError &&
          nextCursor == other.nextCursor &&
          hasMore == other.hasMore &&
          searchQuery == other.searchQuery &&
          unsyncedCount == other.unsyncedCount &&
          lastFailedMutation == other.lastFailedMutation &&
          tasks.length == other.tasks.length;

  @override
  int get hashCode =>
      tasks.hashCode ^
      isLoadingFirstPage.hashCode ^
      firstPageError.hashCode ^
      isLoadingNextPage.hashCode ^
      nextPageError.hashCode ^
      nextCursor.hashCode ^
      hasMore.hashCode ^
      searchQuery.hashCode ^
      unsyncedCount.hashCode ^
      lastFailedMutation.hashCode;
}
