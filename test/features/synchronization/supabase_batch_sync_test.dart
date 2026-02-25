import 'package:day_tracker/features/synchronization/data/repositories/supabase_api.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('retryWithBackoff', () {
    late SupabaseApi api;

    setUp(() {
      api = SupabaseApi();
    });

    test('succeeds on first attempt', () async {
      var callCount = 0;
      final result = await api.retryWithBackoff(() async {
        callCount++;
        return 'success';
      });

      expect(result, 'success');
      expect(callCount, 1);
    });

    test('retries on failure and succeeds on second attempt', () async {
      var callCount = 0;
      final result = await api.retryWithBackoff(() async {
        callCount++;
        if (callCount < 2) throw Exception('temporary error');
        return 'success';
      });

      expect(result, 'success');
      expect(callCount, 2);
    });

    test('retries on failure and succeeds on third attempt', () async {
      var callCount = 0;
      final result = await api.retryWithBackoff(() async {
        callCount++;
        if (callCount < 3) throw Exception('temporary error');
        return 'success';
      });

      expect(result, 'success');
      expect(callCount, 3);
    });

    test('throws after max retries exceeded', () async {
      expect(
        () => api.retryWithBackoff(() async {
          throw Exception('persistent error');
        }),
        throwsA(isA<Exception>()),
      );
    });

    test('throws after custom max retries exceeded', () async {
      var callCount = 0;
      try {
        await api.retryWithBackoff(
          () async {
            callCount++;
            throw Exception('persistent error');
          },
          maxRetries: 2,
        );
      } catch (_) {}

      expect(callCount, 2);
    });

    test('returns correct type', () async {
      final intResult = await api.retryWithBackoff(() async => 42);
      expect(intResult, isA<int>());
      expect(intResult, 42);

      final listResult = await api.retryWithBackoff(() async => [1, 2, 3]);
      expect(listResult, isA<List<int>>());
      expect(listResult, [1, 2, 3]);
    });

    test('rethrows the original exception type', () async {
      expect(
        () => api.retryWithBackoff(() async {
          throw ArgumentError('bad argument');
        }, maxRetries: 1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('delay increases between retries', () async {
      final timestamps = <DateTime>[];
      var callCount = 0;

      try {
        await api.retryWithBackoff(() async {
          timestamps.add(DateTime.now());
          callCount++;
          if (callCount < 3) throw Exception('retry');
          return 'done';
        });
      } catch (_) {}

      expect(timestamps.length, 3);
      // Second delay should be longer than first
      final firstDelay = timestamps[1].difference(timestamps[0]);
      final secondDelay = timestamps[2].difference(timestamps[1]);
      expect(secondDelay.inMilliseconds, greaterThanOrEqualTo(firstDelay.inMilliseconds));
    });

    test('maxRetries of 1 means no retry', () async {
      var callCount = 0;
      try {
        await api.retryWithBackoff(
          () async {
            callCount++;
            throw Exception('fail');
          },
          maxRetries: 1,
        );
      } catch (_) {}

      expect(callCount, 1);
    });
  });

  group('SyncProgressCallback', () {
    test('callback type is defined', () {
      void callback(int completed, int total) {}
      // Verify the function matches the SyncProgressCallback typedef
      final SyncProgressCallback typed = callback;
      expect(typed, isNotNull);
    });
  });

  group('SupabaseApi constants', () {
    test('defaultBatchSize is 50', () {
      expect(SupabaseApi.defaultBatchSize, 50);
    });

    test('defaultDelayBetweenBatches is 100ms', () {
      expect(
        SupabaseApi.defaultDelayBetweenBatches,
        const Duration(milliseconds: 100),
      );
    });

    test('defaultMaxRetries is 3', () {
      expect(SupabaseApi.defaultMaxRetries, 3);
    });
  });
}
