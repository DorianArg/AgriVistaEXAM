import 'package:agrivista_field/core/theme/theme_preference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themePreferenceRepositoryProvider = Provider<ThemePreferenceRepository>(
  (ref) => const SystemThemePreferenceRepository(),
);

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ref.watch(themePreferenceRepositoryProvider).read();
  }

  Future<bool> setMode(ThemeMode mode) async {
    final previous = state;
    state = mode;
    try {
      await ref.read(themePreferenceRepositoryProvider).write(mode);
      return true;
    } catch (_) {
      state = previous;
      return false;
    }
  }
}
