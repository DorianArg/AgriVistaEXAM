import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:agrivista_field/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche le technicien fourni par la source de données', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          obtenirInterventionsProvider.overrideWithValue(
            ObtenirInterventions(
              _FakeRepository(
                DonneesInterventions(
                  technicien: const Technicien(
                    id: 'tech-42',
                    nom: 'Jean Dupont',
                  ),
                  interventions: const [],
                ),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfilePage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jean Dupont'), findsOneWidget);
    expect(find.text('tech-42'), findsOneWidget);
    expect(find.text('JD'), findsOneWidget);
    expect(find.text('Technicienne terrain'), findsOneWidget);
    expect(find.text('AgriVista Field'), findsOneWidget);
    expect(find.text('Marie Santini'), findsNothing);
  });

  testWidgets('reste utilisable sur une largeur de téléphone étroite', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          obtenirInterventionsProvider.overrideWithValue(
            ObtenirInterventions(
              _FakeRepository(
                DonneesInterventions(
                  technicien: const Technicien(
                    id: 'technicien-identifiant-long-42',
                    nom: 'Alexandra De La Fontaine',
                  ),
                  interventions: const [],
                ),
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: ProfilePage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('AF'), findsOneWidget);
  });
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
