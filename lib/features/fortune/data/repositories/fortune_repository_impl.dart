import '../../../../core/error/app_exception.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/fortune_result.dart';
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
    required Oheng? weatherOheng,
    required String lang,
    required FortuneTone tone,
  }) async {
    try {
      final selectedTableName = tone.tableNameForLang(lang);
      final baseTableName = FortuneTone.base.tableNameForLang(lang);
      final (:slot, :date) = TimeSlot.forNow();
      final now = DateTime.now();
      final messages = <FortuneCategory, String>{};

      for (final cat in FortuneCategory.values) {
        final score = scores[cat] ?? 50;
        final code = FortuneCodeBuilder.build(
          category: cat,
          score: score,
          dominantOheng: saju.dominant,
          strength: saju.dominantStrength,
          weatherOheng: weatherOheng,
        );

        final fragments = await _source.fetchWithFallback(
          category: cat,
          baseCode: code,
          selectedTableName: selectedTableName,
          baseTableName: baseTableName,
        );

        // score를 시드에 포함 → 같은 티어 내에서도 점수별 다른 조각 선택
        final seed =
            saju.dayStem.index * 997 ^
            (now.year * 10000 + now.month * 100 + now.day) ^
            (slot.index * 997) ^
            (cat.index * 31) ^
            (score * 17);

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

      return (
        data: FortuneResult(
          scores: scores,
          messages: messages,
          ohengRatio: ohengRatio,
          date: now,
          slot: slot,
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
