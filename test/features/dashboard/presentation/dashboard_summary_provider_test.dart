import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/dashboard/presentation/providers/dashboard_summary_provider.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/mettre_a_jour_statut.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardSummary', () {
    final summary = DashboardSummary.fromInterventions(_interventions());

    test('retourne uniquement des zéros pour une liste vide', () {
      final empty = DashboardSummary.fromInterventions(const []);

      expect([
        empty.total,
        empty.planifiees,
        empty.enCours,
        empty.terminees,
        empty.prioriteHaute,
        empty.prioriteMoyenne,
        empty.prioriteBasse,
      ], everyElement(0));
    });

    test('calcule le total', () => expect(summary.total, 6));
    test('compte les interventions planifiées', () {
      expect(summary.planifiees, 3);
    });
    test('compte les interventions en cours', () {
      expect(summary.enCours, 2);
    });
    test('compte les interventions terminées', () {
      expect(summary.terminees, 1);
    });
    test('compte les priorités hautes', () {
      expect(summary.prioriteHaute, 2);
    });
    test('compte les priorités moyennes', () {
      expect(summary.prioriteMoyenne, 3);
    });
    test('compte les priorités basses', () {
      expect(summary.prioriteBasse, 1);
    });
    test('maintient la cohérence du total par statut', () {
      expect(
        summary.planifiees + summary.enCours + summary.terminees,
        summary.total,
      );
    });
  });

  group('prenomTechnicien', () {
    test('extrait le prénom du nom complet', () {
      expect(prenomTechnicien('  Marie   Santini  '), 'Marie');
    });

    test('gère un nom vide', () {
      expect(prenomTechnicien('   '), isEmpty);
    });
  });

  group('dashboardSummaryProvider', () {
    test('dérive la synthèse sans relire la source de données', () async {
      final repository = _FakeRepository(
        DonneesInterventions(
          technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
          interventions: [_intervention(0, StatutIntervention.planifiee)],
        ),
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(interventionsProvider.future);
      final summary = container.read(dashboardSummaryProvider).requireValue;

      expect(summary.total, 1);
      expect(summary.planifiees, 1);
      expect(repository.readCount, 1);
    });

    test('recalcule automatiquement après un changement de statut', () async {
      final repository = _FakeRepository(
        DonneesInterventions(
          technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
          interventions: [_intervention(0, StatutIntervention.planifiee)],
        ),
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      await container.read(interventionsProvider.future);
      expect(
        container.read(dashboardSummaryProvider).requireValue.planifiees,
        1,
      );

      await container
          .read(interventionsProvider.notifier)
          .mettreAJourStatut('itv-0');
      final updated = container.read(dashboardSummaryProvider).requireValue;

      expect(updated.planifiees, 0);
      expect(updated.enCours, 1);
      expect(repository.readCount, 1);
    });

    test('propage l erreur de interventionsProvider', () async {
      final repository = _FakeRepository(
        DonneesInterventions(
          technicien: const Technicien(id: 't-01', nom: 'Marie Santini'),
          interventions: const [],
        ),
        readFailure: const NetworkFailure(),
      );
      final container = _container(repository);
      addTearDown(container.dispose);

      await expectLater(
        container.read(interventionsProvider.future),
        throwsA(isA<NetworkFailure>()),
      );

      expect(container.read(dashboardSummaryProvider).hasError, isTrue);
    });
  });
}

ProviderContainer _container(_FakeRepository repository) {
  return ProviderContainer.test(
    overrides: [
      obtenirInterventionsProvider.overrideWithValue(
        ObtenirInterventions(repository),
      ),
      mettreAJourStatutProvider.overrideWithValue(
        MettreAJourStatut(repository),
      ),
    ],
  );
}

List<Intervention> _interventions() => [
  _intervention(0, StatutIntervention.planifiee, Priorite.haute),
  _intervention(1, StatutIntervention.planifiee, Priorite.moyenne),
  _intervention(2, StatutIntervention.planifiee, Priorite.basse),
  _intervention(3, StatutIntervention.enCours, Priorite.haute),
  _intervention(4, StatutIntervention.enCours, Priorite.moyenne),
  _intervention(5, StatutIntervention.terminee, Priorite.moyenne),
];

Intervention _intervention(
  int index,
  StatutIntervention statut, [
  Priorite priorite = Priorite.haute,
]) {
  return Intervention(
    id: 'itv-$index',
    station: 'Station $index',
    domaine: 'Domaine $index',
    latitude: 42,
    longitude: 9,
    priorite: priorite,
    statut: statut,
    datePrevue: DateTime(2026, 6, 15),
    description: 'Intervention $index',
    historique: const [],
  );
}

final class _FakeRepository implements InterventionRepository {
  _FakeRepository(this.data, {this.readFailure});

  final DonneesInterventions data;
  final AppFailure? readFailure;
  int readCount = 0;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    readCount++;
    if (readFailure case final failure?) {
      throw failure;
    }
    return data;
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}
