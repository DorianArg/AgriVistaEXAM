import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_picker.dart';
import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/compte_rendu_repository.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/compte_rendu_dependencies.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/compte_rendu_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('charge un compte rendu sans note ni photo', () async {
    final context = _context();
    addTearDown(context.dispose);

    final result = await context.container.read(
      compteRenduProvider('itv-1').future,
    );

    expect(result.note, isEmpty);
    expect(result.photoPath, isNull);
  });

  test('met immédiatement à jour la note enregistrée', () async {
    final context = _context();
    addTearDown(context.dispose);
    await context.container.read(compteRenduProvider('itv-1').future);

    final succeeded = await context.container
        .read(compteRenduProvider('itv-1').notifier)
        .enregistrerNote('Contrôle effectué');

    expect(succeeded, isTrue);
    expect(
      context.container.read(compteRenduProvider('itv-1')).requireValue.note,
      'Contrôle effectué',
    );
  });

  test('maintient un compte rendu distinct par intervention', () async {
    final context = _context();
    addTearDown(context.dispose);
    await context.container.read(compteRenduProvider('itv-1').future);
    await context.container.read(compteRenduProvider('itv-2').future);

    await context.container
        .read(compteRenduProvider('itv-1').notifier)
        .enregistrerNote('Note une');

    expect(
      context.container.read(compteRenduProvider('itv-1')).requireValue.note,
      'Note une',
    );
    expect(
      context.container.read(compteRenduProvider('itv-2')).requireValue.note,
      isEmpty,
    );
  });

  test('sélectionne puis expose le chemin de photo permanent', () async {
    final context = _context(pickedPath: '/temp/photo.jpg');
    addTearDown(context.dispose);
    await context.container.read(compteRenduProvider('itv-1').future);

    final result = await context.container
        .read(compteRenduProvider('itv-1').notifier)
        .choisirEtEnregistrerPhoto();

    expect(result, PhotoSelectionResult.saved);
    expect(
      context.container
          .read(compteRenduProvider('itv-1'))
          .requireValue
          .photoPath,
      '/permanent/photo.jpg',
    );
  });

  test('annulation de sélection ne modifie pas le compte rendu', () async {
    final context = _context();
    addTearDown(context.dispose);
    await context.container.read(compteRenduProvider('itv-1').future);

    final result = await context.container
        .read(compteRenduProvider('itv-1').notifier)
        .choisirEtEnregistrerPhoto();

    expect(result, PhotoSelectionResult.cancelled);
    expect(
      context.container
          .read(compteRenduProvider('itv-1'))
          .requireValue
          .photoPath,
      isNull,
    );
  });

  test('échec d écriture conserve la dernière note valide', () async {
    final context = _context(
      initial: const CompteRenduIntervention(
        interventionId: 'itv-1',
        note: 'Note valide',
      ),
      writeFailure: const LocalStorageFailure(),
    );
    addTearDown(context.dispose);
    await context.container.read(compteRenduProvider('itv-1').future);

    final succeeded = await context.container
        .read(compteRenduProvider('itv-1').notifier)
        .enregistrerNote('Note perdue');

    expect(succeeded, isFalse);
    expect(
      context.container.read(compteRenduProvider('itv-1')).requireValue.note,
      'Note valide',
    );
  });
}

_TestContext _context({
  CompteRenduIntervention? initial,
  String? pickedPath,
  AppFailure? writeFailure,
}) {
  final repository = _FakeRepository(
    initial: initial,
    writeFailure: writeFailure,
  );
  final container = ProviderContainer.test(
    overrides: [
      compteRenduRepositoryProvider.overrideWithValue(repository),
      interventionPhotoPickerProvider.overrideWithValue(
        _FakePhotoPicker(pickedPath),
      ),
    ],
  );
  final subscriptions = [
    container.listen(compteRenduProvider('itv-1'), (_, _) {}),
    container.listen(compteRenduProvider('itv-2'), (_, _) {}),
  ];
  return _TestContext(container, subscriptions);
}

final class _TestContext {
  const _TestContext(this.container, this.subscriptions);

  final ProviderContainer container;
  final List<ProviderSubscription<Object?>> subscriptions;

  void dispose() {
    for (final subscription in subscriptions) {
      subscription.close();
    }
    container.dispose();
  }
}

final class _FakeRepository implements CompteRenduRepository {
  _FakeRepository({CompteRenduIntervention? initial, this.writeFailure}) {
    if (initial != null) {
      reports[initial.interventionId] = initial;
    }
  }

  final Map<String, CompteRenduIntervention> reports = {};
  final AppFailure? writeFailure;

  @override
  Future<CompteRenduIntervention> lire(String interventionId) async {
    return reports[interventionId] ??
        CompteRenduIntervention(interventionId: interventionId);
  }

  @override
  Future<CompteRenduIntervention> enregistrerNote(
    String interventionId,
    String note,
  ) async {
    if (writeFailure case final failure?) {
      throw failure;
    }
    final updated = (await lire(interventionId)).copyWith(note: note);
    reports[interventionId] = updated;
    return updated;
  }

  @override
  Future<CompteRenduIntervention> enregistrerPhoto(
    String interventionId,
    String sourcePath,
  ) async {
    if (writeFailure case final failure?) {
      throw failure;
    }
    final updated = (await lire(
      interventionId,
    )).copyWith(photoPath: '/permanent/photo.jpg');
    reports[interventionId] = updated;
    return updated;
  }
}

final class _FakePhotoPicker implements InterventionPhotoPicker {
  const _FakePhotoPicker(this.path);

  final String? path;

  @override
  Future<String?> choisirDepuisGalerie() async => path;
}
