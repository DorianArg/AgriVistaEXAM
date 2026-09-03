import 'package:agrivista_field/core/utils/date_formatter.dart';
import 'package:agrivista_field/features/interventions/domain/entities/action_historique.dart';
import 'package:flutter/material.dart';

final class InterventionHistory extends StatelessWidget {
  const InterventionHistory({required this.entries, super.key});

  final List<ActionHistorique> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Text('Aucun événement dans l’historique.');
    }

    return Column(
      children: [
        for (var index = 0; index < entries.length; index++)
          _HistoryEntry(
            entry: entries[index],
            isLast: index == entries.length - 1,
          ),
      ],
    );
  }
}

final class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.entry, required this.isLast});

  final ActionHistorique entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatDateFr(entry.date),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(entry.action),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
