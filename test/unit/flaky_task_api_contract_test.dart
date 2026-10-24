import 'package:flutter_test/flutter_test.dart';
import 'package:my_visit/api/flaky_task_api.dart';

Future<TaskPage> _fetchWithRetry(
  FlakyTaskApi api, {
  String? cursor,
  int limit = 20,
}) async {
  for (int i = 0; i < 20; i++) {
    try {
      return await api.fetchTasks(cursor: cursor, limit: limit);
    } catch (_) {}
  }
  throw StateError('Failed to fetch after retries');
}

void main() {
  group('FlakyTaskApi Contract and Behavioral Quirks', () {
    test('task 53 has null title and task 89 has archived status', () async {
      final api = FlakyTaskApi(seed: 42);
      final page1 = await _fetchWithRetry(api, cursor: null, limit: 100);

      final task53 = page1.items.firstWhere((t) => t['id'] == 'task_53');
      expect(task53['title'], isNull,
          reason: 'Backend contract includes visits with null title');

      final task89 = page1.items.firstWhere((t) => t['id'] == 'task_89');
      expect(task89['status'], equals('archived'),
          reason: 'Backend contract includes archived visits');
    });

    test('exhibits off-by-one overlapping cursor behavior between page 1 and page 2',
        () async {
      final api = FlakyTaskApi(seed: 42);
      final page1 = await _fetchWithRetry(api, cursor: null, limit: 20);
      expect(page1.items.length, equals(20));
      expect(page1.nextCursor, equals('20'));

      // Fetch page 2 with cursor '20'
      final page2 = await _fetchWithRetry(api, cursor: page1.nextCursor, limit: 20);

      // Line 57 in FlakyTaskApi: from = start == 0 ? 0 : start - 1
      // For start=20, from=19. The last element of page 1 (task_20) is repeated!
      final lastPage1Id = page1.items.last['id'];
      final firstPage2Id = page2.items.first['id'];

      expect(lastPage1Id, equals('task_20'));
      expect(firstPage2Id, equals('task_20'),
          reason:
              'FlakyTaskApi returns item index 19 again in page 2 due to start - 1 logic');
    });

    test('nextCursor becomes null when reaching end of matches', () async {
      final api = FlakyTaskApi(seed: 42);
      final page = await _fetchWithRetry(api, cursor: '130', limit: 20);
      // Total items = 137, start=130, end=137
      expect(page.nextCursor, isNull);
    });
  });
}
