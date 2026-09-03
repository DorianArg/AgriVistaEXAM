import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';

final class ObtenirInterventions {
  const ObtenirInterventions(this._repository);

  final InterventionRepository _repository;

  Future<DonneesInterventions> call() {
    return _repository.recupererDonneesInitiales();
  }
}
