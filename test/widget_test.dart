import 'package:agrivista_field/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('application bootstrap uses the Material 3 theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: AgriVistaApp(home: SizedBox.shrink())),
    );

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.theme?.useMaterial3, isTrue);
    expect(materialApp.title, 'AgriVista Field');
  });
}
