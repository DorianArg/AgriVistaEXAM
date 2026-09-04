import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_remote_data_source.dart';
import 'package:agrivista_field/features/interventions/data/models/agrivista_response_dto.dart';
import 'package:agrivista_field/features/interventions/data/repositories/intervention_repository_impl.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InterventionRepositoryImpl', () {
    test('conserve le statut JSON sans surcharge locale', () async {
      final repository = _repository(
        response: _response([_intervention('itv-1', 'planifiee')]),
      );

      final result = await repository.recupererDonneesInitiales();

      expect(result.interventions.single.statut, StatutIntervention.planifiee);
    });

    test('donne priorité au statut local', () async {
      final repository = _repository(
        response: _response([_intervention('itv-1', 'planifiee')]),
        overrides: {'itv-1': StatutIntervention.enCours},
      );

      final result = await repository.recupererDonneesInitiales();
      final intervention = result.interventions.single;

      expect(intervention.statut, StatutIntervention.enCours);
      expect(intervention.description, 'Description itv-1');
      expect(intervention.historique.single.action, 'Intervention creee');
    });

    test(
      'fusionne les surcharges sans créer une intervention obsolète',
      () async {
        final repository = _repository(
          response: _response([
            _intervention('itv-1', 'planifiee'),
            _intervention('itv-2', 'en_cours'),
            _intervention('itv-3', 'terminee'),
          ]),
          overrides: {
            'itv-1': StatutIntervention.enCours,
            'itv-3': StatutIntervention.terminee,
            'itv-obsolete': StatutIntervention.enCours,
          },
        );

        final result = await repository.recupererDonneesInitiales();

        expect(result.interventions.map((item) => item.statut), [
          StatutIntervention.enCours,
          StatutIntervention.enCours,
          StatutIntervention.terminee,
        ]);
        expect(result.interventions, hasLength(3));
        expect(
          result.interventions.any((item) => item.id == 'itv-obsolete'),
          isFalse,
        );
      },
    );

    test('applique une surcharge à toutes les interventions JSON', () async {
      final repository = _repository(
        response: _response([
          _intervention('itv-1', 'planifiee'),
          _intervention('itv-2', 'en_cours'),
        ]),
        overrides: {
          'itv-1': StatutIntervention.terminee,
          'itv-2': StatutIntervention.terminee,
        },
      );

      final result = await repository.recupererDonneesInitiales();

      expect(
        result.interventions.map((item) => item.statut),
        everyElement(StatutIntervention.terminee),
      );
    });

    test(
      'préserve la surcharge locale après un nouveau chargement distant',
      () async {
        final repository = InterventionRepositoryImpl(
          _SequencedRemoteDataSource([
            _response([_intervention('itv-1', 'planifiee')]),
            _response([_intervention('itv-1', 'terminee')]),
          ]),
          const _FakeLocalDataSource(
            overrides: {'itv-1': StatutIntervention.enCours},
          ),
        );

        final initial = await repository.recupererDonneesInitiales();
        final refreshed = await repository.recupererDonneesInitiales();

        expect(initial.interventions.single.statut, StatutIntervention.enCours);
        expect(
          refreshed.interventions.single.statut,
          StatutIntervention.enCours,
        );
      },
    );

    test('propage une erreur de lecture locale au chargement global', () {
      final repository = _repository(
        response: _response([_intervention('itv-1', 'planifiee')]),
        readFailure: const LocalStorageFailure('Lecture impossible.'),
      );

      expect(
        repository.recupererDonneesInitiales,
        throwsA(isA<LocalStorageFailure>()),
      );
    });
  });
}

InterventionRepositoryImpl _repository({
  required AgriVistaResponseDto response,
  Map<String, StatutIntervention> overrides = const {},
  AppFailure? readFailure,
}) {
  return InterventionRepositoryImpl(
    _FakeRemoteDataSource(response),
    _FakeLocalDataSource(overrides: overrides, readFailure: readFailure),
  );
}

AgriVistaResponseDto _response(List<InterventionDto> interventions) {
  return AgriVistaResponseDto(
    technicien: const TechnicienDto(id: 't-01', nom: 'Marie Santini'),
    interventions: interventions,
  );
}

InterventionDto _intervention(String id, String statut) {
  return InterventionDto(
    id: id,
    station: 'Station $id',
    domaine: 'Domaine $id',
    latitude: 42,
    longitude: 9,
    priorite: 'haute',
    statut: statut,
    datePrevue: '2026-06-15',
    description: 'Description $id',
    historique: const [
      ActionHistoriqueDto(date: '2026-06-10', action: 'Intervention creee'),
    ],
  );
}

final class _FakeRemoteDataSource implements InterventionRemoteDataSource {
  const _FakeRemoteDataSource(this.response);

  final AgriVistaResponseDto response;

  @override
  Future<AgriVistaResponseDto> recupererDonnees() async => response;
}

final class _SequencedRemoteDataSource implements InterventionRemoteDataSource {
  _SequencedRemoteDataSource(this.responses);

  final List<AgriVistaResponseDto> responses;
  int readCount = 0;

  @override
  Future<AgriVistaResponseDto> recupererDonnees() async {
    return responses[readCount++];
  }
}

final class _FakeLocalDataSource implements InterventionLocalDataSource {
  const _FakeLocalDataSource({this.overrides = const {}, this.readFailure});

  final Map<String, StatutIntervention> overrides;
  final AppFailure? readFailure;

  @override
  Future<Map<String, StatutIntervention>> lireSurchargesStatut() async {
    final failure = readFailure;
    if (failure != null) {
      throw failure;
    }
    return overrides;
  }

  @override
  Future<void> enregistrerStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {}
}
