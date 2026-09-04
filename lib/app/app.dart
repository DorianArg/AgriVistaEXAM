import 'package:agrivista_field/app/app_shell.dart';
import 'package:agrivista_field/app/app_constants.dart';
import 'package:agrivista_field/core/theme/app_theme.dart';
import 'package:agrivista_field/core/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgriVistaApp extends ConsumerWidget {
  const AgriVistaApp({this.home, super.key});

  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: home ?? const AppShell(),
    );
  }
}
