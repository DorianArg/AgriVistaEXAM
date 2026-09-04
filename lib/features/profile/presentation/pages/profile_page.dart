import 'package:agrivista_field/core/widgets/async_state_views.dart';
import 'package:agrivista_field/core/theme/theme_mode_provider.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:agrivista_field/features/profile/presentation/widgets/profile_identity.dart';
import 'package:agrivista_field/features/profile/presentation/widgets/theme_mode_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProfilePage extends ConsumerWidget {
  const ProfilePage({this.isTablet = false, super.key});

  final bool isTablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(interventionsProvider)
        .when(
          loading: () => const AppLoadingView(message: 'Chargement du profil…'),
          error: (error, _) => AppErrorView(
            error: error,
            onRetry: () => ref.read(interventionsProvider.notifier).recharger(),
          ),
          data: (data) => ProfileIdentity(
            technicien: data.technicien,
            isTablet: isTablet,
            footer: ThemeModeSelector(
              value: ref.watch(themeModeProvider),
              onChanged: (mode) => _changeTheme(context, ref, mode),
            ),
          ),
        );
  }

  Future<void> _changeTheme(
    BuildContext context,
    WidgetRef ref,
    ThemeMode mode,
  ) async {
    final succeeded = await ref.read(themeModeProvider.notifier).setMode(mode);
    if (!succeeded && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer le thème sélectionné.'),
        ),
      );
    }
  }
}
