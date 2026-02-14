import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteSearchProvider', () {
    test('initial state is empty', () {
      final provider = NoteSearchProvider();
      expect(provider.state.isActive, false);
      expect(provider.state.query, '');
      expect(provider.state.categoryFilter, isNull);
      expect(provider.state.dateFrom, isNull);
      expect(provider.state.dateTo, isNull);
    });

    test('setQuery updates state with new query', () {
      final provider = NoteSearchProvider();
      provider.setQuery('meeting');

      expect(provider.state.query, 'meeting');
      expect(provider.state.isActive, true);
    });

    test('setQuery with empty string clears query but keeps other filters', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final provider = NoteSearchProvider();
      provider.setCategoryFilter(category);
      provider.setQuery('test');
      provider.setQuery('');

      expect(provider.state.query, '');
      expect(provider.state.categoryFilter, category);
      expect(provider.state.isActive, true); // Still active due to category
    });

    test('setCategoryFilter updates state with new category', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final provider = NoteSearchProvider();
      provider.setCategoryFilter(category);

      expect(provider.state.categoryFilter, category);
      expect(provider.state.isActive, true);
    });

    test('setCategoryFilter with null clears category filter', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final provider = NoteSearchProvider();
      provider.setCategoryFilter(category);
      provider.setCategoryFilter(null);

      expect(provider.state.categoryFilter, isNull);
      expect(provider.state.isActive, false);
    });

    test('setDateRange updates both from and to dates', () {
      final provider = NoteSearchProvider();
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 1, 31);

      provider.setDateRange(from, to);

      expect(provider.state.dateFrom, from);
      expect(provider.state.dateTo, to);
      expect(provider.state.isActive, true);
    });

    test('setDateRange can set only from date', () {
      final provider = NoteSearchProvider();
      final from = DateTime(2026, 1, 1);

      provider.setDateRange(from, null);

      expect(provider.state.dateFrom, from);
      expect(provider.state.dateTo, isNull);
      expect(provider.state.isActive, true);
    });

    test('setDateRange can set only to date', () {
      final provider = NoteSearchProvider();
      final to = DateTime(2026, 1, 31);

      provider.setDateRange(null, to);

      expect(provider.state.dateFrom, isNull);
      expect(provider.state.dateTo, to);
      expect(provider.state.isActive, true);
    });

    test('setDateRange with both null clears date filters', () {
      final provider = NoteSearchProvider();
      provider.setDateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31));
      provider.setDateRange(null, null);

      expect(provider.state.dateFrom, isNull);
      expect(provider.state.dateTo, isNull);
      expect(provider.state.isActive, false);
    });

    test('clearAll resets state to default', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final provider = NoteSearchProvider();

      // Set all filters
      provider.setQuery('meeting');
      provider.setCategoryFilter(category);
      provider.setDateRange(DateTime(2026, 1, 1), DateTime(2026, 1, 31));

      expect(provider.state.isActive, true);

      // Clear all
      provider.clearAll();

      expect(provider.state.isActive, false);
      expect(provider.state.query, '');
      expect(provider.state.categoryFilter, isNull);
      expect(provider.state.dateFrom, isNull);
      expect(provider.state.dateTo, isNull);
    });

    test('multiple operations maintain state correctly', () {
      final category1 = NoteCategory(title: 'Work', color: Colors.blue);
      final category2 = NoteCategory(title: 'Leisure', color: Colors.green);
      final provider = NoteSearchProvider();

      // Set initial filters
      provider.setQuery('test');
      provider.setCategoryFilter(category1);
      expect(provider.state.query, 'test');
      expect(provider.state.categoryFilter, category1);

      // Update category
      provider.setCategoryFilter(category2);
      expect(provider.state.query, 'test'); // Query unchanged
      expect(provider.state.categoryFilter, category2);

      // Update query
      provider.setQuery('meeting');
      expect(provider.state.query, 'meeting');
      expect(provider.state.categoryFilter, category2); // Category unchanged

      // Add date range
      final from = DateTime(2026, 1, 1);
      final to = DateTime(2026, 1, 31);
      provider.setDateRange(from, to);
      expect(provider.state.query, 'meeting');
      expect(provider.state.categoryFilter, category2);
      expect(provider.state.dateFrom, from);
      expect(provider.state.dateTo, to);
    });
  });
}
