enum StatutIntervention {
  planifiee,
  enCours,
  terminee;

  StatutIntervention? get suivant => switch (this) {
    StatutIntervention.planifiee => StatutIntervention.enCours,
    StatutIntervention.enCours => StatutIntervention.terminee,
    StatutIntervention.terminee => null,
  };
}
