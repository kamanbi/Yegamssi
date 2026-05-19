import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/locale/country_code.dart';
import '../../../core/locale/locale_provider.dart';
import '../../user/presentation/user_profile_provider.dart';
import '../../weather/domain/entities/weather_entity.dart';
import '../../weather/presentation/weather_provider.dart';
import '../data/repositories/fortune_repository_impl.dart';
import '../data/sources/mingri_data_source.dart';
import '../domain/calculators/fortune_score_calculator.dart';
import '../domain/calculators/ganji_calculator.dart';
import '../domain/calculators/saju_calculator.dart';
import '../domain/entities/fortune_result.dart';
import '../domain/entities/oheng.dart';
import '../domain/services/weather_oheng_mapper.dart';
import 'fortune_tone_provider.dart';

part 'fortune_provider.g.dart';

const _fortuneCacheVersion = 'v5';
const _fortuneCacheCleanupVersionKey = 'daily_fortune_cache_cleanup_version';

@Riverpod(keepAlive: true)
Future<FortuneResult> dailyFortune(Ref ref) async {
  final logger = Logger();
  final profile = await ref.watch(userProfileNotifierProvider.future);
  if (profile == null) {
    throw const FortuneNoProfileException();
  }

  final lang = ref.watch(appLanguageNotifierProvider).tableKey;
  final tone = ref.watch(fortuneToneProvider);
  final (:slot, :date) = TimeSlot.forNow();
  final fortuneBasisDate = date;
  final dateKey =
      '${fortuneBasisDate.year}${fortuneBasisDate.month.toString().padLeft(2, '0')}${fortuneBasisDate.day.toString().padLeft(2, '0')}';
  final profileFingerprint = [
    profile.birthDate.year,
    profile.birthDate.month.toString().padLeft(2, '0'),
    profile.birthDate.day.toString().padLeft(2, '0'),
    profile.birthHour,
  ].join();
  final cacheKey =
      'fortune_${_fortuneCacheVersion}_${lang}_${tone.storageValue}_${dateKey}_${slot.name}_$profileFingerprint';

  final prefs = await SharedPreferences.getInstance();
  await _clearLegacyFortuneCacheIfNeeded(prefs);
  final cachedValue = prefs.getString(cacheKey);
  if (cachedValue != null) {
    try {
      return FortuneResult.fromJson(
        jsonDecode(cachedValue) as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      logger.w(
        '운세 캐시 파싱 실패로 재생성합니다: cacheKey=$cacheKey',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  WeatherCondition? weatherCondition;
  try {
    final weather = await ref.read(currentWeatherProvider.future);
    weatherCondition = weather.condition;
  } catch (_) {}

  final weatherOheng = weatherCondition == null
      ? null
      : WeatherOhengMapper.toOheng(weatherCondition);
  final saju = SajuCalculator.calculate(profile.birthDate, profile.birthHour);
  final todayGanji = GanjiCalculator.todayGanji(fortuneBasisDate);
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
    '운세 점수 계산: '
    'cacheVersion=$_fortuneCacheVersion, '
    'slot=${slot.name}, '
    'basisDate=${fortuneBasisDate.toIso8601String()}, '
    'birthDate=${profile.birthDate.toIso8601String()}, '
    'birthHour=${profile.birthHour}, '
    'weatherCondition=${weatherCondition?.name}, '
    'weatherOheng=${weatherOheng?.name}, '
    'ohengCount=${saju.ohengCount.map((key, value) => MapEntry(key.name, value))}, '
    'rawScores=${rawScores.map((key, value) => MapEntry(key.name, value))}, '
    'scores=${scores.map((key, value) => MapEntry(key.name, value))}',
  );

  const repository = FortuneRepositoryImpl(MingriDataSource());
  final result = await repository.getDailyFortune(
    saju: saju,
    scores: scores,
    weatherOheng: weatherOheng,
    lang: lang,
    tone: tone,
  );

  if (result.error != null) {
    throw Exception(result.error.toString());
  }

  final fortune = result.data!;
  await prefs.setString(cacheKey, jsonEncode(fortune.toJson()));
  return fortune;
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
