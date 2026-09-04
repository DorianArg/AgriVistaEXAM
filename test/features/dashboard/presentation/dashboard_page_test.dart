import 'dart:async';

import 'package:agrivista_field/app/app_shell.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'affiche le technicien, les compteurs et les trois destinations',
    (tester) async {
      final context = await _pumpApp(tester);
      addTearDown(context.container.dispose);

      expect(find.text('Bonjour Marie'), findsOneWidget);
      expect(find.byKey(const Key('dashboard-total')), findsOneWidget);
      expect(find.text('Planifiées'), findsOneWidget);
      expect(find.text('En cours'), findsOneWidget);
      expect(find.text('Terminées'), findsOneWidget);
      expect(find.text('Haute'), findsOneWidget);
      expect(find.text('Moyenne'), findsOneWidget);
      expect(find.text('Basse'), findsOneWidget);

      final navigationBar = tester.widget<NavigationBar>(
        find.byType(NavigationBar),
      );
      expect(
        navigationBar.destinations.cast<NavigationDestination>().map(
          (destination) => destination.label,
        ),
        ['Dashboard', 'Interventions', 'Profil'],
      );
    },
  );

  testWidgets('un clic Planifiées ouvre la liste avec ce seul filtre', (
    tester,
  ) async {
    final context = await _pumpApp(tester);
    addTearDown(context.container.dispose);
    final notifier = context.container.read(
      interventionFiltersProvider.notifier,
    );
    notifier.rechercher('ancienne recherche');
    notifier.filtrerParPriorite(PrioriteFilter.haute);
    await tester.pump();

    await _tapMetric(tester, 'dashboard-planifiees');

    final filters = context.container.read(interventionFiltersProvider);
    expect(filters.recherche, isEmpty);
    expect(filters.statut, StatutFilter.planifiee);
    expect(filters.priorite, PrioriteFilter.toutes);
    expect(find.text('Station planifiée'), findsOneWidget);
    expect(find.text('Station en cours'), findsNothing);
  });

  testWidgets('un clic En cours ouvre la liste avec ce seul filtre', (
    tester,
  ) async {
    final context = await _pumpApp(tester);
    addTearDown(context.container.dispose);

    await _tapMetric(tester, 'dashboard-en-cours');

    final filters = context.container.read(interventionFiltersProvider);
    expect(filters.statut, StatutFilter.enCours);
    expect(find.text('Station en cours'), findsOneWidget);
    expect(find.text('Station planifiée'), findsNothing);
  });

  testWidgets('un clic Terminées ouvre la liste avec ce seul filtre', (
    tester,
  ) async {
    final context = await _pumpApp(tester);
    addTearDown(context.container.dispose);

    await _tapMetric(tester, 'dashboard-terminees');

    final filters = context.container.read(interventionFiltersProvider);
    expect(filters.statut, StatutFilter.terminee);
    expect(find.text('Station terminée'), findsOneWidget);
    expect(find.text('Station planifiée'), findsNothing);
  });

  testWidgets('un clic Haute applique uniquement la priorité haute', (
    tester,
  ) async {
    final context = await _pumpApp(tester);
    addTearDown(context.container.dispose);
    final notifier = context.container.read(
      interventionFiltersProvider.notifier,
    );
    notifier.rechercher('ancienne recherche');
    notifier.filtrerParStatut(StatutFilter.terminee);
    await tester.pump();

    await _tapMetric(tester, 'dashboard-priorite-haute');

    final filters = context.container.read(interventionFiltersProvider);
    expect(filters.recherche, isEmpty);
    expect(filters.statut, StatutFilter.tous);
    expect(filters.priorite, PrioriteFilter.haute);
    expect(find.text('Station planifiée'), findsOneWidget);
    expect(find.text('Station en cours'), findsNothing);
  });

  testWidgets('affiche les zéros et un message lorsque la liste est vide', (
    tester,
  ) async {
    final context = await _pumpApp(
      tester,
      data: _data(interventions: const []),
    );
    addTearDown(context.container.dispose);

    expect(find.text('Aucune intervention disponible.'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(7));
  });

  testWidgets('affiche le loading du flux global', (tester) async {
    final repository = _ControlledRepository(_data());
    final context = _mountApp(tester, repository);
    addTearDown(context.container.dispose);

    await context.pump;
    await tester.pump();

    expect(find.text('Chargement du tableau de bord…'), findsOneWidget);
    repository.result.complete(repository.data);
  });

  testWidgets('Réessayer relance le notifier existant après une erreur', (
    tester,
  ) async {
    final repository = _RetryRepository(_data());
    final context = _mountApp(tester, repository);
    addTearDown(context.container.dispose);
    await context.pump;
    await tester.pumpAndSettle();

    expect(find.text('Réessayer'), findsOneWidget);
    await tester.tap(find.text('Réessayer'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Marie'), findsOneWidget);
    expect(repository.readCount, 2);
  });

  testWidgets('le dashboard reflète un statut modifié depuis le détail', (
    tester,
  ) async {
    final context = await _pumpApp(
      tester,
      data: _data(
        interventions: [
          _intervention(
            'itv-planifiee',
            'Station planifiée',
            StatutIntervention.planifiee,
            Priorite.haute,
          ),
        ],
      ),
    );
    addTearDown(context.container.dispose);

    expect(_metricValue(tester, 'dashboard-planifiees'), '1');
    expect(_metricValue(tester, 'dashboard-en-cours'), '0');

    await tester.tap(find.text('Interventions').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Station planifiée'));
    await tester.pumpAndSettle();
    final startButton = find.text('Démarrer l’intervention');
    await tester.ensureVisible(startButton);
    await tester.pumpAndSettle();
    await tester.tap(startButton);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(_metricValue(tester, 'dashboard-planifiees'), '0');
    expect(_metricValue(tester, 'dashboard-en-cours'), '1');
  });
}

Future<_WidgetContext> _pumpApp(
  WidgetTester tester, {
  DonneesInterventions? data,
}) async {
  final repository = _FakeRepository(data ?? _data());
  final context = _mountApp(tester, repository);
  await context.pump;
  await tester.pumpAndSettle();
  return context;
}

_WidgetContext _mountApp(
  WidgetTester tester,
  InterventionRepository repository,
) {
  final container = ProviderContainer(
    overrides: [
      obtenirInterventionsProvider.overrideWithValue(
        ObtenirInterventions(repository),
      ),
      mettreAJourStatutProvider.overrideWithValue(
        MettreAJourStatut(repository),
      ),
    ],
  );
  final pump = tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    ),
  );
  return _WidgetContext(container, pump);
}

Future<void> _tapMetric(WidgetTester tester, String key) async {
  final card = find.byKey(Key(key));
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(of: card, matching: find.byType(InkWell)));
  await tester.pumpAndSettle();
}

String _metricValue(WidgetTester tester, String key) {
  return tester
      .widgetList<Text>(
        find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text)),
      )
      .first
      .data!;
}

DonneesInterventions _data({List<Intervention>? interventions}) {
  return DonneesInterventions(
    technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
    interventions:
        interventions ??
        [
          _intervention(
            'itv-planifiee',
            'Station planifiée',
            StatutIntervention.planifiee,
            Priorite.haute,
          ),
          _intervention(
            'itv-en-cours',
            'Station en cours',
            StatutIntervention.enCours,
            Priorite.moyenne,
          ),
          _intervention(
            'itv-terminee',
            'Station terminée',
            StatutIntervention.terminee,
            Priorite.basse,
          ),
        ],
  );
}

Intervention _intervention(
  String id,
  String station,
  StatutIntervention statut,
  Priorite priorite,
) {
  return Intervention(
    id: id,
    station: station,
    domaine: 'Domaine test',
    latitude: 42,
    longitude: 9,
    priorite: priorite,
    statut: statut,
    datePrevue: DateTime(2026, 6, 15),
    description: 'Intervention de test',
    historique: const [],
  );
}

final class _WidgetContext {
  const _WidgetContext(this.container, this.pump);

  final ProviderContainer container;
  final Future<void> pump;
}

final class _FakeRepository implements InterventionRepository {
  const _FakeRepository(this.data);

  final DonneesInterventions data;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async => data;

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}

final class _ControlledRepository implements InterventionRepository {
  _ControlledRepository(this.data);

  final DonneesInterventions data;
  final Completer<DonneesInterventions> result = Completer();

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() => result.future;

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}

final class _RetryRepository implements InterventionRepository {
  _RetryRepository(this.data);

  final DonneesInterventions data;
  int readCount = 0;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    readCount++;
    if (readCount == 1) {
      throw const NetworkFailure();
    }
    return data;
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}
