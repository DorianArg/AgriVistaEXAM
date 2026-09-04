import 'dart:io';

import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory temporaryDirectory;
  late PersistentInterventionPhotoStorage storage;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'agrivista_photo_test_',
    );
    storage = PersistentInterventionPhotoStorage(
      () async => temporaryDirectory,
    );
  });

  tearDown(() => temporaryDirectory.delete(recursive: true));

  test('copie une photo dans le répertoire permanent géré', () async {
    final source = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}source.png',
    );
    await source.writeAsBytes([1, 2, 3, 4]);

    final result = await storage.copierDansStockagePermanent(
      'itv-1',
      source.path,
    );

    expect(result, contains(PersistentInterventionPhotoStorage.directoryName));
    expect(await File(result).readAsBytes(), [1, 2, 3, 4]);
    expect(await source.exists(), isTrue);
  });

  test(
    'supprime une ancienne photo uniquement dans le répertoire géré',
    () async {
      final source = File(
        '${temporaryDirectory.path}${Platform.pathSeparator}source.jpg',
      );
      await source.writeAsBytes([1]);
      final managedPath = await storage.copierDansStockagePermanent(
        'itv-1',
        source.path,
      );

      await storage.supprimerSiGeree(managedPath);
      await storage.supprimerSiGeree(source.path);

      expect(await File(managedPath).exists(), isFalse);
      expect(await source.exists(), isTrue);
    },
  );

  test('rejette une source inexistante', () {
    expect(
      storage.copierDansStockagePermanent('itv-1', '/absente/photo.jpg'),
      throwsA(isA<LocalStorageFailure>()),
    );
  });
}
