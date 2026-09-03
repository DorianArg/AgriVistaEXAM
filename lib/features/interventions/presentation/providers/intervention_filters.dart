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

final class InterventionFilters {
  const InterventionFilters({
    this.recherche = '',
    this.statut = StatutFilter.tous,
    this.priorite = PrioriteFilter.toutes,
  });

  final String recherche;
  final StatutFilter statut;
  final PrioriteFilter priorite;

  InterventionFilters copyWith({
    String? recherche,
    StatutFilter? statut,
    PrioriteFilter? priorite,
  }) {
    return InterventionFilters(
      recherche: recherche ?? this.recherche,
      statut: statut ?? this.statut,
      priorite: priorite ?? this.priorite,
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
}

List<Intervention> filtrerInterventions(
  Iterable<Intervention> interventions,
  InterventionFilters filters,
) {
  final recherche = filters.recherche.trim().toLowerCase();

  return interventions
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
}
