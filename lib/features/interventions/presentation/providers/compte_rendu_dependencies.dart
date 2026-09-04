import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_picker.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/compte_rendu_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/enregistrer_note_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/enregistrer_photo_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/lire_compte_rendu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final compteRenduRepositoryProvider = Provider<CompteRenduRepository>((ref) {
  throw StateError(
    'compteRenduRepositoryProvider doit être remplacé au démarrage.',
  );
});

final interventionPhotoPickerProvider = Provider<InterventionPhotoPicker>((
  ref,
) {
  throw StateError(
    'interventionPhotoPickerProvider doit être remplacé au démarrage.',
  );
});

final lireCompteRenduProvider = Provider((ref) {
  return LireCompteRendu(ref.watch(compteRenduRepositoryProvider));
});

final enregistrerNoteInterventionProvider = Provider((ref) {
  return EnregistrerNoteIntervention(ref.watch(compteRenduRepositoryProvider));
});

final enregistrerPhotoInterventionProvider = Provider((ref) {
  return EnregistrerPhotoIntervention(ref.watch(compteRenduRepositoryProvider));
});
