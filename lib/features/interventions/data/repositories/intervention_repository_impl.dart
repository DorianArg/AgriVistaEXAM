import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_remote_data_source.dart';
import 'package:agrivista_field/features/interventions/data/mappers/agrivista_response_mapper.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';

final class InterventionRepositoryImpl implements InterventionRepository {
  const InterventionRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final InterventionRemoteDataSource _remoteDataSource;
  final InterventionLocalDataSource _localDataSource;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    try {
      final response = await _remoteDataSource.recupererDonnees();
      final donneesDistantes = response.toDomain();
      final surcharges = await _localDataSource.lireSurchargesStatut();

      return DonneesInterventions(
        technicien: donneesDistantes.technicien,
        interventions: donneesDistantes.interventions.map((intervention) {
          final statutLocal = surcharges[intervention.id];
          return statutLocal == null
              ? intervention
              : intervention.avecStatut(statutLocal);
        }).toList(),
      );
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const UnknownFailure();
    }
  }

  @override
  Future<void> mettreAJourStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {
    try {
      await _localDataSource.enregistrerStatut(interventionId, statut);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
