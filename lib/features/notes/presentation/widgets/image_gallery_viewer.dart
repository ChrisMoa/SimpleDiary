import 'dart:io';

import 'package:day_tracker/core/widgets/app_ui_kit.dart';
import 'package:day_tracker/features/notes/data/models/note_attachment.dart';
import 'package:day_tracker/features/notes/domain/providers/note_attachments_provider.dart';
import 'package:day_tracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageGalleryViewer extends ConsumerStatefulWidget {
  final List<NoteAttachment> attachments;
  final int initialIndex;
  final String noteId;
  final bool readOnly;

  const ImageGalleryViewer({
    super.key,
    required this.attachments,
    required this.noteId,
    this.initialIndex = 0,
    this.readOnly = false,
  });

  @override
  ConsumerState<ImageGalleryViewer> createState() => _ImageGalleryViewerState();
}

class _ImageGalleryViewerState extends ConsumerState<ImageGalleryViewer> {
  late PageController _pageController;
  late int _currentIndex;
  late List<NoteAttachment> _attachments;

  @override
  void initState() {
    super.initState();
    _attachments = List.from(widget.attachments);
    _currentIndex = widget.initialIndex.clamp(0, _attachments.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_attachments.isEmpty) {
      return Scaffold(
        appBar: AppBar(leading: const CloseButton()),
        body: Center(
          child: Text(
            l10n.noPhotos,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: const CloseButton(),
        title: Text(
          '${_currentIndex + 1} / ${_attachments.length}',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (!widget.readOnly)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: l10n.deletePhoto,
              onPressed: () => _confirmDelete(context, l10n),
            ),
        ],
      ),
      body: PhotoViewGallery.builder(
        pageController: _pageController,
        itemCount: _attachments.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        builder: (context, index) {
          final file = File(_attachments[index].filePath);
          if (!file.existsSync()) {
            return PhotoViewGalleryPageOptions.customChild(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image_outlined,
                        size: 64, color: Colors.white54),
                    AppSpacing.verticalXs,
                    Text(
                      l10n.imageNotFound,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            );
          }
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(file),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          );
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            value: event == null || event.expectedTotalBytes == null
                ? null
                : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: l10n.deletePhoto,
      content: l10n.deletePhotoConfirm,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final toRemove = _attachments[_currentIndex];
    await ref
        .read(noteAttachmentsProvider.notifier)
        .removeAttachment(toRemove);

    setState(() {
      _attachments.removeAt(_currentIndex);
      if (_attachments.isEmpty) {
        Navigator.of(context).pop();
        return;
      }
      _currentIndex = _currentIndex.clamp(0, _attachments.length - 1);
      _pageController.jumpToPage(_currentIndex);
    });
  }
}
