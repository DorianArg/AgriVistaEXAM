import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final interventionsProvider =
    AsyncNotifierProvider<InterventionsNotifier, DonneesInterventions>(
      InterventionsNotifier.new,
    );

final class InterventionsNotifier extends AsyncNotifier<DonneesInterventions> {
  @override
  Future<DonneesInterventions> build() {
    return ref.watch(obtenirInterventionsProvider)();
  }

  Future<void> recharger() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(obtenirInterventionsProvider)(),
    );
  }

  Future<StatutIntervention> mettreAJourStatut(String interventionId) async {
    final donneesActuelles = state.requireValue;
    final intervention = donneesActuelles.interventions.firstWhere(
      (item) => item.id == interventionId,
    );

    final nouveauStatut = await ref.read(mettreAJourStatutProvider)(
      interventionId: interventionId,
      statutActuel: intervention.statut,
    );

    state = AsyncData(
      DonneesInterventions(
        technicien: donneesActuelles.technicien,
        interventions: donneesActuelles.interventions.map((item) {
          return item.id == interventionId
              ? item.avecStatut(nouveauStatut)
              : item;
        }).toList(),
      ),
    );

    return nouveauStatut;
  }
}
