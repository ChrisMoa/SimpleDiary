import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';

final defaultTemplates = <NoteTemplate>[
  NoteTemplate(
    title: 'Meeting',
    description: 'Team meeting to discuss project progress and upcoming tasks.',
    durationMinutes: 60,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Arbeit'),
  ),
  NoteTemplate(
    title: 'Lunch Break',
    description: 'Time to eat lunch and recharge.',
    durationMinutes: 30,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Essen'),
  ),
  NoteTemplate(
    title: 'Gym Session',
    description: 'Strength training and cardio workout.',
    durationMinutes: 90,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Gym'),
  ),
  NoteTemplate(
    title: 'Focused Work',
    description: 'Deep work session without distractions.',
    durationMinutes: 90,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Arbeit'),
  ),
  NoteTemplate(
    title: 'Study Time',
    description: 'Learning new skills or reviewing material.',
    durationMinutes: 60,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Arbeit'),
  ),
  NoteTemplate(
    title: 'Relaxation',
    description: 'Time to unwind and relax.',
    durationMinutes: 60,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Freizeit'),
  ),
  NoteTemplate(
    title: 'Sleep',
    description: 'Good night sleep.',
    durationMinutes: 480, // 8 hours
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Schlafen'),
  ),
];

