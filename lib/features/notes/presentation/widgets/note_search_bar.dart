import 'dart:async';

import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_search_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// A search bar widget with text search, category filter, and date range picker
class NoteSearchBar extends ConsumerStatefulWidget {
  const NoteSearchBar({super.key});

  @override
  ConsumerState<NoteSearchBar> createState() => _NoteSearchBarState();
}

class _NoteSearchBarState extends ConsumerState<NoteSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current search state
    final searchState = ref.read(noteSearchProvider);
    _searchController.text = searchState.query;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(noteSearchProvider.notifier).setQuery(value);
    });
  }

  Future<void> _selectDateFrom() async {
    final l10n = AppLocalizations.of(context);
    final searchState = ref.read(noteSearchProvider);
    final initialDate = searchState.dateFrom ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l10n.dateFrom,
    );

    if (picked != null) {
      ref.read(noteSearchProvider.notifier).setDateRange(
            picked,
            searchState.dateTo,
          );
    }
  }

  Future<void> _selectDateTo() async {
    final l10n = AppLocalizations.of(context);
    final searchState = ref.read(noteSearchProvider);
    final initialDate = searchState.dateTo ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: l10n.dateTo,
    );

    if (picked != null) {
      ref.read(noteSearchProvider.notifier).setDateRange(
            searchState.dateFrom,
            picked,
          );
    }
  }

  void _clearAllFilters() {
    _searchController.clear();
    ref.read(noteSearchProvider.notifier).clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final searchState = ref.watch(noteSearchProvider);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search text field
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchNotesPlaceholder,
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                suffixIcon: searchState.query.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(noteSearchProvider.notifier).setQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2.0,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 12.0),

            // Filter buttons row
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                // Category filter
                _buildCategoryFilter(l10n, searchState),

                // Date from filter
                _buildDateButton(
                  label: searchState.dateFrom != null
                      ? DateFormat.yMMMd().format(searchState.dateFrom!)
                      : l10n.dateFrom,
                  icon: Icons.calendar_today,
                  onPressed: _selectDateFrom,
                  isActive: searchState.dateFrom != null,
                ),

                // Date to filter
                _buildDateButton(
                  label: searchState.dateTo != null
                      ? DateFormat.yMMMd().format(searchState.dateTo!)
                      : l10n.dateTo,
                  icon: Icons.calendar_today,
                  onPressed: _selectDateTo,
                  isActive: searchState.dateTo != null,
                ),

                // Clear all button
                if (searchState.isActive)
                  OutlinedButton.icon(
                    onPressed: _clearAllFilters,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: Text(l10n.clearAll),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),

            // Active filters chips
            if (searchState.isActive) ...[
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  if (searchState.categoryFilter != null)
                    _buildFilterChip(
                      label: searchState.categoryFilter!.title,
                      onDeleted: () {
                        ref.read(noteSearchProvider.notifier).setCategoryFilter(null);
                      },
                      color: searchState.categoryFilter!.color,
                    ),
                  if (searchState.dateFrom != null || searchState.dateTo != null)
                    _buildFilterChip(
                      label: _formatDateRange(searchState.dateFrom, searchState.dateTo),
                      onDeleted: () {
                        ref.read(noteSearchProvider.notifier).setDateRange(null, null);
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(AppLocalizations l10n, NoteSearchState searchState) {
    final categories = ref.watch(categoryLocalDataProvider);

    return PopupMenuButton<NoteCategory?>(
      onSelected: (category) {
        ref.read(noteSearchProvider.notifier).setCategoryFilter(category);
      },
      itemBuilder: (context) => [
        PopupMenuItem<NoteCategory?>(
          value: null,
          child: Text(
            l10n.allCategories,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const PopupMenuDivider(),
        ...categories.map(
          (category) => PopupMenuItem<NoteCategory?>(
            value: category,
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: category.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(category.title),
              ],
            ),
          ),
        ),
      ],
      child: OutlinedButton.icon(
        onPressed: null,
        icon: Icon(
          Icons.category,
          size: 18,
          color: searchState.categoryFilter != null
              ? searchState.categoryFilter!.color
              : null,
        ),
        label: Text(
          searchState.categoryFilter?.title ?? l10n.selectCategory,
        ),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required VoidCallback onDeleted,
    Color? color,
  }) {
    return Chip(
      label: Text(label),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 18),
      backgroundColor: color?.withValues(alpha: 0.2),
      avatar: color != null
          ? CircleAvatar(
              backgroundColor: color,
              radius: 8,
            )
          : null,
    );
  }

  String _formatDateRange(DateTime? from, DateTime? to) {
    final formatter = DateFormat.yMMMd();
    if (from != null && to != null) {
      return '${formatter.format(from)} - ${formatter.format(to)}';
    } else if (from != null) {
      return 'From ${formatter.format(from)}';
    } else if (to != null) {
      return 'To ${formatter.format(to)}';
    }
    return '';
  }
}
