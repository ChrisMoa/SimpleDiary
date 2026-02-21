import 'package:day_tracker/core/utils/utils.dart';
import 'package:day_tracker/features/notes/data/models/note.dart';
import 'package:day_tracker/features/notes/domain/providers/note_attachments_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_editing_page_provider.dart';
import 'package:day_tracker/features/notes/domain/providers/note_local_db_provider.dart';
import 'package:day_tracker/features/notes/presentation/pages/note_editing_page.dart';
import 'package:day_tracker/features/notes/presentation/widgets/image_picker_widget.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteViewingPage extends ConsumerStatefulWidget {
  const NoteViewingPage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteViewingPageState();
}

class _NoteViewingPageState extends ConsumerState<NoteViewingPage> {
  @override
  Widget build(BuildContext context) {
    final note = ref.watch(noteEditingPageProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        actions: _buildViewingActions(context, note),
      ),
      body: ListView(
        padding: AppSpacing.paddingAllMd,
        children: [
          // Title
          Text(
            note.title,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalMd,

          // Category
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: note.noteCategory.color,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpacing.horizontalXs,
              Text(
                note.noteCategory.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          AppSpacing.verticalMd,

          // Date & Time card
          AppCard.flat(
            padding: AppSpacing.paddingAllMd,
            borderRadius: AppRadius.borderRadiusMd,
            child: Column(
              children: [
                _buildDateRow(
                  context,
                  icon: note.isAllDay ? Icons.calendar_today_rounded : Icons.schedule_rounded,
                  label: note.isAllDay ? l10n.allDay : l10n.from,
                  date: Utils.toDate(note.from),
                  time: note.isAllDay ? null : Utils.toTime(note.from),
                ),
                if (!note.isAllDay) ...[
                  Divider(color: theme.colorScheme.outlineVariant),
                  _buildDateRow(
                    context,
                    icon: Icons.schedule_rounded,
                    label: l10n.to,
                    date: Utils.toDate(note.to),
                    time: Utils.toTime(note.to),
                  ),
                ],
              ],
            ),
          ),
          AppSpacing.verticalMd,

          // Description
          if (note.description.isNotEmpty) ...[
            AppCard.flat(
              padding: AppSpacing.paddingAllMd,
              borderRadius: AppRadius.borderRadiusMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.description,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    note.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalMd,
          ],

          // Photos
          ImagePickerWidget(noteId: note.id!, readOnly: true),
        ],
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String date,
    String? time,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        AppSpacing.horizontalSm,
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          date,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (time != null) ...[
          AppSpacing.horizontalSm,
          Text(
            time,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildViewingActions(BuildContext context, Note note) {
    final l10n = AppLocalizations.of(context);
    return [
      IconButton(
        icon: const Icon(Icons.edit),
        tooltip: l10n.editNote,
        onPressed: () {
          ref.read(noteEditingPageProvider.notifier).updateNote(note);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const NoteEditingPage(
                editNote: true,
                navigateBack: true,
              ),
            ),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.delete),
        tooltip: l10n.deleteNote,
        onPressed: () async {
          final confirmed = await AppDialog.confirm(
            context,
            title: l10n.deleteNote,
            content: l10n.confirmDeleteNote,
            confirmLabel: l10n.delete,
            cancelLabel: l10n.cancel,
            isDestructive: true,
          );
          if (confirmed) {
            await ref
                .read(noteAttachmentsProvider.notifier)
                .removeAllForNote(note.id!);
            await ref
                .read(notesLocalDataProvider.notifier)
                .deleteElement(note);
            if (context.mounted) Navigator.of(context).pop();
          }
        },
      ),
    ];
  }
}
