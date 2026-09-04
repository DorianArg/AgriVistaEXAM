import 'package:agrivista_field/app/app.dart';
import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/core/network/dio_client.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_local_data_source.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_remote_data_source.dart';
import 'package:agrivista_field/features/interventions/data/repositories/intervention_repository_impl.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_dependencies.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Initializes technical dependencies and injects them at the composition
/// root before rendering the application.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final statusBox = await _initializeStatusBox();
  final repository = InterventionRepositoryImpl(
    DioInterventionRemoteDataSource(createDioClient()),
    HiveInterventionLocalDataSource(statusBox),
  );

  runApp(
    ProviderScope(
      overrides: [interventionRepositoryProvider.overrideWithValue(repository)],
      child: const AgriVistaApp(),
    ),
  );
}

Future<Box<String>> _initializeStatusBox() async {
  try {
    await Hive.initFlutter();
    return await Hive.openBox<String>(InterventionStatusStorage.boxName);
  } catch (_) {
    throw const LocalStorageFailure(
      'Impossible d’initialiser le stockage local des statuts.',
    );
  }
}
