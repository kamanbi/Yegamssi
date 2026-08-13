import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/ads/banner_ad_owner_provider.dart';
import '../../../core/design/app_spacing.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/widgets/app_banner_ad.dart';
import '../../weather/domain/entities/saved_location.dart';
import '../../weather/presentation/weather_location_provider.dart';
import '../../weather/presentation/weather_provider.dart';
import '../data/activity_evidence_cache.dart';
import '../data/fishing_destination_catalog.dart';
import '../data/forest_fire_data_source.dart';
import '../data/mid_sea_forecast_data_source.dart';
import '../domain/activity_judgment_calculator.dart';
import '../domain/activity_models.dart';
import 'activity_availability_provider.dart';
import 'activity_forecast_provider.dart';
import 'widgets/activity_result_actions.dart';

class ActivityForecastScreen extends ConsumerWidget {
  const ActivityForecastScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availability = ref.watch(activityForecastAvailabilityProvider);
    return availability.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _redirectToMonthly(context),
      data: (value) {
        if (value != ActivityForecastAvailability.eligible) {
          return _redirectToMonthly(context);
        }
        return const _ActivityForecastContent();
      },
    );
  }

  Widget _redirectToMonthly(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(AppRoutes.monthlyYegamssi);
    });
    return const _UnavailableActivityView();
  }
}

class _UnavailableActivityView extends StatelessWidget {
  const _UnavailableActivityView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '활동예감은 대한민국 현재 위치가 확인될 때만 사용할 수 있습니다.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.x2),
            FilledButton(
              onPressed: () => context.go(AppRoutes.monthlyYegamssi),
              child: const Text('월간예감으로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityForecastContent extends ConsumerWidget {
  const _ActivityForecastContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(activityForecastControllerProvider);
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2,
              AppSpacing.x2,
              AppSpacing.x2,
              AppSpacing.x1,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '활동예감',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if ((history.valueOrNull?.isNotEmpty ?? false))
                    TextButton(
                      onPressed: () => _confirmClear(context, ref),
                      child: const Text('전체 삭제'),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final type = ActivityType.values[index];
                return _ActivityButton(
                  type: type,
                  onTap: () => _openJudgmentSheet(context, ref, type: type),
                );
              }, childCount: ActivityType.values.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: AppSpacing.x1,
                crossAxisSpacing: AppSpacing.x1,
                childAspectRatio: 1.05,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2,
              AppSpacing.x3,
              AppSpacing.x2,
              AppSpacing.x1,
            ),
            sliver: SliverToBoxAdapter(
              child: Text(
                '최근 판단',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          history.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Padding(
                padding: AppSpacing.card,
                child: Text('저장된 판단을 불러오지 못했습니다.'),
              ),
            ),
            data: (items) => items.isEmpty
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: AppSpacing.card,
                      child: Text('저장된 판단이 없습니다.'),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.x2,
                      0,
                      AppSpacing.x2,
                      140,
                    ),
                    sliver: SliverList.separated(
                      itemBuilder: (context, index) => _HistoryTile(
                        judgment: items[index],
                        onOpen: () => _openJudgmentSheet(
                          context,
                          ref,
                          type: items[index].request.activityType,
                          existing: items[index],
                        ),
                        onPin: () => ref
                            .read(activityForecastControllerProvider.notifier)
                            .setPinned(items[index].id, !items[index].isPinned),
                        onDelete: () => ref
                            .read(activityForecastControllerProvider.notifier)
                            .remove(items[index].id),
                      ),
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.x1),
                      itemCount: items.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('판단 이력 전체 삭제'),
        content: const Text('고정한 항목을 포함한 모든 판단 이력을 삭제합니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(activityForecastControllerProvider.notifier).clear();
    }
  }

  Future<void> _openJudgmentSheet(
    BuildContext context,
    WidgetRef ref, {
    required ActivityType type,
    ActivityJudgment? existing,
  }) async {
    ActivityDestination? resolvedDestination;
    var requiresDestinationReselection = false;
    final request = existing?.request;
    final isSavedOfficialPort =
        request != null &&
        (request.destinationKind ==
                ActivityDestinationKind.officialFishingPort ||
            request.destinationId.startsWith('mof-port:') ||
            request.destinationId.startsWith('fipa-port:'));
    if (isSavedOfficialPort) {
      resolvedDestination = await ref
          .read(fishingDestinationCatalogProvider)
          .resolveSavedDestination(request);
      requiresDestinationReselection = resolvedDestination == null;
      if (!context.mounted) return;
    }

    ref.read(bannerAdOwnerProvider.notifier).state =
        BannerAdOwner.activitySheet;
    try {
      await showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: false,
        builder: (_) => FractionallySizedBox(
          heightFactor: 1,
          child: _ActivityJudgmentSheet(
            type: type,
            existing: existing,
            resolvedDestination: resolvedDestination,
            requiresDestinationReselection: requiresDestinationReselection,
          ),
        ),
      );
    } finally {
      if (context.mounted) {
        ref.read(bannerAdOwnerProvider.notifier).state = BannerAdOwner.home;
      }
    }
  }
}

class _ActivityButton extends StatelessWidget {
  const _ActivityButton({required this.type, required this.onTap});

  final ActivityType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withAlpha(210),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ActivityImage(type: type, size: 48),
            const SizedBox(height: 4),
            Text(_labelFor(type), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.judgment,
    required this.onOpen,
    required this.onPin,
    required this.onDelete,
  });

  static const double _actionButtonSize = 24;
  static const double _actionIconSize = 16;

  final ActivityJudgment judgment;
  final VoidCallback onOpen;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scoreText = _historyScoreLabel(judgment);
    final expiryText = judgment.isExpired ? ' · 만료됨' : '';
    final summaryText =
        '${_labelFor(judgment.request.activityType)}, '
        '${judgment.request.locationName}, '
        '${_formatDateTime(judgment.request.startsAt)}';
    final judgmentText =
        '판단 ${_judgmentStatusLabel(judgment)} · $scoreText$expiryText';
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        onTap: onOpen,
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
        minVerticalPadding: AppSpacing.x1,
        title: _SingleLineScaleDownText(summaryText),
        subtitle: _SingleLineScaleDownText(judgmentText),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HistoryActionButton(
              tooltip: judgment.isPinned ? '고정 해제' : '고정',
              onPressed: onPin,
              icon: judgment.isPinned
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
            ),
            _HistoryActionButton(
              tooltip: '삭제',
              onPressed: onDelete,
              icon: Icons.delete_outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryActionButton extends StatelessWidget {
  const _HistoryActionButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: _HistoryTile._actionIconSize,
      splashRadius: _HistoryTile._actionButtonSize / 2,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(_HistoryTile._actionButtonSize),
        maximumSize: const Size.square(_HistoryTile._actionButtonSize),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _SingleLineScaleDownText extends StatelessWidget {
  const _SingleLineScaleDownText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SizedBox(
        width: constraints.maxWidth,
        child: FittedBox(
          alignment: Alignment.centerLeft,
          fit: BoxFit.scaleDown,
          child: Text(text, maxLines: 1, softWrap: false),
        ),
      ),
    );
  }
}

class _ActivityJudgmentSheet extends ConsumerStatefulWidget {
  const _ActivityJudgmentSheet({
    required this.type,
    this.existing,
    this.resolvedDestination,
    this.requiresDestinationReselection = false,
  });

  final ActivityType type;
  final ActivityJudgment? existing;
  final ActivityDestination? resolvedDestination;
  final bool requiresDestinationReselection;

  @override
  ConsumerState<_ActivityJudgmentSheet> createState() =>
      _ActivityJudgmentSheetState();
}

class _ActivityJudgmentSheetState
    extends ConsumerState<_ActivityJudgmentSheet> {
  static const _maximumCustomFishingDistanceKm = 25.0;
  static const _automaticRecalculationInterval = Duration(hours: 6);

  late DateTime _startsAt;
  late int _durationMinutes;
  late ActivityOptions _options;
  SavedLocation? _selectedLocation;
  ActivityDestination? _selectedDestination;
  ActivityJudgment? _result;
  bool _isEditing = true;
  bool _isCalculating = false;
  String? _errorMessage;
  String? _activeId;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _startsAt =
        existing?.request.startsAt ??
        DateTime.now().add(const Duration(hours: 1));
    _durationMinutes = existing?.request.durationMinutes ?? 120;
    _options =
        existing?.request.options ??
        ActivityOptions(variant: _optionsFor(widget.type).first);
    _selectedLocation = existing == null
        ? null
        : SavedLocation(
            name: existing.request.locationName,
            lat: existing.request.latitude,
            lon: existing.request.longitude,
          );
    if (widget.resolvedDestination != null) {
      _selectedDestination = widget.resolvedDestination;
    } else if (existing != null &&
        existing.request.destinationId.isNotEmpty &&
        !widget.requiresDestinationReselection) {
      _selectedDestination = ActivityDestination(
        id: existing.request.destinationId,
        name: existing.request.locationName,
        areaName: existing.request.destinationAreaName,
        latitude: existing.request.latitude,
        longitude: existing.request.longitude,
        source: existing.request.destinationSource,
        kind:
            existing.request.destinationKind ??
            ActivityDestinationKind.customLocation,
        supportedOptions: existing.request.options.secondary.isEmpty
            ? const []
            : [existing.request.options.secondary],
      );
    }
    _result = existing;
    _activeId = existing?.id;
    _isEditing = existing == null;
    if (_shouldAutomaticallyRecalculate(existing)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _calculate();
      });
    }
  }

  bool _shouldAutomaticallyRecalculate(ActivityJudgment? judgment) {
    if (judgment == null || widget.requiresDestinationReselection) return false;
    if (!judgment.request.startsAt.isAfter(DateTime.now())) return false;
    if (!judgment.sources.contains(
      ActivityJudgmentCalculator.calculationVersion,
    )) {
      return true;
    }
    if (judgment.judgmentMode == ActivityJudgmentMode.detailed) return false;
    return DateTime.now().difference(judgment.calculatedAt) >=
        _automaticRecalculationInterval;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final isKeyboardOpen = keyboardInset > 0;
    final bottomInset = isKeyboardOpen
        ? keyboardInset
        : mediaQuery.viewPadding.bottom;

    final compactTheme = Theme.of(
      context,
    ).copyWith(visualDensity: VisualDensity.compact);

    return Theme(
      data: compactTheme,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2),
              child: Column(
                children: [
                  SizedBox(
                    height: 96,
                    child: Row(
                      children: [
                        _ActivityImage(type: widget.type, size: 56),
                        const SizedBox(width: AppSpacing.x2),
                        Expanded(
                          child: Text(
                            _labelFor(widget.type),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          tooltip: '닫기',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 22),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: AppSpacing.x1),
                      child: _isEditing ? _buildForm() : _buildResult(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          if (!isKeyboardOpen) const AppBannerAd(),
          SizedBox(height: bottomInset + AppSpacing.x1),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final requiresPlannedDestination =
        widget.type == ActivityType.seaFishing ||
        widget.type == ActivityType.hiking;
    final favorites = ref.watch(favoriteLocationsProvider).valueOrNull ?? [];
    final selectableLocations = [...favorites];
    final selectedLocation = _selectedLocation;
    if (selectedLocation != null &&
        !selectableLocations.contains(selectedLocation)) {
      selectableLocations.insert(0, selectedLocation);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (requiresPlannedDestination)
          _DestinationField(
            type: widget.type,
            destination: _selectedDestination,
            onTap: widget.type == ActivityType.seaFishing
                ? _selectFishingDestination
                : _selectMountainDestination,
          )
        else
          DropdownButtonFormField<SavedLocation?>(
            initialValue: _selectedLocation,
            decoration: const InputDecoration(labelText: '장소'),
            items: [
              const DropdownMenuItem<SavedLocation?>(child: Text('현재 위치')),
              ...selectableLocations.map(
                (location) => DropdownMenuItem<SavedLocation?>(
                  value: location,
                  child: Text(location.name),
                ),
              ),
            ],
            onChanged: (value) => setState(() => _selectedLocation = value),
          ),
        const SizedBox(height: AppSpacing.x2),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('시작 일시'),
          subtitle: Text(_formatDateTime(_startsAt)),
          onTap: _pickStartDateTime,
        ),
        DropdownButtonFormField<int>(
          initialValue: _durationMinutes,
          decoration: const InputDecoration(labelText: '활동 시간'),
          items: const [60, 120, 180, 240, 360, 480]
              .map(
                (minutes) => DropdownMenuItem(
                  value: minutes,
                  child: Text('${minutes ~/ 60}시간'),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _durationMinutes = value);
          },
        ),
        const SizedBox(height: AppSpacing.x2),
        _ActivityOptionsEditor(
          type: widget.type,
          value: _options,
          supportedSecondaryOptions:
              _selectedDestination?.supportedOptions ?? const [],
          onChanged: (value) => setState(() {
            if (widget.type == ActivityType.seaFishing &&
                value.variant != _options.variant) {
              _selectedDestination = null;
              _options = ActivityOptions(variant: value.variant);
              return;
            }
            _options = value;
          }),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.x2),
          Text(
            _errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.x3),
        FilledButton(
          onPressed: _isCalculating ? null : _calculate,
          child: _isCalculating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('판단하기'),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final result = _result!;
    final positiveFactors = result.factors
        .where((factor) => factor.contribution >= 0)
        .toList(growable: false);
    final riskFactors = result.factors
        .where((factor) => factor.contribution < 0)
        .toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withAlpha(180),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _judgmentScoreLabel(result),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: _safetyColor(result.safetyLevel),
                          ),
                    ),
                    const SizedBox(width: AppSpacing.x1),
                    Text(
                      _judgmentStatusLabel(result),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x1),
              Text(
                '${_judgmentModeLabel(result.judgmentMode)} · 신뢰도 ${_confidenceLabel(result.confidence)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                result.summary,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          '${result.request.locationName} · ${_formatDateTime(result.request.startsAt)}~${_formatTime(result.request.endsAt)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (result.request.activityType == ActivityType.carWash)
          Text(
            '유지 판단 ${_formatDateTime(result.request.startsAt)}~${_formatDateTime(result.request.evidenceEndsAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        const SizedBox(height: AppSpacing.x1),
        _ActivityDetailSection(title: '행동 권고', lines: [result.action]),
        if (positiveFactors.isNotEmpty)
          _ActivityFactorSection(title: '긍정 요인', factors: positiveFactors),
        if (riskFactors.isNotEmpty)
          _ActivityFactorSection(title: '위험 요인', factors: riskFactors),
        if (result.unverifiedFactors.isNotEmpty)
          _ActivityDetailSection(
            title: '미확인 자료',
            lines: result.unverifiedFactors,
          ),
        if (result.alternativeWindows.isNotEmpty)
          _ActivityDetailSection(
            title: '더 나은 대안',
            lines: result.alternativeWindows,
          ),
        const SizedBox(height: AppSpacing.x1),
        Text(
          '자료 기준 ${_formatDateTime(result.dataObservedAt)} · ${_coverageLabel(result.coverageLevel)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (result.evidenceValidFrom != null &&
            result.evidenceValidUntil != null)
          Text(
            '해양 예보 유효 ${_formatDateTime(result.evidenceValidFrom!)}~${_formatDateTime(result.evidenceValidUntil!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (result.isExpired)
          Text(
            '이 판단은 만료되었습니다. 다시 계산하세요.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (_errorMessage != null)
          Text(
            _errorMessage!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        Text(
          result.sources.join(' · '),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.x2),
        ActivityResultActions(
          isCalculating: _isCalculating,
          onEditConditions: () => setState(() {
            _isEditing = true;
            _errorMessage = null;
          }),
          onRecalculate: () {
            if (widget.requiresDestinationReselection &&
                _selectedDestination == null) {
              setState(() {
                _isEditing = true;
                _errorMessage = '현재 국가어항 목록에서 해제된 목적지입니다. 출조 지역을 다시 선택하세요.';
              });
              return;
            }
            _calculate();
          },
          onSaveAsNew: () => setState(() {
            _activeId = null;
            _isEditing = true;
            _errorMessage = null;
          }),
          onDelete: () async {
            await ref
                .read(activityForecastControllerProvider.notifier)
                .remove(result.id);
            if (mounted) Navigator.pop(context);
          },
        ),
        const SizedBox(height: AppSpacing.x2),
      ],
    );
  }

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 10)),
    );
    if (date == null || !mounted) return;
    final time = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _ActivityTimeWheelPicker(
        initialTime: TimeOfDay.fromDateTime(_startsAt),
      ),
    );
    if (time == null) return;
    setState(() {
      _startsAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _selectFishingDestination() async {
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });
    try {
      final catalog = ref.read(fishingDestinationCatalogProvider);
      final catalogs = await Future.wait([
        catalog.load(),
        catalog.loadOfficialIndexStations(_options.variant),
      ]);
      final destinations = FishingDestinationCatalog.merge(
        officialFishingPorts: catalogs[0],
        officialIndexStations: catalogs[1],
      );
      if (!mounted) return;
      if (destinations.isEmpty) {
        throw const FormatException('선택 가능한 출조 지역을 불러오지 못했습니다.');
      }
      final selected = await showModalBottomSheet<ActivityDestination>(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.82,
          child: _DestinationPicker(
            title: '출조 지역 선택',
            destinations: destinations,
            onUseCustomLocation: _createCustomFishingDestination,
          ),
        ),
      );
      if (selected == null || !mounted) return;
      setState(() {
        _selectedDestination = selected;
        _options = ActivityOptions(
          variant: _options.variant,
          intensity: selected.name,
          secondary: selected.supportedOptions.contains(_options.secondary)
              ? _options.secondary
              : '',
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is FormatException
            ? error.message
            : '출조 지역 목록을 가져오지 못했습니다.';
      });
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  Future<void> _selectMountainDestination() async {
    final query = await _askMountainQuery();
    if (query == null || !mounted) return;
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });
    try {
      final mountains = await ref
          .read(mountainDestinationDataSourceProvider)
          .search(query);
      if (!mounted) return;
      if (mountains.isEmpty) {
        throw const FormatException('검색된 산이 없습니다. 산 이름을 확인하세요.');
      }
      final selected = await showModalBottomSheet<MountainSearchResult>(
        context: context,
        useRootNavigator: true,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (_) => FractionallySizedBox(
          heightFactor: 0.82,
          child: _MountainPicker(mountains: mountains),
        ),
      );
      if (selected == null || !mounted) return;
      final geocoded = await locationFromAddress(
        '${selected.name} ${selected.address}',
      ).timeout(const Duration(seconds: 8));
      final coordinates = geocoded.firstOrNull;
      if (coordinates == null) {
        throw const FormatException('선택한 산의 위치를 확인하지 못했습니다.');
      }
      final location = SavedLocation(
        name: selected.name,
        lat: coordinates.latitude,
        lon: coordinates.longitude,
      );
      if (!await _isKoreanLocation(location)) {
        throw const FormatException('선택한 산의 대한민국 좌표를 확인하지 못했습니다.');
      }
      if (!mounted) return;
      setState(() {
        _selectedDestination = ActivityDestination(
          id: 'mountain:${selected.id}',
          name: selected.name,
          areaName: [
            selected.address,
            if (selected.heightMeters != null) '${selected.heightMeters}m',
          ].join(' · '),
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          source: '산림청 산 정보 조회_GW · 기기 위치 변환',
          kind: ActivityDestinationKind.mountain,
        );
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is FormatException
            ? error.message
            : '산 정보를 가져오지 못했습니다. 잠시 후 다시 시도하세요.';
      });
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  Future<ActivityDestination> _createCustomFishingDestination(
    String rawQuery,
  ) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      throw const FormatException('지역명 또는 주소를 입력하세요.');
    }
    final geocoded = await locationFromAddress(
      '$query, 대한민국',
    ).timeout(const Duration(seconds: 8));
    for (final coordinates in geocoded) {
      final location = SavedLocation(
        name: query,
        lat: coordinates.latitude,
        lon: coordinates.longitude,
      );
      final places = await placemarkFromCoordinates(
        location.lat,
        location.lon,
      ).timeout(const Duration(seconds: 5));
      final placemark = places.firstOrNull;
      if (placemark?.isoCountryCode?.toUpperCase() != 'KR') continue;

      final catalog = ref.read(fishingDestinationCatalogProvider);
      final nearbyReferences = FishingDestinationCatalog.merge(
        officialFishingPorts: await catalog.load(),
        officialIndexStations: await catalog.loadOfficialIndexStations(
          _options.variant,
        ),
      );
      final nearestDistanceKm = nearbyReferences
          .map(
            (destination) => _distanceKm(
              coordinates.latitude,
              coordinates.longitude,
              destination.latitude,
              destination.longitude,
            ),
          )
          .reduce(math.min);
      if (nearestDistanceKm > _maximumCustomFishingDistanceKm) continue;

      final administrativeArea = [
        placemark!.administrativeArea,
        placemark.locality,
        placemark.subLocality,
      ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' ');
      return ActivityDestination(
        id: 'custom:${coordinates.latitude.toStringAsFixed(5)},${coordinates.longitude.toStringAsFixed(5)}',
        name: query,
        areaName: administrativeArea.isEmpty
            ? '사용자 지정 연안 위치 · 공식 지수 미지원'
            : '$administrativeArea · 공식 지수 미지원',
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        source: '사용자 지정 위치 · 기기 위치 변환',
      );
    }
    throw const FormatException(
      '대한민국 연안 위치를 확인하지 못했습니다. 가까운 항구나 해안 지역을 입력하세요.',
    );
  }

  Future<String?> _askMountainQuery() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('산 검색'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(hintText: '예: 지리산'),
                onSubmitted: (value) {
                  if (value.trim().length >= 2) {
                    Navigator.pop(dialogContext, value.trim());
                  }
                },
              ),
              const SizedBox(height: AppSpacing.x2),
              Wrap(
                spacing: AppSpacing.x1,
                runSpacing: AppSpacing.x1,
                children: const ['지리산', '설악산', '북한산', '한라산']
                    .map(
                      (mountain) => ActionChip(
                        label: Text(mountain),
                        onPressed: () => Navigator.pop(dialogContext, mountain),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().length >= 2) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: const Text('검색'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _calculate() async {
    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      _validateInputBeforeFetch();
      final location = _selectedLocation;
      final destination = _selectedDestination;
      final ({double lat, double lon}) coordinates;
      final String locationName;
      final String destinationId;
      final String destinationSource;
      if (destination != null) {
        coordinates = (lat: destination.latitude, lon: destination.longitude);
        locationName = destination.name;
        destinationId = destination.id;
        destinationSource = destination.source;
      } else if (location == null) {
        final verifiedLocation = await ref.read(
          verifiedKoreanLocationProvider.future,
        );
        if (verifiedLocation == null) {
          throw const FormatException('대한민국 현재 위치를 다시 확인할 수 없습니다.');
        }
        coordinates = (
          lat: verifiedLocation.latitude,
          lon: verifiedLocation.longitude,
        );
        locationName = verifiedLocation.locationName;
        destinationId = '';
        destinationSource = '';
      } else {
        if (!await _isKoreanLocation(location)) {
          throw const FormatException('대한민국 내 즐겨찾기 장소만 선택할 수 있습니다.');
        }
        coordinates = (lat: location.lat, lon: location.lon);
        locationName = location.name;
        destinationId = '';
        destinationSource = '';
      }

      final evidenceCache = ref.read(activityEvidenceCacheProvider);
      final weather = await evidenceCache.getWeather(
        latitude: coordinates.lat,
        longitude: coordinates.lon,
        loader: () async {
          final repository = await ref.read(weatherRepositoryProvider.future);
          final weatherResult = await repository.getCurrentWeather(
            lat: coordinates.lat,
            lon: coordinates.lon,
          );
          if (weatherResult.error != null || weatherResult.data == null) {
            throw weatherResult.error ??
                StateError('weather response is empty');
          }
          return weatherResult.data!;
        },
      );

      final request = ActivityJudgmentRequest(
        activityType: widget.type,
        locationName: locationName,
        latitude: coordinates.lat,
        longitude: coordinates.lon,
        startsAt: _startsAt,
        durationMinutes: _durationMinutes,
        options: _options,
        destinationId: destinationId,
        destinationSource: destinationSource,
        destinationAreaName: destination?.areaName ?? '',
        destinationKind: destination?.kind,
      );
      final judgmentMode = ref
          .read(activityJudgmentCalculatorProvider)
          .judgmentModeFor(request: request, weather: weather);
      final hasForecastEvidence = judgmentMode != ActivityJudgmentMode.pending;
      final seaFishingEvidence =
          hasForecastEvidence &&
              widget.type == ActivityType.seaFishing &&
              destination!.supportsOfficialFishingIndex
          ? await evidenceCache.getSeaFishingEvidence(
              requestedAt: _startsAt,
              requestedUntil: request.evidenceEndsAt,
              fishingType: _options.variant,
              placeName: destination.name,
              targetFish: _options.secondary,
              loader: () => ref
                  .read(seaFishingDataSourceProvider)
                  .fetch(
                    requestedAt: _startsAt,
                    requestedUntil: request.evidenceEndsAt,
                    fishingType: _options.variant,
                    placeName: destination.name,
                    targetFish: _options.secondary,
                  ),
            )
          : null;
      final midSeaForecastEvidence =
          hasForecastEvidence &&
              widget.type == ActivityType.seaFishing &&
              seaFishingEvidence == null
          ? await _loadMidSeaForecastEvidence(
              evidenceCache: evidenceCache,
              coordinates: coordinates,
              requestedUntil: request.evidenceEndsAt,
            )
          : null;
      final forestFireEvidence =
          hasForecastEvidence && widget.type == ActivityType.hiking
          ? await evidenceCache.getForestFireEvidence(
              requestedAt: _startsAt,
              regionKey:
                  ForestFireDataSource.provinceCodeFor(destination!.areaName) ??
                  'national',
              loader: () => ref
                  .read(forestFireDataSourceProvider)
                  .fetch(
                    requestedAt: _startsAt,
                    destinationAreaName: destination.areaName,
                  ),
            )
          : null;
      final weatherWarningEvidence =
          judgmentMode == ActivityJudgmentMode.detailed &&
              widget.type == ActivityType.seaFishing &&
              !_startsBeyondWarningWindow(_startsAt)
          ? await evidenceCache.getWeatherWarningEvidence(
              loader: () => ref.read(weatherWarningDataSourceProvider).fetch(),
            )
          : null;
      final result = await ref
          .read(activityForecastControllerProvider.notifier)
          .calculateAndSave(
            request: request,
            weather: weather,
            seaFishingEvidence: seaFishingEvidence,
            midSeaForecastEvidence: midSeaForecastEvidence,
            forestFireEvidence: forestFireEvidence,
            weatherWarningEvidence: weatherWarningEvidence,
            existingId: _activeId,
          );
      if (!mounted) return;
      setState(() {
        _result = result;
        _activeId = result.id;
        _isEditing = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error is FormatException
            ? error.message
            : '판단 자료를 가져오지 못했습니다. 잠시 후 다시 시도하세요.';
      });
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  bool _startsBeyondWarningWindow(DateTime startsAt) {
    return startsAt.isAfter(DateTime.now().add(const Duration(hours: 6)));
  }

  Future<MidSeaForecastEvidence?> _loadMidSeaForecastEvidence({
    required ActivityEvidenceCache evidenceCache,
    required ({double lat, double lon}) coordinates,
    required DateTime requestedUntil,
  }) async {
    final region = MidSeaForecastDataSource.regionFor(
      latitude: coordinates.lat,
      longitude: coordinates.lon,
    );
    if (region == null) return null;
    return evidenceCache.getMidSeaForecastEvidence(
      requestedAt: _startsAt,
      seaRegionId: region.id,
      loader: () => ref
          .read(midSeaForecastDataSourceProvider)
          .fetch(
            requestedAt: _startsAt,
            requestedUntil: requestedUntil,
            latitude: coordinates.lat,
            longitude: coordinates.lon,
          ),
    );
  }

  void _validateInputBeforeFetch() {
    if (_startsAt.isBefore(
      DateTime.now().subtract(const Duration(minutes: 5)),
    )) {
      throw const FormatException('이미 지난 시간은 판단할 수 없습니다.');
    }
    if (widget.type == ActivityType.seaFishing &&
        _selectedDestination == null) {
      throw const FormatException('출조 지역을 선택하세요.');
    }
    if (widget.type == ActivityType.hiking && _selectedDestination == null) {
      throw const FormatException('산행할 산을 선택하세요.');
    }
  }

  Future<bool> _isKoreanLocation(SavedLocation location) async {
    try {
      final places = await placemarkFromCoordinates(
        location.lat,
        location.lon,
      ).timeout(const Duration(seconds: 5));
      return places.firstOrNull?.isoCountryCode?.toUpperCase() == 'KR';
    } catch (_) {
      return false;
    }
  }

  double _distanceKm(
    double latitudeA,
    double longitudeA,
    double latitudeB,
    double longitudeB,
  ) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = (latitudeB - latitudeA) * math.pi / 180;
    final longitudeDelta = (longitudeB - longitudeA) * math.pi / 180;
    final startLatitude = latitudeA * math.pi / 180;
    final endLatitude = latitudeB * math.pi / 180;
    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(startLatitude) *
            math.cos(endLatitude) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);
    return earthRadiusKm *
        2 *
        math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));
  }
}

class _ActivityTimeWheelPicker extends StatefulWidget {
  const _ActivityTimeWheelPicker({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_ActivityTimeWheelPicker> createState() =>
      _ActivityTimeWheelPickerState();
}

class _ActivityTimeWheelPickerState extends State<_ActivityTimeWheelPicker> {
  late DateTime _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = DateTime(
      2000,
      1,
      1,
      widget.initialTime.hour,
      widget.initialTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  '시간 선택',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '취소',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(
                    context,
                  ).pop(TimeOfDay.fromDateTime(_selectedTime)),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.x1),
            CupertinoTheme(
              data: const CupertinoThemeData(
                brightness: Brightness.dark,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              child: SizedBox(
                height: 220,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: _selectedTime,
                  onDateTimeChanged: (value) => _selectedTime = value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationField extends StatelessWidget {
  const _DestinationField({
    required this.type,
    required this.destination,
    required this.onTap,
  });

  final ActivityType type;
  final ActivityDestination? destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isFishing = type == ActivityType.seaFishing;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(isFishing ? '출조 지역' : '산행 지역'),
      subtitle: Text(
        destination == null
            ? (isFishing ? '출조 지역을 선택하거나 직접 검색하세요' : '산 이름을 검색해 선택하세요')
            : [
                destination!.name,
                if (isFishing) _destinationSupportLabel(destination!),
                destination!.areaName,
              ].where((value) => value.isNotEmpty).join('\n'),
      ),
      onTap: onTap,
    );
  }
}

class _DestinationPicker extends StatefulWidget {
  const _DestinationPicker({
    required this.title,
    required this.destinations,
    this.onUseCustomLocation,
  });

  final String title;
  final List<ActivityDestination> destinations;
  final Future<ActivityDestination> Function(String query)? onUseCustomLocation;

  @override
  State<_DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<_DestinationPicker> {
  String _query = '';
  bool _isResolvingCustomLocation = false;
  String? _customLocationError;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _query.trim().toLowerCase();
    final filtered = normalizedQuery.isEmpty
        ? widget.destinations
        : widget.destinations
              .where(
                (item) =>
                    item.name.toLowerCase().contains(normalizedQuery) ||
                    item.areaName.toLowerCase().contains(normalizedQuery) ||
                    item.supportedOptions.any(
                      (value) => value.toLowerCase().contains(normalizedQuery),
                    ),
              )
              .toList();
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.x2),
          TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: '지점 또는 어종 검색'),
            onChanged: (value) => setState(() => _query = value),
          ),
          if (widget.onUseCustomLocation != null && _query.trim().isNotEmpty)
            TextButton(
              onPressed: _isResolvingCustomLocation ? null : _useCustomLocation,
              child: Text(
                _isResolvingCustomLocation
                    ? '위치 확인 중'
                    : '“${_query.trim()}” 위치 직접 사용',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (_customLocationError != null)
            Text(
              _customLocationError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: AppSpacing.x1),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('검색 결과가 없습니다.'))
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final destination = filtered[index];
                      return ListTile(
                        title: Text(destination.name),
                        subtitle: Text(
                          [
                            _destinationSupportLabel(destination),
                            if (destination.areaName.isNotEmpty)
                              destination.areaName,
                            if (destination.supportedOptions.isNotEmpty)
                              destination.supportedOptions.join(', '),
                          ].join('\n'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.pop(context, destination),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _useCustomLocation() async {
    final resolver = widget.onUseCustomLocation;
    if (resolver == null) return;
    setState(() {
      _isResolvingCustomLocation = true;
      _customLocationError = null;
    });
    try {
      final destination = await resolver(_query);
      if (mounted) Navigator.pop(context, destination);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _customLocationError = error is FormatException
            ? error.message
            : '입력한 위치를 확인하지 못했습니다.';
      });
    } finally {
      if (mounted) setState(() => _isResolvingCustomLocation = false);
    }
  }
}

String _destinationSupportLabel(ActivityDestination destination) {
  return switch (destination.kind) {
    ActivityDestinationKind.officialIndexStation => '공식 바다낚시지수 지원',
    ActivityDestinationKind.officialFishingPort => '공식 어항 대표좌표 · 지수 미지원',
    ActivityDestinationKind.customLocation => '사용자 지정 · 지수 미지원',
    ActivityDestinationKind.mountain => '',
  };
}

class _MountainPicker extends StatelessWidget {
  const _MountainPicker({required this.mountains});

  final List<MountainSearchResult> mountains;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '산 선택',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.x1),
          const Text('산림청 산 정보 검색 결과'),
          const SizedBox(height: AppSpacing.x2),
          Expanded(
            child: ListView.separated(
              itemCount: mountains.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final mountain = mountains[index];
                final height = mountain.heightMeters == null
                    ? ''
                    : ' · ${mountain.heightMeters}m';
                return ListTile(
                  title: Text('${mountain.name}$height'),
                  subtitle: Text(
                    mountain.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => Navigator.pop(context, mountain),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityOptionsEditor extends StatelessWidget {
  const _ActivityOptionsEditor({
    required this.type,
    required this.value,
    required this.supportedSecondaryOptions,
    required this.onChanged,
  });

  final ActivityType type;
  final ActivityOptions value;
  final List<String> supportedSecondaryOptions;
  final ValueChanged<ActivityOptions> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = _optionsFor(type);
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: options.contains(value.variant)
              ? value.variant
              : options.first,
          decoration: const InputDecoration(labelText: '활동 조건'),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (variant) {
            if (variant != null) {
              onChanged(
                ActivityOptions(
                  variant: variant,
                  intensity: value.intensity,
                  secondary: value.secondary,
                ),
              );
            }
          },
        ),
        if (type == ActivityType.seaFishing) ...[
          const SizedBox(height: AppSpacing.x2),
          DropdownButtonFormField<String>(
            initialValue: supportedSecondaryOptions.contains(value.secondary)
                ? value.secondary
                : '',
            decoration: const InputDecoration(labelText: '대상 어종 (선택)'),
            items: [
              const DropdownMenuItem(value: '', child: Text('전체 어종')),
              ...supportedSecondaryOptions.map(
                (fish) => DropdownMenuItem(value: fish, child: Text(fish)),
              ),
            ],
            onChanged: supportedSecondaryOptions.isEmpty
                ? null
                : (targetFish) => onChanged(
                    ActivityOptions(
                      variant: value.variant,
                      intensity: value.intensity,
                      secondary: targetFish ?? '',
                    ),
                  ),
          ),
        ],
      ],
    );
  }
}

List<String> _optionsFor(ActivityType type) => switch (type) {
  ActivityType.seaFishing => const ['갯바위', '선상'],
  ActivityType.walkingRunning => const ['걷기 · 보통', '달리기 · 보통', '달리기 · 강하게'],
  ActivityType.hiking => const ['초보', '보통', '숙련'],
  ActivityType.laundry => const ['실외 · 일반', '실외 · 두꺼운 빨래', '베란다'],
  ActivityType.carWash => const ['일반 · 24시간', '정밀 · 48시간'],
};

String _labelFor(ActivityType type) => switch (type) {
  ActivityType.seaFishing => '바다낚시',
  ActivityType.walkingRunning => '걷기/달리기',
  ActivityType.hiking => '등산',
  ActivityType.laundry => '빨래',
  ActivityType.carWash => '세차',
};

String _activityImageAsset(ActivityType type) => switch (type) {
  ActivityType.seaFishing => 'assets/icons/activity/sea_fishing.png',
  ActivityType.walkingRunning => 'assets/icons/activity/walking_running.png',
  ActivityType.hiking => 'assets/icons/activity/hiking.png',
  ActivityType.laundry => 'assets/icons/activity/laundry.png',
  ActivityType.carWash => 'assets/icons/activity/car_wash.png',
};

class _ActivityImage extends StatelessWidget {
  const _ActivityImage({required this.type, required this.size});

  final ActivityType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        _activityImageAsset(type),
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ActivityFactorSection extends StatelessWidget {
  const _ActivityFactorSection({required this.title, required this.factors});

  final String title;
  final List<JudgmentFactor> factors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final factor in factors)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      factor.label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    factor.contribution >= 0
                        ? '+${factor.contribution}'
                        : '${factor.contribution}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivityDetailSection extends StatelessWidget {
  const _ActivityDetailSection({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(line, style: Theme.of(context).textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

String _judgmentScoreLabel(ActivityJudgment judgment) {
  if (judgment.judgmentMode == ActivityJudgmentMode.pending) {
    return '예보 대기';
  }
  if (judgment.judgmentMode == ActivityJudgmentMode.planning &&
      judgment.scoreRangeMin != null &&
      judgment.scoreRangeMax != null) {
    return '${judgment.scoreRangeMin}~${judgment.scoreRangeMax}';
  }
  return judgment.score?.toString() ?? '판단 제한';
}

String _historyScoreLabel(ActivityJudgment judgment) {
  final scoreLabel = _judgmentScoreLabel(judgment);
  final hasNumericScore = judgment.score != null;
  final hasScoreRange =
      judgment.scoreRangeMin != null && judgment.scoreRangeMax != null;
  return hasNumericScore || hasScoreRange ? '$scoreLabel점' : scoreLabel;
}

String _judgmentModeLabel(ActivityJudgmentMode mode) => switch (mode) {
  ActivityJudgmentMode.detailed => '상세 판단',
  ActivityJudgmentMode.planning => '계획 판단',
  ActivityJudgmentMode.pending => '예보 대기',
};

String _confidenceLabel(ActivityConfidence confidence) => switch (confidence) {
  ActivityConfidence.high => '높음',
  ActivityConfidence.medium => '보통',
  ActivityConfidence.low => '낮음',
  ActivityConfidence.unavailable => '산정 전',
};

String _safetyLabel(ActivitySafetyLevel level) => switch (level) {
  ActivitySafetyLevel.allowed => '가능',
  ActivitySafetyLevel.caution => '주의',
  ActivitySafetyLevel.stop => '중단 권고',
  ActivitySafetyLevel.limited => '판단 제한',
};

String _judgmentStatusLabel(ActivityJudgment judgment) {
  if (judgment.judgmentMode == ActivityJudgmentMode.pending) {
    return '예보 대기';
  }
  final score = judgment.score;
  if (judgment.request.activityType == ActivityType.laundry && score != null) {
    return score >= 65
        ? '건조 좋음'
        : score >= 45
        ? '건조 보통'
        : '건조 비추천';
  }
  if (judgment.request.activityType == ActivityType.carWash && score != null) {
    return score >= 65
        ? '유지 좋음'
        : score >= 45
        ? '유지 보통'
        : '세차 비추천';
  }
  if (judgment.request.activityType == ActivityType.walkingRunning &&
      judgment.judgmentMode == ActivityJudgmentMode.planning &&
      score != null) {
    return score >= 65
        ? '계획 좋음'
        : score >= 45
        ? '계획 보통'
        : '계획 비추천';
  }
  if (judgment.judgmentMode == ActivityJudgmentMode.planning &&
      (judgment.request.activityType == ActivityType.seaFishing ||
          judgment.request.activityType == ActivityType.hiking) &&
      judgment.safetyLevel != ActivitySafetyLevel.stop) {
    return '안전 미확정';
  }
  return _safetyLabel(judgment.safetyLevel);
}

String _coverageLabel(ActivityCoverageLevel level) => switch (level) {
  ActivityCoverageLevel.full => '전체 자료',
  ActivityCoverageLevel.partial => '일부 자료',
  ActivityCoverageLevel.weatherOnly => '날씨 자료만 반영',
  ActivityCoverageLevel.unavailable => '필수 자료 부족',
};

Color _safetyColor(ActivitySafetyLevel level) => switch (level) {
  ActivitySafetyLevel.allowed => AppColors.scoreExcellent,
  ActivitySafetyLevel.caution => AppColors.scoreFair,
  ActivitySafetyLevel.stop => AppColors.scorePoor,
  ActivitySafetyLevel.limited => AppColors.textMutedDark,
};

String _formatDateTime(DateTime value) {
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.month}/${value.day} ${value.hour}:$minute';
}

String _formatTime(DateTime value) {
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.hour}:$minute';
}
