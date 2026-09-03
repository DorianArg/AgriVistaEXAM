import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_remote_data_source.dart';
import 'package:agrivista_field/features/interventions/data/mappers/agrivista_response_mapper.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';

final class InterventionRepositoryImpl implements InterventionRepository {
  const InterventionRepositoryImpl(this._remoteDataSource);

  final InterventionRemoteDataSource _remoteDataSource;

  @override
  Future<DonneesInterventions> recupererDonneesInitiales() async {
    try {
      final response = await _remoteDataSource.recupererDonnees();
      return response.toDomain();
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
