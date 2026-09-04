import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_picker.dart';
import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/repositories/compte_rendu_repository.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/compte_rendu_dependencies.dart';
import 'package:agrivista_field/features/interventions/presentation/widgets/compte_rendu_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('affiche une note locale existante', (tester) async {
    final repository = _FakeRepository(
      const CompteRenduIntervention(
        interventionId: 'itv-1',
        note: 'Vérifier le câblage demain.',
      ),
    );
    await _pumpSection(tester, repository);

    final field = tester.widget<TextField>(
      find.byKey(const Key('intervention-note-field')),
    );
    expect(field.controller?.text, 'Vérifier le câblage demain.');
  });

  testWidgets('affiche un état explicite sans photo', (tester) async {
    await _pumpSection(
      tester,
      _FakeRepository(const CompteRenduIntervention(interventionId: 'itv-1')),
    );

    expect(find.text('Aucune photo'), findsOneWidget);
    expect(find.text('Ajouter une photo'), findsOneWidget);
  });

  testWidgets('affiche l aperçu d une photo locale', (tester) async {
    await _pumpSection(
      tester,
      _FakeRepository(
        const CompteRenduIntervention(
          interventionId: 'itv-1',
          photoPath: '/persistent/photo.jpg',
        ),
      ),
    );

    expect(find.byKey(const Key('intervention-photo-preview')), findsOneWidget);
    expect(find.text('Remplacer la photo'), findsOneWidget);
  });

  testWidgets('enregistre une note et confirme à l utilisateur', (
    tester,
  ) async {
    final repository = _FakeRepository(
      const CompteRenduIntervention(interventionId: 'itv-1'),
    );
    await _pumpSection(tester, repository);

    await tester.enterText(
      find.byKey(const Key('intervention-note-field')),
      'Nouvelle note terrain',
    );
    await tester.tap(find.byKey(const Key('save-intervention-note')));
    await _pumpAsync(tester);

    expect(repository.current.note, 'Nouvelle note terrain');
    expect(find.text('Note enregistrée localement.'), findsOneWidget);
  });

  testWidgets('sélectionne une photo et met l UI à jour', (tester) async {
    final repository = _FakeRepository(
      const CompteRenduIntervention(interventionId: 'itv-1'),
    );
    await _pumpSection(tester, repository, pickedPath: '/temp/selected.jpg');

    await tester.tap(find.byKey(const Key('select-intervention-photo')));
    await _pumpAsync(tester);

    expect(find.byKey(const Key('intervention-photo-preview')), findsOneWidget);
    expect(find.text('Photo enregistrée localement.'), findsOneWidget);
  });

  testWidgets('affiche une erreur compréhensible sans perdre la note valide', (
    tester,
  ) async {
    final repository = _FakeRepository(
      const CompteRenduIntervention(
        interventionId: 'itv-1',
        note: 'Note valide',
      ),
      writeFailure: const LocalStorageFailure(),
    );
    await _pumpSection(tester, repository);

    await tester.enterText(
      find.byKey(const Key('intervention-note-field')),
      'Modification impossible',
    );
    await tester.tap(find.byKey(const Key('save-intervention-note')));
    await _pumpAsync(tester);

    expect(repository.current.note, 'Note valide');
    expect(find.text('Impossible d’enregistrer la note.'), findsOneWidget);
  });

  testWidgets('affiche une erreur utilisateur lors d un échec de lecture', (
    tester,
  ) async {
    await _pumpSection(
      tester,
      _FakeRepository(
        const CompteRenduIntervention(interventionId: 'itv-1'),
        readFailure: const LocalStorageFailure(),
      ),
    );

    expect(
      find.text('Impossible de lire les données enregistrées localement.'),
      findsOneWidget,
    );
    expect(find.text('Réessayer le chargement'), findsOneWidget);
  });
}

Future<void> _pumpSection(
  WidgetTester tester,
  _FakeRepository repository, {
  String? pickedPath,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        compteRenduRepositoryProvider.overrideWithValue(repository),
        interventionPhotoPickerProvider.overrideWithValue(
          _FakePhotoPicker(pickedPath),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CompteRenduSection(
              interventionId: 'itv-1',
              photoBuilder: _fakePhotoBuilder,
            ),
          ),
        ),
      ),
    ),
  );
  await _pumpAsync(tester);
}

Widget _fakePhotoBuilder(BuildContext context, String path) {
  return const ColoredBox(color: Colors.green);
}

Future<void> _pumpAsync(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

final class _FakeRepository implements CompteRenduRepository {
  _FakeRepository(this.current, {this.readFailure, this.writeFailure});

  CompteRenduIntervention current;
  final AppFailure? readFailure;
  final AppFailure? writeFailure;

  @override
  Future<CompteRenduIntervention> lire(String interventionId) async {
    if (readFailure case final failure?) {
      throw failure;
    }
    return current;
  }

  @override
  Future<CompteRenduIntervention> enregistrerNote(
    String interventionId,
    String note,
  ) async {
    if (writeFailure case final failure?) {
      throw failure;
    }
    current = current.copyWith(note: note);
    return current;
  }

  @override
  Future<CompteRenduIntervention> enregistrerPhoto(
    String interventionId,
    String sourcePath,
  ) async {
    if (writeFailure case final failure?) {
      throw failure;
    }
    current = current.copyWith(photoPath: sourcePath);
    return current;
  }
}

final class _FakePhotoPicker implements InterventionPhotoPicker {
  const _FakePhotoPicker(this.path);

  final String? path;

  @override
  Future<String?> choisirDepuisGalerie() async => path;
}
