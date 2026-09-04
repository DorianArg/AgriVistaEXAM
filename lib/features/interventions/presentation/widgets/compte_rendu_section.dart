import 'dart:io';

import 'package:agrivista_field/core/widgets/async_state_views.dart';
import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/compte_rendu_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef LocalPhotoBuilder = Widget Function(BuildContext context, String path);

final class CompteRenduSection extends ConsumerWidget {
  const CompteRenduSection({
    required this.interventionId,
    this.photoBuilder,
    super.key,
  });

  final String interventionId;
  final LocalPhotoBuilder? photoBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(compteRenduProvider(interventionId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compte rendu terrain',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: state.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => _CompteRenduError(
                error: error,
                onRetry: () => ref
                    .read(compteRenduProvider(interventionId).notifier)
                    .recharger(),
              ),
              data: (compteRendu) => _CompteRenduForm(
                key: ValueKey(interventionId),
                compteRendu: compteRendu,
                photoBuilder: photoBuilder,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class _CompteRenduError extends StatelessWidget {
  const _CompteRenduError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 8),
        Text(messageForFailure(error), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer le chargement'),
        ),
      ],
    );
  }
}

final class _CompteRenduForm extends ConsumerStatefulWidget {
  const _CompteRenduForm({
    required this.compteRendu,
    this.photoBuilder,
    super.key,
  });

  final CompteRenduIntervention compteRendu;
  final LocalPhotoBuilder? photoBuilder;

  @override
  ConsumerState<_CompteRenduForm> createState() => _CompteRenduFormState();
}

final class _CompteRenduFormState extends ConsumerState<_CompteRenduForm> {
  late final TextEditingController _noteController;
  bool _isSavingNote = false;
  bool _isSavingPhoto = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.compteRendu.note);
  }

  @override
  void didUpdateWidget(covariant _CompteRenduForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.compteRendu.note != widget.compteRendu.note &&
        _noteController.text != widget.compteRendu.note) {
      _noteController.value = TextEditingValue(
        text: widget.compteRendu.note,
        selection: TextSelection.collapsed(
          offset: widget.compteRendu.note.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photoPath = widget.compteRendu.photoPath;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          key: const Key('intervention-note-field'),
          controller: _noteController,
          minLines: 3,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Ajouter une note terrain…',
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            key: const Key('save-intervention-note'),
            onPressed: _isSavingNote ? null : _saveNote,
            icon: _isSavingNote
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Enregistrer la note'),
          ),
        ),
        const SizedBox(height: 20),
        Text('Photo', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (photoPath == null)
          const _NoPhoto()
        else
          _PhotoPreview(
            photoPath: photoPath,
            photoBuilder: widget.photoBuilder,
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const Key('select-intervention-photo'),
            onPressed: _isSavingPhoto ? null : _selectPhoto,
            icon: _isSavingPhoto
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
            label: Text(
              photoPath == null ? 'Ajouter une photo' : 'Remplacer la photo',
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveNote() async {
    setState(() => _isSavingNote = true);
    final succeeded = await ref
        .read(compteRenduProvider(widget.compteRendu.interventionId).notifier)
        .enregistrerNote(_noteController.text);
    if (!mounted) {
      return;
    }
    setState(() => _isSavingNote = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          succeeded
              ? 'Note enregistrée localement.'
              : 'Impossible d’enregistrer la note.',
        ),
      ),
    );
  }

  Future<void> _selectPhoto() async {
    setState(() => _isSavingPhoto = true);
    final result = await ref
        .read(compteRenduProvider(widget.compteRendu.interventionId).notifier)
        .choisirEtEnregistrerPhoto();
    if (!mounted) {
      return;
    }
    setState(() => _isSavingPhoto = false);
    if (result == PhotoSelectionResult.cancelled) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result == PhotoSelectionResult.saved
              ? 'Photo enregistrée localement.'
              : 'Impossible d’enregistrer la photo.',
        ),
      ),
    );
  }
}

final class _NoPhoto extends StatelessWidget {
  const _NoPhoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.image_not_supported_outlined),
          SizedBox(height: 8),
          Text('Aucune photo'),
        ],
      ),
    );
  }
}

final class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.photoPath, this.photoBuilder});

  final String photoPath;
  final LocalPhotoBuilder? photoBuilder;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Photo du compte rendu terrain',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          key: const Key('intervention-photo-preview'),
          aspectRatio: 16 / 9,
          child:
              photoBuilder?.call(context, photoPath) ??
              Image.file(
                File(photoPath),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const Center(
                    child: Text('Photo locale indisponible.'),
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
