import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/mappers/local_status_mapper.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract final class InterventionStatusStorage {
  static const boxName = 'intervention_statuses';
}

abstract interface class InterventionLocalDataSource {
  Future<Map<String, StatutIntervention>> lireSurchargesStatut();

  Future<StatutIntervention?> lireStatut(String interventionId);

  Future<void> enregistrerStatut(
    String interventionId,
    StatutIntervention statut,
  );
}

final class HiveInterventionLocalDataSource
    implements InterventionLocalDataSource {
  const HiveInterventionLocalDataSource(this._box);

  final Box<String> _box;

  @override
  Future<Map<String, StatutIntervention>> lireSurchargesStatut() async {
    try {
      final surcharges = <String, StatutIntervention>{};
      for (final entry in _box.toMap().entries) {
        final key = entry.key;
        if (key is! String || key.trim().isEmpty) {
          throw const LocalStorageFailure(
            'Un identifiant d’intervention local est invalide.',
          );
        }
        surcharges[key] = statutInterventionFromStorage(entry.value);
      }
      return Map.unmodifiable(surcharges);
    } on LocalStorageFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure();
    }
  }

  @override
  Future<StatutIntervention?> lireStatut(String interventionId) async {
    try {
      final value = _box.get(interventionId);
      return value == null ? null : statutInterventionFromStorage(value);
    } on LocalStorageFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure();
    }
  }

  @override
  Future<void> enregistrerStatut(
    String interventionId,
    StatutIntervention statut,
  ) async {
    if (interventionId.trim().isEmpty) {
      throw const LocalStorageFailure(
        'L’identifiant de l’intervention ne peut pas être vide.',
      );
    }

    try {
      await _box.put(interventionId, statut.toStorageValue());
    } catch (_) {
      throw const LocalStorageFailure();
    }
  }
}
