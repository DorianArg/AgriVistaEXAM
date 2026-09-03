import 'package:agrivista_field/app/app_shell.dart';
import 'package:agrivista_field/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AgriVistaApp extends StatelessWidget {
  const AgriVistaApp({this.home, super.key});

  final Widget? home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriVista Field',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: home ?? const AppShell(),
    );
  }
}
