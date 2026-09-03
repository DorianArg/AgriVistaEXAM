import 'dart:io';

import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/mappers/local_status_mapper.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('HiveInterventionLocalDataSource', () {
    late Directory temporaryDirectory;
    late Box<String> box;
    late HiveInterventionLocalDataSource dataSource;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'agrivista_hive_test_',
      );
      Hive.init(temporaryDirectory.path);
      box = await Hive.openBox<String>(
        'statuses_${DateTime.now().microsecondsSinceEpoch}',
      );
      dataSource = HiveInterventionLocalDataSource(box);
    });

    tearDown(() async {
      await box.close();
      await temporaryDirectory.delete(recursive: true);
    });

    test('lit une box sans surcharge', () async {
      expect(await dataSource.lireSurchargesStatut(), isEmpty);
    });

    test('lit un statut local valide', () async {
      await box.put('itv-1001', 'en_cours');

      expect(
        await dataSource.lireStatut('itv-1001'),
        StatutIntervention.enCours,
      );
    });

    test('écrit un statut dans la box', () async {
      await dataSource.enregistrerStatut(
        'itv-1001',
        StatutIntervention.terminee,
      );

      expect(box.get('itv-1001'), 'terminee');
    });

    test('rejette une valeur locale inconnue', () async {
      await box.put('itv-1001', 'annulee');

      expect(
        dataSource.lireSurchargesStatut,
        throwsA(isA<LocalStorageFailure>()),
      );
    });
  });

  group('conversion des statuts locaux', () {
    final cases = <String, StatutIntervention>{
      'planifiee': StatutIntervention.planifiee,
      'en_cours': StatutIntervention.enCours,
      'terminee': StatutIntervention.terminee,
    };

    for (final entry in cases.entries) {
      test('convertit ${entry.key} dans les deux sens', () {
        expect(statutInterventionFromStorage(entry.key), entry.value);
        expect(entry.value.toStorageValue(), entry.key);
      });
    }
  });
}
