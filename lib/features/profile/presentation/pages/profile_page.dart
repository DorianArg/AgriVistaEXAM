import 'package:agrivista_field/core/widgets/async_state_views.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:agrivista_field/features/profile/presentation/widgets/profile_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

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
          data: (data) => ProfileIdentity(technicien: data.technicien),
        );
  }
}
