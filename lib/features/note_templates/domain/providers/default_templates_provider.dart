import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final defaultTemplatesProvider = Provider<List<NoteTemplate>>((ref) {
  final categories = ref.watch(categoryLocalDataProvider);

  // Helper to find category by title, or use first available
  NoteCategory getCategoryByTitle(String title) {
    try {
      return categories.firstWhere((cat) => cat.title == title);
    } catch (e) {
      // If category not found, use the first available category
      return categories.isNotEmpty ? categories.first : NoteCategory(title: 'Default', color: const Color(0xFF2196F3));
    }
  }

  if (categories.isEmpty) {
    return [];
  }

  return <NoteTemplate>[
  NoteTemplate(
    title: 'Meeting',
    description: '',
    durationMinutes: 60,
    noteCategory: getCategoryByTitle('Arbeit'),
    descriptionSections: [
      DescriptionSection(title: 'Participants', hint: 'Who attended?'),
      DescriptionSection(title: 'Agenda', hint: 'Topics discussed'),
      DescriptionSection(title: 'Action Items', hint: 'Next steps'),
    ],
  ),
  NoteTemplate(
    title: 'Lunch Break',
    description: 'Time to eat lunch and recharge.',
    durationMinutes: 30,
    noteCategory: getCategoryByTitle('Essen'),
  ),
  NoteTemplate(
    title: 'Gym Session',
    description: '',
    durationMinutes: 90,
    noteCategory: getCategoryByTitle('Gym'),
    descriptionSections: [
      DescriptionSection(title: 'Exercises', hint: 'What exercises did you do?'),
      DescriptionSection(title: 'How I Felt', hint: 'Energy level, mood'),
    ],
  ),
  NoteTemplate(
    title: 'Focused Work',
    description: '',
    durationMinutes: 90,
    noteCategory: getCategoryByTitle('Arbeit'),
    descriptionSections: [
      DescriptionSection(title: 'Goal', hint: 'What are you working on?'),
      DescriptionSection(title: 'Accomplished', hint: 'What did you finish?'),
      DescriptionSection(title: 'Blockers', hint: 'Any obstacles?'),
    ],
  ),
  NoteTemplate(
    title: 'Study Time',
    description: '',
    durationMinutes: 60,
    noteCategory: getCategoryByTitle('Arbeit'),
    descriptionSections: [
      DescriptionSection(title: 'Topic', hint: 'What are you studying?'),
      DescriptionSection(title: 'Key Takeaways', hint: 'What did you learn?'),
      DescriptionSection(title: 'Next Steps', hint: 'What to review next'),
    ],
  ),
  NoteTemplate(
    title: 'Relaxation',
    description: 'Time to unwind and relax.',
    durationMinutes: 60,
    noteCategory: getCategoryByTitle('Freizeit'),
  ),
  NoteTemplate(
    title: 'Sleep',
    description: 'Good night sleep.',
    durationMinutes: 480, // 8 hours
    noteCategory: getCategoryByTitle('Schlafen'),
  ),
];
});
