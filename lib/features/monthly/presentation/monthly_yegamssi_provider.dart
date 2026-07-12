import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/app_exception.dart';
import '../../fortune/domain/calculators/saju_calculator.dart';
import '../../user/domain/entities/user_profile.dart';
import '../../user/presentation/user_profile_provider.dart';
import '../domain/calculators/monthly_day_scorer.dart';
import '../domain/entities/monthly_category.dart';
import '../domain/entities/monthly_yegamssi_result.dart';

part 'monthly_yegamssi_provider.g.dart';

const _monthlyCacheKey = 'monthly_yegamssi_current';

// 메모리 플래그(영속화 금지 — 크래시 시 영구 잠금 방지). 지시서 2.1.
bool _isGenerating = false;

@Riverpod(keepAlive: true)
Future<MonthlyYegamssiResult> monthlyYegamssi(Ref ref) async {
  final logger = Logger();

  final profile = await ref.watch(userProfileNotifierProvider.future);
  if (profile == null) {
    throw const MonthlyNoProfileException();
  }

  final now = DateTime.now();
  final targetYear = now.year;
  final targetMonth = now.month;
  final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
  final currentMonthKey = _monthKey(targetYear, targetMonth);
  final currentProfileHash = _profileHash(profile);

  final prefs = await SharedPreferences.getInstance();
  final cachedRaw = prefs.getString(_monthlyCacheKey);
  MonthlyYegamssiResult? cached;
  if (cachedRaw != null) {
    try {
      cached = MonthlyYegamssiResult.fromJson(
        jsonDecode(cachedRaw) as Map<String, dynamic>,
      );
    } catch (error, stackTrace) {
      logger.w(
        'MonthlyYegamssi: cache parse failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  final profileMatch =
      cached != null && cached.profileHash == currentProfileHash;
  if (kDebugMode) {
    logger.d(
      'MonthlyYegamssi: currentMonthKey=$currentMonthKey '
      'cachedMonthKey=${cached?.monthKey} profileMatch=$profileMatch '
      '${cached != null && cached.monthKey == currentMonthKey && profileMatch ? '→ cache hit' : '→ generate'}',
    );
  }

  if (cached != null &&
      cached.monthKey == currentMonthKey &&
      cached.profileHash == currentProfileHash) {
    return cached;
  }

  // 생성 필요. 동시 생성 방지.
  if (_isGenerating) {
    if (cached != null) return cached;
    throw const MonthlyGenerationException('이미 생성 중입니다');
  }

  _isGenerating = true;
  try {
    if (kDebugMode) {
      logger.d('MonthlyYegamssi: generate start month=$currentMonthKey');
    }

    final seed =
        '${_birthDateKey(profile.birthDate)}_${profile.birthHour}_'
        '${profile.gender.name}_${targetYear}_$targetMonth';

    final saju = SajuCalculator.calculate(profile.birthDate, profile.birthHour);
    final scored = MonthlyDayScorer.scoreMonth(
      saju: saju,
      targetYear: targetYear,
      targetMonth: targetMonth,
      lastDayOfMonth: lastDayOfMonth,
      seed: seed,
    );

    final categories = MonthlyCategory.values
        .map(
          (category) => MonthlyCategoryResult(
            category: category,
            goodDays: List<int>.from(scored[category]!.goodDays)..sort(),
            cautionDays: List<int>.from(scored[category]!.cautionDays)..sort(),
          ),
        )
        .toList();

    final summaryPhase = _decideSummaryPhase(categories, lastDayOfMonth);

    final result = MonthlyYegamssiResult(
      monthKey: currentMonthKey,
      profileHash: currentProfileHash,
      generatedAt: now,
      targetYear: targetYear,
      targetMonth: targetMonth,
      summaryPhase: summaryPhase,
      categories: categories,
    );

    if (!_validate(result, lastDayOfMonth)) {
      logger.w('MonthlyYegamssi: validation failed month=$currentMonthKey');
      if (cached != null) return cached; // 저장 안 함, 기존 캐시 유지
      throw const MonthlyGenerationException();
    }

    await prefs.setString(_monthlyCacheKey, jsonEncode(result.toJson()));
    if (kDebugMode) {
      logger.d('MonthlyYegamssi: save success month=$currentMonthKey');
    }
    return result;
  } finally {
    _isGenerating = false;
  }
}

String _monthKey(int year, int month) =>
    '$year-${month.toString().padLeft(2, '0')}';

String _birthDateKey(DateTime birthDate) =>
    '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-'
    '${birthDate.day.toString().padLeft(2, '0')}';

// 프로필 지문: 생년월일 + 출생시간 + 성별. 변경 시 재생성 트리거.
String _profileHash(UserProfile profile) {
  final raw =
      '${_birthDateKey(profile.birthDate)}_${profile.birthHour}_'
      '${profile.gender.name}';
  return raw.hashCode.toRadixString(16);
}

// 월간 총평: 월을 3구간으로 나눠 전체 카테고리 good day 밀도가 가장 높은 구간 선택.
// scoreMonth가 원점수를 반환하지 않으므로 good day 개수로 판정한다(지시서 허용).
MonthlySummaryPhase _decideSummaryPhase(
  List<MonthlyCategoryResult> categories,
  int lastDayOfMonth,
) {
  final third = lastDayOfMonth / 3;
  var early = 0;
  var mid = 0;
  var late = 0;
  for (final category in categories) {
    for (final day in category.goodDays) {
      if (day <= third) {
        early++;
      } else if (day <= third * 2) {
        mid++;
      } else {
        late++;
      }
    }
  }
  // 동점 시 early > mid > late 우선(결정적).
  if (early >= mid && early >= late) return MonthlySummaryPhase.early;
  if (mid >= late) return MonthlySummaryPhase.mid;
  return MonthlySummaryPhase.late;
}

// 지시서 5장 유효성 검사. 실패 시 저장하지 않는다.
bool _validate(MonthlyYegamssiResult result, int lastDayOfMonth) {
  if (result.monthKey.isEmpty ||
      result.profileHash.isEmpty ||
      result.targetYear <= 0 ||
      result.targetMonth < 1 ||
      result.targetMonth > 12 ||
      result.categories.isEmpty) {
    return false;
  }
  for (final category in result.categories) {
    if (category.goodDays.isEmpty || category.cautionDays.isEmpty) {
      return false;
    }
    final good = category.goodDays.toSet();
    final caution = category.cautionDays.toSet();
    if (good.intersection(caution).isNotEmpty) {
      return false;
    }
    for (final day in [...category.goodDays, ...category.cautionDays]) {
      if (day < 1 || day > lastDayOfMonth) {
        return false;
      }
    }
  }
  return true;
}
