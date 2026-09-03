import 'package:agrivista_field/features/interventions/domain/entities/statut_intervention.dart';
import 'package:agrivista_field/features/interventions/domain/usecases/obtenir_statut_suivant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const obtenirStatutSuivant = ObtenirStatutSuivant();

  test('une intervention planifiée passe en cours', () {
    expect(
      obtenirStatutSuivant(StatutIntervention.planifiee),
      StatutIntervention.enCours,
    );
  });

  test('une intervention en cours passe à terminée', () {
    expect(
      obtenirStatutSuivant(StatutIntervention.enCours),
      StatutIntervention.terminee,
    );
  });

  test('une intervention terminée ne possède pas de statut suivant', () {
    expect(obtenirStatutSuivant(StatutIntervention.terminee), isNull);
  });
}
