import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';

final class ObtenirStatutSuivant {
  const ObtenirStatutSuivant();

  StatutIntervention? call(StatutIntervention statutActuel) {
    return statutActuel.suivant;
  }
}
