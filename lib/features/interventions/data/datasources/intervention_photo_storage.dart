import 'dart:io';

import 'package:agrivista_field/core/errors/app_failure.dart';

typedef ApplicationDirectoryProvider = Future<Directory> Function();

abstract interface class InterventionPhotoStorage {
  Future<String> copierDansStockagePermanent(
    String interventionId,
    String sourcePath,
  );

  Future<void> supprimerSiGeree(String photoPath);
}

final class PersistentInterventionPhotoStorage
    implements InterventionPhotoStorage {
  const PersistentInterventionPhotoStorage(this._applicationDirectoryProvider);

  static const directoryName = 'intervention_photos';

  final ApplicationDirectoryProvider _applicationDirectoryProvider;

  @override
  Future<String> copierDansStockagePermanent(
    String interventionId,
    String sourcePath,
  ) async {
    if (interventionId.trim().isEmpty || sourcePath.trim().isEmpty) {
      throw const LocalStorageFailure('La photo sélectionnée est invalide.');
    }

    try {
      final source = File(sourcePath);
      if (!await source.exists()) {
        throw const LocalStorageFailure(
          'La photo sélectionnée est inaccessible.',
        );
      }

      final directory = await _managedDirectory();
      await directory.create(recursive: true);
      final safeId = interventionId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final extension = _safeExtension(source);
      final fileName =
          '${safeId}_${DateTime.now().microsecondsSinceEpoch}$extension';
      final destination = File(
        '${directory.path}${Platform.pathSeparator}$fileName',
      );
      return (await source.copy(destination.path)).path;
    } on LocalStorageFailure {
      rethrow;
    } catch (_) {
      throw const LocalStorageFailure(
        'Impossible de conserver la photo sélectionnée.',
      );
    }
  }

  @override
  Future<void> supprimerSiGeree(String photoPath) async {
    if (photoPath.trim().isEmpty) {
      return;
    }
    try {
      final directory = await _managedDirectory();
      final file = File(photoPath);
      if (_samePath(file.parent.absolute.path, directory.absolute.path) &&
          await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Le nettoyage d'une ancienne photo ne doit pas invalider la nouvelle.
    }
  }

  Future<Directory> _managedDirectory() async {
    final root = await _applicationDirectoryProvider();
    return Directory('${root.path}${Platform.pathSeparator}$directoryName');
  }

  String _safeExtension(File source) {
    final name = source.uri.pathSegments.isEmpty
        ? ''
        : source.uri.pathSegments.last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex <= 0) {
      return '.jpg';
    }
    final extension = name.substring(dotIndex).toLowerCase();
    return RegExp(r'^\.[a-z0-9]{1,5}$').hasMatch(extension)
        ? extension
        : '.jpg';
  }

  bool _samePath(String left, String right) {
    if (Platform.isWindows) {
      return left.toLowerCase() == right.toLowerCase();
    }
    return left == right;
  }
}
