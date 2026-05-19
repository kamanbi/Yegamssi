import '../../../../core/error/failure.dart';
import '../entities/fortune_result.dart';
import '../entities/fortune_tone.dart';
import '../entities/oheng.dart';
import '../entities/saju.dart';

typedef FortuneQueryResult = ({FortuneResult? data, Failure? error});

abstract interface class FortuneRepository {
  Future<FortuneQueryResult> getDailyFortune({
    required Saju saju,
    required Map<FortuneCategory, int> scores,
    required Oheng? weatherOheng,
    required String lang,
    required FortuneTone tone,
  });
}
