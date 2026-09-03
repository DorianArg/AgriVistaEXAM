import 'package:agrivista_field/app/app_shell.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/mettre_a_jour_statut.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigue entre la liste, le profil et le détail avec retour', (
    tester,
  ) async {
    final repository = _FakeRepository(_data());
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
        child: const MaterialApp(home: AppShell()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Station Nord'), findsOneWidget);

    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Marie Santini'), findsOneWidget);

    await tester.tap(find.text('Interventions'));
    await tester.pumpAndSettle();
    expect(find.text('Station Nord'), findsOneWidget);

    await tester.tap(find.text('Station Nord'));
    await tester.pumpAndSettle();
    expect(find.text('Détail intervention'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Station Nord'), findsOneWidget);
    expect(find.text('Détail intervention'), findsNothing);
  });
}

DonneesInterventions _data() {
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
        statut: StatutIntervention.planifiee,
        datePrevue: DateTime(2026, 6, 15),
        description: 'Remplacement complet du capteur.',
        historique: const [],
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
