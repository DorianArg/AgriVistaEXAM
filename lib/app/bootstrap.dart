import 'package:agrivista_field/app/app.dart';
import 'package:agrivista_field/app/dependency_providers.dart';
import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/datasources/intervention_local_data_source.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Composition root of the application.
///
/// Technical dependencies will be initialized and overridden here as the
/// corresponding data layers are introduced.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  final statusBox = await _initializeStatusBox();

  runApp(
    ProviderScope(
      overrides: [interventionStatusBoxProvider.overrideWithValue(statusBox)],
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
