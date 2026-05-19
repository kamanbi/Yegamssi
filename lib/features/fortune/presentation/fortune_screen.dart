import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/capture/capture_storage.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/premium_card.dart';
import '../domain/entities/fortune_result.dart';
import '../domain/entities/oheng.dart';
import 'fortune_provider.dart';
import 'widgets/fortune_category_card.dart';

class FortuneScreen extends ConsumerWidget {
  const FortuneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fortuneAsync = ref.watch(dailyFortuneProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: fortuneAsync.when(
          loading: () => const _LoadingView(),
          error: (error, _) {
            if (error is FortuneNoProfileException) {
              return _NoProfileView(
                onTap: () => context.go(AppRoutes.onboarding),
              );
            }
            return const _ErrorView();
          },
          data: (fortune) => _FortuneDataView(fortune: fortune),
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
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _NoProfileView extends StatelessWidget {
  const _NoProfileView({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: PremiumCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '운세를 보려면 출생 정보가 필요합니다',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.title(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                '생년월일과 생시를 입력하면 오늘의 운세를 조용한 톤으로 정리해 드립니다.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.body(brightness),
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              AppPrimaryButton(
                label: '출생 정보 입력하기',
                onPressed: onTap,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: PremiumCard(
          child: _SectionMessage(
            title: '운세를 불러오지 못했습니다',
            message: '잠시 뒤 다시 시도해 주세요.',
          ),
        ),
      ),
    );
  }
}

class _FortuneDataView extends StatefulWidget {
  const _FortuneDataView({required this.fortune});

  final FortuneResult fortune;

  @override
  State<_FortuneDataView> createState() => _FortuneDataViewState();
}

class _FortuneDataViewState extends State<_FortuneDataView> {
  static const double _capturePreviewOpacity = 0.01;
  static const double _captureMaxPixelRatio = 2.5;

  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fortune = widget.fortune;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x2,
        AppSpacing.x1,
        AppSpacing.x2,
        120,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppDateFormat.format(fortune.date)} · ${fortune.slot.label}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.body(brightness),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.x1),
                  Text(
                    '오늘의 운세',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: AppColors.title(brightness),
                    ),
                  ),
                ],
              ),
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: AppSpacing.x2),
                _FortuneBrandLogo(width: 132, height: 52),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x3),
        _FortuneContentSections(
          fortune: fortune,
          captureButton: _FortuneCaptureButton(
            isCapturing: _isCapturing,
            onPressed: _isCapturing ? null : _captureFortuneCards,
          ),
        ),
      ],
    );
  }

  Future<void> _captureFortuneCards() async {
    if (_isCapturing) return;

    setState(() => _isCapturing = true);
    OverlayEntry? captureEntry;
    try {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) {
        throw StateError('캡처 화면을 준비하지 못했습니다.');
      }

      final captureBoundaryKey = GlobalKey();
      final mediaQuery = MediaQuery.of(context);
      final captureWidth = MediaQuery.sizeOf(context).width;
      final pixelRatio = MediaQuery.devicePixelRatioOf(
        context,
      ).clamp(1.5, _captureMaxPixelRatio).toDouble();

      captureEntry = OverlayEntry(
        builder: (_) => Positioned(
          left: 0,
          top: 0,
          width: captureWidth,
          child: IgnorePointer(
            child: Opacity(
              opacity: _capturePreviewOpacity,
              child: Material(
                color: Colors.transparent,
                child: MediaQuery(
                  data: mediaQuery,
                  child: RepaintBoundary(
                    key: captureBoundaryKey,
                    child: _FortuneCapturePage(fortune: widget.fortune),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      overlay.insert(captureEntry);

      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          captureBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw StateError('캡처 영역을 찾지 못했습니다.');
      }

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();
      if (pngBytes == null || pngBytes.isEmpty) {
        throw StateError('캡처 이미지 생성에 실패했습니다.');
      }

      final savedPath = await CaptureStorage.savePng(
        bytes: Uint8List.fromList(pngBytes),
        fileName: _captureFileName(widget.fortune.date),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath == null ? '운세 카드 캡처를 저장했습니다.' : '운세 카드 캡처 저장 완료',
          ),
          action: SnackBarAction(
            label: '폴더 열기',
            onPressed: () {
              CaptureStorage.openCaptureFolder();
            },
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('캡처에 실패했습니다: $error')));
    } finally {
      captureEntry?.remove();
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  String _captureFileName(DateTime date) {
    final capturedAt = DateTime.now();
    final stamp = [
      date.year.toString().padLeft(4, '0'),
      date.month.toString().padLeft(2, '0'),
      date.day.toString().padLeft(2, '0'),
      capturedAt.hour.toString().padLeft(2, '0'),
      capturedAt.minute.toString().padLeft(2, '0'),
      capturedAt.second.toString().padLeft(2, '0'),
    ].join();
    return 'yegamssi_fortune_$stamp.png';
  }
}

class _FortuneBrandLogo extends StatelessWidget {
  const _FortuneBrandLogo({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Transform.scale(
            scale: 2.35,
            child: Image.asset(AppAssets.yegamssiLogo, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

class _FortuneCaptureButton extends StatelessWidget {
  const _FortuneCaptureButton({
    required this.isCapturing,
    required this.onPressed,
  });

  final bool isCapturing;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.mutedSurface(brightness).withAlpha(150),
        border: Border.all(color: AppColors.border(brightness)),
      ),
      child: IconButton(
        tooltip: '운세 카드 캡처',
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: isCapturing
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                Icons.photo_camera_outlined,
                color: AppColors.title(brightness),
              ),
      ),
    );
  }
}

class _FortuneCapturePage extends StatelessWidget {
  const _FortuneCapturePage({required this.fortune});

  final FortuneResult fortune;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.scaffold(brightness).withAlpha(245),
            const Color(0xFF102A5F),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${AppDateFormat.format(fortune.date)} · ${fortune.slot.label}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.body(brightness),
                    ),
                  ),
                ),
                const _FortuneBrandLogo(width: 128, height: 50),
              ],
            ),
            const SizedBox(height: AppSpacing.x2),
            Text(
              '오늘의 운세',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.title(brightness),
              ),
            ),
            const SizedBox(height: AppSpacing.x2),
            _FortuneContentSections(fortune: fortune),
          ],
        ),
      ),
    );
  }
}

class _FortuneContentSections extends StatelessWidget {
  const _FortuneContentSections({required this.fortune, this.captureButton});

  final FortuneResult fortune;
  final Widget? captureButton;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FortuneOverviewCard(fortune: fortune, captureButton: captureButton),
        const SizedBox(height: AppSpacing.x3),
        Text(
          '카테고리별 해석',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.title(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.x2),
        FortuneCategoryCard(
          category: FortuneCategory.money,
          score: fortune.scores[FortuneCategory.money] ?? 50,
          message: fortune.messages[FortuneCategory.money] ?? '',
        ),
        const SizedBox(height: AppSpacing.x2),
        FortuneCategoryCard(
          category: FortuneCategory.love,
          score: fortune.scores[FortuneCategory.love] ?? 50,
          message: fortune.messages[FortuneCategory.love] ?? '',
        ),
        const SizedBox(height: AppSpacing.x2),
        FortuneCategoryCard(
          category: FortuneCategory.work,
          score: fortune.scores[FortuneCategory.work] ?? 50,
          message: fortune.messages[FortuneCategory.work] ?? '',
        ),
        const SizedBox(height: AppSpacing.x2),
        FortuneCategoryCard(
          category: FortuneCategory.health,
          score: fortune.scores[FortuneCategory.health] ?? 50,
          message: fortune.messages[FortuneCategory.health] ?? '',
        ),
        const SizedBox(height: AppSpacing.x2),
        FortuneCategoryCard(
          category: FortuneCategory.decision,
          score: fortune.scores[FortuneCategory.decision] ?? 50,
          message: fortune.messages[FortuneCategory.decision] ?? '',
        ),
        const SizedBox(height: AppSpacing.x3),
        _OhengSummaryCard(fortune: fortune),
      ],
    );
  }
}

class _FortuneOverviewCard extends StatelessWidget {
  const _FortuneOverviewCard({required this.fortune, this.captureButton});

  final FortuneResult fortune;
  final Widget? captureButton;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final score = fortune.scores[FortuneCategory.overall] ?? 50;
    final message = fortune.messages[FortuneCategory.overall] ?? '';
    final accent = _scoreColor(score);

    return PremiumCard(
      tone: PremiumCardTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '종합 운세',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.title(brightness),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withAlpha(16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withAlpha(70)),
                ),
                child: Text(
                  '$score점',
                  style: AppTextStyles.labelLarge.copyWith(color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.x2),
          LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            message,
            style: AppTextStyles.fortuneLine.copyWith(
              color: AppColors.body(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          Row(
            children: [
              Expanded(
                child: _LuckyFortuneChips(fortune: fortune, score: score),
              ),
              if (captureButton != null) ...[
                const SizedBox(width: AppSpacing.x1),
                captureButton!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LuckyFortuneChips extends StatelessWidget {
  const _LuckyFortuneChips({required this.fortune, required this.score});

  final FortuneResult fortune;
  final int score;

  @override
  Widget build(BuildContext context) {
    final luckyNumber = _luckyNumberFor(fortune, score);
    final luckyColor = _luckyColorFor(_dominantOheng(fortune.ohengRatio));

    return Wrap(
      spacing: AppSpacing.x1,
      runSpacing: AppSpacing.x1,
      children: [
        _LuckyPill(
          label: '행운 숫자',
          child: Text(
            '$luckyNumber',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.accentGold,
            ),
          ),
        ),
        _LuckyPill(
          label: '행운 색상',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: luckyColor.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(120)),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                luckyColor.name,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentGold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LuckyPill extends StatelessWidget {
  const _LuckyPill({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withAlpha(18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accentGold.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.body(brightness),
            ),
          ),
          const SizedBox(width: 8),
          child,
        ],
      ),
    );
  }
}

class _LuckyColorInfo {
  const _LuckyColorInfo({required this.name, required this.color});

  final String name;
  final Color color;
}

class _OhengSummaryCard extends StatelessWidget {
  const _OhengSummaryCard({required this.fortune});

  final FortuneResult fortune;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return PremiumCard(
      tone: PremiumCardTone.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오행 균형',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.title(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            '오늘의 감정 흐름을 참고하는 보조 지표입니다.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.body(brightness),
            ),
          ),
          const SizedBox(height: AppSpacing.x2),
          ...Oheng.values.map(
            (oheng) => Padding(
              padding: EdgeInsets.only(
                bottom: oheng == Oheng.values.last ? 0 : AppSpacing.x2,
              ),
              child: _OhengRow(
                oheng: oheng,
                value: fortune.ohengRatio[oheng] ?? 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OhengRow extends StatelessWidget {
  const _OhengRow({required this.oheng, required this.value});

  final Oheng oheng;
  final double value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        SizedBox(
          width: 68,
          child: Text(
            oheng.korean,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.title(brightness),
            ),
          ),
        ),
        Expanded(
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outlineVariant.withAlpha(90),
            valueColor: AlwaysStoppedAnimation<Color>(_ohengColor(oheng)),
          ),
        ),
        const SizedBox(width: AppSpacing.x2),
        Text(
          '${(value * 100).round()}%',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.body(brightness),
          ),
        ),
      ],
    );
  }
}

class _SectionMessage extends StatelessWidget {
  const _SectionMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.title(brightness),
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.body(brightness),
          ),
        ),
      ],
    );
  }
}

Color _scoreColor(int score) {
  if (score >= 75) return AppColors.scoreExcellent;
  if (score >= 50) return AppColors.scoreGood;
  if (score >= 25) return AppColors.scoreFair;
  return AppColors.scorePoor;
}

int _luckyNumberFor(FortuneResult fortune, int score) {
  final date = fortune.date;
  final seed =
      date.year * 37 +
      date.month * 17 +
      date.day * 13 +
      score * 7 +
      fortune.slot.index * 11;
  return seed % 99 + 1;
}

Oheng _dominantOheng(Map<Oheng, double> ratios) {
  var bestOheng = Oheng.to;
  var bestValue = -1.0;
  for (final entry in ratios.entries) {
    if (entry.value > bestValue) {
      bestOheng = entry.key;
      bestValue = entry.value;
    }
  }
  return bestOheng;
}

_LuckyColorInfo _luckyColorFor(Oheng oheng) {
  return switch (oheng) {
    Oheng.mok => const _LuckyColorInfo(name: '초록', color: Color(0xFF79C68A)),
    Oheng.hwa => const _LuckyColorInfo(name: '코랄', color: Color(0xFFE68A80)),
    Oheng.to => const _LuckyColorInfo(name: '골드', color: Color(0xFFD6B168)),
    Oheng.geum => const _LuckyColorInfo(name: '실버', color: Color(0xFFB8C3D6)),
    Oheng.su => const _LuckyColorInfo(name: '하늘색', color: Color(0xFF7DAFE8)),
  };
}

Color _ohengColor(Oheng oheng) {
  return switch (oheng) {
    Oheng.mok => const Color(0xFF79C68A),
    Oheng.hwa => const Color(0xFFE68A80),
    Oheng.to => const Color(0xFFD6B168),
    Oheng.geum => const Color(0xFF9FB3CC),
    Oheng.su => const Color(0xFF7DAFE8),
  };
}
