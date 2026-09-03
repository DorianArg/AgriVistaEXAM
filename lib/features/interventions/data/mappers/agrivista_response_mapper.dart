import 'package:agrivista_field/core/errors/app_failure.dart';
import 'package:agrivista_field/features/interventions/data/models/agrivista_response_dto.dart';
import 'package:agrivista_field/features/interventions/domain/entities/action_historique.dart';
import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';
import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/priorite.dart';
import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';

extension AgriVistaResponseDtoMapper on AgriVistaResponseDto {
  DonneesInterventions toDomain() {
    return DonneesInterventions(
      technicien: technicien.toDomain(),
      interventions: interventions.map((item) => item.toDomain()).toList(),
    );
  }
}

extension TechnicienDtoMapper on TechnicienDto {
  Technicien toDomain() {
    return Technicien(
      id: _nonEmpty(id, 'technicien.id'),
      nom: _nonEmpty(nom, 'technicien.nom'),
    );
  }
}

extension InterventionDtoMapper on InterventionDto {
  Intervention toDomain() {
    if (!latitude.isFinite || !longitude.isFinite) {
      throw const DataParsingFailure(
        'Les coordonnées de l’intervention sont invalides.',
      );
    }

    return Intervention(
      id: _nonEmpty(id, 'intervention.id'),
      station: _nonEmpty(station, 'intervention.station'),
      domaine: _nonEmpty(domaine, 'intervention.domaine'),
      latitude: latitude,
      longitude: longitude,
      priorite: _mapPriorite(priorite),
      statut: _mapStatut(statut),
      datePrevue: _mapDate(datePrevue, 'intervention.datePrevue'),
      description: _nonEmpty(description, 'intervention.description'),
      historique: historique.map((item) => item.toDomain()).toList(),
    );
  }
}

extension ActionHistoriqueDtoMapper on ActionHistoriqueDto {
  ActionHistorique toDomain() {
    return ActionHistorique(
      date: _mapDate(date, 'historique.date'),
      action: _nonEmpty(action, 'historique.action'),
    );
  }
}

StatutIntervention _mapStatut(String value) => switch (value) {
  'planifiee' => StatutIntervention.planifiee,
  'en_cours' => StatutIntervention.enCours,
  'terminee' => StatutIntervention.terminee,
  _ => throw DataParsingFailure('Statut inconnu : $value.'),
};

Priorite _mapPriorite(String value) => switch (value) {
  'haute' => Priorite.haute,
  'moyenne' => Priorite.moyenne,
  'basse' => Priorite.basse,
  _ => throw DataParsingFailure('Priorité inconnue : $value.'),
};

DateTime _mapDate(String value, String fieldName) {
  final date = DateTime.tryParse(value);
  if (date == null) {
    throw DataParsingFailure('Date invalide pour $fieldName : $value.');
  }
  return date;
}

String _nonEmpty(String value, String fieldName) {
  if (value.trim().isEmpty) {
    throw DataParsingFailure('Le champ $fieldName ne peut pas être vide.');
  }
  return value;
}
