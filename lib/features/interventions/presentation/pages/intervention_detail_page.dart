import 'package:agrivista_field/core/utils/date_formatter.dart';
import 'package:agrivista_field/core/widgets/async_state_views.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:agrivista_field/features/interventions/presentation/widgets/intervention_badge.dart';
import 'package:agrivista_field/features/interventions/presentation/widgets/intervention_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class InterventionDetailPage extends ConsumerStatefulWidget {
  const InterventionDetailPage({required this.interventionId, super.key});

  final String interventionId;

  @override
  ConsumerState<InterventionDetailPage> createState() =>
      _InterventionDetailPageState();
}

final class _InterventionDetailPageState
    extends ConsumerState<InterventionDetailPage> {
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final interventionsState = ref.watch(interventionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Détail intervention')),
      body: interventionsState.when(
        loading: () =>
            const AppLoadingView(message: 'Chargement de l’intervention…'),
        error: (error, _) => AppErrorView(
          error: error,
          onRetry: () => ref.read(interventionsProvider.notifier).recharger(),
        ),
        data: (data) {
          final intervention = _findIntervention(data.interventions);
          if (intervention == null) {
            return const AppEmptyView(
              message: 'Cette intervention est introuvable.',
            );
          }
          return _DetailContent(
            intervention: intervention,
            isUpdating: _isUpdating,
            onUpdateStatus: () => _updateStatus(intervention.id),
          );
        },
      ),
    );
  }

  Intervention? _findIntervention(List<Intervention> interventions) {
    for (final intervention in interventions) {
      if (intervention.id == widget.interventionId) {
        return intervention;
      }
    }
    return null;
  }

  Future<void> _updateStatus(String interventionId) async {
    if (_isUpdating) {
      return;
    }

    setState(() => _isUpdating = true);
    try {
      await ref
          .read(interventionsProvider.notifier)
          .mettreAJourStatut(interventionId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d’enregistrer le nouveau statut.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}

final class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.intervention,
    required this.isUpdating,
    required this.onUpdateStatus,
  });

  final Intervention intervention;
  final bool isUpdating;
  final VoidCallback onUpdateStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                intervention.station,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                intervention.domaine,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  PriorityBadge(priorite: intervention.priorite),
                  StatusBadge(statut: intervention.statut),
                ],
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Date prévue'),
              Text(formatDateFr(intervention.datePrevue)),
              const SizedBox(height: 24),
              const _SectionTitle('Description'),
              Text(intervention.description),
              const SizedBox(height: 24),
              const _SectionTitle('Localisation'),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        intervention.domaine,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Latitude : ${intervention.latitude}'),
                      const SizedBox(height: 4),
                      Text('Longitude : ${intervention.longitude}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Historique'),
              InterventionHistory(entries: intervention.historique),
              const SizedBox(height: 16),
              _StatusAction(
                statut: intervention.statut,
                isUpdating: isUpdating,
                onPressed: onUpdateStatus,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

final class _StatusAction extends StatelessWidget {
  const _StatusAction({
    required this.statut,
    required this.isUpdating,
    required this.onPressed,
  });

  final StatutIntervention statut;
  final bool isUpdating;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (statut == StatutIntervention.terminee) {
      return const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline),
            SizedBox(width: 8),
            Text('Intervention terminée'),
          ],
        ),
      );
    }

    final label = statut == StatutIntervention.planifiee
        ? 'Démarrer l’intervention'
        : 'Terminer l’intervention';

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isUpdating ? null : onPressed,
        child: isUpdating
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
