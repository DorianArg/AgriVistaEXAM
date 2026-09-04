import 'dart:io';

import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/compte_rendu_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('HiveCompteRenduLocalDataSource', () {
    late Directory temporaryDirectory;
    late Box<String> notesBox;
    late Box<String> photosBox;
    late HiveCompteRenduLocalDataSource dataSource;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'agrivista_report_hive_test_',
      );
      Hive.init(temporaryDirectory.path);
      final suffix = DateTime.now().microsecondsSinceEpoch;
      notesBox = await Hive.openBox<String>('notes_$suffix');
      photosBox = await Hive.openBox<String>('photos_$suffix');
      dataSource = HiveCompteRenduLocalDataSource(notesBox, photosBox);
    });

    tearDown(() async {
      if (notesBox.isOpen) {
        await notesBox.close();
      }
      if (photosBox.isOpen) {
        await photosBox.close();
      }
      await temporaryDirectory.delete(recursive: true);
    });

    test('retourne un compte rendu vide lorsque la note est absente', () async {
      final result = await dataSource.lire('itv-1');

      expect(result.interventionId, 'itv-1');
      expect(result.note, isEmpty);
      expect(result.photoPath, isNull);
    });

    test('enregistre puis relit une note', () async {
      await dataSource.enregistrerNote('itv-1', 'Capteur vérifié.');

      expect((await dataSource.lire('itv-1')).note, 'Capteur vérifié.');
    });

    test('modifie une note existante', () async {
      await dataSource.enregistrerNote('itv-1', 'Première note');
      await dataSource.enregistrerNote('itv-1', 'Note corrigée');

      expect((await dataSource.lire('itv-1')).note, 'Note corrigée');
    });

    test('isole les comptes rendus de deux interventions', () async {
      await dataSource.enregistrerNote('itv-1', 'Note une');
      await dataSource.enregistrerNote('itv-2', 'Note deux');

      expect((await dataSource.lire('itv-1')).note, 'Note une');
      expect((await dataSource.lire('itv-2')).note, 'Note deux');
    });

    test('enregistre et remplace le chemin d une photo', () async {
      await dataSource.enregistrerPhoto('itv-1', '/photos/ancienne.jpg');
      await dataSource.enregistrerPhoto('itv-1', '/photos/nouvelle.jpg');

      expect(
        (await dataSource.lire('itv-1')).photoPath,
        '/photos/nouvelle.jpg',
      );
    });

    test('retrouve note et photo après réouverture des boxes', () async {
      final notesName = notesBox.name;
      final photosName = photosBox.name;
      await dataSource.enregistrerNote('itv-1', 'Note persistante');
      await dataSource.enregistrerPhoto('itv-1', '/photos/persistante.jpg');
      await notesBox.close();
      await photosBox.close();

      notesBox = await Hive.openBox<String>(notesName);
      photosBox = await Hive.openBox<String>(photosName);
      dataSource = HiveCompteRenduLocalDataSource(notesBox, photosBox);
      final result = await dataSource.lire('itv-1');

      expect(result.note, 'Note persistante');
      expect(result.photoPath, '/photos/persistante.jpg');
    });

    test('traduit une erreur de lecture locale', () async {
      await notesBox.close();

      await expectLater(
        dataSource.lire('itv-1'),
        throwsA(isA<LocalStorageFailure>()),
      );
    });

    test('traduit une erreur d écriture locale', () async {
      await photosBox.close();

      await expectLater(
        dataSource.enregistrerPhoto('itv-1', '/photos/test.jpg'),
        throwsA(isA<LocalStorageFailure>()),
      );
    });
  });
}
