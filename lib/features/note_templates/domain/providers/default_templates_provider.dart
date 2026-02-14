import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';

final defaultTemplates = <NoteTemplate>[
  NoteTemplate(
    title: 'Meeting',
    description: '',
    durationMinutes: 60,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Arbeit'),
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
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Essen'),
  ),
  NoteTemplate(
    title: 'Gym Session',
    description: '',
    durationMinutes: 90,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Gym'),
    descriptionSections: [
      DescriptionSection(title: 'Exercises', hint: 'What exercises did you do?'),
      DescriptionSection(title: 'How I Felt', hint: 'Energy level, mood'),
    ],
  ),
  NoteTemplate(
    title: 'Focused Work',
    description: '',
    durationMinutes: 90,
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Arbeit'),
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
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Arbeit'),
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
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Freizeit'),
  ),
  NoteTemplate(
    title: 'Sleep',
    description: 'Good night sleep.',
    durationMinutes: 480, // 8 hours
    noteCategory: availableNoteCategories.firstWhere((cat) => cat.title == 'Schlafen'),
  ),
];
