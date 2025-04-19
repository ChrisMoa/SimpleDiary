import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:day_tracker/features/day_rating/domain/providers/diary_day_local_db_provider.dart';
import 'package:day_tracker/core/provider/theme_provider.dart';

class DiaryDayDetailPage extends ConsumerWidget {
  final DateTime selectedDate;

  const DiaryDayDetailPage({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get diary day data
    final diaryDayAsync = ref.watch(diaryDayForDateProvider(selectedDate));
    // Get notes for this day
    final notesAsync = ref.watch(notesForDayProvider(selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: Text('Day Detail: ${_formatDate(selectedDate)}'),
        actions: [
          diaryDayAsync.when(
            data: (diaryDay) => diaryDay != null
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, ref, diaryDay.id),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: diaryDayAsync.when(
        data: (diaryDay) {
          if (diaryDay == null) {
            return const Center(child: Text('No diary entry for this day'));
          }

          return notesAsync.when(
            data: (notes) => _buildDiaryDayDetail(context, diaryDay, notes),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading notes: $error'),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading diary day: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNewNote(context, selectedDate),
        child: const Icon(Icons.add),
        tooltip: 'Add a note',
      ),
    );
  }

  Widget _buildDiaryDayDetail(
    BuildContext context,
    dynamic diaryDay,
    List<dynamic> notes,
  ) {
    final theme = Theme.of(context);
    // Calculate overall score based on the actual DiaryDay structure
    // DiaryDay in simple_diary already has an overallScore getter
    final overallScore = diaryDay.overallScore;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Day summary card
        Card(
          elevation: 2,
          color: theme.colorScheme.secondaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildRatingsSummary(context, diaryDay),
                const SizedBox(height: 16),
                _buildOverallMood(context, overallScore),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Notes section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notes & Activities',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (notes.isNotEmpty)
              Text(
                '${notes.length} entries',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        notes.isEmpty ? _buildEmptyNotesMessage(context) : _buildNotesList(context, notes),
      ],
    );
  }

  Widget _buildRatingsSummary(BuildContext context, dynamic diaryDay) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: diaryDay.ratings.map<Widget>((rating) {
        // Convert enum to string and extract just the name part
        String enumString = rating.dayRating.toString();
        String ratingName = enumString.split('.').last;

        return _buildRatingChip(context, ratingName, rating.score);
      }).toList(),
    );
  }

  Widget _buildRatingChip(BuildContext context, String label, int rating) {
    final theme = Theme.of(context);
    final color = _getRatingColor(rating);

    return Chip(
      label: Text(
        '$label: ${_getRatingText(rating)}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.2),
      side: BorderSide(color: color),
      avatar: Icon(
        _getRatingIcon(rating),
        color: color,
        size: 18,
      ),
    );
  }

  Widget _buildOverallMood(BuildContext context, int score) {
    final theme = Theme.of(context);
    // Maximum possible score (4 categories × 5 points per category)
    const maxScore = 20;
    final percentage = score / maxScore;

    // Choose color based on score
    Color scoreColor = _getScoreColor(percentage);
    String moodText = _getMoodText(percentage);

    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: scoreColor.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.2),
          child: Text(
            '$score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Mood: $moodText',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage,
                backgroundColor: theme.brightness == Brightness.dark ? theme.colorScheme.surfaceVariant : Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyNotesMessage(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 48,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notes for this day',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your thoughts, activities or memories',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<dynamic> notes) {
    // Sort notes by time
    final sortedNotes = [...notes]..sort((a, b) => a.from.compareTo(b.from));

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedNotes.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return _buildNoteItem(context, note);
      },
    );
  }

  Widget _buildNoteItem(BuildContext context, dynamic note) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _viewNote(context, note),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getCategoryIcon(context, note.noteCategory),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _editNote(context, note),
                    tooltip: 'Edit note',
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              if (note.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer.withOpacity(0.9),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    note.isAllDay ? 'All day' : '${_formatTime(note.from)} - ${_formatTime(note.to)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(BuildContext context, dynamic category) {
    final theme = Theme.of(context);
    IconData iconData = Icons.note;
    Color baseColor = Colors.blue;

    // In simple_diary, Note has 'noteCategory' property which has a 'title' property
    String categoryTitle = "";
    Color? categoryColor;

    if (category is String) {
      categoryTitle = category;
    } else if (category != null) {
      // Try to access noteCategory.title and color
      try {
        categoryTitle = category.title;
        // If the category has a color property, use it
        if (category is dynamic && category.color != null) {
          categoryColor = category.color;
        }
      } catch (e) {
        // If that fails, try toString()
        categoryTitle = category.toString();
      }
    }

    // Check the category title (case insensitive)
    categoryTitle = categoryTitle.toLowerCase();

    if (categoryTitle.contains('arbeit') || categoryTitle.contains('work')) {
      iconData = Icons.work;
      baseColor = categoryColor ?? Colors.blue;
    } else if (categoryTitle.contains('freizeit') || categoryTitle.contains('leisure')) {
      iconData = Icons.sports_esports;
      baseColor = categoryColor ?? Colors.purple;
    } else if (categoryTitle.contains('essen') || categoryTitle.contains('food')) {
      iconData = Icons.restaurant;
      baseColor = categoryColor ?? Colors.orange;
    } else if (categoryTitle.contains('gym')) {
      iconData = Icons.fitness_center;
      baseColor = categoryColor ?? Colors.green;
    } else if (categoryTitle.contains('schlafen') || categoryTitle.contains('sleep')) {
      iconData = Icons.bedtime;
      baseColor = categoryColor ?? Colors.indigo;
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: baseColor.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.2),
      child: Icon(iconData, size: 16, color: baseColor),
    );
  }

  IconData _getRatingIcon(int rating) {
    if (rating <= 1) return Icons.sentiment_very_dissatisfied;
    if (rating == 2) return Icons.sentiment_dissatisfied;
    if (rating == 3) return Icons.sentiment_neutral;
    if (rating == 4) return Icons.sentiment_satisfied;
    return Icons.sentiment_very_satisfied;
  }

  String _getRatingText(int rating) {
    if (rating <= 1) return 'Poor';
    if (rating == 2) return 'Fair';
    if (rating == 3) return 'Good';
    if (rating == 4) return 'Great';
    return 'Excellent';
  }

  String _getMoodText(double percentage) {
    if (percentage < 0.3) return 'Tough Day';
    if (percentage < 0.5) return 'Could Be Better';
    if (percentage < 0.7) return 'Pretty Good';
    if (percentage < 0.9) return 'Great Day';
    return 'Perfect Day';
  }

  Color _getScoreColor(double percentage) {
    if (percentage < 0.3) return Colors.red;
    if (percentage < 0.5) return Colors.orange;
    if (percentage < 0.7) return Colors.amber;
    if (percentage < 0.9) return Colors.lightGreen;
    return Colors.green;
  }

  Color _getRatingColor(int rating) {
    if (rating <= 1) return Colors.red;
    if (rating == 2) return Colors.orange;
    if (rating == 3) return Colors.amber;
    if (rating == 4) return Colors.lightGreen;
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMM d, y').format(date);
  }

  String _formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int diaryDayId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Diary Entry'),
        content: const Text(
          'Are you sure you want to delete this diary entry? This will remove both the day rating and all associated notes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete the diary day
              // Implementation will depend on the actual provider in the project
              // ref.read(diaryDayProvider.notifier).delete(diaryDayId);
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _addNewNote(BuildContext context, DateTime day) {
    // Implementation will depend on the actual providers and pages in the project
  }

  void _viewNote(BuildContext context, dynamic note) {
    // Implementation will depend on the actual providers and pages in the project
  }

  void _editNote(BuildContext context, dynamic note) {
    // Implementation will depend on the actual providers and pages in the project
  }
}

// Define providers for the specific data needed on this page
final diaryDayForDateProvider = FutureProvider.family<dynamic, DateTime>(
  (ref, date) async {
    // Get the diary days from the same data source used in the dashboard
    final diaryDays = ref.watch(diaryDayFullDataProvider);

    // Find the diary day with the matching date
    // Note: This might need adjustment based on how dates are compared in your app
    final found = diaryDays.where((diaryDay) => diaryDay.day.year == date.year && diaryDay.day.month == date.month && diaryDay.day.day == date.day).toList();

    if (found.isEmpty) {
      return null;
    }
    return found.first;
  },
);

final notesForDayProvider = FutureProvider.family<List<dynamic>, DateTime>(
  (ref, date) async {
    // Get the diary day first
    final diaryDay = await ref.watch(diaryDayForDateProvider(date).future);

    // If no diary day found, return empty list
    if (diaryDay == null) {
      return [];
    }

    // Return the notes from the diary day
    return diaryDay.notes;
  },
);
