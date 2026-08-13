import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/features/activity_forecast/data/activity_history_repository.dart';
import 'package:yegamssi/features/activity_forecast/domain/activity_models.dart';

void main() {
  test('keeps pinned judgments first and caps history at 20', () async {
    final repository = ActivityHistoryRepository(storage: _MemoryStorage());
    for (var index = 0; index < 22; index++) {
      await repository.upsert(_judgment(index, isPinned: index == 0));
    }

    final history = await repository.load();
    expect(history, hasLength(ActivityHistoryRepository.maxHistoryCount));
    expect(history.first.id, 'item-0');
    expect(history.first.isPinned, isTrue);
    expect(history.any((item) => item.id == 'item-1'), isFalse);
  });

  test('rejects a new judgment when all 20 entries are pinned', () async {
    final repository = ActivityHistoryRepository(storage: _MemoryStorage());
    for (var index = 0; index < 20; index++) {
      await repository.upsert(_judgment(index, isPinned: true));
    }

    expect(
      () => repository.upsert(_judgment(21)),
      throwsA(isA<FormatException>()),
    );
    expect(await repository.load(), hasLength(20));
  });
}

ActivityJudgment _judgment(int index, {bool isPinned = false}) {
  final at = DateTime(2026, 8, 11).add(Duration(minutes: index));
  return ActivityJudgment(
    id: 'item-$index',
    request: ActivityJudgmentRequest(
      activityType: ActivityType.walkingRunning,
      locationName: '서울',
      latitude: 37.57,
      longitude: 126.98,
      startsAt: at,
      durationMinutes: 60,
      options: const ActivityOptions(),
    ),
    score: 70,
    safetyLevel: ActivitySafetyLevel.allowed,
    coverageLevel: ActivityCoverageLevel.weatherOnly,
    summary: '테스트',
    action: '테스트',
    factors: const [],
    calculatedAt: at,
    dataObservedAt: at,
    expiresAt: at.add(const Duration(minutes: 30)),
    sources: const ['test'],
    isPinned: isPinned,
  );
}

class _MemoryStorage implements ActivityHistoryStorage {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
