import 'package:day_tracker/core/database/db_repository.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// NoteTemplateLocalDataProvider — subclasses DbRepository for custom
/// default template initialization logic.
class NoteTemplateLocalDataProvider extends DbRepository<NoteTemplate> {
  NoteTemplateLocalDataProvider()
      : super(
          tableName: NoteTemplate.tableName,
          columns: NoteTemplate.columns,
          fromMap: NoteTemplate.fromDbMap,
          migrations: NoteTemplate.migrations,
        );

  Future<void> initializeWithDefaults(List<NoteTemplate> defaultTemplates) async {
    await readObjectsFromDatabase();

    if (state.isEmpty) {
      LogWrapper.logger.d('No templates found, adding default templates');
      await addDefaultTemplates(defaultTemplates);
    }
  }

  Future<void> addDefaultTemplates(List<NoteTemplate> templates) async {
    try {
      for (final template in templates) {
        await addElement(template);
      }
      LogWrapper.logger.i('Successfully added ${templates.length} default templates');
    } catch (e) {
      LogWrapper.logger.e('Error adding default templates: $e');
    }
  }
}

final noteTemplateLocalDataProvider = StateNotifierProvider<NoteTemplateLocalDataProvider, List<NoteTemplate>>((ref) {
  return NoteTemplateLocalDataProvider();
});

// Provider for the currently selected template
final selectedTemplateProvider = StateNotifierProvider<SelectedTemplateNotifier, NoteTemplate?>((ref) {
  return SelectedTemplateNotifier();
});

class SelectedTemplateNotifier extends StateNotifier<NoteTemplate?> {
  SelectedTemplateNotifier() : super(null);

  void selectTemplate(NoteTemplate? template) {
    state = template;
  }
}
