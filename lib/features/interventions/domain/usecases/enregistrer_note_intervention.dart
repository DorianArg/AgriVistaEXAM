import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/compte_rendu_repository.dart';

final class EnregistrerNoteIntervention {
  const EnregistrerNoteIntervention(this._repository);

  final CompteRenduRepository _repository;

  Future<CompteRenduIntervention> call({
    required String interventionId,
    required String note,
  }) {
    return _repository.enregistrerNote(interventionId, note);
  }
}
