import 'package:agrivista_field/app/dependency_providers.dart';
import 'package:agrivista_field/core/network/dio_client.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_remote_data_source.dart';
import 'package:agrivista_field/features/interventions/data/repositories/intervention_repository_impl.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/intervention_repository.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_interventions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider((ref) {
  final dio = createDioClient();
  ref.onDispose(() => dio.close());
  return dio;
});

final interventionRemoteDataSourceProvider =
    Provider<InterventionRemoteDataSource>((ref) {
      return DioInterventionRemoteDataSource(ref.watch(dioProvider));
    });

final interventionLocalDataSourceProvider =
    Provider<InterventionLocalDataSource>((ref) {
      return HiveInterventionLocalDataSource(
        ref.watch(interventionStatusBoxProvider),
      );
    });

final interventionRepositoryProvider = Provider<InterventionRepository>((ref) {
  return InterventionRepositoryImpl(
    ref.watch(interventionRemoteDataSourceProvider),
    ref.watch(interventionLocalDataSourceProvider),
  );
});

final obtenirInterventionsProvider = Provider((ref) {
  return ObtenirInterventions(ref.watch(interventionRepositoryProvider));
});
