import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';

abstract interface class InterventionRepository {
  Future<DonneesInterventions> recupererDonneesInitiales();

  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  );
}
