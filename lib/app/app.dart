import 'package:agrivista_field/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AgriVistaApp extends StatelessWidget {
  const AgriVistaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriVista Field',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _InitializationPage(),
    );
  }
}

class _InitializationPage extends StatelessWidget {
  const _InitializationPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AgriVista Field')),
      body: const Center(child: Text('Architecture initialisée')),
    );
  }
}
