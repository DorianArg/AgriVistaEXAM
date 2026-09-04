import 'package:agrivista_field/features/interventions/presentation/providers/intervention_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class InterventionFiltersBar extends ConsumerStatefulWidget {
  const InterventionFiltersBar({super.key});

  @override
  ConsumerState<InterventionFiltersBar> createState() =>
      _InterventionFiltersBarState();
}

final class _InterventionFiltersBarState
    extends ConsumerState<InterventionFiltersBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(interventionFiltersProvider).recherche,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(interventionFiltersProvider);
    final notifier = ref.read(interventionFiltersProvider.notifier);
    ref.listen(interventionFiltersProvider.select((value) => value.recherche), (
      _,
      recherche,
    ) {
      if (_searchController.text != recherche) {
        _searchController.value = TextEditingValue(
          text: recherche,
          selection: TextSelection.collapsed(offset: recherche.length),
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
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
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.sort, size: 20),
            const SizedBox(width: 8),
            Text('Tri :', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 4),
            PopupMenuButton<InterventionSort>(
              key: const Key('intervention-sort-menu'),
              initialValue: filters.tri,
              tooltip: 'Choisir le critère de tri',
              onSelected: notifier.trierPar,
              itemBuilder: (_) => [
                for (final sort in InterventionSort.values)
                  PopupMenuItem(value: sort, child: Text(sort.label)),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(filters.tri.label),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              key: const Key('intervention-sort-direction'),
              tooltip: 'Ordre ${filters.direction.label.toLowerCase()}',
              onPressed: notifier.inverserOrdre,
              icon: Icon(
                filters.direction == SortDirection.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),
          ],
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
