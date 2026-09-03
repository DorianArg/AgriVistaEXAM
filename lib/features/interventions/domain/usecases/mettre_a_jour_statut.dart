import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_statut_suivant.dart';

final class MettreAJourStatut {
  const MettreAJourStatut(
    this._repository, [
    this._obtenirStatutSuivant = const ObtenirStatutSuivant(),
  ]);

  final InterventionRepository _repository;
  final ObtenirStatutSuivant _obtenirStatutSuivant;

  Future<StatutIntervention> call({
    required String interventionId,
    required StatutIntervention statutActuel,
  }) async {
    final nouveauStatut = _obtenirStatutSuivant(statutActuel);
    if (nouveauStatut == null) {
      throw const InvalidStatusTransitionFailure();
    }

    await _repository.mettreAJourStatut(interventionId, nouveauStatut);
    return nouveauStatut;
  }
}
