import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../weather/domain/entities/weather_entity.dart';
import '../data/activity_evidence_cache.dart';
import '../data/fishing_destination_catalog.dart';
import '../data/activity_history_repository.dart';
import '../data/sea_fishing_data_source.dart';
import '../data/forest_fire_data_source.dart';
import '../data/mountain_destination_data_source.dart';
import '../data/mid_sea_forecast_data_source.dart';
import '../data/weather_warning_data_source.dart';
import '../data/tide_data_source.dart';
import '../data/current_data_source.dart';
import '../domain/activity_judgment_calculator.dart';
import '../domain/activity_models.dart';

final activityHistoryRepositoryProvider = Provider<ActivityHistoryRepository>(
  (_) => ActivityHistoryRepository(),
);

final activityEvidenceCacheProvider = Provider<ActivityEvidenceCache>(
  (_) => ActivityEvidenceCache(),
);

final activityJudgmentCalculatorProvider = Provider<ActivityJudgmentCalculator>(
  (_) => ActivityJudgmentCalculator(),
);

final seaFishingDataSourceProvider = Provider<SeaFishingDataSource>(
  (_) => SeaFishingDataSource(),
);

final midSeaForecastDataSourceProvider = Provider<MidSeaForecastDataSource>(
  (_) => MidSeaForecastDataSource(),
);

final tideDataSourceProvider = Provider<TideDataSource>(
  (_) => TideDataSource(),
);

final currentDataSourceProvider = Provider<CurrentDataSource>(
  (_) => CurrentDataSource(),
);

final fishingDestinationCatalogProvider = Provider<FishingDestinationCatalog>(
  (_) => FishingDestinationCatalog(),
);

final forestFireDataSourceProvider = Provider<ForestFireDataSource>(
  (_) => ForestFireDataSource(),
);

final weatherWarningDataSourceProvider = Provider<WeatherWarningDataSource>(
  (_) => WeatherWarningDataSource(),
);

final mountainDestinationDataSourceProvider =
    Provider<MountainDestinationDataSource>(
      (_) => MountainDestinationDataSource(),
    );

final activityForecastControllerProvider =
    StateNotifierProvider<
      ActivityForecastController,
      AsyncValue<List<ActivityJudgment>>
    >((ref) {
      return ActivityForecastController(
        repository: ref.watch(activityHistoryRepositoryProvider),
        calculator: ref.watch(activityJudgmentCalculatorProvider),
      )..load();
    });

class ActivityForecastController
    extends StateNotifier<AsyncValue<List<ActivityJudgment>>> {
  ActivityForecastController({
    required ActivityHistoryRepository repository,
    required ActivityJudgmentCalculator calculator,
  }) : _repository = repository,
       _calculator = calculator,
       super(const AsyncValue.loading());

  final ActivityHistoryRepository _repository;
  final ActivityJudgmentCalculator _calculator;

  Future<void> load() async {
    state = await AsyncValue.guard(_repository.load);
  }

  Future<ActivityJudgment> calculateAndSave({
    required ActivityJudgmentRequest request,
    required WeatherEntity weather,
    SeaFishingEvidence? seaFishingEvidence,
    MidSeaForecastEvidence? midSeaForecastEvidence,
    ForestFireEvidence? forestFireEvidence,
    WeatherWarningEvidence? weatherWarningEvidence,
    TideEvidence? tideEvidence,
    CurrentEvidence? currentEvidence,
    String? existingId,
  }) async {
    final judgment = _calculator.calculate(
      request: request,
      weather: weather,
      existingId: existingId,
      seaFishingEvidence: seaFishingEvidence,
      midSeaForecastEvidence: midSeaForecastEvidence,
      forestFireEvidence: forestFireEvidence,
      weatherWarningEvidence: weatherWarningEvidence,
      tideEvidence: tideEvidence,
      currentEvidence: currentEvidence,
    );
    final history = await _repository.upsert(judgment);
    state = AsyncValue.data(history);
    return judgment;
  }

  Future<void> remove(String id) async {
    state = AsyncValue.data(await _repository.remove(id));
  }

  Future<void> setPinned(String id, bool isPinned) async {
    state = AsyncValue.data(await _repository.setPinned(id, isPinned));
  }

  Future<void> clear() async {
    await _repository.clear();
    state = const AsyncValue.data([]);
  }
}
