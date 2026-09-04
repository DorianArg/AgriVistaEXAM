import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/presentation/providers/interventions_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  return ref
      .watch(interventionsProvider)
      .whenData(
        (data) => DashboardSummary.fromInterventions(data.interventions),
      );
});

final class DashboardSummary {
  const DashboardSummary({
    required this.total,
    required this.planifiees,
    required this.enCours,
    required this.terminees,
    required this.prioriteHaute,
    required this.prioriteMoyenne,
    required this.prioriteBasse,
  });

  factory DashboardSummary.fromInterventions(
    Iterable<Intervention> interventions,
  ) {
    var total = 0;
    var planifiees = 0;
    var enCours = 0;
    var terminees = 0;
    var prioriteHaute = 0;
    var prioriteMoyenne = 0;
    var prioriteBasse = 0;

    for (final intervention in interventions) {
      total++;
      switch (intervention.statut) {
        case StatutIntervention.planifiee:
          planifiees++;
        case StatutIntervention.enCours:
          enCours++;
        case StatutIntervention.terminee:
          terminees++;
      }
      switch (intervention.priorite) {
        case Priorite.haute:
          prioriteHaute++;
        case Priorite.moyenne:
          prioriteMoyenne++;
        case Priorite.basse:
          prioriteBasse++;
      }
    }

    return DashboardSummary(
      total: total,
      planifiees: planifiees,
      enCours: enCours,
      terminees: terminees,
      prioriteHaute: prioriteHaute,
      prioriteMoyenne: prioriteMoyenne,
      prioriteBasse: prioriteBasse,
    );
  }

  final int total;
  final int planifiees;
  final int enCours;
  final int terminees;
  final int prioriteHaute;
  final int prioriteMoyenne;
  final int prioriteBasse;
}

String prenomTechnicien(String nomComplet) {
  final nomNormalise = nomComplet.trim();
  if (nomNormalise.isEmpty) {
    return '';
  }
  return nomNormalise.split(RegExp(r'\s+')).first;
}
