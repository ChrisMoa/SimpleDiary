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

  group('SyncPhase', () {
    test('has all expected values', () {
      expect(SyncPhase.values, containsAll([
        SyncPhase.idle,
        SyncPhase.initializing,
        SyncPhase.authenticating,
        SyncPhase.syncDiaryDays,
        SyncPhase.syncNotes,
        SyncPhase.syncTemplates,
        SyncPhase.downloadDiaryDays,
        SyncPhase.downloadNotes,
        SyncPhase.downloadTemplates,
        SyncPhase.updatingLocalDatabase,
        SyncPhase.completed,
        SyncPhase.failed,
      ]));
      expect(SyncPhase.values.length, 12);
    });
  });

  group('SyncState', () {
    test('construction with required fields', () {
      final state = SyncState(
        status: SyncStatus.idle,
      );

      expect(state.status, SyncStatus.idle);
      expect(state.message, 'Ready to sync');
      expect(state.progress, 0.0);
      expect(state.phase, SyncPhase.idle);
      expect(state.completedItems, 0);
      expect(state.totalItems, 0);
      expect(state.errorMessage, isNull);
    });

    test('construction with all fields', () {
      final state = SyncState(
        status: SyncStatus.syncing,
        phase: SyncPhase.syncDiaryDays,
        progress: 0.5,
        completedItems: 25,
        totalItems: 50,
      );

      expect(state.status, SyncStatus.syncing);
      expect(state.phase, SyncPhase.syncDiaryDays);
      expect(state.message, 'Syncing diary days...');
      expect(state.progress, 0.5);
      expect(state.completedItems, 25);
      expect(state.totalItems, 50);
    });

    test('message getter returns phase-based messages', () {
      expect(
        SyncState(status: SyncStatus.idle, phase: SyncPhase.idle).message,
        'Ready to sync',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.initializing).message,
        'Initializing sync...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.authenticating).message,
        'Authenticating...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.syncDiaryDays).message,
        'Syncing diary days...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.syncNotes).message,
        'Syncing notes...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.syncTemplates).message,
        'Syncing templates...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.downloadDiaryDays).message,
        'Downloading diary days...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.downloadNotes).message,
        'Downloading notes...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.downloadTemplates).message,
        'Downloading templates...',
      );
      expect(
        SyncState(status: SyncStatus.syncing, phase: SyncPhase.updatingLocalDatabase).message,
        'Updating local database...',
      );
      expect(
        SyncState(status: SyncStatus.success, phase: SyncPhase.completed).message,
        'Sync completed successfully',
      );
    });

    test('message getter returns error message for failed phase', () {
      final state = SyncState(
        status: SyncStatus.error,
        phase: SyncPhase.failed,
        errorMessage: 'Connection lost',
      );
      expect(state.message, 'Connection lost');
    });

    test('message getter returns default for failed phase without error message', () {
      final state = SyncState(
        status: SyncStatus.error,
        phase: SyncPhase.failed,
      );
      expect(state.message, 'Sync failed');
    });

    group('copyWith', () {
      test('preserves unchanged fields', () {
        final original = SyncState(
          status: SyncStatus.idle,
          phase: SyncPhase.idle,
          progress: 0.0,
        );
        final copy = original.copyWith(phase: SyncPhase.initializing);

        expect(copy.status, SyncStatus.idle);
        expect(copy.phase, SyncPhase.initializing);
        expect(copy.progress, 0.0);
      });

      test('can update all fields', () {
        final original = SyncState(
          status: SyncStatus.idle,
        );
        final copy = original.copyWith(
          status: SyncStatus.success,
          phase: SyncPhase.completed,
          progress: 1.0,
          completedItems: 100,
          totalItems: 100,
        );

        expect(copy.status, SyncStatus.success);
        expect(copy.phase, SyncPhase.completed);
        expect(copy.progress, 1.0);
        expect(copy.completedItems, 100);
        expect(copy.totalItems, 100);
      });

      test('does not mutate original', () {
        final original = SyncState(
          status: SyncStatus.idle,
        );
        original.copyWith(
          status: SyncStatus.error,
          phase: SyncPhase.failed,
          progress: 0.3,
          errorMessage: 'Failed',
        );

        expect(original.status, SyncStatus.idle);
        expect(original.phase, SyncPhase.idle);
        expect(original.progress, 0.0);
      });
    });

    test('progress defaults to 0.0', () {
      final state = SyncState(
        status: SyncStatus.syncing,
        phase: SyncPhase.initializing,
      );
      expect(state.progress, 0.0);
    });

    test('typical sync lifecycle states', () {
      var state = SyncState(status: SyncStatus.idle);

      state = state.copyWith(
        status: SyncStatus.syncing,
        phase: SyncPhase.initializing,
        progress: 0.0,
      );
      expect(state.status, SyncStatus.syncing);

      state = state.copyWith(phase: SyncPhase.authenticating, progress: 0.1);
      expect(state.progress, 0.1);

      state = state.copyWith(phase: SyncPhase.syncDiaryDays, progress: 0.2);
      expect(state.progress, 0.2);
      expect(state.message, 'Syncing diary days...');

      state = state.copyWith(phase: SyncPhase.syncNotes, progress: 0.5);
      expect(state.progress, 0.5);
      expect(state.message, 'Syncing notes...');

      state = state.copyWith(
        status: SyncStatus.success,
        phase: SyncPhase.completed,
        progress: 1.0,
      );
      expect(state.status, SyncStatus.success);
      expect(state.progress, 1.0);
      expect(state.message, 'Sync completed successfully');
    });

    test('error state preserves progress', () {
      final state = SyncState(
        status: SyncStatus.syncing,
        phase: SyncPhase.syncDiaryDays,
        progress: 0.5,
        completedItems: 25,
        totalItems: 50,
      );
      final errorState = state.copyWith(
        status: SyncStatus.error,
        phase: SyncPhase.failed,
        errorMessage: 'Connection lost',
      );

      expect(errorState.status, SyncStatus.error);
      expect(errorState.message, 'Connection lost');
      expect(errorState.progress, 0.5);
      expect(errorState.completedItems, 25);
      expect(errorState.totalItems, 50);
    });

    test('batch progress tracking', () {
      var state = SyncState(
        status: SyncStatus.syncing,
        phase: SyncPhase.syncDiaryDays,
        progress: 0.2,
        completedItems: 0,
        totalItems: 120,
      );

      // First batch done
      state = state.copyWith(completedItems: 50, progress: 0.325);
      expect(state.completedItems, 50);
      expect(state.totalItems, 120);

      // Second batch done
      state = state.copyWith(completedItems: 100, progress: 0.45);
      expect(state.completedItems, 100);

      // Third batch done
      state = state.copyWith(completedItems: 120, progress: 0.5);
      expect(state.completedItems, 120);
    });
  });
}
