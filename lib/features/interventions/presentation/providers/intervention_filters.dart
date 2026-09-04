import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StatutFilter {
  tous,
  planifiee,
  enCours,
  terminee;

  String get label => switch (this) {
    StatutFilter.tous => 'Tous',
    StatutFilter.planifiee => 'Planifiée',
    StatutFilter.enCours => 'En cours',
    StatutFilter.terminee => 'Terminée',
  };
}

enum PrioriteFilter {
  toutes,
  haute,
  moyenne,
  basse;

  String get label => switch (this) {
    PrioriteFilter.toutes => 'Toutes',
    PrioriteFilter.haute => 'Haute',
    PrioriteFilter.moyenne => 'Moyenne',
    PrioriteFilter.basse => 'Basse',
  };
}

enum InterventionSort {
  datePrevue,
  priorite,
  statut;

  String get label => switch (this) {
    InterventionSort.datePrevue => 'Date prévue',
    InterventionSort.priorite => 'Priorité',
    InterventionSort.statut => 'Statut',
  };
}

enum SortDirection {
  ascending,
  descending;

  String get label => switch (this) {
    SortDirection.ascending => 'Croissant',
    SortDirection.descending => 'Décroissant',
  };
}

final class InterventionFilters {
  const InterventionFilters({
    this.recherche = '',
    this.statut = StatutFilter.tous,
    this.priorite = PrioriteFilter.toutes,
    this.tri = InterventionSort.datePrevue,
    this.direction = SortDirection.ascending,
  });

  final String recherche;
  final StatutFilter statut;
  final PrioriteFilter priorite;
  final InterventionSort tri;
  final SortDirection direction;

  InterventionFilters copyWith({
    String? recherche,
    StatutFilter? statut,
    PrioriteFilter? priorite,
    InterventionSort? tri,
    SortDirection? direction,
  }) {
    return InterventionFilters(
      recherche: recherche ?? this.recherche,
      statut: statut ?? this.statut,
      priorite: priorite ?? this.priorite,
      tri: tri ?? this.tri,
      direction: direction ?? this.direction,
    );
  }
}

final interventionFiltersProvider =
    NotifierProvider<InterventionFiltersNotifier, InterventionFilters>(
      InterventionFiltersNotifier.new,
    );

final class InterventionFiltersNotifier extends Notifier<InterventionFilters> {
  @override
  InterventionFilters build() => const InterventionFilters();

  void rechercher(String value) {
    state = state.copyWith(recherche: value);
  }

  void filtrerParStatut(StatutFilter value) {
    state = state.copyWith(statut: value);
  }

  void filtrerParPriorite(PrioriteFilter value) {
    state = state.copyWith(priorite: value);
  }

  void trierPar(InterventionSort value) {
    state = state.copyWith(tri: value);
  }

  void inverserOrdre() {
    state = state.copyWith(
      direction: state.direction == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending,
    );
  }

  void appliquerStatutDepuisDashboard(StatutFilter value) {
    state = InterventionFilters(
      statut: value,
      tri: state.tri,
      direction: state.direction,
    );
  }

  void appliquerPrioriteDepuisDashboard(PrioriteFilter value) {
    state = InterventionFilters(
      priorite: value,
      tri: state.tri,
      direction: state.direction,
    );
  }
}

List<Intervention> filtrerInterventions(
  Iterable<Intervention> interventions,
  InterventionFilters filters,
) {
  final recherche = filters.recherche.trim().toLowerCase();

  final filtered = interventions
      .where((intervention) {
        final correspondRecherche =
            recherche.isEmpty ||
            intervention.station.toLowerCase().contains(recherche) ||
            intervention.domaine.toLowerCase().contains(recherche) ||
            intervention.description.toLowerCase().contains(recherche);

        final correspondStatut = switch (filters.statut) {
          StatutFilter.tous => true,
          StatutFilter.planifiee =>
            intervention.statut == StatutIntervention.planifiee,
          StatutFilter.enCours =>
            intervention.statut == StatutIntervention.enCours,
          StatutFilter.terminee =>
            intervention.statut == StatutIntervention.terminee,
        };

        final correspondPriorite = switch (filters.priorite) {
          PrioriteFilter.toutes => true,
          PrioriteFilter.haute => intervention.priorite == Priorite.haute,
          PrioriteFilter.moyenne => intervention.priorite == Priorite.moyenne,
          PrioriteFilter.basse => intervention.priorite == Priorite.basse,
        };

        return correspondRecherche && correspondStatut && correspondPriorite;
      })
      .toList(growable: false);

  final indexed = filtered.asMap().entries.toList();
  indexed.sort((left, right) {
    final comparison = _compareInterventions(
      left.value,
      right.value,
      filters.tri,
    );
    if (comparison == 0) {
      return left.key.compareTo(right.key);
    }
    return filters.direction == SortDirection.ascending
        ? comparison
        : -comparison;
  });

  return indexed.map((entry) => entry.value).toList(growable: false);
}

int _compareInterventions(
  Intervention left,
  Intervention right,
  InterventionSort sort,
) {
  return switch (sort) {
    InterventionSort.datePrevue => left.datePrevue.compareTo(right.datePrevue),
    InterventionSort.priorite => _prioriteRank(
      left.priorite,
    ).compareTo(_prioriteRank(right.priorite)),
    InterventionSort.statut => _statutRank(
      left.statut,
    ).compareTo(_statutRank(right.statut)),
  };
}

int _prioriteRank(Priorite priorite) => switch (priorite) {
  Priorite.haute => 0,
  Priorite.moyenne => 1,
  Priorite.basse => 2,
};

int _statutRank(StatutIntervention statut) => switch (statut) {
  StatutIntervention.planifiee => 0,
  StatutIntervention.enCours => 1,
  StatutIntervention.terminee => 2,
};
