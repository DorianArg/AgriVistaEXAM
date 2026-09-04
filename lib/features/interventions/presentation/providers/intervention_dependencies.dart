import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/mettre_a_jour_statut.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final interventionRepositoryProvider = Provider<InterventionRepository>((ref) {
  throw StateError(
    'interventionRepositoryProvider doit être remplacé au démarrage.',
  );
});

final obtenirInterventionsProvider = Provider((ref) {
  return ObtenirInterventions(ref.watch(interventionRepositoryProvider));
});

final mettreAJourStatutProvider = Provider((ref) {
  return MettreAJourStatut(ref.watch(interventionRepositoryProvider));
});
