import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/interventions_page.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:agrivista_field/features/interventions/presentation/widgets/intervention_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche le refresh et le tri par date croissante par défaut', (
    tester,
  ) async {
    final context = await _pumpPage(tester, _SequenceRepository([_data()]));
    addTearDown(context.dispose);

    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.text('Tri :'), findsOneWidget);
    expect(find.text('Date prévue'), findsOneWidget);
    expect(find.byTooltip('Ordre croissant'), findsOneWidget);
    expect(_firstVisibleIntervention(tester), 'early');
  });

  testWidgets('sélectionne le tri par priorité et réordonne la liste', (
    tester,
  ) async {
    final context = await _pumpPage(tester, _SequenceRepository([_data()]));
    addTearDown(context.dispose);

    await _selectSort(tester, 'Priorité');

    expect(
      context.read(interventionFiltersProvider).tri,
      InterventionSort.priorite,
    );
    expect(_firstVisibleIntervention(tester), 'late-high');
  });

  testWidgets('sélectionne le tri par statut et réordonne la liste', (
    tester,
  ) async {
    final context = await _pumpPage(tester, _SequenceRepository([_data()]));
    addTearDown(context.dispose);

    await _selectSort(tester, 'Statut');

    expect(
      context.read(interventionFiltersProvider).tri,
      InterventionSort.statut,
    );
    expect(_firstVisibleIntervention(tester), 'late-high');
  });

  testWidgets('permet de revenir au tri Date prévue', (tester) async {
    final context = await _pumpPage(tester, _SequenceRepository([_data()]));
    addTearDown(context.dispose);
    await _selectSort(tester, 'Priorité');

    await _selectSort(tester, 'Date prévue');

    expect(
      context.read(interventionFiltersProvider).tri,
      InterventionSort.datePrevue,
    );
    expect(_firstVisibleIntervention(tester), 'early');
  });

  testWidgets('inverse l ordre du tri affiché', (tester) async {
    final context = await _pumpPage(tester, _SequenceRepository([_data()]));
    addTearDown(context.dispose);

    await tester.tap(find.byKey(const Key('intervention-sort-direction')));
    await tester.pumpAndSettle();

    expect(
      context.read(interventionFiltersProvider).direction,
      SortDirection.descending,
    );
    expect(find.byTooltip('Ordre décroissant'), findsOneWidget);
    expect(_firstVisibleIntervention(tester), 'late-high');
  });

  testWidgets('pull-to-refresh affiche les nouvelles données', (tester) async {
    final repository = _SequenceRepository([
      _data(singleStation: 'Ancienne station'),
      _data(singleStation: 'Nouvelle station'),
    ]);
    final context = await _pumpPage(tester, repository);
    addTearDown(context.dispose);

    await _showRefresh(tester);

    expect(repository.readCount, 2);
    expect(find.text('Nouvelle station'), findsOneWidget);
    expect(find.text('Ancienne station'), findsNothing);
  });

  testWidgets('refresh échoué garde la liste et affiche un SnackBar', (
    tester,
  ) async {
    final repository = _SequenceRepository([
      _data(singleStation: 'Station conservée'),
      const NetworkFailure(),
    ]);
    final context = await _pumpPage(tester, repository);
    addTearDown(context.dispose);

    await _showRefresh(tester);

    expect(find.text('Station conservée'), findsOneWidget);
    expect(
      find.text('Impossible d’actualiser les interventions.'),
      findsOneWidget,
    );
  });

  testWidgets('refresh conserve recherche, filtres et tri', (tester) async {
    final repository = _SequenceRepository([_data(), _data()]);
    final context = await _pumpPage(tester, repository);
    addTearDown(context.dispose);
    final notifier = context.read(interventionFiltersProvider.notifier);
    notifier.rechercher('Station');
    notifier.filtrerParStatut(StatutFilter.enCours);
    notifier.filtrerParPriorite(PrioriteFilter.moyenne);
    notifier.trierPar(InterventionSort.statut);
    notifier.inverserOrdre();
    await tester.pump();

    await _showRefresh(tester);

    final filters = context.read(interventionFiltersProvider);
    expect(filters.recherche, 'Station');
    expect(filters.statut, StatutFilter.enCours);
    expect(filters.priorite, PrioriteFilter.moyenne);
    expect(filters.tri, InterventionSort.statut);
    expect(filters.direction, SortDirection.descending);
  });
}

Future<ProviderContainer> _pumpPage(
  WidgetTester tester,
  InterventionRepository repository,
) async {
  final container = ProviderContainer(
    overrides: [
      obtenirInterventionsProvider.overrideWithValue(
        ObtenirInterventions(repository),
      ),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: InterventionsPage())),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _selectSort(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const Key('intervention-sort-menu')));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

Future<void> _showRefresh(WidgetTester tester) async {
  final refresh = tester
      .state<RefreshIndicatorState>(find.byType(RefreshIndicator))
      .show();
  await tester.pumpAndSettle();
  await refresh;
}

String _firstVisibleIntervention(WidgetTester tester) {
  return tester
      .widgetList<InterventionCard>(find.byType(InterventionCard))
      .first
      .intervention
      .id;
}

DonneesInterventions _data({String? singleStation}) {
  return DonneesInterventions(
    technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
    interventions: singleStation == null
        ? [
            _intervention(
              'late-high',
              'Station Haute',
              day: 20,
              priorite: Priorite.haute,
              statut: StatutIntervention.planifiee,
            ),
            _intervention(
              'early',
              'Station Basse',
              day: 5,
              priorite: Priorite.basse,
              statut: StatutIntervention.terminee,
            ),
            _intervention(
              'middle',
              'Station Moyenne',
              day: 12,
              priorite: Priorite.moyenne,
              statut: StatutIntervention.enCours,
            ),
          ]
        : [
            _intervention(
              'single',
              singleStation,
              day: 10,
              priorite: Priorite.haute,
              statut: StatutIntervention.planifiee,
            ),
          ],
  );
}

Intervention _intervention(
  String id,
  String station, {
  required int day,
  required Priorite priorite,
  required StatutIntervention statut,
}) {
  return Intervention(
    id: id,
    station: station,
    domaine: 'Domaine $id',
    latitude: 42,
    longitude: 9,
    priorite: priorite,
    statut: statut,
    datePrevue: DateTime(2026, 6, day),
    description: 'Intervention $id',
    historique: const [],
  );
}

final class _SequenceRepository implements InterventionRepository {
  _SequenceRepository(this.results);

  final List<Object> results;
  int readCount = 0;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    final result = results[readCount++];
    if (result case final AppFailure failure) {
      throw failure;
    }
    return result as DonneesInterventions;
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}
