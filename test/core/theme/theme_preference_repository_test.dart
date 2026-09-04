import 'dart:io';

import 'package:agrivista_field/core/theme/theme_preference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  group('HiveThemePreferenceRepository', () {
    late Directory temporaryDirectory;
    late Box<String> box;
    late String boxName;

    setUp(() async {
      temporaryDirectory = await Directory.systemTemp.createTemp(
        'agrivista_theme_hive_test_',
      );
      Hive.init(temporaryDirectory.path);
      boxName = 'preferences_${DateTime.now().microsecondsSinceEpoch}';
      box = await Hive.openBox<String>(boxName);
    });

    tearDown(() async {
      if (box.isOpen) {
        await box.close();
      }
      await temporaryDirectory.delete(recursive: true);
    });

    test('utilise le thème système par défaut', () {
      final repository = HiveThemePreferenceRepository(box);

      expect(repository.read(), ThemeMode.system);
    });

    test('enregistre les préférences claire et sombre', () async {
      final repository = HiveThemePreferenceRepository(box);

      await repository.write(ThemeMode.light);
      expect(repository.read(), ThemeMode.light);
      expect(box.get(ThemePreferenceStorage.themeModeKey), 'light');

      await repository.write(ThemeMode.dark);
      expect(repository.read(), ThemeMode.dark);
      expect(box.get(ThemePreferenceStorage.themeModeKey), 'dark');
    });

    test('restaure la préférence après réouverture de Hive', () async {
      final repository = HiveThemePreferenceRepository(box);
      await repository.write(ThemeMode.dark);
      await box.close();

      box = await Hive.openBox<String>(boxName);
      final restoredRepository = HiveThemePreferenceRepository(box);

      expect(restoredRepository.read(), ThemeMode.dark);
    });
  });
}
