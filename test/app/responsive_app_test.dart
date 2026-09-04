import 'package:agrivista_field/app/app_shell.dart';
import 'package:agrivista_field/core/utils/responsive_breakpoints.dart';
import 'package:agrivista_field/core/theme/theme_mode_provider.dart';
import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/compte_rendu_repository.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/mettre_a_jour_statut.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/compte_rendu_dependencies.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classe les largeurs autour du breakpoint centralisé', () {
    expect(ResponsiveBreakpoints.forWidth(719), AppLayoutSize.phone);
    expect(ResponsiveBreakpoints.forWidth(720), AppLayoutSize.tablet);
  });

  testWidgets('le téléphone conserve la NavigationBar', (tester) async {
    await _pumpShell(tester, const Size(390, 844));

    expect(find.byKey(const Key('phone-navigation-bar')), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    expect(find.byKey(const Key('dashboard-phone-layout')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la tablette utilise NavigationRail et le dashboard adapté', (
    tester,
  ) async {
    await _pumpShell(tester, const Size(1200, 900));

    expect(find.byKey(const Key('tablet-navigation-rail')), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('dashboard-tablet-layout')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la tablette affiche et pilote le master/detail', (tester) async {
    await _pumpShell(tester, const Size(1200, 900));
    await _tapRailDestination(tester, 'Interventions');
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('interventions-master-detail')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('tablet-intervention-detail')), findsOneWidget);
    expect(find.text('Description nord'), findsOneWidget);
    expect(find.byKey(const Key('intervention-note-field')), findsOneWidget);
    expect(find.byKey(const Key('select-intervention-photo')), findsOneWidget);

    await tester.tap(find.text('Station Sud').first);
    await tester.pumpAndSettle();

    expect(find.text('Description sud'), findsOneWidget);
    expect(find.text('Description nord'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('le profil tablette reste centré et expose le choix du thème', (
    tester,
  ) async {
    final container = await _pumpShell(tester, const Size(1200, 900));
    await _tapRailDestination(tester, 'Profil');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profile-tablet-layout')), findsOneWidget);
    expect(find.byKey(const Key('theme-mode-selector')), findsOneWidget);
    expect(find.text('Système'), findsOneWidget);
    expect(find.text('Clair'), findsOneWidget);
    expect(find.text('Sombre'), findsOneWidget);

    await tester.tap(find.text('Sombre'));
    await tester.pump();
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(tester.takeException(), isNull);
  });
}

Future<ProviderContainer> _pumpShell(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      obtenirInterventionsProvider.overrideWithValue(
        ObtenirInterventions(_FakeInterventionRepository(_data())),
      ),
      mettreAJourStatutProvider.overrideWithValue(
        MettreAJourStatut(_FakeInterventionRepository(_data())),
      ),
      compteRenduRepositoryProvider.overrideWithValue(
        const _FakeCompteRenduRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> _tapRailDestination(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byKey(const Key('tablet-navigation-rail')),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

DonneesInterventions _data() {
  return DonneesInterventions(
    technicien: const Technicien(id: 'tech-1', nom: 'Marie Santini'),
    interventions: [
      _intervention('itv-nord', 'Station Nord', 'Description nord'),
      _intervention('itv-sud', 'Station Sud', 'Description sud'),
    ],
  );
}

Intervention _intervention(String id, String station, String description) {
  return Intervention(
    id: id,
    station: station,
    domaine: 'Domaine test',
    latitude: 42,
    longitude: 9,
    priorite: Priorite.moyenne,
    statut: StatutIntervention.planifiee,
    datePrevue: DateTime(2026, 6, 15),
    description: description,
    historique: const [],
  );
}

final class _FakeInterventionRepository implements InterventionRepository {
  const _FakeInterventionRepository(this.data);

  final DonneesInterventions data;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async => data;

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}

final class _FakeCompteRenduRepository implements CompteRenduRepository {
  const _FakeCompteRenduRepository();

  @override
  Future<CompteRenduIntervention> lire(String interventionId) async {
    return CompteRenduIntervention(
      interventionId: interventionId,
      note: 'Note locale',
    );
  }

  @override
  Future<CompteRenduIntervention> enregistrerNote(
    String interventionId,
    String note,
  ) async {
    return CompteRenduIntervention(interventionId: interventionId, note: note);
  }

  @override
  Future<CompteRenduIntervention> enregistrerPhoto(
    String interventionId,
    String sourcePath,
  ) async {
    return CompteRenduIntervention(
      interventionId: interventionId,
      photoPath: sourcePath,
    );
  }
}
