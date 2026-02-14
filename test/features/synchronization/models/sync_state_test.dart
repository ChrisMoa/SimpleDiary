import 'package:day_tracker/features/synchronization/domain/providers/supabase_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncStatus', () {
    test('has all expected values', () {
      expect(SyncStatus.values, containsAll([
        SyncStatus.idle,
        SyncStatus.syncing,
        SyncStatus.success,
        SyncStatus.error,
      ]));
      expect(SyncStatus.values.length, 4);
    });
  });

  group('SyncState', () {
    test('construction with required fields', () {
      final state = SyncState(
        status: SyncStatus.idle,
        message: 'Ready to sync',
      );

      expect(state.status, SyncStatus.idle);
      expect(state.message, 'Ready to sync');
      expect(state.progress, 0.0);
    });

    test('construction with all fields', () {
      final state = SyncState(
        status: SyncStatus.syncing,
        message: 'Uploading...',
        progress: 0.5,
      );

      expect(state.status, SyncStatus.syncing);
      expect(state.message, 'Uploading...');
      expect(state.progress, 0.5);
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = SyncState(
          status: SyncStatus.idle,
          message: 'Ready',
          progress: 0.0,
        );
        final copy = original.copyWith(message: 'Updated');

        expect(copy.status, SyncStatus.idle);
        expect(copy.message, 'Updated');
        expect(copy.progress, 0.0);
      });

      test('can update all fields', () {
        final original = SyncState(
          status: SyncStatus.idle,
          message: 'Ready',
          progress: 0.0,
        );
        final copy = original.copyWith(
          status: SyncStatus.success,
          message: 'Done',
          progress: 1.0,
        );

        expect(copy.status, SyncStatus.success);
        expect(copy.message, 'Done');
        expect(copy.progress, 1.0);
      });

      test('does not mutate original', () {
        final original = SyncState(
          status: SyncStatus.idle,
          message: 'Ready',
          progress: 0.0,
        );
        original.copyWith(
          status: SyncStatus.error,
          message: 'Failed',
          progress: 0.3,
        );

        expect(original.status, SyncStatus.idle);
        expect(original.message, 'Ready');
        expect(original.progress, 0.0);
      });
    });

    test('progress defaults to 0.0', () {
      final state = SyncState(
        status: SyncStatus.syncing,
        message: 'Starting...',
      );
      expect(state.progress, 0.0);
    });

    test('typical sync lifecycle states', () {
      // idle -> syncing -> success
      var state = SyncState(status: SyncStatus.idle, message: 'Ready');

      state = state.copyWith(
        status: SyncStatus.syncing,
        message: 'Initializing...',
        progress: 0.0,
      );
      expect(state.status, SyncStatus.syncing);

      state = state.copyWith(message: 'Authenticating...', progress: 0.1);
      expect(state.progress, 0.1);

      state = state.copyWith(message: 'Syncing diary days...', progress: 0.2);
      expect(state.progress, 0.2);

      state = state.copyWith(message: 'Syncing notes...', progress: 0.5);
      expect(state.progress, 0.5);

      state = state.copyWith(
        status: SyncStatus.success,
        message: 'Sync completed',
        progress: 1.0,
      );
      expect(state.status, SyncStatus.success);
      expect(state.progress, 1.0);
    });

    test('error state preserves progress', () {
      final state = SyncState(
        status: SyncStatus.syncing,
        message: 'Syncing...',
        progress: 0.5,
      );
      final errorState = state.copyWith(
        status: SyncStatus.error,
        message: 'Connection lost',
      );

      expect(errorState.status, SyncStatus.error);
      expect(errorState.message, 'Connection lost');
      expect(errorState.progress, 0.5);
    });
  });
}
