import 'package:agrivista_field/features/interventions/domain/entities/donnees_interventions.dart';

abstract interface class InterventionRepository {
  Future<DonneesInterventions> recupererDonneesInitiales();
}
