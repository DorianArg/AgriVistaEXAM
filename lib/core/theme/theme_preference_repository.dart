import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract interface class ThemePreferenceRepository {
  ThemeMode read();

  Future<void> write(ThemeMode mode);
}

abstract final class ThemePreferenceStorage {
  static const boxName = 'app_preferences';
  static const themeModeKey = 'theme_mode';
}

final class HiveThemePreferenceRepository implements ThemePreferenceRepository {
  const HiveThemePreferenceRepository(this._box);

  final Box<String> _box;

  @override
  ThemeMode read() {
    return switch (_box.get(ThemePreferenceStorage.themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> write(ThemeMode mode) {
    return _box.put(ThemePreferenceStorage.themeModeKey, mode.name);
  }
}

final class SystemThemePreferenceRepository
    implements ThemePreferenceRepository {
  const SystemThemePreferenceRepository();

  @override
  ThemeMode read() => ThemeMode.system;

  @override
  Future<void> write(ThemeMode mode) async {}
}
