import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class InterventionFiltersBar extends ConsumerWidget {
  const InterventionFiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(interventionFiltersProvider);
    final notifier = ref.read(interventionFiltersProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: notifier.rechercher,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Rechercher une intervention…',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        _FilterRow<StatutFilter>(
          semanticsLabel: 'Filtrer par statut',
          values: StatutFilter.values,
          selected: filters.statut,
          labelFor: (value) => value.label,
          onSelected: notifier.filtrerParStatut,
        ),
        const SizedBox(height: 10),
        _FilterRow<PrioriteFilter>(
          semanticsLabel: 'Filtrer par priorité',
          values: PrioriteFilter.values,
          selected: filters.priorite,
          labelFor: (value) => value.label,
          onSelected: notifier.filtrerParPriorite,
        ),
      ],
    );
  }
}

final class _FilterRow<T> extends StatelessWidget {
  const _FilterRow({
    required this.semanticsLabel,
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onSelected,
  });

  final String semanticsLabel;
  final List<T> values;
  final T selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      container: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final value in values) ...[
              ChoiceChip(
                label: Text(labelFor(value)),
                selected: value == selected,
                onSelected: (_) => onSelected(value),
              ),
              if (value != values.last) const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}
