import 'package:agrivista_field/core/widgets/async_state_views.dart';
import 'package:agrivista_field/features/dashboard/presentation/providers/dashboard_summary_provider.dart';
import 'package:agrivista_field/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class DashboardPage extends ConsumerWidget {
  const DashboardPage({
    required this.onStatusSelected,
    required this.onPrioritySelected,
    this.isTablet = false,
    super.key,
  });

  final ValueChanged<StatutFilter> onStatusSelected;
  final ValueChanged<PrioriteFilter> onPrioritySelected;
  final bool isTablet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryState = ref.watch(dashboardSummaryProvider);

    return summaryState.when(
      loading: () =>
          const AppLoadingView(message: 'Chargement du tableau de bord…'),
      error: (error, _) => AppErrorView(
        error: error,
        onRetry: () => ref.read(interventionsProvider.notifier).recharger(),
      ),
      data: (summary) {
        final technicien = ref
            .watch(interventionsProvider)
            .requireValue
            .technicien;
        return DashboardContent(
          summary: summary,
          technicienNom: technicien.nom,
          onStatusSelected: onStatusSelected,
          onPrioritySelected: onPrioritySelected,
          isTablet: isTablet,
        );
      },
    );
  }
}
