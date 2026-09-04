import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/compte_rendu_dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PhotoSelectionResult { saved, cancelled, failed }

final compteRenduProvider =
    AsyncNotifierProvider.family<
      CompteRenduNotifier,
      CompteRenduIntervention,
      String
    >(CompteRenduNotifier.new, isAutoDispose: true, retry: (_, _) => null);

final class CompteRenduNotifier extends AsyncNotifier<CompteRenduIntervention> {
  CompteRenduNotifier(this.interventionId);

  final String interventionId;

  @override
  Future<CompteRenduIntervention> build() {
    return ref.watch(lireCompteRenduProvider)(interventionId);
  }

  Future<void> recharger() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(lireCompteRenduProvider)(interventionId),
    );
  }

  Future<bool> enregistrerNote(String note) async {
    final current = state.value;
    if (current == null) {
      return false;
    }
    try {
      final updated = await ref.read(enregistrerNoteInterventionProvider)(
        interventionId: interventionId,
        note: note,
      );
      state = AsyncData(updated);
      return true;
    } catch (_) {
      state = AsyncData(current);
      return false;
    }
  }

  Future<PhotoSelectionResult> choisirEtEnregistrerPhoto() async {
    final current = state.value;
    if (current == null) {
      return PhotoSelectionResult.failed;
    }
    try {
      final sourcePath = await ref
          .read(interventionPhotoPickerProvider)
          .choisirDepuisGalerie();
      if (sourcePath == null) {
        return PhotoSelectionResult.cancelled;
      }
      final updated = await ref.read(enregistrerPhotoInterventionProvider)(
        interventionId: interventionId,
        sourcePath: sourcePath,
      );
      state = AsyncData(updated);
      return PhotoSelectionResult.saved;
    } catch (_) {
      state = AsyncData(current);
      return PhotoSelectionResult.failed;
    }
  }
}
