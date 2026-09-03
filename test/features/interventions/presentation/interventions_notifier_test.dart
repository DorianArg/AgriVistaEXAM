import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/mettre_a_jour_statut.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('met à jour une intervention planifiée vers en cours', () async {
    final context = await _context(StatutIntervention.planifiee);
    final notifier = context.container.read(interventionsProvider.notifier);

    final result = await notifier.mettreAJourStatut('itv-1');

    expect(result, StatutIntervention.enCours);
    expect(_status(context.container), StatutIntervention.enCours);
    expect(context.repository.savedStatus, StatutIntervention.enCours);
  });

  test('met à jour une intervention en cours vers terminée', () async {
    final context = await _context(StatutIntervention.enCours);
    final notifier = context.container.read(interventionsProvider.notifier);

    final result = await notifier.mettreAJourStatut('itv-1');

    expect(result, StatutIntervention.terminee);
    expect(_status(context.container), StatutIntervention.terminee);
  });

  test('refuse une progression après terminée', () async {
    final context = await _context(StatutIntervention.terminee);
    final notifier = context.container.read(interventionsProvider.notifier);

    await expectLater(
      notifier.mettreAJourStatut('itv-1'),
      throwsA(isA<InvalidStatusTransitionFailure>()),
    );
    expect(_status(context.container), StatutIntervention.terminee);
    expect(context.repository.savedStatus, isNull);
  });

  test('conserve l état précédent lorsque l écriture échoue', () async {
    final context = await _context(
      StatutIntervention.planifiee,
      writeFailure: const LocalStorageFailure(),
    );
    final notifier = context.container.read(interventionsProvider.notifier);

    await expectLater(
      notifier.mettreAJourStatut('itv-1'),
      throwsA(isA<LocalStorageFailure>()),
    );
    expect(_status(context.container), StatutIntervention.planifiee);
  });

  test(
    'retrouve immédiatement l intervention mise à jour dans la liste',
    () async {
      final context = await _context(StatutIntervention.planifiee);

      await context.container
          .read(interventionsProvider.notifier)
          .mettreAJourStatut('itv-1');

      final intervention = context.container
          .read(interventionsProvider)
          .requireValue
          .interventions
          .singleWhere((item) => item.id == 'itv-1');
      expect(intervention.statut, StatutIntervention.enCours);
    },
  );

  test('recalcule le filtre après le changement de statut', () async {
    final context = await _context(StatutIntervention.planifiee);
    const planifiees = InterventionFilters(statut: StatutFilter.planifiee);
    final before = filtrerInterventions(
      context.container.read(interventionsProvider).requireValue.interventions,
      planifiees,
    );

    await context.container
        .read(interventionsProvider.notifier)
        .mettreAJourStatut('itv-1');
    final after = filtrerInterventions(
      context.container.read(interventionsProvider).requireValue.interventions,
      planifiees,
    );

    expect(before, hasLength(1));
    expect(after, isEmpty);
  });
}

Future<_TestContext> _context(
  StatutIntervention initialStatus, {
  AppFailure? writeFailure,
}) async {
  final repository = _FakeRepository(
    initialData: _data(initialStatus),
    writeFailure: writeFailure,
  );
  final container = ProviderContainer.test(
    overrides: [
      obtenirInterventionsProvider.overrideWithValue(
        ObtenirInterventions(repository),
      ),
      mettreAJourStatutProvider.overrideWithValue(
        MettreAJourStatut(repository),
      ),
    ],
  );
  await container.read(interventionsProvider.future);
  return _TestContext(container, repository);
}

StatutIntervention _status(ProviderContainer container) {
  return container
      .read(interventionsProvider)
      .requireValue
      .interventions
      .single
      .statut;
}

DonneesInterventions _data(StatutIntervention status) {
  return DonneesInterventions(
    technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
    interventions: [
      Intervention(
        id: 'itv-1',
        station: 'Station Nord',
        domaine: 'Vignoble Patrimonio',
        latitude: 42.703,
        longitude: 9.347,
        priorite: Priorite.haute,
        statut: status,
        datePrevue: DateTime(2026, 6, 15),
        description: 'Remplacement du capteur.',
        historique: const [],
      ),
    ],
  );
}

final class _TestContext {
  const _TestContext(this.container, this.repository);

  final ProviderContainer container;
  final _FakeRepository repository;
}

final class _FakeRepository implements InterventionRepository {
  _FakeRepository({required this.initialData, this.writeFailure});

  final DonneesInterventions initialData;
  final AppFailure? writeFailure;
  StatutIntervention? savedStatus;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async => initialData;

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {
    final failure = writeFailure;
    if (failure != null) {
      throw failure;
    }
    savedStatus = statut;
  }
}
