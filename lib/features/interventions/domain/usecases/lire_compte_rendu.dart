import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/compte_rendu_repository.dart';

final class LireCompteRendu {
  const LireCompteRendu(this._repository);

  final CompteRenduRepository _repository;

  Future<CompteRenduIntervention> call(String interventionId) {
    return _repository.lire(interventionId);
  }
}
