import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/core/widgets/async_state_views.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:agrivista_field/features/interventions/presentation/pages/intervention_detail_page.dart';
import 'package:agrivista_field/features/interventions/presentation/widgets/intervention_card.dart';
import 'package:agrivista_field/features/interventions/presentation/widgets/intervention_filters_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class InterventionsPage extends ConsumerStatefulWidget {
  const InterventionsPage({
    this.onInterventionSelected,
    this.masterDetail = false,
    super.key,
  });

  final ValueChanged<Intervention>? onInterventionSelected;
  final bool masterDetail;

  @override
  ConsumerState<InterventionsPage> createState() => _InterventionsPageState();
}

final class _InterventionsPageState extends ConsumerState<InterventionsPage> {
  String? _selectedInterventionId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(interventionsProvider);
    if (widget.masterDetail) {
      return state.when(
        loading: () =>
            const AppLoadingView(message: 'Chargement des interventions…'),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.read(interventionsProvider.notifier).recharger(),
        ),
        data: (data) => _buildMasterDetail(context, ref, data),
      );
    }

    return InterventionsView(
      state: state,
      onRetry: () => ref.read(interventionsProvider.notifier).recharger(),
      onRefresh: () => _refresh(context, ref),
      onInterventionSelected: widget.onInterventionSelected,
    );
  }

  Widget _buildMasterDetail(
    BuildContext context,
    WidgetRef ref,
    DonneesInterventions data,
  ) {
    final filters = ref.watch(interventionFiltersProvider);
    final visibleInterventions = filtrerInterventions(
      data.interventions,
      filters,
    );
    final selectedId =
        visibleInterventions.any((item) => item.id == _selectedInterventionId)
        ? _selectedInterventionId
        : visibleInterventions.firstOrNull?.id;

    return LayoutBuilder(
      builder: (context, constraints) {
        final listWidth = (constraints.maxWidth * .4).clamp(340.0, 480.0);
        return Row(
          key: const Key('interventions-master-detail'),
          children: [
            SizedBox(
              width: listWidth,
              child: _InterventionsDataView(
                data: data,
                onRefresh: () => _refresh(context, ref),
                selectedInterventionId: selectedId,
                onInterventionSelected: (intervention) {
                  setState(() => _selectedInterventionId = intervention.id);
                },
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: selectedId == null
                  ? const AppEmptyView(
                      message: 'Sélectionnez une intervention.',
                    )
                  : InterventionDetailPage(
                      key: ValueKey('tablet-detail-$selectedId'),
                      interventionId: selectedId,
                      embedded: true,
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final succeeded = await ref
        .read(interventionsProvider.notifier)
        .recharger();
    if (!succeeded && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’actualiser les interventions.'),
        ),
      );
    }
  }
}

final class InterventionsView extends StatelessWidget {
  const InterventionsView({
    required this.state,
    required this.onRetry,
    this.onRefresh,
    this.onInterventionSelected,
    super.key,
  });

  final AsyncValue<DonneesInterventions> state;
  final VoidCallback onRetry;
  final RefreshCallback? onRefresh;
  final ValueChanged<Intervention>? onInterventionSelected;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () =>
          const AppLoadingView(message: 'Chargement des interventions…'),
      error: (error, _) => AppErrorView(error: error, onRetry: onRetry),
      data: (data) => _InterventionsDataView(
        data: data,
        onRefresh: onRefresh,
        onInterventionSelected: onInterventionSelected,
      ),
    );
  }
}

final class _InterventionsDataView extends ConsumerWidget {
  const _InterventionsDataView({
    required this.data,
    this.onRefresh,
    this.onInterventionSelected,
    this.selectedInterventionId,
  });

  final DonneesInterventions data;
  final RefreshCallback? onRefresh;
  final ValueChanged<Intervention>? onInterventionSelected;
  final String? selectedInterventionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(interventionFiltersProvider);
    final interventions = filtrerInterventions(data.interventions, filters);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InterventionFiltersBar(),
          const SizedBox(height: 20),
          Text(
            'Interventions (${interventions.length})',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh ?? () async {},
              child: interventions.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 240,
                          child: AppEmptyView(
                            message: data.interventions.isEmpty
                                ? 'Aucune intervention disponible.'
                                : 'Aucune intervention ne correspond à votre recherche.',
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: interventions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final intervention = interventions[index];
                        return InterventionCard(
                          intervention: intervention,
                          selected: intervention.id == selectedInterventionId,
                          onTap: onInterventionSelected == null
                              ? null
                              : () => onInterventionSelected!(intervention),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
