import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/mettre_a_jour_statut.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MettreAJourStatut', () {
    test('persiste planifiee vers enCours avant de réussir', () async {
      final repository = _FakeInterventionRepository();
      final useCase = MettreAJourStatut(repository);

      final result = await useCase(
        interventionId: 'itv-1',
        statutActuel: StatutIntervention.planifiee,
      );

      expect(result, StatutIntervention.enCours);
      expect(repository.savedStatuses, {'itv-1': StatutIntervention.enCours});
    });

    test('persiste enCours vers terminee', () async {
      final repository = _FakeInterventionRepository();
      final useCase = MettreAJourStatut(repository);

      final result = await useCase(
        interventionId: 'itv-1',
        statutActuel: StatutIntervention.enCours,
      );

      expect(result, StatutIntervention.terminee);
      expect(repository.savedStatuses['itv-1'], StatutIntervention.terminee);
    });

    test('considère la mise à jour comme échouée si l écriture échoue', () {
      final repository = _FakeInterventionRepository(
        writeFailure: const LocalStorageFailure('Écriture impossible.'),
      );
      final useCase = MettreAJourStatut(repository);

      expect(
        () => useCase(
          interventionId: 'itv-1',
          statutActuel: StatutIntervention.planifiee,
        ),
        throwsA(isA<LocalStorageFailure>()),
      );
      expect(repository.savedStatuses, isEmpty);
    });

    test('refuse toute progression après terminee', () {
      final repository = _FakeInterventionRepository();
      final useCase = MettreAJourStatut(repository);

      expect(
        () => useCase(
          interventionId: 'itv-1',
          statutActuel: StatutIntervention.terminee,
        ),
        throwsA(isA<InvalidStatusTransitionFailure>()),
      );
      expect(repository.savedStatuses, isEmpty);
    });
  });
}

final class _FakeInterventionRepository implements InterventionRepository {
  _FakeInterventionRepository({this.writeFailure});

  final AppFailure? writeFailure;
  final Map<String, StatutIntervention> savedStatuses = {};

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() {
    throw UnimplementedError();
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {
    final failure = writeFailure;
    if (failure != null) {
      throw failure;
    }
    savedStatuses[interventionId] = statut;
  }
}
