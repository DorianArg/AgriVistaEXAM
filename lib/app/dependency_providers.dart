import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final interventionStatusBoxProvider = Provider<Box<String>>((ref) {
  throw StateError(
    'interventionStatusBoxProvider doit être remplacé au démarrage.',
  );
});
