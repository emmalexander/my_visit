import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pending_mutation.dart';
import 'task_local_store.dart';

class SharedPrefsTaskLocalStore implements TaskLocalStore {
  SharedPrefsTaskLocalStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const String _keyMutations = 'my_visits_pending_mutations_v1';
  static const String _keySequence = 'my_visits_mutation_sequence_v1';

  SharedPreferences? _prefs;
  final Map<String, PendingMutation> _cache = {};
  int _sequenceCounter = 0;

  @override
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    _sequenceCounter = _prefs!.getInt(_keySequence) ?? 0;
    final jsonString = _prefs!.getString(_keyMutations);
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        _cache.clear();
        for (final entry in decoded.entries) {
          _cache[entry.key] = PendingMutation.fromMap(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      } catch (e) {
        // In case of corrupt storage, gracefully continue with empty cache
        _cache.clear();
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
    await _persist();
  }

  @override
  Future<void> removeMutation(String taskId) async {
    _cache.remove(taskId);
    await _persist();
  }

  @override
  Future<void> markMutationFailed(String taskId, String error) async {
    final existing = _cache[taskId];
    if (existing != null) {
      _cache[taskId] = existing.copyWith(
        isFailed: true,
        lastError: error,
        retryCount: existing.retryCount + 1,
      );
      await _persist();
    }
  }

  @override
  Future<void> clearAll() async {
    _cache.clear();
    await _prefs?.remove(_keyMutations);
  }

  @override
  int getNextSequenceNumber() {
    _sequenceCounter++;
    _prefs?.setInt(_keySequence, _sequenceCounter);
    return _sequenceCounter;
  }

  Future<void> _persist() async {
    if (_prefs == null) return;
    final map = <String, dynamic>{};
    for (final entry in _cache.entries) {
      map[entry.key] = entry.value.toMap();
    }
    await _prefs!.setString(_keyMutations, jsonEncode(map));
  }
}
