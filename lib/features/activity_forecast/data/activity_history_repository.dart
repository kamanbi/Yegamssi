import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/activity_models.dart';

class ActivityHistoryRepository {
  ActivityHistoryRepository({ActivityHistoryStorage? storage})
    : _storage = storage ?? const SecureActivityHistoryStorage();

  static const _historyKey = 'activity_forecast_history_v1';
  static const maxHistoryCount = 20;

  final ActivityHistoryStorage _storage;

  Future<List<ActivityJudgment>> load() async {
    final encoded = await _storage.read(_historyKey);
    if (encoded == null || encoded.isEmpty) return [];

    try {
      final items = jsonDecode(encoded) as List<dynamic>;
      final history = items
          .map(
            (item) => ActivityJudgment.fromJson(item as Map<String, dynamic>),
          )
          .toList();
      _sortForDisplay(history);
      return history;
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<List<ActivityJudgment>> upsert(ActivityJudgment judgment) async {
    final history = await load();
    final isNewJudgment = history.every((item) => item.id != judgment.id);
    if (isNewJudgment &&
        history.length >= maxHistoryCount &&
        history.every((item) => item.isPinned)) {
      throw const FormatException('고정된 판단이 20개입니다. 새 판단을 저장하려면 고정을 하나 해제하세요.');
    }
    history.removeWhere((item) => item.id == judgment.id);
    history.insert(0, judgment);
    final trimmed = _trim(history);
    _sortForDisplay(trimmed);
    await _save(trimmed);
    return trimmed;
  }

  Future<List<ActivityJudgment>> remove(String id) async {
    final history = await load()
      ..removeWhere((item) => item.id == id);
    await _save(history);
    return history;
  }

  Future<List<ActivityJudgment>> setPinned(String id, bool isPinned) async {
    final history = await load();
    final updated = history
        .map((item) => item.id == id ? item.copyWith(isPinned: isPinned) : item)
        .toList();
    _sortForDisplay(updated);
    await _save(updated);
    return updated;
  }

  Future<void> clear() => _storage.delete(_historyKey);

  List<ActivityJudgment> _trim(List<ActivityJudgment> history) {
    if (history.length <= maxHistoryCount) return history;
    final kept = [...history];
    for (
      var index = kept.length - 1;
      index >= 0 && kept.length > maxHistoryCount;
      index--
    ) {
      if (!kept[index].isPinned) kept.removeAt(index);
    }
    if (kept.length > maxHistoryCount) {
      throw const FormatException('고정된 판단이 20개입니다. 새 판단을 저장하려면 고정을 하나 해제하세요.');
    }
    return kept;
  }

  void _sortForDisplay(List<ActivityJudgment> history) {
    history.sort((left, right) {
      if (left.isPinned != right.isPinned) return left.isPinned ? -1 : 1;
      return right.calculatedAt.compareTo(left.calculatedAt);
    });
  }

  Future<void> _save(List<ActivityJudgment> history) {
    return _storage.write(
      _historyKey,
      jsonEncode(history.map((item) => item.toJson()).toList()),
    );
  }
}

abstract interface class ActivityHistoryStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class SecureActivityHistoryStorage implements ActivityHistoryStorage {
  const SecureActivityHistoryStorage({
    FlutterSecureStorage secureStorage = const FlutterSecureStorage(),
  }) : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> read(String key) => _secureStorage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _secureStorage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _secureStorage.delete(key: key);
}
