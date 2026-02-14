import 'package:day_tracker/core/settings/settings_container.dart';
import 'package:day_tracker/features/note_templates/data/models/description_section.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/notes/data/models/note_category.dart';
import 'package:day_tracker/features/notes/domain/providers/category_local_db_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final defaultTemplatesProvider = Provider<List<NoteTemplate>>((ref) {
  final categories = ref.watch(categoryLocalDataProvider);
  final languageCode = settingsContainer.activeUserSettings.languageCode;

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

  // Get localized template data
  final t = _getLocalizedTemplates(languageCode);
  final workCategory = getCategoryByTitle(t['categoryWork'] as String);
  final foodCategory = getCategoryByTitle(t['categoryFood'] as String);
  final gymCategory = getCategoryByTitle(t['categoryGym'] as String);
  final leisureCategory = getCategoryByTitle(t['categoryLeisure'] as String);
  final sleepCategory = getCategoryByTitle(t['categorySleep'] as String);

  return <NoteTemplate>[
    NoteTemplate(
      title: t['meeting']['title'] as String,
      description: '',
      durationMinutes: 60,
      noteCategory: workCategory,
      descriptionSections: [
        DescriptionSection(
          title: t['meeting']['participants'] as String,
          hint: t['meeting']['participantsHint'] as String,
        ),
        DescriptionSection(
          title: t['meeting']['agenda'] as String,
          hint: t['meeting']['agendaHint'] as String,
        ),
        DescriptionSection(
          title: t['meeting']['actionItems'] as String,
          hint: t['meeting']['actionItemsHint'] as String,
        ),
      ],
    ),
    NoteTemplate(
      title: t['lunchBreak']['title'] as String,
      description: t['lunchBreak']['description'] as String,
      durationMinutes: 30,
      noteCategory: foodCategory,
    ),
    NoteTemplate(
      title: t['gymSession']['title'] as String,
      description: '',
      durationMinutes: 90,
      noteCategory: gymCategory,
      descriptionSections: [
        DescriptionSection(
          title: t['gymSession']['exercises'] as String,
          hint: t['gymSession']['exercisesHint'] as String,
        ),
        DescriptionSection(
          title: t['gymSession']['howFelt'] as String,
          hint: t['gymSession']['howFeltHint'] as String,
        ),
      ],
    ),
    NoteTemplate(
      title: t['focusedWork']['title'] as String,
      description: '',
      durationMinutes: 90,
      noteCategory: workCategory,
      descriptionSections: [
        DescriptionSection(
          title: t['focusedWork']['goal'] as String,
          hint: t['focusedWork']['goalHint'] as String,
        ),
        DescriptionSection(
          title: t['focusedWork']['accomplished'] as String,
          hint: t['focusedWork']['accomplishedHint'] as String,
        ),
        DescriptionSection(
          title: t['focusedWork']['blockers'] as String,
          hint: t['focusedWork']['blockersHint'] as String,
        ),
      ],
    ),
    NoteTemplate(
      title: t['studyTime']['title'] as String,
      description: '',
      durationMinutes: 60,
      noteCategory: workCategory,
      descriptionSections: [
        DescriptionSection(
          title: t['studyTime']['topic'] as String,
          hint: t['studyTime']['topicHint'] as String,
        ),
        DescriptionSection(
          title: t['studyTime']['keyTakeaways'] as String,
          hint: t['studyTime']['keyTakeawaysHint'] as String,
        ),
        DescriptionSection(
          title: t['studyTime']['nextSteps'] as String,
          hint: t['studyTime']['nextStepsHint'] as String,
        ),
      ],
    ),
    NoteTemplate(
      title: t['relaxation']['title'] as String,
      description: t['relaxation']['description'] as String,
      durationMinutes: 60,
      noteCategory: leisureCategory,
    ),
    NoteTemplate(
      title: t['sleep']['title'] as String,
      description: t['sleep']['description'] as String,
      durationMinutes: 480, // 8 hours
      noteCategory: sleepCategory,
    ),
  ];
});

/// Get localized template strings based on language code
Map<String, dynamic> _getLocalizedTemplates(String languageCode) {
  switch (languageCode) {
    case 'de':
      return {
        'categoryWork': 'Arbeit',
        'categoryFood': 'Essen',
        'categoryGym': 'Gym',
        'categoryLeisure': 'Freizeit',
        'categorySleep': 'Schlafen',
        'meeting': {
          'title': 'Meeting',
          'participants': 'Teilnehmer',
          'participantsHint': 'Wer war dabei?',
          'agenda': 'Agenda',
          'agendaHint': 'Besprochene Themen',
          'actionItems': 'Aktionspunkte',
          'actionItemsHint': 'Nächste Schritte',
        },
        'lunchBreak': {
          'title': 'Mittagspause',
          'description': 'Zeit zum Essen und Auftanken.',
        },
        'gymSession': {
          'title': 'Gym Session',
          'exercises': 'Übungen',
          'exercisesHint': 'Welche Übungen hast du gemacht?',
          'howFelt': 'Wie ich mich gefühlt habe',
          'howFeltHint': 'Energielevel, Stimmung',
        },
        'focusedWork': {
          'title': 'Fokussierte Arbeit',
          'goal': 'Ziel',
          'goalHint': 'Woran arbeitest du?',
          'accomplished': 'Erreicht',
          'accomplishedHint': 'Was hast du geschafft?',
          'blockers': 'Hindernisse',
          'blockersHint': 'Gab es Hindernisse?',
        },
        'studyTime': {
          'title': 'Lernzeit',
          'topic': 'Thema',
          'topicHint': 'Was lernst du?',
          'keyTakeaways': 'Wichtigste Erkenntnisse',
          'keyTakeawaysHint': 'Was hast du gelernt?',
          'nextSteps': 'Nächste Schritte',
          'nextStepsHint': 'Was als nächstes wiederholen',
        },
        'relaxation': {
          'title': 'Entspannung',
          'description': 'Zeit zum Entspannen und Erholen.',
        },
        'sleep': {
          'title': 'Schlafen',
          'description': 'Gute Nacht.',
        },
      };
    case 'en':
    case 'es':
      return {
        'categoryWork': 'Trabajo',
        'categoryFood': 'Comida',
        'categoryGym': 'Gimnasio',
        'categoryLeisure': 'Ocio',
        'categorySleep': 'Dormir',
        'meeting': {
          'title': 'Reunión',
          'participants': 'Participantes',
          'participantsHint': '¿Quién asistió?',
          'agenda': 'Agenda',
          'agendaHint': 'Temas discutidos',
          'actionItems': 'Puntos de Acción',
          'actionItemsHint': 'Próximos pasos',
        },
        'lunchBreak': {
          'title': 'Pausa para Almorzar',
          'description': 'Tiempo para comer y recargar energías.',
        },
        'gymSession': {
          'title': 'Sesión de Gimnasio',
          'exercises': 'Ejercicios',
          'exercisesHint': '¿Qué ejercicios hiciste?',
          'howFelt': 'Cómo me sentí',
          'howFeltHint': 'Nivel de energía, estado de ánimo',
        },
        'focusedWork': {
          'title': 'Trabajo Concentrado',
          'goal': 'Objetivo',
          'goalHint': '¿En qué estás trabajando?',
          'accomplished': 'Logrado',
          'accomplishedHint': '¿Qué terminaste?',
          'blockers': 'Obstáculos',
          'blockersHint': '¿Hubo obstáculos?',
        },
        'studyTime': {
          'title': 'Tiempo de Estudio',
          'topic': 'Tema',
          'topicHint': '¿Qué estás estudiando?',
          'keyTakeaways': 'Conclusiones Clave',
          'keyTakeawaysHint': '¿Qué aprendiste?',
          'nextSteps': 'Próximos Pasos',
          'nextStepsHint': 'Qué revisar a continuación',
        },
        'relaxation': {
          'title': 'Relajación',
          'description': 'Tiempo para relajarse y descansar.',
        },
        'sleep': {
          'title': 'Dormir',
          'description': 'Buenas noches.',
        },
      };
    case 'fr':
      return {
        'categoryWork': 'Travail',
        'categoryFood': 'Nourriture',
        'categoryGym': 'Gym',
        'categoryLeisure': 'Loisirs',
        'categorySleep': 'Sommeil',
        'meeting': {
          'title': 'Réunion',
          'participants': 'Participants',
          'participantsHint': 'Qui a participé ?',
          'agenda': 'Ordre du jour',
          'agendaHint': 'Sujets discutés',
          'actionItems': 'Points d\'action',
          'actionItemsHint': 'Prochaines étapes',
        },
        'lunchBreak': {
          'title': 'Pause Déjeuner',
          'description': 'Temps pour manger et se ressourcer.',
        },
        'gymSession': {
          'title': 'Séance de Gym',
          'exercises': 'Exercices',
          'exercisesHint': 'Quels exercices avez-vous faits ?',
          'howFelt': 'Comment je me suis senti',
          'howFeltHint': 'Niveau d\'énergie, humeur',
        },
        'focusedWork': {
          'title': 'Travail Concentré',
          'goal': 'Objectif',
          'goalHint': 'Sur quoi travaillez-vous ?',
          'accomplished': 'Accompli',
          'accomplishedHint': 'Qu\'avez-vous terminé ?',
          'blockers': 'Obstacles',
          'blockersHint': 'Y a-t-il eu des obstacles ?',
        },
        'studyTime': {
          'title': 'Temps d\'Étude',
          'topic': 'Sujet',
          'topicHint': 'Qu\'étudiez-vous ?',
          'keyTakeaways': 'Points Clés',
          'keyTakeawaysHint': 'Qu\'avez-vous appris ?',
          'nextSteps': 'Prochaines Étapes',
          'nextStepsHint': 'Quoi réviser ensuite',
        },
        'relaxation': {
          'title': 'Relaxation',
          'description': 'Temps pour se détendre et se relaxer.',
        },
        'sleep': {
          'title': 'Sommeil',
          'description': 'Bonne nuit.',
        },
      };
    default:
      return {
        'categoryWork': 'Work',
        'categoryFood': 'Food',
        'categoryGym': 'Gym',
        'categoryLeisure': 'Leisure',
        'categorySleep': 'Sleep',
        'meeting': {
          'title': 'Meeting',
          'participants': 'Participants',
          'participantsHint': 'Who attended?',
          'agenda': 'Agenda',
          'agendaHint': 'Topics discussed',
          'actionItems': 'Action Items',
          'actionItemsHint': 'Next steps',
        },
        'lunchBreak': {
          'title': 'Lunch Break',
          'description': 'Time to eat lunch and recharge.',
        },
        'gymSession': {
          'title': 'Gym Session',
          'exercises': 'Exercises',
          'exercisesHint': 'What exercises did you do?',
          'howFelt': 'How I Felt',
          'howFeltHint': 'Energy level, mood',
        },
        'focusedWork': {
          'title': 'Focused Work',
          'goal': 'Goal',
          'goalHint': 'What are you working on?',
          'accomplished': 'Accomplished',
          'accomplishedHint': 'What did you finish?',
          'blockers': 'Blockers',
          'blockersHint': 'Any obstacles?',
        },
        'studyTime': {
          'title': 'Study Time',
          'topic': 'Topic',
          'topicHint': 'What are you studying?',
          'keyTakeaways': 'Key Takeaways',
          'keyTakeawaysHint': 'What did you learn?',
          'nextSteps': 'Next Steps',
          'nextStepsHint': 'What to review next',
        },
        'relaxation': {
          'title': 'Relaxation',
          'description': 'Time to unwind and relax.',
        },
        'sleep': {
          'title': 'Sleep',
          'description': 'Good night sleep.',
        },
      };
  }
}
