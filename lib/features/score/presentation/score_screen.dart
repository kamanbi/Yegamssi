import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/glassmorphism.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/widgets/header_refresh_button.dart';
import '../../weather/presentation/weather_provider.dart';
import '../domain/entities/activity_score.dart';
import '../domain/entities/score_tier.dart';
import 'score_provider.dart';
import 'widgets/score_gauge.dart';

class ScoreScreen extends ConsumerWidget {
  const ScoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(currentScoreProvider);
    final weatherAsync = ref.watch(currentWeatherProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: scoreAsync.when(
          loading: () => const _LoadingView(),
          error: (error, _) => _ErrorView(message: error.toString()),
          data: (score) => _ScoreContent(
            score: score,
            pm10: weatherAsync.valueOrNull?.pm10,
            pm25: weatherAsync.valueOrNull?.pm25,
            o3: weatherAsync.valueOrNull?.o3,
            khaiValue: weatherAsync.valueOrNull?.khaiValue,
            khaiGrade: weatherAsync.valueOrNull?.khaiGrade,
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            '야외 활동 점수를 계산하는 중...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                '점수를 계산할 수 없습니다',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreContent extends StatelessWidget {
  const _ScoreContent({
    required this.score,
    this.pm10,
    this.pm25,
    this.o3,
    this.khaiValue,
    this.khaiGrade,
  });

  final ActivityScore score;
  final double? pm10;
  final double? pm25;
  final double? o3;
  final double? khaiValue;
  final int? khaiGrade;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppDateFormat.format(DateTime.now()),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '야외활동 점수',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const HeaderRefreshButton(),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: ScoreGauge(score: score.score, tier: score.tier),
              ),
              const SizedBox(height: 16),
              Text(
                _adviceFor(score.tier),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        if (pm10 != null ||
            pm25 != null ||
            o3 != null ||
            khaiValue != null) ...[
          const SizedBox(height: 16),
          _AirQualityCard(
            pm10: pm10,
            pm25: pm25,
            o3: o3,
            khaiValue: khaiValue,
            khaiGrade: khaiGrade,
          ),
        ],
        const SizedBox(height: 16),
        const _SectionLabel(text: '감점 내역'),
        const SizedBox(height: 8),
        if (score.breakdown.total > 0)
          GlassCard(
            child: Column(
              children: [
                if (score.breakdown.rainDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.umbrella_rounded,
                    iconColor: const Color(0xFF64B5F6),
                    label: '눈비와 강수',
                    deduction: score.breakdown.rainDeduction,
                  ),
                if (score.breakdown.windDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.air_rounded,
                    iconColor: const Color(0xFF80CBC4),
                    label: '바람',
                    deduction: score.breakdown.windDeduction,
                  ),
                if (score.breakdown.heatDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.thermostat_rounded,
                    iconColor: const Color(0xFFEF9A9A),
                    label: '기온',
                    deduction: score.breakdown.heatDeduction,
                  ),
                if (score.breakdown.dustDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.masks_rounded,
                    iconColor: const Color(0xFFCE93D8),
                    label: '대기질',
                    deduction: score.breakdown.dustDeduction,
                  ),
                if (score.breakdown.uvDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.wb_sunny_outlined,
                    iconColor: const Color(0xFFFFB74D),
                    label: '자외선',
                    deduction: score.breakdown.uvDeduction,
                    isLast: score.breakdown.ozoneDeduction == 0,
                  ),
                if (score.breakdown.ozoneDeduction > 0)
                  _BreakdownRow(
                    icon: Icons.blur_on_rounded,
                    iconColor: const Color(0xFFA5D6A7),
                    label: '오존',
                    deduction: score.breakdown.ozoneDeduction,
                    isLast: true,
                  ),
              ],
            ),
          )
        else
          const GlassCard(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.scoreExcellent,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '감점 요인이 거의 없는 안정적인 야외활동 날씨입니다.',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        const GlassCard(
          backgroundColor: AppColors.glassWhite,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '야외활동 점수는 강수, 바람, 체감 기온, 대기질, 자외선 정보를 바탕으로 계산합니다.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _adviceFor(ScoreTier tier) {
    return switch (tier) {
      ScoreTier.excellent => '오늘은 야외활동하기 좋은 날입니다.\n가볍게 나가서 컨디션을 올려보세요.',
      ScoreTier.good => '야외활동은 무난하지만, 바람과 자외선은 한 번 더 확인해 보세요.',
      ScoreTier.fair => '야외활동은 가능하지만, 준비를 더 잘할수록 편안합니다.',
      ScoreTier.poor => '오늘은 실내 활동 중심으로 계획하는 편이 더 안전합니다.',
    };
  }
}

class _AirQualityCard extends StatelessWidget {
  const _AirQualityCard({
    this.pm10,
    this.pm25,
    this.o3,
    this.khaiValue,
    this.khaiGrade,
  });

  final double? pm10;
  final double? pm25;
  final double? o3;
  final double? khaiValue;
  final int? khaiGrade;

  @override
  Widget build(BuildContext context) {
    final integratedGrade = _integratedGrade();
    final metrics = <_AirMetric>[
      if (pm10 != null)
        _AirMetric(
          title: '미세먼지',
          value: pm10!,
          unit: '㎍/㎥',
          grade: _pm10Grade(pm10!),
          maxValue: 200,
          thresholdLabels: const ['좋음', '보통', '나쁨', '매우 나쁨'],
        ),
      if (pm25 != null)
        _AirMetric(
          title: '초미세먼지',
          value: pm25!,
          unit: '㎍/㎥',
          grade: _pm25Grade(pm25!),
          maxValue: 100,
          thresholdLabels: const ['좋음', '보통', '나쁨', '매우 나쁨'],
        ),
      if (o3 != null)
        _AirMetric(
          title: '오존',
          value: o3!,
          unit: 'ppm',
          grade: _o3Grade(o3!),
          maxValue: 0.2,
          thresholdLabels: const ['좋음', '보통', '나쁨', '매우 나쁨'],
          fractionDigits: 3,
        ),
      if (khaiValue != null || khaiGrade != null)
        _AirMetric(
          title: '통합 대기질',
          value: khaiValue ?? _khaiValueFromGrade(khaiGrade),
          unit: '점',
          grade: integratedGrade,
          maxValue: 250,
          thresholdLabels: const ['좋음', '보통', '나쁨', '매우 나쁨'],
        ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.masks_rounded,
                color: Color(0xFFCE93D8),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '대기질',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: integratedGrade.color.withAlpha(36),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: integratedGrade.color.withAlpha(100),
                  ),
                ),
                child: Text(
                  integratedGrade.label,
                  style: TextStyle(
                    color: integratedGrade.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...metrics.asMap().entries.map((entry) {
            final isLast = entry.key == metrics.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: _AirMetricBar(metric: entry.value),
            );
          }),
        ],
      ),
    );
  }

  _AirGrade _integratedGrade() {
    if (khaiGrade != null) {
      return _khaiGrade(khaiGrade!);
    }
    if (pm25 != null) {
      return _pm25Grade(pm25!);
    }
    if (pm10 != null) {
      return _pm10Grade(pm10!);
    }
    if (o3 != null) {
      return _o3Grade(o3!);
    }
    return const _AirGrade('정보 없음', AppColors.textMuted);
  }

  double _khaiValueFromGrade(int? grade) {
    return switch (grade) {
      1 => 40,
      2 => 90,
      3 => 140,
      4 => 220,
      _ => 0,
    };
  }

  _AirGrade _pm10Grade(double value) {
    if (value <= 30) return const _AirGrade('좋음', Color(0xFF4CAF50));
    if (value <= 80) return const _AirGrade('보통', Color(0xFFFFC107));
    if (value <= 150) return const _AirGrade('나쁨', Color(0xFFFF7043));
    return const _AirGrade('매우 나쁨', Color(0xFFE53935));
  }

  _AirGrade _pm25Grade(double value) {
    if (value <= 15) return const _AirGrade('좋음', Color(0xFF4CAF50));
    if (value <= 35) return const _AirGrade('보통', Color(0xFFFFC107));
    if (value <= 75) return const _AirGrade('나쁨', Color(0xFFFF7043));
    return const _AirGrade('매우 나쁨', Color(0xFFE53935));
  }

  _AirGrade _o3Grade(double value) {
    if (value <= 0.030) return const _AirGrade('좋음', Color(0xFF4CAF50));
    if (value <= 0.090) return const _AirGrade('보통', Color(0xFFFFC107));
    if (value <= 0.150) return const _AirGrade('나쁨', Color(0xFFFF7043));
    return const _AirGrade('매우 나쁨', Color(0xFFE53935));
  }

  _AirGrade _khaiGrade(int value) {
    return switch (value) {
      1 => const _AirGrade('좋음', Color(0xFF4CAF50)),
      2 => const _AirGrade('보통', Color(0xFFFFC107)),
      3 => const _AirGrade('나쁨', Color(0xFFFF7043)),
      _ => const _AirGrade('매우 나쁨', Color(0xFFE53935)),
    };
  }
}

class _AirMetric {
  const _AirMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.grade,
    required this.maxValue,
    required this.thresholdLabels,
    this.fractionDigits = 0,
  });

  final String title;
  final double value;
  final String unit;
  final _AirGrade grade;
  final double maxValue;
  final List<String> thresholdLabels;
  final int fractionDigits;
}

class _AirMetricBar extends StatelessWidget {
  const _AirMetricBar({required this.metric});

  final _AirMetric metric;

  @override
  Widget build(BuildContext context) {
    final ratio = (metric.value / metric.maxValue).clamp(0.0, 1.0);
    final valueLabel = metric.fractionDigits == 0
        ? metric.value.round().toString()
        : metric.value.toStringAsFixed(metric.fractionDigits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                metric.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: metric.grade.color.withAlpha(36),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                metric.grade.label,
                style: TextStyle(
                  color: metric.grade.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$valueLabel ${metric.unit}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final markerLeft = (ratio * constraints.maxWidth - 5).clamp(
              0.0,
              constraints.maxWidth - 10,
            );
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4CAF50),
                          Color(0xFFFFC107),
                          Color(0xFFFF7043),
                          Color(0xFFE53935),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: markerLeft,
                    top: 1,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.white70),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: metric.thresholdLabels
              .map(
                (label) => Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _AirGrade {
  const _AirGrade(this.label, this.color);

  final String label;
  final Color color;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.deduction,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int deduction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                '-$deduction',
                style: const TextStyle(
                  color: AppColors.scorePoor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(color: Colors.white.withAlpha(25), height: 1),
      ],
    );
  }
}
