import 'dart:async';
import 'package:my_visit/api/flaky_task_api.dart';

class FakeFlakyTaskApi extends FlakyTaskApi {
  FakeFlakyTaskApi({
    this.customFetchHandler,
    this.customUpdateHandler,
  }) : super(seed: 1);

  Future<TaskPage> Function({String? cursor, String? query, int? limit})?
      customFetchHandler;
  Future<Map<String, dynamic>> Function(String id, String status)?
      customUpdateHandler;

  int fetchCallsCount = 0;
  int updateCallsCount = 0;
  final List<String> fetchedCursors = [];
  final List<String> fetchedQueries = [];

  @override
  Future<TaskPage> fetchTasks({
    String? cursor,
    String query = '',
    int limit = 20,
  }) async {
    fetchCallsCount++;
    fetchedCursors.add(cursor ?? 'null');
    fetchedQueries.add(query);

    if (customFetchHandler != null) {
      return customFetchHandler!(cursor: cursor, query: query, limit: limit);
    }

    return super.fetchTasks(cursor: cursor, query: query, limit: limit);
  }

  @override
  Future<Map<String, dynamic>> updateStatus(String id, String status) async {
    updateCallsCount++;

    if (customUpdateHandler != null) {
      return customUpdateHandler!(id, status);
    }

    return super.updateStatus(id, status);
  }
}
