import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:flutter/material.dart';

extension PrioriteLabel on Priorite {
  String get label => switch (this) {
    Priorite.haute => 'Haute',
    Priorite.moyenne => 'Moyenne',
    Priorite.basse => 'Basse',
  };
}

extension StatutInterventionLabel on StatutIntervention {
  String get label => switch (this) {
    StatutIntervention.planifiee => 'Planifiée',
    StatutIntervention.enCours => 'En cours',
    StatutIntervention.terminee => 'Terminée',
  };
}

final class PriorityBadge extends StatelessWidget {
  const PriorityBadge({required this.priorite, super.key});

  final Priorite priorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (priorite) {
      Priorite.haute => (colors.errorContainer, colors.onErrorContainer),
      Priorite.moyenne => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      Priorite.basse => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };

    return _Badge(
      label: priorite.label,
      background: background,
      foreground: foreground,
    );
  }
}

final class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.statut, super.key});

  final StatutIntervention statut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final (background, foreground) = switch (statut) {
      StatutIntervention.planifiee => (
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      StatutIntervention.enCours => (
        colors.tertiaryContainer,
        colors.onTertiaryContainer,
      ),
      StatutIntervention.terminee => (
        colors.secondaryContainer,
        colors.onSecondaryContainer,
      ),
    };

    return _Badge(
      label: statut.label,
      background: background,
      foreground: foreground,
    );
  }
}

final class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
