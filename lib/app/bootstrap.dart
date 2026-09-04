import 'package:agrivista_field/app/app.dart';
import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/core/network/dio_client.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/compte_rendu_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_picker.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_photo_storage.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_remote_data_source.dart';
import 'package:agrivista_field/features/interventions/data/repositories/compte_rendu_repository_impl.dart';
import 'package:agrivista_field/features/interventions/data/repositories/intervention_repository_impl.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/compte_rendu_dependencies.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Initializes technical dependencies and injects them at the composition
/// root before rendering the application.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final boxes = await _initializeLocalBoxes();
  final repository = InterventionRepositoryImpl(
    DioInterventionRemoteDataSource(createDioClient()),
    HiveInterventionLocalDataSource(boxes.statuses),
  );
  final compteRenduRepository = CompteRenduRepositoryImpl(
    HiveCompteRenduLocalDataSource(boxes.notes, boxes.photos),
    PersistentInterventionPhotoStorage(getApplicationDocumentsDirectory),
  );

  runApp(
    ProviderScope(
      overrides: [
        interventionRepositoryProvider.overrideWithValue(repository),
        compteRenduRepositoryProvider.overrideWithValue(compteRenduRepository),
        interventionPhotoPickerProvider.overrideWithValue(
          ImagePickerInterventionPhotoPicker(ImagePicker()),
        ),
      ],
      child: const AgriVistaApp(),
    ),
  );
}

Future<({Box<String> statuses, Box<String> notes, Box<String> photos})>
_initializeLocalBoxes() async {
  try {
    await Hive.initFlutter();
    final statuses = await Hive.openBox<String>(
      InterventionStatusStorage.boxName,
    );
    final notes = await Hive.openBox<String>(CompteRenduStorage.notesBoxName);
    final photos = await Hive.openBox<String>(CompteRenduStorage.photosBoxName);
    return (statuses: statuses, notes: notes, photos: photos);
  } catch (_) {
    throw const LocalStorageFailure(
      'Impossible d’initialiser le stockage local.',
    );
  }
}
