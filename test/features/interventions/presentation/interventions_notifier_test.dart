import 'dart:async';

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
    expect(context.repository.readCount, 1);
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

  test('recharger passe de error à loading puis data', () async {
    final repository = _RetryRepository(_data(StatutIntervention.planifiee));
    final container = ProviderContainer.test(
      overrides: [
        obtenirInterventionsProvider.overrideWithValue(
          ObtenirInterventions(repository),
        ),
      ],
    );

    await expectLater(
      container.read(interventionsProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
    expect(container.read(interventionsProvider).hasError, isTrue);

    final retry = container.read(interventionsProvider.notifier).recharger();
    expect(container.read(interventionsProvider).isLoading, isTrue);

    repository.retryResult.complete(repository.data);
    await retry;

    expect(container.read(interventionsProvider).hasValue, isTrue);
    expect(container.read(interventionsProvider).requireValue, repository.data);
    expect(repository.readCount, 2);
  });

  test(
    'refresh conserve les données visibles puis expose les nouvelles',
    () async {
      final initialData = _data(StatutIntervention.planifiee);
      final refreshedData = _data(StatutIntervention.terminee);
      final repository = _RefreshRepository(initialData);
      final container = ProviderContainer.test(
        overrides: [
          obtenirInterventionsProvider.overrideWithValue(
            ObtenirInterventions(repository),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(interventionsProvider.future);

      final refresh = container
          .read(interventionsProvider.notifier)
          .recharger();

      expect(repository.readCount, 2);
      expect(container.read(interventionsProvider).requireValue, initialData);
      repository.refreshResult.complete(refreshedData);
      expect(await refresh, isTrue);
      expect(
        container
            .read(interventionsProvider)
            .requireValue
            .interventions
            .single
            .statut,
        StatutIntervention.terminee,
      );
    },
  );

  test(
    'refresh échoué conserve les données et les critères d affichage',
    () async {
      final initialData = _data(StatutIntervention.enCours);
      final repository = _FailedRefreshRepository(initialData);
      final container = ProviderContainer.test(
        overrides: [
          obtenirInterventionsProvider.overrideWithValue(
            ObtenirInterventions(repository),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(interventionsProvider.future);
      final filtersNotifier = container.read(
        interventionFiltersProvider.notifier,
      );
      filtersNotifier.rechercher('Patrimonio');
      filtersNotifier.filtrerParStatut(StatutFilter.enCours);
      filtersNotifier.filtrerParPriorite(PrioriteFilter.haute);
      filtersNotifier.trierPar(InterventionSort.statut);
      filtersNotifier.inverserOrdre();

      final succeeded = await container
          .read(interventionsProvider.notifier)
          .recharger();

      expect(succeeded, isFalse);
      expect(container.read(interventionsProvider).hasValue, isTrue);
      expect(container.read(interventionsProvider).requireValue, initialData);
      final filters = container.read(interventionFiltersProvider);
      expect(filters.recherche, 'Patrimonio');
      expect(filters.statut, StatutFilter.enCours);
      expect(filters.priorite, PrioriteFilter.haute);
      expect(filters.tri, InterventionSort.statut);
      expect(filters.direction, SortDirection.descending);
    },
  );

  test('réordonne la liste triée par statut après une progression', () async {
    final repository = _FakeRepository(initialData: _statusSortData());
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
    addTearDown(container.dispose);
    await container.read(interventionsProvider.future);
    const filters = InterventionFilters(tri: InterventionSort.statut);

    await container
        .read(interventionsProvider.notifier)
        .mettreAJourStatut('itv-1');
    final sorted = filtrerInterventions(
      container.read(interventionsProvider).requireValue.interventions,
      filters,
    );

    expect(sorted.map((item) => item.id), ['itv-2', 'itv-1']);
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

DonneesInterventions _statusSortData() {
  return DonneesInterventions(
    technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
    interventions: [
      Intervention(
        id: 'itv-1',
        station: 'Station 1',
        domaine: 'Domaine 1',
        latitude: 42,
        longitude: 9,
        priorite: Priorite.haute,
        statut: StatutIntervention.planifiee,
        datePrevue: DateTime(2026, 6, 15),
        description: 'Intervention 1',
        historique: const [],
      ),
      Intervention(
        id: 'itv-2',
        station: 'Station 2',
        domaine: 'Domaine 2',
        latitude: 42,
        longitude: 9,
        priorite: Priorite.moyenne,
        statut: StatutIntervention.planifiee,
        datePrevue: DateTime(2026, 6, 16),
        description: 'Intervention 2',
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
  int readCount = 0;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    readCount++;
    return initialData;
  }

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

final class _RetryRepository implements InterventionRepository {
  _RetryRepository(this.data);

  final DonneesInterventions data;
  final Completer<DonneesInterventions> retryResult = Completer();
  int readCount = 0;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    readCount++;
    if (readCount == 1) {
      throw const NetworkFailure();
    }
    return retryResult.future;
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}

final class _RefreshRepository implements InterventionRepository {
  _RefreshRepository(this.initialData);

  final DonneesInterventions initialData;
  final Completer<DonneesInterventions> refreshResult = Completer();
  int readCount = 0;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    readCount++;
    if (readCount == 1) {
      return initialData;
    }
    return refreshResult.future;
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}

final class _FailedRefreshRepository implements InterventionRepository {
  _FailedRefreshRepository(this.initialData);

  final DonneesInterventions initialData;
  int readCount = 0;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    readCount++;
    if (readCount > 1) {
      throw const NetworkFailure();
    }
    return initialData;
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}
