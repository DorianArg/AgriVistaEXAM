import 'package:agrivista_field/features/interventions/domain/entities/intervention.dart';
import 'package:agrivista_field/features/interventions/domain/entities/technicien.dart';

final class DonneesInterventions {
  DonneesInterventions({
    required this.technicien,
    required List<Intervention> interventions,
  }) : interventions = List.unmodifiable(interventions);

  final Technicien technicien;
  final List<Intervention> interventions;
}
