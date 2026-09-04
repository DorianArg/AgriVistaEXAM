import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/compte_rendu_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_storage.dart';
import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/compte_rendu_repository.dart';

final class CompteRenduRepositoryImpl implements CompteRenduRepository {
  const CompteRenduRepositoryImpl(this._localDataSource, this._photoStorage);

  final CompteRenduLocalDataSource _localDataSource;
  final InterventionPhotoStorage _photoStorage;

  @override
  Future<CompteRenduIntervention> lire(String interventionId) async {
    try {
      return await _localDataSource.lire(interventionId);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure(
        'Impossible de lire le compte rendu local.',
      );
    }
  }

  @override
  Future<CompteRenduIntervention> enregistrerNote(
    String interventionId,
    String note,
  ) async {
    try {
      final current = await _localDataSource.lire(interventionId);
      await _localDataSource.enregistrerNote(interventionId, note);
      return current.copyWith(note: note);
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure(
        'Impossible d’enregistrer la note locale.',
      );
    }
  }

  @override
  Future<CompteRenduIntervention> enregistrerPhoto(
    String interventionId,
    String sourcePath,
  ) async {
    String? newPath;
    try {
      final current = await _localDataSource.lire(interventionId);
      newPath = await _photoStorage.copierDansStockagePermanent(
        interventionId,
        sourcePath,
      );
      await _localDataSource.enregistrerPhoto(interventionId, newPath);
      final previousPath = current.photoPath;
      if (previousPath != null && previousPath != newPath) {
        await _photoStorage.supprimerSiGeree(previousPath);
      }
      return current.copyWith(photoPath: newPath);
    } on AppFailure {
      if (newPath != null) {
        await _photoStorage.supprimerSiGeree(newPath);
      }
      rethrow;
    } catch (_) {
      if (newPath != null) {
        await _photoStorage.supprimerSiGeree(newPath);
      }
      throw const LocalStorageFailure(
        'Impossible d’enregistrer la photo locale.',
      );
    }
  }
}
