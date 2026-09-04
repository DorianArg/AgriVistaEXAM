import 'package:agrivista_field/app/app.dart';
import 'package:agrivista_field/core/theme/theme_mode_provider.dart';
import 'package:agrivista_field/core/theme/theme_preference_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expose le thème système par défaut', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);
  });

  test('passe au thème clair et le persiste', () async {
    final repository = _MemoryThemeRepository();
    final container = _container(repository);
    addTearDown(container.dispose);

    expect(
      await container.read(themeModeProvider.notifier).setMode(ThemeMode.light),
      isTrue,
    );

    expect(container.read(themeModeProvider), ThemeMode.light);
    expect(repository.value, ThemeMode.light);
  });

  test('passe au thème sombre et le persiste', () async {
    final repository = _MemoryThemeRepository(ThemeMode.light);
    final container = _container(repository);
    addTearDown(container.dispose);

    expect(
      await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark),
      isTrue,
    );

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(repository.value, ThemeMode.dark);
  });

  testWidgets('met à jour MaterialApp lorsque le thème change', (tester) async {
    final repository = _MemoryThemeRepository();
    final container = _container(repository);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const AgriVistaApp(home: SizedBox.shrink()),
      ),
    );

    expect(_materialApp(tester).themeMode, ThemeMode.system);
    expect(_materialApp(tester).darkTheme?.useMaterial3, isTrue);

    await container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await tester.pump();

    expect(_materialApp(tester).themeMode, ThemeMode.dark);
  });
}

ProviderContainer _container(ThemePreferenceRepository repository) {
  return ProviderContainer(
    overrides: [
      themePreferenceRepositoryProvider.overrideWithValue(repository),
    ],
  );
}

MaterialApp _materialApp(WidgetTester tester) {
  return tester.widget<MaterialApp>(find.byType(MaterialApp));
}

final class _MemoryThemeRepository implements ThemePreferenceRepository {
  _MemoryThemeRepository([this.value = ThemeMode.system]);

  ThemeMode value;

  @override
  ThemeMode read() => value;

  @override
  Future<void> write(ThemeMode mode) async => value = mode;
}
