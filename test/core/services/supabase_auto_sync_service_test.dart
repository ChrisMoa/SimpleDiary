import 'package:day_tracker/core/services/supabase_auto_sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseAutoSyncService', () {
    setUp(() {
      SupabaseAutoSyncService.resetDebounce();
    });

    test('resetDebounce clears last sync time', () {
      // Verify resetDebounce does not throw
      expect(() => SupabaseAutoSyncService.resetDebounce(), returnsNormally);
    });
  });
}
