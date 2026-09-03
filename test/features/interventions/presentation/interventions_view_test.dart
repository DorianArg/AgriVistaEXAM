import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/domain/entities/action_historique.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/interventions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche un indicateur et un message pendant le chargement', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(const InterventionsView(state: AsyncLoading(), onRetry: _noop)),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Chargement des interventions…'), findsOneWidget);
  });

  testWidgets('affiche une erreur lisible et permet de réessayer', (
    tester,
  ) async {
    var retryCount = 0;
    await tester.pumpWidget(
      _testApp(
        InterventionsView(
          state: AsyncError(const NetworkFailure(), StackTrace.current),
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(find.text('Impossible de contacter le serveur.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);

    await tester.tap(find.text('Réessayer'));
    expect(retryCount, 1);
  });

  testWidgets('affiche une intervention avec ses informations principales', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(InterventionsView(state: AsyncData(_data()), onRetry: _noop)),
    );

    expect(find.text('Station Nord'), findsOneWidget);
    expect(find.text('Vignoble Patrimonio'), findsOneWidget);
    expect(find.text('Haute'), findsWidgets);
    expect(find.text('Planifiée'), findsWidgets);
    expect(find.text('Prévue le 15/06/2026'), findsOneWidget);
  });
}

Widget _testApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

DonneesInterventions _data() {
  return DonneesInterventions(
    technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
    interventions: [
      Intervention(
        id: 'itv-1001',
        station: 'Station Nord',
        domaine: 'Vignoble Patrimonio',
        latitude: 42.703,
        longitude: 9.347,
        priorite: Priorite.haute,
        statut: StatutIntervention.planifiee,
        datePrevue: DateTime(2026, 6, 15),
        description: 'Remplacement du capteur.',
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

void _noop() {}
