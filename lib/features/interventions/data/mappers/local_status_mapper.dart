import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';

StatutIntervention statutInterventionFromStorage(String value) {
  return switch (value) {
    'planifiee' => StatutIntervention.planifiee,
    'en_cours' => StatutIntervention.enCours,
    'terminee' => StatutIntervention.terminee,
    _ => throw LocalStorageFailure('Statut local inconnu : $value.'),
  };
}

extension StatutInterventionStorageMapper on StatutIntervention {
  String toStorageValue() => switch (this) {
    StatutIntervention.planifiee => 'planifiee',
    StatutIntervention.enCours => 'en_cours',
    StatutIntervention.terminee => 'terminee',
  };
}
