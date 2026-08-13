import 'package:flutter_test/flutter_test.dart';
import 'package:yegamssi/core/background/background_refresh_scheduler.dart';
import 'package:yegamssi/core/error/failure.dart';

void main() {
  group('runBackgroundRefreshTask', () {
    test('completes without retry when refresh succeeds', () async {
      final shouldComplete = await runBackgroundRefreshTask(() async {});

      expect(shouldComplete, isTrue);
    });

    test('defers domain failures until the next regular interval', () async {
      final shouldComplete = await runBackgroundRefreshTask(() async {
        throw const NetworkFailure('background network blocked');
      });

      expect(shouldComplete, isTrue);
    });

    test('retries unexpected implementation failures', () async {
      final shouldComplete = await runBackgroundRefreshTask(() async {
        throw StateError('unexpected');
      });

      expect(shouldComplete, isFalse);
    });
  });
}
