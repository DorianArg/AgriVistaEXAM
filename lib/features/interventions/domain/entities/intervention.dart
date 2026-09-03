import 'package:agrivista_field/features/interventions/domain/entities/action_historique.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';

final class Intervention {
  Intervention({
    required this.id,
    required this.station,
    required this.domaine,
    required this.latitude,
    required this.longitude,
    required this.priorite,
    required this.statut,
    required this.datePrevue,
    required this.description,
    required List<ActionHistorique> historique,
  }) : historique = List.unmodifiable(historique);

  final String id;
  final String station;
  final String domaine;
  final double latitude;
  final double longitude;
  final Priorite priorite;
  final StatutIntervention statut;
  final DateTime datePrevue;
  final String description;
  final List<ActionHistorique> historique;

  Intervention avecStatut(StatutIntervention nouveauStatut) {
    return Intervention(
      id: id,
      station: station,
      domaine: domaine,
      latitude: latitude,
      longitude: longitude,
      priorite: priorite,
      statut: nouveauStatut,
      datePrevue: datePrevue,
      description: description,
      historique: historique,
    );
  }
}
