final class CompteRenduIntervention {
  const CompteRenduIntervention({
    required this.interventionId,
    this.note = '',
    this.photoPath,
  });

  final String interventionId;
  final String note;
  final String? photoPath;

  CompteRenduIntervention copyWith({String? note, String? photoPath}) {
    return CompteRenduIntervention(
      interventionId: interventionId,
      note: note ?? this.note,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}
