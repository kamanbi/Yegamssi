import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/fortune_result.dart';
import '../../domain/calculators/lucky_color_calculator.dart';
import '../../domain/entities/fortune_evaluation_context.dart';
import '../../domain/entities/fortune_tone.dart';
import '../../domain/entities/oheng.dart';
import '../../domain/entities/saju.dart';
import '../../domain/repositories/fortune_repository.dart';
import '../../domain/services/fragment_composer.dart';
import '../sources/fortune_data_source.dart';
import '../sources/mingri_data_source.dart';

class FortuneRepositoryImpl implements FortuneRepository {
  const FortuneRepositoryImpl(this._source);

  final MingriDataSource _source;

  @override
  Future<FortuneQueryResult> getDailyFortune({
    required Saju saju,
    required Map<FortuneCategory, int> scores,
    required FortuneEvaluationContext context,
  }) async {
    try {
      final selectedTableName = context.tone.tableNameForLang(context.language);
      final baseTableName = FortuneTone.base.tableNameForLang(context.language);
      final messages = <FortuneCategory, String>{};

      for (final cat in FortuneCategory.values) {
        final score = scores[cat] ?? 50;
        final code = FortuneCodeBuilder.build(
          category: cat,
          score: score,
          dominantOheng: saju.dominant,
          strength: saju.dominantStrength,
          weatherOheng: context.weatherOheng,
        );

        var fragments = await _source.fetchWithFallback(
          category: cat,
          baseCode: code,
          selectedTableName: selectedTableName,
          baseTableName: baseTableName,
        );
        if (fragments.isEmpty && selectedTableName != baseTableName) {
          fragments = await _source.fetchWithFallback(
            category: cat,
            baseCode: code,
            selectedTableName: baseTableName,
            baseTableName: baseTableName,
          );
        }

        // score를 시드에 포함 → 같은 티어 내에서도 점수별 다른 조각 선택
        final seed = context.messageSeed(
          categoryIndex: cat.index,
          score: score,
        );

        messages[cat] = FragmentComposer.compose(
          fragments,
          seed,
          isOverall: cat == FortuneCategory.overall,
        );
      }

      // 오행 비율
      final total = saju.ohengCount.values.fold(0, (a, b) => a + b);
      final ohengRatio = <Oheng, double>{
        for (final o in Oheng.values)
          o: total > 0 ? (saju.ohengCount[o] ?? 0) / total : 0.2,
      };
      final luckyColor = LuckyColorCalculator.calculate(
        LuckyColorInput(
          saju: saju,
          basisDate: context.basisDate,
          slot: context.slot,
          scores: scores,
          weatherOheng: context.weatherOheng,
        ),
      );

      return (
        data: FortuneResult(
          scores: scores,
          messages: messages,
          ohengRatio: ohengRatio,
          luckyColor: luckyColor,
          date: context.basisDate,
          slot: context.slot,
        ),
        error: null,
      );
    } on NetworkException catch (e) {
      return (data: null, error: NetworkFailure(e.message));
    } catch (e) {
      return (data: null, error: UnknownFailure(e.toString()));
    }
  }
}
