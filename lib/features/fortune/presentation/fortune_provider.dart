import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/locale_provider.dart';
import '../../../core/refresh/refresh_policy.dart';
import '../../user/presentation/user_profile_provider.dart';
import '../../weather/domain/entities/weather_entity.dart';
import '../../weather/presentation/weather_provider.dart';
import '../data/repositories/fortune_repository_impl.dart';
import '../data/sources/mingri_data_source.dart';
import '../domain/calculators/fortune_score_calculator.dart';
import '../domain/calculators/ganji_calculator.dart';
import '../domain/calculators/saju_calculator.dart';
import '../domain/entities/fortune_evaluation_context.dart';
import '../domain/entities/fortune_result.dart';
import '../domain/entities/fortune_tone.dart';
import '../domain/entities/oheng.dart';
import '../domain/services/weather_oheng_mapper.dart';
import 'fortune_tone_provider.dart';

part 'fortune_provider.g.dart';

const _fortuneCacheVersion = 'v8';
const _fortuneCacheCleanupVersionKey = 'daily_fortune_cache_cleanup_version';

@Riverpod(keepAlive: true)
Future<FortuneResult> dailyFortune(Ref ref) async {
  final logger = Logger();
  final slotTimer = Timer(_durationUntilNextFortuneSlot(), ref.invalidateSelf);
  ref.onDispose(slotTimer.cancel);

  final profile = await ref.watch(userProfileNotifierProvider.future);
  if (profile == null) {
    throw const FortuneNoProfileException();
  }

  // watch는 언어/톤 변경 시 재계산 트리거용. 실제 값은 저장소에서 직접 읽는다 —
  // 두 notifier 모두 초기값(ko/base)으로 시작한 뒤 저장값을 비동기 로드하므로,
  // 앱 시작 직후 watch 값만 쓰면 잘못된 키로 캐시 미스가 나는 레이스가 있다.
  ref.watch(appLanguageNotifierProvider);
  ref.watch(fortuneToneProvider);
  final language = (await loadSavedAppLanguage()).tableKey;
  final (:slot, :date) = TimeSlot.forNow();
  final profileFingerprint = [
    profile.birthDate.year,
    profile.birthDate.month.toString().padLeft(2, '0'),
    profile.birthDate.day.toString().padLeft(2, '0'),
    profile.birthHour,
  ].join();

  final prefs = await SharedPreferences.getInstance();
  final tone = FortuneTone.fromStorage(prefs.getString(fortuneToneStorageKey));

  final dateKey =
      '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  final cacheKey =
      'fortune_$_fortuneCacheVersion'
      '_$language'
      '_${tone.storageValue}'
      '_$dateKey'
      '_${slot.name}'
      '_$profileFingerprint';
  final diagnosticFingerprint = FortuneEvaluationContext.stableFingerprint(
    profileFingerprint,
  );

  await _clearLegacyFortuneCacheIfNeeded(prefs);
  final cachedValue = prefs.getString(cacheKey);
  if (cachedValue != null) {
    try {
      logger.d(
        '[Fortune] cache hit slot=${slot.name} '
        'profile=$diagnosticFingerprint',
      );
      return FortuneResult.fromJson(
        jsonDecode(cachedValue) as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      logger.w(
        '[Fortune] cache parse failed slot=${slot.name}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  late final WeatherCondition weatherCondition;
  try {
    final weather = await ref
        .read(currentWeatherProvider.future)
        .timeout(const Duration(seconds: 2));
    if (RefreshPolicy.isWeatherRefreshDue(weather)) {
      throw const FortuneWeatherRefreshRequiredException();
    }
    weatherCondition = weather.condition;
  } on FortuneWeatherRefreshRequiredException {
    rethrow;
  } catch (_) {
    throw const FortuneWeatherRefreshRequiredException();
  }

  final weatherOheng = WeatherOhengMapper.toOheng(weatherCondition);
  final context = FortuneEvaluationContext(
    basisDate: date,
    slot: slot,
    profileFingerprint: profileFingerprint,
    language: language,
    tone: tone,
    weatherOheng: weatherOheng,
  );

  final saju = SajuCalculator.calculate(profile.birthDate, profile.birthHour);
  final todayGanji = GanjiCalculator.todayGanji(context.basisDate);
  final rawScores = FortuneScoreCalculator.calculateRawScores(
    saju,
    todayGanji,
    weatherOheng,
  );
  final scores = FortuneScoreCalculator.calculate(
    saju,
    todayGanji,
    weatherOheng,
  );
  logger.d(
    '[Fortune] compute version=$_fortuneCacheVersion '
    'slot=${context.slot.name} date=${date.toIso8601String()} '
    'profile=${context.diagnosticFingerprint} weather=${weatherOheng?.name} '
    'raw=$rawScores scores=$scores',
  );

  const repository = FortuneRepositoryImpl(MingriDataSource());
  final result = await repository.getDailyFortune(
    saju: saju,
    scores: scores,
    context: context,
  );
  if (result.error != null) {
    throw Exception(result.error.toString());
  }

  final fortune = result.data!;
  await prefs.setString(cacheKey, jsonEncode(fortune.toJson()));
  return fortune;
}

Duration _durationUntilNextFortuneSlot() {
  final now = DateTime.now();
  final nextBoundary = switch (now.hour) {
    < TimeSlot.morningStartHour => DateTime(
      now.year,
      now.month,
      now.day,
      TimeSlot.morningStartHour,
    ),
    < TimeSlot.afternoonStartHour => DateTime(
      now.year,
      now.month,
      now.day,
      TimeSlot.afternoonStartHour,
    ),
    _ => DateTime(now.year, now.month, now.day + 1, TimeSlot.morningStartHour),
  };
  return nextBoundary.difference(now) + const Duration(seconds: 1);
}

Future<void> _clearLegacyFortuneCacheIfNeeded(SharedPreferences prefs) async {
  if (prefs.getString(_fortuneCacheCleanupVersionKey) == _fortuneCacheVersion) {
    return;
  }

  final fortuneCacheKeys = prefs
      .getKeys()
      .where((key) => key.startsWith('fortune_'))
      .toList(growable: false);
  for (final key in fortuneCacheKeys) {
    await prefs.remove(key);
  }
  await prefs.setString(_fortuneCacheCleanupVersionKey, _fortuneCacheVersion);
}
