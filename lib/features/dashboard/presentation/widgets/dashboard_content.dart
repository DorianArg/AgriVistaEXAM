import 'package:agrivista_field/features/dashboard/presentation/providers/dashboard_summary_provider.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:flutter/material.dart';

final class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.summary,
    required this.technicienNom,
    required this.onStatusSelected,
    required this.onPrioritySelected,
    super.key,
  });

  final DashboardSummary summary;
  final String technicienNom;
  final ValueChanged<StatutFilter> onStatusSelected;
  final ValueChanged<PrioriteFilter> onPrioritySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final prenom = prenomTechnicien(technicienNom);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            prenom.isEmpty ? 'Bonjour' : 'Bonjour $prenom',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          _TotalCard(total: summary.total),
          const SizedBox(height: 24),
          Text('Par statut', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _MetricsWrap(
            children: [
              _MetricCard(
                key: const Key('dashboard-planifiees'),
                value: summary.planifiees,
                label: 'Planifiées',
                icon: Icons.schedule_outlined,
                background: colors.primaryContainer,
                foreground: colors.onPrimaryContainer,
                onTap: () => onStatusSelected(StatutFilter.planifiee),
              ),
              _MetricCard(
                key: const Key('dashboard-en-cours'),
                value: summary.enCours,
                label: 'En cours',
                icon: Icons.play_circle_outline,
                background: colors.tertiaryContainer,
                foreground: colors.onTertiaryContainer,
                onTap: () => onStatusSelected(StatutFilter.enCours),
              ),
              _MetricCard(
                key: const Key('dashboard-terminees'),
                value: summary.terminees,
                label: 'Terminées',
                icon: Icons.check_circle_outline,
                background: colors.secondaryContainer,
                foreground: colors.onSecondaryContainer,
                onTap: () => onStatusSelected(StatutFilter.terminee),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Par priorité', style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          _MetricsWrap(
            children: [
              _MetricCard(
                key: const Key('dashboard-priorite-haute'),
                value: summary.prioriteHaute,
                label: 'Haute',
                icon: Icons.priority_high,
                background: colors.errorContainer,
                foreground: colors.onErrorContainer,
                onTap: () => onPrioritySelected(PrioriteFilter.haute),
              ),
              _MetricCard(
                key: const Key('dashboard-priorite-moyenne'),
                value: summary.prioriteMoyenne,
                label: 'Moyenne',
                icon: Icons.remove,
                background: colors.tertiaryContainer,
                foreground: colors.onTertiaryContainer,
                onTap: () => onPrioritySelected(PrioriteFilter.moyenne),
              ),
              _MetricCard(
                key: const Key('dashboard-priorite-basse'),
                value: summary.prioriteBasse,
                label: 'Basse',
                icon: Icons.keyboard_arrow_down,
                background: colors.secondaryContainer,
                foreground: colors.onSecondaryContainer,
                onTap: () => onPrioritySelected(PrioriteFilter.basse),
              ),
            ],
          ),
          if (summary.total == 0) ...[
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    Icon(Icons.assignment_outlined),
                    SizedBox(width: 12),
                    Expanded(child: Text('Aucune intervention disponible.')),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

final class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      key: const Key('dashboard-total'),
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        child: Center(
          child: Column(
            children: [
              Text(
                '$total',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Interventions',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _MetricsWrap extends StatelessWidget {
  const _MetricsWrap({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 340 ? 3 : 2;
        final itemWidth =
            (constraints.maxWidth - (12 * (columns - 1))) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

final class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    super.key,
  });

  final int value;
  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: '$label : $value. Afficher les interventions correspondantes.',
      child: Card(
        color: background,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 116),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: foreground, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    '$value',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
