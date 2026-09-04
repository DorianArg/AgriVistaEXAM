import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract final class CompteRenduStorage {
  static const notesBoxName = 'intervention_notes';
  static const photosBoxName = 'intervention_photos';
}

abstract interface class CompteRenduLocalDataSource {
  Future<CompteRenduIntervention> lire(String interventionId);

  Future<void> enregistrerNote(String interventionId, String note);

  Future<void> enregistrerPhoto(String interventionId, String photoPath);
}

final class HiveCompteRenduLocalDataSource
    implements CompteRenduLocalDataSource {
  const HiveCompteRenduLocalDataSource(this._notesBox, this._photosBox);

  final Box<String> _notesBox;
  final Box<String> _photosBox;

  @override
  Future<CompteRenduIntervention> lire(String interventionId) async {
    _validateId(interventionId);
    _ensureBoxesOpen();
    try {
      final photoPath = _photosBox.get(interventionId);
      if (photoPath != null && photoPath.trim().isEmpty) {
        throw const LocalStorageFailure(
          'Le chemin de photo local est invalide.',
        );
      }
      return CompteRenduIntervention(
        interventionId: interventionId,
        note: _notesBox.get(interventionId, defaultValue: '') ?? '',
        photoPath: photoPath,
      );
    } on LocalStorageFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure(
        'Impossible de lire le compte rendu local.',
      );
    }
  }

  @override
  Future<void> enregistrerNote(String interventionId, String note) async {
    _validateId(interventionId);
    _ensureBoxesOpen();
    try {
      await _notesBox.put(interventionId, note);
    } catch (_) {
      throw const LocalStorageFailure(
        'Impossible d’enregistrer la note locale.',
      );
    }
  }

  @override
  Future<void> enregistrerPhoto(String interventionId, String photoPath) async {
    _validateId(interventionId);
    if (photoPath.trim().isEmpty) {
      throw const LocalStorageFailure('Le chemin de photo est invalide.');
    }
    _ensureBoxesOpen();
    try {
      await _photosBox.put(interventionId, photoPath);
    } catch (_) {
      throw const LocalStorageFailure(
        'Impossible d’enregistrer la photo locale.',
      );
    }
  }

  void _ensureBoxesOpen() {
    if (!_notesBox.isOpen || !_photosBox.isOpen) {
      throw const LocalStorageFailure('Le stockage local est fermé.');
    }
  }

  void _validateId(String interventionId) {
    if (interventionId.trim().isEmpty) {
      throw const LocalStorageFailure(
        'L’identifiant de l’intervention ne peut pas être vide.',
      );
    }
  }
}
