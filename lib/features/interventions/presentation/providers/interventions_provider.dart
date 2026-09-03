import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
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
}
