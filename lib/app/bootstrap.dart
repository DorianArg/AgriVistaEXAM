import 'package:agrivista_field/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Composition root of the application.
///
/// Technical dependencies will be initialized and overridden here as the
/// corresponding data layers are introduced.
void bootstrap() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: AgriVistaApp()));
}
