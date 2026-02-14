import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/note_search_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteSearchState', () {
    test('default state has no active filters', () {
      const state = NoteSearchState();
      expect(state.isActive, false);
      expect(state.query, '');
      expect(state.categoryFilter, isNull);
      expect(state.dateFrom, isNull);
      expect(state.dateTo, isNull);
    });

    test('isActive returns true when query is set', () {
      const state = NoteSearchState(query: 'test');
      expect(state.isActive, true);
      expect(state.query, 'test');
    });

    test('isActive returns true when category filter is set', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final state = NoteSearchState(categoryFilter: category);
      expect(state.isActive, true);
      expect(state.categoryFilter, category);
    });

    test('isActive returns true when dateFrom is set', () {
      final date = DateTime(2026, 1, 1);
      final state = NoteSearchState(dateFrom: date);
      expect(state.isActive, true);
      expect(state.dateFrom, date);
    });

    test('isActive returns true when dateTo is set', () {
      final date = DateTime(2026, 1, 31);
      final state = NoteSearchState(dateTo: date);
      expect(state.isActive, true);
      expect(state.dateTo, date);
    });

    test('isActive returns true when multiple filters are set', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final dateFrom = DateTime(2026, 1, 1);
      final dateTo = DateTime(2026, 1, 31);
      final state = NoteSearchState(
        query: 'meeting',
        categoryFilter: category,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      expect(state.isActive, true);
    });

    test('copyWith preserves unmodified fields', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final original = NoteSearchState(query: 'test', categoryFilter: category);
      final updated = original.copyWith(
        dateFrom: () => DateTime(2026, 1, 1),
      );

      expect(updated.query, 'test');
      expect(updated.categoryFilter, category);
      expect(updated.dateFrom, DateTime(2026, 1, 1));
      expect(updated.dateTo, isNull);
    });

    test('copyWith can update query', () {
      const original = NoteSearchState(query: 'old');
      final updated = original.copyWith(query: 'new');

      expect(updated.query, 'new');
    });

    test('copyWith can clear category filter', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final original = NoteSearchState(categoryFilter: category);
      final updated = original.copyWith(categoryFilter: () => null);

      expect(updated.categoryFilter, isNull);
    });

    test('copyWith can clear date filters', () {
      final original = NoteSearchState(
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 1, 31),
      );
      final updated = original.copyWith(
        dateFrom: () => null,
        dateTo: () => null,
      );

      expect(updated.dateFrom, isNull);
      expect(updated.dateTo, isNull);
    });

    test('clearCategory helper clears category filter', () {
      final category = NoteCategory(title: 'Work', color: Colors.blue);
      final original = NoteSearchState(
        query: 'test',
        categoryFilter: category,
      );
      final updated = original.clearCategory();

      expect(updated.query, 'test');
      expect(updated.categoryFilter, isNull);
    });

    test('clearDateRange helper clears both date filters', () {
      final original = NoteSearchState(
        query: 'test',
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 1, 31),
      );
      final updated = original.clearDateRange();

      expect(updated.query, 'test');
      expect(updated.dateFrom, isNull);
      expect(updated.dateTo, isNull);
    });
  });
}
