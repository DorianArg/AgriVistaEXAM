import 'package:agrivista_field/features/interventions/domain/entities/action_historique.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final interventions = [
    _intervention(
      id: '1',
      station: 'Station Nord',
      domaine: 'Vignoble Patrimonio',
      description: 'Remplacement du capteur',
      statut: StatutIntervention.planifiee,
      priorite: Priorite.haute,
    ),
    _intervention(
      id: '2',
      station: 'Station Ouest',
      domaine: 'Clos de Calvi',
      description: 'Calibration de température',
      statut: StatutIntervention.enCours,
      priorite: Priorite.moyenne,
    ),
    _intervention(
      id: '3',
      station: 'Station Sud',
      domaine: 'Domaine de Sartene',
      description: 'Nettoyage du panneau solaire',
      statut: StatutIntervention.terminee,
      priorite: Priorite.basse,
    ),
    _intervention(
      id: '4',
      station: 'Station Est',
      domaine: 'Coteaux du Cap Corse',
      description: 'Réparation du boîtier',
      statut: StatutIntervention.planifiee,
      priorite: Priorite.moyenne,
    ),
  ];

  test('recherche par station', () {
    expect(_ids(interventions, recherche: 'Sud'), ['3']);
  });

  test('recherche par domaine', () {
    expect(_ids(interventions, recherche: 'Patrimonio'), ['1']);
  });

  test('recherche par description', () {
    expect(_ids(interventions, recherche: 'panneau solaire'), ['3']);
  });

  test('recherche insensible à la casse', () {
    expect(_ids(interventions, recherche: 'sTaTiOn NoRd'), ['1']);
  });

  test('filtre les interventions planifiées', () {
    expect(_ids(interventions, statut: StatutFilter.planifiee), ['1', '4']);
  });

  test('filtre les interventions en cours', () {
    expect(_ids(interventions, statut: StatutFilter.enCours), ['2']);
  });

  test('filtre les interventions terminées', () {
    expect(_ids(interventions, statut: StatutFilter.terminee), ['3']);
  });

  test('filtre les priorités hautes', () {
    expect(_ids(interventions, priorite: PrioriteFilter.haute), ['1']);
  });

  test('filtre les priorités moyennes', () {
    expect(_ids(interventions, priorite: PrioriteFilter.moyenne), ['2', '4']);
  });

  test('filtre les priorités basses', () {
    expect(_ids(interventions, priorite: PrioriteFilter.basse), ['3']);
  });

  test('combine recherche et statut', () {
    expect(
      _ids(interventions, recherche: 'station', statut: StatutFilter.enCours),
      ['2'],
    );
  });

  test('combine statut et priorité', () {
    expect(
      _ids(
        interventions,
        statut: StatutFilter.planifiee,
        priorite: PrioriteFilter.moyenne,
      ),
      ['4'],
    );
  });

  test('retourne une liste vide sans résultat', () {
    expect(_ids(interventions, recherche: 'introuvable'), isEmpty);
  });

  test('retourne toutes les interventions avec des critères vides', () {
    expect(_ids(interventions), ['1', '2', '3', '4']);
  });
}

List<String> _ids(
  List<Intervention> interventions, {
  String recherche = '',
  StatutFilter statut = StatutFilter.tous,
  PrioriteFilter priorite = PrioriteFilter.toutes,
}) {
  return filtrerInterventions(
    interventions,
    InterventionFilters(
      recherche: recherche,
      statut: statut,
      priorite: priorite,
    ),
  ).map((item) => item.id).toList();
}

Intervention _intervention({
  required String id,
  required String station,
  required String domaine,
  required String description,
  required StatutIntervention statut,
  required Priorite priorite,
}) {
  return Intervention(
    id: id,
    station: station,
    domaine: domaine,
    latitude: 42,
    longitude: 9,
    priorite: priorite,
    statut: statut,
    datePrevue: DateTime(2026, 6, 15),
    description: description,
    historique: [
      ActionHistorique(date: DateTime(2026, 6, 10), action: 'Créée'),
    ],
  );
}
