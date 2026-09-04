import 'package:agrivista_field/features/interventions/domain/entities/compte_rendu_intervention.dart';

abstract interface class CompteRenduRepository {
  Future<CompteRenduIntervention> lire(String interventionId);

  Future<CompteRenduIntervention> enregistrerNote(
    String interventionId,
    String note,
  );

  Future<CompteRenduIntervention> enregistrerPhoto(
    String interventionId,
    String sourcePath,
  );
}
