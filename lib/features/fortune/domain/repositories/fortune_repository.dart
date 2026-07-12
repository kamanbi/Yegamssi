import '../../../../core/error/failure.dart';
import '../entities/fortune_result.dart';
import '../entities/fortune_evaluation_context.dart';
import '../entities/oheng.dart';
import '../entities/saju.dart';

typedef FortuneQueryResult = ({FortuneResult? data, Failure? error});

abstract interface class FortuneRepository {
  Future<FortuneQueryResult> getDailyFortune({
    required Saju saju,
    required Map<FortuneCategory, int> scores,
    required FortuneEvaluationContext context,
  });
}
