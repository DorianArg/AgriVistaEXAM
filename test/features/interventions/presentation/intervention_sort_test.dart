import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final interventions = [
    _intervention(
      'a',
      station: 'Patrimonio Alpha',
      day: 20,
      priorite: Priorite.haute,
      statut: StatutIntervention.planifiee,
    ),
    _intervention(
      'b',
      station: 'Station Beta',
      day: 10,
      priorite: Priorite.basse,
      statut: StatutIntervention.terminee,
    ),
    _intervention(
      'c',
      station: 'Station Centre',
      day: 15,
      priorite: Priorite.moyenne,
      statut: StatutIntervention.enCours,
    ),
    _intervention(
      'd',
      station: 'Patrimonio Delta',
      day: 5,
      priorite: Priorite.haute,
      statut: StatutIntervention.enCours,
    ),
    _intervention(
      'e',
      station: 'Patrimonio Est',
      day: 12,
      priorite: Priorite.haute,
      statut: StatutIntervention.enCours,
    ),
  ];

  test('trie par date croissante', () {
    expect(_ids(interventions), ['d', 'b', 'e', 'c', 'a']);
  });

  test('trie par date décroissante', () {
    expect(_ids(interventions, direction: SortDirection.descending), [
      'a',
      'c',
      'e',
      'b',
      'd',
    ]);
  });

  test('trie les priorités Haute puis Moyenne puis Basse', () {
    expect(_ids(interventions, tri: InterventionSort.priorite), [
      'a',
      'd',
      'e',
      'c',
      'b',
    ]);
  });

  test('trie les priorités dans l ordre inverse', () {
    expect(
      _ids(
        interventions,
        tri: InterventionSort.priorite,
        direction: SortDirection.descending,
      ),
      ['b', 'c', 'a', 'd', 'e'],
    );
  });

  test('trie les statuts selon le cycle métier', () {
    expect(_ids(interventions, tri: InterventionSort.statut), [
      'a',
      'c',
      'd',
      'e',
      'b',
    ]);
  });

  test('trie les statuts dans l ordre inverse', () {
    expect(
      _ids(
        interventions,
        tri: InterventionSort.statut,
        direction: SortDirection.descending,
      ),
      ['b', 'c', 'd', 'e', 'a'],
    );
  });

  test('applique le tri après la recherche', () {
    expect(_ids(interventions, recherche: 'Patrimonio'), ['d', 'e', 'a']);
  });

  test('applique le tri après le filtre de statut', () {
    expect(_ids(interventions, statut: StatutFilter.enCours), ['d', 'e', 'c']);
  });

  test('applique le tri après le filtre de priorité', () {
    expect(_ids(interventions, priorite: PrioriteFilter.haute), [
      'd',
      'e',
      'a',
    ]);
  });

  test('combine recherche, statut, priorité et tri', () {
    expect(
      _ids(
        interventions,
        recherche: 'Patrimonio',
        statut: StatutFilter.enCours,
        priorite: PrioriteFilter.haute,
        direction: SortDirection.descending,
      ),
      ['e', 'd'],
    );
  });

  test('le filtre venant du dashboard conserve le tri courant', () {
    final container = ProviderContainer.test();
    addTearDown(container.dispose);
    final notifier = container.read(interventionFiltersProvider.notifier);
    notifier.rechercher('ancienne recherche');
    notifier.filtrerParPriorite(PrioriteFilter.basse);
    notifier.trierPar(InterventionSort.statut);
    notifier.inverserOrdre();

    notifier.appliquerStatutDepuisDashboard(StatutFilter.planifiee);
    final filters = container.read(interventionFiltersProvider);

    expect(filters.recherche, isEmpty);
    expect(filters.statut, StatutFilter.planifiee);
    expect(filters.priorite, PrioriteFilter.toutes);
    expect(filters.tri, InterventionSort.statut);
    expect(filters.direction, SortDirection.descending);
  });
}

List<String> _ids(
  List<Intervention> interventions, {
  String recherche = '',
  StatutFilter statut = StatutFilter.tous,
  PrioriteFilter priorite = PrioriteFilter.toutes,
  InterventionSort tri = InterventionSort.datePrevue,
  SortDirection direction = SortDirection.ascending,
}) {
  return filtrerInterventions(
    interventions,
    InterventionFilters(
      recherche: recherche,
      statut: statut,
      priorite: priorite,
      tri: tri,
      direction: direction,
    ),
  ).map((item) => item.id).toList();
}

Intervention _intervention(
  String id, {
  required String station,
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
