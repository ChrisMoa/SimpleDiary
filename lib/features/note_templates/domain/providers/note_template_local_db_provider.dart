import 'package:day_tracker/core/database/abstract_local_db_provider_state.dart';
import 'package:day_tracker/core/database/local_db_helper.dart';
import 'package:day_tracker/core/log/logger_instance.dart';
import 'package:day_tracker/features/note_templates/data/models/note_template.dart';
import 'package:day_tracker/features/note_templates/data/repositories/note_template_local_db.dart';
import 'package:day_tracker/features/note_templates/domain/providers/default_templates_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteTemplateLocalDataProvider extends AbstractLocalDbProviderState<NoteTemplate> {
  NoteTemplateLocalDataProvider() : super(tableName: 'note_templates', primaryKey: 'id');

  @override
  LocalDbHelper createLocalDbHelper(String tableName, String primaryKey) {
    return NoteTemplateLocalDb(tableName: tableName, primaryKey: primaryKey, dbFile: dbFile);
  }

  @override
  Future<void> readObjectsFromDatabase() async {
    await super.readObjectsFromDatabase();

    // Check if templates are empty and add defaults if needed
    if (state.isEmpty) {
      LogWrapper.logger.d('No templates found, adding default templates');
      await addDefaultTemplates();
    }
  }

  Future<void> addDefaultTemplates() async {
    try {
      for (final template in defaultTemplates) {
        await addElement(template);
      }
      LogWrapper.logger.i('Successfully added ${defaultTemplates.length} default templates');
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
