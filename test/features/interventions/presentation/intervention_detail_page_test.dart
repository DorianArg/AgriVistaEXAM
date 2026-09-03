import 'package:agrivista_field/features/interventions/domain/entities/action_historique.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/mettre_a_jour_statut.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/intervention_detail_page.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche toutes les informations du détail planifié', (
    tester,
  ) async {
    await _pumpDetail(tester, StatutIntervention.planifiee);

    expect(find.text('Station Nord'), findsOneWidget);
    expect(find.text('Vignoble Patrimonio'), findsNWidgets(2));
    expect(find.text('15/06/2026'), findsOneWidget);
    expect(find.text('Remplacement complet du capteur.'), findsOneWidget);
    expect(find.text('Latitude : 42.703'), findsOneWidget);
    expect(find.text('Longitude : 9.347'), findsOneWidget);
    expect(find.text('10/06/2026'), findsOneWidget);
    expect(find.text('Intervention créée'), findsOneWidget);
    expect(find.text('Démarrer l’intervention'), findsOneWidget);
  });

  testWidgets('affiche Terminer l intervention pour un statut en cours', (
    tester,
  ) async {
    await _pumpDetail(tester, StatutIntervention.enCours);

    expect(find.text('Terminer l’intervention'), findsOneWidget);
    expect(find.text('Démarrer l’intervention'), findsNothing);
  });

  testWidgets('ne propose aucune progression pour une intervention terminée', (
    tester,
  ) async {
    await _pumpDetail(tester, StatutIntervention.terminee);

    expect(find.text('Intervention terminée'), findsOneWidget);
    expect(find.text('Démarrer l’intervention'), findsNothing);
    expect(find.text('Terminer l’intervention'), findsNothing);
  });
}

Future<void> _pumpDetail(WidgetTester tester, StatutIntervention status) async {
  final repository = _FakeRepository(_data(status));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        obtenirInterventionsProvider.overrideWithValue(
          ObtenirInterventions(repository),
        ),
        mettreAJourStatutProvider.overrideWithValue(
          MettreAJourStatut(repository),
        ),
      ],
      child: const MaterialApp(
        home: InterventionDetailPage(interventionId: 'itv-1'),
      ),
    ),
  );
  await tester.pumpAndSettle();
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
        description: 'Remplacement complet du capteur.',
        historique: [
          ActionHistorique(
            date: DateTime(2026, 6, 10),
            action: 'Intervention créée',
          ),
        ],
      ),
    ],
  );
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
