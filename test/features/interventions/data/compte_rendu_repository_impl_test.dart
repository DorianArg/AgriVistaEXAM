import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/compte_rendu_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_storage.dart';
import 'package:agrivista_field/features/interventions/data/repositories/compte_rendu_repository_impl.dart';
import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('enregistre une note sans modifier la photo', () async {
    final local = _FakeLocalDataSource(
      const CompteRenduIntervention(
        interventionId: 'itv-1',
        photoPath: '/photos/existante.jpg',
      ),
    );
    final repository = CompteRenduRepositoryImpl(local, _FakePhotoStorage());

    final result = await repository.enregistrerNote('itv-1', 'Nouvelle note');

    expect(result.note, 'Nouvelle note');
    expect(result.photoPath, '/photos/existante.jpg');
  });

  test('remplace la photo puis supprime l ancien fichier géré', () async {
    final local = _FakeLocalDataSource(
      const CompteRenduIntervention(
        interventionId: 'itv-1',
        note: 'Note conservée',
        photoPath: '/photos/ancienne.jpg',
      ),
    );
    final storage = _FakePhotoStorage();
    final repository = CompteRenduRepositoryImpl(local, storage);

    final result = await repository.enregistrerPhoto(
      'itv-1',
      '/temp/image.jpg',
    );

    expect(result.note, 'Note conservée');
    expect(result.photoPath, '/permanent/image.jpg');
    expect(local.savedPhotoPath, '/permanent/image.jpg');
    expect(storage.deletedPaths, ['/photos/ancienne.jpg']);
  });

  test('supprime la nouvelle copie si l écriture Hive échoue', () async {
    final local = _FakeLocalDataSource(
      const CompteRenduIntervention(interventionId: 'itv-1'),
      writeFailure: const LocalStorageFailure(),
    );
    final storage = _FakePhotoStorage();
    final repository = CompteRenduRepositoryImpl(local, storage);

    await expectLater(
      repository.enregistrerPhoto('itv-1', '/temp/image.jpg'),
      throwsA(isA<LocalStorageFailure>()),
    );

    expect(storage.deletedPaths, ['/permanent/image.jpg']);
  });

  test('propage une erreur de lecture locale', () {
    final repository = CompteRenduRepositoryImpl(
      _FakeLocalDataSource(
        const CompteRenduIntervention(interventionId: 'itv-1'),
        readFailure: const LocalStorageFailure(),
      ),
      _FakePhotoStorage(),
    );

    expect(repository.lire('itv-1'), throwsA(isA<LocalStorageFailure>()));
  });
}

final class _FakeLocalDataSource implements CompteRenduLocalDataSource {
  _FakeLocalDataSource(this.current, {this.readFailure, this.writeFailure});

  CompteRenduIntervention current;
  final AppFailure? readFailure;
  final AppFailure? writeFailure;
  String? savedPhotoPath;

  @override
  Future<CompteRenduIntervention> lire(String interventionId) async {
    if (readFailure case final failure?) {
      throw failure;
    }
    return current;
  }

  @override
  Future<void> enregistrerNote(String interventionId, String note) async {
    if (writeFailure case final failure?) {
      throw failure;
    }
    current = current.copyWith(note: note);
  }

  @override
  Future<void> enregistrerPhoto(String interventionId, String photoPath) async {
    if (writeFailure case final failure?) {
      throw failure;
    }
    savedPhotoPath = photoPath;
    current = current.copyWith(photoPath: photoPath);
  }
}

final class _FakePhotoStorage implements InterventionPhotoStorage {
  final List<String> deletedPaths = [];

  @override
  Future<String> copierDansStockagePermanent(
    String interventionId,
    String sourcePath,
  ) async {
    return '/permanent/image.jpg';
  }

  @override
  Future<void> supprimerSiGeree(String photoPath) async {
    deletedPaths.add(photoPath);
  }
}
