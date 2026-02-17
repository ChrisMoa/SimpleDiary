import 'dart:io';

import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:day_tracker/features/notes/domain/providers/note_attachments_provider.dart';
import 'package:day_tracker/features/notes/presentation/widgets/image_gallery_viewer.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int _maxAttachments = 10;

class ImagePickerWidget extends ConsumerWidget {
  final String noteId;
  final bool readOnly;

  const ImagePickerWidget({
    super.key,
    required this.noteId,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final attachments = ref
        .watch(noteAttachmentsProvider)
        .where((a) => a.noteId == noteId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.photos,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            if (!readOnly && attachments.length < _maxAttachments)
              TextButton.icon(
                onPressed: () => _pickImages(context, ref, attachments.length),
                icon: Icon(Icons.add_photo_alternate_outlined,
                    color: Theme.of(context).colorScheme.primary),
                label: Text(
                  '${attachments.length}/$_maxAttachments',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
          ],
        ),
        if (attachments.isEmpty && readOnly)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.noPhotos,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        if (attachments.isNotEmpty)
          _buildThumbnailGrid(context, ref, attachments),
      ],
    );
  }

  Widget _buildThumbnailGrid(
    BuildContext context,
    WidgetRef ref,
    List<NoteAttachment> attachments,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: attachments.length,
      itemBuilder: (context, index) {
        final attachment = attachments[index];
        final file = File(attachment.filePath);
        final exists = file.existsSync();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ImageGalleryViewer(
                attachments: attachments,
                initialIndex: index,
                noteId: noteId,
                readOnly: readOnly,
              ),
            ));
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: exists
                    ? Image.file(
                        file,
                        fit: BoxFit.cover,
                        cacheWidth: 300,
                        errorBuilder: (_, __, ___) =>
                            _brokenImagePlaceholder(context),
                      )
                    : _brokenImagePlaceholder(context),
              ),
              if (!readOnly)
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _removeAttachment(ref, attachment),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _brokenImagePlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.broken_image_outlined,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Future<void> _pickImages(
    BuildContext context,
    WidgetRef ref,
    int currentCount,
  ) async {
    final remaining = _maxAttachments - currentCount;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final selected = result.files.take(remaining).toList();
    for (final pf in selected) {
      if (pf.path == null) continue;
      await ref
          .read(noteAttachmentsProvider.notifier)
          .addImage(File(pf.path!), noteId);
    }
  }

  Future<void> _removeAttachment(
    WidgetRef ref,
    NoteAttachment attachment,
  ) async {
    await ref
        .read(noteAttachmentsProvider.notifier)
        .removeAttachment(attachment);
  }
}
